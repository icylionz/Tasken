#include <ApplicationServices/ApplicationServices.h>
float sysIdleTime()
{       
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    return timeSinceLastEvent;
}