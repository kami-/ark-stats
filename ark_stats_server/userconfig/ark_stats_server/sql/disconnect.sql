CREATE TABLE IF NOT EXISTS 'disconnect' (
    'id' INTEGER PRIMARY KEY,
    'created' NOT NULL DEFAULT CURRENT_TIMESTAMP,
    'created_ingame' REAL NOT NULL,
    'mission_id' INTEGER NOT NULL,
    'player_uid' TEXT NOT NULL,
    'player_name' TEXT NOT NULL
);