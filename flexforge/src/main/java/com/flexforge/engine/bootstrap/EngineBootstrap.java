package com.flexforge.engine.bootstrap;

import com.flexforge.engine.config.model.AppConfig;
import com.flexforge.engine.schema.SchemaManager;
import com.flexforge.engine.schema.SqlDialect;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * Runs once on startup, during bean initialization (before the web server accepts
 * traffic), to bring the database in line with the data model. In production this is
 * where the Liquibase diff + migration gate plugs in (ROADMAP v2).
 */
@Component
public class EngineBootstrap {

    private static final Logger log = LoggerFactory.getLogger(EngineBootstrap.class);

    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private final SqlDialect dialect;
    private final AppConfig config;

    public EngineBootstrap(JdbcTemplate jdbcTemplate, DataSource dataSource,
                           SqlDialect dialect, AppConfig config) {
        this.jdbcTemplate = jdbcTemplate;
        this.dataSource = dataSource;
        this.dialect = dialect;
        this.config = config;
    }

    @PostConstruct
    public void syncSchema() {
        log.info("[engine] synchronizing schema for app '{}' on {} dialect", config.appId, dialect.key());
        new SchemaManager(jdbcTemplate, dataSource, dialect).sync(config);
        log.info("[engine] schema ready — app '{}' is live", config.appId);
    }
}
