package com.flexforge.engine.data;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Remembers the result of a write keyed by a client-supplied Idempotency-Key, so a retried
 * request (network hiccup, webhook redelivery) returns the original result instead of
 * creating a duplicate. This is a universal requirement for any money-moving app and a
 * platform primitive rather than per-app code.
 *
 * <p>v0 is an in-memory store; production uses a TTL'd shared store (Redis/DB).
 */
@Component
public class IdempotencyStore {

    private final Map<String, Object> store = new ConcurrentHashMap<>();

    public Optional<Object> get(String scope, String key) {
        return Optional.ofNullable(store.get(scope + ":" + key));
    }

    public void put(String scope, String key, Object value) {
        store.put(scope + ":" + key, value);
    }
}
