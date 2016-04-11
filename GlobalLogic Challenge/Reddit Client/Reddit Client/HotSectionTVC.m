//
//  HotSectionTVC.m
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import "HotSectionTVC.h"
#import "Post.h"
#import "Conexion.h"
#import "AppDelegate.h"
#import "CacheImage.h"

static NSString * const SMALLKEY = @"smallKey";

@interface HotSectionTVC ()

@property (nonatomic,strong) NSMutableArray * top50Array;
@property (strong, nonatomic) IBOutlet UITableView *tableViewTop50;
@property (strong,nonatomic) UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView * thumbnail;
- (IBAction)buttonRefresh:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) AppDelegate * appDelegate;
- (IBAction)buttonThumbnail:(id)sender;
@property (strong,nonatomic) UIView * viewBigSize;
@property (strong,nonatomic) UIView * fadeView;
@property(strong,nonatomic) UIImageView * bigSizeImage;
@property (nonatomic) int index;
@end

@implementation HotSectionTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIndicator.hidden = YES;
        [self downloadFirst50Post];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];

}

#pragma mark - Table view data source
-(void)downloadFirst50Post{
    self.activityIndicator.center = CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    self.appDelegate = [AppDelegate app];
    [self.appDelegate.window addSubview:self.activityIndicator];
        self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [Conexion jsonRequestWithBaseURL:[AppDelegate getUrlFromPlistFileWithKey:@"URL_TOP"] completion:^(NSDictionary *json, BOOL success) {
        if (success) {
            NSArray * allPosts =[[json valueForKey:@"data"] valueForKey:@"children"];
            self.top50Array = [NSMutableArray array];
            for (NSArray * singlePost  in allPosts) {
                Post * singlePostObject = [[Post alloc]initWithTitle:[[singlePost valueForKey:@"data"]valueForKey:@"title"] author:[[singlePost valueForKey:@"data"] valueForKey:@"author"] entryDate:[[singlePost valueForKey:@"data"] valueForKey:@"created_utc"] numberOfComments:[[singlePost valueForKey:@"data"] valueForKey:@"num_comments"] thumbnail:[[singlePost valueForKey:@"data"] valueForKey:@"thumbnail"] bigSizePhoto:[[singlePost valueForKey:@"data"] valueForKey:@"thumbnail"]];
                
                [self.top50Array addObject:singlePostObject];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                    self.activityIndicator.hidden = YES;
                [self.tableViewTop50 reloadData];
            });
            
            
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.top50Array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    top50TVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"top50" forIndexPath:indexPath];
    
    
    Post * singlePost = [self.top50Array objectAtIndex:indexPath.row];
    
    cell.buttonThumbnailFromCell.tag = indexPath.row;
    [cell.buttonThumbnailFromCell addTarget:self action:@selector(buttonThumbnail:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.labelTitle.text =  [singlePost getTitle];
    self.titleLabel.text =cell.labelTitle.text;
    [cell.labelTitle setFont:[UIFont fontWithName:@"Avenir" size:14]];
    cell.labelTitle.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:255.0/255.0 alpha:1];
    cell.labelTitle.numberOfLines = 0;
    cell.labelTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    cell.labelComments.text = [[NSString stringWithFormat:@"%@",[singlePost getNumberOfComments]] stringByAppendingString:@" comments"];
    cell.labelComments.textColor = [UIColor lightGrayColor];
    [cell.labelComments setFont:[UIFont fontWithName:@"Avenir" size:12]];
    
    
    cell.labelDateAndAuthor.text = [[@"submitted " stringByAppendingString:[[self getBirthDateWithMiliseconds:[[singlePost getEntryDate] longLongValue]] stringByAppendingString:@" hours ago by "]] stringByAppendingString:[singlePost getAuthor]];
    cell.labelDateAndAuthor.textColor = [UIColor lightGrayColor];
    [cell.labelDateAndAuthor setFont:[UIFont fontWithName:@"Avenir" size:12]];
    
    cell.imageThumbnail.image = [UIImage imageNamed:@"no_photo"];
    
    NSString * buildKey = [[singlePost getAuthor] stringByAppendingString:[NSString stringWithFormat:@"%@",[singlePost getEntryDate]]];
    NSString * key = [SMALLKEY stringByAppendingString:buildKey];
    UIImage * imageCached = [[CacheImage sharedInstance] getCachedImageForKey:key];
    
    if (imageCached) {
        cell.imageThumbnail.image = imageCached;
        cell.imageThumbnail.layer.cornerRadius = 5;
        cell.imageThumbnail.clipsToBounds = YES;
        cell.viewThumbnail.layer.cornerRadius = 5;
        cell.viewThumbnail.layer.borderWidth = 1;
        cell.viewThumbnail.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }else{
        NSString * urlThumbnail = [singlePost getThumbnail];
        if (urlThumbnail.length > 0) {
            NSURL * imageUrl = [NSURL URLWithString:[singlePost getThumbnail]];
            [Conexion downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    if (image != nil) {
                        cell.imageThumbnail.image = image;
                        cell.imageThumbnail.layer.cornerRadius = 5;
                        cell.imageThumbnail.clipsToBounds = YES;
                        cell.viewThumbnail.layer.cornerRadius = 5;
                        cell.viewThumbnail.layer.borderWidth = 1;
                        cell.viewThumbnail.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        
                        NSString * buildKey = [[singlePost getAuthor] stringByAppendingString:[NSString stringWithFormat:@"%@",[singlePost getEntryDate]]];
                        NSString * key = [SMALLKEY stringByAppendingString:buildKey];
                        [[CacheImage sharedInstance]cacheImage:image forKey:key];
                        
                    }
                }
            }];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  30.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString * titulo = @"Top 50 post from www.reddit.com/top";
    return titulo;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
       [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString*)getBirthDateWithMiliseconds:(long)dateInMiliseconds{
    
    long currentTimeStamp = [[self timeStamp]longLongValue];
    long xHours = currentTimeStamp - dateInMiliseconds;
    xHours = xHours/60;
    xHours = xHours/60;
    NSString * dateString = [NSString stringWithFormat:@"%ld", xHours];
    return dateString;
}
- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
}


- (IBAction)buttonRefresh:(id)sender {
    [self downloadFirst50Post];
}

- (IBAction)buttonThumbnail:(id)sender {
    self.index = (int)[sender tag];
    self.fadeView = [[UIView alloc]initWithFrame:CGRectMake(self.tableViewTop50.bounds.origin.x,self.tableViewTop50.bounds.origin.y+64, self.tableViewTop50.bounds.size.width,self.tableViewTop50.bounds.size.height)];
    [self.fadeView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    [self.view addSubview:self.fadeView];
    self.viewBigSize=[[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-100)];
    [self.viewBigSize setBackgroundColor:[UIColor whiteColor]];
    self.viewBigSize.layer.cornerRadius = 5;
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(5, self.viewBigSize.bounds.origin.y+self.viewBigSize.bounds.size.height-50, self.viewBigSize.bounds.size.width-10,45)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
  cancelButton.layer.cornerRadius = 5;
    [cancelButton addTarget:self action:@selector(dismissViewWithImage) forControlEvents:UIControlEventTouchUpInside];
    
    self.bigSizeImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.viewBigSize.bounds.size.width-40,self.viewBigSize.bounds.size.height-100)];
    
    NSString * buildKey = [[[self.top50Array objectAtIndex:[sender tag]] valueForKey:@"author"] stringByAppendingString:[NSString stringWithFormat:@"%@",[[self.top50Array objectAtIndex:[sender tag]] valueForKey:@"entryDate"]]];
    NSString * key = [SMALLKEY stringByAppendingString:buildKey];
    UIImage * image = [[CacheImage sharedInstance]getCachedImageForKey:key];
    if (image) {
        self.bigSizeImage.image = image;
    }else{
        self.bigSizeImage.image = [UIImage imageNamed:@"no_photo"];
    }

    
    [self.viewBigSize addSubview:self.bigSizeImage];
    [self.viewBigSize addSubview:cancelButton];
  
    [self.fadeView addSubview:self.viewBigSize];
    self.tableViewTop50.scrollEnabled = NO;

}
-(void)dismissViewWithImage{
    
    [UIView animateWithDuration:0.7 animations:^{
        self.fadeView.alpha = self.fadeView.alpha == 1 ? 0:1;
    } completion:^(BOOL finished) {
        self.tableViewTop50.scrollEnabled=YES;
    }];
    
}
- (void) orientationChanged:(NSNotification *)note{
    UIDevice * device = note.object;
    if (self.fadeView.alpha ==1) {
        switch(device.orientation)
        {
            case UIDeviceOrientationPortrait:
                //1
                [self fadeViewForPortrait];
                break;
            case UIDeviceOrientationLandscapeLeft:
                //3
                [self fadeViewForLandscapeLeft];
                break;
            case UIDeviceOrientationLandscapeRight:
                //4
                [self fadeViewForLandscapeRight];
                break;
                
            default:
                break;
        };
    }
}

-(void)fadeViewForPortrait{
    
    [self.fadeView removeFromSuperview];
    self.fadeView = [[UIView alloc]initWithFrame:CGRectMake(self.tableViewTop50.bounds.origin.x,self.tableViewTop50.bounds.origin.y+64, self.tableViewTop50.bounds.size.width,self.tableViewTop50.bounds.size.height)];
    [self.fadeView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    [self.view addSubview:self.fadeView];
    self.viewBigSize=[[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-100)];
    [self.viewBigSize setBackgroundColor:[UIColor whiteColor]];
    self.viewBigSize.layer.cornerRadius = 5;
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(5, self.viewBigSize.bounds.origin.y+self.viewBigSize.bounds.size.height-50, self.viewBigSize.bounds.size.width-10,45)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    cancelButton.layer.cornerRadius = 5;
    [cancelButton addTarget:self action:@selector(dismissViewWithImage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBigSize addSubview:cancelButton];
    
    self.bigSizeImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.viewBigSize.bounds.size.width-40,self.viewBigSize.bounds.size.height-100)];
    
    NSString * buildKey = [[[self.top50Array objectAtIndex:self.index] valueForKey:@"author"] stringByAppendingString:[NSString stringWithFormat:@"%@",[[self.top50Array objectAtIndex:self.index] valueForKey:@"entryDate"]]];
    NSString * key = [SMALLKEY stringByAppendingString:buildKey];
    UIImage * image = [[CacheImage sharedInstance]getCachedImageForKey:key];
    if (image) {
        self.bigSizeImage.image = image;
    }else{
        self.bigSizeImage.image = [UIImage imageNamed:@"no_photo"];
    }
    
    [self.viewBigSize addSubview:self.bigSizeImage];
    
    [self.fadeView addSubview:self.viewBigSize];
    self.tableViewTop50.scrollEnabled = NO;
}

-(void)fadeViewForLandscapeLeft{
    [self.fadeView removeFromSuperview];
    
    self.fadeView = [[UIView alloc]initWithFrame:CGRectMake(self.tableViewTop50.bounds.origin.x,self.tableViewTop50.bounds.origin.y+30, self.tableViewTop50.bounds.size.width,self.tableViewTop50.bounds.size.height)];
    [self.fadeView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    [self.view addSubview:self.fadeView];
    self.viewBigSize=[[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-70)];
    [self.viewBigSize setBackgroundColor:[UIColor whiteColor]];
    self.viewBigSize.layer.cornerRadius = 5;
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(5, self.viewBigSize.bounds.origin.y+self.viewBigSize.bounds.size.height-50, self.viewBigSize.bounds.size.width-10,45)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    cancelButton.layer.cornerRadius = 5;
    [cancelButton addTarget:self action:@selector(dismissViewWithImage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBigSize addSubview:cancelButton];
    
    self.bigSizeImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.viewBigSize.bounds.size.width-40,self.viewBigSize.bounds.size.height-100)];
    
    NSString * buildKey = [[[self.top50Array objectAtIndex:self.index] valueForKey:@"author"] stringByAppendingString:[NSString stringWithFormat:@"%@",[[self.top50Array objectAtIndex:self.index] valueForKey:@"entryDate"]]];
    NSString * key = [SMALLKEY stringByAppendingString:buildKey];
    UIImage * image = [[CacheImage sharedInstance]getCachedImageForKey:key];
    if (image) {
        self.bigSizeImage.image = image;
    }else{
        self.bigSizeImage.image = [UIImage imageNamed:@"no_photo"];
    }
    
    [self.viewBigSize addSubview:self.bigSizeImage];
    
    [self.fadeView addSubview:self.viewBigSize];
    self.tableViewTop50.scrollEnabled = NO;

}

-(void)fadeViewForLandscapeRight{
    [self.fadeView removeFromSuperview];
    
    self.fadeView = [[UIView alloc]initWithFrame:CGRectMake(self.tableViewTop50.bounds.origin.x,self.tableViewTop50.bounds.origin.y+30, self.tableViewTop50.bounds.size.width,self.tableViewTop50.bounds.size.height)];
    [self.fadeView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
    [self.view addSubview:self.fadeView];
    self.viewBigSize=[[UIView alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40,self.view.bounds.size.height-70)];
    [self.viewBigSize setBackgroundColor:[UIColor whiteColor]];
    self.viewBigSize.layer.cornerRadius = 5;
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(5, self.viewBigSize.bounds.origin.y+self.viewBigSize.bounds.size.height-50, self.viewBigSize.bounds.size.width-10,45)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    cancelButton.layer.cornerRadius = 5;
    [cancelButton addTarget:self action:@selector(dismissViewWithImage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBigSize addSubview:cancelButton];
    
    self.bigSizeImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.viewBigSize.bounds.size.width-40,self.viewBigSize.bounds.size.height-100)];
    
    NSString * buildKey = [[[self.top50Array objectAtIndex:self.index] valueForKey:@"author"] stringByAppendingString:[NSString stringWithFormat:@"%@",[[self.top50Array objectAtIndex:self.index] valueForKey:@"entryDate"]]];
    NSString * key = [SMALLKEY stringByAppendingString:buildKey];
    UIImage * image = [[CacheImage sharedInstance]getCachedImageForKey:key];
    if (image) {
        self.bigSizeImage.image = image;
    }else{
        self.bigSizeImage.image = [UIImage imageNamed:@"no_photo"];
    }
    
    [self.viewBigSize addSubview:self.bigSizeImage];
    
    [self.fadeView addSubview:self.viewBigSize];
    self.tableViewTop50.scrollEnabled = NO;
    
}
@end
