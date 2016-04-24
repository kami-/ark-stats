#include "Extension.h"

#include <fstream>
#include <iostream>
#include <string>
#include <sstream>

#include <shlwapi.h>
#include "shlobj.h"
#include "Poco/StringTokenizer.h"
#include "Poco/Nullable.h"
#include "Poco/Data/MySQL/MySQLException.h"

namespace ark_stats {
namespace extension {

Extension::Extension() {
	std::string logLevelStr, host, port, user, password, database, extensionFolder(getExtensionFolder());
	std::ifstream file(fmt::format("{}\\{}", extensionFolder, CONFIG_FILE_NAME));
	std::getline(file, logLevelStr);
	std::getline(file, host);
	std::getline(file, port);
	std::getline(file, user);
	std::getline(file, password);
	std::getline(file, database);
    logger = spdlog::rotating_logger_mt("ark_stats_extension", fmt::format("{}\\{}", extensionFolder, getLogFileName()), 1024 * 1024 * 20, 1, true);
    logger->set_level(getLogLevel(logLevelStr));
	logger->info("=======================================================================");
    logger->info("Starting Ark_Stats extension version '{}'.", ARK_STATS_EXTENSION_VERSION);
	connect(host, port, user, password, database);
}

Extension::~Extension() {
	disconnect();
    logger->info("Stopped Ark_Stats extension version '{}'.", ARK_STATS_EXTENSION_VERSION);
}

void Extension::connect(const std::string& host, const std::string& port, const std::string& user, const std::string& password, const std::string& database) {
	logger->info("Connecting to MySQL server at host '{}' as user '{}' to database '{}'.", host, user, database);
	isConnected = false;
	try {
		Poco::Data::MySQL::Connector::registerConnector();
		session = new Poco::Data::Session("MySQL", fmt::format("host={};port={};db={};user={};password={};compress=true;auto-reconnect=true", host, port, database, user, password));
		isConnected = true;
		logger->trace("Starting DB thread.");
		dbThread = std::thread(&Extension::processRequests, this);
		logger->trace("Started DB thread.");
	}
	catch (Poco::Data::ConnectionFailedException& e) {
		logger->error("Failed to connect to MySQL server! Error code: '{}', Error message: {}", e.code(), e.displayText());
	}
	catch (Poco::Data::MySQL::ConnectionException& e) {
		logger->error("Failed to connect to MySQL server! Error code: '{}', Error message: {}", e.code(), e.displayText());
	}
}
 
void Extension::disconnect() {
	if (isConnected) {
		delete session;
	}
	Poco::Data::MySQL::Connector::unregisterConnector();
	requests.push(Request(POISON_ID, ""));
	logger->trace("Pushed poison request.");
	dbThread.join();
	logger->trace("DB thread joined.");
}

spdlog::level::level_enum Extension::getLogLevel(const std::string& logLevelStr) const {
	if (logLevelStr == "debug") { return spdlog::level::debug; }
	if (logLevelStr == "trace") { return spdlog::level::trace; }
	return spdlog::level::info;
}

void Extension::respond(char* output, const uint32_t& requestId, const ResponseType& type, const std::string& response) const {
	std::string data = fmt::format("[{},{},{}]", requestId, type, response);
	data.copy(output, data.length());
	output[data.length()] = '\0';
}

std::vector<std::string>& Extension::split(const std::string &s, const std::string& delim, std::vector<std::string> &elems) const {
	Poco::StringTokenizer tokenizer(s, delim, Poco::StringTokenizer::TOK_TRIM);
	for (auto token : tokenizer) {
		elems.push_back(token);
	}
	return elems;
}

std::string Extension::getExtensionFolder() const {
	wchar_t wpath[MAX_PATH];
	std::string localAppData = ".";
	if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_LOCAL_APPDATA, NULL, 0, wpath))) {
		Poco::UnicodeConverter::toUTF8(wpath, localAppData);
		return fmt::format("{}\\ArkStatsExtension", localAppData);
	}
	return localAppData;
}

std::string Extension::getLogFileName() const {
    std::time_t time = std::time(nullptr);
    std::tm* timeinfo = std::localtime(&time);
    char buffer[80];
    std::strftime(buffer, 80, "%Y-%m-%d", timeinfo);
    std::string fileName("ark_stats_extension-log_");
    fileName.append(buffer);
    return fileName;
}

uint32_t Extension::parseUnsigned(const std::string& str) const {
	uint32_t number = 0;
	if (!Poco::NumberParser::tryParseUnsigned(str, number)) {
		return 0;
	}
	return number;
}

double Extension::parseFloat(const std::string& str) const {
	double number = 0;
	if (!Poco::NumberParser::tryParseFloat(str, number)) {
		return 0;
	}
	return number;
}

Poco::Nullable<double> Extension::getNumericValue(const std::vector<std::string>& parameters, const size_t& idx) const {
	if (parameters.size() > idx && !parameters[idx].empty()) {
		double number = 0;
		if (!Poco::NumberParser::tryParseFloat(parameters[idx], number)) {
			return Poco::Nullable<double>();
		}
		return Poco::Nullable<double>(number);
	}
	return Poco::Nullable<double>();
}

