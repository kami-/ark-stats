#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\preinit.h"
#include "logbook.h"


if (isServer) then {
    ark_stats_isInitialized = false;

    [] call compile preProcessFileLineNumbers ADDON_PATH(config_functions.sqf);
    ark_stats_isEnabled = ["isEnabled"] call ark_stats_config_fnc_getBool;

    if (ark_stats_isEnabled) then {
        [] call compile preProcessFileLineNumbers ADDON_PATH(extension_functions.sqf);
        [] call compile preProcessFileLineNumbers ADDON_PATH(mission_functions.sqf);
        [] call compile preProcessFileLineNumbers ADDON_PATH(entity_functions.sqf);

        ark_stats_isInitialized = true;
        INFO("ark.stats",FMT_1("Ark Stats version '%1' has been successfully initialized.",ARK_STATS_VERSION));

        [] call ark_stats_ext_fnc_preInit;
        INFO("ark.stats",FMT_1("Ark Stats Extension version '%1' has been loaded.",[] call ark_stats_ext_fnc_version));
        [] call ark_stats_mission_fnc_preInit;
        [] call ark_stats_entity_fnc_preInit;
    } else {
        INFO("ark.stats",FMT_1("Ark Stats Server version '%1' was disabled.",ARK_STATS_VERSION));
    };
};