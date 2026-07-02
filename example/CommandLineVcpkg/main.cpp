//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <iostream>
#include <sqlite3.h>

int main(int /*argc*/, char** /*argv*/)
{
    try
    {
        std::cout << "sqlite3 version: " << SQLITE_VERSION << "\n";
    }
    catch (const std::exception& ex)
    {
        std::cout << "Exception: " << ex.what() << "\n";
    }
}
