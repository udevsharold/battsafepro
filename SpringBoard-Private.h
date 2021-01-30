#import <Foundation/NSOperation.h>
#import <UserNotifications/UserNotifications.h>

@interface FBProcessState : NSObject
-(void)setTaskState:(long long)arg1 ;
-(void)setVisibility:(long long)arg1 ;
-(int)pid;

@end

@interface BSProcessHandle : NSObject
+(id)processHandleForPID:(int)arg1 ;
@end

@interface RBSProcessIdentity : NSObject
@property (nonatomic,copy,readonly) NSString * embeddedApplicationIdentifier;
@property (nonatomic,copy,readonly) NSString * executablePath;
@property (getter=isDaemon,nonatomic,readonly) BOOL daemon;
@property (nonatomic,copy,readonly) NSString * daemonJobLabel;
@property (nonatomic,readonly) unsigned euid;
+(id)identityForEmbeddedApplicationIdentifier:(id)arg1 ;
@end

@interface FBProcess : NSObject
@property (nonatomic,readonly) int pid;
@property (nonatomic,readonly) BSProcessHandle * handle;
@property (nonatomic,readonly) RBSProcessIdentity * identity;
-(FBProcessState *)state;
-(id)initWithHandle:(id)arg1 identity:(id)arg2 executionContext:(id)arg3 ;
-(void)_queue_rebuildState;
-(void)_queue_executeLaunchCompletionBlocks:(BOOL)arg1 ;
-(void)_queue_updateStateWithBlock:(/*^block*/id)arg1 ;
-(void)_queue_setTaskState:(long long)arg1 ;
-(void)_queue_setVisibility:(long long)arg1 ;
-(void)launchWithDelegate:(id)arg1 ;
@end

@interface FBApplicationProcess : FBProcess
-(void)setNowPlayingWithAudio:(BOOL)arg1 ;
@end


@protocol SBActivationSettings <NSObject>
@required
-(BOOL)boolForActivationSetting:(unsigned)arg1;
-(id)objectForActivationSetting:(unsigned)arg1;
-(void)applyActivationSettings:(id)arg1;
-(void)setObject:(id)arg1 forActivationSetting:(unsigned)arg2;
-(void)setFlag:(long long)arg1 forActivationSetting:(unsigned)arg2;
-(long long)flagForActivationSetting:(unsigned)arg1;
-(id)copyActivationSettings;
-(void)clearActivationSettings;

@end

@interface SBActivationSettings : NSObject <SBActivationSettings>
@end


@interface FBSOpenApplicationOptions : NSObject
+(id)optionsWithDictionary:(id)arg1 ;
-(void)_sanitizeAndValidatePayload;
@end


@interface FBSystemServiceOpenApplicationRequest : NSObject
+(id)request;
-(void)setOptions:(FBSOpenApplicationOptions *)arg1 ;
-(void)setBundleIdentifier:(NSString *)arg1 ;
-(void)setTrusted:(BOOL)arg1 ;
-(void)setClientProcess:(FBProcess *)arg1 ;
@end

@interface FBSystemService : NSObject
+(id)sharedInstance;
-(void)dealloc;
-(id)initWithQueue:(id)arg1 ;
-(void)listener:(id)arg1 didReceiveConnection:(id)arg2 withContext:(id)arg3 ;
-(void)canOpenApplication:(id)arg1 completion:(/*^block*/id)arg2 ;
-(oneway void)openApplication:(id)arg1 withOptions:(id)arg2 originator:(id)arg3 requestID:(id)arg4 completion:(/*^block*/id)arg5 ;
-(void)shutdownWithOptions:(unsigned long long)arg1 ;
-(void)isPasscodeLockedOrBlockedWithResult:(/*^block*/id)arg1 ;
-(void)handleActions:(id)arg1 source:(id)arg2 withResult:(/*^block*/id)arg3 ;
-(void)terminateApplication:(id)arg1 forReason:(long long)arg2 andReport:(BOOL)arg3 withDescription:(id)arg4 source:(id)arg5 completion:(/*^block*/id)arg6 ;
-(void)terminateApplicationGroup:(long long)arg1 forReason:(long long)arg2 andReport:(BOOL)arg3 withDescription:(id)arg4 source:(id)arg5 completion:(/*^block*/id)arg6 ;
-(void)shutdownWithOptions:(id)arg1 origin:(id)arg2 ;
-(void)_setInfoProvider;
-(void)shutdownWithOptions:(unsigned long long)arg1 forSource:(long long)arg2 ;
-(void)setPendingExit:(BOOL)arg1 ;
-(unsigned long long)_mapShutdownOptionsToOptions:(id)arg1 ;
-(void)_performExitTasksForRelaunch:(BOOL)arg1 ;
-(void)exitAndRelaunch:(BOOL)arg1 withOptions:(unsigned long long)arg2 ;
-(void)_terminateProcesses:(id)arg1 forReason:(long long)arg2 andReport:(BOOL)arg3 withDescription:(id)arg4 completion:(/*^block*/id)arg5 ;
-(void)_activateApplication:(id)arg1 requestID:(id)arg2 options:(id)arg3 source:(id)arg4 originalSource:(id)arg5 withResult:(/*^block*/id)arg6 ;
-(BOOL)_isTrustedRequest:(id)arg1 forCaller:(id)arg2 fromClient:(id)arg3 forApplication:(id)arg4 withOptions:(id)arg5 fatalError:(out id*)arg6 ;
-(void)_reallyActivateApplication:(id)arg1 requestID:(id)arg2 options:(id)arg3 source:(id)arg4 originalSource:(id)arg5 isTrusted:(BOOL)arg6 sequenceNumber:(unsigned long long)arg7 cacheGUID:(id)arg8 ourSequenceNumber:(unsigned long long)arg9 ourCacheGUID:(id)arg10 withResult:(/*^block*/id)arg11 ;
-(BOOL)_shouldPendRequestForClientSequenceNumber:(unsigned long long)arg1 clientCacheGUID:(id)arg2 ourSequenceNumber:(unsigned long long)arg3 ourCacheGUID:(id)arg4 ;
-(void)activateApplication:(id)arg1 requestID:(id)arg2 options:(id)arg3 source:(id)arg4 originalSource:(id)arg5 withResult:(/*^block*/id)arg6 ;
-(void)prepareDisplaysForExit;
-(BOOL)_isWhitelistedLaunchSuspendedApp:(id)arg1 ;
-(void)shutdownAndReboot:(BOOL)arg1 ;
-(void)shutdownUsingOptions:(id)arg1 ;
-(void)exitAndRelaunch:(BOOL)arg1 ;
-(void)prepareForExitAndRelaunch:(BOOL)arg1 ;
-(void)setSystemIdleSleepDisabled:(BOOL)arg1 forReason:(id)arg2 ;
-(BOOL)isPendingExit;
@end

