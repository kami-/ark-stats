#include "Extension.h"

#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <shlwapi.h>
#include "shlobj.h"

#include "Poco/StringTokenizer.h"
#include "Poco/Data/MySQL/MySQLException.h"
#include "Poco/Data/MySQL/Connector.h"

namespace ark_stats {

void Extension::init() {
    std::string logLevelStr, extensionFolder(getExtensionFolder());
    std::ifstream file(fmt::format("{}\\{}", extensionFolder, "config.txt"));
    std::getline(file, logLevelStr);
    std::getline(file, host);
    std::getline(file, port);
    std::getline(file, user);
    std::getline(file, password);
    std::getline(file, database);
    logger = spdlog::rotating_logger_mt("ark_stats_extension", fmt::format("{}\\{}", extensionFolder, getLogFileName()), 1024 * 1024 * 20, 1, true);
    logger->set_level(getLogLevel(logLevelStr));
    logger->info("=======================================================================");
    logger->info("Starting ark_stats_extension version '{}'.", ARK_STATS_EXTENSION_VERSION);
}

void Extension::cleanup() {
    if (isConnected) {
        delete session;
        requests.push(Request{ POISON_ID, "" });
        dbThread.join();
    }
    Poco::Data::MySQL::Connector::unregisterConnector();
    logger->info("Stopped ark_stats_extension version '{}'.", ARK_STATS_EXTENSION_VERSION);
}

void Extension::call(char* output, int outputSize, const char* function) {
    uint32_t requestId = idGenerator.next();
    if (hasError) {
        respond(output, requestId, ResponseType::error, "\"\"");
        return;
    }
    Request request{ requestId, "" };
    split(std::string(function), SQF_DELIMITER, request.params);
    if (!request.params.empty()) {
        request.type = request.params[0];
    }
    if (request.type == "co" || request.type == "se" || request.type == "ve" || request.type == "mi") {
        Response response;
        {
            std::lock_guard<std::mutex> lock(sessionMutex);
            response = processRequest(request);
        }
        respond(output, response.id, response.type, response.message);
    }
    else {
        requests.push(request);
        respond(output, request.id, ResponseType::ok, "\"\"");
    }
}

void Extension::connect() {
    logger->info("Connecting to MySQL server at '{}@{}:{}/{}'.", user, host, port, database);
    hasError = false;
    isConnected = false;
    try {
        Poco::Data::MySQL::Connector::registerConnector();
        session = new Poco::Data::Session("MySQL", fmt::format("host={};port={};db={};user={};password={};compress=true;auto-reconnect=true", host, port, database, user, password));
        isConnected = true;
        logger->trace("Creating DB thread.");
        dbThread = std::thread(&Extension::processRequests, this);
    }
    catch (Poco::Data::ConnectionFailedException& e) {
        logger->error("Failed to connect to MySQL server! Error code: '{}', Error message: {}", e.code(), e.displayText());
        hasError = true;
    }
    catch (Poco::Data::MySQL::ConnectionException& e) {
        logger->error("Failed to connect to MySQL server! Error code: '{}', Error message: {}", e.code(), e.displayText());
        hasError = true;
    }
}

spdlog::level::level_enum Extension::getLogLevel(const std::string& logLevelStr) {
    if (logLevelStr == "debug") { return spdlog::level::debug; }
    if (logLevelStr == "trace") { return spdlog::level::trace; }
    return spdlog::level::info;
}

void Extension::respond(char* output, const uint32_t& requestId, const ResponseType& type, const std::string& response) {
    std::string data = fmt::format("[{},{},{}]", requestId, type, response);
    data.copy(output, data.length());
    output[data.length()] = '\0';
}

std::vector<std::string>& Extension::split(const std::string &s, const std::string& delim, std::vector<std::string> &elems) {
    Poco::StringTokenizer tokenizer(s, delim, Poco::StringTokenizer::TOK_TRIM);
    for (auto token : tokenizer) {
        elems.push_back(token);
    }
    return elems;
}

std::string Extension::getExtensionFolder() {
    wchar_t wpath[MAX_PATH];
    std::string localAppData = ".";
    if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_LOCAL_APPDATA, NULL, 0, wpath))) {
        Poco::UnicodeConverter::toUTF8(wpath, localAppData);
        return fmt::format("{}\\ArkStatsExtension", localAppData);
    }
    return localAppData;
}

