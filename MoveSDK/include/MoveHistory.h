//
//  MoveHistory.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveHistory : NSObject
@property NSString * historyId;
@property NSDate   * sent;     // timestamp of send
@property NSDate   * created; // timestamp of created
@property NSDate   * updated; // timestamp of created
@property NSString * type;     // audio/text/image/call
@property NSString * toId;     // identification like a phonenumer or email address
@property NSString * toType;   // identification like a phonenumer or email address
@property NSString * fromId;   // identification like a phonenumer or email address
@property NSString * fromType; // identification type like a phonenumer or email address
@property NSString * context;  // a way to link it back to the message

+ (NSArray *) getHistoryFromJSON:(NSDictionary *)json;
+ (MoveHistory *) getHistoryItemFromJSON:(NSDictionary *)json;
@end
