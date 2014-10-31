//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Prabhjeet Singh on 10/28/14.
//  Copyright (c) 2014 PJ. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCFLoatingToolbar.h"

#define kBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh command")

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCFLoatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) BLCFLoatingToolbar *toolbar;

@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome", @"Welcome title") message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") otherButtonTitles:nil];
    
    [alert show];
}

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    [self buildURLField];
    
    self.toolbar = [[BLCFLoatingToolbar alloc] initWithFourTitles:@[kBrowserBackString, kBrowserForwardString, kBrowserStopString, kBrowserRefreshString]];
    self.toolbar.delegate = self;
    
    
    [mainView addSubview:self.webView];
    [mainView addSubview:self.textField];

    [mainView addSubview:self.toolbar];
    
    self.view = mainView;
}

//configure url text field
- (void)buildURLField {
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Enter Website URL or Search Keywords", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
}


- (void)updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.toolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kBrowserBackString];
    [self.toolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kBrowserForwardString];
    [self.toolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBrowserStopString];
    [self.toolbar setEnabled:self.webView.request.URL && self.frameCount == 0 forButtonWithTitle:kBrowserRefreshString];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *urlString = textField.text;
    
    //Check if the url contains a space
    NSRange range = [urlString rangeOfString:@" "];
    
    //If so, create a new URL string that will search google with the keywords entered
    if( range.location != NSNotFound) {
        NSArray *keywords = [urlString componentsSeparatedByString:@" "];
        NSMutableString *searchString = [NSMutableString stringWithString:@"google.com/search?q="];
        for (int i=0; i<keywords.count; i++) {
            [searchString appendString:keywords[i]];
            if ((i+1) != keywords.count) {
                [searchString appendString:@"+"];
            }
        }
        urlString = searchString;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (!url.scheme) {
        // The user didn't type http: or https:
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
    }
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (error.code != 999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alert show];
    }
    [self updateButtonsAndTitle];
    self.frameCount--;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width =CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.toolbar.frame = CGRectMake(20, 100, 280, 60);
}

- (void)resetWebView {
    [self.webView removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    
    [self updateButtonsAndTitle];
}

- (void) floatingToolbar:(BLCFLoatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqual:kBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqual:kBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqual:kBrowserRefreshString]) {
        [self.webView reload];
    }
}

@end
