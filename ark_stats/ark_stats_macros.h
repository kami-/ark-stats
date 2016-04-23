#ifndef ARK_STATS_MACROS_H
#define ARK_STATS_MACROS_H

#include "\userconfig\ark_stats\log\global.h"

#define ARK_STATS_VERSION               "0.1.0"

#define CONCAT_ADDON_PATH(FILE)         x\ark\addons\ark_stats\FILE
#define ADDON_PATH(FILE)                #CONCAT_ADDON_PATH(FILE)

#define STATS_BASE_CONFIG               "ArkStats"
#define STATS_MISSION_CONFIG_FILE       missionConfigFile >> STATS_BASE_CONFIG
#define STATS_CONFIG_FILE               configFile >> STATS_BASE_CONFIG

#define CONFIG_TYPE_BOOL                0
#define CONFIG_TYPE_NUMBER              1
#define CONFIG_TYPE_TEXT                2
#define CONFIG_TYPE_ARRAY               3
#define CONFIG_TYPE_FUNCTIONS           [ark_stats_config_fnc_getBool, ark_stats_config_fnc_getNumber, ark_stats_config_fnc_getText, ark_stats_config_fnc_getArray]

#define EXTENSION_NAME                                              "ark_stats_extension"
#define RESULT_ID_IDX                                               0
#define RESULT_TYPE_IDX                                             1
#define RESULT_DATA_IDX                                             2

#define RESULT_TYPE_OK                                              0
#define RESULT_TYPE_ERROR                                           1


// Extension call type IDs
#define CALL_TYPE_ID_VERSION                                        "ve"
#define CALL_TYPE_ID_MISSION                                        "mi"
#define CALL_TYPE_ID_MISSION_ATTRIBUTE                              "ma"
#define CALL_TYPE_ID_MISSION_EVENT                                  "me"
#define CALL_TYPE_ID_ENTITY                                         "en"
#define CALL_TYPE_ID_ENTITY_ATTRIBUTE                               "ea"
#define CALL_TYPE_ID_ENTITY_EVENT                                   "ee"
#define CALL_TYPE_ID_ENTITY_POSITION                                "ep"


// Attribute type IDs
#define ATTRIBUTE_TYPE_ID_MISSION_NAME                              1
#define ATTRIBUTE_TYPE_ID_MISSION_WORLD                             2
#define ATTRIBUTE_TYPE_ID_MISSION_DATE                              3
#define ATTRIBUTE_TYPE_ID_MISSION_TIME                              4
#define ATTRIBUTE_TYPE_ID_MISSION_FOG                               5
#define ATTRIBUTE_TYPE_ID_MISSION_WEATHER                           6

#define ATTRIBUTE_TYPE_ID_ENTITY_SIDE                               7

#define ATTRIBUTE_TYPE_ID_PLAYER_UID                                8
#define ATTRIBUTE_TYPE_ID_PLAYER_NAME                               9
#define ATTRIBUTE_TYPE_ID_PLAYER_GROUP                              10
#define ATTRIBUTE_TYPE_ID_PLAYER_IS_JIP                             11
#define ATTRIBUTE_TYPE_ID_PLAYER_HULL_FACTION                       12
#define ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_TEMPLATE                 13
#define ATTRIBUTE_TYPE_ID_PLAYER_HULL_UNIFORM_TEMPLATE              14
#define ATTRIBUTE_TYPE_ID_PLAYER_HULL_GEAR_CLASS                    15


// Event type IDs
#define EVENT_TYPE_ID_MISSION_SAFETY_ENDED                          1

#define EVENT_TYPE_ID_ENTITY_KILLED                                 2
#define EVENT_TYPE_ID_ENTITY_VEHICLE                                3

#define EVENT_TYPE_ID_PLAYER_CONNECTED                              4
#define EVENT_TYPE_ID_PLAYER_DISCONNECTED                           5


// Position type IDs
#define POSITION_TYPE_ID_ENTITY_POSITION                            1

#define POSITION_TYPE_ID_AI_POSITION                                2



// WARNING
// Macros are sensitive for "," (comma), "(", ")" (parenthese) and " " (space).
// Provide only the asked numbers of arguments, without additional commas and without spaces beetween commas.
// Example:
//      PUSH_ALL(_units, [_unit] call getPlayersAroundUnit);
//      This will work as intended.
//      PUSH_ALL(_units, [_unit, 100] call getPlayersAroundUnit);
//      This won't work, as the macro identifies 100 as a third parameter.
//      Use AS_ARRAY_* instead of passing actual arrays.
//      PUSH_ALL(_units, AS_ARRAY_2(_unit, 100) call getPlayersAroundUnit);

