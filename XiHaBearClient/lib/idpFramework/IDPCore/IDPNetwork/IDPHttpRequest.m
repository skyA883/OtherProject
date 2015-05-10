//
//  IPDHttpRequest.m
//  iPadClient
//
//  Created by zhong on 12-12-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "ASIFormDataRequest.h"
#import "IDPHttpRequest.h"
#import "IDPSingleton.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDataDecompressor.h"
#pragma mark -

#undef	DEFAULT_GET_TIMEOUT
#define DEFAULT_GET_TIMEOUT			(30.0f)			// 取图30秒超时

#undef	DEFAULT_POST_TIMEOUT
#define DEFAULT_POST_TIMEOUT		(30.0f)			// 发协议30秒超时

#undef	DEFAULT_UPLOAD_TIMEOUT
#define DEFAULT_UPLOAD_TIMEOUT		(120.0f)		// 上传图片120秒超时

#pragma mark -

@implementation NSObject(IDPRequestResponder)

- (BOOL)isRequestResponder{
	if ( [self respondsToSelector:@selector(handleRequest:)] ){
		return YES;
	}
	
	return NO;
}

- (IDPHttpRequest *)GET:(NSString *)url{
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue GET:url];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}
}

- (IDPHttpRequest *)POST:(NSString *)url dict:(NSDictionary *)kvs
{
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue POST:url params:kvs];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}
}

- (IDPHttpRequest *)POST:(NSString *)url params:(id)first, ...{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; ){
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[dict setObject:value forKey:key];
	}
    
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue POST:url params:dict];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}
}

- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files dict:(NSDictionary *)kvs{
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue POST:url files:files params:kvs];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}	
}


- (IDPHttpRequest *)POST:(NSString *)url json:(NSArray *)jsonDict {
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue POST:url json:jsonDict];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}
}


- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(id)first, ...
{
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; ){
		NSObject<NSCopying> * key = [dict count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[dict setObject:value forKey:key];
	}
    
	if ( [self isRequestResponder] ){
		IDPHttpRequest * request = [IDPHttpRequestQueue POST:url files:files params:dict];
		request.responder = self;
		return request;
	}
	else{
		return nil;
	}	
}

- (BOOL)requestingURL{
	if ( [self isRequestResponder] ){
		return [IDPHttpRequestQueue requesting:nil byResponder:self];
	}
	else{
		return NO;
	}		
}

- (BOOL)requestingURL:(NSString *)url{
	if ( [self isRequestResponder] ){
		return [IDPHttpRequestQueue requesting:url byResponder:self];
	}
	else{
		return NO;
	}			
}

- (NSArray *)requests{
	return [IDPHttpRequestQueue requests:nil byResponder:self];
}

- (NSArray *)requests:(NSString *)url{
	return [IDPHttpRequestQueue requests:url byResponder:self];
}

- (void)cancelRequests{
	if ( [self isRequestResponder] ){
		[IDPHttpRequestQueue cancelRequestByResponder:self];
	}
}

- (void)handleRequest:(IDPHttpRequest *)request{
}

@end


#pragma mark -

@interface IDPHttpRequest(Private)
- (void)updateSendProgress;
- (void)updateRecvProgress;
@end

@implementation IDPHttpRequest

@synthesize state = _state;
@synthesize errorCode = _errorCode;
@synthesize responder = _responder;

@synthesize blockReqCallback = _blockReqCallback;
@synthesize paramHookBlock   = _paramHookBlock;

@synthesize initTimeStamp = _initTimeStamp;
@synthesize sendTimeStamp = _sendTimeStamp;
@synthesize recvTimeStamp = _recvTimeStamp;
@synthesize doneTimeStamp = _doneTimeStamp;

@synthesize sendProgressed = _sendProgressed;
@synthesize recvProgressed = _recvProgressed;

