//
//  UserProfileViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "UserProfileViewController.h"

#import "WHSoundCloudUser.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <DLImageLoader/DLImageLoader.h>

#import "PlaceholderTableViewCell.h"

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfLikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfFollowinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfPlaylistLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *fakeNavBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation UserProfileViewController

- (id)initWithUser:(WHSoundCloudUser *)aUser{
    if (self = [super initWithNibName:@"UserProfileViewController" bundle:nil]) {
        userInfo = aUser;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 36, 36);
    FAKFontAwesome *buttonIcon =  [FAKFontAwesome timesIconWithSize:17.0f];
    [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    
    [backButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.titleView = nil;
    
    NSString *userAvatar = userInfo.avatarUrl;
    if (userAvatar != nil || ![userAvatar isKindOfClass:[NSNull class]]) {
        NSString *tempUrl = [userAvatar stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
        [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                           completed:^(NSError *error, UIImage *image) {
                                               if (!error) {
                                                   self.userImageView.image = image;
                                                   self.backgroundImage.image = image;
                                               }
                                           }];
    }
    
    //https://api.soundcloud.com/users/%@/tracks
    
    [[WHWebrequestManager sharedManager] fetchTracksWithUrl:[NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks", userInfo.userId]
                                                    success:^(id responseObject) {
                                                        self->userTracks =  responseObject;
                                                        [self.tableView reloadData];
                                                    }
                                                    failure:^(NSError *error) {
                                                        
                                                    }];
    
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PlaceholderTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlaceholderTableViewCell"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setSecondaryGroupingSize:3];
    
    _numOfLikesLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:userInfo.favoritesCount]];
    _numOfFollowinsLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:userInfo.followingsCount]];
    _numOfPlaylistLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:userInfo.playlistsCount]];
    
    _userNameLabel.text = userInfo.userName;
    _titleLabel.text = userInfo.userName;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTracksArray:)
                                                 name:WHSoundPlayerDidLoadMore
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[WHSoundManager sharedManager] setDataSource:nil];
    [[WHSoundManager sharedManager] setDelegate:nil];
}

- (void)didUpdatePlayingTracksArray:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSArray class]]) {
        userTracks = (NSArray *)info.object;
        [_tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat alpha = (scrollView.contentOffset.y - (434 - 224.0 + 17.0f)) / (224.0 + 17.0f);
    
    if (alpha > 1.0) {
        alpha = 1.0;
    }
    
    _fakeNavBarView.alpha = alpha;
    
}

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
        if ([[WHSoundManager sharedManager] playingTrack] == currentPlayingTrack) {
            [[WHSoundManager sharedManager] playerPause];
        }else{
            [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
    }
}

@end
