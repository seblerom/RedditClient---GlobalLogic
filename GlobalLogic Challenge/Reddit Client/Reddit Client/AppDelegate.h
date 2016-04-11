//
//  AppDelegate.h
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(NSString*)getUrlFromPlistFileWithKey:(NSString*)dictKey;
+(AppDelegate*) app;
@end

