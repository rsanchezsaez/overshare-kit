//
//  OSKTencentWeiboUtility.m
//  Overshare
//
//
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKTencentWeiboUtility.h"

@import Social;
@import Accounts;

#import "OSKLogger.h"
#import "OSKManagedAccountCredential.h"
#import "OSKApplicationCredential.h"
#import "OSKShareableContentItem.h"

#import <AnimatedGIFImageSerialization/AnimatedGIFImageSerialization.h>

@interface UIImage (OSKFix)

- (UIImage *)imageWithAppliedOrientation;

@end

@implementation UIImage (OSKFix)

// Redraw image so image.imageOrientation is
// applied to the actual image data
- (UIImage *)imageWithAppliedOrientation
{
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointMake(0, 0)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation OSKTencentWeiboUtility

#pragma mark - Write Post

+ (void)postContentItem:(OSKMicroblogPostContentItem *)item
        toSystemAccount:(ACAccount *)account
          appCredential:(OSKApplicationCredential *)appCredential
             completion:(void(^)(BOOL success, NSError *error))completion {
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData != nil)
        {
            NSInteger statusCode = urlResponse.statusCode;
            if ((statusCode >= 200) && (statusCode < 300))
            {
                OSKLog(@"[OSKTencentWeiboUtility] Successfully created Tencent Weibo post");
                
                
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
                
                OSKLog(@"[OSKTencentWeiboUtility] Error received when trying to create Tencent Weibo post. Server responded with status code %li and response: %@",
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
            OSKLog(@"[OSKTencentWeiboUtility] An error occurred while attempting to to create Tencent Weibo post: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO, error);
                }
            });
        }
    };
    
    // This API endpoint also works for regular posts without picture
    NSURL *URL = [NSURL URLWithString:@"https://open.t.qq.com/api/t/add_pic"];
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableString *message = [NSMutableString new];
    if (item.text) {
        [message appendString:item.text];
    }
    if (item.textURL && [item.textURL length] > 0) {
        if ([message length] > 0)
        {
            [message appendString:@" "];
        }
        [message appendFormat:@"%@", item.textURL];
    }
    postDictionary[@"content"] = message;
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTencentWeibo
                                            requestMethod:SLRequestMethodPOST
                                                      URL:URL
                                               parameters:postDictionary];
    
    if ([item.images count] > 0) {
        UIImage *image = item.images[0];
        NSData *imageData = nil;
        NSString *MIMEtype = nil;
        NSString *remoteFilename = nil;
        if ([image.images count] >= 2) {
            imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:image
                                                                       duration:1.0
                                                                      loopCount:1
                                                                          error:nil];
            MIMEtype = @"image/gif";
            remoteFilename = @"image.gif";
        }
        else
        {
            // Tencent doesn't honor the image.imageOrientation EXIF flag
            // so we have to redraw it just in case
            image = [item.images[0] imageWithAppliedOrientation];

            imageData = UIImageJPEGRepresentation(image, 1.0f);
            MIMEtype = @"image/jpeg";
            remoteFilename = @"image.jpg";
        }
        
        [request addMultipartData:imageData withName:@"pic" type:MIMEtype filename:remoteFilename];
    }

    request.account = account;
    [request performRequestWithHandler:requestHandler];

}

@end


