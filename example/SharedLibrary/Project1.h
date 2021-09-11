//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#pragma once

#if defined(PROJECT1_EXPORTS)
#    define PROJECT1_API __declspec(dllexport)
#else
#    define PROJECT1_API __declspec(dllimport)
#endif

class PROJECT1_API CProject1
{
public:
    CProject1();
};

extern PROJECT1_API int nProject1;

PROJECT1_API int fnProject1();
