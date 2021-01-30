#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface BSPPrefsManagerClient : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
@property(nonatomic, strong) NSString *identifier;
-(instancetype)init;
-(instancetype)initWithIdentifier:(NSString *)identifier;
-(NSDictionary *)readPrefs;
-(NSDictionary *)readPrefs:(NSString *)identifier;
-(void)writePrefs:(NSDictionary *)dictionary;
-(void)writePrefs:(NSDictionary *)dictionary identifier:(NSString *)identifier;
-(void)setValue:(id)value forKey:(NSString *)key;
-(void)setValue:(id)value forKey:(NSString *)key  identifier:(NSString *)identifier;
-(void)removeKey:(NSString *)key;
-(void)removeKey:(NSString *)key identifier:(NSString *)identifier;
-(id)valueForKey:(NSString *)key;
-(id)valueForKey:(NSString *)key identifier:(NSString *)identifier;
-(void)postNotification:(NSString *)notificationName;
@end
