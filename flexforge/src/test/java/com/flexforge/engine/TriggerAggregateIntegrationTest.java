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

/** Covers record-change triggers (flow runs on create) and aggregation queries. */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class TriggerAggregateIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    @SuppressWarnings("unchecked")
    void recordTriggerFiresOnCreate() {
        ResponseEntity<Map> cust = rest.postForEntity("/api/Customer",
                Map.of("email", "trig@example.com", "fullName", "Trig"), Map.class);
        Object customerId = cust.getBody().get("id");

        rest.postForEntity("/api/Order",
                Map.of("customerId", customerId, "total", 50, "status", "NEW"), Map.class);

        ResponseEntity<List> notes = rest.getForEntity("/__notifications", List.class);
        List<Map<String, Object>> body = notes.getBody();
        assertThat(body.stream().anyMatch(n -> "New order".equals(n.get("subject")))).isTrue();
    }

    @Test
    void aggregateCountAndGroupBy() {
        rest.postForEntity("/api/Customer", Map.of("email", "a1@x.com", "fullName", "A1", "tier", "gold"), Map.class);
        rest.postForEntity("/api/Customer", Map.of("email", "a2@x.com", "fullName", "A2", "tier", "gold"), Map.class);
        rest.postForEntity("/api/Customer", Map.of("email", "a3@x.com", "fullName", "A3", "tier", "silver"), Map.class);

        ResponseEntity<Map> count = rest.getForEntity("/api/Customer/_aggregate?op=count", Map.class);
        assertThat(count.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(((Number) count.getBody().get("value")).intValue()).isGreaterThanOrEqualTo(3);

        ResponseEntity<List> byTier = rest.getForEntity("/api/Customer/_aggregate?op=count&groupBy=tier", List.class);
        assertThat(byTier.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(byTier.getBody()).isNotEmpty();
    }
}
