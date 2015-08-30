#include "stats_macros.h"

#include "\userconfig\ark_stats_server\log\postinit.h"
#include "logbook.h"


if (isServer) then {
    [] call stats_server_fnc_postInit;
};