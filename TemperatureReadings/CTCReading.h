//
// CTCReading
// TemperatureReadings
//
// Created by ncipollina on 3/25/13.
// Copyright 2013 Lowe's Companies, Inc..  All rights reserved.
//


#import <Foundation/Foundation.h>


@interface CTCReading : NSObject

@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, strong) NSDate *readingDate;
@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, assign) BOOL temperatureValidated;

- (NSDictionary *)toDictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end