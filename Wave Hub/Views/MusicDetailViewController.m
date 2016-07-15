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

- (id)initWithMusicName:(NSString *)name
             authorName:(NSString *)authorName
        withCollections:(NSArray *)collections{
    if (self = [super initWithNibName:@"MusicDetailViewController" bundle:nil]) {
        musicName = name;
        author = authorName;
        currentPlayingCollection = collections;
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
    
    FAKFontAwesome *playPauseIcon =  ([[WHSoundManager sharedManager] isPlaying]) ? [FAKFontAwesome pauseIconWithSize:20] :[FAKFontAwesome playIconWithSize:20];
    [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
}

- (void)didUpdatePlayingIndex:(NSInteger)index{
    Collection *info = currentPlayingCollection[index];
    
    _musicTitleLabel.text = info.title;
    _authorLabel.text = info.user.username;
    
    if (![info.artworkUrl isKindOfClass:[NSNull class]]) {
        [[DLImageLoader sharedInstance] imageFromUrl:[info.artworkUrl stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"]
                                           completed:^(NSError *error, UIImage *image) {
                                               if (!error) {
                                                    self.musicCoverImageView.image = image;
                                               }
                                           }];
    }
    
}
- (IBAction)togglePlayPausePressed:(id)sender {
    if ([[WHSoundManager sharedManager] isPlaying]) {
        [[WHSoundManager sharedManager] playerPause];
    }else{
        
        if ([[WHSoundManager sharedManager] playingIdx] == -1) {
            MyFavourite *favourite = [[MyFavourite alloc] init];
            favourite.collection = currentPlayingCollection;
            [[WHSoundManager sharedManager] playMyFavourite:favourite withIndex:_currentIndex forceStart:YES];
        }else{
            [[WHSoundManager sharedManager] playerPlay];
        }
    }
    
    
}

- (IBAction)forwardButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerForward];
}

- (IBAction)prevButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerBackward];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
//    [self ysl_addTransitionDelegate:self];
//    [self ysl_popTransitionAnimationWithCurrentScrollView:nil
//                                    cancelAnimationPointY:self.musicCoverImageView.frame.size.height - (statusHeight + navigationHeight)
//                                        animationDuration:0.3
//                                  isInteractiveTransition:YES];
//}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
//    [self ysl_addTransitionDelegate:self];
//    [self ysl_popTransitionAnimationWithCurrentScrollView:nil
//                                    cancelAnimationPointY:self.musicCoverImageView.frame.size.height - (statusHeight + navigationHeight)
//                                        animationDuration:0.3
//                                  isInteractiveTransition:NO];
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
