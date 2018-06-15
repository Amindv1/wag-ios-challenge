//
//  CoreDataHelper.h
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/14/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

+(CoreDataHelper*)helper;
-(NSPersistentContainer*)persistentContainer;
-(void)saveContext;
-(NSArray*)fetchEntity:(NSString*) entity inContext:(NSManagedObjectContext*) context;

@end
