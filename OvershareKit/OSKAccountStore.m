//
//  OSKAccountStore.m
//  Pods
//
//  Created by Ricardo Sánchez-Sáez on 02/07/2014.
//
//

#import "OSKAccountStore.h"

#import "OSKActivity.h"
#import "OSKSystemAccountStore.h"
#import "OSKManagedAccountStore.h"
#import "OSKManagedAccount.h"

@implementation OSKAccountStore

#pragma mark - Authentication

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static OSKManagedAccountStore * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)activeAccountForActivity:(OSKActivity *)activity {
    id account = nil;
    if ([[activity class] authenticationMethod] == OSKAuthenticationMethod_SystemAccounts) {
        account = [[OSKSystemAccountStore sharedInstance] lastUsedAccountForType:[[activity class] systemAccountTypeIdentifier]];
    }
    else if ([[activity class] authenticationMethod] == OSKAuthenticationMethod_ManagedAccounts) {
        account = [[OSKManagedAccountStore sharedInstance] activeAccountForActivityType:[[activity class] activityType]];
    }
    return account;
}

- (NSString *)activeAccountUsernameForActivity:(OSKActivity *)activity {
    id account = [self activeAccountForActivity:activity];
    NSString *username = nil;
    if (account) {
        if ([account isKindOfClass:[ACAccount class]] || [account isKindOfClass:[OSKManagedAccount class]])
        {
            username = [account username];
        }
    }
    return username;
}

@end
