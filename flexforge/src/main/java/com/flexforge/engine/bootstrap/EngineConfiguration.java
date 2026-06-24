package com.flexforge.engine.bootstrap;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.api.graphql.GraphQLSchemaBuilder;
import com.flexforge.engine.config.ConfigLoader;
import com.flexforge.engine.config.ConfigValidator;
import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.AppConfig;
import com.flexforge.engine.config.model.DatabaseConfig;
import com.flexforge.engine.data.DynamicCrudService;
import com.flexforge.engine.schema.SqlDialect;
import com.zaxxer.hikari.HikariDataSource;
import graphql.GraphQL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The composition root. Loads and validates the config bundle, then assembles the engine:
 * datasource (dialect chosen at boot), metadata registry, generic CRUD service, and the
 * REST + GraphQL surfaces. Everything downstream keys off the one {@link MetadataRegistry}.
 */
@Configuration
public class EngineConfiguration {

    private static final Logger log = LoggerFactory.getLogger(EngineConfiguration.class);
    private static final Pattern ENV_PLACEHOLDER = Pattern.compile("^\\$\\{([A-Za-z0-9_]+)}$");

    /** Path to an external config bundle; falls back to the classpath sample if unset. */
    @Value("${flexforge.config.path:}")
    private String configPath;

    @Bean
    public ConfigLoader configLoader() {
        return new ConfigLoader();
    }

    @Bean
    public ConfigValidator configValidator() {
        return new ConfigValidator();
    }

    @Bean
    public AppConfig appConfig(ConfigLoader loader, ConfigValidator validator) {
        AppConfig config;
        JsonNode tree;
        if (configPath != null && !configPath.isBlank() && !configPath.startsWith("classpath:")) {
            Path path = Path.of(configPath);
            if (!Files.exists(path)) {
                throw new IllegalStateException("Configured flexforge.config.path does not exist: " + path);
            }
            log.info("[engine] loading config bundle from file: {}", path);
            config = loader.loadFromPath(path);
            tree = loader.readTree(path);
        } else {
            String resourceName = (configPath != null && configPath.startsWith("classpath:"))
                    ? configPath.substring("classpath:".length())
                    : "config/app.yaml";
            boolean json = resourceName.endsWith(".json");
            log.info("[engine] loading classpath config: {}", resourceName);
            ClassPathResource resource = new ClassPathResource(resourceName);
            try (InputStream in = resource.getInputStream()) {
                config = loader.loadFromStream(in, json);
            } catch (Exception e) {
                throw new IllegalStateException("Failed to read classpath config: " + resourceName, e);
            }
            try (InputStream in = resource.getInputStream()) {
                tree = (json ? new com.fasterxml.jackson.databind.ObjectMapper()
                        : new com.fasterxml.jackson.dataformat.yaml.YAMLMapper()).readTree(in);
            } catch (Exception e) {
                throw new IllegalStateException("Failed to parse classpath config: " + resourceName, e);
            }
        }
        validator.validate(tree, config);
        log.info("[engine] config '{}' v{} validated: {} entit(ies), REST={}, GraphQL={}",
                config.appId, config.configVersion, config.entities.size(),
                config.api.rest.enabled, config.api.graphql.enabled);
        return config;
    }

    @Bean
    public MetadataRegistry metadataRegistry(AppConfig appConfig) {
        return new MetadataRegistry(appConfig);
    }

    @Bean
    public com.flexforge.engine.config.model.SecurityConfig securityConfig(AppConfig appConfig) {
        return appConfig.security == null
                ? new com.flexforge.engine.config.model.SecurityConfig()
                : appConfig.security;
    }

    @Bean
    public com.flexforge.engine.auth.JwtService jwtService(
            com.flexforge.engine.config.model.SecurityConfig security) {
        return new com.flexforge.engine.auth.JwtService(security);
    }

    @Bean
    public com.flexforge.engine.auth.AccessGuard accessGuard(
            com.flexforge.engine.config.model.SecurityConfig security) {
        return new com.flexforge.engine.auth.AccessGuard(security);
    }

