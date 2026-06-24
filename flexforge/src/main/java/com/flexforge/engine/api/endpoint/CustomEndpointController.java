package com.flexforge.engine.api.endpoint;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.EndpointConfig;
import com.flexforge.engine.error.NotFoundException;
import com.flexforge.engine.error.ValidationException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Dispatches config-declared custom endpoints at {@code /run/{name}}. It validates the
 * declared method, required headers and required params (returning a clear, structured
 * "what's missing" error — the explicit flow feedback the user asked for) and then runs
 * the action: a static JSON response, a redirect to a (UI) URL, or a webhook call to a
 * third-party — all configured, not coded.
 */
@RestController
public class CustomEndpointController {

    private final MetadataRegistry registry;
    private final ObjectMapper objectMapper;
    private final HttpClient http = HttpClient.newHttpClient();

    public CustomEndpointController(MetadataRegistry registry, ObjectMapper objectMapper) {
        this.registry = registry;
        this.objectMapper = objectMapper;
    }

    @RequestMapping("/run/{name}")
    public ResponseEntity<?> handle(@PathVariable String name, HttpServletRequest request,
                                    @RequestBody(required = false) String body) throws Exception {
        EndpointConfig ep = registry.config().endpoint(name);
        if (ep == null) {
            throw new NotFoundException("No endpoint '" + name + "'");
        }
        if (!ep.method.equalsIgnoreCase(request.getMethod())) {
            return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                    .body(Map.of("message", "Endpoint '" + name + "' expects " + ep.method
                            + " but got " + request.getMethod()));
        }
        validate(ep, request);

        return switch (ep.action.type == null ? "json" : ep.action.type.toLowerCase()) {
            case "redirect" -> redirect(ep);
            case "webhook" -> webhook(ep, body);
            default -> json(ep);
        };
    }

    private void validate(EndpointConfig ep, HttpServletRequest request) {
        List<String> errors = new ArrayList<>();
        for (String h : ep.requiredHeaders) {
            if (request.getHeader(h) == null) {
                errors.add("required header '" + h + "' is missing");
            }
        }
        for (String p : ep.requiredParams) {
            if (request.getParameter(p) == null) {
                errors.add("required query param '" + p + "' is missing");
            }
        }
        if (!errors.isEmpty()) {
            throw new ValidationException(errors);
        }
    }

    private ResponseEntity<?> json(EndpointConfig ep) {
        ResponseEntity.BodyBuilder b = ResponseEntity.status(
                ep.action.status == null ? 200 : ep.action.status);
        ep.action.headers.forEach(b::header);
        return b.body(ep.action.body);
    }

    private ResponseEntity<?> redirect(EndpointConfig ep) {
        if (ep.action.url == null) {
            throw new ValidationException(List.of("redirect action requires action.url"));
        }
        return ResponseEntity.status(ep.action.status == null ? 302 : ep.action.status)
                .header("Location", ep.action.url)
                .build();
    }

    private ResponseEntity<?> webhook(EndpointConfig ep, String body) throws Exception {
        if (ep.action.url == null) {
            throw new ValidationException(List.of("webhook action requires action.url"));
        }
        HttpRequest.Builder req = HttpRequest.newBuilder(URI.create(ep.action.url))
                .POST(HttpRequest.BodyPublishers.ofString(body == null ? "{}" : body))
                .header("Content-Type", "application/json");
        ep.action.headers.forEach(req::header);
        HttpResponse<String> resp = http.send(req.build(), HttpResponse.BodyHandlers.ofString());
        return ResponseEntity.status(resp.statusCode())
                .body(Map.of("forwardedTo", ep.action.url, "status", resp.statusCode(),
                        "response", resp.body()));
    }
}
