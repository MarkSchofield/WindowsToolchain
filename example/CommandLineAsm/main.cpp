//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <exception>
#include <iostream>

extern "C"
{
    int CallAsmCode();
}

int main(int /*argc*/, char** /*argv*/)
{
    try
    {
        try
        {
            std::cout << "Value from asm: " << CallAsmCode();
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
