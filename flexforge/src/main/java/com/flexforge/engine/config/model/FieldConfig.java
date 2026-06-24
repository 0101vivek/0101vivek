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

    /** For REFERENCE fields: the target entity name this field links to. */
    public String references;

    /** When true, the value is stored AES-256-GCM encrypted at rest and decrypted on read.
     *  Use with STRING/TEXT (ciphertext is longer than plaintext — prefer TEXT). */
    public boolean encrypted = false;

    /** Allowed values for SELECT / MULTISELECT fields. */
    public java.util.List<String> options = new java.util.ArrayList<>();

    /** For FORMULA fields: a ${field} template computed on read, e.g. "${tier} - ${fullName}". */
    public String formula;

    /** LOOKUP: name of the REFERENCE field on this entity to follow. */
    public String reference;

    /** LOOKUP: field on the referenced entity to pull. ROLLUP: child field to aggregate. */
    public String field;

    /** ROLLUP: child entity name. */
    public String from;

    /** ROLLUP: the REFERENCE field on the child entity that points back to this entity. */
    public String via;

    /** ROLLUP: count | sum | avg | min | max. */
    public String op;

    /** Whether this field is stored in the database (false for FORMULA/LOOKUP/ROLLUP). */
    public boolean isStored() {
        return type != FieldType.FORMULA && type != FieldType.LOOKUP && type != FieldType.ROLLUP;
    }
}
