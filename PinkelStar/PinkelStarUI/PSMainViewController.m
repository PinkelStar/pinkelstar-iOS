/*
 Copyright (c) 2010 PinkelStar, MillMobile BV
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Except as contained in this notice, the name(s) and/or trademarks of the 
 above copyright holders shall not be used in advertising or otherwise to 
 promote the sale, use or other dealings in this Software without prior 
 written authorization. 
 
 */

//
//  PSMainViewController.m
//  pinkelstar
//
//  Created by Alexander van Elsas on 6/17/10.

#import "PSMainViewController.h"
#import "PSPinkelStarServer.h"
#import "PSSocialNetworks.h"
#import "PSPermissionView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGImage.h>

// Prefs view
static CGFloat prefRowWidth = 302.0;
static CGFloat prefRowHeight = 45.0;
static CGPoint prefRowOrigin = {0.0, 0.0};
// the social network icons
static CGFloat prefIconWidth = 34.0;
static CGFloat prefIconHeight = 34.0;
static CGPoint prefIconOrigin = {10.0, 0.0};
// the social network label
static CGFloat prefLabelWidth = 200.0;
static CGFloat prefLabelHeight = 20.0;
static CGPoint prefLabelOrigin = {50.0, 0.0};
// the social network Switch
static CGFloat prefSwitchHeight = 27.0;
static CGPoint prefSwitchOrigin = {200.0, 0.0};

// iPad
static CGFloat prefRowWidth_iPad = 488.0;
static CGFloat prefRowHeight_iPad = 65.0;
static CGPoint prefRowOrigin_iPad = {30.0, 0.0};
// the social network icons
static CGFloat prefIconWidth_iPad = 65.0;
static CGFloat prefIconHeight_iPad = 48.0;
static CGPoint prefIconOrigin_iPad = {46.0, 10.0};
// the social network label
static CGFloat prefLabelWidth_iPad = 250.0;
static CGFloat prefLabelHeight_iPad = 12.0;
static CGPoint prefLabelOrigin_iPad = {115.0, 0.0};
// the social network Switch
static CGFloat prefSwitchWidth_iPad = 94.0;
static CGFloat prefSwitchHeight_iPad = 27.0;
static CGPoint prefSwitchOrigin_iPad = {400.0, 0.0};

// Main view
// The buttons
// iPhone
static CGFloat buttonWidth = 87.0;
static CGFloat buttonHeight = 93.0;
static CGFloat buttonIconWidth = 61.0;
static CGFloat buttonIconHeight = 46.0;
static CGPoint buttonOrigin = {18.0, 10.0};
static CGFloat buttonSpaceX = 13.0;
static CGFloat buttonSpaceY = 13.0;

// iPad
static CGFloat buttonWidth_iPad = 114.0;
static CGFloat buttonHeight_iPad = 122.0;
//static CGFloat buttonIconWidth_iPad = 80.0;
//static CGFloat buttonIconHeight_iPad = 60.0;
static CGPoint buttonOrigin_iPad = {66.0,0.0};
static CGFloat buttonSpaceX_iPad = 34.0;
static CGFloat buttonSpaceY_iPad = 34.0;


static CGFloat permissionViewOffsetX = 20.0;
static CGFloat permissionViewOffsetY = 26.0;


@implementation PSMainViewController

@synthesize delegate = _delegate;
@synthesize userMessage;
@synthesize _customShareMessageLabel;
@synthesize _customShareMessageText;
@synthesize _appIconView;
@synthesize eventType = _eventType;
@synthesize psServer;
@synthesize supportedNetworks;
@synthesize permissionView;
@synthesize _buttonScrollView;
@synthesize _cancelButton;
@synthesize _publishButton;
@synthesize _publishButtonShine;
@synthesize _prefButton;
@synthesize _prefView;
@synthesize _donePrefButton;
@synthesize _prefScrollView;
@synthesize socialNetworkButtons = _socialNetworkButtons;
@synthesize contentURL = _contentURL;

// start a dialogue to obtain permission to publish to a specific social network
// Is called in both the preferences view and the main view
- (void) getPermissionPS:(NSString *) networkName
{
	PSPermissionView *permView = [[[PSPermissionView alloc] initWithDelegate:self] autorelease];
	permView.frame = CGRectMake(permissionViewOffsetX, permissionViewOffsetX+permissionViewOffsetY, self.view.frame.size.width - 2*permissionViewOffsetX, self.view.frame.size.height - (2*permissionViewOffsetX + permissionViewOffsetY));
	permView.networkName = networkName;
	permView.sessionKey = psServer.psSessionKey;
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
	CGRect frame = CGRectMake(0, 0, width, height); // we really need 122x92 for high resh
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0); // prevent iOS from scaling this again
	[someImage drawInRect:frame]; 
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext(); 
	UIGraphicsEndImageContext();
	
	return newImage; 
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Preferences view methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void) showPreferencesView
{
	// The preferences view consists of a view, with content
	// and a done button
	//[self.view bringSubviewToFront:_prefView];
	//[_prefView setNeedsDisplay];
	_prefView.hidden = NO;
	_donePrefButton.hidden = NO;
	_prefScrollView.hidden = NO;
	_prefButton.hidden = YES;
	
}

-(void) hidePreferencesView
{
	// The preferences view consists of a view, with content
	// and a done button
	_prefView.hidden = YES;
	_donePrefButton.hidden = YES;
	_prefScrollView.hidden = YES;
	_prefButton.hidden = NO;
}

// Clearing all cookies will ensure that when a user revokes a permission
// he will need to log in again first the next time he wishes to publish 
// to that social network again
-(void) clearCookies:networkName
{
	DebugLog(@"Clearing all cookies for this network: %@", networkName);
	NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		if([[cookie domain] isEqual:[NSString stringWithFormat:@".%@.com", networkName]])
		{
			DebugLog(@"Removing this cookie now: %@", cookie);
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		}
	}
}

