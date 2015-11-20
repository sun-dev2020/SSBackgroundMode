//
//  ViewController.m
//  SSBackgroundMode
//
//  Created by mac on 15/11/20.
//  Copyright (c) 2015年 treebear. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    AVQueuePlayer *player;
    NSDate *time;
    UILabel *timeLab;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self audioSession];
    [self updateUI];
}

//执行后台任务
- (void)backgroudFetch:(void(^)())completion{
    time = [NSDate date];
    completion();
}
- (void)updateUI{
    if (!timeLab) {
        timeLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 20)];
        [self.view addSubview:timeLab];
    }
    if (time) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterLongStyle;
        timeLab.text = [formatter stringFromDate:time];
    }else{
        timeLab.text = @"Not yet updated";
    }
}

//音频播放
- (void)audioSession{
    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    if (!success) {
        NSLog(@" failed to set audio session category");
    }
    //使用音频的单例模式，去设置播放的类别，确保生意从扬声器中出来而不是听筒
    NSArray *names = @[@"周杰伦 - 青花瓷",@"薛之谦 - 演员"];
    NSMutableArray *songs = [NSMutableArray array];
    [names enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       [songs addObject:[[AVPlayerItem alloc] initWithURL:[[NSBundle mainBundle] URLForResource:obj withExtension:@".mp3"]]];
    }];
    player = [[AVQueuePlayer alloc] initWithItems:songs];
    player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;  //循环播放
    [self addObserver:player forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];

    
    //设置一个1/100s的监听
    [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            NSLog(@" time : %@ ",[NSString stringWithFormat:@"%02.2f",CMTimeGetSeconds(time)]);
        }
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 300, 150, 50);
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"play" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playClicked:) forControlEvents:UIControlEventTouchUpInside ];
    [self.view addSubview:button];
}
- (void)playClicked:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [player play];
    }else{
        [player pause];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@" change item");
    if ([keyPath isEqualToString:@"currentItem"] && [object isEqual:player]) {
        AVPlayerItem *currentItem = (AVPlayerItem *)object;
        NSLog(@" currentItem : %@ ",currentItem);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
