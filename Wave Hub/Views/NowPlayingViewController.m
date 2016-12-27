//
//  NowPlayingViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 27/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "NowPlayingViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "LGHorizontalLinearFlowLayout.h"

#import "MusicCoverCollectionViewCell.h"

@interface NowPlayingViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSInteger currentPage;
    
    NSInteger currentPlayingIdx;
}

@property (strong, nonatomic) NSArray <WHTrackModel *> *dataSource;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *placeholderIndictor;
@property (weak, nonatomic) IBOutlet UISlider *songProgressSlider;

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *backwardButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (strong, nonatomic) LGHorizontalLinearFlowLayout *collectionViewLayout;

@end

@implementation NowPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    FAKFontAwesome *prevIcon =  [FAKFontAwesome backwardIconWithSize:17];
    [prevIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.backwardButton setAttributedTitle:prevIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *forwardIcon =  [FAKFontAwesome forwardIconWithSize:17];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.forwardButton setAttributedTitle:forwardIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *playPauseIcon = [FAKFontAwesome pauseIconWithSize:20];
    [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.playPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *downIcon =  [FAKFontAwesome angleDownIconWithSize:17];
    [downIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.closeButton setAttributedTitle:downIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *randomIcon =  [FAKFontAwesome randomIconWithSize:17];
    [randomIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.randomButton setAttributedTitle:randomIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *repostIcon =  [FAKFontAwesome retweetIconWithSize:17];
    [repostIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.repostButton setAttributedTitle:repostIcon.attributedString forState:UIControlStateNormal];
    
    FAKFontAwesome *favoriteIcon =  [FAKFontAwesome heartIconWithSize:17];
    [favoriteIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [self.favoriteButton setAttributedTitle:favoriteIcon.attributedString forState:UIControlStateNormal];
    
    [self configureCollectionView];
    [self configureDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTracksArray:)
                                                 name:WHSoundPlayerDidLoadMore
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingProgress:)
                                                 name:WHSoundTrackProgressNotifiction
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scrollToPage:currentPlayingIdx animated:YES];
    
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.collectionView.alpha = 1.0;
                         self.placeholderIndictor.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Configuration

- (void)configureCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:@"MusicCoverCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:@"MusicCoverCollectionViewCell"];
    
    self.collectionViewLayout = [LGHorizontalLinearFlowLayout layoutConfiguredWithCollectionView:self.collectionView
                                                                                        itemSize:CGSizeMake(250, 250)
                                                                              minimumLineSpacing:0];
}

- (void)configureDataSource {
    self.dataSource = [[WHSoundManager sharedManager] nowPlayingTrackWithLimit:30];
    
    WHTrackModel *currentPlaying = [[WHSoundManager sharedManager] playingTrack];
    
    currentPlayingIdx = [self.dataSource indexOfObject:currentPlaying];
    
    self.songNameLabel.text = currentPlaying.trackTitle;
    self.authorLabel.text = currentPlaying.author;
    
//    [self.collectionView reloadData];
    
    
    
}

- (void)configurePageControl {
    
}

- (void)configureButtons {
    
}

#pragma mark - Actions
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

- (IBAction)showMoreButtonPressed:(id)sender {
}

- (IBAction)pageControlValueChanged:(id)sender {
}

- (IBAction)nextButtonAction:(id)sender {
}

- (IBAction)previousButtonAction:(id)sender {
    
}
- (IBAction)songDurationChanged:(id)sender {
    [[WHSoundManager sharedManager] playerSeekTime:self.songProgressSlider.value];
}

- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated {
    [self.collectionView scrollRectToVisible:CGRectMake(page * [self pageWidth], 0.0, 250, 250) animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MusicCoverCollectionViewCell *cell =
    (MusicCoverCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MusicCoverCollectionViewCell"
                                                                    forIndexPath:indexPath];
    
    [cell setInfo:self.dataSource[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking) return;
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[MusicCoverCollectionViewCell class]]) {
        MusicCoverCollectionViewCell *musicCell = (MusicCoverCollectionViewCell *)cell;
        [musicCell cancelImageLoad];
    }
}

#pragma mark - UICollectionViewDelegate
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    if (--self.animationsCount > 0) return;
//    self.collectionView.userInteractionEnabled = YES;
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    currentPage = (int) (self.contentOffset / self.pageWidth);
    
    [self didTogglePlayPause:self.dataSource[currentPage]];
}

#pragma mark - Convenience

- (CGFloat)pageWidth {
    return self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing;
}

- (CGFloat)contentOffset {
    return self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
}


#pragma mark - Player Related

- (void)didTogglePlayPause:(WHTrackModel *)info{
    
    
    if ([[WHSoundManager sharedManager] isPlaying]) {
        if ([[WHSoundManager sharedManager] playingTrack] == info) {
            // Do noting
        }else{
            [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
    }
}

- (void)didUpdatePlayingProgress:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSNumber class]]) {
        if(!self.songProgressSlider.isTracking) {
            self.songProgressSlider.value = [info.object floatValue];
        }
        
    }else if ([info.object isKindOfClass:[NSNull class]]) {
        
    }
}

- (void)didUpdatePlayingTrack:(NSNotification *)info{
    
    if ([info.object isKindOfClass:[WHTrackModel class]]) {
        FAKFontAwesome *playPauseIcon = [FAKFontAwesome pauseIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.playPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
        
        WHTrackModel *aTrack = (WHTrackModel *)info.object;
        self.songNameLabel.text = aTrack.trackTitle;
        self.authorLabel.text = aTrack.author;
        currentPlayingIdx = [self.dataSource indexOfObject:aTrack];
        
        [self.collectionView reloadData];
        [self scrollToPage:currentPlayingIdx animated:YES];
        
    }else if ([info.object isKindOfClass:[NSNull class]]) {
        FAKFontAwesome *playPauseIcon = [FAKFontAwesome playIconWithSize:20];
        [playPauseIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.playPauseButton setAttributedTitle:playPauseIcon.attributedString forState:UIControlStateNormal];
    }
}

- (void)didUpdatePlayingTracksArray:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSArray class]]) {
        self.dataSource = (NSArray *)info.object;
        
        [self.collectionView reloadData];
    }
}

@end
