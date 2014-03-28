//
//  LTSunsetPushHelper.m
//  Lights
//
//  Created by Evan Coleman on 3/25/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "LTSunsetNotificationHelper.h"
#import "LTBeaconManager.h"
#import "LTLocationManager.h"
#import <EDSunriseSet/EDSunriseSet.h>
#import <NSDate-Extensions/NSDate-Utilities.h>

@implementation LTSunsetNotificationHelper

+ (void)scheduleSunsetNotificationWithCompletion:(void (^)())completion {
    LTLocationManager *locationManager = [[LTLocationManager alloc] init];
    [locationManager fetchLocationWithCompletion:^(CLLocation *location, NSError *error) {
        if (location) {
            EDSunriseSet *set = [EDSunriseSet sunrisesetWithTimezone:[NSTimeZone localTimeZone] latitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            NSDate *date = [NSDate date];
            if ([date isToday]) {
                date = [date dateByAddingDays:1];
            }
            [set calculateSunriseSunset:date];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = set.sunset;
            notification.hasAction = NO;
            notification.userInfo = @{@"event": @"fire_sunset"};
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
            NSLog(@"Sunset notification scheduled for %@", notification.fireDate);
            
            if (completion) {
                completion();
            }
        }
    }];
}

+ (void)sunsetNotificationDidFire {
    [[LTBeaconManager sharedManager] nearestBeacon:^(LKBeacon *beacon) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"It's getting dark out! Slide to turn on the lights in %@ \uE04C", beacon.name];
        notification.userInfo = @{@"roomId": @(beacon.roomId), @"event": @"trigger_room"};
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }];
}

@end
