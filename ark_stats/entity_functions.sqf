#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\entity.h"
#include "logbook.h"


ark_stats_entity_fnc_preInit = {
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
            _entityId = [ark_stats_mission_id] call ark_stats_ext_fnc_entity;
            if (ark_stats_ext_hasError) exitWith {
                ERROR("ark.stats.entity",FMT_1("Failed to create entity due to extension error for marker '%1'.",_x));
            };
            DEBUG("ark.stats.entity",FMT_2("Created new entity from marker '%1' with ID '%2'",_x,_entityId));
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_SHAPE, "", markerShape _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_TYPE, "", markerType _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_NAME, "", _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_TEXT, "", markerText _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_SIZE_A, (markerSize _x) select 0, ""] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_SIZE_B, (markerSize _x) select 1, ""] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_DIRECTION, markerDir _x, ""] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_COLOR, "", markerColor _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_BRUSH, "", markerBrush _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_MARKER_ALPHA, markerAlpha _x, ""] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, POSITION_TYPE_ID_ENTITY_POSITION, markerPos _x] call ark_stats_ext_fnc_entityPosition;
        };
    } foreach allMapMarkers;
};

ark_stats_entity_fnc_track = {
    while {!ark_stats_ext_hasError} do {
        {
            if (ark_stats_ext_hasError) exitWith {
                ERROR("ark.stats.entity","Stopping tracking due to extension error.");
            };
            if (!isNull _x && alive _x) then {
                DEBUG("ark.stats.entity",FMT_1("Unit '%1' is alive.",_x));
                if (isPlayer _x || {!(_x in playableUnits)}) then {
                    DEBUG("ark.stats.entity",FMT_1("Unit '%1' is a player or AI and will be tracked.",_x));
                    [_x] call ark_stats_entity_fnc_trackEntity;
                } else {
                    DEBUG("ark.stats.entity",FMT_1("Unit '%1' is a playable unit and won't be tracked.",_x));
                    if (!isNil {_x getVariable "ark_stats_entityId"}) then {
                        DEBUG("ark.stats.entity",FMT_2("Playable unit's '%1' entityId '%2' will be removed.",_x,_x getVariable "ark_stats_entityId"));
                        _x setVariable ["ark_stats_entityId", nil, true];
                    };
                };
            };
        } foreach allUnits;
        sleep ark_stats_mission_trackingDelay;
    };
    ERROR("ark.stats.entity","Stopping tracking due to extension error.");
};

ark_stats_entity_fnc_trackEntity = {
    FUN_ARGS_1(_unit);

    private _entityId = _x getVariable "ark_stats_entityId";
    if (isNil {_entityId}) then {
        _entityId = [ark_stats_mission_id] call ark_stats_ext_fnc_entity;
        if (ark_stats_ext_hasError) exitWith {
            ERROR("ark.stats.entity",FMT_1("Failed to create entity due to extension error for unit '%1'.",_unit));
        };
        _x setVariable ["ark_stats_entityId", _entityId, true];
        DEBUG("ark.stats.entity",FMT_2("Created new entity from unit '%1' with ID '%2'",_unit,_entityId));
        [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_ENTITY_SIDE, "", side _x] call ark_stats_ext_fnc_entityAttribute;
        if (isPlayer _x) then {
            DEBUG("ark.stats.entity",FMT_2("Tracking player unit '%1' with ID '%2'.",_unit,_entityId));
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_UID, "", getPlayerUID _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_NAME, "", name _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_GROUP, "", group _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_IS_JIP, "", didJIPOwner _x] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_FACTION, "", _x getVariable ["hull3_faction", ""]] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_TEMPLATE, "", _x getVariable ["hull3_gear_template", ""]] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_UNIFORM_TEMPLATE, "", _x getVariable ["hull3_uniform_template", ""]] call ark_stats_ext_fnc_entityAttribute;
            [ark_stats_mission_id, _entityId, ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_CLASS, "", _x getVariable ["hull3_gear_class", ""]] call ark_stats_ext_fnc_entityAttribute;
        };
    };
    [ark_stats_mission_id, _entityId, POSITION_TYPE_ID_ENTITY_POSITION, getPosASL _x] call ark_stats_ext_fnc_entityPosition;
    [ark_stats_mission_id, _entityId, EVENT_TYPE_ID_ENTITY_VEHICLE, "", typeOf _x] call ark_stats_ext_fnc_entityEvent;
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
        [ark_stats_mission_id, _killedEntityId, EVENT_TYPE_ID_ENTITY_KILLED_BY_ENTITY, _killerEntityId, ""] call ark_stats_ext_fnc_entityEvent;
        DEBUG("ark.stats.entity",FMT_4("Entity '%1' with ID '%2' was killed by entity '%3' with ID '%4'.",_killed,_killedEntityId,_killer,_killerEntityId));
    } else {
        [ark_stats_mission_id, _killedEntityId, EVENT_TYPE_ID_ENTITY_KILLED_BY_UNKNOWN, "", [str _killer, ":", "-"] call CBA_fnc_replace] call ark_stats_ext_fnc_entityEvent;
        DEBUG("ark.stats.entity",FMT_3("Entity '%1' with ID '%2' was killed by unknown entity '%3'.",_killed,_killedEntityId,_killer));
    };
};