@interface FBApplicationProcessWatchdogPolicy : NSObject
+(id)defaultPolicy;
@end


@interface FBProcessManager : NSObject
-(void)launchProcessWithContext:(id)arg1 ;
-(void)_queue_addProcess:(id)arg1 ;
-(void)_queue_addForegroundRunningProcess:(id)arg1 ;
-(id)allApplicationProcesses;
-(id)allProcesses;
-(void)launchProcessWithContext:(id)arg1 ;
-(id)applicationProcessesForBundleIdentifier:(id)arg1 ;
-(void)_setPreferredForegroundApplicationProcess:(id)arg1 deferringToken:(id)arg2 ;
-(void)setDefaultWatchdogPolicy:(FBApplicationProcessWatchdogPolicy *)arg1 ;
-(void)_queue_evaluateForegroundEventRouting;
-(id)_createProcessWithExecutionContext:(id)arg1 ;
-(id)registerProcessForHandle:(id)arg1 ;
@end


@interface SBWorkspaceEntity : NSObject
@end

@interface SBApplicationSceneEntity : SBWorkspaceEntity
@end

@interface SBDeviceApplicationSceneEntity : SBApplicationSceneEntity
-(id)initWithApplicationSceneHandle:(id)arg1 ;
+(id)newEntityWithApplicationForMainDisplay:(id)arg1 ;
+(id)defaultEntityWithApplicationForMainDisplay:(id)arg1 ;
+(id)defaultEntityWithApplicationForMainDisplay:(id)arg1 targetContentIdentifier:(id)arg2 ;
+(id)entityWithApplicationForMainDisplay:(id)arg1 withScenePersistenceIdentifier:(id)arg2 ;
@end

@interface SBWorkspaceTransitionRequest : NSObject
@property (nonatomic,retain) BSProcessHandle * originatingProcess;
@end


@interface SBMainWorkspaceTransitionRequest : SBWorkspaceTransitionRequest
@end


@protocol BSPowerMonitorObserver <NSObject>
@optional
-(BOOL)powerMonitorSystemSleepRequested:(id)arg1;
-(void)powerMonitorSystemSleepRequestAborted:(id)arg1;
-(void)powerMonitorSystemWillSleep:(id)arg1;
-(void)powerMonitorSystemWillWakeFromSleep:(id)arg1;
-(void)powerMonitorSystemDidWakeFromSleep:(id)arg1;

@end

@interface SBWorkspace : NSObject
@end


@interface SBMainWorkspace : SBWorkspace <BSPowerMonitorObserver>
+(id)sharedInstance;
+(id)_sharedInstanceWithNilCheckPolicy:(long long)arg1 ;
-(void)systemService:(FBSystemService *)arg1 handleOpenApplicationRequest:(FBSystemServiceOpenApplicationRequest *)arg2 withCompletion:(/*^block*/id)arg3 ;
-(void)_resume;
-(void)applicationProcessWillLaunch:(FBApplicationProcess *)arg1 ;
-(void)applicationProcessDidLaunch:(FBApplicationProcess *)arg1 ;
-(void)_updateFrontMostApplicationEventPort;
-(void)_finishInitialization;
-(void)_updateMedusaEnablementAndNotify:(BOOL)arg1 ;
-(void)_handleTrustedOpenRequestForApplication:(id)arg1 options:(id)arg2 activationSettings:(id)arg3 origin:(id)arg4 withResult:(/*^block*/id)arg5 ;
-(void)_handleOpenApplicationRequest:(id)arg1 options:(id)arg2 activationSettings:(id)arg3 origin:(id)arg4 withResult:(/*^block*/id)arg5 ;
-(id)_validateRequestToOpenApplication:(id)arg1 options:(id)arg2 origin:(id)arg3 error:(out id*)arg4 ;
-(SBMainWorkspaceTransitionRequest *)createRequestWithOptions:(unsigned long long)arg1 ; //12
-(SBMainWorkspaceTransitionRequest *)createRequestForApplicationActivation:(SBDeviceApplicationSceneEntity *)arg1 options:(unsigned long long)arg2 ; //0
-(void)_suspend;
-(void)_resume;
-(BOOL)executeTransitionRequest:(id)arg1 ;
-(void)setCurrentTransaction:(id)arg1 ;
-(id)_transactionForTransitionRequest:(id)arg1 ;
-(void)_noteDidWakeFromSleep;
@end

@interface SBApplicationProcessState : NSObject
@property (nonatomic,readonly) int pid;
@property (getter=isRunning,nonatomic,readonly) BOOL running;
@property (getter=isForeground,nonatomic,readonly) BOOL foreground;
@property (nonatomic,readonly) long long taskState;
@property (nonatomic,readonly) long long visibility;
@property (nonatomic,readonly) BOOL isBeingDebugged;
-(id)_initWithProcess:(id)arg1 stateSnapshot:(id)arg2 ;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) SBApplicationProcessState * processState;
-(void)_setInternalProcessState:(id)arg1 ;
-(NSString *)bundleIdentifier;
-(void)_updateProcess:(id)arg1 withState:(id)arg2 ;
-(void)_processWillLaunch:(id)arg1 ;
-(void)_processDidLaunch:(id)arg1 ;
@end

@interface NCNotificationDispatcher : NSObject
-(void)postNotificationWithRequest:(id)arg1 ;
-(void)destination:(id)arg1 requestsClearingNotificationRequests:(id)arg2 ;
@end

@interface SBNCNotificationDispatcher : NSObject
@property (nonatomic,retain) NCNotificationDispatcher * dispatcher;
@end

@interface SpringBoard : UIApplication
@property (nonatomic,readonly) SBNCNotificationDispatcher * notificationDispatcher;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
-(void)_simulateLockButtonPress;
-(void)_simulateHomeButtonPress;
-(void)takeScreenshot;
-(void)setBatterySaverModeActive:(BOOL)arg1;
-(BOOL)isBatterySaverModeActive;
-(void)showPowerDownAlert;
-(BOOL)isShowingHomescreen;
- (void)setNextAssistantRecognitionStrings:(id)arg1;
-(int)nowPlayingProcessPID;
-(void)launchAppBypassLockScreenForIdentifier:(NSString *)bundleID suspended:(BOOL)suspend withPayloadURL:(NSString *)payloadURL;
-(void)setNowPlayingInfo:(id)arg1 forProcessWithPID:(int)arg2 ;
-(SBApplication *)_accessibilityFrontMostApplication;

