#import "common.h"
#import "BSPPowerManagerClient.h"

@implementation BSPPowerManagerClient

- (instancetype)init{
    if ((self = [super init])) {
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:POWERMANAGER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
    }
    return self;
}

-(NSDictionary *)updateState:(BOOL)enableCharging{
    HBLogDebug(@"BSPPowerManagerClient updateState");
    return [_messagingCenter sendMessageAndReceiveReplyName:@"updateState" userInfo:@{@"enableCharging":@(enableCharging)}];
}
@end
