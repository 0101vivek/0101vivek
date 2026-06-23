package com.flexforge.engine.data;

import java.util.LinkedHashMap;
import java.util.Map;

/** Pagination, sorting and equality filters for a list query. */
public class QueryOptions {

    public int page = 0;
    public int size = 20;
    public String sort;          // logical field name
    public String direction = "ASC";

    /** Equality filters keyed by logical field name. */
    public Map<String, Object> filters = new LinkedHashMap<>();

    public static QueryOptions defaults() {
        return new QueryOptions();
    }
}
