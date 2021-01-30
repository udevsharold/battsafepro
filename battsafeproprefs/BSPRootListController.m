#import "../common.h"
#include "BSPRootListController.h"
#import "BSPWelcomeController.h"
#import "BSPDiagnosticController.h"
#import "../NSTask.h"

#define CONTRIBUTORS @"peterfectionn, xiehq, Crevette, u/vladaad, himajin"

static NSBundle *tweakBundle;

@implementation BSPRootListController

void reloadAllSpecifiers() {
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME object:nil];
}

- (instancetype)init{
    if ((self = [super init])) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadAllSpecifiers, (CFStringRef)RELOAD_SPECIFIERS_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSpecifiers:) name:RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME object:nil];
    }
    return self;
}

- (void)refreshSpecifiers:(NSNotification *)notification{
    [self reloadSpecifiers];
}

-(id)getValueForKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)TWEAK_IDENTIFIER;
    CFPreferencesAppSynchronize(appID);
    return CFBridgingRelease(CFPreferencesCopyAppValue((CFStringRef)key, appID));
}

-(void)setValue:(id)value forKey:(NSString *)key{
    CFStringRef appID = (CFStringRef)TWEAK_IDENTIFIER;
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, appID);
    CFPreferencesAppSynchronize(appID);
}

