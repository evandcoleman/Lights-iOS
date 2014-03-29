//
//  LTBeaconManager.h
//  Lights
//
//  Created by Evan Coleman on 3/12/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKBeacon;

@interface LTBeaconManager : NSObject

+ (instancetype)sharedManager;
- (void)beginTracking;
- (void)stopTracking;

- (void)triggerActionWithNotification:(UILocalNotification *)note;
- (void)nearestBeacon:(void (^)(LKBeacon *))completion;

@end
