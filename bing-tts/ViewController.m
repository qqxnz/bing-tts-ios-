//
//  ViewController.m
//  bing-tts
//
//  Created by lv on 2018/9/25.
//  Copyright © 2018年 lv. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Bing_TTS.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *stateView;
@property (nonatomic,strong) AVAudioPlayer * audioPlayer;
@property (nonatomic,strong) NSString * auth;
@property (nonatomic,strong) NSData * data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    
    
}
- (IBAction)auth:(id)sender {
    [self pas1];
}

- (IBAction)tts:(id)sender {
        [self pas2];
}

-(void)pas1{


    [[Bing_TTS sharedInstance] setAuthKey:@"a875ac03927346a68049b182838b56e9"];
    
    [[Bing_TTS sharedInstance] bing_auth:^(BOOL state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"授权结果%d",state);
            if(state){
                [self.stateView setText:@"授权成功"];
            }else{
                [self.stateView setText:@"授权失败"];
            }
        });
    }];
    

}


-(void)pas2{
    ///设置授权key
    [[Bing_TTS sharedInstance] setAuthKey:@"a875ac03927346a68049b182838b56e9"];
    ///文本转语音
    [[Bing_TTS sharedInstance] tts:self.textView.text completionHandler:^(NSData * _Nullable data, NSInteger * _Nullable code) {
       
//        NSLog(@"%d",code);
//        NSLog(@"%@",data);
//        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(code != 200){
                [self.stateView setText:@"转换失败"];
            }else{
                [self.stateView setText:@"转换成功"];
                [self player:data];
            }
        });
        
        
    }];
    
    
}

///播放器
-(void)player:(NSData *) data{
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    //准备播放
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
