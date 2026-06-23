package com.flexforge.engine.api.file;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.auth.AccessGuard;
import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;
import com.flexforge.engine.config.model.FieldType;
import com.flexforge.engine.crypto.EncryptionService;
import com.flexforge.engine.data.DynamicCrudService;
import com.flexforge.engine.error.NotFoundException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Upload, download and base64 access for FILE fields (images, documents, …). The file is
 * stored on its entity row as JSON metadata + base64 content, so it travels with the
 * record and needs no separate storage system in v0.
 *
 * <ul>
 *   <li>{@code POST /api/{entity}/{id}/file/{field}} (multipart "file") — store</li>
 *   <li>{@code GET  /api/{entity}/{id}/file/{field}} — download inline (opens image/doc)</li>
 *   <li>{@code GET  /api/{entity}/{id}/file/{field}?format=base64} — JSON with base64 data</li>
 * </ul>
 */
@RestController
public class FileController {

    private final DynamicCrudService crud;
    private final MetadataRegistry registry;
    private final AccessGuard accessGuard;
    private final ObjectMapper objectMapper;

    public FileController(DynamicCrudService crud, MetadataRegistry registry,
                          AccessGuard accessGuard, ObjectMapper objectMapper) {
        this.crud = crud;
        this.registry = registry;
        this.accessGuard = accessGuard;
        this.objectMapper = objectMapper;
    }

    @PostMapping("/api/{entity}/{id}/file/{field}")
    public Map<String, Object> upload(@PathVariable String entity, @PathVariable String id,
                                      @PathVariable String field,
                                      @RequestParam("file") MultipartFile file) throws IOException {
        accessGuard.requireWrite(entity);
        requireFileField(entity, field);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("filename", file.getOriginalFilename());
        payload.put("contentType", file.getContentType() == null
                ? MediaType.APPLICATION_OCTET_STREAM_VALUE : file.getContentType());
        payload.put("size", file.getSize());
        payload.put("dataBase64", EncryptionService.base64Encode(file.getBytes()));

        String json = objectMapper.writeValueAsString(payload);
        crud.update(entity, id, Map.of(field, json));
        payload.remove("dataBase64"); // don't echo the whole file back on upload
        payload.put("status", "stored");
        return payload;
    }

    @GetMapping("/api/{entity}/{id}/file/{field}")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> download(@PathVariable String entity, @PathVariable String id,
                                      @PathVariable String field,
                                      @RequestParam(required = false) String format) throws IOException {
        accessGuard.requireRead(entity);
        requireFileField(entity, field);

        Map<String, Object> row = crud.findById(entity, id);
        Object raw = row.get(field);
        if (raw == null) {
            throw new NotFoundException("No file stored in " + entity + "." + field);
        }
        Map<String, Object> payload = objectMapper.readValue(raw.toString(), Map.class);

        if ("base64".equalsIgnoreCase(format) || "json".equalsIgnoreCase(format)) {
            return ResponseEntity.ok(payload);
        }
        byte[] bytes = EncryptionService.base64Decode(String.valueOf(payload.get("dataBase64")));
        String contentType = String.valueOf(payload.getOrDefault("contentType",
                MediaType.APPLICATION_OCTET_STREAM_VALUE));
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, contentType)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + payload.getOrDefault("filename", "file") + "\"")
                .body(bytes);
    }

    private void requireFileField(String entity, String field) {
        EntityConfig e = registry.require(entity);
        FieldConfig f = e.field(field);
        if (f == null || f.type != FieldType.FILE) {
            throw new NotFoundException("No FILE field '" + field + "' on " + entity);
        }
    }
}
