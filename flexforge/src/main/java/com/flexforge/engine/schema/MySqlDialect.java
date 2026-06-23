package com.flexforge.engine.schema;

import com.flexforge.engine.config.model.FieldType;

/** MySQL / MariaDB dialect. Identifiers are quoted with backticks. */
public class MySqlDialect implements SqlDialect {

    @Override
    public String key() {
        return "mysql";
    }

    @Override
    public String columnType(FieldType type, Integer length) {
        return switch (type) {
            case STRING -> "VARCHAR(" + (length == null ? 255 : length) + ")";
            case TEXT -> "TEXT";
            case INT -> "INT";
            case LONG -> "BIGINT";
            case DOUBLE -> "DOUBLE";
            case DECIMAL -> "DECIMAL(19,4)";
            case BOOLEAN -> "TINYINT(1)";
            case DATE -> "DATE";
            case TIMESTAMP -> "DATETIME";
            case JSON -> "JSON";
            case REFERENCE -> "BIGINT";
        };
    }

    @Override
    public String autoIncrementPk(String quotedColumn) {
        return quotedColumn + " BIGINT AUTO_INCREMENT PRIMARY KEY";
    }

    @Override
    public String quote(String identifier) {
        return "`" + identifier + "`";
    }
}
