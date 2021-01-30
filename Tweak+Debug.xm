#import "common.h"
#import "NSTask.h"
#import "Tweak+Debug.h"
#import <sys/utsname.h>

#ifdef DEBUG

#define STRINGIZE(x) #x
#define STRINGIZE_VALUE_OF(x) STRINGIZE(x)

static NSString* deviceName(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

static NSString* version(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.version
                              encoding:NSUTF8StringEncoding];
}

static NSString* iosVersion(){
    return [[UIDevice currentDevice] systemVersion];
}

static NSString* release(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.release
                              encoding:NSUTF8StringEncoding];
}

static NSString* systemName(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.sysname
                              encoding:NSUTF8StringEncoding];
}

static NSDateFormatter* dateFormatter(){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZZ"];
    return dateFormatter;
}

/*
static NSString* localTime(NSDate *date){
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    return [dateFormatter() stringFromDate:[NSDate dateWithTimeInterval:seconds sinceDate:date]];
}
*/

static NSString* globalTime(NSDate *date){
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate:date];
    return [dateFormatter() stringFromDate:[NSDate dateWithTimeInterval:seconds sinceDate:date]];
}


static void writeToLogFile(NSString* content){
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE_PATH];
    NSString *dateNow = globalTime([NSDate date]);
    if (fileHandle){
        content = [NSString stringWithFormat:@"%@ %@\n", dateNow, content];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        content = [NSString stringWithFormat:@"Package: %@, %@\nDevice: %@, %@\nRelease: %@\nVersion: %@\nSystem: %@\n\n%@ %@\n", TWEAK_IDENTIFIER, [NSString stringWithUTF8String:STRINGIZE_VALUE_OF(TWEAKVERSION)], deviceName(), iosVersion(), release(), version(), systemName(), dateNow, content];
        [content writeToFile:LOG_FILE_PATH
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
}

void fullLogging(NSString* format, ...){
    va_list args;
    va_start(args, format);
    NSString *argsString = [[NSString alloc] initWithFormat:format arguments:args];
    writeToLogFile(argsString);
    HBLogDebug(@"%@", argsString);
    va_end(args);
}
#endif
