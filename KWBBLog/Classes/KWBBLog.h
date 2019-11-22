//
//  KWBBLog.h
//  Apollo
//
//  Created by apus on 2019/6/17.
//  Copyright © 2019 apus.cuixuerui.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, KWBBLoggerLevel) {
    KWBBLoggerLevelALL = 0,
    KWBBLoggerLevelDEBUG,
    KWBBLoggerLevelINFO,
    KWBBLoggerLevelWARN,
    KWBBLoggerLevelERROR,
    KWBBLoggerLevelOFF
};

typedef NS_ENUM(NSUInteger, KWBBWebDisplay) {
    KWBBWebDisplayALL = 0,
    KWBBWebDisplayDEBUG,
    KWBBWebDisplayOFF,
};

extern void BBLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
extern void BBDebug(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
extern void BBInfo(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
extern void BBWarn(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
extern void BBError(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

//extern void BBLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

extern void BBStartService(void);
extern void BBStopService(void);
extern void BBRestartService(void);
extern void SetBBLogLevel(KWBBLoggerLevel level);
extern void SetDDWebDisplay(KWBBWebDisplay level);

@interface KWBBLog : NSObject

@property (nonatomic, assign) KWBBLoggerLevel loggerLevel;
@property (nonatomic, assign) KWBBWebDisplay webDisplayLevel;

+ (instancetype)shared;

- (void)startService;
- (void)stopService;
- (void)restartService;

@end

NS_ASSUME_NONNULL_END