@end



@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(id)applicationWithPid:(int)arg1 ;
-(SBApplication *)applicationWithBundleIdentifier:(id)arg1 ;
-(void)applicationVisibilityMayHaveChanged;
@end








@interface RBProcessState : NSObject
@property (nonatomic,copy,readonly) RBSProcessIdentity * identity;
@property (nonatomic,readonly) unsigned char role;
@property (nonatomic,readonly) unsigned char terminationResistance;
-(id)initWithIdentity:(id)arg1 ;
@end

@interface RBMutableProcessState : RBProcessState
-(void)setRole:(unsigned char)arg1;
-(void)setPreventLaunch:(BOOL)arg1 ;
-(void)setTerminationResistance:(unsigned char)arg1 ;
-(void)setIsBeingDebugged:(BOOL)arg1 ;
-(void)setPreventIdleSleep:(BOOL)arg1 ;

@end

@interface RBSProcessState : NSObject
@property (assign,nonatomic) unsigned char taskState;
@property (assign,nonatomic) unsigned char terminationResistance;
@property (getter=isRunning,nonatomic,readonly) BOOL running;
+(id)stateWithProcess:(id)arg1 ;
-(void)setTaskState:(unsigned char)arg1 ;
-(void)setDebugState:(unsigned char)arg1 ;
-(void)setPreventLaunchState:(unsigned char)arg1 ;
-(void)setTerminationResistance:(unsigned char)arg1 ;
-(void)setEndowmentNamespaces:(NSSet *)arg1 ;
-(void)setLegacyAssertions:(NSSet *)arg1 ;
-(void)setPrimitiveAssertions:(NSSet *)arg1 ;
-(unsigned char)preventLaunchState;
-(BOOL)isRunning;
-(BOOL)isEmptyState;
-(NSSet *)endowmentNamespaces;
-(NSSet *)assertions;
-(NSSet *)legacyAssertions;
-(NSSet *)primitiveAssertions;
-(BOOL)isPreventedFromLaunching;
-(void)encodeWithPreviousState:(id)arg1 ;
@end

@interface RBSProcessHandle : NSObject
@property (nonatomic,readonly) RBSProcessState * currentState;
+(id)currentProcess;
-(RBSProcessState *)currentState;
@end

@interface RBProcess : NSObject
@property (nonatomic,copy,readonly) RBSProcessIdentity * identity;
@property (getter=isSuspended,nonatomic,readonly) BOOL suspended;
@property (nonatomic,copy,readonly) RBSProcessHandle * handle;
-(void)setTerminating:(BOOL)arg1 ;
-(id)processPredicate;
-(BOOL)terminateWithContext:(id)arg1 ;
-(void)_lock_suspend;
-(void)_lock_resume;
-(void)_lock_applyRole;
-(void)_applyState:(id)arg1 ;
-(BOOL)_sendSignal:(int)arg1 ;
-(void)invalidate;
-(BOOL)terminateWithContext:(id)arg1 ;
@end

@interface RBDaemon : NSObject
+(id)_sharedInstance;
-(void)assertionManager:(id)arg1 willExpireAssertionsSoonForProcess:(id)arg2 expirationTime:(double)arg3 ;
-(id)_reconnectOriginatorProcess;
@end

@interface RBConcreteTarget : NSObject
+(id)systemTarget;
+(id)targetWithIdentity:(id)arg1 environment:(id)arg2 ;
+(id)targetWithProcess:(id)arg1 environment:(id)arg2 ;
@end

@interface RBBasicProcessConcreteTarget : RBConcreteTarget
-(id)_initWithProcess:(id)arg1 ;
@end

@interface RBSAssertionIdentifier : NSObject
+(id)identifierWithClientPid:(int)arg1 ;
@end

/*
@interface RBAssertion : NSObject
@property (getter=isPersistent,nonatomic,readonly) BOOL persistent;
@property (getter=isActive,nonatomic,readonly) BOOL active;
@property (getter=isSuspended,nonatomic,readonly) BOOL suspended;
@property (getter=isValid,nonatomic,readonly) BOOL invalid;
@property (nonatomic,copy,readonly) RBProcessState * processState;
+(id)assertionWithDescriptor:(id)arg1 target:(id)arg2 originator:(id)arg3 context:(id)arg4 ;
+(id)assertionWithIdentifier:(RBSAssertionIdentifier *)arg1 target:(RBBasicProcessConcreteTarget *)arg2 explanation:(NSString *)arg3 attributes:(NSArray *)arg4 originator:(RBSProcessIdentifier *)arg5 context:(RBAttributeContext *)arg6;
@end
*/

@protocol RBProcessMonitoring <NSObject>
@required
-(void)addObserver:(id)arg1;
-(void)removeObserver:(id)arg1;
-(void)didUpdateProcessStates:(id)arg1;
-(void)removeStateForProcessIdentity:(id)arg1;
-(void)suppressUpdatesForIdentity:(id)arg1;
-(void)unsuppressUpdatesForIdentity:(id)arg1;
-(id)statesMatchingPredicate:(id)arg1;
-(void)didRemoveProcess:(id)arg1 withState:(id)arg2;
-(id)statesMatchingConfiguration:(id)arg1;
-(void)didAddProcess:(id)arg1 withState:(id)arg2;
-(void)trackStateForProcessIdentity:(id)arg1;

@end

@interface RBProcessMonitor : NSObject <RBProcessMonitoring>
+(id)_clientStateForServerState:(id)arg1 process:(id)arg2 ;
-(void)suppressUpdatesForIdentity:(id)arg1 ;
-(void)unsuppressUpdatesForIdentity:(id)arg1 ;
-(void)_queue_updateServerState:(id)arg1 forProcess:(id)arg2 force:(BOOL)arg3 ;
-(void)didUpdateProcessStates:(id)arg1 ;
-(void)_queue_publishState:(id)arg1 forIdentity:(id)arg2 ;
-(void)_queue_suppressUpdatesForIdentity:(id)arg1 ;
-(void)removeStateForProcessIdentity:(id)arg1 ;
@end


