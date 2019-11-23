//
//  KWBBLogServer.h
//  Apollo
//
//  Created by cuixuerui on 2019/6/17.
//  Copyright © 2019 cuixuerui.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KWBBLogServer : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)shared;

+ (void)logMsg:(NSString *)msg;
- (void)stop;
- (void)restart;
- (void)start;
- (nullable id)runcommandWithArray:(NSArray *)commands;

@end

NS_ASSUME_NONNULL_END
