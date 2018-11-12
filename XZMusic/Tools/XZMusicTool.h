//
//  XZMusicTool.h
//  XZMusic
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前播放的状态
typedef NS_ENUM(NSInteger, XZPlayerStatus) {
    XZPlayerStatusUnknown, /// 出现未知错误
    XZPlayerStatusReadyToPlay, /// 将要播放
    XZPlayerStatusFailed, /// 播放失败
    XZPlayerStatusFinished, /// 播放结束
};

@protocol XZMusicToolDelegate <NSObject>
/// 播放进度回调
- (void)xz_progress:(CGFloat)progress;
/// 缓冲进度回调
- (void)xz_bufferProgress:(CGFloat)progress;
/// 当前播放状态，例如，已经准备好播放，去掉菊花转圈等
- (void)xz_playerStatus:(XZPlayerStatus)stasus;
/// 当前rate
- (void)xz_playerCurrentRate:(float)rate;
@end

@interface XZMusicTool : NSObject
/// 单例
+ (instancetype)shared;
/// 初始化 0 顺序播放 1 单曲播放
- (void)xz_playerWithURLs:(NSArray *)urls withMode:(NSInteger)mode currentSong:(NSInteger)currentSong;
/// 用户拖动进度条，修改播放进度
- (void)xz_playSliderValueChange:(float)value;
/// 下一首
- (void)xz_nextSong;
/// 上一首
- (void)xz_lastSong;
/// 播放
- (void)xz_play;
/// 暂停
- (void)xz_pause;

/// 代理
@property (nonatomic, assign) id<XZMusicToolDelegate> delegate;
/// 当前是第几首歌
@property (nonatomic, assign, readonly) NSInteger currentSongIdx;
@end

NS_ASSUME_NONNULL_END
