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

    public DynamicRestController(DynamicCrudService crud, MetadataRegistry registry,
                                 com.flexforge.engine.auth.AccessGuard accessGuard) {
        this.crud = crud;
        this.registry = registry;
        this.accessGuard = accessGuard;
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
            if (!RESERVED.contains(key) && !values.isEmpty()) {
                opts.filters.put(key, values.get(0));
            }
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
    public ResponseEntity<Map<String, Object>> create(@PathVariable String entity,
                                                       @RequestBody Map<String, Object> body) {
        guard(entity);
        accessGuard.requireWrite(entity);
        return ResponseEntity.status(HttpStatus.CREATED).body(crud.create(entity, body));
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
