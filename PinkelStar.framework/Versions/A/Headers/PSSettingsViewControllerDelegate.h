//
//  PSSettingsViewControllerDelegate.h
//  pinkelstar
//
//  Created by Alexander van Elsas on 9/24/10.
//  Copyright 2010 PinkelStar. All rights reserved.
//


#import <Foundation/Foundation.h>

@class PSSettingsViewController;

@protocol PSSettingsViewControllerDelegate <NSObject>

@optional

// Called when the user has revoked a permission
- (void)psPermissionRevoked:(PSSettingsViewController *)vController;

// Called when the user has added a permission
- (void)psPermissionAdded:(PSSettingsViewController *)vController;

// Called when the user presses the done button
- (void)psSettingsFinished:(PSSettingsViewController *)vController;


@end
