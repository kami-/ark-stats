#include "stats_macros.h"

#include "\userconfig\ark_stats_server\log\sql.h"
#include "logbook.h"

#include "\userconfig\ark_stats_server\sql\config.sqf"


stats_sql_fnc_preInit = {
    [] call stats_sql_fnc_initSchema;
    stats_sql_canExecuteQuery = true;
};

stats_sql_fnc_executeQuery = {
    _this spawn {
        FUN_ARGS_3(_query,_arguments,_callback);

        waitUntil {
            !isNil {stats_sql_canExecuteQuery} && {stats_sql_canExecuteQuery};
        };
        stats_sql_canExecuteQuery = false;
        DECLARE(_result) = nil;
        while {isNil {_result}} do {
            // SQL standard uses single qoutes, so we use them in the query strings too. With A2NET bad empty string parsing we have to wrap the DB and query in double qoutes to parse empty strings correctly!
            _result = "Arma2Net.Unmanaged" callExtension format ['Arma2NETMySQLCommandAsync ["%1", "%2"]', stats_sql_dataBase, _query];
            TRACE("ark.stats.sql.query",FMT_2("Ran query '%1' with result '%2'.",_query,_result));
            if (_result == "") then {
                _result = nil;
            };
            sleep stats_sql_asyncPollingDelay;
        };
        stats_sql_canExecuteQuery = true;
        [(call compile _result) select 0 select 0, _arguments] call _callback;
        DEBUG("ark.stats.sql",FMT_2("Query '%1' executed with result '%2'.",_query,_result));
    };
};

stats_sql_fnc_executeQuerySynchronous = {
    FUN_ARGS_1(_query);

    // SQL standard uses single qoutes, so we use them in the query strings too. With A2NET bad empty string parsing we have to wrap the DB and query in double qoutes to parse empty strings correctly!
    DECLARE(_result) = "Arma2Net.Unmanaged" callExtension format ['Arma2NETMySQLCommand ["%1", "%2"]', stats_sql_dataBase, _query];
    TRACE("ark.stats.sql.query",FMT_2("Ran synchronous query '%1' with result '%2'.",_query,_result));

    _result;
};

stats_sql_fnc_initSchema = {
    {
        DECLARE(_query) = loadFile format ["%1\%2.sql", SQL_BASE_PATH, _x];
        [_query] call stats_sql_fnc_executeQuerySynchronous;
    } foreach stats_sql_tables;
};

stats_sql_fnc_quoteStringOrNull = {
    FUN_ARGS_2(_string,_nullValue);

    if (_string == _nullValue) then {
        "NULL";
    } else {
        format ["'%1'", _string];
    };
};

stats_sql_fnc_boolToInt = {
    FUN_ARGS_1(_bool);

    if (_bool) then {1} else {0};
};