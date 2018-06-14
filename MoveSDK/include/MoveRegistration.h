//
//  Registration.h
//  Move
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
@property NSString * name;    // username
@property NSString * username;    // username
@property NSString * tn;    // tn
@property NSMutableSet * services;    // List of Services
@property MoveService  * selectService;    // List of Services

- (id) initWithJSON:(NSDictionary *) data;
- (NSArray*) getCameras;
- (MoveService*) getCamerabyName:(NSString*)Name;
- (MoveService*) getCamerabyID:(NSString*)ID;
- (NSString*) getVoiceAccountId;
- (NSString*) getVideoAccountId;
- (NSString*) getUsername;
- (NSString*) getTN;
- (NSString*) getEmail;
@end



/*
 "address": "556677",
 "addressType": "camera",
 "address_id": "5afab7724e028b6a7c8f03fa",
 "created": "0001-01-01T00:00:00Z"
 */
@interface MoveServiceAddress : NSObject
@property NSString * address;
@property NSString * id;
@property NSString * type;
@property NSDate   * created;  
@end
