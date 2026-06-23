package com.flexforge.engine;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Covers entity relations (REFERENCE fields with app-level integrity) and convention-based
 * auto timestamps (createdAt/updatedAt).
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class RelationsIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void orderLinksToCustomerAndAutoStampsTimes() {
        ResponseEntity<Map> customer = rest.postForEntity("/api/Customer",
                Map.of("email", "rel@example.com", "fullName", "Relator"), Map.class);
        assertThat(customer.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        Object customerId = customer.getBody().get("id");

        ResponseEntity<Map> order = rest.postForEntity("/api/Order",
                Map.of("customerId", customerId, "total", 99.5, "status", "NEW"), Map.class);
        assertThat(order.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        // createdAt + updatedAt auto-populated by the engine
        assertThat(order.getBody().get("createdAt")).isNotNull();
        assertThat(order.getBody().get("updatedAt")).isNotNull();
        assertThat(String.valueOf(order.getBody().get("customerId"))).isEqualTo(String.valueOf(customerId));
    }

    @Test
    void referenceToMissingRowIsRejected() {
        ResponseEntity<Map> order = rest.postForEntity("/api/Order",
                Map.of("customerId", 999999, "total", 10), Map.class);
        assertThat(order.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(order.getBody()).containsKey("errors");
    }
}
