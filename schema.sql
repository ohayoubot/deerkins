-- deerkins cloudflare D1 schema.
-- Apply with: pppm run db:init (local) / pnpm run db:init:remote

CREATE TABLE IF NOT EXISTS deer (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  date     TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
  creator  TEXT NOT NULL DEFAULT 'n/a',
  deer     TEXT NOT NULL,
  kinskode TEXT NOT NULL,
  irccode  TEXT NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS deer_name ON deer (deer);
CREATE INDEX IF NOT EXISTS deer_date ON deer (date DESC);

-- rows older than 24h are pruned on write, so this stays small.
CREATE TABLE IF NOT EXISTS save_log (
  ip_hash TEXT NOT NULL,
  ts      INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS save_log_ip_ts ON save_log (ip_hash, ts);
CREATE INDEX IF NOT EXISTS save_log_ts ON save_log (ts);
