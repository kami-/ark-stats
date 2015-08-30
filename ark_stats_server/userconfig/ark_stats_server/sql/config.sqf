stats_sql_dataBase = "ark_a2";
if (!isNil {call compile "blufor"}) then {
    stats_sql_dataBase = "ark_a3";
};
stats_sql_tables = ["mission", "player", "disconnect", "ai_movement", "player_movement"];
stats_sql_asyncPollingDelay = 0.1;

stats_server_trackingDelay = 20;
stats_server_safetyTimerEndDelay = 10;