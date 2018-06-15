//
//  API.h
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/12/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+(void)getUsers: (void (^)(NSArray *users)) cb;
+(void)getImage:(NSString*)gravatarURL completionHandler: (void (^)(NSData *gravatarImageData)) cb;

@end