@interface RBProcessMap : NSObject
-(unsigned long long)count;
-(void)removeAllObjects;
-(id)dictionary;
-(void)enumerateWithBlock:(/*^block*/id)arg1 ;
-(RBSProcessState *)stateForIdentity:(id)arg1;
-(void)removeIdentity:(id)arg1 ;
-(id)removeStateForIdentity:(id)arg1 ;
-(RBSProcessState *)setState:(RBSProcessState *)arg1 forIdentity:(RBSProcessIdentity *)arg2;
-(id)removeStateForIdentity:(id)arg1 withPredicate:(/*^block*/id)arg2 ;
-(BOOL)containsIdentity:(id)arg1 ;
-(id)allState;
-(void)addIdentity:(id)arg1 ;
-(id)allIdentities;
@end

@interface SBMediaController : NSObject
@property (assign,nonatomic) int nowPlayingProcessPID;
@property (nonatomic,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
+(BOOL)applicationCanBeConsideredNowPlaying:(id)arg1 ;
-(id)init;
-(void)dealloc;
-(BOOL)isPaused;
-(BOOL)isPlaying;
-(BOOL)hasTrack;
-(id)_nowPlayingInfo;
-(void)setNowPlayingInfo:(id)arg1 ;
-(SBApplication *)nowPlayingApplication;
@end

@interface LSBundleProxy : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSURL * dataContainerURL;
@property (nonatomic,readonly) NSURL * bundleContainerURL;
@end

@interface LSApplicationProxy : LSBundleProxy
+ (LSApplicationProxy *)applicationProxyForIdentifier:(id)appIdentifier;
@property(readonly) NSString * applicationIdentifier;
@property(readonly) NSString * bundleVersion;
@property(readonly) NSString * bundleExecutable;
@property(readonly) NSArray * deviceFamily;
@property(readonly) NSURL * bundleContainerURL;
@property(readonly) NSString * bundleIdentifier;
@property(readonly) NSURL * bundleURL;
@property(readonly) NSURL * containerURL;
@property(readonly) NSURL * dataContainerURL;
@property(readonly) NSString * localizedShortName;
@property(readonly) NSString * localizedName;
@property(readonly) NSString * shortVersionString;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)path withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (BOOL)applicationIsInstalled:(NSString *)appIdentifier;
- (NSArray *)allInstalledApplications;
- (NSArray *)allApplications;
- (NSArray *)applicationsOfType:(unsigned int)appType; // 0 for user, 1 for system
@end

@interface SBWakeLogger : NSObject
+(id)sharedInstance;
-(void)_lock_wakeDidBegin:(long long)arg1 ;
-(void)wakeDidBegin:(long long)arg1 ;
-(void)wakeDidEnd;
-(void)lockDidBegin;
@end

@interface BSPowerMonitor : NSObject
+(id)sharedInstance;
@end

@interface PCScheduleSystemWakeOperation : NSOperation {

    BOOL _scheduleOrCancel;
    BOOL _userVisible;
    NSDate* _wakeDate;
    double _acceptableDelay;
    NSString* _serviceIdentifier;
    void* _unqiueIdentifier;

}
-(void)main;
-(id)initForScheduledWake:(BOOL)arg1 wakeDate:(id)arg2 acceptableDelay:(double)arg3 userVisible:(BOOL)arg4 serviceIdentifier:(id)arg5 uniqueIdentifier:(void*)arg6 ;
@end


@interface PCSystemWakeManager : NSObject
+(void)scheduleWake:(BOOL)arg1 wakeDate:(id)arg2 acceptableDelay:(double)arg3 userVisible:(BOOL)arg4 serviceIdentifier:(id)arg5 uniqueIdentifier:(void*)arg6 ;
@end

