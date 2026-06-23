package com.flexforge.engine;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * FlexForge Runtime Engine.
 *
 * <p>One hardened image. It reads an immutable config bundle at startup and becomes a
 * full backend application — data model, schema, and REST + GraphQL APIs — with no
 * per-app source code generated anywhere.
 */
@SpringBootApplication
public class FlexForgeEngineApplication {

    public static void main(String[] args) {
        SpringApplication.run(FlexForgeEngineApplication.class, args);
    }
}
