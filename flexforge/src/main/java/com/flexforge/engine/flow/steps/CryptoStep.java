package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.crypto.EncryptionService;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

/**
 * "crypto" step. params: {op, value, min, max}. Ops: sha256, encrypt, decrypt,
 * base64encode, base64decode, uuid, random. Returns {result}.
 */
@Component
public class CryptoStep implements FlowStep {

    private final EncryptionService encryption;

    public CryptoStep(EncryptionService encryption) {
        this.encryption = encryption;
    }

    @Override
    public String type() {
        return "crypto";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "uuid"));
        String value = p.get("value") == null ? "" : String.valueOf(p.get("value"));
        Object result = switch (op) {
            case "sha256" -> encryption.sha256Hex(value);
            case "encrypt" -> encryption.encrypt(value);
            case "decrypt" -> encryption.decrypt(value);
            case "base64encode" -> EncryptionService.base64Encode(value.getBytes(StandardCharsets.UTF_8));
            case "base64decode" -> new String(EncryptionService.base64Decode(value), StandardCharsets.UTF_8);
            case "uuid" -> UUID.randomUUID().toString();
            case "random" -> ThreadLocalRandom.current().nextInt(intOf(p.get("min"), 0), intOf(p.get("max"), 100) + 1);
            default -> throw new IllegalArgumentException("Unknown crypto op '" + op + "'");
        };
        return Map.of("result", result);
    }

    private int intOf(Object o, int def) {
        try {
            return o == null ? def : Integer.parseInt(String.valueOf(o));
        } catch (NumberFormatException e) {
            return def;
        }
    }
}
