package com.flexforge.engine.api.flow;

import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowEngine;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * HTTP trigger for flows: {@code POST /flows/{name}/run} with a JSON body as the flow
 * input. If the flow hits a respond step, that response (and status) is returned;
 * otherwise a summary of all step outputs is returned.
 */
@RestController
public class FlowController {

    private final FlowEngine engine;

    public FlowController(FlowEngine engine) {
        this.engine = engine;
    }

    @PostMapping(value = "/flows/{name}/run", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> run(@PathVariable String name,
                                 @RequestBody(required = false) Map<String, Object> input) {
        FlowContext ctx = engine.run(name, input == null ? new LinkedHashMap<>() : input);
        if (ctx.hasResponse()) {
            int status = ctx.responseStatus() == null ? 200 : ctx.responseStatus();
            return ResponseEntity.status(status).body(ctx.response());
        }
        return ResponseEntity.ok(Map.of("flow", name, "steps", ctx.steps()));
    }
}
