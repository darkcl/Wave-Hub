//
//  MusicDetailViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "MusicDetailViewController.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <DLImageLoader/DLImageLoader.h>

@interface MusicDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *togglePlayPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;

@property (strong, nonatomic) IBOutlet UIProgressView *playingProgress;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *musicCoverImageView;
@end

@implementation MusicDetailViewController

- (id)initWithTrackInfo:(WHTrackModel *)info{
    if (self = [super initWithNibName:@"MusicDetailViewController" bundle:nil]) {
        musicName = info.trackTitle;
        author = info.author;
        currentTrack = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 36, 36);
    FAKFontAwesome *buttonIcon =  [FAKFontAwesome chevronLeftIconWithSize:17.0f];
    [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    
    [backButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.titleView = nil;
    
    _authorLabel.text = author;
    _musicTitleLabel.text = musicName;
    
    FAKFontAwesome *prevIcon =  [FAKFontAwesome backwardIconWithSize:17];
    [prevIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.prevButton setAttributedTitle:prevIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *playPauseIcon =  ([[WHSoundManager sharedManager] isPlaying]) ? [FAKFontAwesome pauseIconWithSize:20] :[FAKFontAwesome playIconWithSize:20];
    [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *forwardIcon =  [FAKFontAwesome forwardIconWithSize:17];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.forwardButton setAttributedTitle:forwardIcon.attributedString forState:UIControlStateNormal];
}

- (void)backButtonPressed:(id)sender{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self ysl_removeTransitionDelegate];
    
    [[WHSoundManager sharedManager] setDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[WHSoundManager sharedManager] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.musicCoverImageView.layer.shadowColor = [UIColor blackColor].CGColor;\
    self.musicCoverImageView.layer.shadowOffset = CGSizeMake(0, 15);
    self.musicCoverImageView.layer.shadowRadius = 15;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:0.3f];
    anim.duration = 0.2;
    [self.musicCoverImageView.layer addAnimation:anim forKey:@"shadowOpacity"];
    self.musicCoverImageView.layer.shadowOpacity = 0.3f;
}

- (void)soundDidStop{
    [_playingProgress setProgress:0.0f animated:YES];
    
    FAKFontAwesome *playPauseIcon =  [FAKFontAwesome playIconWithSize:17];
    [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
}

- (void)didUpdatePlayingProgress:(float)progress{
    [_playingProgress setProgress:progress animated:YES];
    
    FAKFontAwesome *playPauseIcon =  ([[WHSoundManager sharedManager] isPlaying] && [[[WHSoundManager sharedManager] playingTrack].responseDict isEqual:currentTrack.responseDict]) ? [FAKFontAwesome pauseIconWithSize:20] :[FAKFontAwesome playIconWithSize:20];
    [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
}

- (void)didUpdatePlayingTrack:(WHTrackModel *)info{
    _authorLabel.text = info.author;
    _musicTitleLabel.text = info.trackTitle;
    NSString *tempUrl = [info.albumCoverUrl stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
    [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                       completed:^(NSError *error, UIImage *image) {
                                           if (!error) {
                                               self.musicCoverImageView.image = image;
                                           }
                                       }];
    currentTrack = info;
}

- (IBAction)togglePlayPausePressed:(id)sender {
    if ([[WHSoundManager sharedManager] isPlaying] && [[[WHSoundManager sharedManager] playingTrack].responseDict isEqual:currentTrack.responseDict]) {
        [[WHSoundManager sharedManager] playerPause];
    }else{
        [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(NSArray <WHTrackModel *> *result) {
            NSInteger index = [result indexOfObject:self->currentTrack];
            NSInteger idx = 0;
            for (WHTrackModel *info in result) {
                if ([info.responseDict isEqual:self->currentTrack.responseDict]) {
                    index = idx;
                }
                idx++;
            }
            
            [[WHSoundManager sharedManager] playMyFavourite:result withIndex:index forceStart:YES];
        }];
    }
    
    
}

- (IBAction)forwardButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerForward];
}

- (IBAction)prevButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerBackward];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- YSLTransitionAnimatorDataSource

- (UIImageView *)pushTransitionImageView
{
    return nil;
}

- (UIImageView *)popTransitionImageView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.musicCoverImageView.center = CGPointMake(bounds.size.width / 2, (250 / 2) + 26);
    
    return self.musicCoverImageView;
}

@end
