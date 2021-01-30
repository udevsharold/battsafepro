#import "OnboardingKit.h"

@interface BSPDiagnosticController : OBWelcomeController
@property(nonatomic, strong) OBBoldTrayButton *refreshButton;
@property(nonatomic, strong) NSTimer *autoRefreshTimer;
@end
