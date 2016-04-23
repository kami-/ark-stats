CREATE DATABASE ark_stats CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON ark_stats.* TO 'ark_stats'@'%' INDENTIFIED BY 'password';
GRANT SELECT ON performance_schema.global_variables TO 'ark_stats'@'%';
FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS mission (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    created DATETIME NOT NULL, -- Need to set this to UTC_TIMESTAMP() on INSERT manually

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mission_attribute (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    attribute_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(10000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mission_event (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    event_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(10000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS entity (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS entity_attribute (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    entity_id INT UNSIGNED NOT NULL,
    attribute_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(10000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS entity_event (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    entity_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    event_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(10000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS entity_position (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    entity_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    position_type_id INT UNSIGNED NOT NULL,
    pos_x DOUBLE,
    pos_y DOUBLE,
    pos_z DOUBLE,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS attribute_type (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    attribute_name VARCHAR(10000) NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS event_type (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(10000) NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS position_type (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    position_name VARCHAR(10000) NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;


SET @attribute_type_id = 0;
SET @attribute_type_name = '';

SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.name';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.world';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.date';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.time';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.fog';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'mission.weather';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;

SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'entity.side';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;

SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.uid';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.name';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.group';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.is_jip';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.hull_faction';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.hull_gear_template';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.hull_uniform_template';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'player.hull_gear_class';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;




SET @event_type_id = 0;
SET @event_type_name = '';

SET @event_type_id = @event_type_id + 1; SET @event_name = 'mission.safety_ended';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;

SET @event_type_id = @event_type_id + 1; SET @event_name = 'entity.killed_by_entity';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;
SET @event_type_id = @event_type_id + 1; SET @event_name = 'entity.killed_by_unkown';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;
SET @event_type_id = @event_type_id + 1; SET @event_name = 'entity.vehicle';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;

SET @event_type_id = @event_type_id + 1; SET @event_name = 'player.connected';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;
SET @event_type_id = @event_type_id + 1; SET @event_name = 'player.disconnected_from_entity';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;
SET @event_type_id = @event_type_id + 1; SET @event_name = 'player.disconnected';
INSERT INTO event_type(id, event_name) VALUES(@event_type_id, @event_name) ON DUPLICATE KEY UPDATE event_name = @event_name;




SET @position_type_id = 0;
SET @position_type_name = '';

SET @position_type_id = @position_type_id + 1; SET @position_name = 'entity.position';
INSERT INTO position_type(id, position_name) VALUES(@position_type_id, @position_name) ON DUPLICATE KEY UPDATE position_name = @position_name;

SET @position_type_id = @position_type_id + 1; SET @position_name = 'ai.waypoint_position';
INSERT INTO position_type(id, position_name) VALUES(@position_type_id, @position_name) ON DUPLICATE KEY UPDATE position_name = @position_name;