//
//  XZMusicTool.m
//  XZMusic
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "XZMusicTool.h"
#import <AVFoundation/AVFoundation.h>

@interface XZMusicTool()

@property (nonatomic, strong) AVPlayer *player;
/// 监听播放进度
@property (nonatomic, strong) id timeObserver;
/// 当前正在播放哪一首
@property (nonatomic, assign) NSInteger currentSong;
/// 播放列表
@property (nonatomic, strong) NSArray *playLists;
/// 当前播放模式
@property (nonatomic, assign) NSInteger currentMode;

@end

@implementation XZMusicTool

+ (instancetype)shared {
    static XZMusicTool *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[XZMusicTool alloc] init];
    });
    return player;
}

/// 播放歌曲
- (void)xz_playWithURL:(NSURL *)url {
    // 移除上首歌的监听
    [self xz_removeCurrentObserver];
    // 创建要播放的资源
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL: url];
    // 播放当前资源
    [self.player replaceCurrentItemWithPlayerItem: playerItem];
    
    // 播放
    [self xz_play];
    
    // 添加观察者
    [self xz_addObserver];
}

/// 初始化 0 顺序播放 1 单曲播放
- (void)xz_playerWithURLs:(NSArray *)urls withMode:(NSInteger)mode currentSong:(NSInteger)currentSong {
    _playLists = urls;
    _currentMode = mode;
    _currentSong = currentSong;
    
    switch (mode) {
        case 0: // 顺序播放
        {
            [self xz_playWithURL: urls[_currentSong]];
        }
            break;
        case 1: // 单曲循环播放
        {
            [self xz_playWithURL: urls[_currentSong]];
        }
            break;
        default:
            break;
    }
    
}

/// 上一首
- (void)xz_lastSong {
    if (_currentSong > 0) {
        _currentSong -= 1;
    }
    
    [self xz_playWithURL: _playLists[_currentSong]];
}

/// 下一首
- (void)xz_nextSong {
    if (_currentSong < _playLists.count - 1) {
        _currentSong += 1;
    }
    
    [self xz_playWithURL: _playLists[_currentSong]];
}

/// 播放
- (void)xz_play {
    [self.player play];
}

/// 暂停
- (void)xz_pause {
    [self.player pause];
}

/// 当前是第几首歌曲
- (NSInteger)currentSongIdx {
    return _currentSong;
}

/// 用户拖动进度条，修改播放进度
- (void)xz_playSliderValueChange:(float)value
{
    // 根据值计算时间
    float time = value * CMTimeGetSeconds(self.player.currentItem.duration);
    // 跳转到当前指定时间
    [self.player seekToTime: CMTimeMake(time, 1)];
}

// 添加监听
- (void)xz_addObserver {
    // 监听播放状态
    [self.player.currentItem addObserver: self
                              forKeyPath: @"status"
                                 options: NSKeyValueObservingOptionNew
                                 context: nil];
    
    // 监听缓冲加载情况属性
    [self.player.currentItem addObserver: self
                              forKeyPath: @"loadedTimeRanges"
                                 options: NSKeyValueObservingOptionNew
                                 context: nil];
    
    // 监听播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playbackFinished:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: self.player.currentItem];
    
    // 监听时间进度
    __weak typeof (self)weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval: CMTimeMake(1, 1)
                                                                  queue: dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        if (current) {
            // 进度
            CGFloat prgress = current / total;
            NSLog(@"进度： %.2f", prgress);
            
            // 进度回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(xz_progress:)]) {
                [weakSelf.delegate xz_progress: prgress];
            }
        }
    }];
}

// 移除监听
- (void)xz_removeCurrentObserver {
    [self.player.currentItem removeObserver: self  forKeyPath: @"status"];
    [self.player.currentItem removeObserver: self forKeyPath: @"loadedTimeRanges"];
    
    if (_timeObserver) {
        [self.player removeTimeObserver: _timeObserver];
        _timeObserver = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name: AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

/// 播放完成
- (void)playbackFinished:(NSNotification *)notifi {
    NSLog(@"播放完成");
    
    // 播放完成回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(xz_playerStatus:)]) {
        [self.delegate xz_playerStatus: XZPlayerStatusFinished];
    }
    
    // 播放完成，自动进行下一曲播放
    if (_currentMode == 0) { // 列表播放
        if (_currentSong < _playLists.count - 1) {
            _currentSong += 1;
            
            [self xz_playWithURL: _playLists[_currentSong]];
            
        }else { // 已经是最后一曲的时候，暂停播放
            [self xz_pause];
        }
    }else { // 单曲循环播放
        [self xz_playWithURL: _playLists[_currentSong]];
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status = [change[@"new"] integerValue];
        
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                // 开始播放
                [self xz_play];
                
                // 已经准备好播放，去掉菊花转圈等
                if (self.delegate && [self.delegate respondsToSelector:@selector(xz_playerStatus:)]) {
                    [self.delegate xz_playerStatus: XZPlayerStatusReadyToPlay];
                }
            
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"加载失败");
                // 加载失败
                if (self.delegate && [self.delegate respondsToSelector:@selector(xz_playerStatus:)]) {
                    [self.delegate xz_playerStatus: XZPlayerStatusFailed];
                }
                
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"未知资源");
                // 未知错误
                if (self.delegate && [self.delegate respondsToSelector:@selector(xz_playerStatus:)]) {
                    [self.delegate xz_playerStatus: XZPlayerStatusUnknown];
                }
            }
                break;
            default:
                break;
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        
        // 本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        // 缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        NSLog(@"共缓冲：%.2f", totalBuffer);
        // 缓冲回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(xz_bufferProgress:)]) {
            [self.delegate xz_bufferProgress: (CGFloat)totalBuffer];
        }
        
    } else if ([keyPath isEqualToString:@"rate"]) {
        
        // rate = 1:播放，rate != 1:非播放
        float rate = self.player.rate;
        
        NSLog(@"rate：%.2f", rate);
        
        if (self.delegate && [self.delegate respondsToSelector: @selector(xz_playerCurrentRate:)]) {
            [self.delegate xz_playerCurrentRate: rate];
        }
    }
//    else if ([keyPath isEqualToString:@"currentItem"]) {
//
//        NSLog(@"新的currentItem");
//
////        if (self.delegate && [self.delegate respondsToSelector:@selector(changeNewPlayItem:)]) {
////            [self.delegate changeNewPlayItem:self.player];
////        }
//    }
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 1.0; // 默认
    }
    return _player;
}

@end
