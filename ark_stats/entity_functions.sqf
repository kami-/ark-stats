#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\entity.h"
#include "logbook.h"


ark_stats_entity_fnc_preInit = {
    ark_stats_entity_lastId = 1;
    ark_stats_entity_trackingDelay = 4;
    ark_stats_entity_positiontrackingMinDistance = 4;
    if (!ark_stats_ext_hasError) then {
        DEBUG("ark.stats.entity","Preinit was successfull.");
    } else {
        ERROR("ark.stats.entity","Preinit failed due to extension error.");
    };
    DEBUG("ark.stats.entity","Preinit done.");
};

ark_stats_entity_fnc_postInit = {
    addMissionEventHandler ["EntityKilled", ark_stats_entity_fnc_killedHandler];
    [] call ark_stats_entity_fnc_trackMarkers;
    [] spawn ark_stats_entity_fnc_track;
    DEBUG("ark.stats.entity","Postinit done.");
};

ark_stats_entity_fnc_trackMarkers = {
    {
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity","Stopping marker tracking due to extension error.");
        };
        if (_x find "hull" == -1) then {
            private _entityId = ark_stats_entity_lastId;
            ark_stats_entity_lastId = ark_stats_entity_lastId + 1;
            [_entityId] call ark_stats_ext_fnc_entity;
            if (ark_stats_ext_hasError) exitWith {
                ERROR("ark.stats.entity",FMT_2("Failed to create entity due to extension error for marker '%1' with ID '%2'.",_x,_entityId));
            };
            DEBUG("ark.stats.entity",FMT_2("Created new entity from marker '%1' with ID '%2'",_x,_entityId));
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_SHAPE, "", markerShape _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_TYPE, "", markerType _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_NAME, "", _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_TEXT, "", markerText _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_SIZE_A, (markerSize _x) select 0, ""] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_SIZE_B, (markerSize _x) select 1, ""] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_DIRECTION, markerDir _x, ""] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_COLOR, "", markerColor _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_BRUSH, "", markerBrush _x] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, ATTRIBUTE_TYPE_ID_MARKER_ALPHA, markerAlpha _x, ""] call ark_stats_ext_fnc_entityAttribute;
            [_entityId, POSITION_TYPE_ID_ENTITY_POSITION, markerPos _x] call ark_stats_ext_fnc_entityPosition;
        };
    } foreach allMapMarkers;
};


ark_stats_entity_fnc_track = {
    while {!ark_stats_ext_hasError} do {
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity","Stopping tracking due to extension error.");
        };
        [] call ark_stats_entity_fnc_trackPlayers;
        [] call ark_stats_entity_fnc_trackAiGroups;
        sleep ark_stats_entity_trackingDelay;
    };
    ERROR("ark.stats.entity","Stopping tracking due to extension error.");
};

ark_stats_entity_fnc_trackPlayers = {
    {
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity.player","Stopping player tracking due to extension error.");
        };
        if (!isNull _x && alive _x) then {
            DEBUG("ark.stats.entity.player",FMT_1("Unit '%1' is alive.",_x));
            if (isPlayer _x) then {
                DEBUG("ark.stats.entity.player",FMT_1("Unit '%1' is a player and will be tracked.",_x));
                [_x] call ark_stats_entity_fnc_trackPlayer;
            } else {
                DEBUG("ark.stats.entity.player",FMT_1("Unit '%1' is a playable unit and won't be tracked.",_x));
                if (!isNil {_x getVariable "ark_stats_entityId"}) then {
                    DEBUG("ark.stats.entity.player",FMT_2("Playable unit's '%1' entityId '%2' will be removed.",_x,_x getVariable "ark_stats_entityId"));
                    _x setVariable ["ark_stats_entityId", nil, true];
                };
            };
        };
    } foreach playableUnits;
};

