package com.flexforge.engine.config.model;

/**
 * How schema changes flow across regenerations. v0 applies additive changes
 * automatically and refuses destructive ones; the full Liquibase-backed
 * expand/contract + preview/approve loop is the v2 deliverable (see ROADMAP.md).
 */
public class MigrationPolicy {

    /** "auto" — additive changes (new table/column) applied on boot. */
    public String additive = "auto";

    /** "require_approval" — destructive changes are never run silently. */
    public String destructive = "require_approval";

    /** Migration pattern for risky changes. */
    public String pattern = "expand_contract";

    /** Snapshot/backup before applying changes. */
    public boolean backupBeforeApply = true;
}