std::string Extension::getLogFileName() {
    std::time_t time = std::time(nullptr);
    std::tm* timeinfo = std::localtime(&time);
    char buffer[80];
    std::strftime(buffer, 80, "%Y-%m-%d", timeinfo);
    std::string fileName("ark_stats_extension-log_");
    fileName.append(buffer);
    return fileName;
}

uint32_t Extension::parseUnsigned(const std::string& str) {
    uint32_t number = 0;
    if (!Poco::NumberParser::tryParseUnsigned(str, number)) {
        return 0;
    }
    return number;
}

double Extension::parseFloat(const std::string& str) {
    double number = 0;
    if (!Poco::NumberParser::tryParseFloat(str, number)) {
        return 0;
    }
    return number;
}

Poco::Nullable<double> Extension::getNumericValue(const std::vector<std::string>& parameters, const size_t& idx) {
    if (parameters.size() > idx && !parameters[idx].empty()) {
        double number = 0;
        if (!Poco::NumberParser::tryParseFloat(parameters[idx], number)) {
            return Poco::Nullable<double>();
        }
        return Poco::Nullable<double>(number);
    }
    return Poco::Nullable<double>();
}

Poco::Nullable<std::string> Extension::getCharValue(const std::vector<std::string>& parameters, const size_t& idx) {
    if (parameters.size() > idx && !parameters[idx].empty()) {
        return Poco::Nullable<std::string>(parameters[idx]);
    }
    return Poco::Nullable<std::string>();
}

void Extension::processRequests() {
    logger->trace("Starting DB thread.");
    auto request = requests.pop();
    while (request.id != POISON_ID) {
        {
            std::lock_guard<std::mutex> lock(sessionMutex);
            processRequest(request);
        }
        request = requests.pop();
    }
    logger->trace("Stopping DB thread.");
}


