//
//  OSKTumblrActivity.m
//  Overshare
//
//
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKTumblrActivity.h"
#import "OSKBloggingActivity.h"

#import "OSKActivitiesManager.h"
#import "OSKActivity_ManagedAccounts.h"
#import "OSKTumblrUtility.h"
#import "OSKLogger.h"
#import "OSKManagedAccount.h"
#import "OSKShareableContentItem.h"
#import "NSString+OSKEmoji.h"

static NSInteger OSKTumblrActivity_MaxCharacterCount = 6000;
static NSInteger OSKTumblrActivity_MaxUsernameLength = 20;
static NSInteger OSKTumblrActivity_MaxImageCount = 0;

@interface OSKTumblrActivity ()

@property (copy, nonatomic) OSKManagedAccountAuthenticationHandler completionHandler;

@end

@implementation OSKTumblrActivity

@synthesize activeManagedAccount = _activeManagedAccount;
@synthesize remainingCharacterCount = _remainingCharacterCount;

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
    }
    return self;
}

#pragma mark - System Account Methods

+ (OSKManagedAccountAuthenticationViewControllerType)authenticationViewControllerType {
    return OSKManagedAccountAuthenticationViewControllerType_OneOfAKindCustomBespokeViewController;
}

- (OSKUsernameNomenclature)usernameNomenclatureForSignInScreen {
    return OSKUsernameNomenclature_Email;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_BlogPost;
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSString *)activityType {
    return OSKActivityType_API_Tumblr;
}

+ (NSString *)activityName {
    return @"Tumblr";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-tumblrIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-tumblrIcon-76.png"];
    }
    return image;
}

+ (UIImage *)settingsIcon {
    return [UIImage imageNamed:@"osk-tumblrIcon-29.png"];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_ManagedAccounts;
}

+ (BOOL)requiresApplicationCredential {
    return YES;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_ViewController_Microblogging;
}

- (BOOL)allowLinkShortening {
    return NO;
}

- (BOOL)isReadyToPerform {
    BOOL isReadyToPerform = [super isReadyToPerform];

    BOOL appCredentialPresent = ([self.class applicationCredential] != nil);
    BOOL credentialPresent = (self.activeManagedAccount.credential != nil);
    BOOL accountPresent = (self.activeManagedAccount != nil);
    
    NSInteger maxCharacterCount = [self maximumCharacterCount];
    BOOL textIsValid = (0 <= self.remainingCharacterCount && self.remainingCharacterCount < maxCharacterCount);
    
    return (isReadyToPerform && appCredentialPresent && credentialPresent && accountPresent && textIsValid);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if (completion) {
                completion(self, NO, nil);
            }
        }];
        [OSKTumblrUtility postContentItem:(OSKBlogPostContentItem *)self.contentItem
                           withCredential:self.activeManagedAccount.credential
                            appCredential:[self.class applicationCredential]
                               completion:^(BOOL success, NSError *error) {
                                   if (success) {
                                       OSKLog(@"Success! Sent new post to Tumblr.");
                                   }
                                   if (completion) {
                                       completion(self, success, error);
                                   }
                                   [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
                               }];
    });
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return OSKTumblrActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKTumblrActivity_MaxImageCount;
}

- (OSKSyntaxHighlighting)syntaxHighlighting {
    return OSKSyntaxHighlighting_Hashtags | OSKSyntaxHighlighting_Links | OSKSyntaxHighlighting_Usernames;
}

- (NSInteger)maximumUsernameLength {
    return OSKTumblrActivity_MaxUsernameLength;
}

- (NSInteger)updateRemainingCharacterCount:(OSKMicroblogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities {
    
    NSString *text = contentItem.text;
    NSInteger composedLength = [text osk_lengthAdjustingForComposedCharacters];
    NSInteger remainingCharacterCount = [self maximumCharacterCount] - composedLength;
    
    [self setRemainingCharacterCount:remainingCharacterCount];
    
    return remainingCharacterCount;
}

@end
