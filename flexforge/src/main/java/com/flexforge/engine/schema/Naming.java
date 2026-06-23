package com.flexforge.engine.schema;

import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;

/**
 * Canonical naming strategy. The engine emits a single convention (snake_case,
 * consistently quoted) so identifiers behave identically across databases that fold
 * case differently (Postgres lower, Oracle upper, MySQL platform-dependent).
 */
public final class Naming {

    private Naming() {
    }

    public static String snake(String input) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            if (Character.isUpperCase(c)) {
                if (i > 0) {
                    sb.append('_');
                }
                sb.append(Character.toLowerCase(c));
            } else if (c == ' ' || c == '-') {
                sb.append('_');
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    public static String tableName(EntityConfig entity) {
        if (entity.table != null && !entity.table.isBlank()) {
            return entity.table;
        }
        return snake(entity.name);
    }

    public static String columnName(FieldConfig field) {
        if (field.column != null && !field.column.isBlank()) {
            return field.column;
        }
        return snake(field.name);
    }
}
