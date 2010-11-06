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
#import "PSSettingsViewController.h"
#import "PSPinkelStarServer.h"
#import "PSSocialNetworks.h"
#import "PSPermissionView.h"
#import "PSMailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGImage.h>

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
static CGPoint buttonOrigin_iPad = {66.0,0.0};
static CGFloat buttonSpaceX_iPad = 34.0;
static CGFloat buttonSpaceY_iPad = 34.0;


static CGFloat permissionViewOffsetX = 20.0;
static CGFloat permissionViewOffsetY = 26.0;


@implementation PSMainViewController

@synthesize psMainDelegate = _psMainDelegate;
@synthesize _mainView;
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
@synthesize socialNetworkButtons = _socialNetworkButtons;
@synthesize contentURL = _contentURL;

// start a dialogue to obtain permission to publish to a specific social network
- (void) getPermissionPS:(NSString *) networkName
{
	PSPermissionView *permView = [[[PSPermissionView alloc] initWithDelegate:self] autorelease];
	permView.frame = CGRectMake(permissionViewOffsetX, permissionViewOffsetX+permissionViewOffsetY, self.view.frame.size.width - 2*permissionViewOffsetX, self.view.frame.size.height - (2*permissionViewOffsetX + permissionViewOffsetY));
	permView.networkName = networkName;
	permView.sessionKey = psServer.psSessionKey;
	[permView show];
}

