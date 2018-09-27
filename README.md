#  微软必应语音AI-文本转语音API实现(IOS) 

 
 
```
    ///设置授权key
    [[Bing_TTS sharedInstance] setAuthKey:@"a875ac03927346a68049b182838b56e9"];
    ///文本转语音
    [[Bing_TTS sharedInstance] tts:@"Let\'s doWarm-up.The next action iselbow warm up. forty  Seconds." completionHandler:^(NSData * _Nullable data, NSInteger * _Nullable code) {
       
        NSLog(@"%d",code);
        NSLog(@"%@",data);

 
    }];
```