// Creates private declaritions for arguments.
// Example:
//      GIVEN:
//      WHEN:
//          PVT_3(_unit,_group,_trigger); 
//      THEN:
//          private ["_unit","_group","_trigger"];
#define PVT_1(VAR1) private [#VAR1]
#define PVT_2(VAR1,VAR2) private [#VAR1,#VAR2]
#define PVT_3(VAR1,VAR2,VAR3) private [#VAR1,#VAR2,#VAR3]
#define PVT_4(VAR1,VAR2,VAR3,VAR4) private [#VAR1,#VAR2,#VAR3,#VAR4]
#define PVT_5(VAR1,VAR2,VAR3,VAR4,VAR5) private [#VAR1,#VAR2,#VAR3,#VAR4,#VAR5]
#define PVT_6(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6) private [#VAR1,#VAR2,#VAR3,#VAR4,#VAR5,#VAR6]
#define PVT_7(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7) private [#VAR1,#VAR2,#VAR3,#VAR4,#VAR5,#VAR6,#VAR7]
#define PVT_8(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8) private [#VAR1,#VAR2,#VAR3,#VAR4,#VAR5,#VAR6,#VAR7,#VAR8]
#define PVT_9(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8,VAR9) private [#VAR1,#VAR2,#VAR3,#VAR4,#VAR5,#VAR6,#VAR7,#VAR8,#VAR9]


// Creates array selection for arguments. Only works if the array is a variable!
// Example:
//      GIVEN:
//          _strings = ["unit", "group", "trigger"];
//      WHEN:
//          SELECT_3(_strings,_unit,_group,_trigger); 
//      THEN:
//          _unit == "unit";
//          _group == "group";
//          _trigger == "trigger";
#define SELECT_1(ARRAY,VAR1) VAR1 = (ARRAY) select 0
#define SELECT_2(ARRAY,VAR1,VAR2) SELECT_1(ARRAY,VAR1); VAR2 = (ARRAY) select 1
#define SELECT_3(ARRAY,VAR1,VAR2,VAR3) SELECT_2(ARRAY,VAR1,VAR2); VAR3 = (ARRAY) select 2
#define SELECT_4(ARRAY,VAR1,VAR2,VAR3,VAR4) SELECT_3(ARRAY,VAR1,VAR2,VAR3); VAR4 = (ARRAY) select 3
#define SELECT_5(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5) SELECT_4(ARRAY,VAR1,VAR2,VAR3,VAR4); VAR5 = (ARRAY) select 4
#define SELECT_6(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6) SELECT_5(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5); VAR6 = (ARRAY) select 5
#define SELECT_7(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7) SELECT_6(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6); VAR7 = (ARRAY) select 6
#define SELECT_8(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8) SELECT_7(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7); VAR8 = (ARRAY) select 7
#define SELECT_9(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8,VAR9) SELECT_8(ARRAY,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8); VAR9 = (ARRAY) select 8


// Creates private declarations and selection from _this array for arguments.
// Recommended for function/script argument processing.
// Example:
//      GIVEN:
//          _this = ["unit", "group", "trigger"];
//      WHEN:
//          FUN_ARGS_3(_unit,_group,_trigger);
//      THEN:
//          private ["_unit","_group","_trigger"];
//          _unit == "unit";
//          _group == "group";
//          _trigger == "trigger";
#define FUN_ARGS_1(VAR1) \
    PVT_1(VAR1); \
    SELECT_1(_this,VAR1)
    
#define FUN_ARGS_2(VAR1,VAR2) \
    PVT_2(VAR1,VAR2); \
    SELECT_2(_this,VAR1,VAR2)
    
#define FUN_ARGS_3(VAR1,VAR2,VAR3) \
    PVT_3(VAR1,VAR2,VAR3); \
    SELECT_3(_this,VAR1,VAR2,VAR3)
    
#define FUN_ARGS_4(VAR1,VAR2,VAR3,VAR4) \
    PVT_4(VAR1,VAR2,VAR3,VAR4); \
    SELECT_4(_this,VAR1,VAR2,VAR3,VAR4)
    
#define FUN_ARGS_5(VAR1,VAR2,VAR3,VAR4,VAR5) \
    PVT_5(VAR1,VAR2,VAR3,VAR4,VAR5); \
    SELECT_5(_this,VAR1,VAR2,VAR3,VAR4,VAR5)
    
