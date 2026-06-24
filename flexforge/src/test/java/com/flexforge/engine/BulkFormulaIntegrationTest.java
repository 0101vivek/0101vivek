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

/** Covers bulk create and computed FORMULA fields. */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class BulkFormulaIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void bulkCreateInsertsMany() {
        List<Map<String, Object>> batch = List.of(
                Map.of("sku", "BULK-1", "name", "One"),
                Map.of("sku", "BULK-2", "name", "Two"),
                Map.of("sku", "BULK-3", "name", "Three"));
        ResponseEntity<List> resp = rest.postForEntity("/api/Product/bulk", batch, List.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(resp.getBody()).hasSize(3);
    }

    @Test
    void formulaFieldComputedOnRead() {
        ResponseEntity<Map> created = rest.postForEntity("/api/Customer",
                Map.of("email", "formula@example.com", "fullName", "Ada", "tier", "gold"), Map.class);
        Object id = created.getBody().get("id");
        ResponseEntity<Map> read = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(read.getBody().get("label")).isEqualTo("gold · Ada");
    }
}
