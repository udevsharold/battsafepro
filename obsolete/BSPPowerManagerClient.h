#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface BSPPowerManagerClient : NSObject{
    CPDistributedMessagingCenter * _messagingCenter;
}
-(instancetype)init;
-(NSDictionary *)updateState:(BOOL)enableCharging;
@end
