//
//  PSSettingsViewController.h
//  pinkelstar
//
//  Created by Alexander van Elsas on 9/23/10.
//  Copyright 2010 PinkelStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPermissionViewDelegate.h";
#import "PSSettingsViewControllerDelegate.h";

// iPhone

@interface PSSettingsViewController : UIViewController
<PSPermissionViewDelegate> {

	id<PSSettingsViewControllerDelegate> _delegate;
	
	UITableView *_prefTableView;
	UIImageView *_prefBackgroundView;
	
	// Obtained from the server
	NSMutableDictionary *_socialNetworkPrefIcons;
	
	// a list of UISwitch objects
	NSMutableDictionary *_socialNetworkSwitches;
	
}

// preferences design
@property (nonatomic, retain) id<PSSettingsViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *_prefTableView;
@property (nonatomic, retain) IBOutlet UIImageView *_prefBackgroundView;

@end
