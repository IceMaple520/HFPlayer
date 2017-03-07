//
//  ViewController.m
//  HFAVPlayer
//
//  Created by 司华锋 on 2017/3/7.
//  Copyright © 2017年 HF. All rights reserved.
//

#import "ViewController.h"
#import "HPlayerView.h"
#define __WIDTH   [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<HPlayerViewDelegate>
@property (nonatomic,strong) HPlayerView *playerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUI];
}
- (void)setUI
{
    _playerView = [[HPlayerView alloc] initWithFrame:CGRectMake(0, 64, __WIDTH, 250) urlString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    _playerView.delegate = self;
    _playerView.tag = 300;
    [self.view addSubview:_playerView];
}
- (void)changeMaxView:(UIView *)view
{
    [self.view bringSubviewToFront:view];
    self.navigationController.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
}
- (void)changeMinView:(UIView *)view
{
    self.navigationController.tabBarController.tabBar.hidden = NO;
    
    self.navigationController.navigationBar.hidden = NO;
}
- (void)isCurrentView:(UIView *)view
{
    if (self.playerView == nil) {
        self.playerView = (HPlayerView*)view;
        
    }else if(self.playerView.tag == view.tag){
        
        NSLog(@"%ld",(long)self.playerView.tag);
        
    }else{
        
        [self.playerView.player pause];
        self.playerView.playButton.selected = NO;
        self.playerView.playButton.alpha = 1 ;
        self.playerView = (HPlayerView*)view;
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
