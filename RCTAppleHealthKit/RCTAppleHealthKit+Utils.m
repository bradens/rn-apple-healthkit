//
//  RCTAppleHealthKit+Utils.m
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Utils)


#pragma mark - Utilities

+ (NSDate *)parseISO8601DateFromString:(NSString *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = posix;
    dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";
    return [dateFormatter dateFromString:date];
}


+ (NSString *)buildISO8601StringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = posix;
    dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";
    return [dateFormatter stringFromDate:date];
}


+ (NSPredicate *)predicateForSamplesToday {
    NSDate *now = [NSDate date];
    return [RCTAppleHealthKit predicateForSamplesOnDay:now];
}


+ (NSPredicate *)predicateForSamplesOnDayFromTimestamp:(NSString *)timestamp {
    NSDate *day = [RCTAppleHealthKit parseISO8601DateFromString:timestamp];
    return [RCTAppleHealthKit predicateForSamplesOnDay:day];
}


+ (NSPredicate *)predicateForSamplesOnDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar startOfDayForDate:date];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}


+ (NSPredicate *)predicateForSamplesBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}


+ (double)doubleValueFromOptions:(NSDictionary *)options {
    double value = [[options objectForKey:@"value"] doubleValue];
    return value;
}


+ (NSDate *)dateFromOptions:(NSDictionary *)options {
    NSString *dateString = [options objectForKey:@"date"];
    NSDate *date;
    if(dateString != nil){
        date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
    }
    return date;
}


+ (NSDate *)dateFromOptionsDefaultNow:(NSDictionary *)options {
    NSString *dateString = [options objectForKey:@"date"];
    if(dateString != nil){
        NSDate *date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
        if(date == nil){
            // probably not a good idea... should return an error or just the null pointer
            date = [NSDate date];
        }
        return date;
    }
    NSDate *now = [NSDate date];
    return now;
}


+ (NSDate *)startDateFromOptions:(NSDictionary *)options {
    NSString *dateString = [options objectForKey:@"startDate"];
    NSDate *date;
    if(dateString != nil){
        date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
        return date;
    }
    return date;
}


+ (NSDate *)endDateFromOptions:(NSDictionary *)options {
    NSString *dateString = [options objectForKey:@"endDate"];
    NSDate *date;
    if(dateString != nil){
        date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
    }
    return date;
}


+ (NSDate *)endDateFromOptionsDefaultNow:(NSDictionary *)options {
    NSString *dateString = [options objectForKey:@"endDate"];
    NSDate *date;
    if(dateString != nil){
        date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
        return date;
    }
    if(date == nil){
        date = [NSDate date];
    }
    return date;
}

