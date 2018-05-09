//
//  Registration.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveService.h"

@interface MoveRegistration : NSObject

@property NSString * registrationId;          // RegistrationId
@property NSDate   * created;     // timestamp of account creation
@property NSDate   * updated;     // timestamp of account updated
@property NSString * accountId;   // Account ID
@property NSString * username;    // username
@property NSString * tn;    // tn
@property NSMutableSet * services;    // List of Services
@property MoveService  * selectService;    // List of Services

- (id) initWithJSON:(NSDictionary *) data;
- (NSString*) getVoiceAccountId;
- (NSString*) getVideoAccountId;
- (NSString*) getUsername;
@end