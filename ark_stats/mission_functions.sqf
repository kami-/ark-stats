#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\mission.h"
#include "logbook.h"


ark_stats_mission_fnc_preInit = {
    ark_stats_mission_trackingDelay = 1;
    ark_stats_mission_id = -1;
    private _missionId = [] call ark_stats_ext_fnc_mission;
    if (!ark_stats_ext_hasError) then {
        ark_stats_mission_id = _missionId;
        DEBUG("ark.stats.mission",FMT_1("New mission ID is '%1'.",ark_stats_mission_id));
        [] call ark_stats_mission_fnc_logNameAndWorld;
    } else {
        ERROR("ark.stats.mission","Preinit failed to get new mission ID.");
    };
    DEBUG("ark.stats.mission","Preinit done.");
};

ark_stats_mission_fnc_postInit = {
    [] spawn ark_stats_mission_fnc_logEnvironment;
    DEBUG("ark.stats.mission","Postinit done.");
};

ark_stats_mission_fnc_logNameAndWorld = {
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_NAME, "", missionName] call ark_stats_ext_fnc_missionAttribute;
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_WORLD, "", worldName] call ark_stats_ext_fnc_missionAttribute;
};

ark_stats_mission_fnc_logEnvironment = {
    sleep 5;
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_DATE, "", hull3_mission_date] call ark_stats_ext_fnc_missionAttribute;
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_TIME, "", hull3_mission_timeOfDay] call ark_stats_ext_fnc_missionAttribute;
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_FOG, "", hull3_mission_fog] call ark_stats_ext_fnc_missionAttribute;
    [ark_stats_mission_id, ATTRIBUTE_TYPE_ID_MISSION_WEATHER, "", hull3_mission_weather] call ark_stats_ext_fnc_missionAttribute;
};

