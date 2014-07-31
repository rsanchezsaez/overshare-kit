//
//  OSKSinaWeiboActivity.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Accounts;

#import "OSKSinaWeiboActivity.h"

#import "OSKSinaWeiboUtility.h"
#import "OSKMicrobloggingActivity.h"
#import "OSKShareableContentItem.h"
#import "OSKSystemAccountStore.h"
#import "OSKActivity_SystemAccounts.h"
#import "OSKTwitterText.h"
#import "NSString+OSKEmoji.h"

static NSInteger OSKSinaWeiboActivity_MaxCharacterCount = 140;
static NSInteger OSKSinaWeiboActivity_MaxUsernameLength = 20;
static NSInteger OSKSinaWeiboActivity_MaxImageCount = 1;

@interface OSKSinaWeiboActivity ()

@property (copy, nonatomic) NSNumber *estimatedShortURLLength_http;
@property (copy, nonatomic) NSNumber *estimatedShortURLLength_https;

@end

@implementation OSKSinaWeiboActivity

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
    return ACAccountTypeIdentifierSinaWeibo;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+ (BOOL)isAvailable {
    return YES; // This is *in general*, not whether account access has been granted.
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_SinaWeibo;
}

+ (NSString *)activityName {
    return @"Sina Weibo";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-sinaWeiboIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-sinaWeiboIcon-76.png"];
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
    return NO;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_ViewController_Microblogging;
}

- (BOOL)isReadyToPerform {
    BOOL isReadyToPerform = [super isReadyToPerform];


    BOOL accountPresent = (self.activeSystemAccount != nil);
    BOOL textIsValid = (0 <= self.remainingCharacterCount && self.remainingCharacterCount < [self maximumCharacterCount]);
    
    return (isReadyToPerform && accountPresent && textIsValid);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKSinaWeiboActivity *weakSelf = self;
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (completion) {
            completion(weakSelf, NO, nil);
        }
    }];
    [OSKSinaWeiboUtility
     postContentItem:(OSKMicroblogPostContentItem *)self.contentItem
     toSystemAccount:self.activeSystemAccount
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
    return OSKSinaWeiboActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKSinaWeiboActivity_MaxImageCount;
}

- (NSInteger)maximumUsernameLength {
    return OSKSinaWeiboActivity_MaxUsernameLength;
}

- (NSInteger)updateRemainingCharacterCount:(OSKMicroblogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities {
    
    NSString *text = contentItem.text;
    
    NSInteger composedLength = [text osk_lengthAdjustingForComposedCharacters];
    NSInteger extraURLLength = [contentItem.textURL osk_lengthAdjustingForComposedCharacters] + 1;
    NSInteger estimatedLength = composedLength + extraURLLength;
    NSInteger remainingCharacterCount = [self maximumCharacterCount] - estimatedLength;
    
    [self setRemainingCharacterCount:remainingCharacterCount];
    
    return remainingCharacterCount;
}

- (OSKSyntaxHighlighting)syntaxHighlighting {
    return OSKSyntaxHighlighting_Usernames | OSKSyntaxHighlighting_Links | OSKSyntaxHighlighting_Hashtags;
}

- (BOOL)allowLinkShortening {
    return NO;
}

@end




