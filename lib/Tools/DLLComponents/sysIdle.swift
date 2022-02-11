func sysIdleTime(){
    lastEvent = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState, eventType: kCGAnyInputEventType)

    print(lastEvent)
}