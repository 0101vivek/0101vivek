package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/** Covers LOOKUP (pull across a relation) and ROLLUP (aggregate child records). */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class LookupRollupIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void lookupAndRollupComputeAcrossRelations() {
        ResponseEntity<Map> cust = rest.postForEntity("/api/Customer",
                Map.of("email", "lr@example.com", "fullName", "LR Test"), Map.class);
        Object customerId = cust.getBody().get("id");

        rest.postForEntity("/api/Order", Map.of("customerId", customerId, "total", 100, "status", "NEW"), Map.class);
        ResponseEntity<Map> order = rest.postForEntity("/api/Order",
                Map.of("customerId", customerId, "total", 250, "status", "NEW"), Map.class);

        // LOOKUP: Order.customerEmail pulls Customer.email across the reference
        assertThat(order.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        ResponseEntity<Map> orderRead = rest.getForEntity("/api/Order/" + order.getBody().get("id"), Map.class);
        assertThat(orderRead.getBody().get("customerEmail")).isEqualTo("lr@example.com");

        // ROLLUP: Customer.orderCount = 2, orderTotal = 350
        ResponseEntity<Map> custRead = rest.getForEntity("/api/Customer/" + customerId, Map.class);
        assertThat(((Number) custRead.getBody().get("orderCount")).intValue()).isEqualTo(2);
        assertThat(((Number) custRead.getBody().get("orderTotal")).doubleValue()).isEqualTo(350.0);
    }
}