@interface PCPersistentTimer : NSObject
@property BOOL disableSystemWaking;
- (BOOL)disableSystemWaking;
- (id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (void)invalidate;
- (BOOL)isValid;
- (void)scheduleInRunLoop:(id)arg1;
- (void)setDisableSystemWaking:(BOOL)arg1;
- (id)userInfo;
-(void)setMinimumEarlyFireProportion:(double)arg1 ;
-(void)setEarlyFireConstantInterval:(double)arg1 ;
@end


@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(BOOL)isUILocked;
@end

@interface SBNCScreenController : NSObject
-(void)_turnOnScreenForPocketMode;
-(void)_turnOnScreen;
-(void)setTurnOnScreenForOutOfPocketEvent:(BOOL)arg1 ;
-(void)_createOrResetPowerAssertionWithTimeout:(double)arg1 ;
@end


@interface PowerMonitor : NSObject
+(id)sharedMonitor;
-(void)setSystemIsAsleep:(BOOL)arg1 ;
@end


@interface PCPersistentInterfaceManager : NSObject
+(id)sharedInstance;
-(void)_adjustWakeOnWiFi;
-(BOOL)_wantsWakeOnWiFiEnabled;
-(void)_adjustWakeOnWiFiLocked;
@end


@interface CUPersistentTimer : NSObject
-(void)invalidate;
-(void)_invalidate;
-(NSDate *)date;
-(void)setInvalidationHandler:(id)arg1 ;
-(void)start;
-(double)interval;
-(void)setInterval:(double)arg1 ;
-(id)initWithIdentifier:(id)arg1 ;
-(id)invalidationHandler;
//-(NSObject*<OS_dispatch_queue>)dispatchQueue;
-(void)_start;
-(void)setDate:(NSDate *)arg1 ;
//-(void)setDispatchQueue:(NSObject*<OS_dispatch_queue>)arg1 ;
-(double)leeway;
-(void)setLeeway:(double)arg1 ;
-(void)setRepeating:(BOOL)arg1 ;
-(void)setUseXPC:(BOOL)arg1 ;
-(void)setWakeSystem:(BOOL)arg1 ;
-(void)_startPCPersistentTimer;
-(void)_startXPCActivity;
-(void)_pcTimerFired:(id)arg1 ;
-(void)_xpcTimerFired:(id)arg1 ;
-(BOOL)repeating;
-(id)timerHandler;
-(void)setTimerHandler:(id)arg1 ;
-(BOOL)useXPC;
-(BOOL)wakeSystem;
@end



@interface SBSRelaunchAction : NSObject
@property (nonatomic, readonly) unsigned long long options;
@property (nonatomic, readonly, copy) NSString *reason;
@property (nonatomic, readonly, retain) NSURL *targetURL;
+ (id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (id)initWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (unsigned long long)options;
- (id)reason;
- (id)targetURL;

@end

@interface FBSSystemService : NSObject
+ (id)sharedService;
- (void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2;
@end

@interface MPUMarqueeView : UIView
@property (nonatomic,readonly) UIView * contentView;
@end

@interface MediaControlsHeaderView : UIView
@property (nonatomic,retain) MPUMarqueeView * primaryMarqueeView;
-(void)setPrimaryString:(NSString *)arg1 ;
-(void)setSecondaryString:(NSString *)arg1 ;
-(NSString *)secondaryString;
-(NSString *)primaryString;
-(void)_updateStyle;
-(void)setStyle:(long long)arg1 ;
-(void)_updateRTL;
@end


@interface MRPlatterViewController : UIViewController
@property (nonatomic,retain) MediaControlsHeaderView * nowPlayingHeaderView;
-(id)initWithStyle:(long long)arg1 ;
+(id)coverSheetPlatterViewController;
-(void)setSecondaryStringComponents:(NSMutableArray *)arg1 ;
-(void)_updateSecondaryStringFormat;
@end


@interface MediaControlsCollectionViewController : UIViewController{
        NSMutableDictionary* _activeViewControllers;
}
@end

@interface MediaControlsEndpointController : MediaControlsCollectionViewController
@end

@protocol CCUIContentModule <NSObject>
@property (nonatomic,readonly) MediaControlsEndpointController *contentViewController;
@end

@interface MediaControlsEndpointsViewController : MediaControlsCollectionViewController
@end

@interface MediaControlsAudioModule : NSObject <CCUIContentModule>
@end

@interface CCUIContentModuleContentContainerView : UIView
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,retain) CCUIContentModuleContentContainerView * contentContainerView;
@end

@interface CCUIModuleCollectionViewController : UIViewController
@end

@interface CCUIModularControlCenterViewController : UIViewController
@property (nonatomic,readonly) CCUIModuleCollectionViewController * moduleCollectionViewController;
+(id)_sharedCollectionViewController;
@end

@interface MPCPlayerCommandRequest : NSObject
@property (nonatomic,readonly) unsigned command;
@end

@interface MPButton : UIButton
@end

@interface MediaControlsTransportButton : MPButton
@property (nonatomic,retain) MPCPlayerCommandRequest * touchUpInsideCommandRequest;
@end


@interface FBSSceneSettings : NSObject
@property (nonatomic,readonly) double level;
-(BOOL)isOccluded;
-(BOOL)prefersProcessTaskSuspensionWhileSceneForeground;
-(void)setPrefersProcessTaskSuspensionWhileSceneForeground:(BOOL)arg1 ;
@end

@interface FBSMutableSceneSettings : FBSSceneSettings
@property (assign,nonatomic) long long userInterfaceStyle;
@property (assign,nonatomic) BOOL underLock;
@property (nonatomic,copy) NSArray * occlusions;
@property (assign,getter=isForeground,nonatomic) BOOL foreground;
@property (assign,getter=isBackgrounded,nonatomic) BOOL backgrounded;
@property (assign,nonatomic) double level;
-(void)setForeground:(BOOL)arg1 ;
-(BOOL)isForeground;
-(void)setBackgrounded:(BOOL)arg1 ;
-(void)setUnderLock:(BOOL)arg1 ;
-(void)setDeactivationReasons:(unsigned long long)arg1 ;
-(void)setUserInterfaceStyle:(long long)arg1 ;
-(CGRect)frame;
-(void)setFrame:(CGRect)arg1 ;
-(void)setBackgrounded:(BOOL)arg1 ;
-(void)setIdleModeEnabled:(BOOL)arg1 ;
-(void)setPersistenceIdentifier:(NSString *)arg1 ;
-(id)otherSettings;
-(void)setOcclusions:(NSArray *)arg1;
-(void)setLevel:(double)arg1 ;;
@end

@interface UIMutableApplicationSceneSettings : FBSMutableSceneSettings
@end

@interface FBSSceneSpecification : NSObject
@property (nonatomic,readonly) NSString * uiSceneSessionRole;
@end

@interface FBScene : NSObject
@property (nonatomic,copy,readonly) FBSSceneSpecification * specification;
@property (nonatomic,retain) FBSMutableSceneSettings * mutableSettings;
@property (nonatomic,readonly) long long contentState;
@property (nonatomic,copy,readonly) NSString * identifier;
@property (nonatomic,copy,readonly) NSString * workspaceIdentifier;
@property (nonatomic,readonly) FBSSceneSettings * settings;
@property (nonatomic,readonly) FBProcess * clientProcess;
@property (getter=isValid,nonatomic,readonly) BOOL valid;
-(void)updateUISettingsWithBlock:(/*^block*/id)arg1 ;
-(void)updateSettingsWithBlock:(/*^block*/id)arg1 ;
-(void)_applyUpdateWithContext:(id)arg1 completion:(/*^block*/id)arg2 ;
-(unsigned long long)_beginTransaction;
-(void)_setContentState:(long long)arg1 ;
-(void)updateSettings:(id)arg1 withTransitionContext:(id)arg2 ;
@end

@interface FBSceneManager : NSObject{
    NSMutableDictionary* _scenesByID;
}
+(id)sharedInstance;
+(void)synchronizeChanges:(/*^block*/id)arg1 ;
-(void)_noteSceneChangedLevel:(id)arg1 ;
-(void)_noteSceneMovedToForeground:(id)arg1 ;
-(void)_noteSceneMovedToBackground:(id)arg1 ;
-(id)sceneWithIdentifier:(id)arg1 ;
-(void)_applyMutableSettings:(id)arg1 toScene:(id)arg2 withTransitionContext:(id)arg3 completion:(/*^block*/id)arg4 ;
-(void)destroyScene:(id)arg1 withTransitionContext:(id)arg2 ;
@end


@interface SBUILegibilityLabel : UIView
@property (assign,nonatomic) long long numberOfLines;
@property (nonatomic,copy) NSString * string;
@property (assign,nonatomic) BOOL adjustsFontSizeToFitWidth;
@property (assign,nonatomic) long long lineBreakMode;
@end

@interface SBFLockScreenDateSubtitleView : UIView{
    SBUILegibilityLabel* _label;
}
-(void)setString:(NSString *)arg1 ;
@end

@interface SBFLockScreenDateView : UIView
@property (nonatomic,retain) NSDate * date;
-(void)_updateLabels;
@end

@interface BBObserver : NSObject
@end

@interface SBBulletinLocalObserverGateway : NSObject{
    BBObserver* _bbObserver;
}
+(id)sharedInstance;
@end

@interface BBSectionInfo : NSObject
@property (nonatomic,copy) NSArray * subsections;
@property (nonatomic,copy) NSString * sectionID;
@property (nonatomic,copy) NSString * subsectionID;
@property (assign,nonatomic) BOOL allowsNotifications;
@property (assign,nonatomic) unsigned long long alertType;
@property (assign,nonatomic) BOOL showsOnExternalDevices;
+(id)defaultSectionInfoForType:(long long)arg1 ;
+(id)defaultSectionInfoForSection:(id)arg1 ;
@end

@interface BBImage : NSObject
+(id)imageWithData:(id)arg1 ;
+(id)imageWithPath:(id)arg1 ;
+(id)imageWithName:(id)arg1 inBundlePath:(id)arg2 ;
+(id)imageWithName:(id)arg1 inBundle:(id)arg2 ;
@end

@interface BBBulletin : NSObject
@property (assign,nonatomic) long long sectionSubtype;
@property (nonatomic,readonly) BOOL allowsAutomaticRemovalFromLockScreen;
@property (nonatomic,readonly) BOOL allowsAddingToLockScreenWhenUnlocked;
@property (assign,nonatomic) BOOL preventAutomaticRemovalFromLockScreen;
@property (assign,nonatomic) long long lockScreenPriority;
@property (nonatomic,retain) BBImage *accessoryImage;
@property (nonatomic,copy) NSString * bulletinVersionID;

@end

@interface BBSound : NSObject
-(id)initWithToneAlertConfiguration:(id)arg1 ;
@end

@interface BBAction : NSObject
@property (nonatomic,copy) id internalBlock;
@property (nonatomic,readonly) BOOL hasLaunchAction;
@property (nonatomic,readonly) BOOL hasPluginAction;
@property (nonatomic,readonly) BOOL hasRemoteViewAction;
@property (nonatomic,readonly) BOOL hasInteractiveAction;
@property (assign,nonatomic) long long actionType;
@property (nonatomic,copy) NSString * identifier;
//@property (nonatomic,copy) BBAppearance * appearance;
@property (assign,getter=isAuthenticationRequired,nonatomic) BOOL authenticationRequired;
@property (assign,nonatomic) BOOL shouldDismissBulletin;
@property (nonatomic,copy) NSURL * launchURL;
@property (nonatomic,copy) NSString * launchBundleID;
@property (assign,nonatomic) BOOL launchCanBypassPinLock;
@property (assign,nonatomic) unsigned long long activationMode;
@property (nonatomic,copy) NSString * activatePluginName;
@property (nonatomic,copy) NSDictionary * activatePluginContext;
@property (nonatomic,copy) NSString * remoteViewControllerClassName;
@property (nonatomic,copy) NSString * remoteServiceBundleIdentifier;
@property (assign,nonatomic) long long behavior;
@property (nonatomic,copy) NSDictionary * behaviorParameters;
@property (assign,nonatomic) BOOL canBypassPinLock;
+(id)action;
+(id)actionWithIdentifier:(id)arg1 ;
+(id)actionWithLaunchURL:(id)arg1 callblock:(/*^block*/id)arg2 ;
+(id)actionWithLaunchBundleID:(id)arg1 callblock:(/*^block*/id)arg2 ;
+(id)actionWithCallblock:(/*^block*/id)arg1 ;
+(id)actionWithAppearance:(id)arg1 ;
+(id)actionWithIdentifier:(id)arg1 title:(id)arg2 ;
+(id)actionWithLaunchURL:(id)arg1 ;
+(id)actionWithLaunchBundleID:(id)arg1 ;
+(id)actionWithActivatePluginName:(id)arg1 activationContext:(id)arg2 ;
@end

@interface BBSectionIconVariant : NSObject
@property (nonatomic,copy) NSString * applicationIdentifier;
+(id)_variantWithFormat:(long long)arg1 ;
+(id)variantWithFormat:(long long)arg1 imageData:(id)arg2 ;
+(id)variantWithFormat:(long long)arg1 imagePath:(id)arg2 ;
+(id)variantWithFormat:(long long)arg1 imageName:(id)arg2 inBundle:(id)arg3 ;
@end

@interface BBSectionIcon : NSObject
@property (nonatomic,copy) NSSet * variants;
@end

@interface BBBulletinRequest : BBBulletin
@property (nonatomic,copy) NSString * bulletinID;
@property (nonatomic,retain) NSDate * lastInterruptDate;
@property (nonatomic,retain) NSDate * publicationDate;
@property (nonatomic,copy) NSString * universalSectionID;
@property (nonatomic,copy) NSString * parentSectionID;
@property (assign,nonatomic) long long contentPreviewSetting;
@property (nonatomic,retain) NSDictionary * context;
@property (nonatomic,copy) NSString * unlockActionLabelOverride;
@property (assign,nonatomic) unsigned long long realertCount_deprecated;
@property (nonatomic,copy) NSSet * alertSuppressionAppIDs_deprecated;
@property (nonatomic,copy) NSString * sectionID;
@property (nonatomic,copy) NSSet * subsectionIDs;
@property (nonatomic,copy) NSString * recordID;
@property (nonatomic,copy) NSString * publisherBulletinID;
@property (nonatomic,copy) NSString * dismissalID;
@property (nonatomic,copy) NSString * categoryID;
@property (nonatomic,copy) NSString * threadID;
@property (nonatomic,copy) NSArray * peopleIDs;
@property (assign,nonatomic) long long sectionSubtype;
@property (nonatomic,copy) NSArray * intentIDs;
@property (assign,nonatomic) unsigned long long counter;
@property (nonatomic,copy) NSString * header;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * subtitle;
@property (nonatomic,copy) NSString * message;
//@property (nonatomic,retain) BBContent * modalAlertContent;
@property (nonatomic,copy) NSString * summaryArgument;
@property (assign,nonatomic) unsigned long long summaryArgumentCount;
@property (nonatomic,retain) BBSectionIcon * icon;
@property (assign,nonatomic) BOOL hasCriticalIcon;
@property (assign,nonatomic) BOOL hasEventDate;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,retain) NSDate * endDate;
@property (nonatomic,retain) NSDate * recencyDate;
@property (assign,nonatomic) long long dateFormatStyle;
@property (assign,nonatomic) BOOL dateIsAllDay;
@property (nonatomic,retain) NSTimeZone * timeZone;
//@property (nonatomic,retain) BBAccessoryIcon * accessoryIconMask;
//@property (nonatomic,retain) BBImage * accessoryImage;
@property (assign,nonatomic) BOOL clearable;
@property (nonatomic,retain) BBSound * sound;
@property (assign,nonatomic) BOOL turnsOnDisplay;
//@property (nonatomic,copy) BBAttachmentMetadata * primaryAttachment;
@property (nonatomic,copy) NSArray * additionalAttachments;
@property (assign,nonatomic) BOOL wantsFullscreenPresentation;
@property (assign,nonatomic) BOOL ignoresQuietMode;
@property (assign,nonatomic) BOOL ignoresDowntime;
@property (assign,nonatomic) BOOL preemptsPresentedAlert;
@property (assign,nonatomic) BOOL preemptsSTAR;
@property (nonatomic,copy) NSSet * alertSuppressionContexts;
@property (nonatomic,copy) BBAction * defaultAction;
@property (nonatomic,copy) BBAction * alternateAction;
@property (nonatomic,copy) BBAction * acknowledgeAction;
@property (nonatomic,copy) BBAction * dismissAction;
@property (nonatomic,copy) BBAction * snoozeAction;
@property (nonatomic,copy) BBAction * raiseAction;
@property (nonatomic,copy) BBAction * silenceAction;
@property (nonatomic,copy) NSArray * supplementaryActions;
@property (nonatomic,retain) NSDate * expirationDate;
@property (assign,nonatomic) unsigned long long expirationEvents;                     //@synthesize expirationEvents=_expirationEvents - In the implementation block
@property (nonatomic,copy) BBAction * expireAction;
@property (assign,nonatomic) BOOL usesExternalSync;
@property (assign,getter=isLoading,nonatomic) BOOL loading;
@property (assign,nonatomic) BOOL preventAutomaticRemovalFromLockScreen;
@property (assign,nonatomic) long long lockScreenPriority;
@property (assign,nonatomic) long long backgroundStyle;
@property (nonatomic,copy) NSArray * buttons;
//@property (nonatomic,retain) BBContent * starkBannerContent;
@property (assign,nonatomic) BOOL expiresOnPublisherDeath;
@property (nonatomic,copy) NSString * section;
@property (assign,nonatomic) unsigned long long realertCount;
@property (assign,nonatomic) BOOL showsUnreadIndicator;
@property (assign,nonatomic) BOOL tentative;
@property (assign,nonatomic) long long primaryAttachmentType;
@end


@interface NCBulletinNotificationSource : NSObject
@property (nonatomic,retain) BBObserver * observer;
@property (nonatomic,retain) NCNotificationDispatcher * dispatcher;
-(id)initWithDispatcher:(id)arg1 ;
@end


@interface TLAlertConfiguration : NSObject
@end

@interface UNNotificationIcon : NSObject
+(id)iconAtPath:(id)arg1 ;
+(id)iconNamed:(id)arg1 ;
+(id)iconForApplicationIdentifier:(id)arg1 ;
@end

@interface UNMutableNotificationContent (Private)
@property (nonatomic,copy) UNNotificationIcon * icon;
@property (nonatomic,copy) NSString * accessoryImageName;
@property (nonatomic,copy,readonly) NSString * categoryIdentifier;
@end

@interface UNNotificationRequest (Private)
@property (assign,nonatomic) unsigned long long destinations;
@property (nonatomic,copy,readonly) NSString * identifier;
@property (nonatomic,copy,readonly) UNNotificationContent * content;
@property (nonatomic,copy,readonly) UNNotificationTrigger * trigger;
+(id)requestWithIdentifier:(id)arg1 content:(id)arg2 trigger:(id)arg3 ;
+(id)requestWithIdentifier:(id)arg1 content:(id)arg2 trigger:(id)arg3 destinations:(unsigned long long)arg4 ;
+(id)requestWithIdentifier:(id)arg1 pushPayload:(id)arg2 bundleIdentifier:(id)arg3 ;
@end

@interface NCNotificationOptions : NSObject
@end

@interface NCMutableNotificationOptions : NCNotificationOptions
@property (assign,nonatomic) BOOL alertsWhenLocked;
@property (assign,nonatomic) BOOL addToLockScreenWhenUnlocked;
@property (assign,nonatomic) unsigned long long lockScreenPersistence;
@property (assign,nonatomic) unsigned long long lockScreenPriority;
@property (assign,nonatomic) BOOL canTurnOnDisplay;
@property (assign,nonatomic) BOOL overridesPocketMode;
@property (assign,nonatomic) BOOL dismissAutomatically;
@property (assign,nonatomic) BOOL dismissAutomaticallyForCarPlay;
@end

@interface NCNotificationContent : NSObject
@end

@interface NCMutableNotificationContent : NCNotificationContent
@property (nonatomic,copy) NSString * header;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * subtitle;
@property (nonatomic,copy) NSString * message;
@property (nonatomic,copy) NSString * hiddenPreviewsBodyPlaceholder;
@property (nonatomic,copy) NSString * categorySummaryFormat;
@property (nonatomic,copy) NSString * summaryArgument;
@property (assign,nonatomic) unsigned long long summaryArgumentCount;
@property (nonatomic,retain) UIImage * icon;
@property (nonatomic,retain) NSArray * icons;
@property (nonatomic,retain) UIImage * carPlayIcon;
@property (nonatomic,retain) NSArray * carPlayIcons;
@property (nonatomic,retain) UIImage * attachmentImage;
@property (nonatomic,retain) NSDate * date;
@property (assign,getter=isDateAllDay,nonatomic) BOOL dateAllDay;
@end

@protocol NCNotificationActionRunner <NSObject>
@property (assign,nonatomic) BOOL shouldForwardAction;
@required
-(void)executeAction:(id)arg1 fromOrigin:(id)arg2 endpoint:(id)arg3 withParameters:(id)arg4 completion:(/*^block*/id)arg5;
-(BOOL)shouldForwardAction;
-(void)setShouldForwardAction:(BOOL)arg1;

@end


@interface NCNotificationAction : NSObject
+(id)notificationActionForAction:(id)arg1 bulletin:(id)arg2 observer:(id)arg3 ;
@end

@interface NCMutableNotificationAction : NCNotificationAction
@property (nonatomic,copy) NSString * identifier;
@property (nonatomic,copy) NSString * title;
@property (assign,nonatomic) unsigned long long activationMode;
@property (nonatomic,copy) NSURL * launchURL;
@property (nonatomic,copy) NSString * launchBundleID;
@property (assign,nonatomic) unsigned long long behavior;
@property (nonatomic,copy) NSDictionary * behaviorParameters;
@property (assign,nonatomic) BOOL requiresAuthentication;
@property (nonatomic,retain) id<NCNotificationActionRunner> actionRunner;
@property (assign,getter=isDestructiveAction,nonatomic) BOOL destructiveAction;
@property (assign,nonatomic) BOOL shouldDismissNotification;
@end

@interface NCNotificationSound : NSObject
@end

@interface NCMutableNotificationSound : NCNotificationSound
@property (assign,nonatomic) long long soundType;
@property (assign,nonatomic) unsigned systemSoundID;
@property (assign,nonatomic) unsigned long long soundBehavior;
@property (nonatomic,copy) NSString * ringtoneName;
@property (nonatomic,copy) NSDictionary * vibrationPattern;
@property (assign,getter=isRepeating,nonatomic) BOOL repeats;
@property (assign,nonatomic) double maxDuration;
@property (nonatomic,copy) NSDictionary * controllerAttributes;
@property (nonatomic,copy) NSString * songPath;
@property (nonatomic,copy) TLAlertConfiguration * alertConfiguration;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic,readonly) BBBulletin * bulletin;
@property (nonatomic,copy,readonly) NSString * sectionIdentifier;
@property (nonatomic,copy,readonly) NSString * notificationIdentifier;
@property (nonatomic,readonly) NSDate * timestamp;
@property (nonatomic,readonly) NCNotificationOptions * options;
@property (nonatomic,readonly) NCNotificationContent * content;
+(id)notificationRequest;
+(id)notificationRequestForBulletin:(id)arg1 observer:(id)arg2 sectionInfo:(id)arg3 feed:(unsigned long long)arg4 ;
+(id)notificationRequestForBulletin:(id)arg1 observer:(id)arg2 sectionInfo:(id)arg3 feed:(unsigned long long)arg4 playLightsAndSirens:(BOOL)arg5 ;
@end

