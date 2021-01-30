#import "common.h"
#import "BattSafePro.h"
#import "BSPPowerMonitor.h"
#import "BattSafe-Private.h"
#import "SpringBoard-Private.h"
#import "Tweak+Debug.h"

static NSBundle *tweakBundle;

static void bypassStateCallBack(){
     BSPPowerMonitor *monitor = [%c(BSPPowerMonitor) sharedInstance];
    [monitor bypassState];
}

static void prermingCallback(){
     BSPPowerMonitor *monitor = [%c(BSPPowerMonitor) sharedInstance];
    [monitor prerming];
}

@implementation BSPPowerMonitor

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

        [self createPowerdXPCConnection];
        self.prefsManagerClient = [[%c(BSPPrefsManagerClient) alloc] initWithIdentifier:TWEAK_IDENTIFIER];
        [self reloadPrefs];
        tweakBundle = [NSBundle bundleWithPath:bundlePath];
        [tweakBundle load];
        
        _ndMessagingCenter = [CPDistributedMessagingCenter centerNamed:NOTIFICATIONDISPATCHER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_ndMessagingCenter);
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)bypassStateCallBack, (CFStringRef)POWERMONITOR_BYPASS_CHARGING_STATE_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prermingCallback, (CFStringRef)POWERMONITOR_PRERMING_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

-(void)_execute:(dispatch_block_t)block{
    dispatch_async(dispatch_get_main_queue(), block);
    HBL(@"Block executed");
}

-(void)execute:(PCPersistentTimer *)timer{
    if ([timer userInfo][@"block"]){
        [self _execute:[timer userInfo][@"block"]];
    }
}

-(void)wakeAndExecute:(dispatch_block_t)block delay:(double)delay{
    HBL(@"Waking up and executing in %f seconds", delay);
    PCPersistentTimer *timer = [[%c(PCPersistentTimer) alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:delay] serviceIdentifier:TWEAK_IDENTIFIER target:self selector:@selector(execute:) userInfo:block?@{@"block":block}:nil];
    [timer setMinimumEarlyFireProportion:1];
    if ([NSThread isMainThread]) {
        [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
        });
    }
}

-(BOOL)notifyAtLevel:(double)level{
    HBL(@"Will notify at level: %f", level);
    
    NSDictionary *ret = [_ndMessagingCenter sendMessageAndReceiveReplyName:@"dispatchRequest" userInfo:@{@"level":@(level)}];
    return [ret[@"result"] boolValue];
}

-(BOOL)recallNotification{
    NSDictionary *ret = [_ndMessagingCenter sendMessageAndReceiveReplyName:@"recallRequest" userInfo:nil];
    return [ret[@"result"] boolValue];
    self.notificationDelivered = NO;
    HBL(@"Recalled notification");
}

-(void)destroyState{
    [self notifyChargingState:NO];
    [self notifyChargingState:YES];
}

-(void)resetState{
    //[self notifyChargingState:NO];
    [self notifyChargingState:YES];
    HBL(@"resetState");
}

-(void)bypassState{
    self.fullChargeBypass = YES;
    [self resetState];
    HBL(@"Bypassed BattSafe");
}

-(void)createPowerdXPCConnection{
    self.powerd_xpc_connection =
    xpc_connection_create_mach_service(POWERD_XPC_NAME, NULL, 0);
    xpc_connection_set_event_handler(self.powerd_xpc_connection, ^(xpc_object_t event) {
        // Same semantics as a connection created through
        // xpc_connection_create().
    });
    xpc_connection_resume(self.powerd_xpc_connection);
}

-(BOOL)sendMessageWithBoolReplyPowerdXPC:(xpc_object_t)message{
    BOOL ret = NO;
    if (self.powerd_xpc_connection){
        xpc_object_t reply = xpc_connection_send_message_with_reply_sync(self.powerd_xpc_connection, message);
        if (xpc_get_type(reply) == XPC_TYPE_DICTIONARY){
            ret = xpc_dictionary_get_bool(reply, "result");
        }
        //xpc_release(reply);
    }
    return ret;
}

-(void)notifySleepingState:(BOOL)sleep{
    HBL(@"Will notify to %@", sleep?@"be able to sleep again":@"standy system");
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_bool(message, "BATTSAFEPRO_updateSleepingState", sleep);
    [self sendMessageWithBoolReplyPowerdXPC:message];
}