// As soon as the icon has been loaded from the PinkelStar server we call this
// to replace the placeholder icon with the correct social network icon
-(void) updateSocialNetworkPrefIcon:(NSInteger) networkIndex
{
	DebugLog(@"Entering updateSocialNetworkPrefIcon");
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:networkIndex];
	UIImage *prefIcon;
	
	// update this icon in the prefs view now
	if(networkIndex != NSNotFound)
	{
		prefIcon = [psServer getSocialNetworkIconPS:networkName size:PSSocialNetworkIconSmall];
		if(prefIcon)
		{
			if ([self currentDeviceIsRetinaDisplay])
			{
				// we need to adjust the image, as iOS will try to scale it to 2.0
				[[_socialNetworkPrefIcons objectAtIndex:networkIndex] 
				 setImage:[self adjustImageScaleForRetinaDisplay:prefIcon width:prefIconWidth height:prefIconHeight]];		
				
			}
			else
			{
				[[_socialNetworkPrefIcons objectAtIndex:networkIndex] setImage:prefIcon];
			}
			
		}
		else {
			DebugLog(@"updateSocialNetworkPrefIcon: nothing to update");
		}
	}
	else 
		DebugLog(@"updateSocialNetworkPrefIcon: Unknown icon for network name = %@", networkName);
	
}

-(void) toggleSocialNetworkPrefSwitch:(NSString *) networkName
{
	// Locate the switch and toggle its value. We don't care what it was before
	// all we know is it was changed
	UISwitch *prefSwitch = [_socialNetworkSwitches objectAtIndex:[supportedNetworks getIndexFromNetworkName:networkName]];
	BOOL onOrOff = prefSwitch.isOn;
	[prefSwitch setOn:!onOrOff animated:NO];	
}

// position the Social Network icon in the prefs view
-(CGRect) calculatePrefSocialNetworkIconPosition:(NSInteger) row
{
	// We position the rows in a grid
	float iconOffsetY;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// iconOffsetY = (prefRowHeight_iPad - prefIconHeight_iPad) / 2.0;
		iconOffsetY = 5.0;
		DebugLog(@"Row nr == %d, or in float %f", row, (float) row);
		DebugLog(@"Positioning an icon at: (%f, %f)", prefIconOrigin_iPad.x, prefIconOrigin_iPad.y + (float) row * prefRowHeight_iPad + iconOffsetY);
		return CGRectMake(prefIconOrigin_iPad.x,
						  prefIconOrigin_iPad.y + (float) row * (prefRowHeight_iPad - iconOffsetY),
						  prefIconWidth_iPad, 
						  prefIconHeight_iPad);
	}
	else
	{
		iconOffsetY = (prefRowHeight - prefIconHeight) / 2;
	
		DebugLog(@"Positioning an icon at: (%f, %f)", prefIconOrigin.x, prefIconOrigin.y + (float) row * prefRowHeight + iconOffsetY);
		return CGRectMake(prefIconOrigin.x,
						  prefIconOrigin.y + (float) row * prefRowHeight + iconOffsetY,
						  prefIconWidth, 
						  prefIconHeight);
	}
	
}

// position the Social Network label in the prefs view
-(CGRect) calculatePrefSocialNetworkLabelPosition:(NSInteger) row
{
	// We position the rows in a grid. Each row is of size: 302x45 (wxh)
	// The row starts at position (0, 0), labels are always placed at (50, y)
	// The icon is centered in the row, and positioned on the left
	float labelOffsetY;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		labelOffsetY = (prefRowHeight_iPad - prefLabelHeight_iPad) / 2;
		
		DebugLog(@"Positioning a label at: (%f, %f)", prefLabelOrigin_iPad.x, prefLabelOrigin_iPad.y + (float) row * prefRowHeight_iPad + labelOffsetY);
		return CGRectMake(prefLabelOrigin_iPad.x,
						  prefLabelOrigin_iPad.y + (float) row * prefRowHeight_iPad + labelOffsetY,
						  prefLabelWidth_iPad, 
						  prefLabelHeight_iPad);
		
	}
	else
	{
		labelOffsetY = (prefRowHeight - prefLabelHeight) / 2;
	
		DebugLog(@"Positioning a label at: (%f, %f)", prefLabelOrigin.x, prefLabelOrigin.y + (float) row * prefRowHeight + labelOffsetY);
		return CGRectMake(prefLabelOrigin.x,
						  prefLabelOrigin.y + (float) row * prefRowHeight + labelOffsetY,
						  prefLabelWidth, 
						  prefLabelHeight);
	}
}

// position the Social Network switch in the prefs view
-(CGRect) calculatePrefSocialNetworkSwitchPosition:(NSInteger) row
{
	// We position the rows in a grid. Each row is of size: 302x45 (wxh) iPhone, and 488x66 iPad
	// The row starts at position (0, 0)
	// the slider is positioned on the right, centered, always placed at (200, y)
	CGFloat switchOffsetY;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		switchOffsetY = (prefRowHeight_iPad - prefSwitchHeight_iPad) / 2;
		
		DebugLog(@"Positioning a switch at: (%f, %f)", prefSwitchOrigin_iPad.x, prefSwitchOrigin_iPad.y + (float) row * prefRowHeight_iPad + switchOffsetY);
		return CGRectMake(prefSwitchOrigin_iPad.x,
						  prefSwitchOrigin_iPad.y + (float) row * prefRowHeight_iPad + switchOffsetY,
						  prefSwitchWidth_iPad, 
						  prefSwitchHeight_iPad);
	}
	else
	{
		switchOffsetY = (prefRowHeight - prefSwitchHeight) / 2;
	
		DebugLog(@"Positioning a switch at: (%f, %f)", prefSwitchOrigin.x, prefSwitchOrigin.y + (float) row * prefRowHeight + switchOffsetY);
		return CGRectMake(prefSwitchOrigin.x,
						  prefSwitchOrigin.y + (float) row * prefRowHeight + switchOffsetY,
						  prefRowWidth, 
						  prefRowHeight);
	}
}

// position the Social Network pref row in the prefs view
-(CGRect) calculatePrefRowPosition:(NSInteger) row
{
	// We position the rows in a grid. Each row is of size: 302x45 (wxh) iPhone, or 488x65 iPad
	// The row starts at position (0, 0)
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		DebugLog(@"Positioning a row at: (%f, %f)", prefRowOrigin_iPad.x, prefRowOrigin_iPad.y + (float) row * prefRowHeight_iPad);
		return CGRectMake(prefRowOrigin_iPad.x,
						  prefRowOrigin_iPad.y + (float) row * prefRowHeight_iPad,
						  prefRowWidth_iPad, 
						  prefRowHeight_iPad);
	}
	else
	{
		DebugLog(@"Positioning a row at: (%f, %f)", prefRowOrigin.x, prefRowOrigin.y + (float) row * prefRowHeight);
		return CGRectMake(prefRowOrigin.x,
					  prefRowOrigin.y + (float) row * prefRowHeight,
					  prefRowWidth, 
					  prefRowHeight);
	}
}

