//
//  BLCWebBrowserViewController.h
//  BlocBrowser
//
//  Created by Prabhjeet Singh on 10/28/14.
//  Copyright (c) 2014 PJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCFLoatingToolbar.h"

@interface BLCWebBrowserViewController : UIViewController

- (void) floatingToolbar:(BLCFLoatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

- (void)resetWebView;

@end
