package com.flexforge.engine.schema;

import com.flexforge.engine.config.model.FieldType;

/**
 * Encapsulates the per-database differences the engine must bridge: column type mapping,
 * identifier quoting, identity/sequence syntax and pagination. In v0 this is a small
 * hand-rolled abstraction over H2/Postgres/MySQL; the production engine delegates the
 * heavy lifting to Hibernate 6 + jOOQ (see ARCHITECTURE.md / ROADMAP.md), but the shape
 * of the seam stays the same.
 */
public interface SqlDialect {

    /** Engine key used in config: "h2", "postgres", "mysql". */
    String key();

    /** Concrete column type for a logical field type (length used for STRING). */
    String columnType(FieldType type, Integer length);

    /** Column fragment that makes an integer PK auto-generate, e.g. "BIGINT GENERATED ...". */
    String autoIncrementPk(String quotedColumn);

    /** Quote an identifier so casing/keywords behave identically everywhere. */
    String quote(String identifier);

    /** Pagination suffix, e.g. "LIMIT :limit OFFSET :offset". */
    default String paginate() {
        return "LIMIT :limit OFFSET :offset";
    }

    static SqlDialect forEngine(String engine) {
        String e = engine == null ? "h2" : engine.trim().toLowerCase();
        return switch (e) {
            case "postgres", "postgresql" -> new PostgresDialect();
            case "mysql", "mariadb" -> new MySqlDialect();
            case "h2" -> new H2Dialect();
            default -> throw new IllegalArgumentException(
                    "Unsupported database engine '" + engine + "'. Supported: h2, postgres, mysql.");
        };
    }
}
