//
//  KWBBLogServer.m
//  Apollo
//
//  Created by cuixuerui on 2019/6/17.
//  Copyright © 2019 cuixuerui.cn. All rights reserved.
//

#import "KWBBLogServer.h"

#if __has_include(<GCDWebServer/GCDWebServer.h>)
#import <GCDWebServer/GCDWebServer.h>
#else
#import "GCDWebServer.h"
#endif
#if __has_include(<GCDWebServer/GCDWebServerDataResponse.h>)
#import <GCDWebServer/GCDWebServerDataResponse.h>
#else
#import "GCDWebServerDataResponse.h"
#endif
#if __has_include(<GCDWebServer/GCDWebServerDataRequest.h>)
#import <GCDWebServer/GCDWebServerDataRequest.h>
#else
#import "GCDWebServerDataRequest.h"
#endif

#import "KWBBPageInfo.h"

#define MAX_LOG_LENGTH  (512 * 1024)
#define APS_LOGSERVER_PORT 8080

@interface KWBBLogServer ()
@property (nonatomic, strong) NSPipe *inputPipe;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSMutableString *logString;
@property (nonatomic, assign) BOOL runging;
@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation KWBBLogServer

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static KWBBLogServer *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inputPipe = [[NSPipe alloc] init];
        _outputPipe = [[NSPipe alloc] init];
        _logString = [[NSMutableString alloc] init];
    }
    return self;
}

- (NSString *)webServerUrl {
    if (_webServer.serverURL != nil) {
        return _webServer.serverURL.absoluteString;
    } else {
        return nil;
    }
}

+ (void)logMsg:(NSString *)msg {
    KWBBLogServer * logServer = [KWBBLogServer shared];
    NSUInteger length = [logServer bytesLengthWithString:logServer.logString];
    if (length > MAX_LOG_LENGTH) {
        [logServer.logString appendString:msg];
        NSUInteger start = logServer.logString.length / 4;
        NSString * suffixString = [logServer.logString substringFromIndex:logServer.logString.length - start];
        logServer.logString = [NSMutableString stringWithString:suffixString];
    } else {
        [logServer.logString appendString:msg];
    }
    [logServer.logString appendFormat:@"\n"];
}

- (void)stop {
    if (!self.runging) return;
    [_webServer stop];
    self.runging = NO;
}

- (void)restart {
    [_webServer startWithPort:APS_LOGSERVER_PORT bonjourName:nil];
    self.runging = YES;
}

- (void)start {
    if (self.runging) return;
    
    self.runging = YES;
    [GCDWebServer setLogLevel:4];
    _webServer = [[GCDWebServer alloc] init];
    [_webServer addDefaultHandlerForMethod:@"GET" requestClass:[GCDWebServerRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        return [[GCDWebServerDataResponse alloc] initWithHTML: pageContent];
    }];
    
    __weak __typeof(self) weakSelf = self;
    [_webServer addHandlerForMethod:@"GET" path:@"/getLog" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (strongSelf.logString != nil) {
            [dict setObject:strongSelf.logString forKey:@"data"];
        }
        return [[GCDWebServerDataResponse alloc] initWithJSONObject:dict];
    }];
    
    [_webServer addHandlerForMethod:@"GET" path:@"/command" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *value = [request.query objectForKey:@"value"];
        
        if (value != nil) {
            NSString *replaceString = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSArray *array = [[replaceString stringByReplacingOccurrencesOfString:@">" withString:@""]
                               componentsSeparatedByString:@" "];
            id value = [strongSelf runcommandWithArray:array];
            if (value != nil) {
                [dict setObject:value forKey:@"data"];
            }
        }
        [dict setObject:@"\n>" forKey:@"terminator"];
        
        return [[GCDWebServerDataResponse alloc] initWithJSONObject:dict];
    }];
    
    [_webServer addHandlerForMethod:@"GET" path:@"/clear" requestClass:[GCDWebServerDataRequest class] processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"\n>" forKey:@"terminator"];
        
        return [[GCDWebServerDataResponse alloc] initWithJSONObject:dict];
    }];
    
    [_webServer startWithPort:APS_LOGSERVER_PORT bonjourName:nil];
    if (_webServer.serverURL == nil) {
        if (_webServer.isRunning) {
            [_webServer stop];
        }
        self.runging = NO;
    }
#ifdef DEBUG
    if (_webServer.serverURL != nil) {
        NSLog(@"使用 %@ 进行连接", _webServer.serverURL.absoluteString);
    } else {
        NSLog(@"服务器启动失败，请检查端口是否被占用");
    }
#endif
    
}

- (id)runcommandWithArray:(NSArray *)commands {
    if (commands.count >= 2) {
        NSString *command = [NSString stringWithFormat:@"%@",commands[0]];
        if ([command isEqualToString:@"sp"]) {
            NSString *subCommand = [[NSString stringWithFormat:@"%@",commands[1]]
                                    stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([subCommand hasPrefix:@"--"] || [subCommand hasPrefix:@"-"]) {
                if ([subCommand isEqualToString:@"--keys"]) {
                    return [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
                             allKeys] description];
                } else if ([subCommand isEqualToString:@"--key"] || [subCommand isEqualToString:@"-k"]) {
                    if (commands.count > 2) {
                        NSString *value = [NSString stringWithFormat:@"%@", commands[2]];
                        id ret = [[NSUserDefaults standardUserDefaults] objectForKey:value];
                        return ret;
                    }
                } else if([subCommand isEqualToString:@"--all"] || [subCommand isEqualToString:@"-a"]) {
                    id all = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
                    return [all description];
                } else if([subCommand isEqualToString:@"--values"]) {
                    return [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
                             allValues] description];
                } else if([subCommand isEqualToString:@"--help"] || [subCommand isEqualToString:@"-h"]) {
                    return [self helpContents];
                }
            }
        }
    }
    return nil;
}

- (NSString *)helpContents {
        return @"\
        \n\
        usage:\
        \n\
            sp --keys: 查看UserDefaults下所有Key\n\
            sp --values: 查看UserDefaults下所有的value\n\
            sp --key [-k] value:通过key == value查询UserDefaults下的value\n\
            clear : 清除当前屏幕\n\
        \n\
    ";
}

- (NSUInteger)bytesLengthWithString:(NSString *)string {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSUInteger length = [string lengthOfBytesUsingEncoding:encoding];
    return length;
}
@end
