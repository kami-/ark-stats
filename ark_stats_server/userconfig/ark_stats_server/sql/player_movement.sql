CREATE TABLE IF NOT EXISTS 'player_movement' (
    'id' INTEGER PRIMARY KEY,
    'created' NOT NULL DEFAULT CURRENT_TIMESTAMP,
    'created_ingame' REAL NOT NULL,
    'player_id' INTEGER NOT NULL,
    'position' TEXT NOT NULL,
    'vehicle' TEXT
);