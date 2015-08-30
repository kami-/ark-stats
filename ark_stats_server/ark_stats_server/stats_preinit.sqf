#include "stats_macros.h"

#include "\userconfig\ark_stats_server\log\preinit.h"
#include "logbook.h"

if (isServer) then {
    stats_server_isInitialized = false;

    [] call compile preProcessFileLineNumbers ADDON_PATH(sql_functions.sqf);
    [] call compile preProcessFileLineNumbers ADDON_PATH(server_functions.sqf);

    stats_server_isInitialized = true;
    INFO("ark.stats.server",FMT_1("Ark Stats Server version '%1' has been successfully initialized.",ARK_STATS_SERVER_VERSION));

    [] call stats_sql_fnc_preInit;
    [] call stats_server_fnc_preInit
};