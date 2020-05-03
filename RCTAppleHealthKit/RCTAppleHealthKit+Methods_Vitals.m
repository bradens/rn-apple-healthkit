#import "RCTAppleHealthKit+Methods_Vitals.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Vitals)

- (void)vitals_getHeartRateSamplesForWorkout:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKUnit *count = [HKUnit countUnit];
    HKUnit *minute = [HKUnit minuteUnit];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[count unitDividedByUnit:minute]];
    NSString *uuidString = [RCTAppleHealthKit stringFromOptions:input key:@"uuid" withDefault:nil];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate
                                                                       ascending:YES];

    if(uuidString == nil) {
        callback(@[RCTMakeError(@"uuid is required in options", nil, nil)]);
        return;
    }
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    NSPredicate *workoutPredicate = [HKQuery predicateForObjectWithUUID:uuid];
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        NSPredicate *samplePredicate = [HKQuery predicateForObjectsFromWorkout:results[0]];
        HKSampleQuery *samplesQuery = [[HKSampleQuery alloc] initWithSampleType:heartRateType predicate:samplePredicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            NSLog(@"Found some heart rate samples");
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (HKQuantitySample *sample in results) {
                    HKQuantity *quantity = sample.quantity;
                    double value = [quantity doubleValueForUnit:unit];

                    NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                    NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];

                    NSDictionary *elem = @{
                            @"value" : @(value),
                            @"startDate" : startDateString,
                            @"workoutUuid" : uuidString,
                            @"endDate" : endDateString,
                    };

                    [data addObject:elem];
                }
                callback(@[[NSNull null], data]);
            });
        }];
        [self.healthStore executeQuery:samplesQuery];
    };
    
    // Execute the query to get the workout
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:handlerBlock];
    [self.healthStore executeQuery:query];
}

- (void)vitals_getHeartRateSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    HKUnit *count = [HKUnit countUnit];
    HKUnit *minute = [HKUnit minuteUnit];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[count unitDividedByUnit:minute]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:heartRateType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
    }];
}


- (void)vitals_getBodyTemperatureSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bodyTemperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit degreeCelsiusUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:bodyTemperatureType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"error getting body temperature samples: %@", error);
            callback(@[RCTMakeError(@"error getting body temperature samples", nil, nil)]);
            return;
        }
    }];
}


- (void)vitals_getBloodPressureSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKCorrelationType *bloodPressureCorrelationType = [HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
    HKQuantityType *systolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *diastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];


    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit millimeterOfMercuryUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchCorrelationSamplesOfType:bloodPressureCorrelationType
                                   unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            for (NSDictionary *sample in results) {
                HKCorrelation *bloodPressureValues = [sample valueForKey:@"correlation"];

                HKQuantitySample *bloodPressureSystolicValue = [bloodPressureValues objectsForType:systolicType].anyObject;
                HKQuantitySample *bloodPressureDiastolicValue = [bloodPressureValues objectsForType:diastolicType].anyObject;

                NSDictionary *elem = @{
                                       @"bloodPressureSystolicValue" : @([bloodPressureSystolicValue.quantity doubleValueForUnit:unit]),
                                       @"bloodPressureDiastolicValue" : @([bloodPressureDiastolicValue.quantity doubleValueForUnit:unit]),
                                       @"startDate" : [sample valueForKey:@"startDate"],
                                       @"endDate" : [sample valueForKey:@"endDate"],
                                      };

                [data addObject:elem];
            }

            callback(@[[NSNull null], data]);
            return;
        } else {
            NSLog(@"error getting blood pressure samples: %@", error);
            callback(@[RCTMakeError(@"error getting blood pressure samples", nil, nil)]);
            return;
        }
    }];
}


- (void)vitals_getRespiratoryRateSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *respiratoryRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];

    HKUnit *count = [HKUnit countUnit];
    HKUnit *minute = [HKUnit minuteUnit];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[count unitDividedByUnit:minute]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:respiratoryRateType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"error getting respiratory rate samples: %@", error);
            callback(@[RCTMakeError(@"error getting respiratory rate samples", nil, nil)]);
            return;
        }
    }];
}

- (void)vitals_saveHeartRateSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *time = [RCTAppleHealthKit dateFromOptions:input key:@"time" withDefault:nil];
    double value = [RCTAppleHealthKit doubleFromOptions:input key:@"value" withDefault:0.0];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKUnit *bpm = [HKUnit unitFromString:@"count/min"];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:bpm
                                            doubleValue:value];
    NSString *uuidString = [RCTAppleHealthKit stringFromOptions:input key:@"uuid" withDefault:nil];

    HKQuantitySample *sample =[HKQuantitySample quantitySampleWithType:quantityType
                                    quantity:quantity
                                   startDate:time
                                     endDate:time];
    
    if(uuidString == nil) {
        [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                NSLog(@"An error occured saving the heart rate %@. The error was: %@.", sample, error);
                callback(@[RCTMakeError(@"An error occured saving the sample", error, nil)]);
                return;
            }
            callback(@[[NSNull null], sample.UUID.UUIDString]);
        }];
    } else {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        NSPredicate *workoutPredicate = [HKQuery predicateForObjectWithUUID:uuid];
        void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
        handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
            [self.healthStore addSamples:[NSArray arrayWithObject:sample] toWorkout:results[0] completion:^(BOOL success, NSError * _Nullable error) {
                callback(@[[NSNull null], sample.UUID.UUIDString]);
            }];
        };
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType workoutType] predicate:workoutPredicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:handlerBlock];
        [self.healthStore executeQuery:query];
    }
}

@end
