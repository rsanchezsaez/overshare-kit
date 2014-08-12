//
//  OSKGenericAccountViewController.h
//  Pods
//
//  Created by Sam Hare on 31/07/2014.
//
//

#import <UIKit/UIKit.h>

#import "OSKActivity.h"
#import "OSKActivity_GenericAuthentication.h"

@interface OSKGenericAccountViewController : UITableViewController

@property (strong, nonatomic) OSKActivity <OSKActivity_GenericAuthentication> *activity;

@end
