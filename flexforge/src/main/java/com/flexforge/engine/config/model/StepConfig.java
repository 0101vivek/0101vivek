package com.flexforge.engine.config.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * One node in a flow. Every step — classic, AI, or connector — has this same shape: a
 * type, a params map (resolved against the flow context via ${...} expressions), and
 * routing (next, or then/else for a condition). This uniform shape is what lets new step
 * types (including AI modules) slot in without engine changes.
 */
public class StepConfig {

    public String id;

    /** Step type key, resolved against the FlowStep registry (set, condition, db, http, ...). */
    public String type;

    public Map<String, Object> params = new LinkedHashMap<>();

    /** Next step id for linear steps (defaults to the following step in the list). */
    public String next;

    /** For condition steps: step id to go to when the predicate is true. */
    public String then;

    /** For condition steps: step id to go to when false ('else' is a Java keyword). */
    @JsonProperty("else")
    public String elseStep;
}
