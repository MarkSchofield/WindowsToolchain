//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
import std.core;

int main(int /*argc*/, char** /*argv*/)
{
    try
    {
        try
        {
            std::cout << "Hello, World!";
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
