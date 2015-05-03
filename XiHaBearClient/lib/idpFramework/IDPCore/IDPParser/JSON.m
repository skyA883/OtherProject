//
//  JSON.m
//  pppppp
//
//  Created by 冰 周 on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "JSON.h"
#import "JSONKit.h"

@implementation NSArray (NSArray_JSONString)

- (NSString *)JSONRepresentation
{
    if ([self isEqual:[NSNull null]] || !self) {
        return nil;
    }
    
    NSError *error = nil;
    
    NSString *json = [self JSONStringWithOptions:JKParseOptionStrict error:&error];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", [error localizedDescription]);
    return json;
}

@end



@implementation NSDictionary (NSDictionary_JSONString)

- (NSString *)JSONRepresentation
{
    if ([self isEqual:[NSNull null]] || !self) {
        return nil;
    }
    
    NSError *error = nil;
    
    NSString *json = [self JSONStringWithOptions:JKParseOptionStrict error:&error];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", [error localizedDescription]);
    return json;
}

@end



@implementation NSString (NSString_JSONObject)

- (id)JSONValue
{
    if ([self isEqual:[NSNull null]] || !self || ![self length]) {
        return nil;
    }
    
    NSError *error = nil;
    
    id repr = [self objectFromJSONStringWithParseOptions:JKParseOptionStrict error:&error];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", [error localizedDescription]);
    return repr;
}

@end



@implementation NSData (NSData_JSONObject)

- (id)JSONValue
{
    if ([self isEqual:[NSNull null]] || !self || ![self length]) {
        return nil;
    }

    NSError *error = nil;
    
    id repr = [self objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&error];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", [error localizedDescription]);
    return repr;
}

@end
