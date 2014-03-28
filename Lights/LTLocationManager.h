//
//  LTLocationManager.h
//  Lights
//
//  Created by Evan Coleman on 3/26/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LTLocationManager : NSObject

@property (nonatomic) NSTimeInterval timeoutInterval;

- (void)fetchLocationWithCompletion:(void (^)(CLLocation *, NSError *))completion;

@end
