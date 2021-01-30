#import <ControlCenterUIKit/CCUIToggleModule.h>
#import <ControlCenterUI/CCUIModuleInstance.h>
#import <ControlCenterUI/CCUIModuleInstanceManager.h>

@interface CCUIModuleInstanceManager (CCSupport)
- (CCUIModuleInstance*)instanceForModuleIdentifier:(NSString*)moduleIdentifier;
@end

@interface BattSafeProCC : CCUIToggleModule{
  BOOL _selected;
}
-(void)updateStateViaPreferences;
@end
