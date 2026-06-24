package com.flexforge.engine.flow;

import com.flexforge.engine.config.MetadataRegistry;
import com.flexforge.engine.config.model.FlowConfig;
import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.error.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Executes a flow as a walk over its step graph, threading a single {@link FlowContext}.
 * Linear steps follow {@code next} (or the next step in the list); condition steps branch
 * to {@code then}/{@code else}; a {@code respond} step ends the run with a response. A
 * step-count guard prevents runaway loops. This is the v0 core of the no-code logic layer.
 */
@Component
public class FlowEngine {

    private static final Logger log = LoggerFactory.getLogger(FlowEngine.class);
    private static final int MAX_STEPS = 1000;

    private final MetadataRegistry registry;
    private final StepRegistry steps;

    public FlowEngine(MetadataRegistry registry, StepRegistry steps) {
        this.registry = registry;
        this.steps = steps;
    }

    public FlowContext run(String flowName, Map<String, Object> input) {
        FlowConfig flow = registry.config().flow(flowName);
        if (flow == null) {
            throw new NotFoundException("Unknown flow '" + flowName + "'");
        }
        FlowContext ctx = new FlowContext(input);
        String current = flow.start != null ? flow.start
                : (flow.steps.isEmpty() ? null : flow.steps.get(0).id);

        int guard = 0;
        while (current != null) {
            if (guard++ > MAX_STEPS) {
                throw new IllegalStateException("Flow '" + flowName + "' exceeded " + MAX_STEPS + " steps");
            }
            StepConfig step = flow.step(current);
            if (step == null) {
                throw new IllegalStateException("Flow '" + flowName + "' references unknown step '" + current + "'");
            }
            Object output = steps.require(step.type).execute(step, ctx);
            ctx.putStepOutput(step.id, output);
            log.debug("[flow:{}] step {} ({}) -> {}", flowName, step.id, step.type, output);

            if (ctx.hasResponse()) {
                break;
            }
            current = switch (step.type) {
                case "condition" -> Boolean.TRUE.equals(output) ? step.then : step.elseStep;
                // a switch step returns the id of the next step to jump to (or null to fall through)
                case "switch" -> output instanceof String s ? s : (step.next != null ? step.next : flow.stepAfter(step.id));
                default -> step.next != null ? step.next : flow.stepAfter(step.id);
            };
        }
        return ctx;
    }
}
