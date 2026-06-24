package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * "set" / transform step: resolves each param (with ${...} expressions) and writes the
 * results into vars, also returning them as this step's output.
 */
@Component
public class SetStep implements FlowStep {

    @Override
    public String type() {
        return "set";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> resolved = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        Map<String, Object> out = new LinkedHashMap<>(resolved);
        ctx.vars().putAll(out);
        return out;
    }
}
