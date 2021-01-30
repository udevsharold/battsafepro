#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <HBLog.h>

#define TWEAK_IDENTIFIER @"com.udevs.battsafepro"
#define PREFS_CHANGED_NOTIFICATION_NAME @"com.udevs.battsafepro.prefschanged"

#define RELOAD_SPECIFIERS_NOTIFICATION_NAME @"com.udevs.battsafepro.reloadspecifiers"
#define RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME @"com.udevs.battsafepro.reloadspecifiers.local"
#define REFRESH_MODULE_NOTIFICATION_NAME @"com.udevs.battsafepro.refreshmodule"

#define BSPPREFSMANAGER_CENTER_IDENTIFIER @"com.udevs.battsafepro.center.sb"
#define NOTIFICATIONDISPATCHER_CENTER_IDENTIFIER @"com.udevs.battsafepro.center.notificationdispatcher"

#define POWERMONITOR_BYPASS_CHARGING_STATE_NOTIFICATION_NAME @"com.udevs.battsafepro-powermonitor-bypassState"
#define POWERMONITOR_PRERMING_NOTIFICATION_NAME @"com.udevs.battsafepro-powermonitor-prerming"

#define POWERD_XPC_NAME "com.apple.iokit.powerdxpc"
#define POWERD_XPC_BATTSAFEPRO_QUEUE_NAME "com.udevs.battsafepro.queue"

#define defaultMaxChargingLevel 80
#define defaultSensitivityLevel 4
#define defaultPreventSleepingTimeout 900 //15 minutes
#define defaultGracingDOD 5

#define bundlePath @"/Library/PreferenceBundles/BattSafeProPrefs.bundle"
#define LOCALIZEDF(str, ...) [NSString stringWithFormat:[tweakBundle localizedStringForKey:str value:@"" table:nil], ##__VA_ARGS__]
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]
