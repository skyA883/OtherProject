//
//  XHBaseItem.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/2.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBaseItem.h"
#import <objc/runtime.h>

@implementation XHBaseItem

// 反序列化自身包括子类
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
        for (unsigned i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            NSString * propertyName= [NSString stringWithUTF8String:property_getName(property)];
            @try {
                id value = [aDecoder decodeObjectForKey:propertyName];
                [self setValue:value forKey:propertyName];
                //                IDPLogDebug(@"decode: %@ = %@, type[%@]",propertyName, value, [value class]);
            }@catch (NSException *exception) {
                IDPLogWarning(0, @"proprty is not KVC compliant: %@", propertyName);
            }
        }
        free(propertyList);
    }
    return self;
}

// 序列化自身包括子类
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        NSString * propertyName= [NSString stringWithUTF8String:property_getName(property)];
        @try {
            id value = [self valueForKey:propertyName];
            [aCoder encodeObject:value forKey:propertyName];
            //            IDPLogDebug(@"encode: %@ = %@, type[%@]",propertyName, value, [value class]);
        }@catch (NSException *exception) {
            IDPLogWarning(0, @"proprty is not KVC compliant: %@", propertyName);
        }
    }
    free(propertyList);
}

@end