ark_stats_entity_fnc_trackPlayer = {
    FUN_ARGS_1(_unit);

    private _entityId = _unit getVariable "ark_stats_entityId";
    if (isNil {_entityId}) then {
        _entityId = ark_stats_entity_lastId;
        ark_stats_entity_lastId = ark_stats_entity_lastId + 1;
        [_entityId] call ark_stats_ext_fnc_entity;
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity.player",FMT_2("Failed to create player entity due to extension error for unit '%1' with ID '%2'.",_unit,_entityId));
        };
        _unit setVariable ["ark_stats_entityId", _entityId, true];
        DEBUG("ark.stats.entity.player",FMT_2("Created new entity from unit '%1' with ID '%2'",_unit,_entityId));
        [_entityId, ATTRIBUTE_TYPE_ID_ENTITY_SIDE, "", side _unit] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_UID, "", getPlayerUID _unit] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_NAME, "", name _unit] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_GROUP, "", group _unit] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_IS_JIP, "", didJIPOwner _unit] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_FACTION, "", _unit getVariable ["hull3_faction", ""]] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_TEMPLATE, "", _unit getVariable ["hull3_gear_template", ""]] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_UNIFORM_TEMPLATE, "", _unit getVariable ["hull3_uniform_template", ""]] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_CLASS, "", _unit getVariable ["hull3_gear_class", ""]] call ark_stats_ext_fnc_entityAttribute;
    };
    [_unit, _entityId] call ark_stats_entity_fnc_trackPosition;
    [_unit, _entityId] call ark_stats_entity_fnc_trackVehicle;
};

ark_stats_entity_fnc_trackAiGroups = {
    {
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity.group","Stopping group tracking due to extension error.");
        };
        private ["_group", "_aliveCount", "_leader"];
        _group = _x;
        _leader = leader _group;
        _aliveCount = { alive _x } count units _group > 0;
        if (!isNull _x && {_aliveCount} && {!(_leader in playableUnits)}) then {
            DEBUG("ark.stats.entity.group",FMT_2("AI Group '%1' has '%2' alive units.",_x,_aliveCount));
            [_group, _leader, _aliveCount] call ark_stats_entity_fnc_trackAiGroup;
        };
    } foreach allGroups;
};

ark_stats_entity_fnc_trackAiGroup = {
    FUN_ARGS_3(_group,_leader,_aliveCount);

    private _entityId = _group getVariable "ark_stats_entityId";
    if (isNil {_entityId}) then {
        _entityId = ark_stats_entity_lastId;
        ark_stats_entity_lastId = ark_stats_entity_lastId + 1;
        [_entityId] call ark_stats_ext_fnc_entity;
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity.group",FMT_2("Failed to create group entity due to extension error for group '%1' with ID '%2'.",_group,_entityId));
        };
        _group setVariable ["ark_stats_entityId", _entityId, true];
        DEBUG("ark.stats.entity.group",FMT_2("Created new entity from group '%1' with ID '%2'",_group,_entityId));
        [_entityId, ATTRIBUTE_TYPE_ID_ENTITY_SIDE, "", side _group] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_AI_GROUP, "", _group] call ark_stats_ext_fnc_entityAttribute;
        [_entityId, ATTRIBUTE_TYPE_ID_AI_GROUP_ALIVE_COUNT, _aliveCount, ""] call ark_stats_ext_fnc_entityAttribute;
    };
    [_leader, _entityId] call ark_stats_entity_fnc_trackPosition;
    [_leader, _entityId] call ark_stats_entity_fnc_trackVehicle;
    [_group, _entityId] call ark_stats_entity_fnc_trackAiWaypointPosition;
};

