//
//
//  NSData+IDPExtension.h
//  IDP
//
//  Created by douj on 13-3-6.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (IDPExtension)

- (NSData *)MD5;
- (NSString *)MD5String;
- (NSString *)UTF8String;

+ (NSData *)dataFromBase64String:(NSString *)base64String;
- (id)initWithBase64String:(NSString *)base64String;
- (NSString *)base64EncodedString;

-(NSArray*)array;
-(NSDictionary*)dictionary;
@end
