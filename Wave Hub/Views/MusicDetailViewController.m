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

#import "WHAppDelegate.h"
#import "PlaceholderTableViewCell.h"

@interface MusicDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *togglePlayPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewMoreLabel;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndictorView;
@property (strong, nonatomic) IBOutlet UIProgressView *playingProgress;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *musicCoverImageView;

@property (weak, nonatomic) IBOutlet UILabel *numOfLikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfFollowinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfPlaylistLabel;
@property (strong, nonatomic) IBOutlet UIButton *followButton;

@end

@implementation MusicDetailViewController

- (id)initWithTrackInfo:(WHTrackModel *)info withDataSources:(NSArray <WHTrackModel *> *)tracks{
    if (self = [super initWithNibName:@"MusicDetailViewController" bundle:nil]) {
        trackInfo = info;
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
    
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PlaceholderTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlaceholderTableViewCell"];
    
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
    
    
    
    
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PlaceholderTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlaceholderTableViewCell"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setSecondaryGroupingSize:3];
    
    [SVProgressHUD show];
    
    [[WHWebrequestManager sharedManager] fetchUserInfoWithUserId:[trackInfo.responseDict[@"user"][@"id"] stringValue]
                                                         success:^(id responseObject) {
                                                             self->currentUser = [[WHSoundCloudUser alloc] initWithUserInfo:responseObject];
                                                             [SVProgressHUD popActivity];
                                                             
                                                             
                                                             self.numOfLikesLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:self->currentUser.favoritesCount]];
                                                             self.numOfFollowinsLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:self->currentUser.followingsCount]];
                                                             self.numOfPlaylistLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:self->currentUser.playlistsCount]];
                                                             
                                                             [SVProgressHUD show];
                                                             [[WHWebrequestManager sharedManager] fetchTracksWithUrl:[NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks", self->currentUser.userId]
                                                                                                             success:^(id responseObject2) {
                                                                                                                 [SVProgressHUD popActivity];
                                                                                                                 self->userTracks =  responseObject2;
                                                                                                                 [self.tableView reloadData];
                                                                                                             }
                                                                                                             failure:^(NSError *error) {
                                                                                                                 [SVProgressHUD dismiss];
                                                                                                             }];
                                                             
                                                             [SVProgressHUD show];
                                                             [[WHWebrequestManager sharedManager] fetchIsFollowUserId:self->currentUser.userId
                                                                                                              success:^(NSNumber *isFollowingObj) {
                                                                                                                  [SVProgressHUD popActivity];
                                                                                                                  BOOL isFollowing = [isFollowingObj boolValue];
                                                                                                                  self->currentUser.isFollowing = isFollowing;
                                                                                                                  
                                                                                                                  [self.followButton setTitle:isFollowing ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
                                                                                                              }
                                                                                                              failure:^(NSError *error) {
                                                                                                                  [SVProgressHUD dismiss];
                                                                                                              }];
                                                             
                                                         }
                                                         failure:^(NSError *error) {
                                                             [SVProgressHUD dismiss];
                                                         }];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTracksArray:)
                                                 name:WHSoundPlayerDidLoadMore
                                               object:nil];
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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.musicCoverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.musicCoverImageView.layer.shadowOffset = CGSizeMake(0, 15);
    self.musicCoverImageView.layer.shadowRadius = 15;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:0.3f];
    anim.duration = 0.2;
    [self.musicCoverImageView.layer addAnimation:anim forKey:@"shadowOpacity"];
    self.musicCoverImageView.layer.shadowOpacity = 0.3f;
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
                                                             
                                                             WHAppDelegate *appDelegate = (WHAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                             
                                                             [appDelegate.window.rootViewController presentViewController:navVC animated:YES completion:nil];
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

#pragma mark - WHSoundManagerDelegate

- (void)soundDidStop{
    [_tableView reloadData];
}

- (void)didUpdatePlayingTrack:(NSNotification *)info{
    
    if ([info.object isKindOfClass:[WHTrackModel class]]) {
        WHTrackModel *aTrack = (WHTrackModel *)info.object;
        currentPlayingTrack = aTrack;
    }else if ([info.object isKindOfClass:[NSNull class]]) {
        currentPlayingTrack = nil;
    }
    [_tableView reloadData];
}

- (void)didUpdatePlayingTracksArray:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSArray class]]) {
        userTracks = (NSArray *)info.object;
        [_tableView reloadData];
    }
}

#pragma mark - WHSoundManagerDatasource

- (NSArray <WHTrackModel *> *)currentPlayingTracks{
    return userTracks;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return userTracks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSInteger currentPlayingIndex = [userTracks indexOfObject:currentPlayingTrack];
    
    // Configure the cell...
    WHTrackModel *info = userTracks[indexPath.row];
    
    if (info.trackType == WHTrackTypePlaceHolder) {
        PlaceholderTableViewCell *cell = (PlaceholderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaceholderTableViewCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[PlaceholderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceholderTableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        MusicTableViewCell *cell = (MusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MusicTableViewCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[MusicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MusicTableViewCell"];
        }
        [cell setInfo:info isCurrentlyPlaying:(currentPlayingIndex == indexPath.row)];
        
        cell.cellDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 44.0f;
 }
 */

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    WHTrackModel *info = userTracks[indexPath.row];
    
    if (info.trackType == WHTrackTypePlaceHolder) {
        [[WHWebrequestManager sharedManager] fetchTracksWithUrl:info.nextHref
                                                        success:^(NSArray *responseObject) {
                                                            NSMutableArray *result = [NSMutableArray arrayWithArray:self->userTracks];
                                                            [result removeLastObject];
                                                            [result addObjectsFromArray:responseObject];
                                                            self->userTracks =  result;
                                                            [self.tableView reloadData];
                                                            
                                                            if ([[WHSoundManager sharedManager] dataSource] == self) {
                                                                [[WHSoundManager sharedManager] reloadTracksData];
                                                            }
                                                        }
                                                        failure:^(NSError *error) {
                                                            
                                                        }];
    }else{
        MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
        [musicCell startLoadingCover:info.albumCoverUrl];
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WHTrackModel *info = userTracks[indexPath.row];
    
    if (info.trackType != WHTrackTypePlaceHolder && [cell isKindOfClass:[MusicTableViewCell class]]) {
        MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
        [musicCell cancelLoadingCover];
    }
}

#pragma mark - Music Cell Delegate

- (void)didTogglePlayPause:(WHTrackModel *)info{
    if ([[WHSoundManager sharedManager] isPlaying]) {
        if ([[WHSoundManager sharedManager] playingTrack] == info) {
            [[WHSoundManager sharedManager] playerPause];
        }else{
            [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
    }
}

@end
