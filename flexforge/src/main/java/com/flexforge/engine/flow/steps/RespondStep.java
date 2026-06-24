package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

/**
 * "respond" step: sets the flow's HTTP response and ends the run. params: {status, body}.
 */
@Component
public class RespondStep implements FlowStep {

    @Override
    public String type() {
        return "respond";
    }

    @Override
    public Object execute(StepConfig step, FlowContext ctx) {
        Object body = Expressions.resolve(step.params.get("body"), ctx.root());
        Integer status = step.params.get("status") == null ? 200
                : Integer.valueOf(String.valueOf(step.params.get("status")));
        ctx.setResponse(body, status);
        return body;
    }
}
