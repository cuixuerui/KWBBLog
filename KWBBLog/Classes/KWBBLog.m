//
//  KWBBLog.m
//  Apollo
//
//  Created by apus on 2019/6/17.
//  Copyright © 2019 apus.cuixuerui.com. All rights reserved.
//

#import "KWBBLog.h"
#import "KWBBLogPrivate.h"

void SetBBLogLevel(KWBBLoggerLevel level) {
    [[KWBBLog shared] setLoggerLevel:level];
}

void SetDDWebDisplay(KWBBWebDisplay level) {
    [[KWBBLog shared] setWebDisplayLevel:level];
}

void BBLog(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    KWBBLog *shared = [KWBBLog shared];
    [shared _DDlogWithEnable:shared.loggerLevel <= KWBBLoggerLevelALL flag:nil message:message];
}

void BBDebug(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    KWBBLog *shared = [KWBBLog shared];
    [shared _DDlogWithEnable:shared.loggerLevel <= KWBBLoggerLevelDEBUG flag:@"[DEBUG]" message:message];
}

void BBInfo(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    KWBBLog *shared = [KWBBLog shared];
    [shared _DDlogWithEnable:shared.loggerLevel <= KWBBLoggerLevelINFO flag:@"[INFO]" message:message];
}

void BBWarn(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    KWBBLog *shared = [KWBBLog shared];
    [shared _DDlogWithEnable:shared.loggerLevel <= KWBBLoggerLevelWARN flag:@"[WARN]" message:message];
}

void BBError(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    KWBBLog *shared = [KWBBLog shared];
    [shared _DDlogWithEnable:shared.loggerLevel <= KWBBLoggerLevelERROR flag:@"[ERROR]" message:message];
}

void BBStartService() {
    [[KWBBLog shared] startService];
}

void BBStopService() {
    [[KWBBLog shared] stopService];
}

void BBRestartService() {
    [[KWBBLog shared] restartService];
}

@implementation KWBBLog

+ (instancetype)shared {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loggerLevel = KWBBLoggerLevelALL;
        _webDisplayLevel = KWBBWebDisplayDEBUG;
    }
    return self;
}

- (void)startService {
    if (self.webDisplayLevel <= KWBBWebDisplayALL) {
        [[KWBBLogServer shared] start];
    } else if (self.webDisplayLevel <= KWBBWebDisplayDEBUG) {
        [[KWBBLogServer shared] start];
    }
}

- (void)stopService {
    if (self.webDisplayLevel <= KWBBWebDisplayALL) {
        [[KWBBLogServer shared] stop];
    } else if (self.webDisplayLevel <= KWBBWebDisplayDEBUG) {
        [[KWBBLogServer shared] stop];
    }
}

- (void)restartService {
    if (self.webDisplayLevel <= KWBBWebDisplayALL) {
        [[KWBBLogServer shared] restart];
    } else if (self.webDisplayLevel <= KWBBWebDisplayDEBUG) {
        [[KWBBLogServer shared] restart];
    }
}

- (void)_DDlogWithEnable:(BOOL)enable flag:(NSString *)flag format:(id)format args:(va_list)args {
    if (args == nil) return;
    NSMutableString *message = [NSMutableString stringWithFormat:@"%@", format];
    id object = nil;
    while ((object = va_arg(args, id))) {
        [message appendFormat:@" %@", object];
    }
    
    [self _DDlogWithEnable:enable flag:flag message:message];
}

- (void)_DDlogWithEnable:(BOOL)enable flag:(NSString *)flag message:(NSString *)msg {
    if (enable) {
        if (flag != nil) {
            NSLog(@"%@ %@", flag, msg);
        } else {
            NSLog(@"%@", msg);
        }
        if (self.webDisplayLevel <= KWBBWebDisplayALL) {
            if (flag != nil) {
                NSString *message = [NSString stringWithFormat:@"%@ %@", flag, msg];
                [KWBBLogServer logMsg:message];
            } else {
                [KWBBLogServer logMsg:msg];
            }
        } else if(self.webDisplayLevel <= KWBBWebDisplayDEBUG) {
            if (flag != nil) {
                NSString *message = [NSString stringWithFormat:@"%@ %@", flag, msg];
                [KWBBLogServer logMsg:message];
            } else {
                [KWBBLogServer logMsg:msg];
            }
        }
    }
}

@end
