CREATE TABLE IF NOT EXISTS 'mission' (
    'id' INTEGER PRIMARY KEY,
    'created' TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    'mission_name' TEXT NOT NULL,
    'world_name' TEXT NOT NULL,
    'safety_timer' TEXT,
    'safety_timer_ingame' REAL,
    'end' TEXT,
    'end_ingame' REAL
);