package com.flexforge.engine.config.model;

/**
 * Logical field types. The schema layer maps each to a dialect-correct column type and
 * the data layer maps each to a JDBC type. Keeping a small logical vocabulary is what
 * lets one config run unchanged across databases.
 */
public enum FieldType {
    STRING,
    TEXT,
    INT,
    LONG,
    DOUBLE,
    DECIMAL,
    BOOLEAN,
    DATE,
    TIMESTAMP,
    JSON,
    /** Foreign-key style link to another entity's primary key (see FieldConfig.references). */
    REFERENCE,
    /** Stored file/image/document: JSON metadata + base64 content, served via the file API. */
    FILE,
    /** Single choice from FieldConfig.options. */
    SELECT,
    /** Multiple choices from FieldConfig.options (stored comma-separated). */
    MULTISELECT,
    /** Not stored; computed on read from FieldConfig.formula (a ${field} template). */
    FORMULA
}
