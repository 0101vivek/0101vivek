package com.flexforge.engine.audit;

/**
 * One append-only audit record: who did what to which entity, when. Audit logging is a
 * near-universal compliance requirement (HIPAA, FERPA, SOC 2, RBI/IRDAI, 21 CFR 11, FOIA),
 * so the platform records it centrally rather than leaving it to each app.
 */
public record AuditEntry(String at, String user, String op, String entity, Object recordId) {
}
