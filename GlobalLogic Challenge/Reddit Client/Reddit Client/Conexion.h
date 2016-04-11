//
//  Conexion.h
//  Reddit Client
//
//  Created by alvaro sebastian leon romero on 1/17/16.
//  Copyright © 2016 seblerom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Conexion : NSObject<NSURLSessionDataDelegate,NSURLSessionDelegate>

+ (void)jsonRequestWithBaseURL:(NSString *)baseURL completion:(void (^)( NSDictionary * json, BOOL success))completion;
+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
@end
