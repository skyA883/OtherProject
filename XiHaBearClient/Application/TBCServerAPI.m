//
//  TBCServerAPI.m
//  IDP
//
//  Created by zhangdongjin on 13-3-18.
//
//

#import "TBCServerAPI.h"
#import "NSString+IDPExtension.h"
#import "JSON.h"
#import "UIDevice-Hardware.h"

// 用于上传的统计数据，本次传上次的
@interface _TBCServerAPINetworkProfiler : NSObject
@property (nonatomic, strong) NSString *api;
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign) CFTimeInterval timecost;
@end

@implementation _TBCServerAPINetworkProfiler

- (void)dealloc {
    self.api = nil;
}

@end

_TBCServerAPINetworkProfiler *profiler = nil;


@implementation TBCServerAPI

- (id)initWithServer:(NSString *)server timeout:(NSTimeInterval)timeout_s {
    // 初始化 profiler
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        profiler = [_TBCServerAPINetworkProfiler new];
    });
    self = [super initWithServer:server timeout:timeout_s];
    return self;
}

// 增加附加参数
- (NSDictionary *)addExtraParams
{
    NSMutableDictionary *extraParams = [NSMutableDictionary new];
    
    NSString *macAddress = nil;
#ifdef __IPHONE_6_0
    macAddress = [[NSUUID UUID] UUIDString];
#else
    macAddress = [[UIDevice currentDevice] uniqueIdentifier];
#endif
    if (nil == macAddress) {
        macAddress = [[UIDevice currentDevice] macaddress];
    }
    /*
    extraParams[IF_CLIENT_REQUEST_PARAM_IMEI] = macAddress;
    extraParams[IF_CLIENT_REQUEST_PARAM_PROJECTID] = IF_CLIENT_REQUEST_VALUE_PROJECTID;
    extraParams[IF_CLIENT_REQUEST_PARAM_APPID] = IF_CLIENT_REQUEST_VALUE_APPID;
    if([IFAppSetting shareAppSetting].deiviceId.length > 0)
    {
//        [UIAlertView showWithTitle:@"deiviceId" message:[IFAppSetting shareAppSetting].deiviceId onDismiss:^(){
//            
//        }];
        extraParams[IF_CLIENT_REQUEST_PARAM_DEIVICEID] = [IFAppSetting shareAppSetting].deiviceId;
    }
    else
    {
        extraParams[IF_CLIENT_REQUEST_PARAM_DEIVICEID] = @"0";
    }
    
    extraParams[IF_CLIENT_REQUEST_PARAM_PLATFORM] = [[UIDevice currentDevice] platformString];
    extraParams[IF_CLIENT_REQUEST_PARAM_OS_VERSION] = [[UIDevice currentDevice] systemVersion];
    extraParams[IF_CLIENT_REQUEST_PARAM_OS] = [[UIDevice currentDevice] systemName];
    extraParams[IF_CLIENT_REQUEST_PARAM_APP_VERSION] = [IFAppSetting shareAppSetting].appVersion;
    
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).userName) {
        extraParams[IF_CLIENT_REQUEST_PARAM_UNAME] = ((AppDelegate *)[UIApplication sharedApplication].delegate).userName;
    }
     */
//    else
//    {
//        extraParams[IF_CLIENT_REQUEST_PARAM_UNAME] = @"15110091879";
//    }
    //username and pwd
    /*
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).userPwd) {
        extraParams[IF_CLIENT_REQUEST_PARAM_UPWD] = ((AppDelegate *)[UIApplication sharedApplication].delegate).userPwd;
    }
     */
//    else
//    {
//        extraParams[IF_CLIENT_REQUEST_PARAM_UPWD] = @"123456";
//    }
    // 合入用户参数
    if (self.reqParams) {
        [extraParams addEntriesFromDictionary:self.reqParams];
    }
    IDPLogDebug(@"allParams=%@", extraParams);

    return extraParams;
}

// 解析结果
- (void)parseBody {
    // 保存profile 信息，以备下次上传
    profiler.api = self.api;
    profiler.timecost = self.netCost;
    profiler.isError = (self.state == IDP_PROC_STAT_FAILED);

    if (self.state != IDP_PROC_STAT_SUCCEED) {
        return;
    }
    IDPLogDebug(@"server return body is %@",self.rawString);
    // 空数据
    if(!self.rawData || !self.rawData.length) {
        self.state = IDP_PROC_STAT_FAILED;
        self.error = [NSError errorWithDomain:IDPServerAPIErrorDomain
                                         code:IDP_E_DATA_FORMAT_ERROR
                                     userInfo:@{@"reason":@"server return empty body"}];
        self.rawData = nil;
        IDPLogWarning(0, @"server return empty body");
    }
    // 解析出json
    self.parsedData = [self.rawData JSONValue];
    if (self.parsedData == nil || (![self.parsedData isKindOfClass:NSDictionary.class] && ![self.parsedData isKindOfClass:NSArray.class])) {
        self.state = IDP_PROC_STAT_FAILED;
        self.error = [NSError errorWithDomain:IDPServerAPIErrorDomain
                                         code:IDP_E_DATA_FORMAT_ERROR
                                     userInfo:@{@"reason":@"body is not json dict"}];
        self.parsedData = nil;
        IDPLogWarning(0, @"body is not json dict");
        return;
    }

    IDPLogDebug(@"server responseData parsed: %@", self.parsedData);
    
    if ([self.parsedData isKindOfClass:[NSDictionary class]]) {
        // 分析错误，服务器可能返回两个版本的错误信息结构
        int error_code = 0;
        NSString *error_msg = nil;
        NSNumber *error_code1 = [self.parsedData numberAtPath:@"error_code"];
        NSNumber *error_code2 = [self.parsedData numberAtPath:@"error/errno"];
        // 未找到，则报错
        /*
         if (!error_code1 && !error_code2) {
         self.state = IDP_PROC_STAT_FAILED;
         self.error = [NSError errorWithDomain:IDPServerAPIErrorDomain
         code:IDP_E_DATA_FORMAT_ERROR
         userInfo:@{@"reason":@"error code not found"}];
         IDPLogWarning(0, @"error code not found in server ret: %@", self.parsedData);
         return;
         } else
         */
        if (![error_code1 isEqualToValue:@0]) {
            error_code = [error_code1 intValue];
            error_msg = [self.parsedData stringAtPath:@"error_msg"];
        } else if (![error_code2 isEqualToValue:@0]) {
            error_code = [error_code2 intValue];
            error_msg = [self.parsedData stringAtPath:@"error/errmsg"];
        }
        
        // 1 = IDP_E_SERVER_USER_NOT_LOGIN
        // if (error_code != 1) {
        if (error_code) {
            self.state = IDP_PROC_STAT_FAILED;
            self.error = [NSError errorWithDomain:IDPServerAPIErrorDomain
                                             code:IDP_E_SERVER_ERROR
                                         userInfo:@{
                          @"reason":@"server return non-zero error code",
                          @"errno":[NSNumber numberWithInt:error_code],
                          @"errmsg":error_msg?error_msg:@"unknown error"
                          }];
            IDPLogWarning(0, @"server return non-zero error_code[%d] with message[%@]", error_code, error_msg);
            return;
        }
    }
}

@end