@interface NCMutableNotificationRequest : NCNotificationRequest
@property (nonatomic,copy) NSString * sectionIdentifier;
@property (nonatomic,copy) NSString * notificationIdentifier;
@property (nonatomic,copy) NSString * threadIdentifier;
@property (nonatomic,copy) NSString * categoryIdentifier;
@property (nonatomic,copy) NSSet * subSectionIdentifiers;
@property (nonatomic,copy) NSString * highestPrioritySubSectionIdentifier;
@property (nonatomic,copy) NSArray * intentIdentifiers;
@property (nonatomic,copy) NSArray * peopleIdentifiers;
@property (nonatomic,copy) NSString * parentSectionIdentifier;
@property (assign,getter=isUniqueThreadIdentifier,nonatomic) BOOL uniqueThreadIdentifier;
@property (nonatomic,retain) NSDate * timestamp;
@property (nonatomic,copy) NSSet * requestDestinations;
@property (nonatomic,retain) NCNotificationContent * content;
@property (nonatomic,retain) NCNotificationOptions * options;
@property (nonatomic,copy) NSDictionary * context;
@property (nonatomic,copy) NSSet * settingsSections;
@property (nonatomic,retain) NCNotificationSound * sound;
@property (nonatomic,retain) NCNotificationAction * clearAction;
@property (nonatomic,retain) NCNotificationAction * closeAction;
@property (nonatomic,retain) NCNotificationAction * defaultAction;
@property (nonatomic,retain) NCNotificationAction * silenceAction;
@property (nonatomic,copy) NSDictionary * supplementaryActions;
@property (nonatomic,retain) UNNotification * userNotification;
@property (assign,nonatomic) BOOL isCollapsedNotification;
@property (assign,nonatomic) unsigned long long collapsedNotificationsCount;
@property (nonatomic,copy) NSDictionary * sourceInfo;
@property (assign,getter=isCriticalAlert,nonatomic) BOOL criticalAlert;
@end