-(void)viewDidLoad  {
    tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    [super viewDidLoad];
    
    
    CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
    CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed: 0.40 green: 0.75 blue: 0.40 alpha: 1.00];
    
    
    UIImage *headerImage = [[UIImage alloc]
                            initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle"] pathForResource:@"BattSafePro512" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
    [imageView setImage:headerImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setText:@"BattSafePro"];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    self.table.tableHeaderView = headerView;
    
    self.respringBtn = [[UIBarButtonItem alloc] initWithTitle:LOCALIZED(@"RESPRING") style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    self.navigationItem.rightBarButtonItem = self.respringBtn;
    
    if (!([self getValueForKey:@"hasWelcomedUser"] ? [[self getValueForKey:@"hasWelcomedUser"] boolValue] : NO)){
        if (@available(iOS 13.0, *)){
            BSPWelcomeController *welcomeController = [BSPWelcomeController new];
            [self presentViewController:welcomeController animated:YES completion:nil];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BattSafePro" message:LOCALIZED(@"OVERSHOOTING_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *gotItAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_GOT_IT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:gotItAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        [self setValue:@YES forKey:@"hasWelcomedUser"];
    }
    
    
}

-(void)loadView {
    [super loadView];
    ((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        
        NSMutableArray *rootSpecifiers = [[NSMutableArray alloc] init];
        
        //Enabled
        PSSpecifier *enabledTweakGroupSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"TWEAK") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [enabledTweakGroupSpec setProperty:LOCALIZED(@"TWEAK_FOOTER") forKey:@"footerText"];
        [rootSpecifiers addObject:enabledTweakGroupSpec];
        
        PSSpecifier *enabledSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"ENABLED") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [enabledSpec setProperty:LOCALIZED(@"ENABLED") forKey:@"label"];
        [enabledSpec setProperty:@"enabled" forKey:@"key"];
        [enabledSpec setProperty:@YES forKey:@"default"];
        [enabledSpec setProperty:TWEAK_IDENTIFIER forKey:@"defaults"];
        [enabledSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:enabledSpec];
        
        //show notification
        PSSpecifier *showNotificationGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [showNotificationGroupSpec setProperty:LOCALIZED(@"SHOW_NOTIFICATION_FOOTER") forKey:@"footerText"];
        [rootSpecifiers addObject:showNotificationGroupSpec];
        
        PSSpecifier *showNotificationSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SHOW_NOTIFICATION") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [showNotificationSpec setProperty:LOCALIZED(@"SHOW_NOTIFICATION") forKey:@"label"];
        [showNotificationSpec setProperty:@"showNotification" forKey:@"key"];
        [showNotificationSpec setProperty:@YES forKey:@"default"];
        [showNotificationSpec setProperty:TWEAK_IDENTIFIER forKey:@"defaults"];
        [showNotificationSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:showNotificationSpec];
        
        
        //wake screen
        PSSpecifier *notifySilentlyGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [notifySilentlyGroupSpec setProperty:LOCALIZED(@"NOTIFY_SILENTLY_FOOTER") forKey:@"footerText"];
        [rootSpecifiers addObject:notifySilentlyGroupSpec];
        
        PSSpecifier *notifySilentlySpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"NOTIFY_SILENTLY") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [notifySilentlySpec setProperty:LOCALIZED(@"NOTIFY_SILENTLY") forKey:@"label"];
        [notifySilentlySpec setProperty:@"notifySilently" forKey:@"key"];
        [notifySilentlySpec setProperty:@YES forKey:@"default"];
        [notifySilentlySpec setProperty:TWEAK_IDENTIFIER forKey:@"defaults"];
        [notifySilentlySpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        self.notifySilentlySpecifier = notifySilentlySpec;
        [rootSpecifiers addObject:notifySilentlySpec];
        
        
        //max charging level
        PSSpecifier *maxChargingLevelGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [maxChargingLevelGroupSpec setProperty:LOCALIZED(@"MAX_CHARGE_LEVEL_FOOTER") forKey:@"footerText"];
        [rootSpecifiers addObject:maxChargingLevelGroupSpec];
        
        
        PSTextFieldSpecifier* maxChargingLevelSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:LOCALIZED(@"MAX_CHARGE_LEVEL") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
        [maxChargingLevelSpec setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
        [maxChargingLevelSpec setPlaceholder:[@(defaultMaxChargingLevel) stringValue]];
        [maxChargingLevelSpec setProperty:@"maxChargingLevel" forKey:@"key"];
        [maxChargingLevelSpec setProperty:TWEAK_IDENTIFIER forKey:@"defaults"];
        [maxChargingLevelSpec setProperty:LOCALIZED(@"MAX_CHARGE_LEVEL") forKey:@"label"];
        [maxChargingLevelSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:maxChargingLevelSpec];
        
        //blsnk group
        PSSpecifier *blankSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:blankSpecGroup];
        
        //show welcome
        PSSpecifier *welcomeViewSpec;
        if (@available(iOS 13.0, *)){
            welcomeViewSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"ONBOARDING_SCREEN_SHOW") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [welcomeViewSpec setProperty:LOCALIZED(@"ONBOARDING_SCREEN_SHOW") forKey:@"label"];
        }else{
            welcomeViewSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"ONBOARDING_ALERT_SHOW") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [welcomeViewSpec setProperty:LOCALIZED(@"ONBOARDING_ALERT_SHOW") forKey:@"label"];
        }
        [welcomeViewSpec setButtonAction:@selector(showOnboardingScreen)];
        [rootSpecifiers addObject:welcomeViewSpec];
        
        //show diagnostic
        if (@available(iOS 13.0, *)){
            PSSpecifier *diagnosticViewSpec;
            if (@available(iOS 13.0, *)){
                diagnosticViewSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"DIAGNOSTIC_SCREEN_SHOW") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
                [diagnosticViewSpec setProperty:LOCALIZED(@"DIAGNOSTIC_SCREEN_SHOW") forKey:@"label"];
            }else{
                diagnosticViewSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"DIAGNOSTIC_ALERT_SHOW") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
                [diagnosticViewSpec setProperty:LOCALIZED(@"DIAGNOSTIC_ALERT_SHOW") forKey:@"label"];
            }
            [diagnosticViewSpec setButtonAction:@selector(showDiagnosticScreen)];
            [rootSpecifiers addObject:diagnosticViewSpec];
        }
        //blsnk group
        [rootSpecifiers addObject:blankSpecGroup];
        [rootSpecifiers addObject:blankSpecGroup];
        
        //Support Dev
        PSSpecifier *supportDevGroupSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"DEVELOPMENT") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:supportDevGroupSpec];
        
        PSSpecifier *supportDevSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"SUPPORT") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [supportDevSpec setProperty:LOCALIZED(@"SUPPORT") forKey:@"label"];
        [supportDevSpec setButtonAction:@selector(donation)];
        [supportDevSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle/PayPal.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:supportDevSpec];
        
        
        //Contact
        PSSpecifier *contactGroupSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"CONTACT") target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:contactGroupSpec];
        
        //Twitter
        PSSpecifier *twitterSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"TWITTER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [twitterSpec setProperty:LOCALIZED(@"TWITTER") forKey:@"label"];
        [twitterSpec setButtonAction:@selector(twitter)];
        [twitterSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle/Twitter.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:twitterSpec];
        
        //Reddit
        PSSpecifier *redditSpec = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"REDDIT") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [redditSpec setProperty:LOCALIZED(@"REDDIT") forKey:@"label"];
        [redditSpec setButtonAction:@selector(reddit)];
        [redditSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle/Reddit.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:redditSpec];
        
        //udevs
        PSSpecifier *createdByGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [createdByGroupSpec setProperty:LOCALIZED(@"FOOTER_CREATED") forKey:@"footerText"];
        [createdByGroupSpec setProperty:@1 forKey:@"footerAlignment"];
        [rootSpecifiers addObject:createdByGroupSpec];
        
        //blank
        [rootSpecifiers addObject:blankSpecGroup];
        //[rootSpecifiers addObject:blankSpecGroup];
        
        //special thanks
        PSSpecifier *specialThanksByGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [specialThanksByGroupSpec setProperty:LOCALIZEDF(@"FOOTER_CREDITS", CONTRIBUTORS) forKey:@"footerText"];
        [specialThanksByGroupSpec setProperty:@1 forKey:@"footerAlignment"];
        [rootSpecifiers addObject:specialThanksByGroupSpec];
        _specifiers = rootSpecifiers;
        
    }
    
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier{
    id value = [super readPreferenceValue:specifier];
    if ([specifier.properties[@"key"] isEqualToString:@"showNotification"]){
        [self.notifySilentlySpecifier setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:self.notifySilentlySpecifier animated:YES];
    }
    return value;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [super setPreferenceValue:value specifier:specifier];
    if ([specifier.properties[@"key"] isEqualToString:@"enabled"]){
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)REFRESH_MODULE_NOTIFICATION_NAME, NULL, NULL, YES);
    }else if ([specifier.properties[@"key"] isEqualToString:@"showNotification"]){
        [self.notifySilentlySpecifier setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:self.notifySilentlySpecifier animated:YES];
    }
}

