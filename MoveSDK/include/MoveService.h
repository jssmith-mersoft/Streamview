//
//  MoveService.h
//  Move1
//
//  Created by Jeff Smith on 2/6/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveService : NSObject
@property NSString * serviceId;             // Service Id
@property NSString * type;           // type of service
@property NSMutableSet  * subscriptions;  // username
@property NSMutableSet  * features;       // List of Services
@end
