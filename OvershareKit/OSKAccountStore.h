//
//  OSKAccountStore.h
//  Pods
//
//  Created by Ricardo Sánchez-Sáez on 02/07/2014.
//
//

#import <Foundation/Foundation.h>

@class OSKActivity;

@interface OSKAccountStore : NSObject

///-----------------------------------------------
/// @name Account Access
///-----------------------------------------------

+ (instancetype)sharedInstance;

/**
    Return active account (either OSKManagedAccount or ACAccount)
 */
- (id)activeAccountForActivity:(OSKActivity *)activity;

/**
 Return active account name
 */
- (NSString *)activeAccountUsernameForActivity:(OSKActivity *)activity;

@end
