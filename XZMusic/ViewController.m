//
//  ViewController.m
//  XZMusic
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import "XZMusicTool.h"

@interface ViewController ()

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
    [[XZMusicTool shared] xz_lastSong];
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