// Place the Social Network icon in the prefs view
-(void) setUpSocialNetworkPrefIcon:(NSInteger) i
{
	UIImageView *prefSocialNetworkIconView;
	//NSString *imagePath;
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:i];
	UIImage *prefIcon =  [psServer getSocialNetworkIconPS:networkName size:PSSocialNetworkIconSmall];
	
	// if it doesn't exist yet it will be updated from the server soon
	if(!prefIcon)
	{
		//imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"pref_placeholder_icon_small"] ofType:@"png"];
		DebugLog(@"setupSocialNetworkPreferences: imagePath = %@", networkName);
		//prefIcon = [UIImage imageWithContentsOfFile:imagePath];
		prefIcon = [self getImage:@"pref_placeholder_icon_small" ofType:@"png"];
	}
	prefSocialNetworkIconView = [[[UIImageView alloc] initWithImage:prefIcon] autorelease];
	prefSocialNetworkIconView.contentMode = UIViewContentModeCenter;
	prefSocialNetworkIconView.frame = [self calculatePrefSocialNetworkIconPosition:i];
	
	// we store this locally so that we can update the view when the server sends us the correct icons
	[_socialNetworkPrefIcons addObject:prefSocialNetworkIconView];
	
	[_prefScrollView addSubview:prefSocialNetworkIconView];
}

// Place a background image for each pref
// We may at some point use coregrapics to reduce image usage, but for now this is fine
-(void) setupPrefBackgroundImage:(NSInteger) backgroundIndex rows:(NSInteger) rows
{
	UIImageView *imgView;
	//NSString *imagePath;
	CGRect frame;
	DebugLog(@"Entering setupPreferencesBackgroundImage");
	frame = [self calculatePrefRowPosition:backgroundIndex];
	
	// We need separate images for iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// the top row has rounded corners
		if(backgroundIndex == 0)
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_toprow_bg_iPad" ofType:@"png"]] autorelease];
		}
		else if(backgroundIndex == rows -1)
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_bottomrow_bg_iPad" ofType:@"png"]] autorelease];
		}
		// the bottom row has rounded corners
		else
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_row_bg_iPad" ofType:@"png"]] autorelease];
		}
	}
	else
	{
		// the top row has rounded corners
		if(backgroundIndex == 0)
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_toprow_bg" ofType:@"png"]] autorelease];
		}
		else if(backgroundIndex == rows -1)
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_bottomrow_bg" ofType:@"png"]] autorelease];
		}
		// the bottom row has rounded corners
		else
		{
			imgView = [[[UIImageView alloc] initWithImage:[self getImage:@"pref_table_row_bg" ofType:@"png"]] autorelease];
		}
	}
	imgView.frame = frame;
	[_prefScrollView addSubview:imgView];
}

// Create a social network switch label in the pref view
-(void) setSocialNetworkPrefSwitchLabel:(NSInteger) switchIndex
{
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:switchIndex];
	UILabel *switchLabel = [[[UILabel alloc] initWithFrame:[self calculatePrefSocialNetworkLabelPosition:switchIndex]] autorelease];
	
	switchLabel.text = networkName;
	switchLabel.backgroundColor = [UIColor clearColor];
	switchLabel.textColor = [UIColor whiteColor];
	switchLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(15.0)];
	
	[_prefScrollView addSubview: switchLabel];
}

