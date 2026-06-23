package com.flexforge.engine.config;

import com.flexforge.engine.config.model.AppConfig;
import com.flexforge.engine.config.model.EntityConfig;

import java.util.List;

/**
 * The parsed, validated config held in memory. Every layer (schema, data, REST, GraphQL)
 * keys off this — exactly like Mendix keeps its app model in memory and reinterprets it.
 * Swapping the registry contents is how a config hot-reload would take effect (ROADMAP v3).
 */
public class MetadataRegistry {

    private final AppConfig config;

    public MetadataRegistry(AppConfig config) {
        this.config = config;
    }

    public AppConfig config() {
        return config;
    }

    public List<EntityConfig> entities() {
        return config.entities;
    }

    public EntityConfig require(String entityName) {
        EntityConfig e = config.entity(entityName);
        if (e == null) {
            throw new IllegalArgumentException("Unknown entity '" + entityName + "'");
        }
        return e;
    }

    public boolean hasEntity(String entityName) {
        return config.entity(entityName) != null;
    }
}
