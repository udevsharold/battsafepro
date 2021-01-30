#import "../common.h"
#import "BSPPowerManager.h"


%hookf(void, xpc_connection_set_event_handler, xpc_connection_t connection, xpc_handler_t handler){
    
    if (connection){
        xpc_handler_t originalHandler = handler;
        handler = ^(xpc_object_t event){
            if (event){
                if (xpc_get_type(event) != XPC_TYPE_ERROR && xpc_get_type(event) == XPC_TYPE_DICTIONARY){
                    xpc_object_t updateChargingStateObject = xpc_dictionary_get_value(event, "BATTSAFEPRO_updateChargingState");
                    xpc_object_t updateSleepingStateObject = xpc_dictionary_get_value(event, "BATTSAFEPRO_updateSleepingState");
                    
                    if (updateChargingStateObject){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[BSPPowerManager sharedInstance] handleUpdateChargingStateMessage:event];
                        });
                    }
                    if (updateSleepingStateObject){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[BSPPowerManager sharedInstance] handleUpdateSleepingStateMessage:event];
                        });
                    }
                    if (updateChargingStateObject || updateSleepingStateObject){
                        return;
                    }
                }
            }
            if (originalHandler)
                originalHandler(event);
        };
    }
    %orig;
}
