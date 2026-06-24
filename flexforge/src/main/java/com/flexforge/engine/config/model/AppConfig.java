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

    /** Config-driven authentication & authorization (JWT). Disabled by default. */
    public SecurityConfig security = new SecurityConfig();

    /** Custom endpoints beyond CRUD (redirects, static responses, webhooks). */
    public List<EndpointConfig> endpoints = new ArrayList<>();

    /** No-code flows: trigger -> steps (logic/actions). */
    public List<FlowConfig> flows = new ArrayList<>();

    /** AI provider configuration for the 'ai' flow step. */
    public AiConfig ai = new AiConfig();

    public FlowConfig flow(String name) {
        for (FlowConfig f : flows) {
            if (f.name != null && f.name.equalsIgnoreCase(name)) {
                return f;
            }
        }
        return null;
    }

    public EndpointConfig endpoint(String name) {
        for (EndpointConfig e : endpoints) {
            if (e.name != null && e.name.equalsIgnoreCase(name)) {
                return e;
            }
        }
        return null;
    }

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