#define FUN_ARGS_6(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6) \
    PVT_6(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6); \
    SELECT_6(_this,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6)
    
#define FUN_ARGS_7(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7) \
    PVT_7(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7); \
    SELECT_7(_this,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7)
    
#define FUN_ARGS_8(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8) \
    PVT_8(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8); \
    SELECT_8(_this,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8)
    
#define FUN_ARGS_9(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8,VAR9) \
    PVT_9(VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8,VAR9); \
    SELECT_9(_this,VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7,VAR8,VAR9)

// Adds a value to the end of an array.
// Example:
//      GIVEN:
//          _numbers = [1, 3, 5, 1];
//          _number = 1;
//      WHEN:
//          PUSH(_numbers, _number);
//      THEN:
//          _numbers == [1, 3, 5, 1, 1];
#define PUSH(ARRAY,VAL) (ARRAY) set [count (ARRAY), (VAL)]

// Adds all values from one array to another.
// Example:
//      GIVEN:
//          _numbers = [5, 9, 6];
//          _otherNumbers = [1, 3, 8];
//      WHEN:
//          PUSH_ALL(_numbers, _otherNumbers);
//      THEN:
//          _numbers == [5, 9, 6, 1, 3, 8];
#define PUSH_ALL(TO,FROM) { PUSH(TO,_x); } foreach (FROM)

// Filters the FROM array with a condition and adds the values that return true to the TO array.
// The values from the FROM array can be referenced by variable "_x".
// Example:
//      GIVEN:
//          _numbers = [];
//          _otherNumbers = [1, 2, 3, 6, 8];
//          _condition = {_x % 2 == 0};
//      WHEN:
//          FILTER_PUSH_ALL(_numbers, _otherNumbers, _condition);
//      THEN:
//          _numbers == [2, 6, 8];
#define FILTER_PUSH_ALL(TO,FROM,COND) { if (call COND) then { PUSH(TO,_x); }; } foreach (FROM)

// Selects a random value from an array.
// Example:
//      GIVEN:
//          _behaviours = ['AWARE', 'SAFE'];
//      WHEN:
//          _random = SELECT_RAND(_behaviours);
//      THEN:
//          _random == 'AWARE' or _random == 'AWARE'
#define SELECT_RAND(ARRAY) (ARRAY) select (floor (random (count (ARRAY))))

// Adds 1 to the variable.
// Example:
//      GIVEN:
//          _i = 0;
//      WHEN:
//          INC(_i);
//      THEN:
//          _i == 1;
#define INC(VAR) VAR = VAR + 1

// Subtracts 1 from the variable.
// Example:
//      GIVEN:
//          _i = 3;
//      WHEN:
//          DEC(_i);
//      THEN:
//          _i == 2;
#define DEC(VAR) VAR = VAR - 1

// Creates an array from given arguments.
// Example:
//      GIVEN:
//      WHEN:
//          _array = AS_ARRAY_2('AWARE','SAFE');
//      THEN:
//          _array == ['AWARE', 'SAFE'];
#define AS_ARRAY_1(VAL1) [VAL1]
#define AS_ARRAY_2(VAL1,VAL2) [VAL1,VAL2]
#define AS_ARRAY_3(VAL1,VAL2,VAL3) [VAL1,VAL2,VAL3]
#define AS_ARRAY_4(VAL1,VAL2,VAL3,VAL4) [VAL1,VAL2,VAL3,VAL4]
#define AS_ARRAY_5(VAL1,VAL2,VAL3,VAL4,VAL5) [VAL1,VAL2,VAL3,VAL4,VAL5]

// Adds weapon to unit if it doesn't have one already.
#define TRY_ADD_WEAPON(UNIT,WEAPON) if (!((UNIT) hasWeapon (WEAPON))) then {(UNIT) addWeapon (WEAPON);};

// Creates a private declaration for a variable and enables instant assigment.
// Example:
//      GIVEN:
//      WHEN:
//          DECLARE(_group) = _x;
//      THEN:
//          private "_group"; _group = _x;
#define DECLARE(VAR) private #VAR; VAR

// Double quotes the given argument.
// Example:
//      GIVEN:
//      WHEN:
//          QOUTE(some_variable)
//      THEN:
//          "some_variable"
#define QUOTE(VAR) #VAR

#endif //ARK_STATS_MACROS_H