package com.flexforge.engine.config.model;

/**
 * How a flow is triggered. "manual" flows run via POST /flows/{name}/run; "schedule" flows
 * run automatically on a cron expression or a fixed rate. (Record-change and webhook
 * triggers are on the roadmap.)
 */
public class TriggerConfig {

    /** manual | schedule */
    public String type = "manual";

    /** Cron expression, e.g. "0 0 * * * *" (every hour). Used when type=schedule. */
    public String cron;

    /** Alternative to cron: run every N milliseconds. */
    public Long fixedRateMs;
}
