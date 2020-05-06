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

- (NSArray*)serializeHeartRateSamples:(NSArray *)samples uuid:(NSString*)uuid
{
    HKUnit *count = [HKUnit countUnit];
    HKUnit *minute = [HKUnit minuteUnit];
    HKUnit *unit = [count unitDividedByUnit:minute];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
    for (HKQuantitySample *sample in samples) {
        HKQuantity *quantity = sample.quantity;
        double value = [quantity doubleValueForUnit:unit];
        NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
        NSDictionary *elem = @{
                @"value" : @(value),
                @"workoutUuid" : uuid,
                @"timestamp" : startDateString,
        };
        [data addObject:elem];
    }
    return data;
}

- (void)workout_getWorkoutsWithCalories:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate
                                                                       ascending:NO];
    NSPredicate *workoutPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone], [HKQuery predicateForWorkoutsWithOperatorType:NSGreaterThanPredicateOperatorType totalEnergyBurned:[HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:0]]]];

    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    handlerBlock = ^(HKSampleQuery *query, NSArray *workouts, NSError *error) {
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (HKWorkout *workout in workouts) {
                NSDictionary *workoutObject = @{
                    @"activityId" : [NSNumber numberWithInt:[workout workoutActivityType]],
                    @"activityName" : [RCTAppleHealthKit stringForHKWorkoutActivityType:[workout workoutActivityType]],
                    @"calories" : @([[workout totalEnergyBurned] doubleValueForUnit:[HKUnit kilocalorieUnit]]),
                    @"distance" : @([[workout totalDistance] doubleValueForUnit:[HKUnit mileUnit]]),
                    @"start" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
                    @"uuid": [workout UUID].UUIDString,
                    @"end" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
                };
                [data addObject:workoutObject];
            }
            callback(@[[NSNull null], data]);
        });
    };
    // Execute the query to get the workout
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:handlerBlock];
    [self.healthStore executeQuery:query];
}
//

//- (void)workout_getWorkoutsWithHeartRateData:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
//{
//    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
//    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
//
//    NSPredicate *workoutPredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
//    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//
//    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
//    handlerBlock = ^(HKSampleQuery *query, NSArray *workouts, NSError *error) {
//        NSPredicate *hrPredicate = [HKQuery predicateForObjectsWithUUIDs:[[workouts valueForKey:@"UUID"]];
//        NSMutableArray *workoutsData = [NSMutableArray arrayWithCapacity:1];
//        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
//        HKSampleQuery *samplesQuery = [[HKSampleQuery alloc] initWithSampleType:heartRateType predicate:hrPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        for (HKWorkout *workout in workouts) {
//                            NSDictionary *workoutObject = @{
//                                @"activityId" : [NSNumber numberWithInt:[workout workoutActivityType]],
//                                @"activityName" : [RCTAppleHealthKit stringForHKWorkoutActivityType:[workout workoutActivityType]],
//                                @"calories" : @([[workout totalEnergyBurned] doubleValueForUnit:[HKUnit kilocalorieUnit]]),
//                                @"distance" : @([[workout totalDistance] doubleValueForUnit:[HKUnit mileUnit]]),
//                                @"start" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
//                                @"uuid": [workout UUID].UUIDString,
//                                @"end" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
//                            };
//                            [workoutsData addObject:workoutObject];
//                        }
//                        [data addObject:workoutsData];
//                        [data addObject:[self serializeHeartRateSamples:results uuid:@"test"]];
//                        callback(@[[NSNull null], data]);
//                    });
//                }];
//                [self.healthStore executeQuery:samplesQuery];
//            };
//
//    // Execute the query to get the workout
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:handlerBlock];
//    [self.healthStore executeQuery:query];
//}
//

//- (void)workout_getWorkoutsWithHeartRateData:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
//{
//    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
//    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
//    NSPredicate *workoutPredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
//    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//
//    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
//
//    __block int workoutProcessCount = 0;
//
//    handlerBlock = ^(HKSampleQuery *query, NSArray *workouts, NSError *error) {
//        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (HKWorkout *workout in workouts) {
//                NSPredicate *hrPredicate = [HKQuery predicateForObjectsFromWorkout:workout];
//                HKSampleQuery *samplesQuery = [[HKSampleQuery alloc] initWithSampleType:heartRateType predicate:hrPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if ([results count] > 5) {
//                            // If we have more than 5 heart rate samples, use it.
//                            // Add this workout to the result set
//                            NSDictionary *workoutObject = @{
//                                                   @"activityId" : [NSNumber numberWithInt:[workout workoutActivityType]],
//                                                   @"activityName" : [RCTAppleHealthKit stringForHKWorkoutActivityType:[workout workoutActivityType]],
//                                                   @"calories" : @([[workout totalEnergyBurned] doubleValueForUnit:[HKUnit kilocalorieUnit]]),
//                                                   @"distance" : @([[workout totalDistance] doubleValueForUnit:[HKUnit mileUnit]]),
//                                                   @"start" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
//                                                   @"uuid": [workout UUID].UUIDString,
//                                                   @"end" : [RCTAppleHealthKit buildISO8601StringFromDate:workout.startDate],
//                                                   @"heartRateSamples": [self serializeHeartRateSamples:results uuid:[workout UUID].UUIDString]
//                                                   };
//
//                            [data addObject:workoutObject];
//                        }
//
//                        workoutProcessCount++;
//
//                        if (workoutProcessCount >= workouts.count) {
//                            callback(@[[NSNull null], data]);
//                        }
//                    });
//                }];
//                [self.healthStore executeQuery:samplesQuery];
//            };
//        });
//    };
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//    // Execute the query to get the workout
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:handlerBlock];
//    [self.healthStore executeQuery:query];
//    });
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
