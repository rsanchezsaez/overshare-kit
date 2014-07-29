//
//  OSKFacebookSDKActivity.h
//  Overshare
//
//  Created by Jared Sinclair on 10/15/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKActivity.h"

#import "OSKFacebookSharing.h"
#import "OSKActivity_GenericAuthentication.h"

@interface OSKFacebookSDKActivity : OSKActivity <OSKFacebookSharing, OSKActivity_GenericAuthentication>

// Defaults to ACFacebookAudienceEveryone. See ACAccountType.h for all options.
@property (copy, nonatomic) NSString *currentAudience;
@property (strong, nonatomic) NSDictionary *userInfo;

@end
