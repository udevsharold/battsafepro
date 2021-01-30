#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "BSPPrefsManagerClient.h"
#include <xpc/xpc.h>
#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

//#import "BSPPowerManagerClient.h"

@interface BSPPowerMonitor : NSObject{
    CPDistributedMessagingCenter * _ndMessagingCenter;
}
@property(nonatomic, assign) int powerManagementStatus;
@property(nonatomic, assign) BOOL fullChargeBypass;
@property(nonatomic, assign) BOOL showNotification;
@property(nonatomic, assign) BOOL notificationDelivered;
@property(nonatomic, assign) BOOL chargingNow;
@property(nonatomic, assign) double lastBatteryLevel ;
@property(nonatomic, assign) BOOL systemStandbyed;
@property(nonatomic, assign) BOOL requestedPeriodicCheck;
@property(nonatomic, strong) dispatch_block_t enableChargingBlock;
@property(nonatomic, strong) dispatch_block_t disableChargingBlock;
@property(nonatomic, assign) double maxChargingLevel;
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) int lastExternalConnectedState;
@property(nonatomic, assign) BOOL isPrerming;
@property(nonatomic, assign) BOOL refreshing;
//@property(nonatomic, assign) BOOL gracingEnabled;
//@property(nonatomic, assign) BOOL gracingActive;
//@property(nonatomic, assign) double gracingDepth;
@property(nonatomic, strong) BSPPrefsManagerClient *prefsManagerClient;
@property(nonatomic, strong) xpc_connection_t powerd_xpc_connection;

//-(void)debugWithLevel:(double)level;

+(id)sharedInstance;
-(void)reloadPrefs;
-(void)levelChanged:(double)level;
-(void)bypassState;
-(void)resetState;
-(void)refreshMonitor;
-(void)destroyState;
-(void)prerming;
@end
