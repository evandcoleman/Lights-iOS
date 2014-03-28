//
//  LTSunsetPushHelper.h
//  Lights
//
//  Created by Evan Coleman on 3/25/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTSunsetNotificationHelper : NSObject

+ (void)scheduleSunsetNotificationWithCompletion:(void (^)())completion;
+ (void)sunsetNotificationDidFire;

@end