/*
ark_stats_fnc_postInit = {
    [] call ark_stats_fnc_registerEventHandlers;
    DEBUG("ark.stats.server","Server postinit finished.");
};

ark_stats_fnc_registerEventHandlers = {
    onPlayerDisconnected {[[_uid, _name], ark_stats_fnc_logPlayerDisconnect] call ark_stats_fnc_waitForMissionInit;};
};

ark_stats_fnc_waitForMissionInit = {
     _this spawn {
        FUN_ARGS_2(_arguments,_func);

        waitUntil {
            !isNil {ark_stats_missionId} && {ark_stats_missionId != -1};
        };
        _arguments call _func;
    };
};

// Ugly fix, need to add event to hull!!!!
ark_stats_fnc_waitForSafetyTimerEnd = {
    DECLARE(_hullHasSafetyTimerEnded) = {true};
    if (!isNil {call compile "blufor"}) then {
        _hullHasSafetyTimerEnded = hull3_mission_fnc_hasSafetyTimerEnded;
    } else {
        _hullHasSafetyTimerEnded = hull_mission_fnc_hasSafetyTimerEnded;
    };
    if (!isNil {_hullHasSafetyTimerEnded}) then {
        DECLARE(_waitIteration) = ceil ((60 / ark_stats_safetyTimerEndDelay) * 30);
        for "_i" from 1 to _waitIteration do {
            if ([] call _hullHasSafetyTimerEnded) exitWith {
                [] call ark_stats_fnc_logSafetyTimerEnd;
            };
            sleep ark_stats_safetyTimerEndDelay;
        };
    };
};

ark_stats_fnc_missionInit = {
    FUN_ARGS_2(_rows,_arguments);

    DEBUG("ark.stats.server",FMT_1("Mission logged with id '%1'.",parseNumber (_rows select 0)));
    ark_stats_missionId = parseNumber (_rows select 0);
    [] call ark_stats_fnc_logEnvironment;
    [] spawn ark_stats_fnc_trackingLoop;
    [] spawn ark_stats_fnc_waitForSafetyTimerEnd;
};

ark_stats_fnc_playerInit = {
    FUN_ARGS_2(_rows,_arguments);

    (_arguments select 0) setVariable ["stats_playerId", parseNumber (_rows select 0), true];
};

ark_stats_fnc_trackingLoop = {
    sleep ark_stats_trackingDelay;
    waitUntil {
        DEBUG("ark.stats.server",FMT_1("New tracking loop started for mission with id '%1'",ark_stats_missionId));
        [] call ark_stats_fnc_trackAiGroupMovements;
        [] call ark_stats_fnc_trackPlayerMovements;
        sleep ark_stats_trackingDelay;
        false;
    };
};

ark_stats_fnc_trackAiGroupMovements = {
    {
        DECLARE(_group) = _x;
        if ({alive _x} count units _group > 0 && {!(leader _group in playableUnits)}) then {
            [_group] call ark_stats_fnc_logAiGroupMovement;
        };
    } foreach allGroups;
};

ark_stats_fnc_trackPlayerMovements = {
    {
        if (alive _x && {!isNil {_x getVariable "stats_playerId"}}) then {
            [_x] call ark_stats_fnc_logPlayerMovement;
        };
    } foreach ([] call CBA_fnc_players);
};

ark_stats_fnc_getUnitVehicleType = {
    FUN_ARGS_1(_unit);

    if (vehicle _unit != _unit) then {
        format ["'%1'", typeof vehicle _unit];
    } else {
        "";
    };
};

ark_stats_fnc_logPlayer = {
    FUN_ARGS_6(_player,_uid,_playerName,_gearClass,_groupName,_isJip);

    DECLARE(_query) = "INSERT INTO player(id, created_ingame, mission_id, player_uid, player_name, hull_gear_class, group_name, is_jip, death, death_ingame) VALUES (NULL, %1, %2, '%3', '%4', '%5', '%6', %7, NULL, NULL); SELECT last_insert_rowid();";
    [
        format [_query, time, ark_stats_missionId, SQ_TRY_EMPTY(_uid), SQ_TRY_EMPTY(_playerName), SQ_TRY_EMPTY(_gearClass), SQ_TRY_EMPTY(_groupName), [_isJip] call ark_stats_sql_fnc_boolToInt],
        [_player],
        ark_stats_fnc_playerInit
    ] call ark_stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Player logged for mission with id '%1'",ark_stats_missionId));
};

ark_stats_fnc_logPlayerKilled = {
    FUN_ARGS_1(_player);

    DECLARE(_id) = _player getVariable "stats_playerId";
    if (!isNil {_id}) then {
        DECLARE(_query) = "UPDATE player SET death = CURRENT_TIMESTAMP, death_ingame = '%1' WHERE id = %2;";
        [format [_query, time, _id], [], {} ] call ark_stats_sql_fnc_executeQuery;
    };
    DEBUG("ark.stats.server",FMT_1("Player kill logged for mission with id '%1'",ark_stats_missionId));
};

ark_stats_fnc_logPlayerDisconnect = {
    FUN_ARGS_2(_uid,_playerName);

    if (_playerName != "__SERVER__") then {
        DECLARE(_query) = "INSERT INTO disconnect(id, created_ingame, mission_id, player_uid, player_name) VALUES (NULL, %1, %2, '%3', '%4');";
        [format [_query, time, ark_stats_missionId, SQ_TRY_EMPTY(_uid), SQ_TRY_EMPTY(_playerName)], [], {}] call ark_stats_sql_fnc_executeQuery;
        DEBUG("ark.stats.server",FMT_1("Player diconnect logged for mission with id '%1'",ark_stats_missionId));
    };
};

ark_stats_fnc_logAiGroupMovement = {
    FUN_ARGS_1(_group);

    private ["_query", "_leader", "_currentWaypoint", "_formattedQuery"];
    _query = "INSERT INTO ai_movement(id, created_ingame, mission_id, position, group_name, alive_count, vehicle, waypoint_position, waypoint_type) VALUES (NULL, %1, %2, '%3', '%4', %5, '%6', '%7', '%8');";
    _leader = leader _group;
    _currentWaypoint = [_group, currentWaypoint _group];
    _formattedQuery = format [_query, time, ark_stats_missionId, SQ_TRY_EMPTY(position _leader), SQ_TRY_EMPTY(_group), {alive _x} count units _group,
        SQ_TRY_EMPTY([_leader] call ark_stats_fnc_getUnitVehicleType), SQ_TRY_EMPTY(getWPPos _currentWaypoint), SQ_TRY_EMPTY(waypointType _currentWaypoint)];
    [_formattedQuery, [], {}] call ark_stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("AI movement logged for mission with id '%1'",ark_stats_missionId));
};

ark_stats_fnc_logPlayerMovement = {
    FUN_ARGS_1(_player);

    DECLARE(_query) = "INSERT INTO player_movement(id, created_ingame, player_id, position, vehicle) VALUES (NULL, %1, %2, '%3', '%4');";
    [format [_query, time, _player getVariable "stats_playerId", SQ_TRY_EMPTY(position _player), SQ_TRY_EMPTY([_player] call ark_stats_fnc_getUnitVehicleType)], [], {}] call ark_stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Player movement logged for mission with id '%1'",ark_stats_missionId));
};

ark_stats_fnc_logSafetyTimerEnd = {
    DECLARE(_query) = "UPDATE mission SET safety_timer = CURRENT_TIMESTAMP, safety_timer_ingame = '%1' WHERE id = %2;";
    [format [_query, time, ark_stats_missionId], [], {} ] call ark_stats_sql_fnc_executeQuery;
    DEBUG("ark.stats.server",FMT_1("Safety timer end logged for mission with id '%1'",ark_stats_missionId));
};
*/