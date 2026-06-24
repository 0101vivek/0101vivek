package com.flexforge.engine.flow;

import com.flexforge.engine.config.model.StepConfig;

/**
 * The uniform contract every flow step implements — classic actions, control flow,
 * connectors, and (crucially) AI modules. A new capability is added by registering a new
 * {@code FlowStep} bean; the engine, context, routing and error handling are unchanged.
 * This is what makes the platform extensible without engine surgery.
 */
public interface FlowStep {

    /** The type key this step handles, matched against StepConfig.type. */
    String type();

    /**
     * Execute the step against the shared context. The returned value is stored in the
     * context under the step's id and becomes addressable as ${steps.&lt;id&gt;...}.
     */
    Object execute(StepConfig step, FlowContext ctx);
}
