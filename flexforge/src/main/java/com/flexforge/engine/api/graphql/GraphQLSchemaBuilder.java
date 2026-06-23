package com.flexforge.engine.api.graphql;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.EntityConfig;
import com.flexforge.engine.config.model.FieldConfig;
import com.flexforge.engine.config.model.FieldType;
import com.flexforge.engine.data.DynamicCrudService;
import graphql.Scalars;
import graphql.schema.DataFetcher;
import graphql.schema.GraphQLArgument;
import graphql.schema.GraphQLFieldDefinition;
import graphql.schema.GraphQLInputObjectField;
import graphql.schema.GraphQLInputObjectType;
import graphql.schema.GraphQLNonNull;
import graphql.schema.GraphQLObjectType;
import graphql.schema.GraphQLOutputType;
import graphql.schema.GraphQLScalarType;
import graphql.schema.GraphQLSchema;
import graphql.schema.GraphQLTypeReference;
import graphql.schema.idl.SchemaPrinter;

import java.util.List;
import java.util.Map;

/**
 * Builds a GraphQL schema directly from the config metadata — no .graphqls file, no
 * per-entity resolvers. Every entity becomes an object type with list/byId queries and
 * create/update/delete mutations, all backed by the same {@link DynamicCrudService} that
 * powers REST. This is the concrete proof of "one model, many protocols".
 */
public class GraphQLSchemaBuilder {

    private final MetadataRegistry registry;
    private final DynamicCrudService crud;

    public GraphQLSchemaBuilder(MetadataRegistry registry, DynamicCrudService crud) {
        this.registry = registry;
        this.crud = crud;
    }

    public GraphQLSchema build() {
        GraphQLObjectType.Builder query = GraphQLObjectType.newObject().name("Query");
        GraphQLObjectType.Builder mutation = GraphQLObjectType.newObject().name("Mutation");
        graphql.schema.GraphQLCodeRegistry.Builder code = graphql.schema.GraphQLCodeRegistry.newCodeRegistry();

        GraphQLSchema.Builder schema = GraphQLSchema.newSchema();

        for (EntityConfig entity : registry.entities()) {
            schema.additionalType(objectType(entity));
            schema.additionalType(inputType(entity));
            addQueries(query, entity);
            addMutations(mutation, entity);
            wireFetchers(code, entity);
        }

        return schema.query(query.build())
                .mutation(mutation.build())
                .codeRegistry(code.build())
                .build();
    }

    private void wireFetchers(graphql.schema.GraphQLCodeRegistry.Builder code, EntityConfig entity) {
        code.dataFetcher(graphql.schema.FieldCoordinates.coordinates("Query", lower(entity.name) + "List"),
                listFetcher(entity));
        code.dataFetcher(graphql.schema.FieldCoordinates.coordinates("Query", lower(entity.name) + "ById"),
                byIdFetcher(entity));
        code.dataFetcher(graphql.schema.FieldCoordinates.coordinates("Mutation", "create" + entity.name),
                createFetcher(entity));
        code.dataFetcher(graphql.schema.FieldCoordinates.coordinates("Mutation", "update" + entity.name),
                updateFetcher(entity));
        code.dataFetcher(graphql.schema.FieldCoordinates.coordinates("Mutation", "delete" + entity.name),
                deleteFetcher(entity));
    }

    /** Human-readable SDL of the generated schema, exposed for tooling/debugging. */
    public String printSdl() {
        return new SchemaPrinter().print(build());
    }

    private GraphQLObjectType objectType(EntityConfig entity) {
        GraphQLObjectType.Builder type = GraphQLObjectType.newObject().name(entity.name);
        for (FieldConfig f : entity.fields) {
            type.field(GraphQLFieldDefinition.newFieldDefinition()
                    .name(f.name)
                    .type(outputScalar(f)));
        }
        return type.build();
    }

    private GraphQLInputObjectType inputType(EntityConfig entity) {
        GraphQLInputObjectType.Builder type = GraphQLInputObjectType.newInputObject()
                .name(entity.name + "Input");
        for (FieldConfig f : entity.fields) {
            if (f.pk) {
                continue; // primary key is generated, never part of input
            }
            type.field(GraphQLInputObjectField.newInputObjectField()
                    .name(f.name)
                    .type(scalarFor(f.type)));
        }
        return type.build();
    }

