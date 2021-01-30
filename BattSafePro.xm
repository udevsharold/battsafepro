#import "common.h"
#import "BattSafePro.h"
#import "BSPPowerMonitor.h"
#import "BSPPrefsManagerServer.h"
#import "BSPNotificationDispatcher.h"
#import "BattSafe-Private.h"
#import "Tweak+Debug.h"
#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <xpc/xpc.h>

//extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);


static BOOL isSpringBoard = NO;
static BOOL isSymptomsd = NO;

NCNotificationStructuredListViewController *notificationListViewController;

//static BOOL enabled = YES;
%group SPRINGBOARD_PROCESS
%hook NCNotificationStructuredListViewController
-(id)init{
    return notificationListViewController = %orig;
}
%end
%end



%group SYMPTOMSD_PROCESS
%hook PowerStateRelay
-(void)setBatteryPercentage:(double)level{
    %orig;
    [[%c(BSPPowerMonitor) sharedInstance] levelChanged:level];
}
%end
%end

static void reloadPrefs(){
    if (isSpringBoard){
        [%c(BSPPrefsManagerServer) sharedInstance];
        [%c(BSPNotificationDispatcher) sharedInstance];
        [[%c(BSPNotificationDispatcher) sharedInstance] reloadPrefs];
        //[dispatcher reloadPrefs];
        
    }
    if (isSymptomsd){
        BSPPowerMonitor *monitor = [%c(BSPPowerMonitor) sharedInstance];
        [monitor resetState];
        [monitor refreshMonitor];
    }
}

static void reloadNotification(){
    if (isSymptomsd){
        BSPPowerMonitor *monitor = [%c(BSPPowerMonitor) sharedInstance];
        [monitor refreshMonitor];
    }
}

/*
static void debugBattSafe(){
    BSPPowerMonitor *monitor = [%c(BSPPowerMonitor) sharedInstance];
    [monitor debugWithLevel:65];
}
*/

%ctor{
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                isSymptomsd = [processName isEqualToString:@"symptomsd"];
                
                if (isSymptomsd){
                    %init(SYMPTOMSD_PROCESS);
                    reloadPrefs();
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)PREFS_CHANGED_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadNotification, (CFStringRef)@"SBSpringBoardDidLaunchNotification", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)debugBattSafe, (CFStringRef)@"battsafe.debug", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

                    HBL(@"Injected into symptomsd");
                    rocketbootstrap_unlock("com.udevs.battsafepro.center.powermanager");

                }
                
                if (isSpringBoard){
                    %init(SPRINGBOARD_PROCESS);
                    reloadPrefs();
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)PREFS_CHANGED_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    HBL(@"Injected into SpringBoard");
                }
            }
        }
    }
}
