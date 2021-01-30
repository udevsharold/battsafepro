#import "common.h"
#import "BSPPrefsManager.h"
#import "Tweak+Debug.h"

@implementation BSPPrefsManager

-(instancetype)init{
    self = [super init];
    return self;
}

-(instancetype)initWithIdentifier:(NSString *)identifier{
    if ((self = [super init])){
        self.identifier = identifier;
    }
    return self;
}

-(NSDictionary *)readPrefs{
    if (!self.identifier) return @{};
    return [self readPrefs:self.identifier];
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

-(void)writePrefs:(NSDictionary *)dictionary{
    if (!self.identifier) return;
    [self writePrefs:dictionary identifier:self.identifier];
}

-(void)writePrefs:(NSDictionary *)dictionary identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesSetMultiple((__bridge CFDictionaryRef)dictionary, nil, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesAppSynchronize(appID);
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if (!self.identifier) return;
    [self setValue:value?:nil forKey:key identifier:self.identifier];
}

-(void)setValue:(id)value forKey:(NSString *)key  identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesSetAppValue((__bridge CFStringRef)key, value ? (__bridge CFPropertyListRef)value : NULL, appID);
    CFPreferencesAppSynchronize(appID);
}

-(void)removeKey:(NSString *)key{
    [self removeKey:key identifier:self.identifier];
}

-(void)removeKey:(NSString *)key identifier:(NSString *)identifier{
    [self setValue:nil forKey:key identifier:identifier];
}

-(id)valueForKey:(NSString *)key{
    if (!self.identifier) return nil;
    return [self valueForKey:key identifier:self.identifier];
}

-(id)valueForKey:(NSString *)key identifier:(NSString *)identifier{
    CFStringRef appID = (__bridge CFStringRef)identifier;
    CFPreferencesAppSynchronize(appID);
    return CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)key, appID));
}

-(void)postNotification:(NSString *)notificationName{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationName, NULL, NULL, YES);
}
@end