// Create a social network switch in the pref view
-(void) setSocialNetworkPrefSwitch:(NSInteger) switchIndex
{
	UISwitch *prefSwitch;
	NSString *networkName;
	
	networkName = [supportedNetworks getNetworkNameFromIndex:switchIndex];
	DebugLog(@"setupSocialNetworkPreferences: networkName = %@", networkName);
	prefSwitch = [[[UISwitch alloc] initWithFrame:[self calculatePrefSocialNetworkSwitchPosition:switchIndex]] autorelease];
	[prefSwitch addTarget: self action: @selector(socialNetworkSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	// this will help us remember what switch was touched. It has the same index as the networkName
	[prefSwitch setTag:switchIndex];
	[_socialNetworkSwitches addObject:prefSwitch];
	
	if([psServer canPublishPS:networkName])
	{
		// We can publish to this network, so set slider to true
		[prefSwitch setOn:YES animated:NO];			
	}
	else 
	{
		// we can't publish to this network so set it to false
		[prefSwitch setOn:NO animated:NO];			
	}
	[_prefScrollView addSubview:prefSwitch];
	
}

// call this to set up the Preferences view as soon as the initial
// server response is in
// It will not be displayed until we call showPreferencesView
-(void) setupSocialNetworkPreferenceView
{
	NSInteger nrOfNetworks = [supportedNetworks numberOfSupportedSocialNetworks];
	
	if(!_socialNetworkSwitches)
		_socialNetworkSwitches = [[NSMutableArray alloc] init];
	if(!_socialNetworkPrefIcons)
		_socialNetworkPrefIcons = [[NSMutableArray alloc] init];
	
	// We need a row for each Social Network
	// Every row has a background image, a social network icon, a label and a switch
	for(int i=0; i < nrOfNetworks; i++)
	{
		// Set up the Social Network icon background
		[self setupPrefBackgroundImage:i rows:nrOfNetworks];
		// Set up the Social Network icon
		[self setUpSocialNetworkPrefIcon:i];
		// a label for the network name
		[self setSocialNetworkPrefSwitchLabel:i];
		// and the switch itself
		[self setSocialNetworkPrefSwitch:i];
	}
}

// The user altered the social network pref switch
-(IBAction) socialNetworkSwitchChanged:(id)sender
{
	DebugLog(@"Entering socialNetworkSwitchChanged");
	
	UISwitch *socialNetworkSwitch = (UISwitch *) sender;
	BOOL setting = socialNetworkSwitch.isOn;
	
	// if the switch was On ad it is turned off, we need to call
	// revokePermission
	
	// If the switch was off and it is turned on, we need to
	// call our webView to get the permission
	
	// first, locate the switch an figure out what network it belongs to
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:socialNetworkSwitch.tag];
	
	if(setting)
	{
		DebugLog(@"The switch is on now %@", networkName);
		if(![psServer canPublishPS:networkName])
			// open a modal view to get the permission
			[self getPermissionPS:networkName];
		else
			// This is odd
			DebugLog(@"socialNetworkSwitchChanged: switch is set to ON, but we already have permission according to the PinkelStar server??");
	}
	else 
	{
		DebugLog(@"The switch is off now for %@", networkName);
		// if it is turned off, we will call revoke now forcing the user to provide permission later if he wants
		// to publish to this network again
		
		// make sure we store this change locally
		[supportedNetworks setSocialNetworkSelection:networkName selected:NO];
		[supportedNetworks setWillPublishToNetwork:networkName done:NO];
		
		// And now tell the server to revoke the permission on behalf of the user
		[psServer revokePermissionPS:networkName];
		
		// as a final measure, we clear the network cookies to ensure the user
		// really needs to log in again next time he wants to publish to the social network
		[self clearCookies:networkName];
	}
	
	
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// End preferences view methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Main rotation view methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		DebugLog(@"iPad detected, autorotation is turned on..................................");
        return YES; // supports all orientations
    }
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
		return YES;
	
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// End main rotation view methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Main View view methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////

// Set the delegate
-(id) initWithDelegate:(id) aDelegate
{
	DebugLog(@"Entering initWithDelegate!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	self = [super init];
	if (self != nil) {
		_delegate = aDelegate;
		
	}
	return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		DebugLog(@"Entering initWithNibName!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NibName == %@", nibNameOrNil);
		// Setup a local object that contains the supported Social Networks
		// Note that this will be UPDATED as soon as the server returns with the psInitFinished callback!
		supportedNetworks = [[PSSocialNetworks alloc] init];
		
		// Retrieve the application and developer data
		// without this call the service will not work
		DebugLog(@"Setting up the server initialization");
		psServer = [[PSPinkelStarServer alloc] initWithDelegate:self];
		
		// This is really odd. on iPad for some reason these buttons do not work unless we programatically
		// move them to the front. More people seem to have this issue
		// see : http://stackoverflow.com/questions/3345499/ipad-ibaction-for-uibutton-responds-on-iphone-device-not-on-ipad
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
		{
			[self.view bringSubviewToFront:_cancelButton];	//moves the button above other subviews
			[_cancelButton setNeedsDisplay];				//ensure the button is redrawn
			[self.view bringSubviewToFront:_prefButton];
			[_prefButton setNeedsDisplay];
			[self.view bringSubviewToFront:userMessage];
			[userMessage setNeedsDisplay];			
		}
		
		// Adding the buttonView now
		_buttonScrollView.scrollEnabled = YES;
		[_buttonScrollView setContentSize:CGSizeMake(200.0, 400.0)];
		[_buttonScrollView setNeedsDisplay];

		// Add the pref view, ad then hide it on ViewDidLoad
		[self.view addSubview:_prefView];

		//[self.view setNeedsDisplay];
	}
	return self;
}

-(void) setBlockerView:(NSString *)str
{
	if(!_blockerView)
	{
		_blockerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 80)] autorelease];
		_blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
		_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
		_blockerView.alpha = 1.0;
		_blockerView.clipsToBounds = YES;
		if ([_blockerView.layer respondsToSelector: @selector(setCornerRadius:)]) 
			[(id) _blockerView.layer setCornerRadius: 10];
		UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite] autorelease];
		
		spinner.center = CGPointMake(_blockerView.bounds.size.width / 2, _blockerView.bounds.size.height / 2 + 20);
		[_blockerView addSubview: spinner];
		[self.view addSubview: _blockerView];
		[spinner startAnimating];
	}
	if(!_blockerLabel)
	{
		_blockerLabel = [[[UILabel alloc] initWithFrame: CGRectMake(0, 5, _blockerView.bounds.size.width -10, 40)] autorelease];
		_blockerLabel.backgroundColor = [UIColor clearColor];
		_blockerLabel.textColor = [UIColor whiteColor];
		_blockerLabel.textAlignment = UITextAlignmentCenter;
		_blockerLabel.font = [UIFont boldSystemFontOfSize: 12];
		_blockerLabel.numberOfLines = 2;
	}
	_blockerLabel.text = str;
	[_blockerView addSubview: _blockerLabel];
	//[_blockerLabel release];
}

// Remove the spinner and text message
-(void) removeBlockerView
{
	if(_blockerView)
	{
		[_blockerView removeFromSuperview];
		_blockerView = nil;
		_blockerLabel = nil;
	}
}

// We set up parts of our view here
// Most stuff has been defined in the PSMainViewController.xib file already
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create a spinner animation, until we have loaded our server settings
	[self setBlockerView:NSLocalizedString(@"Loading your settings...", @"Loading your settings...")];

	// Make sure all preference view elements are not visible
	[self hidePreferencesView];
		
	// Setting the publish button to be rounded
	[[_publishButton layer] setCornerRadius:8.0f];
	[[_publishButton layer] setMasksToBounds:YES];
	[[_publishButton layer] setBorderWidth:1.0f];
	// set the border color the same as the pink we use
	[[_publishButton layer] setBorderColor:[[UIColor colorWithRed:0.9098 green:0.043 blue:0.3843 alpha:1.0] CGColor]];
	
	// set the button shine
	[[_publishButtonShine layer] setCornerRadius:8.0f];
	[[_publishButtonShine layer] setMasksToBounds:YES];
	[[_publishButtonShine layer] setBorderWidth:1.0f];
	[[_publishButtonShine layer] setBorderColor:[[UIColor clearColor] CGColor]];
}

// The custom share message is displayed right next to the app icon
-(void)addCustomShareMessage:(NSString *) msg
{
	if(_customShareMessageText)
		[_customShareMessageText release];
	_customShareMessageText = [msg copy];
	
}

// The developer can set a custom content URL that is shared
// This functionality will be supported shortly
// Right now the content url is sent to the server but not displayed in the share yet
-(void)addContentURL:(NSURL *) url
{
	if(_contentURL)
	{
		[_contentURL release];
		_contentURL = nil;
	}
	
	_contentURL = [url copy];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	_blockerLabel = nil;
	_blockerView = nil;
	userMessage = nil;
	psServer = nil;
	supportedNetworks = nil;
	_customShareMessageLabel = nil;
	_customShareMessageText = nil;
	_appIconView = nil;
	_socialNetworkButtons = nil;
	_contentURL = nil;
	_socialNetworkButtons = nil;
	_socialNetworkPrefIcons = nil;
}


