//
//  IDPHttpRequest.h
//  iPadClient
//
//  Created by zhong on 12-12-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIFormDataRequest.h"


@class IDPHttpRequest;

#pragma mark -

@interface NSObject(IDPRequestResponder)

- (BOOL)isRequestResponder;

- (IDPHttpRequest *)GET:(NSString *)url;
- (IDPHttpRequest *)POST:(NSString *)url dict:(NSDictionary *)kvs;
- (IDPHttpRequest *)POST:(NSString *)url params:(id)first, ...;
- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(id)first, ...;
- (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files dict:(NSDictionary *)kvs;
- (IDPHttpRequest *)POST:(NSString *)url json:(id)jsonDict;

- (BOOL)requestingURL;
- (BOOL)requestingURL:(NSString *)url;

- (NSArray *)requests;
- (NSArray *)requests:(NSString *)url;

- (void)cancelRequests;
- (void)handleRequest:(IDPHttpRequest *)request;

@end

#pragma mark -

typedef enum
{
	IDP_REQUEST_STATE_CREATED = 0,
	IDP_REQUEST_STATE_SENDING,
	IDP_REQUEST_STATE_RECVING,
	IDP_REQUEST_STATE_SUCCEED,
    IDP_REQUEST_STATE_FAILED,
	IDP_REQUEST_STATE_CANCELLED,
    IDP_REQUEST_STATE_END
} IDPRequestStateEnum;

#pragma mark -

typedef void (^IDPRequestBlock)(IDPHttpRequest* req);
typedef NSMutableDictionary* (^IDPParamHookBlock)(IDPHttpRequest* req);
#pragma mark -

@interface IDPHttpRequest: ASIFormDataRequest{
    IDPRequestStateEnum		_state;
	id						_responder;
    
	NSInteger				_errorCode;
    
	BOOL					_sendProgressed;
	BOOL					_recvProgressed;
	IDPRequestBlock			_blockReqCallback;
	IDPParamHookBlock       _paramHookBlock;
	
	NSTimeInterval			_initTimeStamp;
	NSTimeInterval			_sendTimeStamp;
	NSTimeInterval			_recvTimeStamp;
	NSTimeInterval			_doneTimeStamp;
    
}

@property (nonatomic, assign) IDPRequestStateEnum		state;
@property (nonatomic, assign) id						responder;

@property (nonatomic, assign) NSInteger					errorCode;

@property (nonatomic, copy) IDPRequestBlock             blockReqCallback;
@property (nonatomic, copy) IDPParamHookBlock           paramHookBlock;

@property (nonatomic, assign) NSTimeInterval			initTimeStamp;
@property (nonatomic, assign) NSTimeInterval			sendTimeStamp;
@property (nonatomic, assign) NSTimeInterval			recvTimeStamp;
@property (nonatomic, assign) NSTimeInterval			doneTimeStamp;

@property (nonatomic, assign) BOOL                      sendProgressed;
@property (nonatomic, assign) BOOL                      recvProgressed;

- (void)changeState:(IDPRequestStateEnum)state;

- (NSTimeInterval)timeCostPending;	// 排队等待耗时
- (NSTimeInterval)timeCostOverDNS;	// 网络连接耗时
- (NSTimeInterval)timeCostRecving;	// 网络收包耗时
- (NSTimeInterval)timeCostOverAir;	// 网络整体耗时

- (NSUInteger)uploadBytes;
- (NSUInteger)uploadTotalBytes;

- (NSUInteger)downloadBytes;
- (NSUInteger)downloadTotalBytes;

@end


#pragma mark -

@interface IDPHttpRequestQueue : NSObject<ASIHTTPRequestDelegate>{
	BOOL					_online;
    
	NSUInteger				_bytesUpload;
	NSUInteger				_bytesDownload;
	
	NSTimeInterval			_delay;
	NSMutableArray*		    _requests;
    
	IDPRequestBlock			_blockReqCallback;
	IDPParamHookBlock       _paramHookBlock;
}

@property (nonatomic, assign) BOOL						online;				// 开网/断网

@property (nonatomic, assign) NSUInteger				bytesUpload;
@property (nonatomic, assign) NSUInteger				bytesDownload;

@property (nonatomic, assign) NSTimeInterval			delay;
@property (nonatomic, retain) NSMutableArray*			requests;

@property (nonatomic, copy)   IDPRequestBlock			blockReqCallback;
@property (nonatomic, copy)   IDPParamHookBlock         paramHookBlock;

+ (IDPHttpRequestQueue *)sharedInstance;

+ (BOOL)isReachableViaWIFI;
+ (BOOL)isReachableViaWLAN;
+ (BOOL)isNetworkInUse;

+ (IDPHttpRequest *)GET: (NSString *)url;
+ (IDPHttpRequest *)POST:(NSString *)url params:(NSDictionary *)kvs;
+ (IDPHttpRequest *)POST:(NSString *)url files:(NSDictionary *)files params:(NSDictionary *)kvs;
+ (IDPHttpRequest *)POST:(NSString *)url json:(id)jsonDict;

+ (BOOL)requesting:(NSString *)url;
+ (BOOL)requesting:(NSString *)url byResponder:(id)responder;

+ (NSArray *)requests:(NSString *)url;
+ (NSArray *)requests:(NSString *)url byResponder:(id)responder;

+ (void)cancelRequest:(IDPHttpRequest*)request;
+ (void)cancelRequestByResponder:(id)responder;
+ (void)cancelAllRequests;
@end



