#include "stats_macros.h"

#include "\userconfig\ark_stats_server\log\server.h"
#include "logbook.h"


stats_server_fnc_preInit = {
    stats_server_missionId = -1;
    [] call stats_server_fnc_logMission;
    DEBUG("ark.stats.server","Server preinit finished.");
};

stats_server_fnc_postInit = {
    [] call stats_server_fnc_registerEventHandlers;
    DEBUG("ark.stats.server","Server postinit finished.");
};

stats_server_fnc_registerEventHandlers = {
    onPlayerDisconnected {[[_uid, _name], stats_server_fnc_logPlayerDisconnect] call stats_server_fnc_waitForMissionInit;};
};

stats_server_fnc_waitForMissionInit = {
     _this spawn {
        FUN_ARGS_2(_arguments,_func);

        waitUntil {
            !isNil {stats_server_missionId} && {stats_server_missionId != -1};
        };
        _arguments call _func;
    };
};

// Ugly fix, need to add event to hull!!!!
stats_server_fnc_waitForSafetyTimerEnd = {
    DECLARE(_hullHasSafetyTimerEnded) = {true};
    if (!isNil {call compile "blufor"}) then {
        _hullHasSafetyTimerEnded = hull3_mission_fnc_hasSafetyTimerEnded;
    } else {
        _hullHasSafetyTimerEnded = hull_mission_fnc_hasSafetyTimerEnded;
    };
    if (!isNil {_hullHasSafetyTimerEnded}) then {
        DECLARE(_waitIteration) = ceil ((60 / stats_server_safetyTimerEndDelay) * 30);
        for "_i" from 1 to _waitIteration do {
            if ([] call _hullHasSafetyTimerEnded) exitWith {
                [] call stats_server_fnc_logSafetyTimerEnd;
            };
            sleep stats_server_safetyTimerEndDelay;
        };
    };
};

stats_server_fnc_missionInit = {
    FUN_ARGS_2(_rows,_arguments);

    DEBUG("ark.stats.server",FMT_1("Mission logged with id '%1'.",parseNumber (_rows select 0)));
    stats_server_missionId = parseNumber (_rows select 0);
    [] spawn stats_server_fnc_trackingLoop;
    [] spawn stats_server_fnc_waitForSafetyTimerEnd;
};

stats_server_fnc_playerInit = {
    FUN_ARGS_2(_rows,_arguments);

    (_arguments select 0) setVariable ["stats_playerId", parseNumber (_rows select 0), true];
};

stats_server_fnc_trackingLoop = {
    sleep stats_server_trackingDelay;
    waitUntil {
        DEBUG("ark.stats.server",FMT_1("New tracking loop started for mission with id '%1'",stats_server_missionId));
        [] call stats_server_fnc_trackAiGroupMovements;
        [] call stats_server_fnc_trackPlayerMovements;
        sleep stats_server_trackingDelay;
        false;
    };
};

stats_server_fnc_trackAiGroupMovements = {
    {
        DECLARE(_group) = _x;
        if ({alive _x} count units _group > 0 && {!(leader _group in playableUnits)}) then {
            [_group] call stats_server_fnc_logAiGroupMovement;
        };
    } foreach allGroups;
};

stats_server_fnc_trackPlayerMovements = {
    {
        if (alive _x && {!isNil {_x getVariable "stats_playerId"}}) then {
            [_x] call stats_server_fnc_logPlayerMovement;
        };
    } foreach ([] call CBA_fnc_players);
};

stats_server_fnc_getUnitVehicleType = {
    FUN_ARGS_1(_unit);

    if (vehicle _unit != _unit) then {
        format ["'%1'", typeof vehicle _unit];
    } else {
        "";
    };
};

stats_server_fnc_logMission = {
    DECLARE(_query) = "INSERT INTO mission(id, mission_name, world_name, safety_timer, safety_timer_ingame, end, end_ingame) VALUES (NULL, '%1', '%2', NULL, NULL, NULL, NULL); SELECT last_insert_rowid();";
    [format [_query, SQ_TRY_EMPTY(missionName), SQ_TRY_EMPTY(worldName)], [], stats_server_fnc_missionInit] call stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server","Logged new mission.");
};

