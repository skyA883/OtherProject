//
//  NSString+IDPExtension.h
//  IDP
//
//  Created by douj on 13-3-6.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IDPExtension)

//将dict转换为 key=value&key2=value2 的字符串追加到str
- (NSString *)urlByAppendingDict:(NSDictionary *)params;

//将变长参数转化为 key=value&key2=value2 的字符串追加到str
- (NSString *)urlByAppendingKeyValues:(id)first, ...;

//将dict转换为 key=value&key2=value2 的字符串
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict;

//将变长参数转化为 key=value&key2=value2 的字符串
+ (NSString *)queryStringFromKeyValues:(id)first, ...;

//将字符串对象中的’<’、’>’、’&’、’\”’分别替换为：”&lt;”、”&gt;” 、”&amp;”、”&quot;”；
+ (NSString *)escapeHTML:(NSString*)string;

//接口将”&lt;”、 ”&gt;” 、”&amp;”、”&quot;”分别替换为’<’、’>’、’&’、’\”’
+ (NSString *)unescapeHTML:(NSString*)string;

//url编码成utf-8 str
- (NSString *)URLEncoding;

//url解码成unicode str
- (NSString *)URLDecoding;

- (NSString *)httpUrlEncoding;

//计算大写 md5
- (NSString *)MD5;
//计算小写 md5
- (NSString *)md5;

//是否是空字符串
- (BOOL)empty;

//转换成data
- (NSData *)UTF8Data;

//获取mac地址
+ (NSString *) macaddress;

//转换#343434 格式颜色
+(UIColor *)colorWithHexString:(NSString *)stringToConvert;

+(int)getIntValue:(id)item;
+(int)getIntegerValue:(id)item;
+(bool)getBoolValue:(id)item;
+(NSString*)getStrValue:(id)item;
+(NSNumber*)getNumValue:(id)item;
+(NSArray*)getArrayValue:(id)item;
+(NSDictionary*)getDicValue:(id)item;
+(double)getDoubleValue:(id)item;

//随机数时间戳+随机数
+(NSString*)getTimeAndRandom;

// 格式化字符
+(NSString*)format:(int)x;
//
+(NSString *)tirmDot:(NSString *)str;

@end
