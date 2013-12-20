//
//  MLNetworkingManager.m
//  WebSocket
//
//  Created by Molon on 13-11-27.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MLNetworkingManager.h"
#import "SRWebSocket.h"
#import "MLRequest.h"
#import "MLJson.h"
#import <zlib.h>

#define kRequestKeyName @"client_code"
#define kRequestKeyLength 5
#define kTimeOut 5 //暂时设置10秒

NSString * const MLNetworkingManagerDidReceivePushMessageNotification = @"com.mlnetworking.didgetnotification";

static NSString * const MLNetworkingManagerBaseURLString = @"ws://service.xianchangjia.com:8000/ws?usezlib=1";

//并发的队列，判断超时
static dispatch_queue_t request_is_timeout_judge_queue() {
    static dispatch_queue_t ml_request_is_timeout_judge_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ml_request_is_timeout_judge_queue = dispatch_queue_create("com.mlnetworking.istimeout.judge", DISPATCH_QUEUE_CONCURRENT);
    });
    return ml_request_is_timeout_judge_queue;
}

@interface MLNetworkingManager()<SRWebSocketDelegate>

//对于requests的操作必须放在主线程，以免不安全
@property (nonatomic,strong,readonly) NSArray *requests;
//准备发送
@property (nonatomic,strong) NSMutableArray *preparedRequests;
//已经发送
@property (nonatomic,strong) NSMutableArray *sentRequests;

@property (nonatomic,strong) SRWebSocket *webSocket;

@property (nonatomic,strong) NSURL *baseURL;
@property (nonatomic,copy) NSString *sessionID;

@end

@implementation MLNetworkingManager

@synthesize webSocket = _webSocket;

+ (instancetype)sharedManager {
    static MLNetworkingManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc]init];
        _sharedManager.baseURL = [NSURL URLWithString:MLNetworkingManagerBaseURLString];
    });
    
    return _sharedManager;
}

//发送一条请求
- (void)sendWithAction:(NSString*)action
            parameters:(NSDictionary *)parameters
               success:(MLNetworkingSuccessBlcok)success
               failure:(MLNetworkingFailureBlcok)failure
{
    //设置一个请求唯一标识
    MLRequest *request  = [[MLRequest alloc]init];
    request.action = action;
    request.params = parameters;
    request.requestKey = [self uniqueRequestKey];
    request.successBlock = success;
    request.failureBlock = failure;
    
    if (self.webSocket.readyState == SR_OPEN) {
        [self sendRequest:request];
    }else{
        [self.preparedRequests addObject:request];
    }
}

