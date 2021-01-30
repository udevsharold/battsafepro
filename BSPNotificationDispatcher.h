#import <RocketBootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "SpringBoard-Private.h"

@interface BSPNotificationDispatcher : NSObject{
    CPDistributedMessagingCenter * _ndMessagingCenter;
}
@property(nonatomic, assign) BOOL notifySilently;
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) BOOL firstInit;
+(id)sharedInstance;
-(void)reloadPrefs;
@end
