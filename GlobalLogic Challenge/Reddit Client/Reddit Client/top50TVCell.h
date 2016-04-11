//
//  top50TVCell.h
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface top50TVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDateAndAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelComments;
@property (strong, nonatomic) IBOutlet UIButton *buttonThumbnailFromCell;

@end
