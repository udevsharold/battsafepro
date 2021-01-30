#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#include <xpc/xpc.h>

@interface BSPPowerManager : NSObject
@property(nonatomic, strong) xpc_connection_t xpc_listener;
@property(nonatomic, strong) dispatch_queue_t queue;
+(id)sharedInstance;
-(void)updateChargingState:(BOOL)enableCharging;
-(void)updateSleepingState:(BOOL)sleep;
-(void)handleUpdateChargingStateMessage:(xpc_object_t)event;
-(void)handleUpdateSleepingStateMessage:(xpc_object_t)event;

//-(NSDictionary *)updateState:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
//-(void)updateDarkWake:(BOOL)preferDarkWake;
//-(void)releaseChargingAssertionIfHeld;
@end
