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
 * Boots the full engine against in-memory H2 using the bundled CRM config and proves the
 * central thesis: the same metadata serves CRUD over BOTH REST and GraphQL, with no
 * per-app code.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EngineIntegrationTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void restCrudRoundTrip() {
        // CREATE
        ResponseEntity<Map> created = rest.postForEntity("/api/Customer",
                Map.of("email", "ada@example.com", "fullName", "Ada Lovelace", "tier", "gold",
                        "active", true),
                Map.class);
        assertThat(created.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(created.getBody()).containsKeys("id", "email");
        Object id = created.getBody().get("id");

        // READ by id
        ResponseEntity<Map> fetched = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(fetched.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(fetched.getBody().get("email")).isEqualTo("ada@example.com");

        // LIST
        ResponseEntity<Map> list = rest.getForEntity("/api/Customer", Map.class);
        assertThat(list.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(((Number) list.getBody().get("total")).intValue()).isGreaterThanOrEqualTo(1);

        // UPDATE
        rest.put("/api/Customer/" + id, Map.of("tier", "platinum"));
        ResponseEntity<Map> afterUpdate = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(afterUpdate.getBody().get("tier")).isEqualTo("platinum");

        // DELETE
        rest.delete("/api/Customer/" + id);
        ResponseEntity<Map> afterDelete = rest.getForEntity("/api/Customer/" + id, Map.class);
        assertThat(afterDelete.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    void graphqlMutationAndQuery() {
        String createMutation = """
                { "query": "mutation { createProduct(input: { sku: \\"SKU-1\\", name: \\"Widget\\", inStock: true }) { id sku name } }" }
                """;
        ResponseEntity<Map> created = postGraphql(createMutation);
        assertThat(created.getStatusCode()).isEqualTo(HttpStatus.OK);
        Map data = (Map) created.getBody().get("data");
        assertThat(data).isNotNull();
        Map product = (Map) data.get("createProduct");
        assertThat(product.get("sku")).isEqualTo("SKU-1");

        String listQuery = "{ \"query\": \"{ productList { id sku name } }\" }";
        ResponseEntity<Map> listed = postGraphql(listQuery);
        Map listData = (Map) listed.getBody().get("data");
        assertThat(((java.util.List<?>) listData.get("productList"))).isNotEmpty();
    }

    private ResponseEntity<Map> postGraphql(String json) {
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
        return rest.postForEntity("/graphql",
                new org.springframework.http.HttpEntity<>(json, headers), Map.class);
    }
}
