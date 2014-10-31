//
//  BLCFLoatingToolbar.h
//  BlocBrowser
//
//  Created by Prabhjeet Singh on 10/29/14.
//  Copyright (c) 2014 PJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCFLoatingToolbar;

@protocol BLCFLoatingToolbarDelegate <NSObject>

@optional

- (void)floatingToolbar:(BLCFLoatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

@end

@interface BLCFLoatingToolbar : UIView

- (instancetype)initWithFourTitles:(NSArray *)titles;

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <BLCFLoatingToolbarDelegate> delegate;

@end