- (id)initWithURL:(NSURL *)newURL{
	self = [super initWithURL:newURL];
	if (self){
		_state = IDP_REQUEST_STATE_CREATED;
		_errorCode = 0;
		
		self.blockReqCallback = nil;
		_sendProgressed = NO;
		_recvProgressed = NO;
		
		_initTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		_sendTimeStamp = _initTimeStamp;
		_recvTimeStamp = _initTimeStamp;	
		_doneTimeStamp = _initTimeStamp;
	}
	return self;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"%@ %@, state ==> %d, %d/%d",
			self.requestMethod, [self.url absoluteString],
			self.state,
			[self uploadBytes], [self downloadBytes]];
}

- (void)dealloc{
	self.blockReqCallback = nil;
	self.paramHookBlock   = nil;
    [super dealloc];
}

- (NSUInteger)uploadBytes{
	return self.postLength;
}

- (NSUInteger)uploadTotalBytes{
	return self.postLength;
}

- (NSUInteger)downloadBytes{
	return [[self rawResponseData] length];
}

- (NSUInteger)downloadTotalBytes{
	return self.contentLength;	
}

- (void)changeState:(IDPRequestStateEnum)state{
	if ( state != _state ){
		_state = state;
		
		if ( IDP_REQUEST_STATE_SENDING == _state ){
			_sendTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		}
		else if ( IDP_REQUEST_STATE_RECVING == _state ){
			_recvTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		}
		else if ( IDP_REQUEST_STATE_FAILED == _state || IDP_REQUEST_STATE_SUCCEED == _state || IDP_REQUEST_STATE_CANCELLED == _state ){
			_doneTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		}
		
        if ( [_responder isRequestResponder] ){
            [_responder handleRequest:self];
        }
		
		if (self.blockReqCallback){
			self.blockReqCallback(self);
		}
	}
}

- (void)updateSendProgress{
	_sendProgressed = YES;
	
	if ( [_responder isRequestResponder] ){
		[_responder handleRequest:self];
	}
	
	if ( self.blockReqCallback ){
		self.blockReqCallback(self);
	}
	_sendProgressed = NO;
}

- (void)updateRecvProgress{
	_recvProgressed = YES;
	
	if ( [_responder isRequestResponder] ){
		[_responder handleRequest:self];
	}
	
	if (self.blockReqCallback){
		self.blockReqCallback(self);
	}
	_recvProgressed = NO;
}

- (NSTimeInterval)timeCostPending{
	return _sendTimeStamp - _initTimeStamp;
}

- (NSTimeInterval)timeCostOverDNS{
	return _recvTimeStamp - _sendTimeStamp;
}

- (NSTimeInterval)timeCostRecving{
	return _doneTimeStamp - _recvTimeStamp;
}

- (NSTimeInterval)timeCostOverAir{
	return _doneTimeStamp - _sendTimeStamp;
}

@end

#pragma mark -

@interface IDPHttpRequestQueue(Private)
- (void)cancelRequest:(IDPHttpRequest *)request;
- (void)cancelRequestByResponder:(id)responder;
- (void)cancelAllRequests;

- (NSArray *)requests:(NSString *)url byResponder:(id)responder;
- (BOOL)requesting:(NSString *)url byResponder:(id)responder;
- (BOOL)requesting:(NSString *)url;

- (IDPHttpRequest *)GET :(NSString *)url sync:(BOOL)sync;
- (IDPHttpRequest *)POST:(NSString *)url params:(NSDictionary *)kvs sync:(BOOL)sync;
- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(NSDictionary *)kvs sync:(BOOL)sync;
- (IDPHttpRequest *)POST:(NSString *)url json:(id)jsonDict sync:(BOOL)sync;
- (NSMutableDictionary *)requestCommonParam:(IDPHttpRequest*)request;
@end

@implementation IDPHttpRequestQueue

@synthesize online        = _online;
@synthesize bytesUpload   = _bytesUpload;
@synthesize bytesDownload = _bytesDownload;

@synthesize delay         = _delay;
@synthesize requests      = _requests;

