package com.flexforge.engine.config.model;

/**
 * Database connection configuration. The engine ships every supported JDBC driver and
 * selects the dialect at boot, so a single artifact adapts to whichever DB the app
 * creator points it at. Connection secrets arrive via ${ENV} placeholders (12-factor),
 * never baked into the bundle.
 */
public class DatabaseConfig {

    /** postgres | mysql | h2 (oracle, sqlserver are roadmap). May be a ${ENV} placeholder. */
    public String engine = "h2";

    /** Full JDBC URL. May be a ${ENV} placeholder. */
    public String url;

    public String username;

    public String password;

    /** HikariCP pool sizing. Small pools outperform large ones (HikariCP guidance). */
    public Pool pool = new Pool();

    public static class Pool {
        public int maxSize = 15;
        public int minIdle = 7;
        public long maxLifetimeMs = 1_680_000L;
    }
}
