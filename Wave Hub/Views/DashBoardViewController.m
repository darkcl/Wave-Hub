//
//  DashBoardViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "DashBoardViewController.h"
#import "DashBoardSectionHeaderView.h"

#import "DashBoardFavoritesTableViewCell.h"
#import "DashBoardPlaylistsTableViewCell.h"

#import "FavoritesViewController.h"

#import "DashboardWhatsNewTableViewCell.h"

#import "WHActivityModel.h"

#import "PlaceholderTableViewCell.h"

NSInteger const kSectionFav = 0;
NSInteger const kSectionPlaylist = 1;
NSInteger const kSectionActivity = 2;

@interface DashBoardViewController () <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDatasource> {
    NSArray <WHTrackModel *> *favourite;
    
    NSArray <WHTrackModel *> *activities;
    
    NSArray <WHPlaylistModel *> *myPlaylists;
    
    NSArray <WHTrackModel *> *selectedSongSet;
    
    WHTrackModel *currentPlayingTrack;
    
    BOOL isMenuShown;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DashBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    
//    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
//    aLabel.text = @"Dashboard";
//    aLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
//    aLabel.textColor = [UIColor blackColor];
//    aLabel.backgroundColor = [UIColor clearColor];
//    aLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = nil;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    isMenuShown = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"DashBoardFavoritesTableViewCell" bundle:nil] forCellReuseIdentifier:@"DashBoardFavoritesTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashboardWhatsNewTableViewCell" bundle:nil] forCellReuseIdentifier:@"DashboardWhatsNewTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlaceholderTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlaceholderTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DashBoardPlaylistsTableViewCell" bundle:nil] forCellReuseIdentifier:@"DashBoardPlaylistsTableViewCell"];
    
    
    
    [[WHWebrequestManager sharedManager] fetchMyPlaylistWithInfo:nil
                                                         success:^(NSArray *responseObject) {
                                                             self->myPlaylists = responseObject;
                                                             [self.tableView reloadData];
                                                         } failure:^(NSError *error) {
                                                             
                                                         }];
    
    [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(id result) {
        if (result == nil) {
            [[WHWebrequestManager sharedManager] fetchAllFavouriteWithInfo:nil
                                                                   success:^(NSArray *responseObject) {
                                                                       
                                                                       [[WHDatabaseManager sharedManager] saveTrackFromFavouriteArray:responseObject];
                                                                       self->favourite = responseObject;
                                                                       
                                                                       [self.tableView reloadData];
                                                                       
                                                                   }
                                                                   failure:^(NSError *error) {
                                                                       
                                                                   }];
        }else{
            self->favourite = result;
            [self.tableView reloadData];
        }
    }];
    
    [[WHWebrequestManager sharedManager] fetchActivityWithUrl:nil
                                                      success:^(NSArray *responseObject) {
                                                          NSLog(@"%@", responseObject);
                                                          
                                                          self->activities = responseObject;
                                                          [self.tableView reloadData];
                                                      }
                                                      failure:^(NSError *error) {
                                                          
                                                      }];
    
    playingType = DashBoardPlayingTypeUnknown;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTracksArray:)
                                                 name:WHSoundPlayerDidLoadMore
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToFavorite)
                                                 name:WHMenuPressFavoriteNotifiction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToPlaylist)
                                                 name:WHMenuPressPlayListsNotifiction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToWhatsNew)
                                                 name:WHMenuPressWhatsNewNotifiction
                                               object:nil];
    
}

- (void)reloadFavorite{
    [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(id result) {
        self->favourite = result;
        [self.tableView reloadData];
    }];
}

