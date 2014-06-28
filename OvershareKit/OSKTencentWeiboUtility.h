//
//  OSKTencentWeiboUtility.h
//  Overshare
//
//  Created by Jared Sinclair on 10/10/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

@class OSKMicroblogPostContentItem;
@class ACAccount;
@class OSKApplicationCredential;

@interface OSKTencentWeiboUtility : NSObject

+ (void)postContentItem:(OSKMicroblogPostContentItem *)item
        toSystemAccount:(ACAccount *)account
          appCredential:(OSKApplicationCredential *)appCredential
             completion:(void(^)(BOOL success, NSError *error))completion; // called on main queue

@end



