//
//  PSSettingsViewController.m
//  pinkelstar
//
//  Created by Alexander van Elsas on 9/23/10.
//  Copyright 2010 PinkelStar. All rights reserved.
//

#import "PSSettingsViewController.h"
#import "PSPermissionView.h"
#import "PSPinkelStarServer.h"

static CGFloat permissionViewOffsetX = 20.0;
static CGFloat permissionViewOffsetY = 26.0;
// the social network icons
static CGFloat prefIconWidth = 34.0;
static CGFloat prefIconHeight = 34.0;

@implementation PSSettingsViewController

@synthesize delegate = _delegate;
@synthesize _prefTableView;
@synthesize _prefBackgroundView;

#pragma mark -
#pragma mark View lifecycle

// start a dialogue to obtain permission to publish to a specific social network
- (void) getPermissionPS:(NSString *) networkName
{
	PSPermissionView *permView = [[[PSPermissionView alloc] initWithDelegate:self] autorelease];
	permView.frame = CGRectMake(permissionViewOffsetX, permissionViewOffsetX+permissionViewOffsetY, self.view.frame.size.width - 2*permissionViewOffsetX, self.view.frame.size.height - (2*permissionViewOffsetX + permissionViewOffsetY));
	permView.networkName = networkName;
	permView.sessionKey = [PSPinkelStarServer sharedInstance].psSessionKey;
	[permView show];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// iPhone 4 retina display utility functions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL) currentDeviceIsRetinaDisplay
{
	if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) 
		return YES;
	else
		return NO;
}

// Temp method needed because Apple hasn't fixed all image functions yet to laod highres images for iPhone 4 when needed
// Didn't implement this as a category on purpose as that provides too many compatibility issues wit devices
// We accept the minor code duplication for now
-(UIImage *) getImage:(NSString *) imageName ofType:(NSString *) ofType
{
	
	// iPhone 4 trick, we can remove this as soon as Apple fixes imageWithContentsOfFile to load
	// Highres @2x images automatically
	// iPhone 4	
	if ([self currentDeviceIsRetinaDisplay]) 
    {
	    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@", imageName, ofType]];
    }
    else 
    {
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:ofType];
		return [UIImage imageWithContentsOfFile:imagePath];		
    }
	
}

// Whenever we load an image form a server we detect first if we are on a retina display. If so we get a highres image
// This methid prevents iOS to scale that image 2x (no need as it is high res already)
-(UIImage *) adjustImageScaleForRetinaDisplay:(UIImage *) someImage width:(CGFloat)width height:(CGFloat) height
{ 
	CGRect frame = CGRectMake(0, 0, width, height); 
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0); // prevent iOS from scaling this again
	[someImage drawInRect:frame]; 
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext(); 
	UIGraphicsEndImageContext();
	
	return newImage; 
}

// Clearing all cookies will ensure that when a user revokes a permission
// he will need to log in again first the next time he wishes to publish 
// to that social network again
-(void) clearCookies:networkName
{
	NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		if([[cookie domain] isEqual:[NSString stringWithFormat:@".%@.com", networkName]])
		{
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		}
	}
}


-(UILabel *) createiPadHeaderTable
{
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 540, 20)] autorelease];
	headerLabel.text = NSLocalizedString(@"Enable/disable social networks", @"Enable/disable social networks");
	headerLabel.textColor = [UIColor whiteColor];	
	headerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(16)];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.shadowColor = [UIColor darkTextColor];
	headerLabel.shadowOffset = CGSizeMake(0, -1);
	
	return headerLabel;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 540, 40)] autorelease];
	UILabel *headerLabel = [self createiPadHeaderTable];
	[containerView addSubview:headerLabel];
	
	_prefTableView.tableHeaderView = containerView;
	_prefTableView.backgroundColor = [UIColor clearColor];
	_prefTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_prefBackgroundView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
 
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		CGRect titleRect = CGRectMake(0, 0, 300, 40);
		UILabel *tableTitle = [[UILabel alloc] initWithFrame:titleRect];
		tableTitle.textColor = [UIColor whiteColor];
		tableTitle.backgroundColor = [_prefTableView backgroundColor];
		tableTitle.opaque = YES;
		tableTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:(12.0)];
		headerLabel.shadowColor = [UIColor darkTextColor];
		headerLabel.shadowOffset = CGSizeMake(0, -1);
		tableTitle.text = NSLocalizedString(@"Enable/disable social networks", @"Enable/disable social networks");
		_prefTableView.tableHeaderView = tableTitle;
		[tableTitle release];
	}
	[_prefTableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Edit view rotation methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES; // supports all orientations
    }
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
		return YES;
	
    return NO;
}



#pragma mark -
#pragma mark Table view data source

