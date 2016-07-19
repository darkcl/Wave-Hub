//
//  WHConstant.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 19/11/2015.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHConstant : NSObject

extern NSString *remoteControlPlayButtonTapped;
extern NSString *remoteControlPauseButtonTapped;
extern NSString *remoteControlStopButtonTapped;
extern NSString *remoteControlForwardButtonTapped;
extern NSString *remoteControlBackwardButtonTapped;
extern NSString *remoteControlOtherButtonTapped;

extern NSString *WHSoundTrackDidChangeNotifiction;
extern NSString *WHSoundPlayModeDidChangeNotifiction;

extern NSString *WHSoundProgressDidChangeNotifiction;


@end
