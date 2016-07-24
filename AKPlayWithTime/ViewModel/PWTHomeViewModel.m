//
//  PWTHomeViewModel.m
//  AKPlayWithTime
//
//  Created by lisaike on 16/7/23.
//  Copyright © 2016年 lisaike. All rights reserved.
//

#import "PWTHomeViewModel.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//model
#import "Event.h"

static NSUInteger const kDefaultLimit = 5;

@interface PWTHomeViewModel ()

@property (nonatomic, assign) NSUInteger loadAtPage;

@end

@implementation PWTHomeViewModel

- (void)addEventWithContent:(NSString *)content startTime:(NSDate *)start endTime:(NSDate *)end {
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
    NSTimeInterval timeInterval = [end timeIntervalSinceDate:start];
    event.startTime = start;
    event.endTime = end;
    event.text = [NSString stringWithFormat:@"[%@'%02li]%@(%@~%@)", @((NSInteger)timeInterval/3600), (NSInteger)timeInterval % 3600 / 60, content, [[self _timeFormatter] stringFromDate:start], [[self _timeFormatter] stringFromDate:end]];
    NSError *error;
    [context save:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)removeEvent:(Event *)event {
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    [context deleteObject:event];
    NSError *error;
    [context save:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)removeAllEvents {
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSError *error;
    NSArray<Event *> *itemToDelete = [self _fetchEventsAtPage:0 error:&error];
    if (error) {
        NSLog(@"fetch data error:%@", error);
        return;
    }
    for (Event *event in itemToDelete) {
        [context deleteObject:event];
    }
    [context save:&error];
    if (error) {
        NSLog(@"delete save error:%@", error);
    }
    
}

- (void)reloadDataWithCompletion:(void (^)(NSError *, NSArray<Event *> *))completionBlock {
    _loadAtPage = 0;
    [self loadNextPageWithCompletion:completionBlock];
}

- (void)loadNextPageWithCompletion:(void (^)(NSError *, NSArray<Event *> *))completionBlock {
    NSError *error;
    NSArray<Event *> *result = [self _fetchEventsAtPage:_loadAtPage error:&error];
    if (error) {
        completionBlock(error,nil);
        return;
    }
    completionBlock(nil,result);
    _loadAtPage ++;
}

#pragma mark - private

- (NSArray<Event *> *)_fetchEventsAtPage:(NSUInteger)page error:(NSError **)error{
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
//    request.fetchLimit = kDefaultLimit;
//    request.fetchOffset = page * kDefaultLimit;
    NSError *innerError;
    NSArray<Event *> *results = [context executeFetchRequest:request error:&innerError];
    if (innerError) {
        NSLog(@"%@", innerError);
        *error = innerError;
    }
    return results;
}

#pragma mark - time formatters

- (NSDateFormatter *)_timeFormatter {
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"hh:mm";
    });
    return timeFormatter;
}

@end
