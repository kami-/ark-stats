#include "ark_stats_macros.h"

#include "\userconfig\ark_stats\log\postinit.h"
#include "logbook.h"


if (isServer && {ark_stats_isEnabled}) then {
    if (!ark_stats_ext_hasError) then {
        [] call ark_stats_mission_fnc_postInit;
        [] call ark_stats_entity_fnc_postInit;
        DEBUG("ark.stats","Postinit was successfull.");
    } else {
        ERROR("ark.stats","Postinit failed due to extension error.");
    };
    DEBUG("ark.stats","Postinit done.");
};