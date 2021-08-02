#include <stdio.h>
#import "../NSTask.h"
#import <dlfcn.h>
#import "../common.h"

#define NSLog(FORMAT, ...) fprintf(stdout, "%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define NSLogN(FORMAT, ...) fprintf(stdout, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#define FLAG_PLATFORMIZE (1 << 1)

//extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

// Platformize binary
void platformize_me() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t ptr = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error) return;
    
    ptr(getpid(), FLAG_PLATFORMIZE);
}

// Patch setuid
void patch_setuid() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error) return;
    
    ptr(getpid());
}


void elevateAsRoot(){
    patch_setuid();
    platformize_me();
    setuid(0);
    setuid(0);
    if (getuid() != 0) {
        NSLog(@"%@", @"Failed to elevate as root");
        exit(1);
    }
}

static NSDictionary* runCommand(NSString *cmd){
    if ([cmd length] != 0){
        NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
        taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
        NSTask * task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:taskArgs];
        NSPipe* outputPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        
        NSMutableData *data = [NSMutableData data];
        
        NSFileHandle *stdoutHandle = [outputPipe fileHandleForReading];
        [stdoutHandle waitForDataInBackgroundAndNotify];
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:stdoutHandle queue:nil usingBlock:^(NSNotification *note){
            // This block is called when output from the task is available.
            NSData *dataRead = [stdoutHandle availableData];
            if ([dataRead length] > 0){
                NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
                NSLog(@"%@", stringRead);
                [data appendData:dataRead];
                [stdoutHandle waitForDataInBackgroundAndNotify];
            }
        }];
        
        [task launch];
        //NSData *data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        [task waitUntilExit];
        NSDictionary *result = @{@"exitCode":@([task terminationStatus]), @"stdout":data?:[@"" dataUsingEncoding:NSUTF8StringEncoding]};
        if (observer) [[NSNotificationCenter defaultCenter] removeObserver:observer];
        return result;
    }
    return @{@"exitCode":@0, @"stdout":[@"" dataUsingEncoding:NSUTF8StringEncoding]};
}

int main(int argc, char *argv[], char *envp[]) {
    
    extern char *optarg;
    extern int optind;
    int opt;
    while ((opt = getopt(argc, argv, "spr")) != -1){
        //switch based on option
        switch (opt){
            case 's':{
                elevateAsRoot();
                NSDictionary *result = runCommand(@"killall -9 symptomsd");
                return [result[@"exitCode"] intValue];
                break;
            }
            case 'p':{
                elevateAsRoot();
                NSDictionary *result = runCommand(@"killall -9 powerd");
                return [result[@"exitCode"] intValue];
                break;
            }
            case 'r':{
                //CFDictionaryRef userInfo = (__bridge CFDictionaryRef)@{@"prerming":@YES};
                //CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.udevs.battsafepro.power.monitor"), NULL, userInfo, YES);
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)POWERMONITOR_PRERMING_NOTIFICATION_NAME, NULL, NULL, YES);
                break;
            }
            default:
                break;
        }
    }
    
    //Finish up
    argc -= optind;
    argv += optind;
    
    
    
    //full stdout
    //NSString *stdouString = [[NSString alloc] initWithData:result[@"stdout"] encoding:NSUTF8StringEncoding];
    //if ([stdouString length] > 0) NSLog(@"%@", stdouString);
    
}
