CREATE TABLE IF NOT EXISTS 'ai_movement' (
    'id' INTEGER PRIMARY KEY,
    'created' NOT NULL DEFAULT CURRENT_TIMESTAMP,
    'created_ingame' REAL NOT NULL,
    'mission_id' INTEGER NOT NULL,
    'position' TEXT NOT NULL,
    'group_name' TEXT NOT NULL,
    'alive_count' INTEGER NOT NULL,
    'vehicle' TEXT,
    'waypoint_position' TEXT NOT NULL,
    'waypoint_type' TEXT NOT NULL
);