// Current version of the PSPinkelStar UI code
+ (NSString *) version
{
	// return @"0.9.1";
	//return @"v.0.9.1.singleton.1";
	return @"v.0.9.2";
	
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

// Temp method needed because Apple hasn't fixed all image functions yet to load highres images for iPhone 4 when needed
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
// This method prevents iOS to scale that image 2x (no need as it is high res already)
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
	PSSettingsViewController *newController;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		newController = [[[PSSettingsViewController alloc] initWithNibName:[NSString stringWithString:@"PSSettingsViewController_iPad"] bundle:nil] autorelease];
	} 
	else 
	{
		newController = [[[PSSettingsViewController alloc] initWithNibName:[NSString stringWithString:@"PSSettingsViewController_iPhone"] bundle:nil] autorelease];
	}
	newController.delegate = self;
	[self.navigationController pushViewController:newController animated:YES];		
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


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		// Setup a local object that contains the supported Social Networks
		// Note that this will be UPDATED as soon as the server returns with the psInitFinished callback!
		supportedNetworks = [[PSSocialNetworks alloc] init];
		
		// Retrieve the application and developer data
		psServer = [PSPinkelStarServer sharedInstance];
		psServer.delegate =  self;
				
		// Set up the navigation controller
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
		self.navigationItem.leftBarButtonItem = cancelButton;

		
		UIButton* prefButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[prefButton addTarget:self action:@selector(prefButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[prefButton setBackgroundImage:[self getImage:@"PinkelStar_icon" ofType:@"png"] forState:UIControlStateNormal];
		[prefButton setBackgroundImage:[self getImage:@"PinkelStar_icon" ofType:@"png"] forState:UIControlStateHighlighted];
		prefButton.frame = CGRectMake(0, 0, 30, 30);
		UIBarButtonItem *prefButtonItem = [[UIBarButtonItem alloc] initWithCustomView:prefButton];
		self.navigationItem.rightBarButtonItem = prefButtonItem;
		[prefButtonItem release];
		
			
		self.title = @"Share";
		self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
		
		
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];

	_buttonScrollView.scrollEnabled = YES;
	[_buttonScrollView setContentSize:CGSizeMake(200.0, 300.0)];
	
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


// The custom share message is displayed right next to the app icon
-(void)addCustomShareMessage:(NSString *) msg
{
	if(_customShareMessageText)
		[_customShareMessageText release];
	_customShareMessageText = [msg copy];
	_customShareMessageLabel.text = _customShareMessageText;
	
	_customShareMessageLabel.text = _customShareMessageText;
	
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
}


- (void)dealloc {
	[userMessage release];
	[supportedNetworks release];
	[psServer release];
	if(_socialNetworkButtons)
		[_socialNetworkButtons release];
	if(_customShareMessageText)
		[_customShareMessageText release];
	if(_contentURL)
		[_contentURL release];
	
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

-(void) shareViaEmail
{
	PSMailViewController *mailController = [[[PSMailViewController alloc] init] autorelease];
	mailController.psMailDelegate = self;
	if(userMessage)
		if(userMessage.text)
			mailController.body = [NSString stringWithString:userMessage.text];
	if(_customShareMessageText)
		mailController.subj = [NSString stringWithString:_customShareMessageText];

	// If you want your user to share an image, or other types of data try this for example:
	// mailcontroller.image = [UIImage imageNamed:@"Whatever_image.png"];
	// see the PSMailViewController.h file for more email share options
	
	if(_contentURL)
		mailController.urlString  = [_contentURL absoluteString];

	mailController.appName = [NSString stringWithString:[psServer getApplicationName]];
	[mailController setupMailView];
	[self presentModalViewController:mailController animated:YES];
	   
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
	else 
	{
		// E-mail always needs a sender, so we start the e-mail view controller
		if([networkName isEqual:@"email"])
		{
			[self shareViaEmail];
		}
		else 
		{
			//This is where we start showing a modal window and request user permission
			// Note that in the success callback this will recursively call
			// publishPS again to see if we need to gather more network permissions
			DebugLog(@"Getting permission now...");
			[self getPermissionPS:networkName];
		}
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
	
	if ([_psMainDelegate respondsToSelector:@selector(psFinished:)])
		[_psMainDelegate psFinished:self];
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
		return CGRectMake(buttonOrigin_iPad.x + column * (buttonWidth_iPad + buttonSpaceX_iPad),
						  buttonOrigin_iPad.y + (float) row *(buttonHeight_iPad + buttonSpaceY_iPad),
						  buttonWidth_iPad, 
						  buttonHeight_iPad);
	}
	else {
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
	NSString *networkName = [supportedNetworks getNetworkNameFromIndex:buttonIndex];
	UIImage *buttonImage;
	if(buttonIndex != NSNotFound)
	{
		buttonImage = [psServer getSocialNetworkIconPS:networkName size:PSSocialNetworkIconMedium];
		DebugLog(@"##########################################");
		DebugLog(@"Updating the social network button icon for %@", networkName);
		if([networkName isEqual:@"email"])
		{
			DebugLog(@"Setting up the e-mail button now");
			if(buttonImage)
				DebugLog(@"Halleluja, we found the email icon");
			else {
				DebugLog(@"Cannot find the email button icon");
			}
		}
		DebugLog(@"##########################################");
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
		{
			[self selectButton:[_socialNetworkButtons objectAtIndex:buttonIndex] networkName:networkName];
		}
		else 
		{
			// make sure we store this change locally
			[supportedNetworks setSocialNetworkSelection:networkName selected:NO];
			[supportedNetworks setWillPublishToNetwork:networkName done:NO];
			[self deselectButton:[_socialNetworkButtons objectAtIndex:buttonIndex] networkName:networkName];
		}

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
	aButton.titleLabel.shadowColor = [UIColor darkTextColor];
	aButton.titleLabel.shadowOffset = CGSizeMake(0, -1);


}

-(void) setupButtons
{
	// This is called when the server response is in. 
	// we need to do 2 things:
	// 1. Create a button for each social network that was returned by the server
	// 2. Set it's status correct. If we already have permission to publish we
	//    will select the button, otherwise we will deselect it
	// Note that the actual network icons are loaded in the background
	NSArray *networks = [psServer getSupportedSocialNetworks];
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

// Call when we know that the PinkelStar server has send us icons
-(void) updateInterfaceIcons
{
	// hack, for now we update them all
	// Overhead is minor, but it's ugly. The UI won't update anyways if there are no new icons
	for(int i = 0; i < [psServer numberOfSupportedSocialNetworks]; i++)
	{
		// main screen
		[self updateSocialNetworkButtonIcon:i];
	}
	// Update the app icon
	[self updateAppIcon];
}

////////////////////////////////////////////////////////////////////////////////////////////
//
// Main button presses
//
////////////////////////////////////////////////////////////////////////////////////////////

-(IBAction)cancelButtonPressed
{	
	// time to close down pinkelstar and hand back control to the host app
	// we log the cancel for stats purposes for the developer
	[psServer userCancelsPS];
	
	[self finishPS];
}

-(IBAction)prefButtonPressed
{
	[self showPreferencesView];
}


-(IBAction)publishButtonPressed
{
	if([self.supportedNetworks isAnySocialNetworkSelected])
		[self publishPS];
	else
		[self alertCantPublishYet];
}

// called when reachability has changed (for example we've lost an Internet connection)
- (void) updateInterfaceWithReachability: (NSString *) message
{
	
	[self setBlockerView:message];
}

-(void) roundedCornerPublishButton
{
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

// We set up parts of our view here
// Most stuff has been defined in the PSMainViewController.xib file already
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(psServer.initialized)
	{
		// remove the spinner
		[self removeBlockerView];
		
		// We need to make sure the ViewController is aware of the loaded
		// developer and application data
		[self updateDeveloperDetails];
				
		// init all icons and buttons using placeholders
		[self setupButtons];
				
		// replace all placeholders with the correct icons
		[self updateInterfaceIcons];
		
	}
	else 
		// Create a spinner animation, until we have loaded our server settings
		// As soon as the server init response is in, the psInit delegate method takes care of everything
		[self setBlockerView:NSLocalizedString(@"Loading your settings...", @"Loading your settings...")];
	
	// Setting the publish button to be rounded
	[self roundedCornerPublishButton];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// All delegation methods
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	// remove the spinner
	[self removeBlockerView];
	
	// We need to make sure the ViewController is aware of the loaded
	// developer and application data
	[self updateDeveloperDetails];

	// We wil have to wait for successive request to finish to see 
	// what social network buttons we add to the interface
	// the icons need to be donwloaded first
	
	// Set up the social network buttons now.
	// Note: this is initial setup only, we load placeholder icons
	//		The actual social network icons will need to be downloaded from the server
	//		As soon as they come in we update the view.
	[self setupButtons];
}

-(void) psPublishRequestSend:(PSPinkelStarServer *) server
{
	// called whenever a publish request is send to the PS server
	// Use it for your own convenience
	
	// we publish to all networks at once, so all is left now is to show the close dialogue
	// technically we could wait for the server to respond with a
	// callback to psDidPublish, but we choose not to wait
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
	
	// We will add better error support later, and ensure the specific error can be found
	// Most likely error is an incorrect APP key and secret.
	if(_blockerLabel)
	{
		// update the text
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

	[self updateInterfaceIcons];
}
-(void) psInvalidApplicationKeySecret:(PSPinkelStarServer *) server
{
	// If you forget to enter your application key and secret in the
	// pinkelstar.plist file this method will
	// fire
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

// PSSetttingsViewControllerDelegate
// Called when the user has revoked a permission in the Settings View
- (void)psPermissionRevoked:(PSSettingsViewController *)vController
{
	
}

// Called when the user has added a permission in the Setting View
- (void)psPermissionAdded:(PSSettingsViewController *)vController
{
}

// Called when the user presses the done button  in the Settings View
- (void)psSettingsFinished:(PSSettingsViewController *)vController
{
	// We check to see if any social network buttons need to be selected/deselected
	for(int i=0;i<[psServer numberOfSupportedSocialNetworks]; i++)
		[self updateButtonState:[supportedNetworks getNetworkNameFromIndex:i]];
	
}

// PSPermissionViewDelegate
// Called when the dialog succeeds and is about to be dismissed.
- (void)psPermissionViewDialogDidSucceed:(PSPermissionView *)pView
{
	// save that we are publishing now to prevent doubles

	[supportedNetworks setWillPublishToNetwork:pView.networkName done:YES];
	[supportedNetworks setSocialNetworkSelection:pView.networkName selected:YES];
	[psServer storePermissionPS:pView.networkName];	
	[self publishPS];
}

// Called when the dialog is cancelled and is about to be dismissed.
- (void)psPermissionViewDialogDidCancel:(PSPermissionView *)pView
{
	DebugLog(@"Entering PSMainViewController:dialogDidCancel");
}

// Called when permission dialog failed to load due to an error.
- (void)dialog:(PSPermissionView *)dialog didFailWithError:(NSError*)error
{
	DebugLog(@"Entering PSMainViewController:didFailWithError");
	
}

// PSMailViewControllerDelegate
// Called when the e-mail was sent succesfully
-(void) psMailSendDidFinish:(PSMailViewController *)vController
{
	[self dismissModalViewControllerAnimated:YES];
	[psServer storePermissionPS:@"email"];	
	
	[self publishPS];
	
}

@end
