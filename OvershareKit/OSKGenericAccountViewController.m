//
//  OSKGenericAccountViewController.m
//  Pods
//
//  Created by Sam Hare on 31/07/2014.
//
//

#import "OSKGenericAccountViewController.h"

#import "OSKPresentationManager.h"

@interface OSKGenericAccountViewController ()

@end

@implementation OSKGenericAccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [[self.activity class] activityName];
    OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
    UIColor *bgColor = [presentationManager color_groupedTableViewBackground];
    self.view.backgroundColor = bgColor;
    self.tableView.backgroundColor = bgColor;
    self.tableView.backgroundView.backgroundColor = bgColor;
    self.tableView.separatorColor = presentationManager.color_separators;
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
        UIColor *bgColor = [presentationManager color_groupedTableViewCells];
        cell.backgroundColor = bgColor;
        cell.backgroundView.backgroundColor = bgColor;
        cell.textLabel.textColor = [presentationManager color_action];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = presentationManager.color_cancelButtonColor_BackgroundHighlighted;
        cell.tintColor = presentationManager.color_action;
        UIFontDescriptor *descriptor = [[OSKPresentationManager sharedInstance] normalFontDescriptor];
        if (descriptor)
        {
            [cell.textLabel setFont:[UIFont fontWithDescriptor:descriptor size:17]];
        }
    }
    
    NSString *title = nil;
    if ([self.activity isAuthenticated])
    {
        if ([self.activity respondsToSelector:@selector(deauthenticate:)])
        {
            title = [[OSKPresentationManager sharedInstance] localizedText_SignOut];
        }
        else
        {
            title = @"Connected";
        }
    } 
    else
    {
        title = [[OSKPresentationManager sharedInstance] localizedText_SignIn];
    }
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.activity isAuthenticated])
    {
        if ([self.activity respondsToSelector:@selector(deauthenticate:)])
        {
            [self.activity deauthenticate:^(BOOL successful, NSError *error) {
                [tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
    else
    {
        [self.activity authenticate:^(BOOL successful, BOOL fromCache, NSError *error) {
            [tableView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end