    private void addQueries(GraphQLObjectType.Builder query, EntityConfig entity) {
        String typeRef = entity.name;

        query.field(GraphQLFieldDefinition.newFieldDefinition()
                .name(lower(entity.name) + "List")
                .type(graphql.schema.GraphQLList.list(new GraphQLTypeReference(typeRef)))
                .argument(GraphQLArgument.newArgument().name("page").type(Scalars.GraphQLInt))
                .argument(GraphQLArgument.newArgument().name("size").type(Scalars.GraphQLInt)));

        query.field(GraphQLFieldDefinition.newFieldDefinition()
                .name(lower(entity.name) + "ById")
                .type(new GraphQLTypeReference(typeRef))
                .argument(GraphQLArgument.newArgument()
                        .name("id").type(new GraphQLNonNull(Scalars.GraphQLID))));
    }

    private void addMutations(GraphQLObjectType.Builder mutation, EntityConfig entity) {
        GraphQLTypeReference typeRef = new GraphQLTypeReference(entity.name);
        GraphQLTypeReference inputRef = new GraphQLTypeReference(entity.name + "Input");

        mutation.field(GraphQLFieldDefinition.newFieldDefinition()
                .name("create" + entity.name)
                .type(typeRef)
                .argument(GraphQLArgument.newArgument()
                        .name("input").type(new GraphQLNonNull(inputRef))));

        mutation.field(GraphQLFieldDefinition.newFieldDefinition()
                .name("update" + entity.name)
                .type(typeRef)
                .argument(GraphQLArgument.newArgument()
                        .name("id").type(new GraphQLNonNull(Scalars.GraphQLID)))
                .argument(GraphQLArgument.newArgument()
                        .name("input").type(new GraphQLNonNull(inputRef))));

        mutation.field(GraphQLFieldDefinition.newFieldDefinition()
                .name("delete" + entity.name)
                .type(Scalars.GraphQLBoolean)
                .argument(GraphQLArgument.newArgument()
                        .name("id").type(new GraphQLNonNull(Scalars.GraphQLID))));
    }

    // ---- data fetchers are registered by GraphQLRuntimeWiring via these helpers --------

    DataFetcher<List<Map<String, Object>>> listFetcher(EntityConfig entity) {
        return env -> {
            com.flexforge.engine.data.QueryOptions opts = new com.flexforge.engine.data.QueryOptions();
            Integer page = env.getArgument("page");
            Integer size = env.getArgument("size");
            if (page != null) {
                opts.page = page;
            }
            if (size != null) {
                opts.size = size;
            }
            return crud.list(entity.name, opts).content();
        };
    }

    DataFetcher<Map<String, Object>> byIdFetcher(EntityConfig entity) {
        return env -> crud.findById(entity.name, env.getArgument("id"));
    }

    DataFetcher<Map<String, Object>> createFetcher(EntityConfig entity) {
        return env -> crud.create(entity.name, env.getArgument("input"));
    }

    DataFetcher<Map<String, Object>> updateFetcher(EntityConfig entity) {
        return env -> crud.update(entity.name, env.getArgument("id"), env.getArgument("input"));
    }

    DataFetcher<Boolean> deleteFetcher(EntityConfig entity) {
        return env -> crud.delete(entity.name, env.getArgument("id"));
    }

    MetadataRegistry registry() {
        return registry;
    }

    private GraphQLOutputType outputScalar(FieldConfig f) {
        if (f.pk) {
            return Scalars.GraphQLID;
        }
        return scalarFor(f.type);
    }

    private GraphQLScalarType scalarFor(FieldType type) {
        return switch (type) {
            case INT -> Scalars.GraphQLInt;
            case DOUBLE, DECIMAL -> Scalars.GraphQLFloat;
            case BOOLEAN -> Scalars.GraphQLBoolean;
            // LONG/STRING/TEXT/DATE/TIMESTAMP/JSON are serialized as String to stay
            // portable and avoid 32-bit Int overflow for LONG values.
            default -> Scalars.GraphQLString;
        };
    }

    private String lower(String s) {
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }
}