// The user altered the social network pref switch
-(IBAction) socialNetworkSwitchChanged:(id)sender
{
	UISwitch *socialNetworkSwitch = (UISwitch *) sender;
	BOOL setting = socialNetworkSwitch.isOn;
	
	// if the switch was On ad it is turned off, we need to call
	// revokePermission
	
	// If the switch was off and it is turned on, we need to
	// call our webView to get the permission
	
	// first, locate the switch an figure out what network it belongs to
	NSString *networkName = [[[PSPinkelStarServer sharedInstance] getSupportedSocialNetworks] objectAtIndex:socialNetworkSwitch.tag];
	
	if(setting)
	{
		if(![[PSPinkelStarServer sharedInstance] canPublishPS:networkName])
			// open a modal view to get the permission
			[self getPermissionPS:networkName];
		else
			// This is odd
			DebugLog(@"socialNetworkSwitchChanged: switch is set to ON, but we already have permission according to the PinkelStar server??");
	}
	else 
	{
		// if it is turned off, we will call revoke now forcing the user to provide permission later if he wants
		// to publish to this network again
		
		// And now tell the server to revoke the permission on behalf of the user
		[[PSPinkelStarServer sharedInstance] revokePermissionPS:networkName];
		
		// as a final measure, we clear the network cookies to ensure the user
		// really needs to log in again next time he wants to publish to the social network
		[self clearCookies:networkName];
		
		// tell the MainViewController about this change in permission
		// This will allow the main interface to update correctly too
		if ([_delegate respondsToSelector:@selector(psPermissionRevoked:)]) {
			[_delegate psPermissionRevoked:self];
		}
		else {
			DebugLog(@"socialNetworkSwitchChanged: delegate doesn't respond to psPermissionRevoked");
		}

	}
	
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[PSPinkelStarServer sharedInstance] numberOfSupportedSocialNetworks];
}

// As soon as the icon has been loaded from the PinkelStar server we call this
// to replace the placeholder icon with the correct social network icon
-(void) updateSocialNetworkPrefIcon:(NSInteger) networkIndex
{
	NSString *networkName = [[[PSPinkelStarServer sharedInstance] getSupportedSocialNetworks] objectAtIndex:networkIndex];
	UIImage *prefIcon;
	
	// update this icon in the prefs view now
	if(networkIndex != NSNotFound)
	{
		prefIcon = [[PSPinkelStarServer sharedInstance] getSocialNetworkIconPS:networkName size:PSSocialNetworkIconSmall];
		if(prefIcon)
		{
			if ([self currentDeviceIsRetinaDisplay])
			{
				// we need to adjust the image, as iOS will try to scale it to 2.0
				[[_socialNetworkPrefIcons objectForKey:networkName] 
				 setImage:[self adjustImageScaleForRetinaDisplay:prefIcon width:prefIconWidth height:prefIconHeight]];		
				
			}
			else
			{
				[[_socialNetworkPrefIcons objectForKey:networkName] setImage:prefIcon];
			}
			
		}
		else {
			DebugLog(@"updateSocialNetworkPrefIcon: nothing to update");
		}
	}
	else 
		DebugLog(@"updateSocialNetworkPrefIcon: Unknown icon for network name = %@", networkName);
	
}

-(UIImage *) getSocialNetworkIcon:(NSInteger) i
{
	NSString *networkName = [[[PSPinkelStarServer sharedInstance] getSupportedSocialNetworks] objectAtIndex:i];
	UIImage *prefIcon =  [[PSPinkelStarServer sharedInstance] getSocialNetworkIconPS:networkName size:PSSocialNetworkIconSmall];
		
	// if it doesn't exist yet it will be updated from the server soon
	if(!prefIcon)
	{
		prefIcon = [self getImage:@"pref_placeholder_icon_small" ofType:@"png"];
	}
	// store it for easy access later
	if(!_socialNetworkPrefIcons)
		_socialNetworkPrefIcons = [[NSMutableDictionary alloc] init];
	
	if ([self currentDeviceIsRetinaDisplay])
	{
		UIImage *retinaImage = [self adjustImageScaleForRetinaDisplay:prefIcon width:prefIconWidth height:prefIconHeight];
		[_socialNetworkPrefIcons setObject:retinaImage forKey:networkName];
		return retinaImage;
	}
	else
	{
		[_socialNetworkPrefIcons setObject:prefIcon forKey:networkName];
		
		return prefIcon;
	}
}

-(NSString *) getSocialNetworkLabelText:(NSInteger) i
{
	return [[[PSPinkelStarServer sharedInstance] getSupportedSocialNetworks] objectAtIndex:i];
}

