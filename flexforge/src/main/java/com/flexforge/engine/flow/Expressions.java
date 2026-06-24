package com.flexforge.engine.flow;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Minimal expression resolution for flow params. Supports {@code ${path.to.value}} lookups
 * into the flow context root ({input, steps, vars}). A param that is exactly one
 * placeholder resolves to the underlying typed value; a string with embedded placeholders
 * is interpolated. Maps and lists are resolved recursively.
 */
public final class Expressions {

    private static final Pattern TOKEN = Pattern.compile("\\$\\{([^}]+)}");
    private static final Pattern WHOLE = Pattern.compile("^\\$\\{([^}]+)}$");

    private Expressions() {
    }

    @SuppressWarnings("unchecked")
    public static Object resolve(Object value, Map<String, Object> root) {
        if (value instanceof String s) {
            return resolveString(s, root);
        }
        if (value instanceof Map<?, ?> map) {
            Map<String, Object> out = new LinkedHashMap<>();
            map.forEach((k, v) -> out.put(String.valueOf(k), resolve(v, root)));
            return out;
        }
        if (value instanceof List<?> list) {
            List<Object> out = new ArrayList<>();
            for (Object item : list) {
                out.add(resolve(item, root));
            }
            return out;
        }
        return value;
    }

    private static Object resolveString(String s, Map<String, Object> root) {
        Matcher whole = WHOLE.matcher(s);
        if (whole.matches()) {
            // A lone placeholder returns the underlying typed value (number, map, etc.).
            return lookup(whole.group(1).trim(), root);
        }
        Matcher m = TOKEN.matcher(s);
        StringBuilder sb = new StringBuilder();
        while (m.find()) {
            Object v = lookup(m.group(1).trim(), root);
            m.appendReplacement(sb, Matcher.quoteReplacement(v == null ? "" : String.valueOf(v)));
        }
        m.appendTail(sb);
        return sb.toString();
    }

    @SuppressWarnings("unchecked")
    public static Object lookup(String path, Map<String, Object> root) {
        Object current = root;
        for (String part : path.split("\\.")) {
            if (current instanceof Map<?, ?> map) {
                current = map.get(part);
            } else {
                return null;
            }
            if (current == null) {
                return null;
            }
        }
        return current;
    }
}