-(int)runCommand:(NSString *)cmd{
    if ([cmd length] != 0){
        NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
        taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
        NSTask * task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:taskArgs];
        NSPipe* outputPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        [task launch];
        //NSData *data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        [task waitUntilExit];
        return [task terminationStatus];
    }
    return 0;
}

- (void)respring {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BattSafePro" message:LOCALIZED(@"RESPRING_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runCommand:@"/usr/local/bin/bts -c \"killall -9 symptomsd\""];
        [self runCommand:@"/usr/local/bin/bts -c \"killall -9 powerd\""];
        
        NSURL *relaunchURL = [NSURL URLWithString:@"prefs:root=BattSafePro"];
        SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:4 targetURL:relaunchURL];
        [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_NO") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)donation {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/udevs"] options:@{} completionHandler:nil];
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/udevs9"] options:@{} completionHandler:nil];
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/h4roldj"] options:@{} completionHandler:nil];
}

-(void)showOnboardingScreen{
    if (@available(iOS 13.0, *)){
        BSPWelcomeController *welcomeController = [BSPWelcomeController new];
        [self presentViewController:welcomeController animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BattSafePro" message:LOCALIZED(@"OVERSHOOTING_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *gotItAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_GOT_IT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:gotItAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)showDiagnosticScreen{
    //[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"zh-Hans"] forKey:@"AppleLanguages"];
    //[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"Base"] forKey:@"AppleLanguages"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    if (@available(iOS 13.0, *)){
        BSPDiagnosticController *diagnosticController = [BSPDiagnosticController new];
        [self presentViewController:diagnosticController animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"DIAGNOSTIC_TITLE") message:LOCALIZED(@"OVERSHOOTING_MESSAGE") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *gotItAction = [UIAlertAction actionWithTitle:LOCALIZED(@"ANSWER_GOT_IT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:gotItAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
