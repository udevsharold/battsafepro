#import "../common.h"
#import "BSPPowerManager.h"
#include <notify.h>
#import "../BattSafe-Private.h"
#import "../SpringBoard-Private.h"

#define kIOPMAssertionTypeInhibitCharging       CFSTR("ChargeInhibit")
#define kIOPMChargeInhibitAssertion             kIOPMAssertionTypeInhibitCharging

static IOPMAssertionID chargingAssertionID;
static IOPMAssertionID sleepingAssertionID;
static IOReturn chargingAssertionSuccess = KERN_FAILURE;

@implementation BSPPowerManager

+(void)load{
    [self sharedInstance];
    
}

+(id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(instancetype)init{
    if ((self = [super init])){
    }
    return self;
}

-(void)replyWithBoolResult:(BOOL)value event:(xpc_object_t)event{
    xpc_connection_t remote = NULL;
    remote = xpc_dictionary_get_remote_connection(event);
    xpc_object_t reply = xpc_dictionary_create_reply(event);
    xpc_dictionary_set_bool(reply, "result", value);
    xpc_connection_send_message(remote, reply);
}

-(void)handleUpdateChargingStateMessage:(xpc_object_t)event{
    [self updateChargingState:xpc_dictionary_get_bool(event, "BATTSAFEPRO_updateChargingState")];
    [self replyWithBoolResult:YES event:event];
}

-(void)handleUpdateSleepingStateMessage:(xpc_object_t)event{
    [self updateSleepingState:xpc_dictionary_get_bool(event, "BATTSAFEPRO_updateSleepingState")];
    [self replyWithBoolResult:YES event:event];
}

-(BOOL)isChargingProhibited{
    CFDictionaryRef assertionStates;
    IOReturn status = IOPMCopyAssertionsStatus(&assertionStates);
    if (status == kIOReturnSuccess){
        CFBooleanRef chargingProhibited = (CFBooleanRef)CFDictionaryGetValue(assertionStates, CFSTR("ChargeInhibit"));
        CFBridgingRelease(assertionStates);
        return CFBooleanGetValue(chargingProhibited);
    }
    return NO;
}

-(void)enableCharging{
    if (chargingAssertionSuccess == kIOReturnSuccess && [self isChargingProhibited]){ //Created assertion, should just directly release
        IOPMAssertionRelease(chargingAssertionID);
    }else{ //Assertion not created, to fix device not charging bug, create and release again
        chargingAssertionSuccess = IOPMAssertionCreateWithName(kIOPMChargeInhibitAssertion, kIOPMAssertionLevelOn, kIOPMAssertionTypeInhibitCharging, &chargingAssertionID);
        IOPMAssertionRelease(chargingAssertionID);
    }
    chargingAssertionSuccess = KERN_FAILURE;
    //HBL(@"Starts charging");
}

-(void)disableCharging{
    IOPMAssertionRelease(chargingAssertionID);
    chargingAssertionSuccess = IOPMAssertionCreateWithName(kIOPMChargeInhibitAssertion, kIOPMAssertionLevelOn, kIOPMAssertionTypeInhibitCharging, &chargingAssertionID);
    //HBL(@"Stops charging");
}

-(void)updateChargingState:(BOOL)enableCharging{
    if (enableCharging){
        [self enableCharging];
    }else{
        [self disableCharging];
    }
}
/*
 -(void)logAssertionByProcess{
 CFDictionaryRef assertionStates;
 IOReturn status = IOPMCopyAssertionsByProcess(&assertionStates);
 if (status == kIOReturnSuccess){
 NSDictionary* dict = (__bridge_transfer NSDictionary*)assertionStates;
 for (id key in dict) {
 HBLogDebug(@"key: %@, value: %@ \n", key, [dict objectForKey:key]);
 }
 CFRelease(assertionStates);
 }
 }
 */

-(void)disableSleep{
    IOPMAssertionRelease(sleepingAssertionID);
    IOPMAssertionCreateWithName(kIOPMAssertionTypeNoIdleSleep, kIOPMAssertionLevelOn, CFSTR("Standing by for BattSafe"), &sleepingAssertionID);
    
    int timeoutSeconds = defaultPreventSleepingTimeout;
    CFNumberRef cfTimeoutSeconds = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &timeoutSeconds);
    IOPMAssertionSetProperty(sleepingAssertionID, kIOPMAssertionTimeoutKey, cfTimeoutSeconds);
    //[self logAssertionByProcess];
    HBLogDebug(@"Sleeping disabled");
}

-(void)enableSleep{
    IOPMAssertionRelease(sleepingAssertionID);
    //[self logAssertionByProcess];
    HBLogDebug(@"Sleeping enabled");
    
}

-(void)updateSleepingState:(BOOL)sleep{
    if (sleep){
        [self enableSleep];
    }else{
        [self disableSleep];
    }
}
@end
