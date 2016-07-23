//
//  PWTHomeViewModel.h
//  AKPlayWithTime
//
//  Created by lisaike on 16/7/23.
//  Copyright © 2016年 lisaike. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Event.h"
@interface PWTHomeViewModel : NSObject

@property (nonatomic, copy  ) NSArray<Event *> *events;
@property (nonatomic, assign, readonly) NSUInteger loadAtPage;

- (void)addEventWithContent:(NSString *)content
                  startTime:(NSDate *)start
                    endTime:(NSDate *)end;
- (void)removeEvent:(Event *)event;

- (void)reloadDataWithCompletion:(void(^)(NSError *error, NSArray<Event *> *array))completionBlock;
- (void)loadNextPageWithCompletion:(void(^)(NSError *error, NSArray<Event *> *array))completionBlock;

@end