+ (HKSampleType *)hkQuantityTypeFromString:(NSString *)type {
    if ([type isEqual:@"Walking"]) {
        return [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    } else if ([type isEqual:@"StairClimbing"]) {
        return [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    } else if ([type isEqual:@"Running"]){
        return [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    } else if ([type isEqual:@"Cycling"]){
        return [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    } else if ([type isEqual:@"Swimming"]){
        return [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceSwimming];
    }
    // default [type isEqual:@"Workout"])
    return [HKObjectType workoutType];
}


+ (HKUnit *)hkUnitFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(HKUnit *)defaultValue {
    NSString *unitString = [options objectForKey:key];
    HKUnit *theUnit;

    if([unitString isEqualToString:@"gram"]){
        theUnit = [HKUnit gramUnit];
    }
    if([unitString isEqualToString:@"kg"]){
        theUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    }
    if([unitString isEqualToString:@"stone"]){
        theUnit = [HKUnit stoneUnit];
    }
    if([unitString isEqualToString:@"pound"]){
        theUnit = [HKUnit poundUnit];
    }
    if([unitString isEqualToString:@"meter"]){
        theUnit = [HKUnit meterUnit];
    }
    if([unitString isEqualToString:@"cm"]){
        theUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixCenti];
    }
    if([unitString isEqualToString:@"inch"]){
        theUnit = [HKUnit inchUnit];
    }
    if([unitString isEqualToString:@"mile"]){
        theUnit = [HKUnit mileUnit];
    }
    if([unitString isEqualToString:@"foot"]){
        theUnit = [HKUnit footUnit];
    }
    if([unitString isEqualToString:@"second"]){
        theUnit = [HKUnit secondUnit];
    }
    if([unitString isEqualToString:@"minute"]){
        theUnit = [HKUnit minuteUnit];
    }
    if([unitString isEqualToString:@"hour"]){
        theUnit = [HKUnit hourUnit];
    }
    if([unitString isEqualToString:@"day"]){
        theUnit = [HKUnit dayUnit];
    }
    if([unitString isEqualToString:@"joule"]){
        theUnit = [HKUnit jouleUnit];
    }
    if([unitString isEqualToString:@"calorie"]){
        theUnit = [HKUnit calorieUnit];
    }
    if([unitString isEqualToString:@"count"]){
        theUnit = [HKUnit countUnit];
    }
    if([unitString isEqualToString:@"percent"]){
        theUnit = [HKUnit percentUnit];
    }
    if([unitString isEqualToString:@"bpm"]){
        HKUnit *count = [HKUnit countUnit];
        HKUnit *minute = [HKUnit minuteUnit];

        theUnit = [count unitDividedByUnit:minute];
    }
    if([unitString isEqualToString:@"fahrenheit"]){
        theUnit = [HKUnit degreeFahrenheitUnit];
    }
    if([unitString isEqualToString:@"celsius"]){
        theUnit = [HKUnit degreeCelsiusUnit];
    }
    if([unitString isEqualToString:@"mmhg"]){
        theUnit = [HKUnit millimeterOfMercuryUnit];
    }
    if([unitString isEqualToString:@"mmolPerL"]){
        theUnit = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];
    }
    if([unitString isEqualToString:@"mgPerdL"]){
        theUnit = [HKUnit unitFromString:@"mg/dL"];
    }

    if(theUnit == nil){
        theUnit = defaultValue;
    }

    return theUnit;
}

+ (HKWorkoutActivityType)hkWorkoutActivityTypeFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(HKWorkoutActivityType)defaultValue {
	NSString *typeString = [options objectForKey:key];
	HKWorkoutActivityType theType = defaultValue;
	
	if([typeString isEqualToString:@"AmericanFootball"]) {
		theType = HKWorkoutActivityTypeAmericanFootball;
	}
	if([typeString isEqualToString:@"Archery"]) {
		theType = HKWorkoutActivityTypeArchery;
	}
	if([typeString isEqualToString:@"AustralianFootball"]) {
		theType = HKWorkoutActivityTypeAustralianFootball;
	}
	if([typeString isEqualToString:@"Badminton"]) {
		theType = HKWorkoutActivityTypeBadminton;
	}
	if([typeString isEqualToString:@"Baseball"]) {
		theType = HKWorkoutActivityTypeBaseball;
	}
	if([typeString isEqualToString:@"Basketball"]) {
		theType = HKWorkoutActivityTypeBasketball;
	}
	if([typeString isEqualToString:@"Bowling"]) {
		theType = HKWorkoutActivityTypeBowling;
	}
	if([typeString isEqualToString:@"Boxing"]) {
		theType = HKWorkoutActivityTypeBoxing ;
	}
	if([typeString isEqualToString:@"Climbing"]) {
		theType = HKWorkoutActivityTypeClimbing;
	}
	if([typeString isEqualToString:@"Cricket"]) {
		theType = HKWorkoutActivityTypeCricket;
	}
	if([typeString isEqualToString:@"CrossTraining"]) {
		theType = HKWorkoutActivityTypeCrossTraining ;
	}
	if([typeString isEqualToString:@"Curling"]) {
		theType = HKWorkoutActivityTypeCurling;
	}
	if([typeString isEqualToString:@"Cycling"]) {
		theType = HKWorkoutActivityTypeCycling;
	}
	if([typeString isEqualToString:@"Dance"]) {
		theType = HKWorkoutActivityTypeDance;
	}
	if([typeString isEqualToString:@"Elliptical"]) {
		theType = HKWorkoutActivityTypeElliptical;
	}
	if([typeString isEqualToString:@"EquestrianSports"]) {
		theType = HKWorkoutActivityTypeEquestrianSports ;
	}
	if([typeString isEqualToString:@"Fencing"]) {
		theType = HKWorkoutActivityTypeFencing;
	}
	if([typeString isEqualToString:@"Fishing"]) {
		theType = HKWorkoutActivityTypeFishing;
	}
	if([typeString isEqualToString:@"FunctionalStrengthTraining"]) {
		theType = HKWorkoutActivityTypeFunctionalStrengthTraining ;
	}
	if([typeString isEqualToString:@"Golf"]) {
		theType = HKWorkoutActivityTypeGolf;
	}
	if([typeString isEqualToString:@"Gymnastics"]) {
		theType = HKWorkoutActivityTypeGymnastics;
	}
	if([typeString isEqualToString:@"Handball"]) {
		theType = HKWorkoutActivityTypeHandball;
	}
	if([typeString isEqualToString:@"Hiking"]) {
		theType = HKWorkoutActivityTypeHiking;
	}
	if([typeString isEqualToString:@"Hockey"]) {
		theType = HKWorkoutActivityTypeHockey ;
	}
	if([typeString isEqualToString:@"Hunting"]) {
		theType = HKWorkoutActivityTypeHunting;
	}
	if([typeString isEqualToString:@"Lacrosse"]) {
		theType = HKWorkoutActivityTypeLacrosse;
	}
	if([typeString isEqualToString:@"MartialArts"]) {
		theType = HKWorkoutActivityTypeMartialArts;
	}
	if([typeString isEqualToString:@"MindAndBody"]) {
		theType = HKWorkoutActivityTypeMindAndBody ;
	}
	if([typeString isEqualToString:@"PaddleSports"]) {
		theType = HKWorkoutActivityTypePaddleSports ;
	}
	if([typeString isEqualToString:@"Play"]) {
		theType = HKWorkoutActivityTypePlay ;
	}
	if([typeString isEqualToString:@"PreparationAndRecovery"]) {
		theType = HKWorkoutActivityTypePreparationAndRecovery ;
	}
	if([typeString isEqualToString:@"Racquetball"]) {
		theType = HKWorkoutActivityTypeRacquetball;
	}
	if([typeString isEqualToString:@"Rowing"]) {
		theType = HKWorkoutActivityTypeRowing;
	}
	if([typeString isEqualToString:@"Rugby"]) {
		theType = HKWorkoutActivityTypeRugby;
	}
	if([typeString isEqualToString:@"Running"]) {
		theType = HKWorkoutActivityTypeRunning;
	}
	if([typeString isEqualToString:@"Sailing"]) {
		theType = HKWorkoutActivityTypeSailing;
	}
	if([typeString isEqualToString:@"SkatingSports"]) {
		theType = HKWorkoutActivityTypeSkatingSports ;
	}
	if([typeString isEqualToString:@"SnowSports"]) {
		theType = HKWorkoutActivityTypeSnowSports ;
	}
	if([typeString isEqualToString:@"Soccer"]) {
		theType = HKWorkoutActivityTypeSoccer;
	}
	if([typeString isEqualToString:@"Softball"]) {
		theType = HKWorkoutActivityTypeSoftball;
	}
	if([typeString isEqualToString:@"Squash"]) {
		theType = HKWorkoutActivityTypeSquash;
	}
	if([typeString isEqualToString:@"StairClimbing"]) {
		theType = HKWorkoutActivityTypeStairClimbing ;
	}
	if([typeString isEqualToString:@"SurfingSports"]) {
		theType = HKWorkoutActivityTypeSurfingSports ;
	}
	if([typeString isEqualToString:@"Swimming"]) {
		theType = HKWorkoutActivityTypeSwimming;
	}
	if([typeString isEqualToString:@"TableTennis"]) {
		theType = HKWorkoutActivityTypeTableTennis;
	}
	if([typeString isEqualToString:@"Tennis"]) {
		theType = HKWorkoutActivityTypeTennis;
	}
	if([typeString isEqualToString:@"TrackAndField"]) {
		theType = HKWorkoutActivityTypeTrackAndField ;
	}
	if([typeString isEqualToString:@"TraditionalStrengthTraining"]) {
		theType = HKWorkoutActivityTypeTraditionalStrengthTraining ;
	}
	if([typeString isEqualToString:@"Volleyball"]) {
		theType = HKWorkoutActivityTypeVolleyball;
	}
	if([typeString isEqualToString:@"Walking"]) {
		theType = HKWorkoutActivityTypeWalking;
	}
	if([typeString isEqualToString:@"WaterFitness"]) {
		theType = HKWorkoutActivityTypeWaterFitness;
	}
	if([typeString isEqualToString:@"WaterPolo"]) {
		theType = HKWorkoutActivityTypeWaterPolo;
	}
	if([typeString isEqualToString:@"WaterSports"]) {
		theType = HKWorkoutActivityTypeWaterSports ;
	}
	if([typeString isEqualToString:@"Wrestling"]) {
		theType = HKWorkoutActivityTypeWrestling;
	}
	if([typeString isEqualToString:@"Yoga"]) {
		theType = HKWorkoutActivityTypeYoga  ;
	}
	if([typeString isEqualToString:@"Barre"]) {
		theType = HKWorkoutActivityTypeBarre;
	}
	if([typeString isEqualToString:@"CoreTraining"]) {
		theType = HKWorkoutActivityTypeCoreTraining;
	}
	if([typeString isEqualToString:@"CrossCountrySkiing"]) {
		theType = HKWorkoutActivityTypeCrossCountrySkiing;
	}
	if([typeString isEqualToString:@"DownhillSkiing"]) {
		theType = HKWorkoutActivityTypeDownhillSkiing;
	}
	if([typeString isEqualToString:@"Flexibility"]) {
		theType = HKWorkoutActivityTypeFlexibility;
	}
	if([typeString isEqualToString:@"HighIntensityIntervalTraining"]) {
		theType = HKWorkoutActivityTypeHighIntensityIntervalTraining;
	}
	if([typeString isEqualToString:@"JumpRope"]) {
		theType = HKWorkoutActivityTypeJumpRope;
	}
	if([typeString isEqualToString:@"Kickboxing"]) {
		theType = HKWorkoutActivityTypeKickboxing;
	}
	if([typeString isEqualToString:@"Pilates"]) {
		theType = HKWorkoutActivityTypePilates;
	}
	if([typeString isEqualToString:@"Snowboarding"]) {
		theType = HKWorkoutActivityTypeSnowboarding;
	}
	if([typeString isEqualToString:@"Stairs"]) {
		theType = HKWorkoutActivityTypeStairs;
	}
	if([typeString isEqualToString:@"StepTraining"]) {
		theType = HKWorkoutActivityTypeStepTraining;
	}
	if([typeString isEqualToString:@"WheelchairWalkPace"]) {
		theType = HKWorkoutActivityTypeWheelchairWalkPace;
	}
	if([typeString isEqualToString:@"WheelchairRunPace"]) {
		theType = HKWorkoutActivityTypeWheelchairRunPace;
	}
	if([typeString isEqualToString:@"TaiChi"]) {
		theType = HKWorkoutActivityTypeTaiChi;
	}
	if([typeString isEqualToString:@"MixedCardio"]) {
		theType = HKWorkoutActivityTypeMixedCardio;
	}
	if([typeString isEqualToString:@"HandCycling"]) {
		theType = HKWorkoutActivityTypeHandCycling;
	}
	
	return theType;
}


+ (NSUInteger)uintFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(NSUInteger)defaultValue {
    NSUInteger val;
    NSNumber *num = [options objectForKey:key];
    if(num != nil){
        val = [num unsignedIntValue];
    } else {
        val = defaultValue;
    }
    return val;
}


+ (double)doubleFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(double)defaultValue {
    double val;
    NSNumber *num = [options objectForKey:key];
    if(num != nil){
        val = [num doubleValue];
    } else {
        val = defaultValue;
    }
    return val;
}


+ (NSDate *)dateFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(NSDate *)defaultValue {
    NSString *dateString = [options objectForKey:key];
    NSDate *date;
    if(dateString != nil){
        date = [RCTAppleHealthKit parseISO8601DateFromString:dateString];
    } else {
        date = defaultValue;
    }
    return date;
}


+ (NSString *)stringFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(NSString *)defaultValue {
    NSString *str = [options objectForKey:key];
    if(str == nil){
        str = defaultValue;
    }
    return str;
}


+ (bool)boolFromOptions:(NSDictionary *)options key:(NSString *)key withDefault:(bool)defaultValue {
    NSNumber *num = [options objectForKey:key];
    if(num == nil){
        return defaultValue;
    }
    return [num boolValue];
}


+ (NSMutableArray *)reverseNSMutableArray:(NSMutableArray *)array {
    if ([array count] <= 1)
        return array;
    NSUInteger i = 0;
    NSUInteger j = [array count] - 1;
    while (i < j) {
        [array exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        i++;
        j--;
    }
    return array;
}

+ (NSString*)stringForHKWorkoutActivityType:(int) enumValue{
    switch( enumValue ){
        case HKWorkoutActivityTypeAmericanFootball:
            return @"AmericanFootball";
        case HKWorkoutActivityTypeArchery:
            return @"Archery";
        case HKWorkoutActivityTypeAustralianFootball:
            return @"AustralianFootball";
        case HKWorkoutActivityTypeBadminton:
            return @"Badminton";
        case HKWorkoutActivityTypeBaseball:
            return @"Baseball";
        case HKWorkoutActivityTypeBasketball:
            return @"Basketball";
        case HKWorkoutActivityTypeBowling:
            return @"Bowling";
        case HKWorkoutActivityTypeBoxing:
            return @"Boxing";
        case HKWorkoutActivityTypeClimbing:
            return @"Climbing";
        case HKWorkoutActivityTypeCricket:
            return @"Cricket";
        case HKWorkoutActivityTypeCrossTraining:
            return @"CrossTraining";
        case HKWorkoutActivityTypeCurling:
            return @"Curling";
        case HKWorkoutActivityTypeCycling:
            return @"Cycling";
        case HKWorkoutActivityTypeDance:
            return @"Dance";
        case HKWorkoutActivityTypeDanceInspiredTraining:
            return @"DanceInspiredTraining";
        case HKWorkoutActivityTypeElliptical:
            return @"Elliptical";
        case HKWorkoutActivityTypeEquestrianSports:
            return @"EquestrianSports";
        case HKWorkoutActivityTypeFencing:
            return @"Fencing";
        case HKWorkoutActivityTypeFishing:
            return @"Fishing";
        case HKWorkoutActivityTypeFunctionalStrengthTraining:
            return @"FunctionalStrengthTraining";
        case HKWorkoutActivityTypeGolf:
            return @"Golf";
        case HKWorkoutActivityTypeGymnastics:
            return @"Gymnastics";
        case HKWorkoutActivityTypeHandball:
            return @"Handball";
        case HKWorkoutActivityTypeHiking:
            return @"Hiking";
        case HKWorkoutActivityTypeHockey:
            return @"Hockey";
        case HKWorkoutActivityTypeHunting:
            return @"Hunting";
        case HKWorkoutActivityTypeLacrosse:
            return @"Lacrosse";
        case HKWorkoutActivityTypeMartialArts:
            return @"MartialArts";
        case HKWorkoutActivityTypeMindAndBody:
            return @"MindAndBody";
        case HKWorkoutActivityTypeMixedMetabolicCardioTraining:
            return @"MixedMetabolicCardioTraining";
        case HKWorkoutActivityTypePaddleSports:
            return @"PaddleSports";
        case HKWorkoutActivityTypePlay:
            return @"Play";
        case HKWorkoutActivityTypePreparationAndRecovery:
            return @"PreparationAndRecovery";
        case HKWorkoutActivityTypeRacquetball:
            return @"Racquetball";
        case HKWorkoutActivityTypeRowing:
            return @"Rowing";
        case HKWorkoutActivityTypeRugby:
            return @"Rugby";
        case HKWorkoutActivityTypeRunning:
            return @"Running";
        case HKWorkoutActivityTypeSailing:
            return @"Sailing";
        case HKWorkoutActivityTypeSkatingSports:
            return @"SkatingSports";
        case HKWorkoutActivityTypeSnowSports:
            return @"SnowSports";
        case HKWorkoutActivityTypeSoccer:
            return @"Soccer";
        case HKWorkoutActivityTypeSoftball:
            return @"Softball";
        case HKWorkoutActivityTypeSquash:
            return @"Squash";
        case HKWorkoutActivityTypeStairClimbing:
            return @"StairClimbing";
        case HKWorkoutActivityTypeSurfingSports:
            return @"SurfingSports";
        case HKWorkoutActivityTypeSwimming:
            return @"Swimming";
        case HKWorkoutActivityTypeTableTennis:
            return @"TableTennis";
        case HKWorkoutActivityTypeTennis:
            return @"Tennis";
        case HKWorkoutActivityTypeTrackAndField:
            return @"TrackAndField";
        case HKWorkoutActivityTypeTraditionalStrengthTraining:
            return @"TraditionalStrengthTraining";
        case HKWorkoutActivityTypeVolleyball:
            return @"Volleyball";
        case HKWorkoutActivityTypeWalking:
            return @"Walking";
        case HKWorkoutActivityTypeWaterFitness:
            return @"WaterFitness";
        case HKWorkoutActivityTypeWaterPolo:
            return @"WaterPolo";
        case HKWorkoutActivityTypeWaterSports:
            return @"WaterSports";
        case HKWorkoutActivityTypeWrestling:
            return @"Wrestling";
        case HKWorkoutActivityTypeYoga:
            return @"Yoga";
        case HKWorkoutActivityTypeOther:
            return @"Other";
        case HKWorkoutActivityTypeBarre:
            return @"Barre";
        case HKWorkoutActivityTypeCoreTraining:
            return @"CoreTraining";
        case HKWorkoutActivityTypeCrossCountrySkiing:
            return @"CrossCountrySkiing";
        case HKWorkoutActivityTypeDownhillSkiing:
            return @"DownhillSkiing";
        case HKWorkoutActivityTypeFlexibility:
            return @"Flexibility";
        case HKWorkoutActivityTypeHighIntensityIntervalTraining:
            return @"HighIntensityIntervalTraining";
        case HKWorkoutActivityTypeJumpRope:
            return @"JumpRope";
        case HKWorkoutActivityTypeKickboxing:
            return @"Kickboxing";
        case HKWorkoutActivityTypePilates:
            return @"Pilates";
        case HKWorkoutActivityTypeSnowboarding:
            return @"Snowboarding";
        case HKWorkoutActivityTypeStairs:
            return @"Stairs";
        case HKWorkoutActivityTypeStepTraining:
            return @"StepTraining";
        case HKWorkoutActivityTypeWheelchairWalkPace:
            return @"WheelchairWalkPace";
        case HKWorkoutActivityTypeWheelchairRunPace:
            return @"WheelchairRunPace";
        case HKWorkoutActivityTypeTaiChi:
            return @"TaiChi";
        case HKWorkoutActivityTypeMixedCardio:
            return @"MixedCardio";
        case HKWorkoutActivityTypeHandCycling:
            return @"HandCycling";
        default:{
            NSException *e = [NSException
                              exceptionWithName:@"HKWorkoutActivityType InvalidValue"
                              reason:@"HKWorkoutActivityType can only have a value from the HKWorkoutActivityType enum"
                              userInfo:nil];
            @throw e;
        }
    }
}

@end
