#import "../common.h"
#import "BSPPowerManager.h"
#include <notify.h>
#import "../BattSafe-Private.h"
#import "../SpringBoard-Private.h"

#define kIOPMAssertionTypeInhibitCharging       CFSTR("ChargeInhibit")
#define kIOPMChargeInhibitAssertion             kIOPMAssertionTypeInhibitCharging

//extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

static IOPMAssertionID chargingAssertionID;
static IOPMAssertionID sleepingAssertionID;
static IOReturn chargingAssertionSuccess = KERN_FAILURE;

//static IOPMAssertionID darkWakeAssertionID;
//static int powerStateNotifyToken;
//static int powerManagementNotifyToken;
/*
 static void processManagerRequest(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
 //HBL(@"Received update charging request");
 NSDictionary *userInfo = (__bridge NSDictionary *)data;
 
 BSPPowerManager *manager = [%c(BSPPowerManager) sharedInstance];
 
 if (userInfo[@"updateChargingState"]){
 [manager updateChargingState:[userInfo[@"updateChargingState"] boolValue]];
 }
 if (userInfo[@"updateSleepingState"]){
 [manager updateSleepingState:[userInfo[@"updateSleepingState"] boolValue]];
 }
 /*
 if (userInfo[@"updateDarkWake"]){
 [manager updateDarkWake:[userInfo[@"updateDarkWake"] boolValue]];
 }
 */
/*
 if (userInfo[@"releaseAssertionIfHeld"] && [userInfo[@"releaseAssertionIfHeld"] boolValue]){
 [manager releaseChargingAssertionIfHeld];
 }
 *
 
 }
 */

/*
 static void updateState(BOOL enableCharging){
 [[%c(BSPPowerManager) sharedInstance] updateState:enableCharging];
 
 }
 */
/*
 static void handleReceivedXPCObject(xpc_object_t object) {
 NSDictionary *info = [NSDictionary dictionaryWithXPCObject:object];
 HBLogDebug(@"handleReceivedXPCObject: %@", info);
 }
 
 
 static void power_manager_peer_event_handler(xpc_connection_t peer, xpc_object_t event){
 xpc_type_t type = xpc_get_type(event);
 if (type == XPC_TYPE_ERROR) {
 if (event == XPC_ERROR_CONNECTION_INVALID) {
 // The client process on the other end of the connection has either
 // crashed or cancelled the connection. After receiving this error,
 // the connection is in an invalid state, and you do not need to
 // call xpc_connection_cancel(). Just tear down any associated state
 // here.
 } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
 // Handle per-connection termination cleanup.
 }
 } else {
 assert(type == XPC_TYPE_DICTIONARY);
 handleReceivedXPCObject(event);
 }
 }
 
 
 static void power_manager_event_handler(xpc_connection_t peer){
 // By defaults, new connections will target the default dispatch concurrent queue.
 xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
 power_manager_peer_event_handler(peer, event);
 });
 
 // This will tell the connection to begin listening for events. If you
 // have some other initialization that must be done asynchronously, then
 // you can defer this call until after that initialization is done.
 xpc_connection_resume(peer);
 }
 */

/*
static void updateChargingStateTrueCallback(){
    
}

static void updateChargingStateFalseCallback(){
    
}

static void updateSleepingStateTrueCallback(){
    
}

static void updateSleepingStateFalseCallback(){
    
}
*/

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
        //[self initXPCConnection];
        /*
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateChargingStateTrueCallback, (CFStringRef)POWERMANAGER_UPDATECHARGESTATE_YES_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateChargingStateFalseCallback, (CFStringRef)POWERMANAGER_UPDATECHARGESTATE_NO_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateSleepingStateTrueCallback, (CFStringRef)POWERMANAGER_UPDATESLEEPINGSTATE_YES_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, updateSleepingStateFalseCallback, (CFStringRef)POWERMANAGER_UPDATESLEEPINGSTATE_NO_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        */
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
    //xpc_release(reply);
}

-(void)handleUpdateSleepingStateMessage:(xpc_object_t)event{
    [self updateSleepingState:xpc_dictionary_get_bool(event, "BATTSAFEPRO_updateSleepingState")];
    [self replyWithBoolResult:YES event:event];
    //xpc_release(reply);
}

