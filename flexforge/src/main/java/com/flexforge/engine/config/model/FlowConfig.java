package com.flexforge.engine.config.model;

import java.util.ArrayList;
import java.util.List;

/**
 * A flow = a trigger + an ordered set of steps forming a (currently linear-with-branches)
 * graph. Flows are how all logic is expressed in FlexForge — no code, just config. v0
 * triggers them over HTTP at {@code /flows/{name}/run}; schedule/record-change triggers
 * are on the roadmap.
 */
public class FlowConfig {

    public String name;

    /** Optional id of the first step; defaults to the first in the list. */
    public String start;

    /** How the flow is triggered (manual by default, or schedule/cron). */
    public TriggerConfig trigger = new TriggerConfig();

    public List<StepConfig> steps = new ArrayList<>();

    public StepConfig step(String id) {
        for (StepConfig s : steps) {
            if (s.id != null && s.id.equals(id)) {
                return s;
            }
        }
        return null;
    }

    public String stepAfter(String id) {
        for (int i = 0; i < steps.size(); i++) {
            if (steps.get(i).id != null && steps.get(i).id.equals(id)) {
                return i + 1 < steps.size() ? steps.get(i + 1).id : null;
            }
        }
        return null;
    }
}
