#include "stats_macros.h"

#define LOGGING_LEVEL_INFO
#define LOGGING_TO_RPT
#include "logbook.h"

stats_client_isInitialized = false;

if (!isDedicated) then {
    [] call compile preProcessFileLineNumbers ADDON_PATH(player_functions.sqf);
};

stats_client_isInitialized = true;
INFO("ark.stats.server",FMT_1("Ark Stats Client version '%1' has been successfully initialized.",ARK_STATS_CLIENT_VERSION));

if (!isDedicated) then {
    [] call stats_player_fnc_preInit;
};