##Setup
Have MySQL 5.7 at least installed with `show_compatibility_56=on` in `my.cnf`.
Execute `db.sql` to create the database. Make sure you change the password.
Copy `config.txt` to `c:\Users\{User}\AppData\Local\ArkStatsExtension\` folder. The config has the following format:
```
<log level: info, debug or trace>
<server hostname>
<server port>
<user>
<password>
<database>
```

##Extension
###Dependencies
You will need to build POCO yourself. Data/Mysql has a dependency on MySQL C Connector. Build everything for 32bit.

* POCO C++ http://pocoproject.org/
    ** Foundation
    ** Data
    ** Data/MySQL

* MySQL C Connector https://dev.mysql.com/downloads/connector/c/

* spdlog https://github.com/gabime/spdlog  (put `spdlog` directory it in `extension/include`)

###Cmake
Update `POCO_HOME` in `extension/build/CmMakeLists.txt` to match your POCO directory. Run `cmake . -G "Visual Studio 14 2015"`.
You will have to copy the `PocoFoundation.dll`, `PocoData.dll`, `PocoDataMySQL.dll` from `POCO_HOME/bin` and `libmysql.dll` from `MYSQL_C_CONNECTOR_HOME/lib` 
to the Release/Debug directories.
