//
//  NSString+FMExtension.m
//
//  NSString+IDPExtension.m
//  IDP
//
//  Created by douj on 13-3-6.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import "NSString+IDPExtension.h"
#import <commoncrypto/CommonDigest.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#pragma mark -

@implementation NSString(IDPExtension)

- (NSString *)URLEncoding
{
	NSString * result = (NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
																			(CFStringRef)self,
																			(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			NULL,
																			kCFStringEncodingUTF8 );
	return [result autorelease];
}


- (NSString *)httpUrlEncoding
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


- (NSString *)URLDecoding
{
	NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
							withString:@" "
							   options:NSLiteralSearch
								 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)MD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
	
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray * pairs = [NSMutableArray array];
	for ( NSString * key in [dict keyEnumerator] )
	{
		if ( !([[dict valueForKey:key] isKindOfClass:[NSString class]]) )
		{
			continue;
		}
		
		NSString * value = [dict objectForKey:key];
		NSString * urlEncoding = [value URLEncoding];
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlEncoding]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)urlByAppendingDict:(NSDictionary *)params
{
    NSURL * parsedURL = [NSURL URLWithString:self];
	NSString * queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString * query = [NSString queryStringFromDictionary:params];
	return [NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query];
}


- (NSString *)urlByAppendingKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
        
		[dict setObject:value forKey:key];
	}
    
	return [self urlByAppendingDict:dict];
}

+ (NSString *)queryStringFromKeyValues:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[dict setObject:value forKey:key];
	}
    
	return [NSString queryStringFromDictionary:dict];
}

- (BOOL)empty
{
	return [self length] > 0 ? NO : YES;
}


+ (NSString *)escapeHTML:(NSString*)string
{
    NSMutableString *newString = [[NSMutableString alloc] initWithString:string];
    
    [newString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    
	return [newString autorelease];
}

+ (NSString *)unescapeHTML:(NSString*)string
{
    //强制检查 以防crash
    if (string == nil || [string isKindOfClass:[NSNull class]])
    {
        return @"";
    }

    NSMutableString *newString = [[NSMutableString alloc] initWithString:string];
    
    [newString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    [newString replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0, [newString length])];
    
	return [newString autorelease];
}

- (NSData *)UTF8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}


+ (NSString *) macaddress {
    
    int mib[6];
    
    size_t len;
    
    char *buf = NULL;
    
    unsigned char *ptr;
    
    struct if_msghdr *ifm;
    
    struct sockaddr_dl *sdl;
    mib[0] = CTL_NET;
    
    mib[1] = AF_ROUTE;
    
    mib[2] = 0;
    
    mib[3] = AF_LINK;
    
    mib[4] = NET_RT_IFLIST;
    
    
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        
        printf("Error: if_nametoindex error/n");
        
        return NULL;
        
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        
        printf("Error: sysctl, take 1/n");
        
        return NULL;
        
    }
    if ((buf = malloc(len)) == NULL) {
        
        printf("Could not allocate memory. error!/n");
        
        return NULL;
        
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
        
    }
    ifm = (struct if_msghdr *)buf;
    
    sdl = (struct sockaddr_dl *)(ifm + 1);
    
    ptr = (unsigned char *)LLADDR(sdl);
    
    // NSString *outstring = [NSString stringWithFormat:@"x:x:x:x:x:x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    
    return [outstring uppercaseString];
}

+(UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return nil;
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


+(int)getIntValue:(id)item
{
    if (item) {
        if ([item isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)item).intValue;
        }
        if ([item isKindOfClass:[NSString class]]) {
            return ((NSString*)item).intValue;
        }
    }
    return 0;
}

+(int)getIntegerValue:(id)item
{
    if (item) {
        if ([item isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)item).integerValue;
        }
        if ([item isKindOfClass:[NSString class]]) {
            return ((NSString*)item).integerValue;
        }
    }
    return 0;
}

+(bool)getBoolValue:(id)item
{
    if (item)
    {
        if ([item isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)item).boolValue;
        }
        if ([item isKindOfClass:[NSString class]]) {
            return ((NSString*)item).boolValue;
        }
        
    }
    return NO;
}
+(NSString*)getStrValue:(id)item
{
    if (item)
    {
        if ([item isKindOfClass:[NSString class]]) {
            return ((NSString*)item);
        }
        if ([item isKindOfClass:[NSNumber class]]) {
            return [(NSNumber *)item stringValue];
        }
    }
    return nil;
}

+(NSNumber*)getNumValue:(id)item
{
    if (item)
    {
        if ([item isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)item);
        }
    }
    return nil;
}
+(NSArray*)getArrayValue:(id)item
{
    if (item)
    {
        if ([item isKindOfClass:[NSArray class]]) {
            return ((NSArray*)item);
        }
    }
    return nil;
}
+(NSDictionary*)getDicValue:(id)item
{
    if (item)
    {
        if ([item isKindOfClass:[NSDictionary class]]) {
            return ((NSDictionary*)item);
        }
    }
    return nil;
}

+(double)getDoubleValue:(id)item{
    if (item) {
        if ([item isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)item).doubleValue;
        }
        if ([item isKindOfClass:[NSString class]]) {
            return ((NSString*)item).doubleValue;
        }
    }
    return 0;
}


+(NSString*)getTimeAndRandom{
    int iRandom=arc4random();
    if (iRandom<0) {
        iRandom=-iRandom;
    }
    
    NSDateFormatter *tFormat=[[[NSDateFormatter alloc] init] autorelease];
    [tFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *tResult=[NSString stringWithFormat:@"%@%d",[tFormat stringFromDate:[NSDate date]],iRandom];
    return tResult;
}


+ (NSString *)format:(int)x {
    NSString *s = [NSString stringWithFormat:@"%@%d",@"",x];
    if (s.length == 1){
        s = [NSString stringWithFormat:@"0%@",s];
    }
    return s;
}


+ (NSString *)tirmDot:(NSString *)str {
    NSRange docRange = [str rangeOfString:@"."];
    IDPLogDebug(@"dot str is %@",str);
    if (docRange.location == NSNotFound) {
        return str;
    }else {
        IDPLogDebug(@"docRange is %d",docRange.location);
        NSString *result = [str substringToIndex:docRange.location];
        IDPLogDebug(@"result is %@",result);
        return result;
    }
}

@end
