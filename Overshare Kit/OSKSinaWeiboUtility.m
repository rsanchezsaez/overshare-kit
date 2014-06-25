//
//  OSKSinaWeiboUtility.m
//  Overshare
//
//
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKSinaWeiboUtility.h"

@import Social;
@import Accounts;

#import "OSKLogger.h"
#import "OSKManagedAccountCredential.h"
#import "OSKShareableContentItem.h"

@implementation OSKSinaWeiboUtility

#pragma mark - Write Post

+ (void)postContentItem:(OSKMicroblogPostContentItem *)item
        toSystemAccount:(ACAccount *)account
             completion:(void(^)(BOOL success, NSError *error))completion {
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData != nil)
        {
            NSInteger statusCode = urlResponse.statusCode;
            if ((statusCode >= 200) && (statusCode < 300))
            {
                OSKLog(@"[OSKSinaWeiboUtility] Successfully created Sina Weibo post");
                

                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }
            }
            else
            {
                NSString *responseString = nil;
                if (responseData) {
                    responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                }
                
                OSKLog(@"[OSKSinaWeiboUtility] Error received when trying to create Sina Weibo post. Server responded with status code %li and response: %@",
                       (long)statusCode,
                       responseString);
                
                NSError *error = [NSError errorWithDomain:@"com.overshare.Errors" code:statusCode userInfo:nil];
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, error);
                    });
                }
            }
        }
        else
        {
            OSKLog(@"[OSKSinaWeiboUtility] An error occurred while attempting to to create Sina Weibo post: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO, error);
                }
            });
        }
    };
    
    NSURL *URL = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];

    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] init];
    postDictionary[@"status"] = item.text;
    
    if ([item.images count] > 0)
    {
        URL = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"];
    }
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo
                                            requestMethod:SLRequestMethodPOST
                                                      URL:URL
                                               parameters:postDictionary];
    
    if ([item.images count] > 0) {
        UIImage *image = item.images[0];
        [request addMultipartData:UIImageJPEGRepresentation(image, 1.0f) withName:@"pic" type:@"image/jpeg" filename:@"image.jpg"];
    }
    
 	request.account = account;
    [request performRequestWithHandler:requestHandler];
}

@end

