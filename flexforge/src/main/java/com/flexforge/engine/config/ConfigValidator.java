package com.flexforge.engine.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion;
import com.networknt.schema.ValidationMessage;
import com.flexforge.engine.config.model.AppConfig;
import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

/**
 * Validates a config bundle in two layers:
 * <ol>
 *   <li><b>Structural</b> — against the published JSON Schema (the product contract).</li>
 *   <li><b>Semantic</b> — rules JSON Schema can't easily express (exactly one PK per
 *       entity, no duplicate field names, etc.).</li>
 * </ol>
 * Nothing is allowed to deploy until it validates, which is what keeps the regenerate
 * loop deterministic and safe.
 */
public class ConfigValidator {

    private static final String SCHEMA_RESOURCE = "/schema/flexforge-config.schema.json";

    /** Throws {@link ConfigValidationException} with all problems if the bundle is invalid. */
    public void validate(JsonNode rawTree, AppConfig config) {
        List<String> errors = new ArrayList<>();
        errors.addAll(validateStructure(rawTree));
        errors.addAll(validateSemantics(config));
        if (!errors.isEmpty()) {
            throw new ConfigValidationException(errors);
        }
    }

    private List<String> validateStructure(JsonNode rawTree) {
        List<String> out = new ArrayList<>();
        try (InputStream schemaStream = getClass().getResourceAsStream(SCHEMA_RESOURCE)) {
            if (schemaStream == null) {
                out.add("Config JSON Schema resource not found: " + SCHEMA_RESOURCE);
                return out;
            }
            JsonSchemaFactory factory =
                    JsonSchemaFactory.getInstance(SpecVersion.VersionFlag.V202012);
            JsonSchema schema = factory.getSchema(schemaStream);
            Set<ValidationMessage> messages = schema.validate(rawTree);
            Set<String> sorted = new TreeSet<>();
            for (ValidationMessage m : messages) {
                sorted.add("schema: " + m.getMessage());
            }
            out.addAll(sorted);
        } catch (Exception e) {
            out.add("schema validation failed: " + e.getMessage());
        }
        return out;
    }

    private List<String> validateSemantics(AppConfig config) {
        List<String> out = new ArrayList<>();
        if (config.appId == null || config.appId.isBlank()) {
            out.add("appId is required");
        }
        if (config.entities == null || config.entities.isEmpty()) {
            out.add("at least one entity is required");
            return out;
        }
        Set<String> entityNames = new HashSet<>();
        for (EntityConfig entity : config.entities) {
            if (entity.name == null || entity.name.isBlank()) {
                out.add("entity name is required");
                continue;
            }
            if (!entityNames.add(entity.name.toLowerCase())) {
                out.add("duplicate entity name: " + entity.name);
            }
            int pkCount = 0;
            Set<String> fieldNames = new HashSet<>();
            for (FieldConfig f : entity.fields) {
                if (f.name == null || f.name.isBlank()) {
                    out.add(entity.name + ": field name is required");
                    continue;
                }
                if (!fieldNames.add(f.name.toLowerCase())) {
                    out.add(entity.name + ": duplicate field name '" + f.name + "'");
                }
                if (f.pk) {
                    pkCount++;
                }
            }
            if (pkCount != 1) {
                out.add(entity.name + ": exactly one primary-key field is required (found " + pkCount + ")");
            }
        }
        return out;
    }
}
