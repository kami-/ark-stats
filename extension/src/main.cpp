#include "Extension.h"

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace {
    ark_stats::extension::Extension *extension;
}

//#define ARK_STATS_CONSOLE
#ifndef ARK_STATS_CONSOLE

BOOL APIENTRY DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    switch (fdwReason) {
    case DLL_PROCESS_ATTACH:
        extension = new ark_stats::extension::Extension();
        break;

    case DLL_PROCESS_DETACH:
        delete extension;
        break;
    }
    return true;
}

extern "C" {
    __declspec(dllexport) void __stdcall RVExtension(char *output, int outputSize, const char *function);
};

void __stdcall RVExtension(char *output, int outputSize, const char *function) {
    outputSize -= 1;
	extension->call(output, outputSize, function);
};

#else

#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    std::string line = "";
    const int outputSize = 10000;
    char *output = new char[outputSize];
    extension = new ark_stats::extension::Extension();
	while (line != "exit") {
		std::getline(std::cin, line);
		extension->call(output, outputSize, line.c_str());
		std::cout << "ARK_STATS: " << output << std::endl;
	}
    delete extension;
    return 0;
}

#endif