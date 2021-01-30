#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface BSPPrefsManagerServer : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
+ (instancetype)sharedInstance;
-(NSDictionary *)readPrefs:(NSString *)identifier;
-(void)writePrefs:(NSDictionary *)dictionary identifier:(NSString *)identifier;
-(void)setValue:(id)value forKey:(NSString *)key  identifier:(NSString *)identifier;
-(NSDictionary *)removeKey:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
-(id)valueForKey:(NSString *)key identifier:(NSString *)identifier;
-(void)postNotification:(NSString *)notificationName;
@end
