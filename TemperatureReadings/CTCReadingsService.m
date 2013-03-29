//
// CTCReadingsService
// TemperatureReadings
//
// Created by ncipollina on 3/25/13.
// Copyright 2013 Lowe's Companies, Inc..  All rights reserved.
//


#import "CTCReadingsService.h"
#import "CTCReading.h"

@interface CTCReadingsService ()

@property (nonatomic, strong) MSTable *readingsTable;
@property (nonatomic)           NSInteger busyCount;

@end

@implementation CTCReadingsService {

}
+ (CTCReadingsService *)sharedService {
    static dispatch_once_t onceToken;
    static CTCReadingsService *instance;

    dispatch_once(&onceToken, ^{
        instance = [CTCReadingsService new];
    });

    return instance;
}

- (void)refreshDataOnSuccess:(CompletionBlock)completion {
    // Create a predicate that finds items where temperatureValidated is true
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"temperatureValidated == YES"];

    // Query the Reading table and update the readings property with the results from the service
    [self.readingsTable readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error) {

        [self logErrorIfNotNil:error];

        [self setReadingsArrayFromResults:results];

        // Let the caller know that we finished
        completion();
    }];

}

- (void)addReading:(CTCReading *)reading
        completion:(CompletionWithIndexBlock)completion {
    [self.readingsTable insert:[reading toDictionary] completion:^(NSDictionary *result, NSError *error){
        if (error) {
            [self logErrorIfNotNil:error];
        } else {
            NSUInteger index = [self.readings count];
            [(NSMutableArray *)self.readings insertObject:[[CTCReading alloc] initWithDictionary:result] atIndex:index];

            // Let the caller know that we finished
            completion(index);
        }
    }];
}

- (void)updateReading:(CTCReading *)reading
           completion:(CompletionWithIndexBlock)completion {
    [self.readingsTable update:[reading toDictionary] completion:^(NSDictionary *result, NSError *error){
        if (error) {
            [self logErrorIfNotNil:error];
        } else {
            NSUInteger index = 0;
            for (int i = 0; i < [self.readings count]; i ++){
                if (reading.identifier == [(CTCReading *)self.readings[i] identifier]){
                    index = i;
                    break;
                }
            }
            ((NSMutableArray *)self.readings)[index] = reading;

            // Let the caller know that we finished
            completion(index);
        }
    }];
}

- (void)deleteReading:(CTCReading *)reading completion:(CompletionWithIndexBlock)completion {
    [self.readingsTable delete:[reading toDictionary] completion:^(NSNumber *itemId, NSError *error){
        if (error){
            [self logErrorIfNotNil:error];
        } else {
            NSUInteger index = 0;
            for (int i = 0; i < [self.readings count]; i++){
                CTCReading *r = self.readings[i];
                if (r.identifier == [itemId integerValue]){
                    index = i;
                    break;
                }
            }
            [(NSMutableArray *) self.readings removeObjectAtIndex:index];

            completion(index);
        }
    }];
}

- (void)setReadingsArrayFromResults:(NSArray *)results {
    NSMutableArray *readings = [NSMutableArray array];

    for (NSDictionary *dictionary in results){
        [readings addObject:[[CTCReading alloc] initWithDictionary:dictionary]];
    }

    self.readings = readings;
}



- (void)handleRequest:(NSURLRequest *)request
               onNext:(MSFilterNextBlock)onNext
           onResponse:(MSFilterResponseBlock)onResponse {
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self busy:NO];
        onResponse(response, data, error);
    };

    // Increment the busy counter before sending the request
    [self busy:YES];
    onNext(request, wrappedResponse);
}

- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil) {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil) {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error && error.code == MSErrorMessageErrorCode) {
        NSLog(@"ERROR %@", error);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Request Failed"
                                                     message:error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialize the Mobile Service client with your URL and key
        MSClient *newClient = [MSClient clientWithApplicationURLString:@""
                                                    withApplicationKey:@""];

        // Add a Mobile Service filter to enable the busy indicator
        self.client = [newClient clientwithFilter:self];

        // Create an MSTable instance to allow us to work with the TodoItem table
        self.readingsTable = [_client getTable:@"Reading"];

        self.readings = [NSMutableArray array];
        self.busyCount = 0;
    }

    return self;
}


@end