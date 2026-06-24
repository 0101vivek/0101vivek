package com.flexforge.engine.audit;

import com.flexforge.engine.auth.AuthContext;
import com.flexforge.engine.realtime.EntityEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

/**
 * Records an audit entry for every data-change event. It listens to the same
 * {@link EntityEvent} stream the real-time surfaces use and captures the acting principal
 * from {@link AuthContext} (set on the request thread; the event is published synchronously
 * within the same request, so the principal is still available).
 *
 * <p>v0 keeps a bounded in-memory log (queryable + logged). A production build persists to
 * an append-only, tamper-evident store with retention rules (ROADMAP).
 */
@Service
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger("flexforge.audit");
    private static final int BUFFER = 500;

    private final Deque<AuditEntry> entries = new ArrayDeque<>();

    @EventListener
    public synchronized void onEvent(EntityEvent event) {
        String user = AuthContext.isAuthenticated() ? AuthContext.get().username() : "anonymous";
        AuditEntry entry = new AuditEntry(event.at(), user, event.op(), event.entity(), event.id());
        entries.addLast(entry);
        while (entries.size() > BUFFER) {
            entries.removeFirst();
        }
        log.info("[audit] {} {} {}#{}", user, event.op(), event.entity(), event.id());
    }

    public synchronized List<AuditEntry> recent(String entity) {
        List<AuditEntry> out = new ArrayList<>();
        for (AuditEntry e : entries) {
            if (entity == null || entity.equalsIgnoreCase(e.entity())) {
                out.add(e);
            }
        }
        return out;
    }
}