Poco::Nullable<std::string> Extension::getCharValue(const std::vector<std::string>& parameters, const size_t& idx) const {
	if (parameters.size() > idx && !parameters[idx].empty()) {
		return Poco::Nullable<std::string>(parameters[idx]);
	}
	return Poco::Nullable<std::string>();
}

void Extension::call(char* output, int outputSize, const char* function) {
	uint32_t requestId = idGenerator.next();
	logger->trace("Pushing new reuquest.");
	requests.push(Request(requestId, std::string(function)));
	logger->trace("Pushed new reuquest.");
	respond(output, requestId, ResponseType::ok, "\"\"");
	logger->trace("Sent response.");
}

void Extension::processRequests() {
	logger->trace("Running DB thread.");
	auto request = requests.pop();
	logger->trace("Popped new request.");
	while (request.id != POISON_ID) {
		{
			logger->trace("Accquired lock.");
			std::lock_guard<std::mutex> lock(sessionMutex);
			processRequest(request.id, request.data);
			logger->trace("Processed request.");
		}
		logger->trace("Dropped lock.");
		request = requests.pop();
		logger->trace("Popped new request.");
	}
	logger->trace("Stopping DB thread.");
}

void Extension::processRequest(const uint32_t& requestId, const std::string& data) {
	std::vector<std::string> parameters;
	std::string type = "";
	split(data, SQF_DELIMITER, parameters);
	if (!parameters.empty()) {
		type = parameters[0];
	}
	auto realParamsSize = parameters.size() - 1;
	std::stringstream ss;
	for (auto p : parameters) {
		ss << "'" << p << "', ";
	}
	logger->trace("[{}] Request parameters '{}' ({}) and size '{}'!", requestId, data, ss.str(), parameters.size());
	try {
		if (type == "ve" && realParamsSize == 0) { // version
			//respond(output, requestId, ResponseType::ok, fmt::format("\"{}\"", ARK_STATS_EXTENSION_VERSION));
		}
		else if (!isConnected) {
			logger->error("[{}] Connection lost to the MySQL server!", requestId);
			//respond(output, requestId, ResponseType::error, "\"Connection lost to the MySQL server!\"");
		}
		else if (type == "mi" && realParamsSize == 0) { // mission
			logger->debug("[{}] Inserting into 'mission'.", requestId);
			*session << "INSERT INTO mission(created) VALUES(UTC_TIMESTAMP())",
				Poco::Data::Keywords::now;
			uint32_t id = 0;
			*session << "SELECT LAST_INSERT_ID()",
				Poco::Data::Keywords::into(id),
				Poco::Data::Keywords::now;
			logger->debug("[{}] New missionId is '{}'.", requestId, id);
			//respond(output, requestId, ResponseType::ok, std::to_string(id));
		}
		else if (type == "ma" && realParamsSize == 4) { // mission_attribute
			uint32_t missionId = parseUnsigned(parameters[1]);
			uint32_t attributeTypeId = parseUnsigned(parameters[2]);
			Poco::Nullable<double> numericValue = getNumericValue(parameters, 3);
			Poco::Nullable<std::string> charValue = getCharValue(parameters, 4);
			logger->debug("[{}] Inserting into 'mission_attribute' values missionId '{}', attributeTypeId '{}', numericValue '{}', charValue '{}'.", requestId, missionId, attributeTypeId, numericValue, charValue);
			*session << "INSERT INTO mission_attribute(mission_id, attribute_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(attributeTypeId),
				Poco::Data::Keywords::use(numericValue),
				Poco::Data::Keywords::use(charValue),
				Poco::Data::Keywords::now;
			//respond(output, requestId, ResponseType::ok, "\"\"");
		}
		else if (type == "me" && realParamsSize == 5) { // mission_event
			uint32_t missionId = parseUnsigned(parameters[1]);
			double gameTime = parseFloat(parameters[2]);
			uint32_t eventTypeId = parseUnsigned(parameters[3]);
			Poco::Nullable<double> numericValue = getNumericValue(parameters, 4);
			Poco::Nullable<std::string> charValue = getCharValue(parameters, 5);
			logger->debug("[{}] Inserting into 'mission_event' values missionId '{}', gameTime '{}', eventTypeId '{}', numericValue '{}', charValue '{}'.", requestId, missionId, gameTime, eventTypeId, numericValue, charValue);
			*session << "INSERT INTO mission_event(mission_id, gameTime, event_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(gameTime),
				Poco::Data::Keywords::use(eventTypeId),
				Poco::Data::Keywords::use(numericValue),
				Poco::Data::Keywords::use(charValue),
				Poco::Data::Keywords::now;
			//respond(output, requestId, ResponseType::ok, "\"\"");
		}
		else if (type == "en" && realParamsSize == 2) { // entity
			uint32_t missionId = parseUnsigned(parameters[1]);
			double gameTime = parseFloat(parameters[2]);
			logger->debug("[{}] Inserting into 'entity' values missionId '{}', gameTime '{}'.", requestId, missionId, gameTime);
			*session << "INSERT INTO entity(mission_id, gameTime) VALUES(?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(gameTime),
				Poco::Data::Keywords::now;
			uint64_t id = 0;
			*session << "SELECT LAST_INSERT_ID()",
				Poco::Data::Keywords::into(id),
				Poco::Data::Keywords::now;
			logger->debug("[{}] New entity is '{}'.", requestId, id);
			//respond(output, requestId, ResponseType::ok, std::to_string(id));
		}
		else if (type == "ea" && realParamsSize == 5) { // entity_attribute
			uint32_t missionId = parseUnsigned(parameters[1]);
			uint64_t entityId = parseUnsigned(parameters[2]);
			uint32_t attributeTypeId = parseUnsigned(parameters[3]);
			Poco::Nullable<double> numericValue = getNumericValue(parameters, 4);
			Poco::Nullable<std::string> charValue = getCharValue(parameters, 5);
			logger->debug("[{}] Inserting into 'entity_attribute' values missionId '{}', entity_id '{}', attributeTypeId '{}', numericValue '{}', charValue '{}'.", requestId, missionId, entityId, attributeTypeId, numericValue, charValue);
			*session << "INSERT INTO entity_attribute(mission_id, entity_id, attribute_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(entityId),
				Poco::Data::Keywords::use(attributeTypeId),
				Poco::Data::Keywords::use(numericValue),
				Poco::Data::Keywords::use(charValue),
				Poco::Data::Keywords::now;
			//respond(output, requestId, ResponseType::ok, "\"\"");
		}
		else if (type == "ee" && realParamsSize == 6) { // entity_event
			uint32_t missionId = parseUnsigned(parameters[1]);
			uint64_t entityId = parseUnsigned(parameters[2]);
			double gameTime = parseFloat(parameters[3]);
			uint32_t eventTypeId = parseUnsigned(parameters[4]);
			Poco::Nullable<double> numericValue = getNumericValue(parameters, 5);
			Poco::Nullable<std::string> charValue = getCharValue(parameters, 6);
			logger->debug("[{}] Inserting into 'entity_event' values missionId '{}', entityId '{}', gameTime '{}', eventTypeId '{}', numericValue '{}', charValue '{}'.", requestId, missionId, entityId, gameTime, eventTypeId, numericValue, charValue);
			*session << "INSERT INTO entity_event(mission_id, entity_id, gameTime, event_type_id, numeric_value, char_value) VALUES(?, ?, ?, ?, ?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(entityId),
				Poco::Data::Keywords::use(gameTime),
				Poco::Data::Keywords::use(eventTypeId),
				Poco::Data::Keywords::use(numericValue),
				Poco::Data::Keywords::use(charValue),
				Poco::Data::Keywords::now;
			//respond(output, requestId, ResponseType::ok, "\"\"");
		}
		else if (type == "ep" && realParamsSize == 7) { // entity_position
			uint32_t missionId = parseUnsigned(parameters[1]);
			uint64_t entityId = parseUnsigned(parameters[2]);
			double gameTime = parseFloat(parameters[3]);
			uint32_t positionTypeId = parseUnsigned(parameters[4]);
			double posX = parseFloat(parameters[5]);
			double posY = parseFloat(parameters[6]);
			double posZ = parseFloat(parameters[7]);
			logger->debug("[{}] Inserting into 'entity_position' values missionId '{}', entityId '{}', gameTime '{}', positionTypeId '{}', posX '{}', posY '{}, posZ '{}''.", requestId, missionId, entityId, gameTime, positionTypeId, posX, posY, posZ);
			*session << "INSERT INTO entity_position(mission_id, entity_id, gameTime, position_type_id, pos_x, pos_y, pos_z) VALUES(?, ?, ?, ?, ?, ?, ?)",
				Poco::Data::Keywords::use(missionId),
				Poco::Data::Keywords::use(entityId),
				Poco::Data::Keywords::use(gameTime),
				Poco::Data::Keywords::use(positionTypeId),
				Poco::Data::Keywords::use(posX),
				Poco::Data::Keywords::use(posY),
				Poco::Data::Keywords::use(posZ),
				Poco::Data::Keywords::now;
			//respond(output, requestId, ResponseType::ok, "\"\"");
		}
		else {
			logger->debug("[{}] Invlaid command type '{}'!", requestId, type);
			//respond(output, requestId, ResponseType::error, fmt::format("\"Invlaid command type '{}'!\"", type));
		}
	}
	catch (Poco::Data::MySQL::MySQLException& e) {
		logger->error("Error executing prepared statement! Error code: '{}', Error message: {}", e.code(), e.displayText());
		//respond(output, requestId, ResponseType::error, fmt::format("\"Error executing prepared statement!\""));
	}
}

} // namespace extension
} // namespace ark_stats