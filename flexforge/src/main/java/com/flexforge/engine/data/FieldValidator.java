package com.flexforge.engine.data;

import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;
import com.flexforge.engine.error.ValidationException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Enforces the declarative validation rules on {@link FieldConfig} before a write. Like
 * everything else in FlexForge these rules are config, not code — the engine applies them
 * uniformly no matter which protocol the write came in on.
 */
public final class FieldValidator {

    private static final Pattern EMAIL =
            Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    private FieldValidator() {
    }

    /**
     * @param create true for inserts (missing required fields are errors), false for
     *               partial updates (only supplied fields are checked).
     */
    public static void validate(EntityConfig entity, Map<String, Object> data, boolean create) {
        List<String> errors = new ArrayList<>();
        for (FieldConfig f : entity.fields) {
            if (f.pk) {
                continue;
            }
            boolean present = data.containsKey(f.name) && data.get(f.name) != null;

            if (create && !f.nullable && !present) {
                errors.add(f.name + " is required");
                continue;
            }
            if (!present) {
                continue;
            }
            validateValue(f, data.get(f.name), errors);
        }
        if (!errors.isEmpty()) {
            throw new ValidationException(errors);
        }
    }

    private static List<String> toList(Object value) {
        if (value instanceof List<?> list) {
            List<String> out = new ArrayList<>();
            for (Object o : list) {
                out.add(String.valueOf(o));
            }
            return out;
        }
        List<String> out = new ArrayList<>();
        for (String part : value.toString().split(",")) {
            if (!part.isBlank()) {
                out.add(part.trim());
            }
        }
        return out;
    }

    private static void validateValue(FieldConfig f, Object value, List<String> errors) {
        if (f.type == com.flexforge.engine.config.model.FieldType.SELECT
                && f.options != null && !f.options.isEmpty()) {
            if (!f.options.contains(value.toString())) {
                errors.add(f.name + " must be one of " + f.options);
            }
            return;
        }
        if (f.type == com.flexforge.engine.config.model.FieldType.MULTISELECT
                && f.options != null && !f.options.isEmpty()) {
            for (Object item : toList(value)) {
                if (!f.options.contains(String.valueOf(item).trim())) {
                    errors.add(f.name + " contains '" + item + "' not in " + f.options);
                }
            }
            return;
        }
        String s = value.toString();

        if (f.minLength != null && s.length() < f.minLength) {
            errors.add(f.name + " must be at least " + f.minLength + " characters");
        }
        if (f.maxLength != null && s.length() > f.maxLength) {
            errors.add(f.name + " must be at most " + f.maxLength + " characters");
        }
        if (f.email && !EMAIL.matcher(s).matches()) {
            errors.add(f.name + " must be a valid email address");
        }
        if (f.pattern != null && !Pattern.matches(f.pattern, s)) {
            errors.add(f.name + " does not match the required format");
        }
        if (f.min != null || f.max != null) {
            try {
                double n = Double.parseDouble(s);
                if (f.min != null && n < f.min) {
                    errors.add(f.name + " must be >= " + f.min);
                }
                if (f.max != null && n > f.max) {
                    errors.add(f.name + " must be <= " + f.max);
                }
            } catch (NumberFormatException e) {
                errors.add(f.name + " must be a number");
            }
        }
    }
}
