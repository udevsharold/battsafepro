#import "common.h"
#import "BattSafePro.h"
#import "BSPNotificationDispatcher.h"
#import "BSPPrefsManagerServer.h"
#import "BattSafe-Private.h"
#import "SpringBoard-Private.h"
#import "Tweak+Debug.h"

static NSBundle *tweakBundle;


@implementation BSPNotificationDispatcher

+(id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

-(instancetype)init{
    if ((self = [super init])){
        //[self reloadPrefs];
        tweakBundle = [NSBundle bundleWithPath:bundlePath];
        [tweakBundle load];
        
        _ndMessagingCenter = [%c(CPDistributedMessagingCenter) centerNamed:NOTIFICATIONDISPATCHER_CENTER_IDENTIFIER];
        rocketbootstrap_distributedmessagingcenter_apply(_ndMessagingCenter);
        [_ndMessagingCenter runServerOnCurrentThread];
        [_ndMessagingCenter registerForMessageName:@"recallRequest" target:self selector:@selector(recallRequest:withUserInfo:)];
        [_ndMessagingCenter registerForMessageName:@"dispatchRequest" target:self selector:@selector(dispatchRequest:withUserInfo:)];
        self.firstInit = NO;
    }
    return self;
}

-(void)notifyBypass{
    HBL(@"Will notify to bypass");
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)POWERMONITOR_BYPASS_CHARGING_STATE_NOTIFICATION_NAME, NULL, NULL, YES);
}

-(void)dismissNotification{
    [notificationListViewController dismissModalFullScreenAnimated:YES];
      [[%c(SBBannerController) sharedInstance] dismissBannerWithAnimation:YES reason:0 forceEvenIfBusy:YES];
      [self recallRequest];
}

//BBObserver method
-(void)sendResponse:(BBResponse *)response withCompletion:(/*^block*/id)arg2{
    [self notifyBypass];
    [self dismissNotification];
}

//BBObserver method
-(void)clearBulletins:(id)arg1 inSection:(id)arg2{
    [self dismissNotification];
}

//BBObserver method
-(void)removeBulletins:(id)arg1 inSection:(id)arg2{
    [self dismissNotification];
}

-(NCNotificationRequest *)requestAtLevel:(int)level{
    BBBulletinRequest* bulletin = [%c(BBBulletinRequest) new];
    
    bulletin.header = @"BattSafePro";
    bulletin.message = LOCALIZEDF(@"NOTI_MESSAGE", level);
    
    bulletin.accessoryImage = (BBImage *)[%c(BBImage) imageWithName:@"BattSafeProBulletin" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle"]];
    
    bulletin.section = @"com.udevs.battsafepro";
    bulletin.sectionID = @"com.udevs.battsafepro";
    NSString* bulletinUUID = [[NSUUID UUID] UUIDString];
    bulletin.bulletinID = bulletinUUID;
    bulletin.bulletinVersionID = bulletinUUID;
    bulletin.recordID = bulletinUUID;
    bulletin.date = [NSDate date];
    bulletin.clearable = YES;
    bulletin.publisherBulletinID = @"com.udevs.battsafepro.enabled";
    
    bulletin.sectionSubtype = 1;
    bulletin.preventAutomaticRemovalFromLockScreen = YES;
    bulletin.lockScreenPriority = 302;
    bulletin.turnsOnDisplay = !self.notifySilently;
    //BBSectionIcon *icon = [%c(BBSectionIcon) new];
    //BBSectionIconVariant *variant = [%c(BBSectionIconVariant) variantWithFormat:0 imageName:@"BattSafeProBulletin" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle"]];
    //icon.variants = [NSSet setWithArray:@[variant]];
    //bulletin.icon = icon;
    
    //BBObserver *observer = [[[%c(NCBulletinNotificationSource) alloc] initWithDispatcher:((SpringBoard *)[%c(UIApplication) sharedApplication]).notificationDispatcher.dispatcher] valueForKey:@"_observer"];
    
    BBSectionInfo *sectionInfo = [%c(BBSectionInfo) new];
    sectionInfo.sectionID = @"com.udevs.battsafepro";
    sectionInfo.allowsNotifications = YES;
    
    BBAction *chargeNowBBAction = [%c(BBAction) actionWithLaunchURL:nil callblock:^{
        //HBL(@"callblokc");
    }];
    chargeNowBBAction.identifier = @"CHARGE_NOW";
    chargeNowBBAction.shouldDismissBulletin = YES;
    chargeNowBBAction.actionType = 1;
    
    //bulletin.defaultAction = chargeNowBBAction;

    //other feed will not dismiss banner automatically
    NCMutableNotificationRequest *request = [[%c(NCNotificationRequest) notificationRequestForBulletin:bulletin observer:self sectionInfo:sectionInfo feed:2] mutableCopy];
    //request.defaultAction = [%c(NCNotificationAction) notificationActionForAction:chargeNowBBAction bulletin:bulletin observer:self];
    
    NCMutableNotificationAction *chargeNowAction = [%c(NCMutableNotificationAction) new];
    NCBulletinActionRunner <NCNotificationActionRunner> *chargeNowActionRunner = [[%c(NCBulletinActionRunner) alloc] initWithAction:chargeNowBBAction bulletin:bulletin observer:self];

    chargeNowAction.shouldDismissNotification = YES;
    chargeNowAction.title = @"Charge Now";
    chargeNowAction.identifier = @"CHARGE_NOW";
    chargeNowAction.activationMode = 1;
    
    chargeNowAction.actionRunner = chargeNowActionRunner;
    request.supplementaryActions = @{@"NCNotificationActionEnvironmentMinimal":@[chargeNowAction], @"NCNotificationActionEnvironmentDefault":@[chargeNowAction]};
    
    request.requestDestinations = [NSSet setWithArray:@[@"BulletinDestinationCoverSheet", @"BulletinDestinationBanner", @"BulletinDestinationNotificationCenter", @"BulletinDestinationLockScreen"]];
    
    NCMutableNotificationOptions *options = [%c(NCMutableNotificationOptions) new];
    options.addToLockScreenWhenUnlocked = YES;
    options.alertsWhenLocked = YES;
    options.lockScreenPersistence = 2;
    options.lockScreenPriority = 302;
    options.canTurnOnDisplay = !self.notifySilently;
    options.overridesPocketMode = YES;
    options.dismissAutomatically = YES;
    options.dismissAutomaticallyForCarPlay = YES;
    
    request.options = options;
    
    return request;
}

-(NSDictionary *)recallRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    BOOL success = [self recallRequest];
    return @{@"result":@(success)};
}

