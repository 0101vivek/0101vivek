package com.flexforge.engine.api.rest;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.data.DynamicCrudService;
import com.flexforge.engine.data.Page;
import com.flexforge.engine.data.QueryOptions;
import com.flexforge.engine.error.NotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Set;

/**
 * One controller, every entity. Routes {@code /api/{entity}} CRUD onto the generic
 * {@link DynamicCrudService}. The set of valid entities — and whether REST is exposed at
 * all — comes entirely from the config bundle.
 */
@RestController
@RequestMapping("/api")
public class DynamicRestController {

    private static final Set<String> RESERVED = Set.of("page", "size", "sort", "direction");

    private final DynamicCrudService crud;
    private final MetadataRegistry registry;
    private final com.flexforge.engine.auth.AccessGuard accessGuard;

    private final com.flexforge.engine.data.IdempotencyStore idempotency;

    public DynamicRestController(DynamicCrudService crud, MetadataRegistry registry,
                                 com.flexforge.engine.auth.AccessGuard accessGuard,
                                 com.flexforge.engine.data.IdempotencyStore idempotency) {
        this.crud = crud;
        this.registry = registry;
        this.accessGuard = accessGuard;
        this.idempotency = idempotency;
    }

    @GetMapping("/{entity}")
    public Page list(@PathVariable String entity,
                     @RequestParam(defaultValue = "0") int page,
                     @RequestParam(defaultValue = "20") int size,
                     @RequestParam(required = false) String sort,
                     @RequestParam(defaultValue = "ASC") String direction,
                     @RequestParam MultiValueMap<String, String> allParams) {
        guard(entity);
        accessGuard.requireRead(entity);
        QueryOptions opts = new QueryOptions();
        opts.page = page;
        opts.size = size;
        opts.sort = sort;
        opts.direction = direction;
        allParams.forEach((key, values) -> {
            if (RESERVED.contains(key) || values.isEmpty()) {
                return;
            }
            // field_op syntax, e.g. name_like, price_gte, status_in. No suffix = equality.
            int us = key.lastIndexOf('_');
            String field = key;
            QueryOptions.Op op = QueryOptions.Op.EQ;
            if (us > 0) {
                QueryOptions.Op parsed = QueryOptions.Op.fromSuffix(key.substring(us + 1));
                if (parsed != QueryOptions.Op.EQ || key.substring(us + 1).equals("eq")) {
                    field = key.substring(0, us);
                    op = parsed;
                }
            }
            opts.addFilter(field, op, values.get(0));
        });
        return crud.list(entity, opts);
    }

    @GetMapping("/{entity}/{id}")
    public Map<String, Object> get(@PathVariable String entity, @PathVariable String id) {
        guard(entity);
        accessGuard.requireRead(entity);
        return crud.findById(entity, id);
    }

    @PostMapping("/{entity}")
    @SuppressWarnings("unchecked")
    public ResponseEntity<Map<String, Object>> create(
            @PathVariable String entity,
            @RequestBody Map<String, Object> body,
            @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey) {
        guard(entity);
        accessGuard.requireWrite(entity);
        // Replay protection: a repeated request with the same key returns the original result.
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            var cached = idempotency.get(entity, idempotencyKey);
            if (cached.isPresent()) {
                return ResponseEntity.status(HttpStatus.OK)
                        .header("Idempotent-Replay", "true")
                        .body((Map<String, Object>) cached.get());
            }
            Map<String, Object> created = crud.create(entity, body);
            idempotency.put(entity, idempotencyKey, created);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(crud.create(entity, body));
    }

    @PostMapping("/{entity}/bulk")
    public ResponseEntity<java.util.List<Map<String, Object>>> bulkCreate(
            @PathVariable String entity, @RequestBody java.util.List<Map<String, Object>> bodies) {
        guard(entity);
        accessGuard.requireWrite(entity);
        java.util.List<Map<String, Object>> created = new java.util.ArrayList<>();
        for (Map<String, Object> body : bodies) {
            created.add(crud.create(entity, body));
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{entity}/{id}")
    public Map<String, Object> update(@PathVariable String entity, @PathVariable String id,
                                      @RequestBody Map<String, Object> body) {
        guard(entity);
        accessGuard.requireWrite(entity);
        return crud.update(entity, id, body);
    }

    @DeleteMapping("/{entity}/{id}")
    public ResponseEntity<Void> delete(@PathVariable String entity, @PathVariable String id) {
        guard(entity);
        accessGuard.requireWrite(entity);
        crud.delete(entity, id);
        return ResponseEntity.noContent().build();
    }

    private void guard(String entity) {
        if (!registry.config().api.rest.enabled) {
            throw new NotFoundException("REST API is disabled for this app");
        }
        if (!registry.hasEntity(entity)) {
            throw new NotFoundException("Unknown entity '" + entity + "'");
        }
    }
}
