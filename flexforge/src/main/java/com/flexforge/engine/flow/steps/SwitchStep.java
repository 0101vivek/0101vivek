package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * "switch" step: multi-way branch. params: {value, cases: {matchValue: stepId}, default}.
 * Returns the id of the step to jump to; the FlowEngine routes to it. A cleaner alternative
 * to chaining many condition steps.
 */
@Component
public class SwitchStep implements FlowStep {

    @Override
    public String type() {
        return "switch";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String value = String.valueOf(p.get("value"));
        Object cases = p.get("cases");
        if (cases instanceof Map<?, ?> map) {
            for (Map.Entry<?, ?> e : map.entrySet()) {
                if (String.valueOf(e.getKey()).equals(value)) {
                    return String.valueOf(e.getValue());
                }
            }
        }
        Object def = p.get("default");
        return def == null ? null : String.valueOf(def);
    }
}