@interface NCNotificationViewController : UIViewController
-(BOOL)dismissPresentedViewControllerAndClearNotification:(BOOL)arg1 animated:(BOOL)arg2 ;
-(BOOL)dismissPresentedViewControllerAndClearNotification:(BOOL)arg1 animated:(BOOL)arg2 completion:(/*^block*/id)arg3 ;
@end

@interface NCNotificationLongLookViewController : NCNotificationViewController
-(void)dismissViewControllerWithTransition:(int)arg1 completion:(/*^block*/id)arg2 ;
@end


@interface NCNotificationStructuredSectionList : NSObject
@property (nonatomic,readonly) NSArray * allNotificationRequests;
@end

@interface NCNotificationMasterList : NSObject
@property (nonatomic,retain) NSMutableArray * notificationSections;
@end

@protocol NCNotificationStructuredListViewControllerDelegate <UIScrollViewDelegate>
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (nonatomic,retain) NCNotificationMasterList * masterList;
@property (assign,nonatomic) NCNotificationViewController * notificationViewControllerPresentingLongLook;
@property (assign,nonatomic) id<NCNotificationStructuredListViewControllerDelegate> delegate;
-(id)init;
-(void)removeNotificationRequest:(id)arg1 ;
-(void)notificationListComponentRequestsClearingAllNotificationRequests:(id)arg1 ;
-(BOOL)dismissModalFullScreenAnimated:(BOOL)arg1 ;
-(void)setNotificationRequestRemovedWhilePresentingLongLook:(NCNotificationRequest *)arg1 ;
@end


