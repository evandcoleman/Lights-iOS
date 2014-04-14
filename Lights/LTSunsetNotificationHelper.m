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
            NSDate *fireDate = [set.sunset dateByAddingTimeInterval:-60 * 15];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = fireDate;
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
    NSLog(@"Sunset Notification Fired");
    [[LTBeaconManager sharedManager] nearestBeacon:^(LKBeacon *beacon) {
        if (beacon) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = [NSString stringWithFormat:@"It's getting dark out! Slide to turn on the lights in %@ \U0001F31B", beacon.name];
            notification.userInfo = @{@"roomId": @(beacon.roomId), @"event": @"trigger_room"};
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }];
}

@end