-(void) toggleSocialNetworkPrefSwitch:(NSString *) networkName
{
	// Locate the switch and toggle its value. We don't care what it was before
	// all we know is it was changed
	UISwitch *prefSwitch = [_socialNetworkSwitches objectForKey:networkName];
	BOOL onOrOff = prefSwitch.isOn;
	[prefSwitch setOn:!onOrOff animated:NO];	
}



-(UISwitch *) getSocialNetworkSwitch:(NSInteger)switchIndex
{
	UISwitch *prefSwitch;
	NSString *networkName;

	networkName = [[[PSPinkelStarServer sharedInstance] getSupportedSocialNetworks] objectAtIndex:switchIndex];

	prefSwitch = [[[UISwitch alloc] init] autorelease];
	[prefSwitch addTarget: self action: @selector(socialNetworkSwitchChanged:) forControlEvents:UIControlEventValueChanged];

	// this will help us remember what switch was touched later
	[prefSwitch setTag:switchIndex];
	// store it for easy access later
	if(!_socialNetworkSwitches)
		_socialNetworkSwitches = [[NSMutableDictionary alloc] init];
	[_socialNetworkSwitches setObject:prefSwitch forKey:networkName];

	if([[PSPinkelStarServer sharedInstance] canPublishPS:networkName])
	{
		// We can publish to this network, so set slider to true
		[prefSwitch setOn:YES animated:NO];			
	}
	else 
	{
		// we can't publish to this network so set it to false
		[prefSwitch setOn:NO animated:NO];			
	}

	return prefSwitch;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	// the background
	NSInteger row = [indexPath row];
	NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
	
	UIImage *backgroundImage;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// the top row has rounded corners
		if(row == 0)
		{
			backgroundImage = [self getImage:@"pref_table_toprow_bg_iPad" ofType:@"png"];
		}
		else if(row == sectionRows -1)
		{
			backgroundImage = [self getImage:@"pref_table_bottomrow_bg_iPad" ofType:@"png"];
		}
		// the bottom row has rounded corners
		else
		{
			backgroundImage = [self getImage:@"pref_table_row_bg_iPad" ofType:@"png"];
		}
	}
	else
	{
		if(row == 0)
		{
			backgroundImage = [self getImage:@"pref_table_toprow_bg" ofType:@"png"];
		}
		else if(row == sectionRows - 1)
		{
			backgroundImage = [self getImage:@"pref_table_bottomrow_bg" ofType:@"png"];
		}
		else
		{
			backgroundImage = [self getImage:@"pref_table_row_bg" ofType:@"png"];
		}
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];

	// The icon
	cell.imageView.image = [self getSocialNetworkIcon:row];
	cell.imageView.contentMode = UIViewContentModeCenter;
	
	cell.textLabel.text = [self getSocialNetworkLabelText:row];
	cell.textLabel.shadowColor = [UIColor darkTextColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, -1);
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor whiteColor];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(18.0)];
	else 
		cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(12.0)];
		
	cell.textLabel.frame = CGRectMake(0, 0, 100, 20);

	// the switch
	cell.accessoryView = [self getSocialNetworkSwitch:row];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	// we do nothing, selection of rows is not needed
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
}


- (void)dealloc {
	if(_socialNetworkSwitches)
		[_socialNetworkSwitches release];
	if(_socialNetworkPrefIcons)
		[_socialNetworkPrefIcons release];		
	[_prefTableView release];
	[_prefBackgroundView release];
	
    [super dealloc];
}

-(void)viewWillDisappear:(BOOL)animated
{
	if ([_delegate respondsToSelector:@selector(psSettingsFinished:)]) {
		[_delegate psSettingsFinished:self];
	}
	else {
		DebugLog(@"viewWillDisappear: delegate doesn't respond to psSettingsFinished");
	}
}

// PSPermissionViewDelegate
// Called when the dialog succeeds and is about to be dismissed.
- (void)psPermissionViewDialogDidSucceed:(PSPermissionView *)pView
{
	[[PSPinkelStarServer sharedInstance] storePermissionPS:pView.networkName];
	
	// tel the main view contorller about the new permission
	if ([_delegate respondsToSelector:@selector(psPermissionAdded:)]) {
		[_delegate psPermissionAdded:self];
	}
	else {
		DebugLog(@"psPermissionViewDialogDidSucceed: delegate doesn't respond to psPermissionAdded");
	}
}

// Called when the dialog is cancelled and is about to be dismissed.
- (void)psPermissionViewDialogDidCancel:(PSPermissionView *)pView
{
	// toggle the switch back to its original position
	[self toggleSocialNetworkPrefSwitch:pView.networkName];
}

// Called when permission dialog failed to load due to an error.
- (void)dialog:(PSPermissionView *)dialog didFailWithError:(NSError*)error
{

}

@end

