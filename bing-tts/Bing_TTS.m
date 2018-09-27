//
//  Bing_TTS.m
//  bing-tts
//
//  Created by lv on 2018/9/25.
//  Copyright © 2018年 lv. All rights reserved.
//

#import "Bing_TTS.h"

static Bing_TTS * _instance = nil;


@implementation Bing_TTS

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)alloc{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super alloc];
    });
    return _instance;
}

+(instancetype) sharedInstance{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}
-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

///授权操作。。。
-(void)bing_auth:(void (^)(BOOL state))result{
    
    if(self.authKey == nil){
        result(NO);
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_authKey forKey:@"Ocp-Apim-Subscription-Key"];
    [dic setObject:@"application/x-www-form-urlencoded" forKey:@"Content-type"];
    [dic setObject:@"0" forKey:@"Content-Length"];
    
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://westus.api.cognitive.microsoft.com/sts/v1.0/issueToken"]];
    
    [req setTimeoutInterval:10];
    [req setHTTPMethod:@"POST"];
    [req setAllHTTPHeaderFields:dic];
    
    NSURLSession *session  = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        NSLog(@"%@",error);
//        NSLog(@"%lu",[data length]);
//        NSLog(@"%@",response);
//        NSLog(@"%ld",[res statusCode]);
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;

        if(error || [res statusCode] != 200){
//            NSLog(@"授权失败");
            result(NO);
        }else{
//            NSLog(@"授权成功");
            self.authString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.authTime = [self getTime];
            result(YES);
        }
        
    }];
    
    [task resume];
    
}

-(void)bing_tts:(NSString*)text completionHandler:(void (^)(NSData * _Nullable data,  NSInteger code))completionHandler{
    
    NSString *str = [NSString stringWithFormat:@"<speak version='1.0' xml:lang='en-US'><voice xml:lang='en-US' xml:gender='Female' name='Microsoft Server Speech Text to Speech Voice (en-US, Jessa24kRUS)'>%@</voice></speak>",text];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    //    [dic setObject:@"a875ac03927346a68049b182838b56e9" forKey:@"Ocp-Apim-Subscription-Key"];
    [dic setObject:@"application/ssml+xml" forKey:@"Content-type"];
    [dic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)str.length] forKey:@"Content-Length"];
    ///输出音频格式。riff-8khz-8bit-mono-mulaw
    [dic setObject:@"audio-16khz-64kbitrate-mono-mp3" forKey:@"X-Microsoft-OutputFormat"];
    //        ///唯一标识客户端应用程序的 ID。 它可以是应用的 Store ID。 如果 Store ID 不可用，也可以是用户为应用程序生成的 ID。
    //        [dic setObject:@"1342" forKey:@"X-Search-AppId"];
    //        ///唯一标识每个安装的应用程序实例的 ID。
    //        [dic setObject:@"com.qqxnz.bing-tts" forKey:@"X-Search-ClientID"];
    //        ///应用程序名称必填，且长度不得超过 255 个字符。
    //        [dic setObject:@"getwell" forKey:@"User-Agent"];
    
    [dic setObject:[NSString stringWithFormat:@" Bearer %@ ",self.authString] forKey:@"Authorization"];
    
    
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://westus.tts.speech.microsoft.com/cognitiveservices/v1"]];
    
    [req setHTTPMethod:@"POST"];
    
    [req setTimeoutInterval:10];
    
    
    [req setAllHTTPHeaderFields:dic];
    
//    NSLog(@"%@",req.allHTTPHeaderFields);
    
    
    [req setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSession *session  = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        NSLog(@"%@",error);
//        NSLog(@"%lu",[data length]);
//        NSLog(@"%@",response);
//        NSLog(@"%ld",[res statusCode]);
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
        completionHandler(data,[res statusCode]);
        
    }];
    
    [task resume];
}


-(NSTimeInterval)getTime {
    
    NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval time = [now timeIntervalSince1970];

    return time;
}

///授权加转换
-(void)tts:(NSString*)text completionHandler:(void (^)(NSData * _Nullable data,  NSInteger code))completionHandler{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSTimeInterval now = [self getTime];
    if(now - self.authTime > 540){///超过9分钟授权一次
        [self bing_auth:^(BOOL state) {
            if(state){
                dispatch_group_leave(group);
            }else{
                completionHandler(nil,-10000);
            }
        }];
    }else{
        dispatch_group_leave(group);
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self bing_tts:text completionHandler:completionHandler];
    });
}


@end
