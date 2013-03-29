//
// CTCReadingsService
// TemperatureReadings
//
// Created by ncipollina on 3/25/13.
// Copyright 2013 Lowe's Companies, Inc..  All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>

@class CTCReading;

typedef void (^CompletionBlock) ();
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^BusyUpdateBlock) (BOOL busy);

@interface CTCReadingsService : NSObject<MSFilter>

@property (nonatomic, strong)   NSArray *readings;
@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;

+(CTCReadingsService *)sharedService;

- (void) refreshDataOnSuccess:(CompletionBlock) completion;

- (void) addReading:(CTCReading *) reading
      completion:(CompletionWithIndexBlock) completion;

- (void) updateReading:(CTCReading *)reading
            completion:(CompletionWithIndexBlock) completion;

- (void) deleteReading:(CTCReading *)reading
            completion:(CompletionWithIndexBlock)completion;

-(void) handleRequest:(NSURLRequest *)request
               onNext:(MSFilterNextBlock)onNext
           onResponse:(MSFilterResponseBlock)onResponse;

@end