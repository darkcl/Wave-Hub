//
//  MusicDetailViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "MusicDetailViewController.h"
#import "UserProfileViewController.h"

#import "UIImage+WaveHubAddition.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <DLImageLoader/DLImageLoader.h>

#import "WHAppDelegate.h"
#import "WHSoundCloudUser.h"
@interface MusicDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *togglePlayPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewMoreLabel;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndictorView;
@property (strong, nonatomic) IBOutlet UIProgressView *playingProgress;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *musicCoverImageView;
@end

@implementation MusicDetailViewController

- (id)initWithTrackInfo:(WHTrackModel *)info withDataSources:(NSArray <WHTrackModel *> *)tracks{
    if (self = [super initWithNibName:@"MusicDetailViewController" bundle:nil]) {
        trackInfo = info;
        
        currentTrack = [[WHSoundManager sharedManager] playingTrack];
        sourceTracks = tracks;
    }
    return self;
}

- (NSArray <WHTrackModel *> *)currentPlayingTracks{
    return sourceTracks;
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
    
    _authorLabel.text = trackInfo.author;
    _musicTitleLabel.text = trackInfo.trackTitle;
    
    FAKFontAwesome *prevIcon =  [FAKFontAwesome backwardIconWithSize:17];
    [prevIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.prevButton setAttributedTitle:prevIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *forwardIcon =  [FAKFontAwesome forwardIconWithSize:17];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.forwardButton setAttributedTitle:forwardIcon.attributedString forState:UIControlStateNormal];
    
    if (trackInfo != currentTrack){
        self.forwardButton.hidden = YES;
        self.prevButton.hidden = YES;
        FAKFontAwesome *playPauseIcon =  [FAKFontAwesome playIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    }else{
        self.forwardButton.hidden = NO;
        self.prevButton.hidden = NO;
        FAKFontAwesome *playPauseIcon =  ([[WHSoundManager sharedManager] isPlaying]) ? [FAKFontAwesome pauseIconWithSize:20] :[FAKFontAwesome playIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    }
    
    //Set up user
    NSString *userAvatar = [[trackInfo.responseDict objectForKey:@"user"] objectForKey:@"avatar_url"];
    [_loadingIndictorView startAnimating];
    if (userAvatar != nil || ![userAvatar isKindOfClass:[NSNull class]]) {
        NSString *tempUrl = [userAvatar stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
        [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                           completed:^(NSError *error, UIImage *image) {
                                               if (!error) {
                                                   self.userImageView.image = image;
                                                   [self.loadingIndictorView stopAnimating];
                                               }
                                           }];
    }
    
    self.viewMoreLabel.text = [NSString stringWithFormat:@"View more from %@", [[trackInfo.responseDict objectForKey:@"user"] objectForKey:@"username"]];
    
    FAKFontAwesome *downloadIcon =  [FAKFontAwesome downloadIconWithSize:25];
    [downloadIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [self.downloadButton setAttributedTitle:downloadIcon.attributedString forState:UIControlStateNormal];
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
//    [self ysl_removeTransitionDelegate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
    [[WHSoundManager sharedManager] setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingProgress:)
                                                 name:WHSoundProgressDidChangeNotifiction
                                               object:nil];
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

- (void)didUpdatePlayingProgress:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSNumber class]]) {
        float progress = [((NSNumber *)info.object) floatValue];
        
        [_playingProgress setProgress:progress animated:YES];
    }
}

- (void)didUpdatePlayingTrack:(NSNotification *)track{
    if ([track.object isKindOfClass:[WHTrackModel class]]) {
        WHTrackModel *info = (WHTrackModel *)track.object;
        currentTrack = info;
        
        _authorLabel.text = info.author;
        _musicTitleLabel.text = info.trackTitle;
        self.musicCoverImageView.image = nil;
        if (info.albumCoverUrl != nil && ![info.albumCoverUrl isKindOfClass:[NSNull class]]) {
            NSString *tempUrl = [info.albumCoverUrl stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
            [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                               completed:^(NSError *error, UIImage *image) {
                                                   if (!error) {
                                                       self.musicCoverImageView.image = image;
                                                   }
                                               }];
        }else{
            self.musicCoverImageView.image = [UIImage musicPlaceHolder];
        }
        trackInfo = info;
        
        //Set up user
        NSString *userAvatar = [[trackInfo.responseDict objectForKey:@"user"] objectForKey:@"avatar_url"];
        
        if (userAvatar != nil || ![userAvatar isKindOfClass:[NSNull class]]) {
            NSString *tempUrl = [userAvatar stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
            [_loadingIndictorView startAnimating];
            _userImageView.image = nil;
            
            [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                               completed:^(NSError *error, UIImage *image) {
                                                   if (!error) {
                                                       self.userImageView.image = image;
                                                       [self.loadingIndictorView stopAnimating];
                                                   }
                                               }];
        }
        
        self.viewMoreLabel.text = [NSString stringWithFormat:@"View more from %@", [[trackInfo.responseDict objectForKey:@"user"] objectForKey:@"username"]];
        
        self.forwardButton.hidden = NO;
        self.prevButton.hidden = NO;
        FAKFontAwesome *playPauseIcon = [FAKFontAwesome pauseIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
        
    }else if ([track.object isKindOfClass:[NSNull class]]) {
        // Player stops
        [_playingProgress setProgress:0.0 animated:NO];
        
        [self.prevButton setHidden:YES];
        [self.forwardButton setHidden:YES];
        
        FAKFontAwesome *playPauseIcon = [FAKFontAwesome playIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.togglePlayPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    }
    
    
}
- (IBAction)viewMoreButtonPressed:(id)sender {
    [SVProgressHUD show];
    
    [[WHWebrequestManager sharedManager] fetchUserInfoWithUserId:[trackInfo.responseDict[@"user"][@"id"] stringValue]
                                                         success:^(id responseObject) {
                                                             [SVProgressHUD dismiss];
                                                             
                                                             UserProfileViewController *detailVC = [[UserProfileViewController alloc] initWithUser:[[WHSoundCloudUser alloc] initWithUserInfo:responseObject]];
                                                             UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:detailVC];
                                                             
                                                             [navVC.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
                                                             [navVC.navigationBar setShadowImage:[[UIImage alloc] init]];
                                                             navVC.navigationBar.barTintColor = [UIColor clearColor];
                                                             
                                                             navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                                                             navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                                             self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                                             [self presentViewController:navVC animated:YES completion:nil];
                                                         }
                                                         failure:^(NSError *error) {
                                                             [SVProgressHUD dismiss];
                                                         }];
    
    
}

- (IBAction)togglePlayPausePressed:(id)sender {
    if ([[WHSoundManager sharedManager] isPlaying] && currentTrack == trackInfo) {
        [[WHSoundManager sharedManager] playerPause];
    }else{
        [[WHSoundManager sharedManager] playTrack:trackInfo forceStart:YES];
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
