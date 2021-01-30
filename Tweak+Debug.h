#import "common.h"

#define LOG_FILE_PATH [NSString stringWithFormat:@"/var/tmp/%@.log", TWEAK_IDENTIFIER]
#ifdef DEBUG
#define HBL(FORMAT, ...) fullLogging(FORMAT, ##__VA_ARGS__)
#else
#define HBL(FORMAT, ...) HBLogDebug(FORMAT, ##__VA_ARGS__)
#endif

#ifdef DEBUG
void fullLogging(NSString* format, ...);
#endif
