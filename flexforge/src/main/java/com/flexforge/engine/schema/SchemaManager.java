package com.flexforge.engine.schema;

import com.flexforge.engine.config.model.AppConfig;
import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Brings the live database into line with the data model declared in config.
 *
 * <p>v0 strategy (deliberately conservative):
 * <ul>
 *   <li>Create missing tables ({@code CREATE TABLE IF NOT EXISTS}).</li>
 *   <li>Add missing columns ({@code ALTER TABLE ADD COLUMN}) — additive, safe, auto.</li>
 *   <li>Never drop or narrow anything. Columns present in the DB but absent from config
 *       are reported and left untouched (destructive = require_approval).</li>
 * </ul>
 *
 * <p>The production engine routes all of this through Liquibase's programmatic diff with
 * an expand/contract + preview/approve gate (ROADMAP v2). This class is the seam where
 * that swap happens.
 */
public class SchemaManager {

    private static final Logger log = LoggerFactory.getLogger(SchemaManager.class);

    private final JdbcTemplate jdbc;
    private final DataSource dataSource;
    private final SqlDialect dialect;

    public SchemaManager(JdbcTemplate jdbc, DataSource dataSource, SqlDialect dialect) {
        this.jdbc = jdbc;
        this.dataSource = dataSource;
        this.dialect = dialect;
    }

    public void sync(AppConfig config) {
        for (EntityConfig entity : config.entities) {
            String table = Naming.tableName(entity);
            Set<String> existing = existingColumns(table);
            if (existing.isEmpty()) {
                createTable(entity);
            } else {
                addMissingColumns(entity, existing);
                reportOrphanColumns(entity, existing);
            }
        }
    }

    private void createTable(EntityConfig entity) {
        String table = Naming.tableName(entity);
        StringBuilder ddl = new StringBuilder("CREATE TABLE IF NOT EXISTS ")
                .append(dialect.quote(table))
                .append(" (");
        boolean first = true;
        for (FieldConfig f : entity.fields) {
            if (!first) {
                ddl.append(", ");
            }
            ddl.append(columnDefinition(f));
            first = false;
        }
        ddl.append(")");
        log.info("[schema] creating table {}", table);
        jdbc.execute(ddl.toString());
    }

    private void addMissingColumns(EntityConfig entity, Set<String> existing) {
        String table = Naming.tableName(entity);
        for (FieldConfig f : entity.fields) {
            String col = Naming.columnName(f);
            if (!existing.contains(col.toLowerCase())) {
                if (f.pk) {
                    throw new IllegalStateException(
                            "Cannot add a primary key column '" + col + "' to existing table '"
                                    + table + "'. This is a destructive change requiring approval.");
                }
                String alter = "ALTER TABLE " + dialect.quote(table)
                        + " ADD COLUMN " + columnDefinition(f);
                log.info("[schema] additive change: {}", alter);
                jdbc.execute(alter);
            }
        }
    }

    private void reportOrphanColumns(EntityConfig entity, Set<String> existing) {
        String table = Naming.tableName(entity);
        Set<String> declared = new LinkedHashSet<>();
        for (FieldConfig f : entity.fields) {
            declared.add(Naming.columnName(f).toLowerCase());
        }
        for (String dbCol : existing) {
            if (!declared.contains(dbCol)) {
                log.warn("[schema] column '{}.{}' exists in the database but not in config. "
                        + "Leaving it untouched (destructive drop requires approval).", table, dbCol);
            }
        }
    }

    private String columnDefinition(FieldConfig f) {
        String col = dialect.quote(Naming.columnName(f));
        if (f.pk) {
            return dialect.autoIncrementPk(col);
        }
        StringBuilder def = new StringBuilder(col)
                .append(' ')
                .append(dialect.columnType(f.type, f.length));
        if (!f.nullable) {
            def.append(" NOT NULL");
        }
        if (f.unique) {
            def.append(" UNIQUE");
        }
        return def.toString();
    }

    private Set<String> existingColumns(String table) {
        Set<String> cols = new LinkedHashSet<>();
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            // Try both cases — different engines store identifiers in different cases.
            for (String candidate : new String[]{table, table.toUpperCase(), table.toLowerCase()}) {
                try (ResultSet rs = meta.getColumns(conn.getCatalog(), null, candidate, null)) {
                    while (rs.next()) {
                        cols.add(rs.getString("COLUMN_NAME").toLowerCase());
                    }
                }
                if (!cols.isEmpty()) {
                    break;
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to introspect schema for table " + table, e);
        }
        return cols;
    }
}
