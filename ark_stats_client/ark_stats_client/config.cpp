#include "stats_macros.h"

__EXEC(_stats_hull_addon = "Hull3"; _stop = false; while {isNil {call compile "blufor"} && {!_stop}} do {_stats_hull_addon = "Hull"; _stop = true;};)

class CfgPatches {
    class ArkStatsClient {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"CBA_MAIN", __EVAL(_stats_hull_addon)};
        author[] = {"Kami", "Ark"};
        authorUrl = "https://github.com/kami-";
    };
};

class Extended_PreInit_EventHandlers {
    class ArkStatsClient {
        init = "[] call compile preProcessFileLineNumbers 'x\ark\addons\ark_stats_client\stats_preinit.sqf';";
    };
};