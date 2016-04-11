//
//  Post.h
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Post : NSObject

- (id)initWithTitle:(NSString*)title author:(NSString*)author entryDate:(NSString*)entryDate numberOfComments:(NSString*)numberOfComments thumbnail:(NSString*)thumbnail bigSizePhoto:(NSString*)bigSizePhoto;

-(NSString*)getTitle;
-(NSString*)getAuthor;
-(NSString*)getEntryDate;
-(NSString*)getNumberOfComments;
-(NSString*)getThumbnail;
-(NSString*)getBigSizePhoto;

@end