/*
-(void)initXPCConnection{
    self.queue = dispatch_queue_create(POWERD_XPC_BATTSAFEPRO_QUEUE_NAME, DISPATCH_QUEUE_CONCURRENT);
    self.xpc_listener = xpc_connection_create_mach_service(POWERD_XPC_NAME, self.queue, XPC_CONNECTION_MACH_SERVICE_LISTENER);
    xpc_connection_set_event_handler(self.xpc_listener, ^(xpc_object_t peer) {
        // Connection dispatch
        xpc_type_t peerType = xpc_get_type(peer);
        if (peerType != XPC_TYPE_ERROR){
            xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
                // Message dispatch
                if (xpc_get_type(event) == XPC_TYPE_DICTIONARY){
                    //Message handler
                    //xpc_dictionary_get_value(event, "battsafepro_updateChargingState");
                    if (xpc_dictionary_get_value(event, "BATTSAFEPRO_updateChargingState")){
                        [self handleUpdateChargingStateMessage:event];
                    }
                    if (xpc_dictionary_get_value(event, "BATTSAFEPRO_updateSleepingState")){
                        [self handleUpdateSleepingStateMessage:event];
                    }
                    
                }
            });
            xpc_connection_resume(peer);
        }else{
            HBLogDebug(@"ERROR: %s", xpc_dictionary_get_string(peer, XPC_ERROR_KEY_DESCRIPTION));
        }
    });
    xpc_connection_resume(self.xpc_listener);
}
*/

-(BOOL)isChargingProhibited{
    //BOOL ret - NO;
    CFDictionaryRef assertionStates;
    IOReturn status = IOPMCopyAssertionsStatus(&assertionStates);
    if (status == kIOReturnSuccess){
        //CFDictionaryRef assertionStates = IOPMAssertionCopyProperties(chargingAssertionID);
        //HBL(@"assertionStates: %@", assertionStates);
        //NSDictionary* dict = (__bridge_transfer NSDictionary*)assertionStates;
        //HBL(@"ChargeInhibit: %@", dict[@"ChargeInhibit"]);
        CFBooleanRef chargingProhibited = (CFBooleanRef)CFDictionaryGetValue(assertionStates, CFSTR("ChargeInhibit"));
        CFBridgingRelease(assertionStates);
        return CFBooleanGetValue(chargingProhibited);
    }
    return NO;
}

-(void)enableCharging{
    /*
     CFDictionaryRef assertionStates;
     IOReturn status = IOPMCopyAssertionsStatus(&assertionStates);
     if (status == kIOReturnSuccess){
     //CFDictionaryRef assertionStates = IOPMAssertionCopyProperties(chargingAssertionID);
     //HBL(@"assertionStates: %@", assertionStates);
     //NSDictionary* dict = (__bridge_transfer NSDictionary*)assertionStates;
     //HBL(@"ChargeInhibit: %@", dict[@"ChargeInhibit"]);
     }
     CFRelease(assertionStates);
     */
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
/*
 -(NSDictionary *)updateState:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
 [self updateState:[userInfo[@"enableCharging"] boolValue]];
 return @{};
 }
 */
/*
 -(void)preferDarkWakeState{
 #define kIOPMAssertionTypeDenySystemSleep                   CFSTR("DenySystemSleep")
 #define kIOPMAssertInternalPreventSleep                     CFSTR("InternalPreventSleep")
 #define kIOPMAssertionTypeDisableInflow                     CFSTR("DisableInflow")
 #define kIOPMInflowDisableAssertion                         kIOPMAssertionTypeDisableInflow
 #define kIOPMAssertionTypeEnableIdleSleep                   CFSTR("EnableIdleSleep")
 //Audio & Graphics will sleep
 //Disk, Network & CPU will not sleep
 IOPMAssertionRelease(darkWakeAssertionID);
 IOReturn status = IOPMAssertionCreateWithName(kIOPMAssertionTypeDenySystemSleep, kIOPMAssertionLevelOn, kIOPMAssertionTypeDenySystemSleep, &darkWakeAssertionID);
 if (status == kIOReturnSuccess){
 HBLogDebug(@"SUCCESS");
 }else{
 HBLogDebug(@"FAILED");
 }
 }
 
 -(void)releaseDarkWakeState{
 IOPMAssertionRelease(darkWakeAssertionID);
 }
 
 -(void)updateDarkWake:(BOOL)preferDarkWake{
 if (preferDarkWake){
 [self preferDarkWakeState];
 }else{
 [self releaseDarkWakeState];
 }
 }
 */

/*
 -(NSDictionary *)assertionInfo{
 CFDictionaryRef assertionStates;
 IOReturn status = IOPMCopyAssertionsStatus(&assertionStates);
 NSDictionary *info = nil;
 if (status == kIOReturnSuccess){
 info = [(__bridge_transfer NSDictionary*)assertionStates copy];
 }
 if (assertionStates != NULL){
 CFRelease(assertionStates);
 }
 return info;
 }
 
 -(BOOL)chargingAssertionHeld{
 return [[self assertionInfo][@"ChargeInhibit"] boolValue];
 }
 
 -(void)releaseChargingAssertionIfHeld{
 if ([self chargingAssertionHeld]) [self enableCharging];
 }
 */

@end
