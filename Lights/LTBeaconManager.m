//
//  LTBeaconManager.m
//  Lights
//
//  Created by Evan Coleman on 3/12/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "LTBeaconManager.h"
#import "LTAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const LTBeaconUUID = @"E2D56DB8-DFFB-38D2-B06A-D0F5A71096E0";
static NSString * const LTBeaconKey = @"LTBeaconKey";
static NSString * const LTBeaconRegionKey = @"LTBeaconRegionKey";
static NSString * const LTBeaconLastExitedKey = @"LTBeaconLastExitedKey";
static NSString * const LTBeaconLastEnteredKey = @"LTBeaconLastEnteredKey";
static NSString * const LTBeaconLastNotificationKey = @"LTBeaconLastNotificationKey";

@interface LTBeaconManager () <CLLocationManagerDelegate>

@property (nonatomic, readonly) LKSession *session;
@property (nonatomic) NSArray *beacons;

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation LTBeaconManager

+ (instancetype)sharedManager {
    static LTBeaconManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LTBeaconManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [self cleanUp];
}

- (void)beginTracking {
    [self cleanUp];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [self.session queryBeaconsWithBlock:^(NSArray *beacons) {
            NSMutableArray *b = [NSMutableArray array];
            for (LKBeacon *beacon in beacons) {
                [b addObject:[NSMutableDictionary dictionaryWithObject:beacon forKey:LTBeaconKey]];
            }
            self.beacons = b;
            [self setupBeacons];
        }];
    }
}

- (void)stopTracking {
    [self cleanUp];
}

- (void)triggerActionWithNotification:(UILocalNotification *)note {
    if (note.userInfo[@"roomId"]) {
        NSString *path = [NSString stringWithFormat:@"api/v1/rooms/%@/1", note.userInfo[@"roomId"]];
        [[LKSession activeSession] PUT:path
                            parameters:@{@"auth_token": [[LKSession activeSession] authToken]}
                               success:^(NSURLSessionDataTask *taks, id responseObject) {
                                   NSLog(@"PUT to %@", path);
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   NSLog(@"%@", [error localizedDescription]);
                               }];
    }
}

#pragma mark - Private methods

- (void)setupBeacons {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:LTBeaconUUID];
    NSString *identifierPrefix = @"net.evancoleman.lights";
    for (NSMutableDictionary *dict in self.beacons) {
        LKBeacon *beacon = dict[LTBeaconKey];
        NSString *identifier = [identifierPrefix stringByAppendingFormat:@".%lu", (long)beacon.beaconId];
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:beacon.major minor:beacon.minor identifier:identifier];
        dict[LTBeaconRegionKey] = beaconRegion;
        
        [self.locationManager startMonitoringForRegion:beaconRegion];
        NSLog(@"Tracking beacon in %@. Major: %lu, Minor: %lu", beacon.name, (long)beacon.major, (long)beacon.minor);
    }
}

- (void)cleanUp {
    for (NSMutableDictionary *dict in self.beacons) {
        [self.locationManager stopMonitoringForRegion:dict[LTBeaconRegionKey]];
    }
    self.beacons = nil;
    
    self.locationManager.delegate = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"LTBeaconRegionKey.major == %@ AND LTBeaconRegionKey.minor == %@", beaconRegion.major, beaconRegion.minor];
    NSMutableDictionary *dict = [[self.beacons filteredArrayUsingPredicate:predicate] firstObject];
    LKBeacon *beacon = dict[LTBeaconKey];
    NSLog(@"Entering %@", beacon.name);
    
    NSDate *lastSeen = dict[LTBeaconLastExitedKey];
    if ([lastSeen timeIntervalSinceNow] < -300 || !lastSeen) {
        if (dict[LTBeaconLastNotificationKey]) {
            [[UIApplication sharedApplication] cancelLocalNotification:dict[LTBeaconLastNotificationKey]];
            [dict removeObjectForKey:LTBeaconLastNotificationKey];
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"Entered %@. Slide to turn on the lights \uE10F", beacon.name];
        notification.userInfo = @{@"roomId": @(beacon.roomId)};
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        dict[LTBeaconLastNotificationKey] = notification;
    } else {
        NSLog(@"Region just exited, ignoring.");
    }
    
    dict[LTBeaconLastEnteredKey] = [NSDate date];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"LTBeaconRegionKey.major == %@ AND LTBeaconRegionKey.minor == %@", beaconRegion.major, beaconRegion.minor];
    NSMutableDictionary *dict = [[self.beacons filteredArrayUsingPredicate:predicate] firstObject];
    NSLog(@"Exiting %@", [dict[LTBeaconKey] name]);
    dict[LTBeaconLastExitedKey] = [NSDate date];
    
    if (dict[LTBeaconLastNotificationKey]) {
        [[UIApplication sharedApplication] cancelLocalNotification:dict[LTBeaconLastNotificationKey]];
        [dict removeObjectForKey:LTBeaconLastNotificationKey];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
