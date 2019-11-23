//
//  APSLogPrivate.h
//  Apollo
//
//  Created by cuixuerui on 2019/6/18.
//  Copyright © 2019 cuixuerui.cn. All rights reserved.
//
#import "KWBBLog.h"
#import "KWBBLogServer.h"
#import <Foundation/Foundation.h>
#ifndef KWBBLogPrivate_h
#define KWBBLogPrivate_h

@interface KWBBLog ()

//- (void)_DDlogWithEnable:(BOOL)enable flag:(NSString *)flag format:(id)format args:(va_list)args;
- (void)_DDlogWithEnable:(BOOL)enable flag:(NSString *)flag message:(NSString *)msg;
@end


#endif /* APSLogPrivate_h */
