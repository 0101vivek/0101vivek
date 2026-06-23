package com.flexforge.engine.config.model;

import java.util.ArrayList;
import java.util.List;

/**
 * An entity = a table + its exposed API surface. Defined purely by metadata.
 */
public class EntityConfig {

    /** Logical name, e.g. "Customer". Mapped to a canonical snake_case table name. */
    public String name;

    /** Optional explicit table name; defaults to snake_case(name) pluralized minimally. */
    public String table;

    /** Identifier generation strategy: SEQUENCE (preferred) or IDENTITY. */
    public String idStrategy = "IDENTITY";

    public List<FieldConfig> fields = new ArrayList<>();

    public FieldConfig primaryKey() {
        for (FieldConfig f : fields) {
            if (f.pk) {
                return f;
            }
        }
        return null;
    }

    public FieldConfig field(String fieldName) {
        for (FieldConfig f : fields) {
            if (f.name.equalsIgnoreCase(fieldName)) {
                return f;
            }
        }
        return null;
    }
}
