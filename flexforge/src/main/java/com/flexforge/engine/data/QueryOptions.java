package com.flexforge.engine.data;

import java.util.ArrayList;
import java.util.List;

/** Pagination, sorting and operator-aware filters for a list query. */
public class QueryOptions {

    public int page = 0;
    public int size = 20;
    public String sort;          // logical field name
    public String direction = "ASC";

    public List<Filter> filters = new ArrayList<>();

    public static QueryOptions defaults() {
        return new QueryOptions();
    }

    public void addFilter(String field, Op op, Object value) {
        filters.add(new Filter(field, op, value));
    }

    /** Supported filter operators, parsed from REST query-param suffixes. */
    public enum Op {
        EQ, NE, LIKE, GT, GTE, LT, LTE, IN;

        public static Op fromSuffix(String suffix) {
            return switch (suffix) {
                case "ne" -> NE;
                case "like" -> LIKE;
                case "gt" -> GT;
                case "gte" -> GTE;
                case "lt" -> LT;
                case "lte" -> LTE;
                case "in" -> IN;
                default -> EQ;
            };
        }
    }

    public record Filter(String field, Op op, Object value) {
    }
}
