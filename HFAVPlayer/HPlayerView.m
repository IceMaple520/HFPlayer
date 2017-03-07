//
//  HPlayerView.m
//  ShowTime
//
//  Created by 司华锋 on 2017/3/7.
//  Copyright © 2017年 HF. All rights reserved.
//

#import "HPlayerView.h"

#define COLORFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000)>>16))/255.0 green:((float)((rgbValue & 0xFF00)>>8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define __WIDTH   [UIScreen mainScreen].bounds.size.width
#define __HEIGHT  [UIScreen mainScreen].bounds.size.height


@implementation HPlayerView
- (instancetype)initWithFrame:(CGRect)frame urlString:(NSString *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.urlName = url;
        self.isPlayer = NO;
        self.isClickScreen = NO;
        self.isFirst = YES;
        self.isFirstButton = NO;
        [self creatVideo];
        [self creatUI];
        [self layoutViews];
        self.rect = frame;
    }
    return self;
}
- (void)creatVideo
{
    NSURL *url;
    if (self.urlName.length <= 0) {
        return;
    }
    if ([self.urlName hasPrefix:@"http://"] || [self.urlName hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:self.urlName];
    }else{
        url = [[NSURL alloc] initFileURLWithPath:self.urlName];
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //观察播放  KVO playerItem.staus
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
- (void)creatUI
{
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"Player_Stop@2x.png"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];

    self.barView = [[UIView alloc] init];
    self.barView.backgroundColor = COLORFromRGB(0x2f2f4f);
    self.barView.hidden = YES;
    [self addSubview:self.barView];
    
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.font = [UIFont systemFontOfSize:17];
    [self.barView addSubview:self.currentTimeLabel];

    self.allTimeLabel = [[UILabel alloc] init];
    self.allTimeLabel.textColor = [UIColor whiteColor];
    self.allTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.barView addSubview:self.allTimeLabel];
    
    
    self.slider = [[UISlider alloc] init];
    [self.slider setThumbImage:[UIImage imageNamed:@"MoviePlayer_Slider@2x.png"] forState:UIControlStateNormal];
    [self.barView addSubview:self.slider];
    
    [self.slider addTarget:self action:@selector(sliderDown) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderUp) forControlEvents:UIControlEventTouchUpInside];

    self.fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullButton setImage:[UIImage imageNamed:@"Player_max@2x.png"] forState:UIControlStateNormal];
    [self.fullButton addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
    [self.barView addSubview:self.fullButton];
    
}
- (void)layoutViews
{
    self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.bounds.size.height);
    self.barView.frame = CGRectMake(0, self.frame.size.height- 39, self.frame.size.width, 39);
    self.playButton.frame = CGRectMake(self.frame.size.width / 2 - 20, self.frame.size.height / 2 - 20, 40, 40);
    self.currentTimeLabel.frame = CGRectMake(0, 0, 80, 39);
    self.allTimeLabel.frame = CGRectMake(self.frame.size.width - 120, 0, 80, 39);
    self.slider.frame = CGRectMake(80, 0, self.frame.size.width - 200, 39);
    self.fullButton.frame = CGRectMake(self.frame.size.width - 40, 0, 40, 39);
    
    
    

}
- (void)sliderUp
{
    self.isSliderDown = NO;
    
    float seconds = self.slider.value;
    
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.playerItem.currentTime.timescale);
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            if (self.playButton.selected && self.isPlayer) {
                [self.player play];
            }else{
                [self.player pause];
            }
        }
    }];
}
- (void)sliderDown
{
    self.isSliderDown = YES;
}

- (void)fullScreenAction
{
    self.fullButton.selected =! self.fullButton.selected;
    


    if (self.fullButton.selected) {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];

        [self.fullButton setImage:[UIImage imageNamed:@"Player_min@2x.png"] forState:UIControlStateNormal];
        self.frame = [UIScreen mainScreen].bounds;
        if (_delegate) {
            [self.delegate changeMaxView:self];
        }
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];

        [self.fullButton setImage:[UIImage imageNamed:@"Player_max@2x.png"] forState:UIControlStateNormal];

        self.frame = self.rect;
        if (_delegate) {
            [self.delegate changeMinView:self];
        }
    }
    
    [self layoutViews];
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
- (void)playAction:(UIButton *)sender
{
    
    if (self.isPlayer && !self.playButton.selected) {
        [self.player play];
        [self.playButton setImage:[UIImage imageNamed:@"Player_Play@2x.png"] forState:UIControlStateSelected];
        self.playButton.alpha = 0;
        self.barView.hidden = NO;
    }else{
        [self.player pause];
    }
    self.isFirstButton = YES;
    self.playButton.selected =! self.playButton.selected;
    if (self.delegate) {
        [self.delegate isCurrentView:self];
    }

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
   //取出status的新值
    AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
    switch (status) {
        case AVPlayerItemStatusFailed:
            
            break;
        case AVPlayerItemStatusUnknown:
            
            break;
        case AVPlayerItemStatusReadyToPlay:
            self.isPlayer = YES;
            self.slider.maximumValue = self.playerItem.duration.value / self.playerItem.duration.timescale;
            [self getVideoData];
            break;
        default:
            break;
    }

}

- (void)getVideoData
{
    __weak AVPlayerItem *tempItem = self.playerItem;
    __weak UISlider *tempSlider = self.slider;
    __weak typeof(self) weakSelf = self;
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        //当前时间
        CGFloat current = self.playerItem.currentTime.value / self.playerItem.currentTime.timescale;
        NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:current];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];//设置时区
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *currentTimeValue = [dateFormatter stringFromDate:detailDate];
        weakSelf.currentTimeLabel.text = currentTimeValue;
        
        //总时间
        
        float totalTime = CMTimeGetSeconds(tempItem.duration);
        NSDate *totalDate = [NSDate dateWithTimeIntervalSince1970:totalTime];
        NSString *allTimeValue = [dateFormatter stringFromDate:totalDate];
        weakSelf.allTimeLabel.text = allTimeValue;
        
        float sliderValue = current;
        if (!weakSelf.isSliderDown) {
            tempSlider.value = sliderValue;
            
        }

        
    }];

}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   [super touchesEnded:touches withEvent:event];
    if (self.isFirstButton == YES) {
        self.isClickScreen =! self.isClickScreen;
        if (!self.isClickScreen) {
            self.playButton.alpha = 1;
            self.barView.hidden = NO;
     
        }else{
            self.playButton.alpha = 0;
            self.barView.hidden = YES;

        }
    }else{
        [self.player play];
        [self.playButton setImage:[UIImage imageNamed:@"Player_Play@2x.png"] forState:UIControlStateSelected];
        self.playButton.alpha = 0;
        self.isFirstButton = YES;
        self.isClickScreen = YES;
        self.playButton.selected = !self.playButton.selected;
        if (self.delegate) {
            [self.delegate isCurrentView:self];
        }
    
    }
    
}

-(void)dealloc
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}




@end
