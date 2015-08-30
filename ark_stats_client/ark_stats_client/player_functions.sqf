#include "stats_macros.h"


stats_player_fnc_preInit = {
    DECLARE(_hullAddEventHandler) = {};
    if (!isNil {call compile "blufor"}) then {
        _hullAddEventHandler = hull3_event_fnc_addEventHandler;
    } else {
        _hullAddEventHandler = hull_event_fnc_addEventHandler;
    };
    ["player.initialized", stats_player_fnc_addKilledEH] call _hullAddEventHandler;
    ["marker.group.created", stats_player_fnc_logPlayer] call _hullAddEventHandler;
};

stats_player_fnc_addKilledEH = {
    FUN_ARGS_1(_unit);

    DECLARE(_ehId) = _unit addEventHandler ["Killed", {
        FUN_ARGS_2(_unit,_killer);
        [0, {
            if (!isNil {stats_server_isInitialized} && {stats_server_isInitialized}) then {
                _this call stats_server_fnc_logPlayerKilled;
            };
        }, [_unit]] call CBA_fnc_globalExecute;
        if (!isNil {_unit getVariable "stats_eh_killed"}) then {
            _unit removeEventHandler ["Killed", _unit getVariable "stats_eh_killed"];
            _unit setVariable ["stats_eh_killed", nil];
        };
    }];
    _unit setVariable ["stats_eh_killed", _ehId];
};

stats_player_fnc_logPlayer = {
    private ["_arguments", "_hullGearClass"];
    _arguments = [];
    PUSH(_arguments,player);
    PUSH(_arguments,if (getPlayerUID player == "") then {"<No UID>"} else {getPlayerUID player});
    PUSH(_arguments,name player);
    _hullGearClass = "hull_gear_class";
    if (!isNil {call compile "blufor"}) then {
        _hullGearClass = "hull3_gear_class";
    };
    PUSH(_arguments,player getVariable AS_ARRAY_2(_hullGearClass, ""));
    PUSH(_arguments,str group player);
    PUSH(_arguments,SLX_XEH_MACHINE select 1);
    [0, {
        if (!isNil {stats_server_isInitialized} && {stats_server_isInitialized}) then {
            [_this, stats_server_fnc_logPlayer] call stats_server_fnc_waitForMissionInit;
        };
    }, _arguments] call CBA_fnc_globalExecute;
};