//
//  UserTableViewCell.h
//  StackOverflowUsers
//
//  Created by Amin Davoodi on 6/12/18.
//  Copyright © 2018 minimiigames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *gravatar;
@property (weak, nonatomic) IBOutlet UILabel *reputation;
@property (weak, nonatomic) IBOutlet UILabel *gold;
@property (weak, nonatomic) IBOutlet UILabel *silver;
@property (weak, nonatomic) IBOutlet UILabel *bronze;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
