package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/** "log" step: emits a resolved message to the engine log. params: {message}. */
@Component
public class LogStep implements FlowStep {

    private static final Logger log = LoggerFactory.getLogger("flexforge.flow");

    @Override
    public String type() {
        return "log";
    }

    @Override
    public Object execute(StepConfig step, FlowContext ctx) {
        Object message = Expressions.resolve(step.params.get("message"), ctx.root());
        log.info("[flow-log] {}", message);
        return message;
    }
}
