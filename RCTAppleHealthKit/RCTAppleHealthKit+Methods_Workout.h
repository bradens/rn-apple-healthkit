//
//  RCTAppleHealthKit+Methods_Workout.h
//  RCTAppleHealthKit
//
//  Created by Ward van Teijlingen on 19/11/2017.
//  Copyright © 2017 Greg Wilson. All rights reserved.
//
#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Methods_Workout)

- (void)workout_saveWorkout:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)workout_getWorkoutsWithHeartRateData:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (NSArray*)serializeHeartRateSamples:(NSArray *)samples uuid:(NSString *)uuid;
- (void)workout_getWorkoutsWithCalories:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
@end

