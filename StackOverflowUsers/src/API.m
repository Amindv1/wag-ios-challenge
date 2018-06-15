//
//  API.m
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/12/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import "API.h"

@implementation API

+(BOOL) hasError:(NSError * _Nullable) error {
    if (error != NULL) {
        NSLog(@"There was an error performing request: %@", error);
        return true;
    }
    
    return false;
}

+(BOOL) hasBadResponse:(NSURLResponse * _Nullable) response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    if ([httpResponse statusCode] < 200 || [httpResponse statusCode] > 299) {
        NSLog(@"There was a server error: %@", response);
        return true;
    }
    
    return false;
}

+(void)performDataTask:(NSString*) urlString completionHandler: (void (^)(NSData * _Nullable data)) cb {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([API hasBadResponse:response] || [API hasError:error]) {
            cb(NULL);
            return;
        }
        
        cb(data);
    }];
    
    [task resume];
}

+(void)getUsers: (void (^)(NSArray *users)) cb {
    NSString *urlString = @"https://api.stackexchange.com/2.2/users?order=desc&sort=reputation&site=stackoverflow";
    [API performDataTask:urlString completionHandler:^(NSData * _Nullable data) {
        if (data != NULL) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray *users = json[@"items"];
            cb(users);
        }
    }];
}

+(void)getImage:(NSString*)gravatarURL completionHandler: (void (^)(NSData *gravatarImageData)) cb {
    [API performDataTask:gravatarURL completionHandler:^(NSData * _Nullable data) {
        if (data != NULL) {
            cb(data);
        }
    }];
}

@end
