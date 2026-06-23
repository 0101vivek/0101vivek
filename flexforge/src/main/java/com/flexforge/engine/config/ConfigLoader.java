package com.flexforge.engine.config;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import com.flexforge.engine.config.model.AppConfig;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Loads a config bundle (YAML or JSON) into {@link AppConfig}. The bundle is the only
 * editable surface of an app; the engine treats it as immutable at runtime.
 */
public class ConfigLoader {

    private final ObjectMapper yamlMapper;
    private final ObjectMapper jsonMapper;

    public ConfigLoader() {
        this.yamlMapper = configure(new ObjectMapper(new YAMLFactory()));
        this.jsonMapper = configure(new ObjectMapper());
    }

    private static ObjectMapper configure(ObjectMapper mapper) {
        // Config models are compact POJOs with public fields and no getters/setters.
        mapper.setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY);
        mapper.setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);
        mapper.setVisibility(PropertyAccessor.IS_GETTER, JsonAutoDetect.Visibility.NONE);
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        return mapper;
    }

    public AppConfig loadFromPath(Path path) {
        try {
            byte[] bytes = Files.readAllBytes(path);
            ObjectMapper mapper = isJson(path.getFileName().toString()) ? jsonMapper : yamlMapper;
            return mapper.readValue(bytes, AppConfig.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load config bundle from " + path, e);
        }
    }

    public AppConfig loadFromStream(InputStream in, boolean json) {
        try {
            ObjectMapper mapper = json ? jsonMapper : yamlMapper;
            return mapper.readValue(in, AppConfig.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load config bundle from stream", e);
        }
    }

    /** Parse a bundle into a generic tree for JSON Schema validation. */
    public JsonNode readTree(Path path) {
        try {
            byte[] bytes = Files.readAllBytes(path);
            ObjectMapper mapper = isJson(path.getFileName().toString()) ? jsonMapper : yamlMapper;
            return mapper.readTree(bytes);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to parse config bundle from " + path, e);
        }
    }

    private boolean isJson(String fileName) {
        return fileName.endsWith(".json");
    }
}
