CREATE TABLE IF NOT EXISTS player (
    'id' INTEGER PRIMARY KEY,
    'created' TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    'created_ingame' REAL NOT NULL,
    'mission_id' INTEGER NOT NULL,
    'player_uid' TEXT NOT NULL,
    'player_name' TEXT NOT NULL,
    'hull_gear_class' TEXT,
    'group_name' TEXT NOT NULL,
    'is_jip' BOOLEAN NOT NULL,
    'death' TEXT,
    'death_ingame' REAL
);