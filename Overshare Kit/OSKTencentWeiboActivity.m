//
//  OSKTencentWeiboActivity.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Accounts;

#import "OSKTencentWeiboActivity.h"

#import "OSKTencentWeiboUtility.h"
#import "OSKMicrobloggingActivity.h"
#import "OSKShareableContentItem.h"
#import "OSKSystemAccountStore.h"
#import "OSKActivity_SystemAccounts.h"
#import "OSKTwitterText.h"
#import "NSString+OSKEmoji.h"

static NSInteger OSKTencentWeiboActivity_MaxCharacterCount = 140;
static NSInteger OSKTencentWeiboActivity_MaxUsernameLength = 20;
static NSInteger OSKTencentWeiboActivity_MaxImageCount = 1;
static NSInteger OSKTencentWeiboActivity_FallbackShortURLEstimate = 24;

@interface OSKTencentWeiboActivity ()

@property (copy, nonatomic) NSNumber *estimatedShortURLLength_http;
@property (copy, nonatomic) NSNumber *estimatedShortURLLength_https;

@end

@implementation OSKTencentWeiboActivity

@synthesize activeSystemAccount = _activeSystemAccount;
@synthesize remainingCharacterCount = _remainingCharacterCount;

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
        //
    }
    return self;
}

#pragma mark - System Accounts

+ (NSString *)systemAccountTypeIdentifier {
    return ACAccountTypeIdentifierTencentWeibo;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+ (BOOL)isAvailable {
    return YES; // This is *in general*, not whether account access has been granted.
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_TencentWeibo;
}

+ (NSString *)activityName {
    return @"Tencent Weibo";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-twitterIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-twitterIcon-76.png"];
    }
    return image;
}

+ (UIImage *)settingsIcon {
    return [self iconForIdiom:UIUserInterfaceIdiomPhone];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_SystemAccounts;
}

+ (BOOL)requiresApplicationCredential {
    return YES;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_ViewController_Microblogging;
}

- (BOOL)isReadyToPerform {
    BOOL appCredentialPresent = ([self.class applicationCredential] != nil);
    BOOL accountPresent = (self.activeSystemAccount != nil);
    BOOL textIsValid = (0 <= self.remainingCharacterCount && self.remainingCharacterCount < [self maximumCharacterCount]);
    
    return (appCredentialPresent && accountPresent && textIsValid);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKTencentWeiboActivity *weakSelf = self;
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (completion) {
            completion(weakSelf, NO, nil);
        }
    }];
    [OSKTencentWeiboUtility
     postContentItem:(OSKMicroblogPostContentItem *)self.contentItem
     toSystemAccount:self.activeSystemAccount
     appCredential:[self.class applicationCredential]
     completion:^(BOOL success, NSError *error) {
         if (completion) {
             completion(weakSelf, (error == nil), error);
         }
         [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
     }];
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return OSKTencentWeiboActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKTencentWeiboActivity_MaxImageCount;
}

- (NSInteger)maximumUsernameLength {
    return OSKTencentWeiboActivity_MaxUsernameLength;
}

- (NSInteger)updateRemainingCharacterCount:(OSKMicroblogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities {
    
    NSString *text = contentItem.text;
    
    NSInteger composedLength = [text osk_lengthAdjustingForComposedCharacters];
    NSInteger remainingCharacterCount = [self maximumCharacterCount] - composedLength;
    
    [self setRemainingCharacterCount:remainingCharacterCount];
    
    return remainingCharacterCount;
}

- (OSKSyntaxHighlighting)syntaxHighlighting {
    return OSKSyntaxHighlighting_Usernames | OSKSyntaxHighlighting_Links | OSKSyntaxHighlighting_Hashtags;
}

- (BOOL)allowLinkShortening {
    return NO;
}

#pragma mark - Updating Estimated Short URL Lengths

- (NSNumber *)estimatedShortURLLength_http {
    
    return @(OSKTencentWeiboActivity_FallbackShortURLEstimate);
}

- (NSNumber *)estimatedShortURLLength_https {
    
    return @(OSKTencentWeiboActivity_FallbackShortURLEstimate);
}

@end