-(BOOL)recallRequest{
    NSMutableArray *sections = notificationListViewController.masterList.notificationSections;
    for (NCNotificationStructuredSectionList *section in sections){
        for (NCNotificationRequest *request in section.allNotificationRequests){
            if ([request.sectionIdentifier containsString:@"com.udevs.battsafepro"]){
                SBNCNotificationDispatcher *sbNotificationDispatcher = ((SpringBoard *)[%c(UIApplication) sharedApplication]).notificationDispatcher;
                [sbNotificationDispatcher.dispatcher destination:nil requestsClearingNotificationRequests:@[request]];
                [notificationListViewController removeNotificationRequest:request];
                HBL(@"Recallled request");
                return YES;
                break;
            }
        }
    }
    return NO;
}

-(NSDictionary *)dispatchRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    int level = [userInfo[@"level"] intValue];
    BOOL success = [self dispatchRequest:[self requestAtLevel:level]];
    return @{@"result":@(success)};
}

-(BOOL)dispatchRequest:(NCNotificationRequest *)req{
    if (!req) return NO;
    //dispatch_async(BBServerQ, ^{
        //[bulletinServer publishBulletinRequest:req destinations:14];
    //});
    SBNCNotificationDispatcher *sbNotificationDispatcher = ((SpringBoard *)[%c(UIApplication) sharedApplication]).notificationDispatcher;
    [sbNotificationDispatcher.dispatcher postNotificationWithRequest:req];
    return YES;
}

-(void)reloadPrefs{
    //if (!self.firstInit){ //To fix reload prefs twice during respring
        BSPPrefsManagerServer *prefsManager = [%c(BSPPrefsManagerServer) sharedInstance];
        self.enabled = [prefsManager valueForKey:@"enabled" identifier:TWEAK_IDENTIFIER] ? [[prefsManager valueForKey:@"enabled" identifier:TWEAK_IDENTIFIER] boolValue] : YES;
        self.notifySilently = [prefsManager valueForKey:@"notifySilently"  identifier:TWEAK_IDENTIFIER] ? [[prefsManager valueForKey:@"notifySilently" identifier:TWEAK_IDENTIFIER] boolValue] : YES;
    //}
    HBL(@"notifySilently: %d", self.notifySilently?1:0);
}

@end
