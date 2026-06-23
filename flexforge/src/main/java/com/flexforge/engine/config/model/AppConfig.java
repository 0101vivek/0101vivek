package com.flexforge.engine.config.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Root of an immutable, versioned config bundle. This is the single source of truth
 * for an application: the engine interprets it at runtime to become the app. There is
 * no per-app source code anywhere — only this declarative metadata.
 */
public class AppConfig {

    /** Stable application identifier, e.g. "crm-acme". */
    public String appId;

    /** Semantic version of this config bundle, e.g. "1.4.0". */
    public String configVersion;

    /** Engine version this bundle is pinned to / tested against, e.g. "0.1.x". */
    public String engineVersion;

    /** Database connection + pool settings (values may be ${ENV} placeholders). */
    public DatabaseConfig database;

    /** Data model: the entities (tables) the app is made of. */
    public List<EntityConfig> entities = new ArrayList<>();

    /** Which API protocols to expose over the data model (REST, GraphQL, ...). */
    public ApiConfig api = new ApiConfig();

    /** How schema changes are applied across regenerations. */
    public MigrationPolicy migrationPolicy = new MigrationPolicy();

    public EntityConfig entity(String name) {
        for (EntityConfig e : entities) {
            if (e.name.equalsIgnoreCase(name)) {
                return e;
            }
        }
        return null;
    }
}
