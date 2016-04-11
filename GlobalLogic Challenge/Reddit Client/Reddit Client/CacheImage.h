//
//  CacheImage.h
//  Reddit Client
//
//  Created by Sebastian Leon on 1/19/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface CacheImage : NSObject

+ (CacheImage*)sharedInstance;
- (void)cacheImage:(UIImage*)image forKey:(NSString*)key;
- (UIImage*)getCachedImageForKey:(NSString*)key;
@end
