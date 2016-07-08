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
    char_value VARCHAR(1000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;
ALTER TABLE mission_attribute ADD INDEX (mission_id);

CREATE TABLE IF NOT EXISTS mission_event (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    event_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(1000),

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
    char_value VARCHAR(1000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;
ALTER TABLE entity_attribute ADD INDEX (entity_id);

CREATE TABLE IF NOT EXISTS entity_event (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    mission_id INT UNSIGNED NOT NULL,
    entity_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    event_type_id INT UNSIGNED NOT NULL,
    numeric_value DOUBLE,
    char_value VARCHAR(1000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;
ALTER TABLE entity_attribute ADD INDEX (mission_id);
ALTER TABLE entity_attribute ADD INDEX (entity_id);

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
    attribute_name VARCHAR(1000) NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS event_type (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(1000) NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS position_type (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    position_name VARCHAR(1000) NOT NULL,

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

SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.shape';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.type';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.name';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.text';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.size_a';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.size_b';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.direction';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.color';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.brush';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'marker.alpha';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;

SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'ai.group';
INSERT INTO attribute_type(id, attribute_name) VALUES(@attribute_type_id, @attribute_name) ON DUPLICATE KEY UPDATE attribute_name = @attribute_name;
SET @attribute_type_id = @attribute_type_id + 1; SET @attribute_name = 'ai.group.alive_count';
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




CREATE TABLE IF NOT EXISTS transformed_mission (
    id BIGINT UNSIGNED NOT NULL,
    created VARCHAR(50) NOT NULL,
    name VARCHAR(1000),
    world VARCHAR(1000),
    date VARCHAR(1000),
    time VARCHAR(1000),
    duration DOUBLE,
    fog VARCHAR(1000),
    weather VARCHAR(1000),

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE PROCEDURE transform_missions()
    INSERT INTO transformed_mission SELECT
        m.id AS id
        , DATE_FORMAT(m.created, '%Y-%m-%d %k:%i:%s') AS created
        , name.char_value AS name
        , world.char_value AS world
        , date.char_value AS date
        , time.char_value AS time
        , (SELECT MAX(ep.gameTime) FROM entity_position ep WHERE ep.mission_id = m.id) AS duration
        , fog.char_value AS fog
        , weather.char_value AS weather
        , (SELECT COUNT(DISTINCT ea.char_value) FROM entity_attribute ea WHERE ea.mission_id = m.id AND ea.attribute_type_id = 9) AS actual_players
    FROM mission m
    LEFT JOIN mission_attribute name ON m.id = name.mission_id AND name.attribute_type_id = 1
    LEFT JOIN mission_attribute world ON m.id = world.mission_id AND world.attribute_type_id = 2
    LEFT JOIN mission_attribute date ON m.id = date.mission_id AND date.attribute_type_id = 3
    LEFT JOIN mission_attribute time ON m.id = time.mission_id AND time.attribute_type_id = 4
    LEFT JOIN mission_attribute fog ON m.id = fog.mission_id AND fog.attribute_type_id = 5
    LEFT JOIN mission_attribute weather ON m.id = weather.mission_id AND weather.attribute_type_id = 6
    WHERE m.id NOT IN (SELECT id FROM transformed_mission)
    ORDER BY m.created DESC;

CREATE EVENT IF NOT EXISTS transform_missions
ON SCHEDULE EVERY 1 WEEK
    STARTS TIMESTAMP(DATE(NOW() + INTERVAL 7 - WEEKDAY(NOW()) DAY), '00:00:00')
DO
    CALL transform_missions();




CREATE TABLE IF NOT EXISTS transformed_player (
    id BIGINT UNSIGNED NOT NULL,
    mission_id INT UNSIGNED NOT NULL,
    gameTime DOUBLE UNSIGNED NOT NULL,
    side VARCHAR(50),
    uid VARCHAR(50),
    name VARCHAR(1000),
    group_name VARCHAR(1000),
    is_jip BOOLEAN,
    hull_faction VARCHAR(1000),
    hull_gear_template VARCHAR(1000),
    hull_uniform_template VARCHAR(1000),
    hull_gear_class VARCHAR(1000),
    kill_count INT UNSIGNED NOT NULL,

    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE PROCEDURE transform_players()
    INSERT INTO transformed_player SELECT
        e.id AS id
        , e.mission_id AS mission_id
        , e.gameTime AS gameTime
        , side.char_value AS side
        , uid.char_value AS uid
        , name.char_value AS name
        , group_name.char_value AS group_name
        , CASE is_jip.char_value
            WHEN 'true' THEN 1
            ELSE 0
          END CASE AS is_jip
        , hull_faction.char_value AS hull_faction
        , hull_gear_template.char_value AS hull_gear_template
        , hull_uniform_template.char_value AS hull_uniform_template
        , hull_gear_class.char_value AS hull_gear_class
        , (SELECT COUNT(ee.id) FROM entity_event ee WHERE ee.mission_id = e.mission_id AND ee.event_type_id = 2 AND ee.numeric_value = e.id) AS kill_count
    FROM entity e
    LEFT JOIN entity_attribute side ON e.id = side.entity_id AND side.attribute_type_id = 7
    LEFT JOIN entity_attribute uid ON e.id = uid.entity_id AND uid.attribute_type_id = 8
    LEFT JOIN entity_attribute name ON e.id = name.entity_id AND name.attribute_type_id = 9
    LEFT JOIN entity_attribute group_name ON e.id = group_name.entity_id AND group_name.attribute_type_id = 10
    LEFT JOIN entity_attribute is_jip ON e.id = is_jip.entity_id AND is_jip.attribute_type_id = 11
    LEFT JOIN entity_attribute hull_faction ON e.id = hull_faction.entity_id AND hull_faction.attribute_type_id = 12
    LEFT JOIN entity_attribute hull_gear_template ON e.id = hull_gear_template.entity_id AND hull_gear_template.attribute_type_id = 13
    LEFT JOIN entity_attribute hull_uniform_template ON e.id = hull_uniform_template.entity_id AND hull_uniform_template.attribute_type_id = 14
    LEFT JOIN entity_attribute hull_gear_class ON e.id = hull_gear_class.entity_id AND hull_gear_class.attribute_type_id = 15
    WHERE e.id NOT IN (SELECT id FROM transformed_player)
    ORDER BY e.gameTime, name.char_value DESC;

CREATE EVENT IF NOT EXISTS transform_players
ON SCHEDULE EVERY 1 WEEK
    STARTS TIMESTAMP(DATE(NOW() + INTERVAL 7 - WEEKDAY(NOW()) DAY), '00:00:00')
DO
    CALL transform_players();
