//---------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Web.Syndication.h>
#include <winrt/RuntimeComponent.h>
#include <iostream>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Web::Syndication;

int main()
{
    winrt::init_apartment();

    RuntimeComponent::Class c;
    c.MyProperty(42);
    std::wcout << "c.MyProperty() = " << c.MyProperty() << std::endl;

    Uri rssFeedUri{ L"https://blogs.windows.com/feed" };
    SyndicationClient syndicationClient;
    SyndicationFeed syndicationFeed = syndicationClient.RetrieveFeedAsync(rssFeedUri).get();
    for (SyndicationItem syndicationItem : syndicationFeed.Items())
    {
        winrt::hstring titleAsHstring = syndicationItem.Title().Text();
        std::wcout << titleAsHstring.c_str() << std::endl;
    }
}
