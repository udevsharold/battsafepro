#import "common.h"
#import "BSPPrefsManagerServer.h"

@implementation BSPPrefsManagerServer



+(instancetype)sharedInstance{
    static BSPPrefsManagerServer *sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init{
    if ((self = [super init])) {
        _messagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:BSPPREFSMANAGER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"readPrefs" target:self selector:@selector(readPrefs:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"writePrefs" target:self selector:@selector(writePrefs:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"setValue" target:self selector:@selector(setValue:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"removeKey" target:self selector:@selector(removeKey:withUserInfo:)];
        [_messagingCenter registerForMessageName:@"valueForKey" target:self selector:@selector(valueForKey:withUserInfo:)];
    }
    return self;
}

-(NSDictionary *)readPrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    return [self readPrefs:userInfo[@"identifier"]];
}

-(NSDictionary *)readPrefs:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesAppSynchronize(appID);
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!keyList){
        return @{};
    }
    NSDictionary *dictionary = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
    CFRelease(keyList);
    return dictionary;
}

-(NSDictionary *)writePrefs:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [self writePrefs:userInfo[@"prefs"] identifier:userInfo[@"identifier"]];
    return @{};
}

-(void)writePrefs:(NSDictionary *)dictionary identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesSetMultiple((__bridge CFDictionaryRef)dictionary, nil, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesAppSynchronize(appID);
}

-(NSDictionary *)setValue:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [self setValue:userInfo[@"value"]?:nil forKey:userInfo[@"key"] identifier:userInfo[@"identifier"]];
    return nil;
}

-(void)setValue:(id)value forKey:(NSString *)key  identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesSetAppValue((__bridge CFStringRef)key, value ? (__bridge CFPropertyListRef)value : NULL, appID);
    CFPreferencesAppSynchronize(appID);
}

-(NSDictionary *)removeKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    [self setValue:nil forKey:userInfo[@"key"] identifier:userInfo[@"identifier"]];
    return nil;
}

-(NSDictionary *)valueForKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    id val = [self valueForKey:userInfo[@"key"] identifier:userInfo[@"identifier"]];
    if (val == [NSNull null] || val == nil){
        return @{@"value":[NSNull null]};

    }
    return @{@"value":val};
}

-(id)valueForKey:(NSString *)key identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
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

-(void)postNotification:(NSString *)notificationName{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationName, NULL, NULL, YES);
}
@end
