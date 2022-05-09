#pragma once

#include "Class.g.h"

namespace winrt::RuntimeComponent::implementation
{
    struct Class : ClassT<Class>
    {
        Class() = default;

        int32_t MyProperty();
        void MyProperty(int32_t value);

        int32_t m_myProperty = 0;
    };
}

namespace winrt::RuntimeComponent::factory_implementation
{
    struct Class : ClassT<Class, implementation::Class>
    {
    };
}
