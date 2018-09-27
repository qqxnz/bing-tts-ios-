//
//  Bing_TTS.h
//  bing-tts
//
//  Created by lv on 2018/9/25.
//  Copyright © 2018年 lv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bing_TTS : NSObject

+(instancetype) sharedInstance;
-(void)bing_auth:(void (^)(BOOL state))result;
-(void)bing_tts:(NSString*)text completionHandler:(void (^)(NSData * _Nullable data,  NSInteger code))completionHandler;
-(void)tts:(NSString*)text completionHandler:(void (^)(NSData * _Nullable data,  NSInteger * _Nullable code))completionHandler;

@property (nonatomic,strong) NSString * authString;
@property (nonatomic,strong) NSString * authKey;
@property (nonatomic,assign) NSTimeInterval  authTime;

@end
