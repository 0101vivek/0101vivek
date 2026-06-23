package com.flexforge.engine.config.model;

/**
 * A single field on an entity. The {@link FieldType} is dialect-mapped to a concrete
 * column type by the schema layer, so the same config produces correct DDL on every DB.
 */
public class FieldConfig {

    public String name;

    /** Logical type; see {@link FieldType}. */
    public FieldType type = FieldType.STRING;

    public boolean pk = false;

    public boolean unique = false;

    public boolean nullable = true;

    /** Length for STRING columns (VARCHAR). */
    public Integer length;

    /** Column name override; defaults to snake_case(name). */
    public String column;
}
