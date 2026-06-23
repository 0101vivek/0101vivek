package com.flexforge.engine.bootstrap;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * CORS for the generated API surfaces so browsers and external tools can call the engine.
 * Permissive in v0; a production build would tie allowed origins to config.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS");
        registry.addMapping("/graphql").allowedOriginPatterns("*").allowedMethods("POST", "OPTIONS");
        registry.addMapping("/__meta/**").allowedOriginPatterns("*").allowedMethods("GET", "OPTIONS");
    }
}
