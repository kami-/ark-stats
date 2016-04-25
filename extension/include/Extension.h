#ifndef ARK_STATS_EXTENSION_EXTENSION_H
#define ARK_STATS_EXTENSION_EXTENSION_H

#include <cstdint>
#include <string>
#include <vector>

#include "IdGenerator.h"
#include "spdlog/spdlog.h"
#include "Queue/Queue.h"
#include "Poco/Nullable.h"
#include "Poco/Data/Session.h"

#define ARK_STATS_EXTENSION_VERSION      "0.2.0"

namespace ark_stats {

enum ResponseType {
	ok = 0,
	error = 1,
};

struct Request {
	uint32_t id;
	std::string type;
	std::vector<std::string> params;
};

struct Response {
	uint32_t id;
	ResponseType type;
	std::string message;
};

class Extension {
public:
	void init();
	void call(char *output, int outputSize, const char *function);
	void cleanup();

private:
	const uint32_t POISON_ID = 0;
	const std::string SQF_DELIMITER = ":";
	const uint32_t SESSION_START_HOUR = 18;
	const uint32_t SESSION_END_HOUR = 6;

	Queue<Request> requests;
	std::shared_ptr<spdlog::logger> logger;
	Poco::Data::Session* session;
	std::thread dbThread;
	std::mutex sessionMutex;
	std::atomic<bool> hasError = false;
	IdGenerator idGenerator;
	bool isConnected = false;
	std::string host, port, user, password, database;

	void connect();
	void respond(char* output, const uint32_t& requestId, const ResponseType& type, const std::string& response);
	spdlog::level::level_enum getLogLevel(const std::string& logLevelStr);
	std::vector<std::string>& split(const std::string &s, const std::string& delim, std::vector<std::string> &elems);
	std::string getExtensionFolder();
	std::string getLogFileName();
	uint32_t parseUnsigned(const std::string& str);
	double parseFloat(const std::string& str);
	Poco::Nullable<double> getNumericValue(const std::vector<std::string>& parameters, const size_t& idx);
	Poco::Nullable<std::string> getCharValue(const std::vector<std::string>& parameters, const size_t& idx);
	void processRequests();
	Response processRequest(const Request& request);
};

} // namespace ark_stats

#endif // ARK_STATS_EXTENSION_EXTENSION_H