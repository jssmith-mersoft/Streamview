//
//  MoveNotification.h
//  Move1
//
//  Created by Jeff Smith on 2/12/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveNotification : NSObject

@property NSString* id;
@property NSDictionary* target;
@property NSDictionary* message;
@property NSString* operation;
@property NSString* type;

+ (MoveNotification *) getNotificationFromJSON:(NSDictionary *)json;

@end