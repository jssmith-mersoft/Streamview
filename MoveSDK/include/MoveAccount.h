//
//  MoveAccount.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoveAccount : NSObject
+ (MoveAccount *) getAccountFromJSON:(NSDictionary *)json;
@end
