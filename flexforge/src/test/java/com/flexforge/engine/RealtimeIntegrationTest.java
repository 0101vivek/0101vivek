package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Verifies CRUD operations emit change events that the real-time surfaces broadcast
 * (checked via the pull buffer; SSE and WebSocket consume the same stream).
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class RealtimeIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    @SuppressWarnings("unchecked")
    void crudEmitsChangeEvents() {
        rest.postForEntity("/api/Product",
                Map.of("sku", "RT-1", "name", "Realtime Widget"), Map.class);

        ResponseEntity<List> recent = rest.getForEntity("/realtime/recent?entity=Product", List.class);
        assertThat(recent.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(recent.getBody()).isNotEmpty();

        List<Map<String, Object>> events = recent.getBody();
        boolean sawCreate = events.stream().anyMatch(e ->
                "create".equals(e.get("op")) && "Product".equals(e.get("entity")));
        assertThat(sawCreate).isTrue();
    }
}
