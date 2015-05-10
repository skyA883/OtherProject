//
//  HomeModel.h
//  XiHaBearClient
//
//  Created by lcfapril on 15/5/7.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBaseModel.h"
#import "XHHomeItem.h"

@interface HomeModel : XHBaseModel

@property (nonatomic,strong) XHHomeItem *homeData;


- (id)initWithBlock:(XHModelBlock)block;


- (void)getHomeData;

@end
