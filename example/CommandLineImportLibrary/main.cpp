//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <exception>
#include <iostream>

#if defined(_M_X64) || defined(_M_AMD64)
#    define _AMD64_
#elif defined(_M_ARM)
#    define _ARM_
#elif defined(_M_ARM64)
#    define _ARM64_
#elif defined(_M_ARM64EC)
#    define _ARM64EC_
#elif defined(_M_IX86)
#    define _X86_
#else
#    error Unknown platform
#endif

#include <sdkddkver.h>
#include <winternl.h>

int main(int /*argc*/, char** /*argv*/)
{
    try
    {
        try
        {
            std::cout << "Found NtCreateFile: " << &NtCreateFile;
        }
        catch (const std::exception& ex)
        {
            std::cout << "Exception: " << ex.what();
        }
    }
    catch (...)
    {
    }
}
