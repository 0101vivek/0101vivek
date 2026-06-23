package com.flexforge.engine.config.model;

/**
 * Which API protocols the engine exposes over the data model. This is the headline of
 * FlexForge: the SAME metadata is projected onto multiple protocols. An app author does
 * not pick "a REST app" or "a GraphQL app" — they declare a data model and turn on
 * whichever protocols they want.
 *
 * <p>v0 ships REST + GraphQL. gRPC, WebSocket subscriptions, OData and SOAP are roadmap
 * surfaces that plug into the same {@code DynamicCrudService}.
 */
public class ApiConfig {

    public Rest rest = new Rest();

    public GraphQl graphql = new GraphQl();

    public static class Rest {
        /** Expose generated REST CRUD endpoints. */
        public boolean enabled = true;
        /** Base path for the REST surface. */
        public String basePath = "/api";
    }

    public static class GraphQl {
        /** Expose a runtime-built GraphQL schema over the same entities. */
        public boolean enabled = true;
        /** Path the GraphQL endpoint is served at. */
        public String path = "/graphql";
    }
}
