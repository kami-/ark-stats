#include "ark_stats_macros.h"

class CfgPatches {
    class ArkStatsServer {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {"CBA_MAIN", "Hull3"};
        author[] = {"Kami", "Ark"};
        authorUrl = "https://github.com/kami-";
    };
};

class Extended_PreInit_EventHandlers {
    class ArkStatsServer {
        init = "[] call compile preProcessFileLineNumbers 'x\ark\addons\ark_stats\ark_stats_preinit.sqf';";
    };
};

class Extended_PostInit_EventHandlers {
    class ArkStatsServer {
        init = "[] call compile preProcessFileLineNumbers 'x\ark\addons\ark_stats\ark_stats_postinit.sqf';";
    };
};

#include "ark_stats.h"