stats_server_fnc_logPlayer = {
    FUN_ARGS_6(_player,_uid,_playerName,_gearClass,_groupName,_isJip);

    DECLARE(_query) = "INSERT INTO player(id, created_ingame, mission_id, player_uid, player_name, hull_gear_class, group_name, is_jip, death, death_ingame) VALUES (NULL, %1, %2, '%3', '%4', '%5', '%6', %7, NULL, NULL); SELECT last_insert_rowid();";
    [
        format [_query, time, stats_server_missionId, SQ_TRY_EMPTY(_uid), SQ_TRY_EMPTY(_playerName), SQ_TRY_EMPTY(_gearClass), SQ_TRY_EMPTY(_groupName), [_isJip] call stats_sql_fnc_boolToInt],
        [_player],
        stats_server_fnc_playerInit
    ] call stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Player logged for mission with id '%1'",stats_server_missionId));
};

stats_server_fnc_logPlayerKilled = {
    FUN_ARGS_1(_player);

    DECLARE(_id) = _player getVariable "stats_playerId";
    if (!isNil {_id}) then {
        DECLARE(_query) = "UPDATE player SET death = CURRENT_TIMESTAMP, death_ingame = '%1' WHERE id = %2;";
        [format [_query, time, _id], [], {} ] call stats_sql_fnc_executeQuery;
    };
    DEBUG("ark.stats.server",FMT_1("Player kill logged for mission with id '%1'",stats_server_missionId));
};

stats_server_fnc_logPlayerDisconnect = {
    FUN_ARGS_2(_uid,_playerName);

    if (_playerName != "__SERVER__") then {
        DECLARE(_query) = "INSERT INTO disconnect(id, created_ingame, mission_id, player_uid, player_name) VALUES (NULL, %1, %2, '%3', '%4');";
        [format [_query, time, stats_server_missionId, SQ_TRY_EMPTY(_uid), SQ_TRY_EMPTY(_playerName)], [], {}] call stats_sql_fnc_executeQuery;
        DEBUG("ark.stats.server",FMT_1("Player diconnect logged for mission with id '%1'",stats_server_missionId));
    };
};

stats_server_fnc_logAiGroupMovement = {
    FUN_ARGS_1(_group);

    private ["_query", "_leader", "_currentWaypoint", "_formattedQuery"];
    _query = "INSERT INTO ai_movement(id, created_ingame, mission_id, position, group_name, alive_count, vehicle, waypoint_position, waypoint_type) VALUES (NULL, %1, %2, '%3', '%4', %5, '%6', '%7', '%8');";
    _leader = leader _group;
    _currentWaypoint = [_group, currentWaypoint _group];
    _formattedQuery = format [_query, time, stats_server_missionId, SQ_TRY_EMPTY(position _leader), SQ_TRY_EMPTY(_group), {alive _x} count units _group,
        SQ_TRY_EMPTY([_leader] call stats_server_fnc_getUnitVehicleType), SQ_TRY_EMPTY(getWPPos _currentWaypoint), SQ_TRY_EMPTY(waypointType _currentWaypoint)];
    [_formattedQuery, [], {}] call stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("AI movement logged for mission with id '%1'",stats_server_missionId));
};

stats_server_fnc_logPlayerMovement = {
    FUN_ARGS_1(_player);

    DECLARE(_query) = "INSERT INTO player_movement(id, created_ingame, player_id, position, vehicle) VALUES (NULL, %1, %2, '%3', '%4');";
    [format [_query, time, _player getVariable "stats_playerId", SQ_TRY_EMPTY(position _player), SQ_TRY_EMPTY([_player] call stats_server_fnc_getUnitVehicleType)], [], {}] call stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Player movement logged for mission with id '%1'",stats_server_missionId));
};

stats_server_fnc_logSafetyTimerEnd = {
    DECLARE(_query) = "UPDATE mission SET safety_timer = CURRENT_TIMESTAMP, safety_timer_ingame = '%1' WHERE id = %2;";
    [format [_query, time, stats_server_missionId], [], {} ] call stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Safety timer end logged for mission with id '%1'",stats_server_missionId));
};
