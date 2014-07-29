//
//  OSKSystemAccountManager.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKSystemAccountStore.h"
#import <Accounts/Accounts.h>
#import "OSKLogger.h"
#import "OSKFileManager.h"

static NSString * OSKSystemAccountStoreSavedActiveAccountIDsKey = @"OSKSystemAccountStoreSavedActiveAccountIDsKey";

@interface OSKSystemAccountStore ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (strong, nonatomic) NSMutableDictionary *lastUsedAccountIDsByAccountType;

@end

@implementation OSKSystemAccountStore

+ (id)sharedInstance {
    static dispatch_once_t once;
    static OSKSystemAccountStore * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        [self _loadSavedActiveAccountIDs];
    }
    return self;
}

- (BOOL)accessGrantedForAccountsWithAccountTypeIdentifier:(NSString *)accountTypeIdentifier {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];

    return [accountType accessGranted];
}

- (void)requestAccessToAccountsWithAccountTypeIdentifier:(NSString *)accountTypeIdentifier
                                                 options:(NSDictionary *)options
                                              completion:(OSKSystemAccountAccessRequestCompletionHandler)completion
{
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];

    [self.accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                OSKLog(@"System account access request denied: %@", error.localizedDescription);
            }
           completion(granted, error);
        });
    }];
}

- (NSArray *)accountsForAccountTypeIdentifier:(NSString *)accountTypeIdentifier {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];

    return [self.accountStore accountsWithAccountType:accountType];
}

- (void)renewCredentialsForAccount:(ACAccount *)account completion:(void(^)(ACAccountCredentialRenewResult renewResult, NSError *error))completion {
    [self.accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult theRenewResult, NSError *theError) {
        if (completion) {
            completion(theRenewResult, theError);
        }
    }];
}

#pragma mark - Active Accounts

- (NSString *)lastUsedAccountIdentifierForType:(NSString *)accountTypeIdentifier {
    NSParameterAssert(accountTypeIdentifier);
    return self.lastUsedAccountIDsByAccountType[accountTypeIdentifier];
}

- (void)setLastUsedAccountIdentifier:(NSString *)identifier forType:(NSString *)accountTypeIdentifier {
    NSParameterAssert(identifier);
    NSParameterAssert(accountTypeIdentifier);
    [self.lastUsedAccountIDsByAccountType setObject:identifier forKey:accountTypeIdentifier];
    [[OSKFileManager sharedInstance] saveObject:self.lastUsedAccountIDsByAccountType
                                         forKey:OSKSystemAccountStoreSavedActiveAccountIDsKey
                                     completion:nil
                                completionQueue:nil];
    if ([self.delegate respondsToSelector:@selector(systemAccountStore:didSetLastUsedAccount:forType:)])
    {
        ACAccount *account = [self accountWithIdentifier:identifier forType:accountTypeIdentifier];
        [self.delegate systemAccountStore:self didSetLastUsedAccount:account forType:accountTypeIdentifier];
    }
}

- (void)_loadSavedActiveAccountIDs {
    NSDictionary *savedDictionary = (NSDictionary *)[[OSKFileManager sharedInstance] loadSavedObjectForKey:OSKSystemAccountStoreSavedActiveAccountIDsKey];
    _lastUsedAccountIDsByAccountType = [[NSMutableDictionary alloc] init];
    if (savedDictionary) {
        [_lastUsedAccountIDsByAccountType addEntriesFromDictionary:savedDictionary];
    }
}

- (ACAccount *)_findAccountWithIdentifier:(NSString *)identifier inArray:(NSArray *)existingAccounts
{
    ACAccount *account = nil;
    if (identifier) {
        for (ACAccount *anAccount in existingAccounts) {
            if ([anAccount.identifier isEqualToString:identifier]) {
                account = anAccount;
                break;
            }
        }
    }
    return account;
}

- (ACAccount *)accountWithIdentifier:(NSString *)identifier forType:(NSString *)accountTypeIdentifier
{
    NSArray *existingAccounts = [self accountsForAccountTypeIdentifier:accountTypeIdentifier];
    
    ACAccount *account = [self _findAccountWithIdentifier:identifier inArray:existingAccounts];
    if (account == nil) {
        account = [existingAccounts firstObject];
    }
    
    return account;
}

- (ACAccount *)lastUsedAccountForType:(NSString *)accountTypeIdentifier {
    NSParameterAssert(accountTypeIdentifier);
    NSString *lastUsedAccountID = [self lastUsedAccountIdentifierForType:accountTypeIdentifier];    
    return [self accountWithIdentifier:lastUsedAccountID forType:accountTypeIdentifier];
}

- (BOOL)isLastUsedAccountValidForType:(NSString *)accountTypeIdentifier {
    NSArray *existingAccounts = [self accountsForAccountTypeIdentifier:accountTypeIdentifier];
    NSString *lastUsedAccountID = [self lastUsedAccountIdentifierForType:accountTypeIdentifier];
    ACAccount *account = [self _findAccountWithIdentifier:lastUsedAccountID inArray:existingAccounts];
    
    return (account != nil);

}

@end






