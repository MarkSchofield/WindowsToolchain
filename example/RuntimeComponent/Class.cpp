#include "pch.h"
#include "Class.h"
#include "Class.g.cpp"

namespace winrt::RuntimeComponent::implementation
{
    int32_t Class::MyProperty()
    {
        return m_myProperty;
    }

    void Class::MyProperty(int32_t value)
    {
        m_myProperty = value;
    }
}