- (void)goToFavorite{
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionFav] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)goToPlaylist{
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionPlaylist] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)goToWhatsNew{
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSectionActivity] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[WHSoundManager sharedManager] setDataSource:self];
    
    [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(id result) {
        self->favourite = result;
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

- (NSArray <WHTrackModel *> *)currentPlayingTracks{
    return selectedSongSet;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSectionFav:{
            return 1;
        }
            
        case kSectionActivity:{
            return activities.count;
        }
            break;
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSectionFav:
            return 230;
            break;
        case kSectionPlaylist:
            return 195;
            break;
        case kSectionActivity:{
            WHTrackModel *trackInfo = activities[indexPath.row];
            if (trackInfo.trackType == WHTrackTypePlaceHolder) {
                return 44.0f;
            }else{
                return 168;
            }
        }
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 68.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DashBoardSectionHeaderView *sectionHeaderView = [DashBoardSectionHeaderView headerWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 68.0f)];
    switch (section) {
        case kSectionFav:{
            sectionHeaderView.sectionTitleLabel.text = @"Favorite";
        }
            break;
        case kSectionActivity:{
            sectionHeaderView.sectionTitleLabel.text = @"What's New";
        }
            break;
        case kSectionPlaylist:{
            sectionHeaderView.sectionTitleLabel.text = @"My Playlists";
        }
            break;
        default:
            break;
    }
    
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSectionFav:{
            NSString *cellIdentifier = @"DashBoardFavoritesTableViewCell";
            DashBoardFavoritesTableViewCell* cell = (DashBoardFavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[DashBoardFavoritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [cell setInfo:favourite];
            
            [cell setDidSelectTrack:^(WHTrackModel *trackInfo) {
                self->playingType = DashBoardPlayingTypeFavorite;
                
                self->selectedSongSet = self->favourite;
                [[WHSoundManager sharedManager] setDataSource:self];
                [[WHSoundManager sharedManager] reloadTracksData];
                [self didTogglePlayPause:trackInfo];
            }];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
            break;
        case kSectionPlaylist:{
            NSString *cellIdentifier = @"DashBoardPlaylistsTableViewCell";
            DashBoardPlaylistsTableViewCell* cell = (DashBoardPlaylistsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[DashBoardPlaylistsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [cell setInfo:myPlaylists];
            
            [cell setDidSelectPlaylist:^(WHPlaylistModel *aPlaylist) {
                if (aPlaylist.playlistTracks != nil && aPlaylist.playlistTracks.count > 0) {
                    self->playingType = DashBoardPlayingTypePlaylist;
                    
                    self->selectedSongSet = [NSArray arrayWithArray:aPlaylist.playlistTracks];
                    
                    [[WHSoundManager sharedManager] setDataSource:self];
                    [[WHSoundManager sharedManager] reloadTracksData];
                    
                    [self didTogglePlayPause:self->selectedSongSet[0]];
                }
            }];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
            break;
        case kSectionActivity:{
            WHTrackModel *trackInfo = activities[indexPath.row];
            
            if (trackInfo.trackType == WHTrackTypePlaceHolder) {
                NSString *cellIdentifier = @"PlaceholderTableViewCell";
                PlaceholderTableViewCell* cell = (PlaceholderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[PlaceholderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                return cell;
            }else{
                NSString *cellIdentifier = @"DashboardWhatsNewTableViewCell";
                DashboardWhatsNewTableViewCell* cell = (DashboardWhatsNewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[DashboardWhatsNewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                [cell setInfo:activities[indexPath.row]];
                
                return cell;
            }
            
        }
            break;
        default:{
            NSString *cellIdentifier = @"DashBoardFavoritesTableViewCell";
            DashBoardFavoritesTableViewCell* cell = (DashBoardFavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[DashBoardFavoritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kSectionActivity) {
        playingType = DashBoardPlayingTypeActivity;
        
        selectedSongSet = activities;
        [[WHSoundManager sharedManager] setDataSource:self];
        [[WHSoundManager sharedManager] reloadTracksData];
        [self didTogglePlayPause:activities[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kSectionActivity) {
        WHTrackModel *info = activities[indexPath.row];
        
        if (info.trackType != WHTrackTypePlaceHolder && [cell isKindOfClass:[DashboardWhatsNewTableViewCell class]]) {
            DashboardWhatsNewTableViewCell *activityCell = (DashboardWhatsNewTableViewCell *)cell;
            [activityCell cancelImageLoad];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kSectionActivity) {
        WHTrackModel *info = activities[indexPath.row];
        
        if (info.trackType == WHTrackTypePlaceHolder) {
            [[WHWebrequestManager sharedManager] fetchTracksWithUrl:info.nextHref
                                                            success:^(NSArray *responseObject) {
                                                                NSMutableArray *result = [NSMutableArray arrayWithArray:self->activities];
                                                                [result removeLastObject];
                                                                [result addObjectsFromArray:responseObject];
                                                                self->activities =  result;
                                                                [self.tableView reloadData];
                                                                
                                                                if ([[WHSoundManager sharedManager] dataSource] == self && self->playingType == DashBoardPlayingTypeActivity) {
                                                                    [[WHSoundManager sharedManager] reloadTracksData];
                                                                }
                                                            }
                                                            failure:^(NSError *error) {
                                                                
                                                            }];
        }
    }
}

#pragma mark - Player Related

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
        if (playingType == DashBoardPlayingTypeActivity) {
            activities = (NSArray *)info.object;
        }
        
        [_tableView reloadData];
    }
}
@end