    @Bean
    public com.flexforge.engine.crypto.EncryptionService encryptionService(
            com.flexforge.engine.config.model.SecurityConfig security) {
        return new com.flexforge.engine.crypto.EncryptionService(resolve(security.encryptionKey));
    }

    @Bean
    public com.flexforge.engine.ai.AiProvider aiProvider(AppConfig appConfig, ObjectMapper objectMapper) {
        com.flexforge.engine.config.model.AiConfig ai =
                appConfig.ai == null ? new com.flexforge.engine.config.model.AiConfig() : appConfig.ai;
        ai.apiKey = resolve(ai.apiKey);
        if (ai.apiKey != null && !ai.apiKey.isBlank() && !"stub".equalsIgnoreCase(ai.provider)) {
            log.info("[engine] AI provider: {} ({})", ai.provider, ai.model);
            return new com.flexforge.engine.ai.OpenAiCompatibleProvider(ai, objectMapper);
        }
        log.info("[engine] AI provider: stub (no apiKey configured)");
        return new com.flexforge.engine.ai.StubAiProvider();
    }

    @Bean
    public SqlDialect sqlDialect(AppConfig appConfig) {
        String engine = resolve(appConfig.database == null ? null : appConfig.database.engine);
        if (engine == null || engine.isBlank()) {
            engine = "h2";
        }
        log.info("[engine] database dialect: {}", engine);
        return SqlDialect.forEngine(engine);
    }

    @Bean(destroyMethod = "close")
    public DataSource dataSource(AppConfig appConfig, SqlDialect dialect) {
        DatabaseConfig db = appConfig.database == null ? new DatabaseConfig() : appConfig.database;
        String url = resolve(db.url);
        if (url == null || url.isBlank()) {
            if (!"h2".equals(dialect.key())) {
                throw new IllegalStateException("database.url is required for engine '" + dialect.key() + "'");
            }
            url = "jdbc:h2:mem:flexforge;DB_CLOSE_DELAY=-1;MODE=LEGACY";
            log.info("[engine] no database.url set — defaulting to in-memory H2");
        }

        HikariDataSource ds = DataSourceBuilder.create()
                .type(HikariDataSource.class)
                .url(url)
                .username(resolve(db.username))
                .password(resolve(db.password))
                .build();
        ds.setMaximumPoolSize(db.pool.maxSize);
        ds.setMinimumIdle(db.pool.minIdle);
        ds.setMaxLifetime(db.pool.maxLifetimeMs);
        ds.setPoolName("flexforge-" + appConfig.appId);
        return ds;
    }

    @Bean
    public DynamicCrudService dynamicCrudService(NamedParameterJdbcTemplate jdbc,
                                                 MetadataRegistry registry,
                                                 SqlDialect dialect,
                                                 ObjectMapper objectMapper,
                                                 com.flexforge.engine.crypto.EncryptionService encryption,
                                                 org.springframework.context.ApplicationEventPublisher events) {
        return new DynamicCrudService(jdbc, registry, dialect, objectMapper, encryption, events);
    }

    @Bean
    public GraphQLSchemaBuilder graphQLSchemaBuilder(MetadataRegistry registry, DynamicCrudService crud,
                                                     com.flexforge.engine.auth.AccessGuard accessGuard) {
        return new GraphQLSchemaBuilder(registry, crud, accessGuard);
    }

    @Bean
    public GraphQL graphQL(GraphQLSchemaBuilder builder) {
        return GraphQL.newGraphQL(builder.build()).build();
    }

    /** Resolve a ${ENV_VAR} placeholder to its environment value; pass through literals. */
    private static String resolve(String value) {
        if (value == null) {
            return null;
        }
        Matcher m = ENV_PLACEHOLDER.matcher(value.trim());
        if (m.matches()) {
            String env = System.getenv(m.group(1));
            return env != null ? env : System.getProperty(m.group(1));
        }
        return value;
    }
}
