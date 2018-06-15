//
//  CoreDataHelper.m
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/14/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

static CoreDataHelper *_helper = nil;
static NSPersistentContainer *_persistentContainer = nil;

+(CoreDataHelper *)helper {
    @synchronized([CoreDataHelper class]) {
        if (!_helper) {
            _helper = [[self alloc] init];
        }
    }

    return _helper;
}

-(NSPersistentContainer*)persistentContainer {
    @synchronized (self) {
        if (!_persistentContainer) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"StackOverflowUsers"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                }
            }];
        }
    }
    
    return _persistentContainer;
}

-(void)saveContext {
    NSManagedObjectContext *context = _persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
}

-(NSArray*)fetchEntity:(NSString*)entity inContext:(NSManagedObjectContext*) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching entity: %@\n%@", [error localizedDescription], [error userInfo]);
        return NULL;
    }
    
    return results;
}

@end
