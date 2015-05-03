//
//  IDPAFRequestManager.h
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "IDPAFHttpCmd.h"

@interface IDPAFRequestManager : AFHTTPRequestOperationManager


@property (nonatomic, retain) NSMutableArray *cmds;

+ (IDPAFRequestManager *)sharedInstance;

- (BOOL)processCommand:(IDPAFHttpCmd *)cmd;

@end
