#include <windows.h>
#include "sysIdle.h"

int sysIdleTime()
{
    LASTINPUTINFO last_input;
    last_input.cbSize = sizeof(LASTINPUTINFO);
    GetLastInputInfo(&last_input);

    return (GetTickCount() - last_input.dwTime);
    
    
    
   
}


