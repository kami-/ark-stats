#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\mission.h"
#include "logbook.h"


ark_stats_mission_fnc_preInit = {
    ark_stats_mission_id = -1;
    ark_stats_mission_ignoreSessionCheck = ["ignoreSessionCheck"] call ark_stats_config_fnc_getBool;
    private _isSession = ([] call ark_stats_ext_fnc_isSession) != 0;
    if (!_isSession && {!ark_stats_mission_ignoreSessionCheck}) exitWith {
        INFO("ark.stats.mission","Ignoring mission as it is not playerd in session time.");
        ark_stats_isEnabled = false;
    };
    [] call ark_stats_ext_fnc_connect;
    if (ark_stats_ext_hasError) exitWith {
        ERROR("ark.stats.mission","Preinit failed to connect to the database.");
    };
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
    addMissionEventHandler ["PlayerConnected", ark_stats_mission_fnc_connectedHandler];
    addMissionEventHandler ["HandleDisconnect", ark_stats_mission_fnc_disconnectedHandler];
    if (!isNil {hull3_isEnabled} && {hull3_isEnabled}) then {
        ["mission.safetytimer.ended", ark_stats_mission_fnc_safetyEndeddHandler] call hull3_event_fnc_addEventHandler;
    };
    [] spawn ark_stats_mission_fnc_logEnvironment;
    DEBUG("ark.stats.mission","Postinit done.");
};

ark_stats_mission_fnc_logNameAndWorld = {
    [ATTRIBUTE_TYPE_ID_MISSION_NAME, "", missionName] call ark_stats_ext_fnc_missionAttribute;
    [ATTRIBUTE_TYPE_ID_MISSION_WORLD, "", worldName] call ark_stats_ext_fnc_missionAttribute;
};

ark_stats_mission_fnc_logEnvironment = {
    sleep 5;
    [ATTRIBUTE_TYPE_ID_MISSION_DATE, "", hull3_mission_date] call ark_stats_ext_fnc_missionAttribute;
    [ATTRIBUTE_TYPE_ID_MISSION_TIME, "", hull3_mission_timeOfDay] call ark_stats_ext_fnc_missionAttribute;
    [ATTRIBUTE_TYPE_ID_MISSION_FOG, "", hull3_mission_fog] call ark_stats_ext_fnc_missionAttribute;
    [ATTRIBUTE_TYPE_ID_MISSION_WEATHER, "", hull3_mission_weather] call ark_stats_ext_fnc_missionAttribute;
};

ark_stats_mission_fnc_connectedHandler = {
    FUN_ARGS_3(_id,_uid,_name);

    if (ark_stats_ext_hasError) exitWith {
        DEBUG("ark.stats.mission","Connected handler skipped due to extension error.");
    };
    private _charValue = [_uid, [_name, ":", "-"] call CBA_fnc_replace];
    [EVENT_TYPE_ID_PLAYER_CONNECTED, "", _charValue] call ark_stats_ext_fnc_missionEvent;
    DEBUG("ark.stats.mission",FMT_2("Player '%1' connected with UID '%2'.",_name,_uid));
};

ark_stats_mission_fnc_disconnectedHandler = {
    FUN_ARGS_4(_unit,_id,_uid,_name);

    if (ark_stats_ext_hasError) exitWith {
        DEBUG("ark.stats.mission","Connected handler skipped due to extension error.");
    };
    private _entityId = _unit getVariable "ark_stats_entityId";
    if (!isNil {_entityId}) then {
        [EVENT_TYPE_ID_PLAYER_DISCONNECTED_FROM_ENTITY, _entityId, ""] call ark_stats_ext_fnc_missionEvent;
        DEBUG("ark.stats.mission",FMT_4("Player '%1' disconnected with UID '%2' and unit '%3' with ID '%4'.",_name,_uid,_unit,_entityId));
    } else {
        private _charValue = [_uid, [_name, ":", "-"] call CBA_fnc_replace, [str _unit, ":", "-"] call CBA_fnc_replace];
        [EVENT_TYPE_ID_PLAYER_DISCONNECTED, "", _charValue] call ark_stats_ext_fnc_missionEvent;
        DEBUG("ark.stats.mission",FMT_3("Player '%1' disconnected with UID '%2' and unknown unit '%3'.",_name,_uid,_unit));
    };
};

ark_stats_mission_fnc_safetyEndeddHandler = {
    if (ark_stats_ext_hasError) exitWith {
        DEBUG("ark.stats.mission","Safety Ended handler skipped due to extension error.");
    };
    [EVENT_TYPE_ID_MISSION_SAFETY_ENDED, "", ""] call ark_stats_ext_fnc_missionEvent;
    DEBUG("ark.stats.mission","Mission safety ended.");
};