package com.flexforge.engine.config.model;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * A custom endpoint declared in config (beyond CRUD). It captures the "flow" the user
 * described: a method, required params and required headers (with explicit checks), and
 * an action to perform — return JSON, redirect to a UI URL, or call a third-party webhook.
 * Served under {@code /run/{name}}.
 */
public class EndpointConfig {

    public String name;

    /** HTTP method this endpoint accepts (GET/POST/...). */
    public String method = "GET";

    /** Headers that must be present, e.g. ["X-API-Key", "X-Tenant"]. */
    public List<String> requiredHeaders = new ArrayList<>();

    /** Query params that must be present. */
    public List<String> requiredParams = new ArrayList<>();

    /** What the endpoint does when the request is valid. */
    public ActionConfig action = new ActionConfig();

    public static class ActionConfig {
        /** json | redirect | webhook */
        public String type = "json";

        /** Target URL for redirect/webhook actions (may be a UI URL). */
        public String url;

        /** HTTP status for a json/redirect response (defaults: 200 / 302). */
        public Integer status;

        /** Static body returned for a json action. */
        public Map<String, Object> body = new LinkedHashMap<>();

        /** Extra response/request headers. */
        public Map<String, String> headers = new LinkedHashMap<>();
    }
}