@synthesize blockReqCallback = _blockReqCallback;
@synthesize paramHookBlock   = _paramHookBlock;

+ (BOOL)isReachableViaWIFI{
	return YES;
}

+ (BOOL)isReachableViaWLAN{
	return YES;
}

+ (BOOL)isNetworkInUse{
	return ([[IDPHttpRequestQueue sharedInstance].requests count] > 0) ? YES : NO;
}

+ (NSUInteger)bandwidthUsedPerSecond{
	return [ASIHTTPRequest averageBandwidthUsedPerSecond];
}

+ (IDPHttpRequestQueue *)sharedInstance{
	static IDPHttpRequestQueue * __sharedInstance = nil;
    
	@synchronized(self)
    {
		if ( nil == __sharedInstance ){
			__sharedInstance = [[IDPHttpRequestQueue alloc] init];
			[ASIHTTPRequest setDefaultUserAgentString:@"IDP"];			
			[[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:10];
		}
	}
	
	return (IDPHttpRequestQueue *)__sharedInstance;
}

- (id)init{
	self = [super init];
	if ( self ){
		_delay = 0.1f;
		_online = YES;
		_requests = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)setOnline:(BOOL)on{
	_online = on;
    
	if ( NO == _online ){
		[self cancelAllRequests];
	}
}

- (void)dealloc{
	[self cancelAllRequests];
    
	[_requests removeAllObjects];
	[_requests release];
    
	self.blockReqCallback = nil;
    self.paramHookBlock   = nil;
	[super dealloc];
}


+ (IDPHttpRequest *)POST:(NSString *)url json:(id)jsonDict {
    return [[IDPHttpRequestQueue sharedInstance] POST:url json:jsonDict sync:NO];
}

- (IDPHttpRequest *)POST:(NSString *)url json:(id)jsonDict sync:(BOOL)sync {
    if ( NO == _online )
		return nil;
    
	IDPHttpRequest * request = nil;
    
	request = [[IDPHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
	request.timeOutSeconds = DEFAULT_UPLOAD_TIMEOUT;
	request.requestMethod = @"POST";
	request.postFormat = ASIMultipartFormDataPostFormat;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request setDelegate:self];
	[request setDownloadProgressDelegate:self];
	[request setUploadProgressDelegate:self];
	[request setNumberOfTimesToRetryOnTimeout:2];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif	// #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	
	[request setThreadPriority:1.0];
	[request setQueuePriority:NSOperationQueuePriorityHigh];
	
    // param hook handle
    NSMutableDictionary* commParam = [self requestCommonParam:request];
	if (commParam) {
		NSArray * Commkeys = [commParam allKeys];
		for ( NSString * key in Commkeys ){
			[request setPostValue:[commParam objectForKey:key] forKey:key];
		}
	}
    if (jsonDict) {
        NSError *error = nil;
        //NSJSONWritingPrettyPrinted:指定生成的JSON数据应使用空格旨在使输出更加可读。如果这个选项是没有设置,最紧凑的可能生成JSON表示。
        NSData *jsonData = [NSJSONSerialization
                            dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        if ([jsonData length] > 0 && error == nil){
            IDPLogDebug(@"Successfully serialized the dictionary into data.");
            //NSData转换为String
            NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
            [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
            IDPLogDebug(@"JSON String = %@", jsonString);
        }
        else if ([jsonData length] == 0 &&
                 error == nil){
            IDPLogDebug(@"No data was returned after serialization.");
        }
        else if (error != nil){
            IDPLogDebug(@"An error happened = %@", error);
        }
    }
	[_requests addObject:request];
	
	if (sync){
		[request startSynchronous];
	}else{
		if (_delay){
			[request performSelector:@selector(startAsynchronous)
						  withObject:nil
						  afterDelay:_delay];
		}else{
			[request startAsynchronous];
		}
	}
	
	return [request autorelease];
}


+ (IDPHttpRequest *)GET:(NSString *)url{
	return [[IDPHttpRequestQueue sharedInstance] GET:url sync:NO];
}

- (IDPHttpRequest *)GET:(NSString *)url sync:(BOOL)sync{
	if ( NO == _online )
		return nil;
    
	IDPHttpRequest * request = nil;
    
	request = [[IDPHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
	request.timeOutSeconds = DEFAULT_GET_TIMEOUT;
	request.requestMethod = @"GET";
	request.postBody = nil;
	[request setDelegate:self];
	[request setDownloadProgressDelegate:self];
	[request setUploadProgressDelegate:self];
	[request setNumberOfTimesToRetryOnTimeout:2];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif	// #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    
	[request setThreadPriority:0.5];
	[request setQueuePriority:NSOperationQueuePriorityLow];
    
	[_requests addObject:request];
	
	if ( sync ){
		[request startSynchronous];
	}
	else{
		if ( _delay ){
			[request performSelector:@selector(startAsynchronous)
						  withObject:nil
						  afterDelay:_delay];		
		}
		else{
			[request startAsynchronous];
		}
	}
    
	return [request autorelease];
}


+ (IDPHttpRequest *)POST:(NSString *)url params:(NSDictionary *)kvs{
	return [[IDPHttpRequestQueue sharedInstance] POST:url params:kvs sync:NO];
}

- (IDPHttpRequest *)POST:(NSString *)url params:(NSDictionary *)kvs sync:(BOOL)sync{
	if ( NO == _online )
		return nil;
    
	IDPHttpRequest * request = nil;
    
	request = [[IDPHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
	request.timeOutSeconds = DEFAULT_POST_TIMEOUT;
	request.requestMethod = @"POST";
	request.postFormat = ASIMultipartFormDataPostFormat;
	[request setDelegate:self];
	[request setDownloadProgressDelegate:self];
	[request setUploadProgressDelegate:self];
	[request setNumberOfTimesToRetryOnTimeout:2];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif	// #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	
	[request setThreadPriority:1.0];
	[request setQueuePriority:NSOperationQueuePriorityHigh];
	
	NSArray * keys = [kvs allKeys];
	for ( NSString * key in keys ){
		[request setPostValue:[kvs objectForKey:key] forKey:key];
	}
	
    // param hook handle
    NSMutableDictionary* commParam = [self requestCommonParam:request];
	if (commParam) {
		NSArray * Commkeys = [commParam allKeys];
		for ( NSString * key in Commkeys ){
			[request setPostValue:[commParam objectForKey:key] forKey:key];
		}
	}
    

	[_requests addObject:request];
    
	if ( sync ){
		[request startSynchronous];
	}else{
		if ( _delay ){
			[request performSelector:@selector(startAsynchronous)
						  withObject:nil
						  afterDelay:_delay];
		}else{
			[request startAsynchronous];			
		}
	}
	
	return [request autorelease];
}

+ (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(NSDictionary *)kvs{
	return [[IDPHttpRequestQueue sharedInstance] POST:url files:files params:kvs sync:NO];
}

//chj add
- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(NSDictionary *)kvs sync:(BOOL)sync{
	if ( NO == _online )
		return nil;
	IDPHttpRequest * request = nil;
    //request.HEADRequest addRequestHeader:<#(NSString *)#> value:<#(NSString *)#>
	request = [[IDPHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
	request.timeOutSeconds = DEFAULT_UPLOAD_TIMEOUT;
	request.requestMethod = @"POST";
	request.postFormat = ASIMultipartFormDataPostFormat;
	[request setDelegate:self];
	[request setDownloadProgressDelegate:self];
	[request setUploadProgressDelegate:self];
	[request setNumberOfTimesToRetryOnTimeout:2];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif	// #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	
	[request setThreadPriority:1.0];
	[request setQueuePriority:NSOperationQueuePriorityHigh];
	
	if (kvs){
		NSArray * keys = [kvs allKeys];
		for ( NSString * key in keys ){
            if([key isEqualToString:@"sign"]){
                NSString* signStr = [NSString stringWithFormat:@"%@", [kvs objectForKey:key]];
                [request addRequestHeader:@"sign" value:signStr];
            }
            else{
                [request setPostValue:[kvs objectForKey:key] forKey:key];
            }
		}
	}
    
    // param hook handle
    NSMutableDictionary* commParam = [self requestCommonParam:request];
	if (commParam) {
		NSArray * Commkeys = [commParam allKeys];
		for ( NSString * key in Commkeys ){
			[request setPostValue:[commParam objectForKey:key] forKey:key];
		}
	}
    

    NSData* imgData = nil;
	if (files){
		NSArray * fileNames = [files allKeys];
		for ( NSInteger i = 0; i < [fileNames count]; ++i ){
			NSString * fileName = [fileNames objectAtIndex:i];
			NSObject * fileData = [files objectForKey:fileName];
            
			if (fileName && fileData){
                if ([fileData isKindOfClass:[NSData class]]){
					imgData = (NSData *)fileData;
                    [request setData:imgData withFileName:fileName andContentType:@"image/jpeg" forKey:@"upfile"];
                }
			}
		}
	}
    
	[_requests addObject:request];
	
	if (sync){
		[request startSynchronous];
	}else{
		if (_delay){
			[request performSelector:@selector(startAsynchronous)
						  withObject:nil
						  afterDelay:_delay];
		}else{
			[request startAsynchronous];
		}
	}
	
	return [request autorelease];
}

- (NSMutableDictionary *)requestCommonParam:(IDPHttpRequest*)request {
	if (self.paramHookBlock && request) {
		return self.paramHookBlock(request);
	}	
	return nil;
}


+ (BOOL)requesting:(NSString *)url{
	return [[IDPHttpRequestQueue sharedInstance] requesting:url];
}

- (BOOL)requesting:(NSString *)url{
	for ( IDPHttpRequest * request in _requests ){
		if ( [[request.url absoluteString] isEqualToString:url] ){
			return YES;
		}			
	}
    
	return NO;
}

+ (BOOL)requesting:(NSString *)url byResponder:(id)responder{
	return [[IDPHttpRequestQueue sharedInstance] requesting:url byResponder:responder];
}

- (BOOL)requesting:(NSString *)url byResponder:(id)responder{
	for ( IDPHttpRequest * request in _requests ){
		if ( responder && request.responder != responder )
			continue;
        
		if ( nil == url || [[request.url absoluteString] isEqualToString:url] ){
			return YES;
		}			
	}
    
	return NO;
}

+ (NSArray *)requests:(NSString *)url{
	return [[IDPHttpRequestQueue sharedInstance] requests:url];
}

- (NSArray *)requests:(NSString *)url{
	NSMutableArray * array = [NSMutableArray array];
	
	for ( IDPHttpRequest * request in _requests ){
		if ( [[request.url absoluteString] isEqualToString:url] ){
			[array addObject:request];
		}			
	}
	
	return array;
}

+ (NSArray *)requests:(NSString *)url byResponder:(id)responder{
	return [[IDPHttpRequestQueue sharedInstance] requests:url byResponder:responder];
}

- (NSArray *)requests:(NSString *)url byResponder:(id)responder{
	NSMutableArray * array = [NSMutableArray array];
    
	for ( IDPHttpRequest * request in _requests ){
		if ( responder && request.responder != responder )
			continue;
		
		if ( nil == url || [[request.url absoluteString] isEqualToString:url] ){
			[array addObject:request];
		}			
	}
    
	return array;
}

+ (void)cancelRequest:(IDPHttpRequest *)request{
	[[IDPHttpRequestQueue sharedInstance] cancelRequest:request];
}

- (void)cancelRequest:(IDPHttpRequest *)request{
	[NSObject cancelPreviousPerformRequestsWithTarget:request selector:@selector(startAsynchronous) object:nil];
	
	if ( [_requests containsObject:request] ){
		if ( request.state ==  IDP_REQUEST_STATE_CREATED ||
             request.state ==  IDP_REQUEST_STATE_SENDING ||
             request.state ==  IDP_REQUEST_STATE_RECVING ){
			[request clearDelegatesAndCancel];
			[request changeState:IDP_REQUEST_STATE_CANCELLED];
		}
		
		[_requests removeObject:request];
	}	
}

+ (void)cancelRequestByResponder:(id)responder{
	[[IDPHttpRequestQueue sharedInstance] cancelRequestByResponder:responder];
}

- (void)cancelRequestByResponder:(id)responder{
	if ( nil == responder ){
		[self cancelAllRequests];
	}
	else{
		NSMutableArray * tempArray = [NSMutableArray array];
		
		for ( IDPHttpRequest * request in _requests ){
			if ( request.responder == responder ){
				[tempArray addObject:request];				
			}			
		}
		
		for ( IDPHttpRequest * request in tempArray ){
			[self cancelRequest:request];
		}
	}
}

+ (void)cancelAllRequests{
	[[IDPHttpRequestQueue sharedInstance] cancelAllRequests];
}

- (void)cancelAllRequests{
	for ( IDPHttpRequest * request in _requests ){
		[self cancelRequest:request];
	}
}

- (NSArray *)requests{
	return _requests;
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request{
    if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
    
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest changeState:IDP_REQUEST_STATE_SENDING];
    
	_bytesUpload += request.postLength;
	
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
    
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest changeState:IDP_REQUEST_STATE_RECVING];
	
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	
	_bytesDownload += [[request rawResponseData] length];
	if (NO == [request isKindOfClass:[IDPHttpRequest class]])
		return;
    
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
    if (![_requests containsObject:networkRequest]) {
        return;
    }
    
	if ([request.requestMethod isEqualToString:@"GET"]){
		if ( request.responseStatusCode >= 400 && request.responseStatusCode < 500 ){
		}
	}
    
	if (200 == request.responseStatusCode){
		[networkRequest changeState:IDP_REQUEST_STATE_SUCCEED];
	}else{
        int rspCode = request.responseStatusCode;
        [networkRequest changeState:IDP_REQUEST_STATE_FAILED];
	}
    
	[_requests removeObject:networkRequest];
	[networkRequest cancel];	
    [request cancel];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
    
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;	
	networkRequest.errorCode = -1;
	[networkRequest changeState:IDP_REQUEST_STATE_FAILED];
	[networkRequest cancel];
	
	[_requests removeObject:networkRequest];
	
}

#pragma mark -
#if 0
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL{
    NSString* url = [NSString stringWithFormat:@"%@",request.url];
    request.url = newURL;
    [self requestStarted:request];
}

- (void)requestRedirected:(ASIHTTPRequest *)request{
}

- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request{
	[self requestFailed:request];
}

- (void)proxyAuthenticationNeededForRequest:(ASIHTTPRequest *)request{
	[self requestFailed:request];
}
#endif 
#pragma mark -
#if 0
// Called when the request receives some data - bytes is the length of that data
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
	return;
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest updateRecvProgress];
}

// Called when the request sends some data
// The first 32KB (128KB on older platforms) of data sent is not included in this amount because of limitations with the CFNetwork API
// bytes may be less than zero if a request needs to remove upload progress (probably because the request needs to run again)
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
	return;
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest updateSendProgress];
}

// Called when a request needs to change the length of the content to download
- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
	return;
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest updateRecvProgress];
}

// Called when a request needs to change the length of the content to upload
// newLength may be less than zero when a request needs to remove the size of the internal buffer from progress tracking
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength{
	if ( NO == [request isKindOfClass:[IDPHttpRequest class]] )
		return;
	return;
	IDPHttpRequest * networkRequest = (IDPHttpRequest *)request;
	[networkRequest updateSendProgress];
}
#endif 
@end



