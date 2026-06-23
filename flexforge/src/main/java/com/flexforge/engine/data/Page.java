package com.flexforge.engine.data;

import java.util.List;
import java.util.Map;

/** A page of rows plus pagination metadata, returned by list queries. */
public record Page(List<Map<String, Object>> content, long total, int page, int size) {
}
