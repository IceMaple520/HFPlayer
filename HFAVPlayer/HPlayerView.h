//
//  HPlayerView.h
//  ShowTime
//
//  Created by 司华锋 on 2017/3/7.
//  Copyright © 2017年 HF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol HPlayerViewDelegate <NSObject>

- (void)changeMaxView:(UIView *)view;
- (void)changeMinView:(UIView *)view;
- (void)isCurrentView:(UIView *)view;

@end

@interface HPlayerView : UIView

/**
   视频地址远程或者本地的
 */
@property (nonatomic,strong) NSString *urlName;

/**
   播放器
 */
@property (nonatomic,strong) AVPlayer *player;

/**
   播放单元
 */
@property (nonatomic,strong) AVPlayerItem *playerItem;

/**
   播放界面
 */
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

/**
   播放按钮
 */
@property (nonatomic,strong) UIButton *playButton;
/**
   全屏按钮
 */
@property (nonatomic,strong) UIButton *fullButton;

/**
    视频当期播放时间
 */
@property (nonatomic,strong) UILabel *currentTimeLabel;
/**
   视频总时长
 */
@property (nonatomic,strong) UILabel *allTimeLabel;

/**
   进度条
 */

@property (nonatomic,strong) UISlider *slider;
/**
    //进度条 当前时间 总时间 全屏按钮父视图
 */
@property (nonatomic,strong) UIView *barView;

/**
   窗口大小
 */
@property (nonatomic,assign) CGRect rect;
/**
 视频是否播放
 */
@property (nonatomic,assign) BOOL isPlayer;
/**
   是否点击屏幕
 */
@property (assign, nonatomic) BOOL  isClickScreen;
/**
    判断是否是第一次点击播放按钮
 */
@property (assign, nonatomic) BOOL  isFirst ;



/**
   判断是否是第一次点击播放按钮
 */
@property (assign, nonatomic) BOOL  isFirstButton;

/**
    判断进度条是否按下
 */
@property (assign, nonatomic) BOOL  isSliderDown;

@property (nonatomic,assign) id<HPlayerViewDelegate>delegate;

/**
   初始化实现
 */
-(instancetype)initWithFrame:(CGRect)frame urlString:(NSString*)url;




@end
