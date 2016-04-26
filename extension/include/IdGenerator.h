#ifndef ARK_STATS_EXTENSION_ID_GENERATOR_H
#define ARK_STATS_EXTENSION_ID_GENERATOR_H

#include <atomic>

namespace ark_stats {

class IdGenerator {
public:
    IdGenerator(): id(seed) {};
    ~IdGenerator() {};
    uint32_t next() { return ++id; };
private:
    const uint32_t seed = 1000;
    std::atomic<uint32_t> id;
};

} // namespace ark_stats

#endif // ARK_STATS_EXTENSION_ID_GENERATOR_H