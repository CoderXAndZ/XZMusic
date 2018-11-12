//
//  ViewController.m
//  XZMusic
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import "XZMusicTool.h"

@interface ViewController ()<XZMusicToolDelegate>

/// 当前模式
@property (weak, nonatomic) IBOutlet UILabel *currentMode;

@property (nonatomic, strong) NSMutableArray *urls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *array = @[@"爱莫忘.mp3", @"爸爸去哪儿.mp3", @"泡沫.mp3", @"小苹果.mp3",  @"昨迟人.mp3", @"Let It Go.mp3", @"愿得一人心(剧场版).mp3"];
    
    //
    for (int i = 0; i < array.count; i++) {
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource: array[i] withExtension:nil];
        [self.urls addObject: fileUrl];
    }
    
    [XZMusicTool shared].delegate = self;
}

#pragma mark --- XZMusicToolDelegate
- (void)xz_playerStatus:(XZPlayerStatus)stasus {
    switch (stasus) {
        case XZPlayerStatusReadyToPlay:{
            NSLog(@"开始播放去掉菊花转圈");
        }
            break;
        case XZPlayerStatusUnknown:{
            NSLog(@"出现未知错误");
        }
            break;
        case XZPlayerStatusFailed:{
            NSLog(@"播放失败");
        }
            break;
        case XZPlayerStatusFinished:
        {
            NSLog(@"播放完成，修改按钮状态");
        }
            break;
            
        default:
            break;
    }
}

/// 播放歌曲
- (IBAction)palySongAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) { // 播放
        [[XZMusicTool shared] xz_playerWithURLs: self.urls withMode: 0 currentSong: 0];
    }else { // 暂停
        [[XZMusicTool shared] xz_pause];
    }
    
}

/// 上一曲
- (IBAction)lastSongAction:(UIButton *)sender {
    
    if ([XZMusicTool shared].currentSongIdx == 0) {
        NSLog(@"已经是第一首歌曲了");
    }else {
        [[XZMusicTool shared] xz_lastSong];
    }
}

/// 下一曲
- (IBAction)nextSongAction:(UIButton *)sender {
    if ([XZMusicTool shared].currentSongIdx == self.urls.count - 1) {
        NSLog(@"已经是最后一首歌曲了");
    }else {
        [[XZMusicTool shared] xz_nextSong];
    }
}

- (NSMutableArray *)urls {
    if (!_urls) {
        _urls = [NSMutableArray array];
    }
    return _urls;
}

@end
