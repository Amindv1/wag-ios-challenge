//
//  UsersTableViewController.m
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/12/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import "API.h"
#import "CoreDataHelper.h"
#import "UserTableViewCell.h"
#import "UsersTableViewController.h"
#import "Gravatar+CoreDataClass.h"
#import "GravatarURL+CoreDataClass.h"

@interface UsersTableViewController ()

@end

@implementation UsersTableViewController

static NSString *CellID = @"UserCellID";
NSMutableArray *data;

-(void)viewDidLoad {
    [super viewDidLoad];
    data = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:CellID];
    [self getUserData];
}

-(void)getUserData {
    [API getUsers: ^(NSArray *users) {
        for (NSDictionary *user in users) {
            NSMutableDictionary *user1 = [@{
                                            @"username" : user[@"display_name"],
                                            @"gold": user[@"badge_counts"][@"gold"],
                                            @"bronze": user[@"badge_counts"][@"bronze"],
                                            @"silver": user[@"badge_counts"][@"silver"],
                                            @"reputation": user[@"reputation"],
                                            @"gravatar": user[@"profile_image"],
                                            } mutableCopy];
            
            [data addObject:user1];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        [self getImagesForUsers];
    }];
}

/**
 Fetches all GravatarURL entities from CoreData. Displays corresponding Gravatar for existing URL's
 and downloads image data for the rest.
 
 In order to improve performance, we seperate the GravatarURL and the Gravatar entities. By doing this
 we avoid loading image data for URL's that will not be displayed in the tableview. Instead, we
 set a relationship between the two entities and get the image data when necessary.
 */
-(void)getImagesForUsers {
    NSManagedObjectContext *context = [[[CoreDataHelper helper] persistentContainer] viewContext];
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateContext setParentContext:context];
    
    [privateContext performBlock:^{
        NSArray *results = [[CoreDataHelper helper] fetchEntity: @"GravatarURL" inContext:privateContext];
        for (int i = 0; i < [data count]; i++) {
            NSMutableDictionary *user = data[i];
            NSString *gravatarURL = user[@"gravatar"];
            NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"imageURL == %@", gravatarURL];
            NSArray *gURLs = [results filteredArrayUsingPredicate:predicate];
            if ([gURLs count] > 0) {
                GravatarURL *gURL = gURLs[0];
                Gravatar *g = [gURL image];
                user[@"gravatarData"] = [g imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                [API getImage:gravatarURL completionHandler: ^(NSData *gravatarImageData) {
                    if (gravatarImageData == NULL) {
                        NSLog(@"Gravatar image data is null. Can't set gravatar.");
                        return;
                    }
                    [user setObject:gravatarImageData forKey:@"gravatarData"];
                    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                    [privateContext setParentContext:context];
                    [privateContext performBlockAndWait:^{
                        Gravatar *g = [NSEntityDescription insertNewObjectForEntityForName:@"Gravatar" inManagedObjectContext:privateContext];
                        GravatarURL *gURL = [NSEntityDescription insertNewObjectForEntityForName:@"GravatarURL" inManagedObjectContext:privateContext];
                        [gURL setImageURL:gravatarURL];
                        [g setImageData:gravatarImageData];
                        [g setGravatarURL:gURL];
                        [gURL setImage:g];
                        NSError *error = nil;
                        if ([privateContext hasChanges] && ![privateContext save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                        }
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [[CoreDataHelper helper] saveContext];
                    });
                }];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *userData = data[indexPath.row];
    [cell.username setText:userData[@"username"]];
    [cell.gold setText:[userData[@"gold"] stringValue]];
    [cell.silver setText:[userData[@"silver"] stringValue]];
    [cell.bronze setText:[userData[@"bronze"] stringValue]];
    [cell.reputation setText:[userData[@"reputation"] stringValue]];
    [cell.activityIndicator startAnimating];
    if ([[userData allKeys] containsObject:@"gravatarData"]) {
        [cell.gravatar setImage:[UIImage imageWithData:userData[@"gravatarData"]]];
        [cell.activityIndicator stopAnimating];
    }
    
    return cell;
}

@end
