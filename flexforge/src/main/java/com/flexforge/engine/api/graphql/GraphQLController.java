package com.flexforge.engine.api.graphql;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.error.NotFoundException;
import graphql.ExecutionInput;
import graphql.ExecutionResult;
import graphql.GraphQL;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

/**
 * Single GraphQL endpoint over the runtime-built schema. Accepts the standard
 * {@code {query, operationName, variables}} POST body and returns the spec response.
 * {@code GET /graphql/schema} returns the generated SDL for tooling.
 */
@RestController
public class GraphQLController {

    private final GraphQL graphQL;
    private final GraphQLSchemaBuilder schemaBuilder;
    private final MetadataRegistry registry;

    public GraphQLController(GraphQL graphQL, GraphQLSchemaBuilder schemaBuilder, MetadataRegistry registry) {
        this.graphQL = graphQL;
        this.schemaBuilder = schemaBuilder;
        this.registry = registry;
    }

    @PostMapping(value = "/graphql", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> execute(@RequestBody Map<String, Object> request) {
        guard();
        String query = (String) request.get("query");
        if (query == null) {
            throw new IllegalArgumentException("GraphQL request must include a 'query'");
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> variables = request.get("variables") instanceof Map
                ? (Map<String, Object>) request.get("variables")
                : Collections.emptyMap();

        ExecutionInput input = ExecutionInput.newExecutionInput()
                .query(query)
                .operationName((String) request.get("operationName"))
                .variables(variables)
                .build();

        ExecutionResult result = graphQL.execute(input);
        return result.toSpecification();
    }

    @GetMapping(value = "/graphql/schema", produces = MediaType.TEXT_PLAIN_VALUE)
    public String schema() {
        guard();
        return schemaBuilder.printSdl();
    }

    private void guard() {
        if (!registry.config().api.graphql.enabled) {
            throw new NotFoundException("GraphQL API is disabled for this app");
        }
    }
}
