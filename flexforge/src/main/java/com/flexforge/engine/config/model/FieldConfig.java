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

    // ---- declarative validation rules (enforced by FieldValidator) ----

    /** Minimum string length. */
    public Integer minLength;

    /** Maximum string length. */
    public Integer maxLength;

    /** Minimum numeric value (INT/LONG/DOUBLE/DECIMAL). */
    public Double min;

    /** Maximum numeric value. */
    public Double max;

    /** Regex the value must fully match (STRING/TEXT). */
    public String pattern;

    /** Convenience flag: value must look like an email address. */
    public boolean email = false;

    /** Whether this field is shown/managed in the generated UI (default true). */
    public boolean uiVisible = true;
}