Response Extension::processRequest(const Request& request) {
    Response response{ request.id, ResponseType::ok, "\"\"" };
    auto realParamsSize = request.params.size() - 1;
    std::stringstream ss;
    for (auto p : request.params) {
        ss << "'" << p << "', ";
    }
    logger->trace("[{}] Request type '{}' params '{}' and size '{}'!", request.id, request.type, ss.str(), request.params.size());
    try {
        if (request.type == "co" && realParamsSize == 0) { // connect
            if (!isConnected) {
                connect();
                response.message = "\"Connected to MySQL server.\"";
            }
        }
        else if (request.type == "se" && realParamsSize == 0) { // session
            Poco::DateTime now;
            bool isSaturdaySession = (now.dayOfWeek() == Poco::DateTime::SATURDAY && now.hour() >= SESSION_START_HOUR)
                || (now.dayOfWeek() == Poco::DateTime::SUNDAY && now.hour() <= SESSION_END_HOUR);
            bool isSundaySession = (now.dayOfWeek() == Poco::DateTime::SUNDAY && now.hour() >= SESSION_START_HOUR)
                || (now.dayOfWeek() == Poco::DateTime::MONDAY && now.hour() <= SESSION_END_HOUR);
            response.message = fmt::format("{}", isSaturdaySession || isSundaySession);
            logger->info("[{}] Is Saturday session '{}', is Sunday session '{}'.", request.id, isSaturdaySession, isSundaySession);
        }
        else if (request.type == "ve" && realParamsSize == 0) { // version
            response.message = fmt::format("\"{}\"", ARK_STATS_EXTENSION_VERSION);
        }
        else if (!isConnected) {
            logger->error("[{}] Connection lost to the MySQL server!", request.id);
            hasError = true;
        }
        else if (request.type == "mi" && realParamsSize == 0) { // mission
            logger->debug("[{}] Inserting into 'mission'.", request.id);
            *session << "INSERT INTO mission(created) VALUES(UTC_TIMESTAMP())",
                Poco::Data::Keywords::now;
            *session << "SELECT LAST_INSERT_ID()",
                Poco::Data::Keywords::into(missionId),
                Poco::Data::Keywords::now;
            logger->debug("[{}] New missionId is '{}'.", request.id, missionId);
            response.message = std::to_string(missionId);
            entityIds.clear();
        }
        else if (request.type == "ma" && realParamsSize == 3) { // mission_attribute
            uint32_t attributeTypeId = parseUnsigned(request.params[1]);
            Poco::Nullable<double> numericValue = getNumericValue(request.params, 2);
            Poco::Nullable<std::string> charValue = getCharValue(request.params, 3);
            logger->debug("[{}] Inserting into 'mission_attribute' values missionId '{}', attributeTypeId '{}', numericValue '{}', charValue '{}'.", request.id, missionId, attributeTypeId, numericValue, charValue);
            *session << "INSERT INTO mission_attribute(mission_id, attribute_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(attributeTypeId),
                Poco::Data::Keywords::use(numericValue),
                Poco::Data::Keywords::use(charValue),
                Poco::Data::Keywords::now;
        }
        else if (request.type == "me" && realParamsSize == 4) { // mission_event
            double gameTime = parseFloat(request.params[1]);
            uint32_t eventTypeId = parseUnsigned(request.params[2]);
            Poco::Nullable<double> numericValue = getNumericValue(request.params, 3);
            Poco::Nullable<std::string> charValue = getCharValue(request.params, 4);
            logger->debug("[{}] Inserting into 'mission_event' values missionId '{}', gameTime '{}', eventTypeId '{}', numericValue '{}', charValue '{}'.", request.id, missionId, gameTime, eventTypeId, numericValue, charValue);
            *session << "INSERT INTO mission_event(mission_id, gameTime, event_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(gameTime),
                Poco::Data::Keywords::use(eventTypeId),
                Poco::Data::Keywords::use(numericValue),
                Poco::Data::Keywords::use(charValue),
                Poco::Data::Keywords::now;
        }
        else if (request.type == "en" && realParamsSize == 2) { // entity
            uint32_t gameEntityId = parseUnsigned(request.params[1]);
            double gameTime = parseFloat(request.params[2]);
            logger->debug("[{}] Inserting into 'entity' values missionId '{}', gameTime '{}' for gameEntityId '{}'.", request.id, missionId, gameTime, gameEntityId);
            *session << "INSERT INTO entity(mission_id, gameTime) VALUES(?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(gameTime),
                Poco::Data::Keywords::now;
            uint64_t entityId = 0;
            *session << "SELECT LAST_INSERT_ID()",
                Poco::Data::Keywords::into(entityId),
                Poco::Data::Keywords::now;
            logger->debug("[{}] New entity is '{}' for game entity ID '{}'.", request.id, entityId, gameEntityId);
            entityIds[gameEntityId] = entityId;
        }
        else if (request.type == "ea" && realParamsSize == 4) { // entity_attribute
            uint32_t gameEntityId = parseUnsigned(request.params[1]);
            if (entityIds.count(gameEntityId) == 0) {
                logger->error("[{}] Missing entityId for gameEntityId '{}'.", request.id, gameEntityId);
                hasError = true;
                return response;
            }
            uint64_t entityId = entityIds[gameEntityId];
            uint32_t attributeTypeId = parseUnsigned(request.params[2]);
            Poco::Nullable<double> numericValue = getNumericValue(request.params, 3);
            Poco::Nullable<std::string> charValue = getCharValue(request.params, 4);
            logger->debug("[{}] Inserting into 'entity_attribute' values missionId '{}', entityId '{}', attributeTypeId '{}', numericValue '{}', charValue '{}'.", request.id, missionId, entityId, attributeTypeId, numericValue, charValue);
            *session << "INSERT INTO entity_attribute(mission_id, entity_id, attribute_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(entityId),
                Poco::Data::Keywords::use(attributeTypeId),
                Poco::Data::Keywords::use(numericValue),
                Poco::Data::Keywords::use(charValue),
                Poco::Data::Keywords::now;
        }
        else if (request.type == "ee" && realParamsSize == 5) { // entity_event
            uint32_t gameEntityId = parseUnsigned(request.params[1]);
            if (entityIds.count(gameEntityId) == 0) {
                logger->error("[{}] Missing entityId for gameEntityId '{}'.", request.id, gameEntityId);
                hasError = true;
                return response;
            }
            uint64_t entityId = entityIds[gameEntityId];
            double gameTime = parseFloat(request.params[2]);
            uint32_t eventTypeId = parseUnsigned(request.params[3]);
            Poco::Nullable<double> numericValue = getNumericValue(request.params, 4);
            Poco::Nullable<std::string> charValue = getCharValue(request.params, 5);
            logger->debug("[{}] Inserting into 'entity_event' values missionId '{}', entityId '{}', gameTime '{}', eventTypeId '{}', numericValue '{}', charValue '{}'.", request.id, missionId, entityId, gameTime, eventTypeId, numericValue, charValue);
            *session << "INSERT INTO entity_event(mission_id, entity_id, gameTime, event_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(entityId),
                Poco::Data::Keywords::use(gameTime),
                Poco::Data::Keywords::use(eventTypeId),
                Poco::Data::Keywords::use(numericValue),
                Poco::Data::Keywords::use(charValue),
                Poco::Data::Keywords::now;
        }
        else if (request.type == "ep" && realParamsSize == 6) { // entity_position
            uint32_t gameEntityId = parseUnsigned(request.params[1]);
            if (entityIds.count(gameEntityId) == 0) {
                logger->error("[{}] Missing entityId for gameEntityId '{}'.", request.id, gameEntityId);
                hasError = true;
                return response;
            }
            uint64_t entityId = entityIds[gameEntityId];
            double gameTime = parseFloat(request.params[2]);
            uint32_t positionTypeId = parseUnsigned(request.params[3]);
            double posX = parseFloat(request.params[4]);
            double posY = parseFloat(request.params[5]);
            double posZ = parseFloat(request.params[6]);
            logger->debug("[{}] Inserting into 'entity_position' values missionId '{}', entityId '{}', gameTime '{}', positionTypeId '{}', posX '{}', posY '{}, posZ '{}''.", request.id, missionId, entityId, gameTime, positionTypeId, posX, posY, posZ);
            *session << "INSERT INTO entity_position(mission_id, entity_id, gameTime, position_type_id, pos_x, pos_y, pos_z) VALUES(?, ?, ?, ?, ?, ?, ?)",
                Poco::Data::Keywords::use(missionId),
                Poco::Data::Keywords::use(entityId),
                Poco::Data::Keywords::use(gameTime),
                Poco::Data::Keywords::use(positionTypeId),
                Poco::Data::Keywords::use(posX),
                Poco::Data::Keywords::use(posY),
                Poco::Data::Keywords::use(posZ),
                Poco::Data::Keywords::now;
        }
        else {
            logger->debug("[{}] Invlaid command type '{}'!", request.id, request.type);
            response.type = ResponseType::error;
            response.message = fmt::format("\"Error executing prepared statement!\"");
        }
    }
    catch (Poco::Data::MySQL::MySQLException& e) {
        logger->error("Error executing prepared statement! Error code: '{}', Error message: {}", e.code(), e.displayText());
        hasError = true;
    }
    return response;
}

} // namespace ark_stats