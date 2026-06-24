package com.flexforge.engine.realtime;

import java.time.Instant;
import java.util.Map;

/**
 * A data-change event emitted by the CRUD engine. It feeds every real-time protocol
 * surface (SSE, WebSocket) and the recent-events buffer — one event source, many
 * transports, mirroring how the same data model feeds REST and GraphQL.
 */
public record EntityEvent(String entity, String op, Object id, Map<String, Object> data, String at) {

    public static EntityEvent of(String entity, String op, Object id, Map<String, Object> data) {
        return new EntityEvent(entity, op, id, data, Instant.now().toString());
    }
}
