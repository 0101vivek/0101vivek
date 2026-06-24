package com.flexforge.engine.flow.steps;

import com.flexforge.engine.config.model.StepConfig;
import com.flexforge.engine.data.DynamicCrudService;
import com.flexforge.engine.data.QueryOptions;
import com.flexforge.engine.flow.Expressions;
import com.flexforge.engine.flow.FlowContext;
import com.flexforge.engine.flow.FlowStep;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * "db" step: performs CRUD against an entity through the same generic CRUD engine the REST
 * and GraphQL surfaces use. params: {op: create|list|get|update|delete, entity, data, id}.
 */
@Component
public class DbStep implements FlowStep {

    private final DynamicCrudService crud;

    public DbStep(DynamicCrudService crud) {
        this.crud = crud;
    }

    @Override
    public String type() {
        return "db";
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(StepConfig step, FlowContext ctx) {
        Map<String, Object> p = (Map<String, Object>) Expressions.resolve(step.params, ctx.root());
        String op = String.valueOf(p.getOrDefault("op", "list"));
        String entity = String.valueOf(p.get("entity"));
        Object id = p.get("id");
        Map<String, Object> data = (Map<String, Object>) p.get("data");

        return switch (op) {
            case "create" -> crud.create(entity, data);
            case "get" -> crud.findById(entity, id);
            case "update" -> crud.update(entity, id, data);
            case "delete" -> Map.of("deleted", crud.delete(entity, id));
            case "list" -> crud.list(entity, QueryOptions.defaults());
            default -> throw new IllegalArgumentException("Unknown db op '" + op + "'");
        };
    }
}
