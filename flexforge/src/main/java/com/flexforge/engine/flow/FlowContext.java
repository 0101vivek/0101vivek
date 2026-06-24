package com.flexforge.engine.flow;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * The shared execution state threaded through every step of a flow run. Steps read prior
 * results via ${input.x}, ${steps.id.field} and ${vars.x} expressions and write their
 * output back keyed by step id. A single audited context is the backbone of the DAG model.
 */
public class FlowContext {

    private final Map<String, Object> input;
    private final Map<String, Object> steps = new LinkedHashMap<>();
    private final Map<String, Object> vars = new LinkedHashMap<>();
    private Object response;
    private Integer responseStatus;

    public FlowContext(Map<String, Object> input) {
        this.input = input == null ? new LinkedHashMap<>() : input;
    }

    public void putStepOutput(String stepId, Object output) {
        steps.put(stepId, output);
    }

    public Map<String, Object> vars() {
        return vars;
    }

    public void setResponse(Object response, Integer status) {
        this.response = response;
        this.responseStatus = status;
    }

    public boolean hasResponse() {
        return response != null || responseStatus != null;
    }

    public Object response() {
        return response;
    }

    public Integer responseStatus() {
        return responseStatus;
    }

    public Map<String, Object> steps() {
        return steps;
    }

    /** The root object expressions resolve against. */
    public Map<String, Object> root() {
        Map<String, Object> root = new LinkedHashMap<>();
        root.put("input", input);
        root.put("steps", steps);
        root.put("vars", vars);
        return root;
    }
}
