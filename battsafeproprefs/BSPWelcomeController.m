#import "../common.h"
#import "BSPWelcomeController.h"

@implementation BSPWelcomeController

-(instancetype)init{
    NSBundle *tweakBundle = [NSBundle bundleWithPath:bundlePath];
    [tweakBundle load];
    
    if (@available(iOS 13.0, *)){
        // Create a bulleted item with a title, description, and icon. Any of the parameters can be set to nil if you wish. You can have as little or as many of these as you wish. The view automatically compensates for adjustments.

        if ((self = [[BSPWelcomeController alloc] initWithTitle:@"BattSafePro" detailText:LOCALIZED(@"WELCOME_DESCRIPTION") icon:[UIImage imageNamed:@"BattSafePro512" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BattSafeProPrefs.bundle"] compatibleWithTraitCollection:nil]])){
            
            // As written here, systemImageNamed is an iOS 13 feature. It is available in the UIKitCore framework publically. You are welcome to use your own images just as usual. Make sure you set them up with UIImageRenderingModeAlwaysTemplate to allow proper coloring.
            [self addBulletedListItemWithTitle:LOCALIZED(@"OVERSHOOTING_HEADER") description:LOCALIZED(@"OVERSHOOTING_MESSAGE") image:[UIImage systemImageNamed:@"1.circle.fill"]];
            [self addBulletedListItemWithTitle:LOCALIZED(@"OPTIMIZED_CHARGING_HEADER") description:LOCALIZED(@"OPTIMIZED_CHARGING_MESSAGE") image:[UIImage systemImageNamed:@"2.circle.fill"]];
            [self addBulletedListItemWithTitle:LOCALIZED(@"ACTIVATOR_SUPPORT_HEADER") description:LOCALIZED(@"ACTIVATOR_SUPPORT_MESSAGE") image:[UIImage systemImageNamed:@"3.circle.fill"]];

            // Create your button here, set some properties, and add it to the controller.
            OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
            [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
            [continueButton setTitle:LOCALIZED(@"ANSWER_GOT_IT") forState:UIControlStateNormal];
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
            
        }
        return self;
    }
    return self = [super init];
}

-(void)dismissWelcomeController { // Say goodbye to your controller. :(
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
