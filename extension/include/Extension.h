#ifndef ARK_STATS_EXTENSION_EXTENSION_H
#define ARK_STATS_EXTENSION_EXTENSION_H

#include <string>

#include "spdlog/spdlog.h"
#include "Poco/Data/Session.h"
#include "Poco/Data/MySQL/Connector.h"

#include "IdGenerator.h"

#define ARK_STATS_EXTENSION_VERSION      "0.1.0"

namespace ark_stats {
namespace extension {

enum ResponseType {
	ok = 0,
	error = 1,
};

class Extension {
public:
    Extension();
    ~Extension();
    void call(char *output, int outputSize, const char *function);
private:
    const uint32_t POISON_ID = 0;
	const uint32_t ERROR_ID = 1;
	const std::string SQF_DELIMITER = ":";
	const std::string CONFIG_FILE_NAME = "config.txt";

	std::shared_ptr<spdlog::logger> logger;
	Poco::Data::Session* session;
	IdGenerator idGenerator;
	bool isConnected;

	void connect(const std::string& host, const std::string& port, const std::string& user, const std::string& password, const std::string& database);
	void disconnect();

	spdlog::level::level_enum getLogLevel(const std::string& logLevelStr) const;
	std::string getExtensionFolder() const;
	std::string getLogFileName() const;
	std::vector<std::string>& split(const std::string &s, const std::string& delim, std::vector<std::string>& elems) const;
	uint32_t parseUnsigned(const std::string& str) const;
	double parseFloat(const std::string& str) const;
	Poco::Nullable<double> getNumericValue(const std::vector<std::string>& parameters, const size_t& idx) const;
	Poco::Nullable<std::string> getCharValue(const std::vector<std::string>& parameters, const size_t& idx) const;
	void respond(char* output, const uint32_t& requestId, const ResponseType& type, const std::string& response) const;
};

} // namespace extension
} // namespace ark_stats

#endif // ARK_STATS_EXTENSION_EXTENSION_H