-(void)notifyChargingState:(BOOL)enableCharging{
    HBL(@"Will notify %@ charging", enableCharging?@"start":@"stop");
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_bool(message, "BATTSAFEPRO_updateChargingState", enableCharging);
    BOOL replyReceived = [self sendMessageWithBoolReplyPowerdXPC:message];
    
    [self.prefsManagerClient setValue:(replyReceived?@(!enableCharging):@NO) forKey:@"isInEffect"];
}

-(BOOL)isExternalConnected{
    return [[self batteryInfo][@"ExternalConnected"] boolValue];
}

-(int)currentBatteryLevel{
    return [[self batteryInfo][@"CurrentCapacity"] intValue];
}

-(BOOL)isCurrentlyCharging{
    return [[self batteryInfo][@"IsCharging"] boolValue];
}

-(NSDictionary *)batteryInfo{
    CFDictionaryRef matching = IOServiceMatching("IOPMPowerSource");
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    CFMutableDictionaryRef prop = NULL;
    IORegistryEntryCreateCFProperties(service, &prop, NULL, 0);
    NSDictionary* dict = (__bridge_transfer NSDictionary*)prop;
    IOObjectRelease(service);
    return dict;
}

-(void)levelChanged:(double)level{
    
    //HBL(@"chargingAssertionHeld: %d", [self chargingAssertionHeld]?1:0);
    if (self.enabled && !self.isPrerming){
        BOOL isCurrentlyExternalConnected = [self isExternalConnected];
        BOOL isCurrentlyCharging = [self isCurrentlyCharging];
        
        if (isCurrentlyExternalConnected && !self.fullChargeBypass){
            HBL(@"Handle Level changed to %f, external: %d, charging: %d", level, isCurrentlyExternalConnected?1:0, isCurrentlyCharging?1:0);
            
            if (self.lastBatteryLevel != level){
                self.lastBatteryLevel = level;
                
                
                if (!self.systemStandbyed && (self.maxChargingLevel - level <= defaultSensitivityLevel) && (self.maxChargingLevel - level > 0) && !self.refreshing ){
                    [self wakeAndExecute:^{
                        [self notifySleepingState:NO];
                    } delay:1];
                    self.systemStandbyed = YES;
                }
                
                
                if (level >= self.maxChargingLevel){
                    //stop charging
                    if (self.showNotification && !self.notificationDelivered){
                        [self notifyAtLevel:level];
                        self.notificationDelivered = YES;
                    }
                    dispatch_block_t block = dispatch_block_create(static_cast<dispatch_block_flags_t>(0), ^{
                        [self notifyChargingState:NO];
                        self.disableChargingBlock = nil;
                        HBL(@"Stopped charging at %f", level);
                    });
                    
                    if (level >= self.lastBatteryLevel){
                        if (!self.disableChargingBlock) {
                            self.disableChargingBlock = block;
                            [self wakeAndExecute:self.disableChargingBlock delay:1];
                        }
                    }else{
                        [self _execute:block];
                    }
                    
                    
                    //if (self.systemStandbyed){
                    [self wakeAndExecute:^{
                        [self notifySleepingState:YES];
                    } delay:1];
                    
                    self.systemStandbyed = NO;
                    //}
                    /*
                     if (self.gracingEnabled){
                     self.gracingActive = YES;
                     }
                     */
                    
                }else{
                    //start charging
                    if (self.notificationDelivered){
                        [self recallNotification];
                        self.notificationDelivered = NO;
                    }
                    
                    /*
                     BOOL gracingInEffect = self.gracingEnabled && self.gracingActive && (level > (self.maxChargingLevel - self.gracingDepth));
                     HBL(@"gracingInEffect: %d", gracingInEffect?1:0);
                     */
                    
                    if (!isCurrentlyCharging /*&& !gracingInEffect*/) {
                        HBL(@"******* begin charging");
                        if (!self.enableChargingBlock){
                            self.enableChargingBlock = dispatch_block_create(static_cast<dispatch_block_flags_t>(0), ^{
                                [self resetState];
                                self.enableChargingBlock = nil;
                                HBL(@"Charging at %f", level);
                            });
                            
                            [self wakeAndExecute:self.enableChargingBlock delay:1];
                        }
                    }/*else{
                      HBL(@"******* NOT charging");
                      }
                      */
                    
                }
            }
        }else{
            if (self.notificationDelivered) [self recallNotification];
            if (isCurrentlyExternalConnected && !isCurrentlyCharging && !self.fullChargeBypass) [self resetState];
            self.notificationDelivered = NO;
            
            self.enableChargingBlock = nil;
            self.disableChargingBlock = nil;
            self.lastBatteryLevel = -2;
        }
        
        //external disconnected
        if (!isCurrentlyExternalConnected && (self.lastExternalConnectedState != isCurrentlyExternalConnected)){
            self.fullChargeBypass = NO;
            if (!self.fullChargeBypass) [self resetState];
            
            
            //if (self.systemStandbyed){
            //[self wakeAndExecute:^{
            [self notifySleepingState:YES];
            //} delay:1];
            self.systemStandbyed = NO;
            //}
            
            
            //if (!self.refreshing) [self notifyReleaseChargingAssertionIfHeld];
            //HBL(@"External disconnected");
        }
        self.lastExternalConnectedState = isCurrentlyExternalConnected ? 1 : 0;
    }
}

