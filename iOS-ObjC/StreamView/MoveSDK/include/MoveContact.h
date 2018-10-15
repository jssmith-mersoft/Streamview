//
//  MoveContact.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveContact : NSObject
@property NSString* uid;
@property NSString* id;
@property NSString* first_name;
@property NSString* last_name;
@property NSString* nickname;
@property NSString* email;

@property NSString* home_phone;
@property NSString* office_phone;
@property NSString* mobile_phone;
@property NSString* other_phone;

@property NSString* contactImgURL;
@property NSString* audio;
@property NSString* smsNotify;

@property NSString* home_address;
@property NSString* home_pobox;
@property NSString* home_city;
@property NSString* home_state;
@property NSString* home_zip;

@property NSString* company;
@property NSString* organization_position;
@property NSString* work_address;
@property NSString* work_pobox;
@property NSString* work_zip;
@property NSString* work_city;
@property NSString* work_state;

@property NSString* modeDate;
@property NSString* sync;

@property NSDate* created_at;
@property NSDate* updated_at;
@property NSDate* deleted_at;
@property NSDate* import_date;

@property NSString* attach_code;
@property NSString* private_contact;
@property NSString* username;
@property NSString* import_id;
@property NSString* directory_id;
@property NSString* status;
@property NSString* user_id;
@property NSString* group_id;


- (NSString *) getNumberTypeForNumber:(NSString*)number;
- (NSString *) getName;// (get's first and last or nickname)

+ (NSArray *) getContactsFromJSON:(NSDictionary *)json;
+ (MoveContact *) getContactFromJSON:(NSDictionary *)json;
+ (NSDictionary *) convertToDictionary;
@end
