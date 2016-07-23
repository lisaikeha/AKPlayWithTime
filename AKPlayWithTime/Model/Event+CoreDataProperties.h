//
//  Event+CoreDataProperties.h
//  AKPlayWithTime
//
//  Created by lisaike on 16/7/23.
//  Copyright © 2016年 lisaike. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) NSDate *startTime;

@end

NS_ASSUME_NONNULL_END
