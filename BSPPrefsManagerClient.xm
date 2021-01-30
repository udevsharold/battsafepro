#import "common.h"
#import "BSPPrefsManagerClient.h"

@implementation BSPPrefsManagerClient

- (instancetype)init{
    if ((self = [super init])) {
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:BSPPREFSMANAGER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
    }
    return self;
}

-(instancetype)initWithIdentifier:(NSString *)identifier{
    if ((self = [super init])){
        self.identifier = identifier;
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:BSPPREFSMANAGER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
    }
    return self;
}

-(NSDictionary *)readPrefs{
    if (!self.identifier) return @{};
    return [self readPrefs:self.identifier];
}

-(NSDictionary *)readPrefs:(NSString *)identifier{
    return [_messagingCenter sendMessageAndReceiveReplyName:@"readPrefs" userInfo:@{@"identifier":identifier}];
}

-(void)writePrefs:(NSDictionary *)dictionary{
    if (!self.identifier) return;
    [self writePrefs:dictionary identifier:self.identifier];
}

-(void)writePrefs:(NSDictionary *)dictionary identifier:(NSString *)identifier{
    [_messagingCenter sendMessageAndReceiveReplyName:@"writePrefs" userInfo:@{@"identifier":identifier, @"prefs":dictionary}];
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if (!self.identifier) return;
    [self setValue:value?:[NSNull null] forKey:key identifier:self.identifier];
}

-(void)setValue:(id)value forKey:(NSString *)key  identifier:(NSString *)identifier{
    [_messagingCenter sendMessageAndReceiveReplyName:@"setValue" userInfo:@{@"identifier":identifier, @"value":value, @"key":key}];
}

-(void)removeKey:(NSString *)key{
    [self removeKey:key identifier:self.identifier];
}

-(void)removeKey:(NSString *)key identifier:(NSString *)identifier{
    [_messagingCenter sendMessageAndReceiveReplyName:@"removeKey" userInfo:@{@"identifier":identifier, @"key":key}];
}

-(id)valueForKey:(NSString *)key{
    if (!self.identifier) return nil;
    return [self valueForKey:key identifier:self.identifier];
}

-(id)valueForKey:(NSString *)key identifier:(NSString *)identifier{
    id val = [_messagingCenter sendMessageAndReceiveReplyName:@"valueForKey" userInfo:@{@"identifier":identifier, @"key":key}][@"value"];
    if (val == [NSNull null] || val == nil){
        return nil;
    }
    return val;
}

-(void)postNotification:(NSString *)notificationName{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)notificationName, NULL, NULL, YES);
}
@end
