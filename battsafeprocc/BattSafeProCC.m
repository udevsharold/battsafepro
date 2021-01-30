#import "../common.h"
#import "BattSafeProCC.h"

@implementation BattSafeProCC
static BOOL shouldSetValue = YES;

- (instancetype)init{
    if ((self = [super init])) {
        [self updateStateViaPreferences];
    }
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)TWEAK_IDENTIFIER;
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, appID);
    CFPreferencesAppSynchronize(appID);
}

-(void)updateStateViaPreferences{
    shouldSetValue = NO;
    _selected = [self getValueForKey:@"enabled"] ? [[self getValueForKey:@"enabled"] boolValue] : YES;
    HBLogDebug(@"_selected: %d", _selected?1:0);
    [self setSelected:_selected];
    shouldSetValue = YES;
}


-(id)getValueForKey:(NSString *)key{
    CFStringRef appID = (__bridge CFStringRef)TWEAK_IDENTIFIER;
    CFPreferencesAppSynchronize(appID);
    
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList != NULL){
        BOOL containsKey = CFArrayContainsValue(keyList, CFRangeMake(0, CFArrayGetCount(keyList)), (__bridge CFStringRef)key);
        CFRelease(keyList);
        if (!containsKey) return nil;
        
        
        return CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, appID));
    }
    return nil;
}

//Return the icon of your module here
- (UIImage *)iconGlyph{
    return [UIImage imageNamed:@"BattSafe" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

//Return the color selection color of your module here
- (UIColor *)selectedColor{
    return [UIColor blueColor];
}

- (BOOL)isSelected{
    return _selected;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    
    [super refreshState];
    if (!shouldSetValue) return;
    
    [self setValue:@(selected) forKey:@"enabled"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)PREFS_CHANGED_NOTIFICATION_NAME, NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)RELOAD_SPECIFIERS_NOTIFICATION_NAME, NULL, NULL, YES);
    
}

@end

static void refreshModule(){
    CCUIModuleInstance* battSafeModule = [[NSClassFromString(@"CCUIModuleInstanceManager") sharedInstance] instanceForModuleIdentifier:@"com.udevs.battsafeprocc"];
    [(BattSafeProCC*)battSafeModule.module updateStateViaPreferences];
}

__attribute__((constructor))
static void init(void){
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshModule, (CFStringRef)REFRESH_MODULE_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
}
