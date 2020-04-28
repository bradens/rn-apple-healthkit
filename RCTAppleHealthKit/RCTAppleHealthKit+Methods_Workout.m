//
//  RCTAppleHealthKit+Methods_Workout.m
//  RCTAppleHealthKit
//
//  Created by Ward van Teijlingen on 19/11/2017.
//  Copyright © 2017 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+Methods_Workout.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Workout)

- (void)workout_saveWorkout:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
	HKWorkoutActivityType activityType = [RCTAppleHealthKit hkWorkoutActivityTypeFromOptions:input key:@"type" withDefault:HKWorkoutActivityTypeOther];
	NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
	NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:nil];
	NSTimeInterval duration = [RCTAppleHealthKit doubleFromOptions:input key:@"duration" withDefault:(NSTimeInterval)0];
	HKQuantity *totalEnergyBurned = [self quantityFromOptions:input valueKey:@"energyBurned" unitKey:@"energyBurnedUnit"];
	HKQuantity *totalDistance = [self quantityFromOptions:input valueKey:@"distance" unitKey:@"distanceUnit"];
	
	HKWorkout *workout = [HKWorkout
												workoutWithActivityType:activityType
												startDate:startDate
												endDate:endDate
												duration:duration
												totalEnergyBurned:totalEnergyBurned
												totalDistance:totalDistance
												metadata:nil];

	[self.healthStore saveObject:workout withCompletion:^(BOOL success, NSError * _Nullable error) {
		if (!success) {
			NSLog(@"An error occured saving the workout %@. The error was: %@.", workout, error);
			callback(@[RCTMakeError(@"An error occured saving the workout", error, nil)]);
			return;
		}
		callback(@[[NSNull null], workout.UUID.UUIDString]);
	}];
}



//- (void)workout_getWorkoutsWithHeartRateData:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
//{
//    HKWorkoutActivityType activityType = [RCTAppleHealthKit hkWorkoutActivityTypeFromOptions:input key:@"type" withDefault:HKWorkoutActivityTypeOther];
//    
//    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit countUnit]];
//    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
//    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
//    NSString *type = [RCTAppleHealthKit stringFromOptions:input key:@"type" withDefault:@"Walking"];
//    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
//    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
//    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
//    HKSampleType *samplesType = [HKObjectType workoutType];
//    [self fetchSamplesOfType:samplesType
//                                unit:unit
//                           predicate:predicate
//                           ascending:ascending
//                               limit:limit
//                          completion:^(NSArray *results, NSError *error) {
//                              if(results){
//                                  // Here we have the workouts
//                                  // Now reject any that don't have heartrate samples
//                                  HKWorkout *workout = results[0];
//                                  NSPredicate *samplesPredicate [HKQuery predicateForObjectWithUUID:[workout UUID]];
//                                  for (int i = 0; i <= results.count; i++)
//                                  {
//                                      [self fetchQuantitySamplesOfType:HKQuantityTypeIdentifierHeartRate unit:unit predicate:samplesPredicate ascending:NO limit:HKObjectQueryNoLimit completion:^(NSArray *innerResults, NSError *innerError) {
//                                          NSLog(@"Now we are in the HR completion handler");
//                                      }];
//                                  }
//
//                                  callback(@[[NSNull null], results]);
//                                  return;
//                              } else {
//                                  NSLog(@"error getting samples: %@", error);
//                                  callback(@[RCTMakeError(@"error getting samples", nil, nil)]);
//                                  return;
//                              }
//                          }];
//}



-(HKQuantity *)quantityFromOptions:(NSDictionary *)input valueKey:(NSString *)valueKey unitKey:(NSString *)unitKey {
	double value = [RCTAppleHealthKit doubleFromOptions:input key:valueKey withDefault:-1];
	HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:unitKey withDefault:nil];
	
	if(unit != nil && value != -1) {
		return [HKQuantity quantityWithUnit:unit doubleValue:value];
	} else {
		return nil;
	}
}
@end
