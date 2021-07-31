#import "BSPActivator.h"
#import "common.h"
#import "Tweak+Debug.h"
#import "NSTask.h"
#import "SpringBoard-Private.h"
#import <dlfcn.h>
#import <objc/runtime.h>

//extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);


@implementation BSPActivator
+(void)load{
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    
    if (args.count != 0) {
        NSString *executablePath = args[0];
        
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            if ([processName isEqualToString:@"SpringBoard"]){
                dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
                if (objc_getClass("LAActivator")) {
                    [self sharedInstance];
                }
            }
        }
    }
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
    if ((self = [super init]))
    {
        self.iconScale = 10;
        [self registerListeners];
    }
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)TWEAK_IDENTIFIER;
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, appID);
    CFPreferencesAppSynchronize(appID);
}

-(void)registerListeners{
    LAActivator *la = [objc_getClass("LAActivator") sharedInstance];
    [la registerListener:self forName:@"battsafepro.enable"];
    [la registerListener:self forName:@"battsafepro.disable"];
    [la registerListener:self forName:@"battsafepro.chargenow"];
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"BattSafePro";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    if ([listenerName isEqualToString:@"battsafepro.enable"]){
        return @"Enable";
    }else if ([listenerName isEqualToString:@"battsafepro.disable"]){
        return @"Disable";
    }else if ([listenerName isEqualToString:@"battsafepro.chargenow"]){
        return @"Charge Now";
    }
    return @"";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    if ([listenerName isEqualToString:@"battsafepro.enable"]){
        return @"Enable BattSafePro";
    }else if ([listenerName isEqualToString:@"battsafepro.disable"]){
        return @"Disable BattSafePro";
    }else if ([listenerName isEqualToString:@"battsafepro.chargenow"]){
        return @"Continue charging to full";
    }
    return @"";
}

-(UIImage *)makeRoundedImage:(UIImage *)image radius:(float)radius scale:(float)scale{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, scale*self.iconScale,scale*self.iconScale);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    //UIGraphicsBeginImageContext(image.size);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scale*self.iconScale,scale*self.iconScale), NO, scale);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

-(NSString *)battSafeProIconPath{
    return @"/Library/PreferenceBundles/BattSafeProPrefs.bundle/BattSafePro@3x.png";
}

- (NSData *)activator:(LAActivator *)activator requiresIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale{
    NSString *iconPath = [self battSafeProIconPath];
    UIImage *icon = [[UIImage alloc] init];
    NSData *iconData = [[NSData alloc] init];
    
    if (*scale == 3.0f){
        icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath] scale:3.0f];
    }else if (*scale == 2.0f){
        icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath] scale:2.0f];
    }else{
        icon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath] scale:1.0f];
    }
    
    icon = [self makeRoundedImage:icon radius:6 scale:*scale];
    
    iconData = [NSData dataWithData:UIImagePNGRepresentation(icon)];
    
    return iconData;
}

- (NSData *)activator:(LAActivator *)activator requiresSmallIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale{
    
    return [self activator:activator requiresIconDataForListenerName:listenerName scale:scale];
}

-(void)postPrefsChangedNotification{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)PREFS_CHANGED_NOTIFICATION_NAME, NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)REFRESH_MODULE_NOTIFICATION_NAME, NULL, NULL, YES);
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
    HBLogDebug(@"listenerName: %@", listenerName);
    if ([listenerName isEqualToString:@"battsafepro.enable"]){
        [self setValue:@YES forKey:@"enabled"];
        [self postPrefsChangedNotification];
    }else if ([listenerName isEqualToString:@"battsafepro.disable"]){
        [self setValue:@NO forKey:@"enabled"];
        [self postPrefsChangedNotification];
    }else if ([listenerName isEqualToString:@"battsafepro.chargenow"]){
        //CFDictionaryRef userInfo = (__bridge CFDictionaryRef)@{@"bypass":@YES};
        //CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.udevs.battsafepro.power.monitor"), NULL, userInfo, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)POWERMONITOR_BYPASS_CHARGING_STATE_NOTIFICATION_NAME, NULL, NULL, YES);
    }
}
@end