-(void)reloadPrefs{
    self.enabled = [self.prefsManagerClient valueForKey:@"enabled"] ? [[self.prefsManagerClient valueForKey:@"enabled"] boolValue] : YES;
    self.showNotification = [self.prefsManagerClient valueForKey:@"showNotification"] ? [[self.prefsManagerClient valueForKey:@"showNotification"] boolValue] : YES;
    
    double tempMaxChargeLevel = self.maxChargingLevel;
    self.maxChargingLevel = [self.prefsManagerClient valueForKey:@"maxChargingLevel"] ? [[self.prefsManagerClient valueForKey:@"maxChargingLevel"] doubleValue] : defaultMaxChargingLevel;
    self.maxChargingLevel = self.maxChargingLevel > 100 ? 100 : self.maxChargingLevel;
    self.maxChargingLevel = self.maxChargingLevel < 0 ? 0 : self.maxChargingLevel;
    self.maxChargingLevel = !self.maxChargingLevel ? defaultMaxChargingLevel : self.maxChargingLevel;
    
    /*
     self.gracingEnabled = [self.prefsManagerClient valueForKey:@"gracingEnabled"] ? [[self.prefsManagerClient valueForKey:@"gracingEnabled"] boolValue] : YES;
     self.gracingDepth = [self.prefsManagerClient valueForKey:@"gracingDOD"] ? [[self.prefsManagerClient valueForKey:@"gracingDOD"] doubleValue] : defaultGracingDOD;
     self.gracingDepth = self.gracingDepth > 100 ? 100 : self.gracingDepth;
     self.gracingDepth = self.gracingDepth < 0 ? 0 : self.gracingDepth;
     self.gracingDepth = !self.gracingDepth ? defaultGracingDOD : self.gracingDepth;
     */
    
    if (!self.enabled){
        [self resetState];
        [self notifySleepingState:YES];
    }
    
    if (self.notificationDelivered && (!self.showNotification || !self.enabled || (self.maxChargingLevel != tempMaxChargeLevel))) [self recallNotification];
    
    self.notificationDelivered = NO;
    self.lastBatteryLevel = -2;
    self.systemStandbyed = NO;
    self.requestedPeriodicCheck = NO;
    self.enableChargingBlock = nil;
    self.disableChargingBlock = nil;
    self.fullChargeBypass = NO;
    self.lastExternalConnectedState = -1;
    self.isPrerming = NO;
    //self.gracingActive = NO;
    [self levelChanged:[self currentBatteryLevel]];
    
    HBL(@"maxChargingLevel: %f", self.maxChargingLevel);
}

-(void)refreshMonitor{
    self.refreshing = YES;
    [self reloadPrefs];
    //[self levelChanged:[self currentBatteryLevel]];
    self.refreshing = NO;
}

-(void)prerming{
    HBL(@"prerming");
    self.isPrerming = YES;
    [self resetState];
    [self notifySleepingState:YES];
}

/*
 -(void)debugWithLevel:(double)level{
 [self levelChanged:level];
 }
 */
@end
