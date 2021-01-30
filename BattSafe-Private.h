@interface PowerStateRelay : NSObject
@property (assign) double batteryPercentage;
@property (assign) BOOL batteryExternalPowerIsConnected;
@property (assign) BOOL batteryIsCharging;
+(id)defaultRelay;
-(void)setBatteryExternalPowerIsConnected:(BOOL)arg1 ;
-(void)setBatteryPercentage:(double)arg1 ;
@end
