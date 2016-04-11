//
//  Post.m
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import "Post.h"

@interface Post()

@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * author;
@property (nonatomic,strong) NSString * entryDate;
@property (nonatomic,strong) NSString * numberOfComments;
@property (nonatomic,strong) NSString * thumbnail;
@property (nonatomic,strong) NSString * bigSizePhoto;
@end

@implementation Post


- (id)initWithTitle:(NSString*)title author:(NSString*)author entryDate:(NSString*)entryDate numberOfComments:(NSString*)numberOfComments thumbnail:(NSString*)thumbnail bigSizePhoto:(NSString*)bigSizePhoto{
    
    self = [super init];
    if( self )
    {
        self.title = title;
        self.author = author;
        self.entryDate = entryDate;
        self.numberOfComments = numberOfComments;
        self.thumbnail = thumbnail;
        self.bigSizePhoto = bigSizePhoto;
    }
    return self;
}


-(NSString*)getTitle{
    return self.title;
}

-(NSString*)getAuthor{
    return self.author;
}
-(NSString*)getEntryDate{
    return self.entryDate;
}
-(NSString*)getNumberOfComments{
    return self.numberOfComments;
}
-(NSString*)getThumbnail{
    return self.thumbnail;
}
-(NSString*)getBigSizePhoto{
    return self.bigSizePhoto;
}
@end
