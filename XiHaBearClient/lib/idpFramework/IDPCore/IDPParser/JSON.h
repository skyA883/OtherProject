//
//  JSON.h
//  pppppp
//
//  Created by 冰 周 on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Adds JSON generation to NSArray
@interface NSArray (NSArray_JSONString)

/// Returns a autorelease string containing the receiver encoded in JSON.
- (NSString *)JSONRepresentation;

@end


/// Adds JSON generation to NSDictionary
@interface NSDictionary (NSDictionary_JSONString)

/// Returns a autorelease string containing the receiver encoded in JSON.
- (NSString *)JSONRepresentation;

@end


/// Adds JSON parsing methods to NSString
@interface NSString (NSString_JSONObject)

/// Returns the autorelease NSDictionary or NSArray represented by the receiver's JSON representation, or nil on error
- (id)JSONValue;

@end


/// Adds JSON parsing methods to NSData
@interface NSData (NSData_JSONObject)

/// Returns the autorelease NSDictionary or NSArray represented by the receiver's JSON representation, or nil on error
- (id)JSONValue;

@end

