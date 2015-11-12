//
//  WHApplication.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

static const NSString *remoteControlPlayButtonTapped = @"play pressed";
static const NSString *remoteControlPauseButtonTapped = @"pause pressed";
static const NSString *remoteControlStopButtonTapped = @"stop pressed";
static const NSString *remoteControlForwardButtonTapped = @"forward pressed";
static const NSString *remoteControlBackwardButtonTapped = @"backward pressed";
static const NSString *remoteControlOtherButtonTapped = @"other pressed";

@interface WHApplication : UIApplication

@end