ark_stats_entity_fnc_trackPosition = {
    FUN_ARGS_2(_unit,_entityId);

    private ["_previousPosition", "_currentPosition"];
    _previousPosition = _unit getVariable ["ark_stats_previousPosition", []];
    _currentPosition = getPosASL _unit;
    if (count _previousPosition == 0 || {_previousPosition distance2D _currentPosition > ark_stats_entity_positiontrackingMinDistance}) then {
        _unit setVariable ["ark_stats_previousPosition", _currentPosition, false];
        [_entityId, POSITION_TYPE_ID_ENTITY_POSITION, _currentPosition] call ark_stats_ext_fnc_entityPosition;
        TRACE("ark.stats.entity",FMT_5("Unit '%1' with ID '%2' has moved at least '%3' metres away from previous position '%4' to new position '%5'.",_unit,_entityId,ark_stats_entity_positiontrackingMinDistance,_previousPosition,_currentPosition));
    };
};

ark_stats_entity_fnc_trackAiWaypointPosition = {
    FUN_ARGS_2(_group,_entityId);

    private ["_previousWaypointPosition", "_currentWaypointPosition"];
    _previousWaypointPosition = _group getVariable ["ark_stats_previousWaypointPosition", []];
    _currentWaypointPosition = getWPPos [_group, currentWaypoint _group];
    if (count _previousWaypointPosition == 0) then {
        _group setVariable ["ark_stats_previousWaypointPosition", _currentWaypointPosition, false];
        [_entityId, POSITION_TYPE_ID_AI_WAYPOINT_POSITION, _currentWaypointPosition] call ark_stats_ext_fnc_entityPosition;
        TRACE("ark.stats.entity.group",FMT_5("Group '%1' with ID '%2' has changed waypoint position from '%3' to new position '%4'.",_group,_entityId,_previousWaypointPosition,_currentWaypointPosition));
    };
};

ark_stats_entity_fnc_trackVehicle = {
    FUN_ARGS_2(_unit,_entityId);

    private ["_previousVehicle", "_currentVehicle"];
    _previousVehicle = _unit getVariable ["ark_stats_previousVehicle", ""];
    _currentVehicle = typeOf vehicle _unit;
    if (_previousVehicle != _currentVehicle) then {
        _unit setVariable ["ark_stats_previousVehicle", _currentVehicle, false];
        [_entityId, EVENT_TYPE_ID_ENTITY_VEHICLE, "", _currentVehicle] call ark_stats_ext_fnc_entityEvent;
        TRACE("ark.stats.entity",FMT_4("Unit '%1' with ID '%2' has changed vehicle from '%3' to '%4'.",_unit,_entityId,_previousVehicle,_currentVehicle));
    };
};

ark_stats_entity_fnc_killedHandler = {
    FUN_ARGS_2(_killed,_killer);

    if (ark_stats_ext_hasError) exitWith {
        DEBUG("ark.stats.entity","Killed handler skipped due to extension error.");
    };
    private ["_killedEntityId", "_killerEntityId"];
    _killedEntityId = _killed getVariable "ark_stats_entityId";
    _killerEntityId = _killer getVariable "ark_stats_entityId";
    if (isNil {_killedEntityId}) exitWith {
        DEBUG("ark.stats.entity",FMT_1("Killed handler skipped. Killed unit '%1' is not tracked.",_killed));
    };
    if (!isNil {_killerEntityId}) then {
        [_killedEntityId, EVENT_TYPE_ID_ENTITY_KILLED_BY_ENTITY, _killerEntityId, ""] call ark_stats_ext_fnc_entityEvent;
        DEBUG("ark.stats.entity",FMT_4("Entity '%1' with ID '%2' was killed by entity '%3' with ID '%4'.",_killed,_killedEntityId,_killer,_killerEntityId));
    } else {
        [_killedEntityId, EVENT_TYPE_ID_ENTITY_KILLED_BY_UNKNOWN, "", [str _killer, ":", "-"] call CBA_fnc_replace] call ark_stats_ext_fnc_entityEvent;
        DEBUG("ark.stats.entity",FMT_3("Entity '%1' with ID '%2' was killed by unknown entity '%3'.",_killed,_killedEntityId,_killer));
    };
};
