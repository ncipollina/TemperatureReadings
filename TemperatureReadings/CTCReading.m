//
// CTCReading
// TemperatureReadings
//
// Created by ncipollina on 3/25/13.
// Copyright 2013 Lowe's Companies, Inc..  All rights reserved.
//


#import "CTCReading.h"


@implementation CTCReading {

}
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [@{
                @"readingDate" : self.readingDate,
                @"temperature" : @(self.temperature),
                @"temperatureValidated" : @(self.temperatureValidated)
        } mutableCopy];
    if (self.identifier != 0){
        dict[@"id"] = @(self.identifier);
    }
    return dict;
}

- (id)init {
    self = [super init];
    if (self) {
        _readingDate = [NSDate date];
        self.temperature = 65;
        self.temperatureValidated = NO;
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self){
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]){
        self.identifier = [value unsignedIntegerValue];
    }
}


@end