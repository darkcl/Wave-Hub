//
//  ContainerViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "ContainerViewController.h"

#import "UIImage+WaveHubAddition.h"

#import <DLImageLoader/DLImageLoader.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "MarqueeLabel.h"

#import "NowPlayingViewController.h"

#import <ZFDragableModalTransition/ZFModalTransitionAnimator.h>

#import "DashBoardViewController.h"

CGFloat const kMiniPlayerHeight = 65.0f;
CGFloat const kMenuWidth = 184.0f;


@interface ContainerViewController (){
    UIViewController *childVC;
    
    BOOL isMenuShown;
}
@property (strong, nonatomic) IBOutlet UIProgressView *playerProgressView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerBottomConstraint;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseToggleButton;
@property (strong, nonatomic) IBOutlet UIButton *backwardButton;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet MarqueeLabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;

@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuRightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *whatsNewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *settingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playlistsImageView;

@end

@implementation ContainerViewController

- (id)initWithContentViewController:(UIViewController *)controller{
    if (self = [super initWithNibName:@"ContainerViewController" bundle:nil]) {
        childVC = controller;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.coverImageView.image = [UIImage musicPlaceHolder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    
    isMenuShown = NO;
    
    [[WHSoundManager sharedManager] addActiveProgressViews:self.playerProgressView];
    
    FAKFontAwesome *playIcon =  [FAKFontAwesome pauseIconWithSize:17];
    [playIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.playPauseToggleButton setAttributedTitle:playIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *forwardIcon =  [FAKFontAwesome forwardIconWithSize:17];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.forwardButton setAttributedTitle:forwardIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *backwardIcon =  [FAKFontAwesome backwardIconWithSize:17];
    [backwardIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.backwardButton setAttributedTitle:backwardIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *heartIcon = [FAKFontAwesome heartIconWithSize:13];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    heartIcon.drawingBackgroundColor = [UIColor clearColor];
    self.favoriteImageView.image = [heartIcon imageWithSize:CGSizeMake(30, 30)];
    
    FAKFontAwesome *newsIcon = [FAKFontAwesome newspaperOIconWithSize:13];
    [newsIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    newsIcon.drawingBackgroundColor = [UIColor clearColor];
    self.whatsNewImageView.image = [newsIcon imageWithSize:CGSizeMake(30, 30)];
    
    FAKFontAwesome *listIcon = [FAKFontAwesome listUlIconWithSize:13];
    [listIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    listIcon.drawingBackgroundColor = [UIColor clearColor];
    self.playlistsImageView.image = [listIcon imageWithSize:CGSizeMake(30, 30)];
    
    FAKFontAwesome *settingsIcon = [FAKFontAwesome cogIconWithSize:13];
    [settingsIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    settingsIcon.drawingBackgroundColor = [UIColor clearColor];
    self.settingImageView.image = [settingsIcon imageWithSize:CGSizeMake(30, 30)];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self addChildViewController:childVC];
    
    [childVC beginAppearanceTransition:YES animated:YES];
    [self.containerView addSubview:childVC.view];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:childVC.view
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:childVC.view
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:childVC.view
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:childVC.view
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0
                                                                    constant:0]];
    [self.containerView layoutIfNeeded];
    
    [childVC endAppearanceTransition];
    [self.view updateConstraints];
    
    [childVC didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (void)showMiniPlayer{
    self.playerBottomConstraint.constant = 0.0f;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)hideMiniPlayer{
    self.playerBottomConstraint.constant = -kMiniPlayerHeight;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}
- (IBAction)showMusicDetail:(id)sender {
    NowPlayingViewController *modalVC = [[NowPlayingViewController alloc] initWithNibName:@"NowPlayingViewController" bundle:nil];
    modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.5f;
    self.animator.transitionDuration = 0.7f;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    
    [self.animator setContentScrollView:modalVC.collectionView];
    
    [modalVC setDidAddFavorite:^(WHTrackModel *info) {
        [[WHDatabaseManager sharedManager] addFavoriteTrack:info];
    }];
    
    [modalVC setDidRemoveFavorite:^(WHTrackModel *info) {
        [[WHDatabaseManager sharedManager] removeFavoriteTrack:info];
    }];
    
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}
- (IBAction)settingButtonPressed:(id)sender {
    self.menuRightConstraint.constant = -kMenuWidth;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    isMenuShown = NO;
    
    // TODO: Show setting?
}

- (IBAction)playlistButtonPressed:(id)sender {
    
    self.menuRightConstraint.constant = -kMenuWidth;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    isMenuShown = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WHMenuPressPlayListsNotifiction object:nil];
}

- (IBAction)whatsNewButtonPressed:(id)sender {
    
    self.menuRightConstraint.constant = -kMenuWidth;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    isMenuShown = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WHMenuPressWhatsNewNotifiction object:nil];
}

- (IBAction)favoriteButtonPressed:(id)sender {
    
    self.menuRightConstraint.constant = -kMenuWidth;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    isMenuShown = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WHMenuPressFavoriteNotifiction object:nil];
}

- (IBAction)menuButtonPressed:(id)sender {
    if (isMenuShown) {
        self.menuRightConstraint.constant = -kMenuWidth;
    }else{
        self.menuRightConstraint.constant = 0.0f;
    }
    
    isMenuShown = !isMenuShown;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)didUpdatePlayingTrack:(NSNotification *)info{
    
    if ([info.object isKindOfClass:[WHTrackModel class]]) {
        WHTrackModel *aTrack = (WHTrackModel *)info.object;
        if (aTrack.albumCoverImage != nil){
            self.coverImageView.image = aTrack.albumCoverImage;
        }else{
            if ([aTrack.albumCoverUrl isKindOfClass:[NSString class]]) {
                [[DLImageLoader sharedInstance] imageFromUrl:aTrack.albumCoverUrl
                                                   completed:^(NSError *error, UIImage *image) {
                                                       if (error == nil && image != nil) {
                                                           self.coverImageView.image = image;
                                                       }else{
                                                           self.coverImageView.image = [UIImage musicPlaceHolder];
                                                       }
                                                   }];
            }else{
                self.coverImageView.image = [UIImage musicPlaceHolder];
            }
        }
        
        self.authorLabel.text = aTrack.author;
        self.songNameLabel.text = aTrack.trackTitle;
        [self showMiniPlayer];
    }else if ([info.object isKindOfClass:[NSNull class]]) {
        [self hideMiniPlayer];
    }
}
- (IBAction)playPauseTogglePressed:(id)sender {
    if ([[WHSoundManager sharedManager] isPlaying]) {
        [[WHSoundManager sharedManager] playerPause];
        
    }else{
        [[WHSoundManager sharedManager] playerPlay];
    }
    
}
- (IBAction)backwardButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerBackward];
}
- (IBAction)forwardButtonPressed:(id)sender {
    [[WHSoundManager sharedManager] playerForward];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