@interface NCBulletinActionRunner : NSObject
-(id)initWithAction:(id)arg1 bulletin:(id)arg2 observer:(id)arg3 ;
@end

@interface BBServer : NSObject
-(id)initWithQueue:(id)arg1 ;
-(void)publishBulletinRequest:(id)arg1 destinations:(unsigned long long)arg2 ;
@end



@interface SBBannerController : NSObject
-(void)dismissBannerWithAnimation:(BOOL)arg1 reason:(long long)arg2 forceEvenIfBusy:(BOOL)arg3 ;
@end

@interface BBResponse : NSObject
@property (nonatomic,copy) NSArray * lifeAssertions;
@property (nonatomic,copy) id sendBlock;
@property (nonatomic,copy) NSString * bulletinID;
@property (assign,nonatomic) long long actionType;
@property (assign,nonatomic) unsigned long long actionActivationMode;
@property (assign,nonatomic) long long actionBehavior;
@property (nonatomic,copy) NSString * buttonID;
@property (nonatomic,copy) NSString * actionID;
@property (nonatomic,copy) NSURL * actionLaunchURL;
@property (nonatomic,copy) NSString * originID;
@property (nonatomic,copy) NSString * replyText;
@property (nonatomic,copy) NSDictionary * context;
@property (assign,nonatomic) BOOL activated;
@property (assign,nonatomic) BOOL didOpenApplication;
@end
