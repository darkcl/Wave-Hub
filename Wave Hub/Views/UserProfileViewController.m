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
        
        currentPlayingProgress = -1;
        currentPlayingIndex = -1;
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
    [[WHWebrequestManager sharedManager] fetchTracksForUserId:userInfo.userId
                                                         info:nil
                                                      success:^(NSArray <WHTrackModel *> *responseObject) {
                                                          self->userTracks =  responseObject;
                                                          [self.tableView reloadData];
                                                      }
                                                      failure:^(NSError *error) {
                                                          
                                                      }];
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[WHSoundManager sharedManager] setDataSource:nil];
    [[WHSoundManager sharedManager] setDelegate:nil];
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
    currentPlayingProgress = -1.0;
    currentPlayingIndex = -1;
    [_tableView reloadData];
}

- (void)didUpdatePlayingProgress:(float)progress{
    currentPlayingProgress = progress;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentPlayingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didUpdatePlayingTrack:(WHTrackModel *)info{
    currentPlayingIndex = [userTracks indexOfObject:info];
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

- (NSString *)timeFormatted:(int)totalMillSeconds{
    
    int totalSeconds = totalMillSeconds/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MusicTableViewCell";
    
    MusicTableViewCell *cell = (MusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MusicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    WHTrackModel *info = userTracks[indexPath.row];
    [cell setInfo:info];
    
    cell.titleLabel.text = info.trackTitle;
    cell.authorLabel.text = info.author ? info.author : @"";
    cell.durationLabel.text = [self timeFormatted:(int)info.duration];
    
    cell.progressView.hidden = YES;
    if (indexPath.row == currentPlayingIndex) {
        cell.progressView.hidden = NO;
        cell.progressView.progress = currentPlayingProgress;
        
        FAKFontAwesome *buttonIcon = ([[WHSoundManager sharedManager] isPlaying])? [FAKFontAwesome pauseIconWithSize:17] : [FAKFontAwesome playIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [cell.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }else{
        cell.progressView.hidden = YES;
        FAKFontAwesome *buttonIcon =  [FAKFontAwesome playIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [cell.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }
    
    cell.cellDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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

#pragma mark - Music Cell Delegate

- (void)didTogglePlayPause:(WHTrackModel *)info{
    if ([[WHSoundManager sharedManager] dataSource] != self) {
        [[WHSoundManager sharedManager] setDelegate:self];
        [[WHSoundManager sharedManager] setDataSource:self];
        [[WHSoundManager sharedManager] playerStop];
        
        [[WHSoundManager sharedManager] reloadTracksData];
    }
    
    
    NSInteger playIndex = [userTracks indexOfObject:info];
    
    if ([[WHSoundManager sharedManager] isPlaying]) {
        if (playIndex == currentPlayingIndex) {
            [[WHSoundManager sharedManager] playerPause];
        }else{
            [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
    }
}

@end
