#import "../common.h"
#import "BSPDiagnosticController.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

static int refreshCountdown = 5;
static NSBundle *tweakBundle;

@implementation BSPDiagnosticController

-(instancetype)init{
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    
    if (@available(iOS 13.0, *)){
        UIImageSymbolConfiguration* imageConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
        UIImage *image;
        
        
        
        // Create a bulleted item with a title, description, and icon. Any of the parameters can be set to nil if you wish. You can have as little or as many of these as you wish. The view automatically compensates for adjustments.
        
        if ((self = [[BSPDiagnosticController alloc] initWithTitle:LOCALIZED(@"DIAGNOSTIC_TITLE") detailText:LOCALIZED(@"DIAGNOSTIC_DESCRIPTION") icon:[UIImage systemImageNamed:@"wrench"]])){
            
            // As written here, systemImageNamed is an iOS 13 feature. It is available in the UIKitCore framework publically. You are welcome to use your own images just as usual. Make sure you set them up with UIImageRenderingModeAlwaysTemplate to allow proper coloring.
            int tagIdx = 0;
            BOOL isInEffect = [self isBattSafeProInEffect];
            image = [UIImage systemImageNamed:(isInEffect?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
            [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_BATTSAFEPRO_IN_EFFECT") description:nil image:image];
            self.bulletedList.items[tagIdx].tag = tagIdx;
            self.bulletedList.items[tagIdx].tintColor = isInEffect ? [UIColor greenColor] : [UIColor redColor];
            tagIdx++;
            
            int chargingProhibited = [self chargingProhibitedState];
            switch (chargingProhibited) {
                case 0:
                    image = [UIImage systemImageNamed:@"xmark.circle.fill" withConfiguration:imageConfig];
                    [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_CHARGING_PROHIBITED") description:nil image:image];
                    self.bulletedList.items[tagIdx].tintColor = [UIColor redColor];
                    break;
                case 1:
                    image = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:imageConfig];
                    [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_CHARGING_PROHIBITED") description:nil image:image];
                    self.bulletedList.items[tagIdx].tintColor = [UIColor greenColor];
                    break;
                case -1:
                    image = [UIImage systemImageNamed:@"exclamationmark.circle.fill" withConfiguration:imageConfig];
                    [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_CHARGING_PROHIBITED") description:nil image:image];
                    self.bulletedList.items[tagIdx].tintColor = [UIColor orangeColor];
                    break;
                default:
                    break;
            }
            self.bulletedList.items[tagIdx].tag = tagIdx;
            tagIdx++;
            
            BOOL isCharging = [self isBatteryCharging];
            image = [UIImage systemImageNamed:(isCharging?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
            [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_CHARGING") description:LOCALIZED(@"DIAGNOSTIC_CHARGING_DESCRIPTION") image:image];
            self.bulletedList.items[tagIdx].tag = tagIdx;
            self.bulletedList.items[tagIdx].tintColor = isCharging ? [UIColor greenColor] : [UIColor redColor];
            tagIdx++;
            
            BOOL externalConnected = [self isExternalConnected];
            image = [UIImage systemImageNamed:(externalConnected?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
            [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_EXTERNAL") description:nil image:image];
            self.bulletedList.items[tagIdx].tag = tagIdx;
            self.bulletedList.items[tagIdx].tintColor = externalConnected ? [UIColor greenColor] : [UIColor redColor];
            tagIdx++;
            
            BOOL externalCapableCharging = [self isExternalCapableCharging];
            image = [UIImage systemImageNamed:(externalCapableCharging?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
            [self addBulletedListItemWithTitle:LOCALIZED(@"DIAGNOSTIC_EXTERNAL_CAPABLE") description:nil image:image];
            self.bulletedList.items[tagIdx].tag = tagIdx;
            self.bulletedList.items[tagIdx].tintColor = externalCapableCharging ? [UIColor greenColor] : [UIColor redColor];
            tagIdx++;
            
            // Create your button here, set some properties, and add it to the controller.
            self.refreshButton = [OBBoldTrayButton buttonWithType:1];
            [self.refreshButton addTarget:self action:@selector(refreshDiagnosticInfo) forControlEvents:UIControlEventTouchUpInside];
            [self.refreshButton setTitle:[NSString stringWithFormat:@"%@ (%d)", LOCALIZED(@"DIAGNOSTIC_BUTTON_REFRESH"), refreshCountdown] forState:UIControlStateNormal];
            [self.refreshButton setClipsToBounds:YES]; // There seems to be an internal issue with the properties, so you may need to force this to YES like so.
            [self.refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // There seems to be an internal issue with the properties, so you may need to force this to be [UIColor whiteColor] like so.
            [self.refreshButton.layer setCornerRadius:15]; // Set your button's corner radius. This can be whatever. If this doesn't work, make sure you make setClipsToBounds to YES.
            [self.buttonTray addButton:self.refreshButton];
            
            OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
            [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
            [continueButton setTitle:LOCALIZED(@"DIAGNOSTIC_BUTTON_CLOSE") forState:UIControlStateNormal];
            [continueButton setClipsToBounds:YES]; // There seems to be an internal issue with the properties, so you may need to force this to YES like so.
            [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // There seems to be an internal issue with the properties, so you may need to force this to be [UIColor whiteColor] like so.
            [continueButton.layer setCornerRadius:15]; // Set your button's corner radius. This can be whatever. If this doesn't work, make sure you make setClipsToBounds to YES.
            [self.buttonTray addButton:continueButton];
            
            
            // Set the Blur Effect Style of the Button Tray
            self.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            
            // Create the view that will contain the blur and set the frame to the View of welcomeController
            UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:self.viewIfLoaded.bounds];
            
            // Set the Blur Effect Style of the Blur View
            effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            
            // Insert the Blur View to the View of the welcomeController atIndex:0 to put it behind everything
            [self.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
            
            // Set the background to the View of the welcomeController to clear so the blur will show
            self.viewIfLoaded.backgroundColor = [UIColor clearColor];
            
            //The caption text goes right above the buttons, sort of like as a thank you or disclaimer. This is optional, and can be excluded from your project.
            //[welcomeController.buttonTray addCaptionText:@"Thank you for using this tutorial on how to use an OBWelcomeView."];
            
            self.modalPresentationStyle = UIModalPresentationPageSheet; // The same style stock iOS uses.
            self.modalInPresentation = NO; //Set this to yes if you don't want the user to dismiss this on a down swipe.
            self.view.tintColor = [UIColor colorWithRed: 0.40 green: 0.75 blue: 0.40 alpha: 1.00]; // If you want a different tint color. If you don't set this, the controller will take the default color.
            refreshCountdown = 5;
            self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshDiagnosticInfoTimer) userInfo:nil repeats:YES];

        }
        return self;
    }
    return self = [super init];
}

-(void)refreshDiagnosticInfoTimer{
    if (refreshCountdown > 0){
        refreshCountdown--;
        [UIView performWithoutAnimation:^{
        [self.refreshButton setTitle:[NSString stringWithFormat:@"%@ (%d)", LOCALIZED(@"DIAGNOSTIC_BUTTON_REFRESH"), refreshCountdown] forState:UIControlStateNormal];
        }];
    }else{
        refreshCountdown = 5;
        [self.refreshButton setTitle:[NSString stringWithFormat:@"%@ (%d)", LOCALIZED(@"DIAGNOSTIC_BUTTON_REFRESH"), refreshCountdown] forState:UIControlStateNormal];
        [self refreshDiagnosticInfo];
    }

}

-(void)dismissWelcomeController { // Say goodbye to your controller. :(
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    refreshCountdown = 5;
    [self.refreshButton setTitle:[NSString stringWithFormat:@"%@ (%d)", LOCALIZED(@"DIAGNOSTIC_BUTTON_REFRESH"), refreshCountdown] forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

-(NSDictionary *)batteryInfo{
    CFDictionaryRef matching = IOServiceMatching("IOPMPowerSource");
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
    CFMutableDictionaryRef prop = NULL;
    IORegistryEntryCreateCFProperties(service, &prop, NULL, 0);
    NSDictionary* dict = (__bridge_transfer NSDictionary*)prop;
    IOObjectRelease(service);
    return dict;
}

-(void)refreshDiagnosticInfo{
    if (@available(iOS 13.0, *)){
        UIImage *image;
        UIImageSymbolConfiguration* imageConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
        
        int tagIdx = 0;
        BOOL isInEffect = [self isBattSafeProInEffect];
        image = [UIImage systemImageNamed:(isInEffect?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
        self.bulletedList.items[tagIdx].tintColor = isInEffect ? [UIColor greenColor] : [UIColor redColor];
        self.bulletedList.items[tagIdx].imageView.image = image;
        tagIdx++;
        
        int chargingProhibited = [self chargingProhibitedState];
        switch (chargingProhibited) {
            case 0:
                image = [UIImage systemImageNamed:@"xmark.circle.fill" withConfiguration:imageConfig];
                self.bulletedList.items[tagIdx].tintColor = [UIColor redColor];
                break;
            case 1:
                image = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:imageConfig];
                self.bulletedList.items[tagIdx].tintColor = [UIColor greenColor];
                break;
            case -1:
                image = [UIImage systemImageNamed:@"exclamationmark.circle.fill" withConfiguration:imageConfig];
                self.bulletedList.items[tagIdx].tintColor = [UIColor orangeColor];
                break;
            default:
                break;
        }
        self.bulletedList.items[tagIdx].imageView.image = image;
        tagIdx++;
        
        BOOL isCharging = [self isBatteryCharging];
        image = [UIImage systemImageNamed:(isCharging?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
        self.bulletedList.items[tagIdx].tintColor = isCharging ? [UIColor greenColor] : [UIColor redColor];
        self.bulletedList.items[tagIdx].imageView.image = image;
        tagIdx++;
        
        BOOL externalConnected = [self isExternalConnected];
        image = [UIImage systemImageNamed:(externalConnected?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
        self.bulletedList.items[tagIdx].tintColor = externalConnected ? [UIColor greenColor] : [UIColor redColor];
        self.bulletedList.items[tagIdx].imageView.image = image;
        tagIdx++;
        
        BOOL externalCapableCharging = [self isExternalCapableCharging];
        image = [UIImage systemImageNamed:(externalCapableCharging?@"checkmark.circle.fill":@"xmark.circle.fill") withConfiguration:imageConfig];
        self.bulletedList.items[tagIdx].tintColor = externalCapableCharging ? [UIColor greenColor] : [UIColor redColor];
        self.bulletedList.items[tagIdx].imageView.image = image;
        tagIdx++;
    }
    
}

-(id)valueForKey:(NSString *)key{
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

-(BOOL)isBattSafeProInEffect{
    return [[self valueForKey:@"isInEffect"] boolValue];
}

-(BOOL)isBatteryCharging{
    return [[self batteryInfo][@"IsCharging"] boolValue];
}

-(BOOL)isExternalConnected{
    return [[self batteryInfo][@"ExternalConnected"] boolValue];
    
}

-(BOOL)isExternalCapableCharging{
    return [[self batteryInfo][@"ExternalChargeCapable"] boolValue];
    
}

-(int)chargingProhibitedState{
    CFDictionaryRef assertionStates;
    IOReturn status = IOPMCopyAssertionsStatus(&assertionStates);
    NSDictionary *info = nil;
    if (status == kIOReturnSuccess){
        info = (NSDictionary*)CFBridgingRelease(assertionStates);
    }
    
    int state = info ? [info[@"ChargeInhibit"] intValue] : -1;
    return state;
}
@end
