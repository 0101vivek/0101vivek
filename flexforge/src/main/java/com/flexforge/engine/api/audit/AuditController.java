package com.flexforge.engine.api.audit;

import com.flexforge.engine.audit.AuditEntry;
import com.flexforge.engine.audit.AuditService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Exposes the audit log: {@code GET /__audit} (optionally {@code ?entity=Customer}). */
@RestController
public class AuditController {

    private final AuditService audit;

    public AuditController(AuditService audit) {
        this.audit = audit;
    }

    @GetMapping(value = "/__audit", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<AuditEntry> recent(@RequestParam(required = false) String entity) {
        return audit.recent(entity);
    }
}
