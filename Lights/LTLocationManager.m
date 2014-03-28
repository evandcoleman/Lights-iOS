//
//  LTLocationManager.m
//  Lights
//
//  Created by Evan Coleman on 3/26/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "LTLocationManager.h"

static CGFloat const kTimeoutIntervalDefault = 20.0f;

@interface LTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *manager;
@property (nonatomic, copy) void (^completionBlock)(CLLocation *, NSError *);
@property (nonatomic) NSTimer *timeoutTimer;

@end

@implementation LTLocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _timeoutInterval = kTimeoutIntervalDefault;
    }
    return self;
}

- (void)dealloc {
    [self cleanUp];
}

- (void)fetchLocationWithCompletion:(void (^)(CLLocation *, NSError *))completion {
    self.completionBlock = completion;
    
    self.manager.delegate = self;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInterval target:self selector:@selector(didTimeout:) userInfo:nil repeats:NO];
    [self.manager startUpdatingLocation];
}

#pragma mark - Private methods

- (void)didTimeout:(NSTimer *)timer {
    NSLog(@"Location timed out");
    [self locationManager:self.manager didFailWithError:nil];
}

- (void)cleanUp {
    [self.manager stopUpdatingLocation];
    self.manager.delegate = nil;
    [self.timeoutTimer invalidate];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = (CLLocation *)[locations lastObject];
    if (location.horizontalAccuracy < self.manager.desiredAccuracy) {
        self.completionBlock(location, nil);
        [self cleanUp];
    } else {
        NSLog(@"Location accuracy not met: %f", location.horizontalAccuracy);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    self.completionBlock(nil, error);
    [self cleanUp];
}

@end