- (void)sendRequest:(MLRequest*)request
{
    //必须保证其是开启状态才能发送
    NSAssert((self.webSocket.readyState == SR_OPEN), @"连接没有打开，无法发送");
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    dict[@"function"] = request.action;
    dict[@"params"] = request.params;
    dict[kRequestKeyName] = request.requestKey;
    [self.webSocket send:[dict JSONString]];
    
    [self.sentRequests addObject:request];
    
    //加入超时队列
    double delayInSeconds = kTimeOut;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //在超时之后执行block
    dispatch_after(popTime, request_is_timeout_judge_queue(), ^(void){
        //判断此request是否还存在于sentRequests里
        if ([_sentRequests containsObject:request]) {
            NSError *error = [NSError errorWithDomain:SRWebSocketErrorDomain code:8888 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Request timeout!"] forKey:NSLocalizedDescriptionKey]];
            dispatch_async(dispatch_get_main_queue(), ^{
                request.failureBlock(request,error);
                //删去request
                [_sentRequests removeObject:request];
            });
        }else{
            NSLog(@"没有超时");
        }
    });
}

-(NSData *)uncompressZippedData:(NSData *)compressedData
{
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = (unsigned)[compressedData length];
    
    unsigned half_length = (unsigned)[compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (uInt)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

#pragma mark - SRWebSocket

- (void)sendSessionID
{

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
//    NSLog(@"Websocket Connected");
    
    //检查如果有准备发送的请求，现在发送
    for (MLRequest *request in self.preparedRequests) {
       [self sendRequest:request];
    }
    [self.preparedRequests removeAllObjects];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
//    NSLog(@":( Websocket Failed With Error %@", error);
    self.webSocket = nil;
    //这里的话需要执行全部保存的requests的失败和清理操作
    for (MLRequest *request in self.requests) {
        //执行对应的failureBlock
        request.failureBlock(request,error);
    }
    [self.sentRequests removeAllObjects];
    [self.preparedRequests removeAllObjects];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
//    NSLog(@"Received \"%@\"", message);
//    NSAssert([message isKindOfClass:[NSString class]],@"返回值不是字符串");
    if (![message isKindOfClass:[NSString class]]) {
        //不是字符串就认作是被zlib压缩的数据Data
        message = [self uncompressZippedData:message];
        message = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *response = [message objectFromJSONString];
    NSString *requestKey = [self getStringValue:response[kRequestKeyName] defaultValue:nil];
    if (!requestKey) {
        //说明此条是服务器直接推过来的数据,想得到的话就注册此通知
        [[NSNotificationCenter defaultCenter] postNotificationName:MLNetworkingManagerDidReceivePushMessageNotification object:nil userInfo:response];
        return;
    }
    for (MLRequest *request in self.sentRequests) {
        if ([request.requestKey isEqualToString:requestKey]) {
            //执行对应的successBlock
            request.successBlock(request,response);
            [self.sentRequests removeObject:request]; //移除此请求
            break;
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
//    NSLog(@"WebSocket closed");
    self.webSocket = nil;
}

#pragma mark - getter and setter

- (SRWebSocket*)webSocket
{
    //如果没有就执行重连接等等
    if (!_webSocket) {
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.baseURL]];
        _webSocket.delegate = self;
        [_webSocket open];
    }
    return _webSocket;
}

- (void)setWebSocket:(SRWebSocket *)webSocket
{
    if (webSocket == nil&&_webSocket) {
        _webSocket.delegate = nil;
        [_webSocket close];
        _webSocket = nil;
        return;
    }
    _webSocket = webSocket;
}

//返回的是俩玩意合集
- (NSArray*)requests
{
    NSArray *r = [NSArray arrayWithArray:self.sentRequests];
    r = [r arrayByAddingObjectsFromArray:self.sentRequests];
    return r;
}

- (NSMutableArray*)preparedRequests
{
    if (!_preparedRequests) {
        _preparedRequests = [NSMutableArray array];
    }
    return _preparedRequests;
}

- (NSMutableArray*)sentRequests
{
    if (!_sentRequests) {
        _sentRequests = [NSMutableArray array];
    }
    return _sentRequests;
}

#pragma mark - other Common

- (NSString*)randomStringWithLength:(NSUInteger)length
{
    char data[length];
    for (int i=0;i<length;data[i++] = (char)('A' + arc4random_uniform(26)));
    NSString *result = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
    return result;
}

- (NSString*)uniqueRequestKey
{
    //随机一个字符串
    NSString *key = [self randomStringWithLength:kRequestKeyLength];
    while (YES) {
        BOOL isHave = NO;
        for (MLRequest *request in self.requests) {
            if ([request.requestKey isEqualToString:key]) {
                isHave = YES;
                break;
            }
        }
        if (isHave) {
            key = [self randomStringWithLength:kRequestKeyLength];
        }else{
            break;
        }
    }
    return key;
}

- (NSString *)getStringValue:(id)object
                defaultValue:(NSString *)defaultValue{
    if (object && ![object isKindOfClass:[NSNull class]]) {
        if ([object isKindOfClass:[NSString class]]) {
            return object;
        } else if ([object isKindOfClass:[NSNumber class]]) {
            return [object stringValue];
        }
    }
    return defaultValue;
}
@end
