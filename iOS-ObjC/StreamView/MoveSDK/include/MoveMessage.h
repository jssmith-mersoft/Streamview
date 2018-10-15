//
//  MoveMessage.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveMessage : NSObject
@property NSString* id;
@property NSString* numberType;
@property NSString* to;
@property NSString* from;
@property NSString* status;
@property NSString* timestame;
@property NSString* class;
@property NSString* priority;
@property NSString* content;
- (int)getSize;

+ (NSArray *) getMessagesFromJSON:(NSDictionary *)json;
+ (MoveMessage *) getMessageFromJSON:(NSDictionary *)json;
@end
