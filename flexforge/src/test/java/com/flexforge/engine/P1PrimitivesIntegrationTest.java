package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers the P1 platform primitives: audit log, idempotency, AI flow step (stub mode), and
 * notification flow step.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class P1PrimitivesIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    @SuppressWarnings("unchecked")
    void crudIsAudited() {
        rest.postForEntity("/api/Customer",
                Map.of("email", "audit@example.com", "fullName", "Audited"), Map.class);
        ResponseEntity<List> audit = rest.getForEntity("/__audit?entity=Customer", List.class);
        assertThat(audit.getStatusCode()).isEqualTo(HttpStatus.OK);
        List<Map<String, Object>> entries = audit.getBody();
        assertThat(entries).isNotEmpty();
        assertThat(entries.stream().anyMatch(e -> "create".equals(e.get("op")))).isTrue();
    }

    @Test
    void idempotencyKeyPreventsDuplicateCreate() {
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Type", "application/json");
        headers.add("Idempotency-Key", "order-key-123");
        HttpEntity<Map<String, Object>> req = new HttpEntity<>(
                Map.of("sku", "IDEMP-1", "name", "Idempotent Widget"), headers);

        ResponseEntity<Map> first = rest.postForEntity("/api/Product", req, Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        Object firstId = first.getBody().get("id");

        ResponseEntity<Map> replay = rest.postForEntity("/api/Product", req, Map.class);
        assertThat(replay.getStatusCode()).isEqualTo(HttpStatus.OK); // replay returns cached
        assertThat(replay.getBody().get("id")).isEqualTo(firstId);    // same record, not a new one
    }

    @Test
    void assistFlowRunsAiStubAndNotifies() {
        ResponseEntity<Map> resp = rest.postForEntity("/flows/assist/run",
                Map.of("text", "hello world", "email", "user@example.com"), Map.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.OK);
        String summary = String.valueOf(resp.getBody().get("summary"));
        assertThat(summary).contains("hello world");   // stub echoes the prompt
        assertThat(summary).contains("stub-ai");

        ResponseEntity<List> notes = rest.getForEntity("/__notifications", List.class);
        assertThat(notes.getBody()).isNotEmpty();
    }
}