- (void)dealloc {
	DebugLog(@"PSMainViewController DEALLOC");
	[userMessage release];
	[supportedNetworks release];
	[psServer release];
	if(_socialNetworkButtons)
		[_socialNetworkButtons release];
	if(_customShareMessageText)
		[_customShareMessageText release];
	if(_contentURL)
		[_contentURL release];
	if(_socialNetworkSwitches)
		[_socialNetworkSwitches release];
	if(_socialNetworkPrefIcons)
		[_socialNetworkPrefIcons release];
	
    [super dealloc];
}

-(void) alertUnknownApplicationKeySecret
{
	// We do not recognize the app, so prompt the developer
	// that he needs to enter his application key and secret in the ApplictionDeveloper.plist file
	// before he can use the PinkelStar service 
	UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Application Key/Secret not set", @"Application Key/Secret not set") 
														message:NSLocalizedString(@"Please enter your app Key and Secret in the pinkelstar.plist file", @"Please enter your app Key and Secret in the pinkelstar.plist file")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(void) alertCantPublishYet
{
	//None of the networks were available. So prompt the user that he needs to login to
	// a network before he can publish anything
	UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't publish yet", @"Can't publish yet") 
														message:NSLocalizedString(@"Please select a social network first", @"Please select a social network first")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

-(void) alertDonePublishing
{
	// Empty the userMessage and tell the user he is done
	userMessage.text = nil;
	NSString *alertMessage = [[NSString alloc] initWithFormat:NSLocalizedString(@"You will now return to the %@ app", @"You will now return to the %@ app"), [psServer getApplicationName]];
	
	// Be aware that if you alter the title here, alter the test at the delegate callback too
	UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Publication was succesful", @"Publication was succesful")
														message:alertMessage 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[alertMessage release];
}	

// Make sure the keyboard disappears when the user is done typing.
-(IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

// Make sure the keyboard disappears when the user is done typing.
-(IBAction)backgroundTap:(id)sender
{
	[sender resignFirstResponder];
}

// This is called when
// a) the user has pressed the publish button, and
// b) we have checked and obtained all permissions to publish
// We can now safely publish
-(void) publishToNetworks
{
	// We now need to check if we have something to publish too or not
	// Pick up the list of networks that have been selected and that we are
	// allowed to publish too
	NSArray *arr = [supportedNetworks getListOfNetworksWillPublish];
	if(arr)
	{
		DebugLog(@"PSMainViewController: publishToNetworks: publishing to %d networks now", [arr count]);
		// Store locally that we now actually will publish
		// DO NOT FORGET THIS, or you may run into an infinite loop of publish messages
		[supportedNetworks willPublishNow];
		
		[psServer publishPS:self.userMessage.text 
			   eventMessage:_customShareMessageText
				 contentUrl:_contentURL
				networkList:arr];
	}
	else
	{
		DebugLog(@"PSMainViewController: publishToNetworks: alertCantPublishYet");
		// Can't publish yet
		[self alertCantPublishYet];
	}
	
}

// See if we can publish to a selected network.
// If not, we ask for permission
-(void)getSelectedNetworkPermission:(NSString *)networkName
{
	
	if([psServer canPublishPS:networkName])
	{
		// save it for later
		DebugLog(@"Saving %@ for publication later", networkName);
		[self.supportedNetworks setWillPublishToNetwork:networkName done:YES];
		// and call publishPS again, cause there may be other networks selected
		[self publishPS];
	}
	else {
		//This is where we start showing a modal window and request user permission
		// Note that in the success callback this will recursively call
		// publishPS again to see if we need to gather more network permissions
		DebugLog(@"Getting permission now...");
		[self getPermissionPS:networkName];
	}
}

// This method finds the first/next network we need to publish to.
// Not that it is recursive until we have gathered all permissions
-(void) publishPS
{
	
	NSString *networkName = [supportedNetworks getNextSelectedSocialNetwork];
	if(networkName)
	{
		// gather its permission and see if there are other networks 
		// to publish to
		[self getSelectedNetworkPermission:networkName];
		
	}
	else {
		// Done, now we can safely go to publishToNetworks
		[self publishToNetworks];
	}
}

// public methods

-(void)finishPS
{
	// time to close down pinkelstar and hand back control to the host app
	// Pop to root first for memory cleanup
	DebugLog(@"PSMainViewController:finishPS, cleaning up now");
	
	if ([_delegate respondsToSelector:@selector(psFinished:)])
		[_delegate psFinished:self];
	else
		DebugLog(@"PSMainViewController: _psdelegate doesn't respond to psFinished?");
}

// set the host app icon in the view
-(void) updateAppIcon
{
	UIImage *appIcon = [psServer getApplicationIcon];
	if(appIcon)
		_appIconView.image = appIcon;
	else {
		// do nothing
		DebugLog(@"updateAppIcon: nothing to update");
	}

}

// You can set default share messages based upon a chosen event
-(void)setEventTypePS:(PSEventType) eventTypePS
{
	_eventType = eventTypePS;
}

- (NSString *) getPSEvent:(PSEventType) eventType
{
	
	switch (eventType) 
	{
		case PSInstallationEvent:
			return [NSString stringWithFormat:NSLocalizedString(@"I just downloaded %@", @"I just downloaded %@"), [psServer getApplicationName]];
			break;
		case PSLikeEvent:
			return [NSString stringWithFormat:NSLocalizedString(@"I like %@ for the iPhone", @"I like %@ for the iPhone"), [psServer getApplicationName]];
			break;
		case PSCustomEvent:
			return _customShareMessageText;
			break;
		default:
			return [NSString stringWithFormat:NSLocalizedString(@"I like %@", @"I like %@"), [psServer getApplicationName]];
			break;
	}
}

// 1. Insert the dev app name in the custom share message if needed
// 2. Update the app icon we received from the server
-(void) updateDeveloperDetails
{
	if(_eventType != PSCustomEvent)
	{
		if(_customShareMessageText)
			[_customShareMessageText release];
		_customShareMessageText = [NSString stringWithString:[self getPSEvent:_eventType]];
	}
	// else, don't touch it, we assume the developer has set it already
	_customShareMessageLabel.text = _customShareMessageText;
	
	[self updateAppIcon];
}

-(void) updateSocialNetworkList
{
	[supportedNetworks updateSocialNetworks:[psServer getSocialNetworksPS]];
}

////////////////////////////////////////////////////////////////////////////////////////////
//
// Code related to the social network buttons displayed on screen
//
////////////////////////////////////////////////////////////////////////////////////////////


-(void) selectButton:(UIButton *) aButton networkName:(NSString *) networkName
{
	// iPhone 4 trick, we can remove this as soon as Apple fixes imageWithContentsOfFile to load
	// Highres @2x images automatically
	// iPhone 4	
	[aButton setBackgroundImage:[self getImage:@"sn_button_bg_selected" ofType:@"png"] forState:UIControlStateNormal];

	[supportedNetworks setSocialNetworkSelection:networkName selected:YES];
}

-(void) deselectButton:(UIButton *) aButton networkName:(NSString *) networkName
{
	// iPhone 4 trick, we can remove this as soon as Apple fixes imageWithContentsOfFile to load
	// Highres @2x images automatically
	// iPhone 4
	[aButton setBackgroundImage:[self getImage:@"sn_button_bg_normal" ofType:@"png"] forState:UIControlStateNormal];

	// Store the deselection locally
	[supportedNetworks setSocialNetworkSelection:networkName selected:NO];
}

- (void) toggleButtonStatus:(UIButton *) aButton networkName:(NSString *) networkName
{
	BOOL networkSelected = [supportedNetworks isSocialNetworkSelected:networkName];
	
	if(!networkSelected)
	{
		[self selectButton:aButton networkName:networkName];
	}
	else
	{
		[self deselectButton:aButton networkName:networkName];
	}
}

-(IBAction) socialNetworkButtonPressed:(UIButton *) aButton
{
	[self toggleButtonStatus:aButton networkName:aButton.titleLabel.text];
}

-(CGRect) calculateSocialNetworkButtonPosition:(int) buttonNr
{
	// We position the buttons in a grid.
	// 3 buttons in a row
	int row = round(buttonNr / 3);
	int column = buttonNr % 3;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
	{
		DebugLog(@"Positioning a button at: (%f, %f)", buttonOrigin_iPad.x + column * (buttonWidth_iPad + buttonSpaceX_iPad), buttonOrigin_iPad.y + (float) row *(buttonHeight_iPad + buttonSpaceY_iPad));
		return CGRectMake(buttonOrigin_iPad.x + column * (buttonWidth_iPad + buttonSpaceX_iPad),
						  buttonOrigin_iPad.y + (float) row *(buttonHeight_iPad + buttonSpaceY_iPad),
						  buttonWidth_iPad, 
						  buttonHeight_iPad);
	}
	else {
		DebugLog(@"Positioning a button at: (%f, %f)", buttonOrigin.x + column * (buttonWidth + buttonSpaceX), buttonOrigin.y + (float) row *(buttonHeight + buttonSpaceY));
		return CGRectMake(buttonOrigin.x + column * (buttonWidth + buttonSpaceX),
						  buttonOrigin.y + (float) row *(buttonHeight + buttonSpaceY),
						  buttonWidth, 
						  buttonHeight);
		
	}
}

// We replace an Social Network placeholder icon with the icon
// we have received from the server
-(void) updateSocialNetworkButtonIcon:(NSInteger) buttonIndex
{
	DebugLog(@"Entering updateSocialNetworkButtonIcon");
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:buttonIndex];
	UIImage *buttonImage;
	if(buttonIndex != NSNotFound)
	{
		buttonImage = [psServer getSocialNetworkIconPS:networkName size:PSSocialNetworkIconMedium];
		if(buttonImage)
		{				 
			if ([self currentDeviceIsRetinaDisplay])
			{
				// we need to adjust the image, as iOS will try to scale it to 2.0
				[[_socialNetworkButtons objectAtIndex:buttonIndex] 
				 setImage:[self adjustImageScaleForRetinaDisplay:buttonImage width:buttonIconWidth height:buttonIconHeight]
																   forState:UIControlStateNormal];
				[[_socialNetworkButtons objectAtIndex:buttonIndex] 
				 setImage:[self adjustImageScaleForRetinaDisplay:buttonImage width:buttonIconWidth height:buttonIconHeight]
																   forState:UIControlStateHighlighted];			
				
			}
			else
			{
				[[_socialNetworkButtons objectAtIndex:buttonIndex] setImage:buttonImage
														   forState:UIControlStateNormal];
				[[_socialNetworkButtons objectAtIndex:buttonIndex] setImage:buttonImage
														   forState:UIControlStateHighlighted];		
			}
		}
		else 
		{
			DebugLog(@"updateSocialNetworkButtonIcon: the new image can't be found yet. Not updating at this moment");
		}

	}
	else 
		DebugLog(@"updateSocialNetworkButtonIcon: Unknown button for network name = %@", networkName);

}

// we call this after the user has set preferences for networks.
// Result:
// if the user has provided premission to a network in prefs, we select the button
// if the user has revoked permission for a network in prefs, we deselect the button
-(void) updateButtonState:(NSString *)networkName
{
	int buttonIndex = [supportedNetworks getIndexFromNetworkName:networkName];
	
	if(buttonIndex != NSNotFound)
	{
		// Check to see if we need to select or deselect it
		if([psServer canPublishPS:networkName])
			[self selectButton:[_socialNetworkButtons objectAtIndex:buttonIndex] networkName:networkName];
		else 
			[self deselectButton:[_socialNetworkButtons objectAtIndex:buttonIndex] networkName:networkName];

	}
	else 
		DebugLog(@"updateButtonState: Unknown button for network name = %@", networkName);
	
}

// Note that we create a default button with a placeholder image here
// The button needs to be udated as soon as the actual
// social network icons are send over by the server
-(void) createButton:(NSString *) networkName
{
	// we store the buttons in this array
	if(!_socialNetworkButtons)
		_socialNetworkButtons = [[NSMutableArray alloc] init];
	
	UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	// we add the button to our scrollable view
	[_buttonScrollView addSubview:aButton];
	
	// store it safely for easy access later
	[_socialNetworkButtons addObject:aButton];
	
	aButton.frame = [self calculateSocialNetworkButtonPosition:[_socialNetworkButtons indexOfObject:aButton]];
	
	// iPhone 4 trick, we can remove this as soon as Apple fixes imageWithContentsOfFile to load
	// Highres @2x images automatically
	// iPhone 4
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
	{
		[aButton setBackgroundImage:[self getImage:@"sn_button_bg_normal_iPad" ofType:@"png"] forState:UIControlStateNormal];
		[aButton setBackgroundImage:[self getImage:@"sn_button_bg_selected_iPad"  ofType:@"png"] forState:UIControlStateHighlighted];		
		// placeholder icon only, icons will be updated once the server responds
		[aButton setImage:[self getImage:@"placeholder_button_icon_iPad" ofType:@"png"] forState:UIControlStateNormal];
		[aButton setImage:[self getImage:@"placeholder_button_icon_iPad" ofType:@"png"] forState:UIControlStateHighlighted];
		[aButton setImageEdgeInsets:UIEdgeInsetsMake(-35.0, 10.0, 0.0, 10.0)];
		[self.view bringSubviewToFront:aButton];	//moves the button above other subviews
		[aButton setNeedsDisplay];				    //ensure the button is redrawn

		aButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(14.0)];
		[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[aButton setTitleEdgeInsets:UIEdgeInsetsMake(55.0, -75.0, 0.0, 0.0)];
		
	}
	else
	{
		[aButton setBackgroundImage:[self getImage:@"sn_button_bg_normal" ofType:@"png"] forState:UIControlStateNormal];
		[aButton setBackgroundImage:[self getImage:@"sn_button_bg_selected"  ofType:@"png"] forState:UIControlStateHighlighted];
		// placeholder icon only, icons will be updated once the server responds
		[aButton setImage:[self getImage:@"placeholder_button_icon" ofType:@"png"] forState:UIControlStateNormal];
		[aButton setImage:[self getImage:@"placeholder_button_icon" ofType:@"png"] forState:UIControlStateHighlighted];
		[aButton setImageEdgeInsets:UIEdgeInsetsMake(-20.0, 10.0, 0.0, 10.0)];
		
		aButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:(12.0)];
		[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[aButton setTitleEdgeInsets:UIEdgeInsetsMake(45.0, -60.0, 0.0, 0.0)];
		
	}
	[aButton addTarget:self action:@selector(socialNetworkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[aButton setTitle:networkName forState:UIControlStateNormal];

}

-(void) setupButtons
{
	// This is called when the server response is in. 
	// we need to do 2 things:
	// 1. Create a button for each social network that was returned by the server
	// 2. Set it's status correct. If we already have permission to publish we
	//    will select the button, otherwise we will deselect it
	// Note that the actual network icons are loaded in the background
	NSArray *networks = [supportedNetworks getSupportedSocialNetworks];
	if([networks count] > 0)
	{
		for(int i=0;i< [networks count]; i++)
		{
			// create the button and position it correctly in the interface
			// We lay them out in a grid
			[self createButton:[networks objectAtIndex:i]];
			// check if we need to select it
			NSString *networkName = [supportedNetworks getNetworkNameFromIndex:i];
			if([psServer canPublishPS:networkName])
			{
				// We keep a score locally. So store that we set the button
				[supportedNetworks setSocialNetworkSelection:networkName selected:YES];
				[self selectButton:[_socialNetworkButtons objectAtIndex:i] networkName:networkName];
			}
		}
	}
	else 
	{
		DebugLog(@"PSMainViewController:setupButtons: There are no social networks to create buttons for");
	}

}


////////////////////////////////////////////////////////////////////////////////////////////
//
// Main button presses
//
////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)cancelButtonPressed
{	
	// time to close down pinkelstar and hand back control to the host app
	DebugLog(@"Cancel Button pressed, sending a cancel request now");
	// we log the cancel for stats purposes for the developer
	[psServer userCancelsPS];
	
	[self finishPS];
}

-(IBAction)prefButtonPressed
{
	DebugLog(@"pref Button pressed, opening a pref dialog now");
	
	// The button only needs to do something if the prefs are not shown
	if(_prefView.hidden)
		[self showPreferencesView];
}


-(IBAction)publishButtonPressed
{
	if([self.supportedNetworks isAnySocialNetworkSelected])
		[self publishPS];
	else
		[self alertCantPublishYet];
}

-(IBAction)donePrefButtonPressed
{
	DebugLog(@"Preferences Save Button Pressed");
	
	// 1. we hide the preferences view
	[self hidePreferencesView];
	// 2. we check to see if any social network buttons need to be selected/deselected
	for(int i=0;i<[supportedNetworks numberOfSupportedSocialNetworks]; i++)
		[self updateButtonState:[supportedNetworks getNetworkNameFromIndex:i]];
	
}

// called when reachability has changed (for example we've lost an Internet connection)
- (void) updateInterfaceWithReachability: (NSString *) message
{
	
	[self setBlockerView:message];
}

// PSPinkelStarServerDelegate

// Server not available. Be careful when using this. It can take up to
// 30 seconds to test if a server is availible or not.
// It is better to wait for psInternetNotAvailable to fire. It's a better indicator
-(void) psServerNotAvailable:(PSPinkelStarServer *) server
{
	DebugLog(@"Entering PSMainViewController: psServerNotAvailable.");
	// Wouldn't use this lightly. It can take a while to detect if there is no server available
	//[self updateInterfaceWithReachability:@"The PinkelStar server cannot be reached. Please wait or press cancel to return"];
}

// This fires if we do not detect Internet on the phone
-(void) psInternetNotAvailable:(PSPinkelStarServer *) server
{
	DebugLog(@"Entering PSMainViewController: psInternetNotAvailable. Updating the blocker message now");
	[self updateInterfaceWithReachability:NSLocalizedString(@"No Internet detected. Please wait or press cancel to return",@"No Internet detected. Please wait or press cancel to return")];
}

// This fires if we do detect Internet on the phone (again)
-(void) psInternetAvailable:(PSPinkelStarServer *) server
{
	DebugLog(@"Entering PSMainViewController: psInternetAvailable. Updating the blocker message now");
	[self updateInterfaceWithReachability:NSLocalizedString(@"Internet detected, loading settings now.",@"Internet detected, loading settings now.")];
	
	// We need to see if the service was already initialized correctly before. If that is not the case we know that
	// the service will autorecover and get a session key from the server. In that specific case we can leave the blocker
	// view message in sight, as it will be killed as soon as the init is finished.
	// The test we do is to see if we already have known social network buttons. If they are available the service was
	// initalized properly
	if([_socialNetworkButtons count] > 0)
		[self removeBlockerView];
}


-(void) psInitFinished:(PSPinkelStarServer *) server
{
	DebugLog(@"ENTERING psInitFinished now....xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
	// remove the spinner
	[self removeBlockerView];
	
	// We need to make sure the ViewController is aware of the loaded
	// developer and application data
	[self updateDeveloperDetails];
	
	// The UI needs to know what networks are supported
	// We store this locally
	[self updateSocialNetworkList];
	
	// We wil have to wait for successive request to finish to see 
	// what social network buttons we add to the interface
	// the icons need to be donwloaded first
	
	// Set up the social network buttons now.
	
	//Note: this is initial setup only, we load placeholder icons
	// The actual social
	// network icons will need to be downloaded from the server
	// As soon as they come in we update the view.
	[self setupButtons];
	
	// set up the preferences view
	// it will not show yet
	[self setupSocialNetworkPreferenceView];
}

-(void) psPublishRequestSend:(PSPinkelStarServer *) server
{
	// called whenever a publish request is send to the PS server
	// Use it for your own convenience
	
	// we publish to all networks at once, so all is left now is to show the close dialogue
	// technically we could wait for the server to respond with a
	// callback to psDidPublish, but we choose not to wait
	DebugLog(@"PSMainViewController: publishPS: AlertDonePublishing now");
	[self alertDonePublishing];
}

-(void) psDidPublish:(PSPinkelStarServer *) server
{
	// called as soon as the client has received back a server response
	// that tells us the publish request has finished
	// We already told the user everyting is done, so we  don't do anything here
}

-(void) psServerRequestFailed:(PSPinkelStarServer *) server
{
	// a server request failed. We now need to fail gracefully
	DebugLog(@"Entering PSMainViewController:psServerRequestFailed");
	
	// We will add better error support later, and ensure the specific error can be found
	// Most likely error is an incorrect APP key and secret.
	if(_blockerLabel)
	{
		// update the text
		DebugLog(@"PSMainController:psServerRequestFailed: there was a blocker view. Update the user message");
		_blockerLabel.text = NSLocalizedString(@"No Internet detected. Please wait or press cancel to return", @"No Internet detected. Please wait or press cancel to return");
	}
	DebugLog(@"PSNavigationController:psServerRequestFailed: No blocker view. we do nothing");
	
}

-(void) psServerRequestFinished:(PSPinkelStarServer *) server
{
	// use at your own convenience

}

-(void) psServerRequestSocialNetworkIconLoaded:(PSPinkelStarServer *) server
{
	// As soon as all icons are downloaded we update the interface
	DebugLog(@"psServerRequestSocialNetworkIconLoaded: we received an icon, updating the view now");
	
	// hack, for now we update them all
	// Overhead is minor, but it's ugly. The UI won't update anyways if there are no new icons
	for(int i = 0; i < [supportedNetworks numberOfSupportedSocialNetworks]; i++)
	{
		// main screen
		[self updateSocialNetworkButtonIcon:i];
		// pref screen
		[self updateSocialNetworkPrefIcon:i];
		// Update the app icon
		[self updateAppIcon];
	}
}
-(void) psInvalidApplicationKeySecret:(PSPinkelStarServer *) server
{
	// If you forget to enter your application key and secret in the
	// pinkelstar.plist file this method will
	// fire
	DebugLog(@"psInvalidApplicationKeySecret: Unknown application key and/or secret. Please upate your pinkelstar.plist file with your app registration details");
	
	[self alertUnknownApplicationKeySecret];
}

//UIAlertview delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	// Don't really care which one 
	
	// We should prob not use titles to determine the action needed ;-)
	if([actionSheet.title isEqual:NSLocalizedString(@"Publication was succesful",@"Publication was succesful")]) // we are done, give control back to the app
		[self finishPS];
	if([actionSheet.title isEqual:NSLocalizedString(@"Application Key/Secret not set", @"Application Key/Secret not set")]) // close PinkelStar
		[self finishPS];
	
	// else to nothing. The user needs to select a network first.
}

// PSPermissionViewDelegate
// Called when the dialog succeeds and is about to be dismissed.
- (void)psPermissionViewDialogDidSucceed:(PSPermissionView *)pView
{
	DebugLog(@"Entering PSMainViewController:dialogDidSucceed: retrieved permission for %@", pView.networkName);
	
	// save that we are publishing now to prevent doubles
	// hack we need to fix this. storePermissionPS is only local store
	[supportedNetworks setWillPublishToNetwork:pView.networkName done:YES];
	[supportedNetworks setSocialNetworkSelection:pView.networkName selected:YES];
	[psServer storePermissionPS:pView.networkName];	

	// we succeeded. Now check where we came from
	if(_prefView.hidden)
	{
		// The original webview was started because of a publish button press
		// check to see if we need more permissions
		DebugLog(@"PSMainViewController:dialogDidSucceed: permission saved, now back to publishPS");
		[self publishPS];
	}
	else {
		// do nothing. The web view was started from the preference window.
		// The user may want to set more prefs there.
		DebugLog(@"PSMainViewController:dialogDidSucceed: preference dialogue finished succesfully");
	}


}

// Called when the dialog is cancelled and is about to be dismissed.
- (void)psPermissionViewDialogDidCancel:(PSPermissionView *)pView
{
	DebugLog(@"Entering PSMainViewController:dialogDidCancel");
	// We need to check if we are in the preferences view or not
	// if so, we need to reset the switch for this specific network to its original
	// value
	if(!_prefView.hidden)
	{
		DebugLog(@"dialogDidCancel: Toggling the switch for %@", pView.networkName);
		[self toggleSocialNetworkPrefSwitch:pView.networkName];
	}
}

// Called when permission dialog failed to load due to an error.
- (void)dialog:(PSPermissionView *)dialog didFailWithError:(NSError*)error
{
	DebugLog(@"Entering PSMainViewController:didFailWithError");
	
}

@end
