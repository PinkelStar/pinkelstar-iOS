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
//  PSMainViewController.h
//  pinkelstar
//
//  Created by Alexander van Elsas on 6/17/10.

#import <UIKit/UIKit.h>
#import <UIKit/UIDevice.h>
#import "PSMainViewControllerDelegate.h"
#import "PSSettingsViewControllerDelegate.h"
#import "PSPinkelStarServerDelegate.h"
#import "PSPermissionViewDelegate.h"
#import "PSMailViewControllerDelegate.h"

#define psDegreesToRadians(x) (M_PI * x / 180.0)

//which type of message is the user sharing
typedef enum {
	PSInstallationEvent,
	PSLikeEvent,
	PSCustomEvent,
} PSEventType;

@class PSSocialNetworks;
@class PSPinkelStarServer;

@interface PSMainViewController : UIViewController 
<UITextFieldDelegate, PSPermissionViewDelegate, PSSettingsViewControllerDelegate, PSPinkelStarServerDelegate, PSMailViewControllerDelegate> {
	
	id<PSMainViewControllerDelegate> _psMaindDelegate;
	
	// The PinkelStar server object
	PSPinkelStarServer *psServer;	
	
	// All supprted social networks
	PSSocialNetworks *supportedNetworks;
	
	UIView *_mainView;
	
	// MAIN UI Elements and sharing data
	// 1. The user typed message
	UITextField *userMessage;
	// 2. The type of event share/like, set by the developer
	PSEventType _eventType;
	
	//3. The custom share message. Set by the developer, defaults to share/like
	UILabel *_customShareMessageLabel;
	NSString *_customShareMessageText;
	
	//4. A content url. Set by the developer.
	//   can be used to share stuff that's available on the web
	// Be aware that it replaces your landing page url in the share message on Twitter
	NSURL *_contentURL;
	
	// The app icon, set by the developer during registration at www.pinkelstar.com/
	UIImageView *_appIconView;
	
	// The social network buttons
	NSMutableArray *_socialNetworkButtons;
	
	// The scroll view that holds the buttons
	UIScrollView *_buttonScrollView;
	UIView *_buttonView;
	
	// The webview used to gather all Social Network permissions from the user
	UIWebView *permissionView;
	
	UIButton *_cancelButton;
	UIButton *_prefButton;
	UIButton *_publishButton;
	UIImageView *_publishButtonShine;

	// The blocker view is used to show the user when we are awaiting a server response
	UIView *_blockerView;
	UILabel *_blockerLabel;
}

//the delegate
@property(nonatomic,assign) id<PSMainViewControllerDelegate> psMainDelegate;

// main view
@property (nonatomic, retain) IBOutlet UIView *_mainView;
@property (nonatomic, retain) IBOutlet UIImageView *_appIconView;
@property (nonatomic, retain) IBOutlet UIScrollView *_buttonScrollView;
@property (nonatomic, retain) IBOutlet UIButton *_cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *_publishButton;
@property (nonatomic, retain) IBOutlet UIImageView *_publishButtonShine;
@property (nonatomic, retain) IBOutlet UIButton *_prefButton;
@property (nonatomic, retain) UIWebView *permissionView;
@property (nonatomic, retain) NSMutableArray *socialNetworkButtons;

// Sharing data
@property (nonatomic, retain) IBOutlet UITextField *userMessage;
@property (nonatomic, retain) IBOutlet UILabel *_customShareMessageLabel;
@property (nonatomic, retain) NSString *_customShareMessageText;
@property (nonatomic) PSEventType eventType;
@property (nonatomic, retain) NSURL *contentURL;

// The Social Network intelligence lies with the PinkelStar Server
@property (nonatomic, retain) PSPinkelStarServer *psServer;
@property (nonatomic, retain) PSSocialNetworks *supportedNetworks;

// Returns the current version nr of the PSPinkelStar UI code
+ (NSString *) version;

// customization of the message that the user will share with friends
// Set this to make sure the library shows the correct message type
// Default == PSInstallationEvent: I just downloaded <app name>
// PSLikeEvent: I like <app name>
// PSCustomEvent : custom set by the developer: <username> <custom message> 
// be aware that on Twitter the message
// is limited to 50 chars max.
-(void)setEventTypePS:(PSEventType) eventTypePS;
// The developer can set a custom event message (instead of I like <app_name>,
// or I just downloaded <app_name>
-(void)addCustomShareMessage:(NSString *) msg;

// The developer can set a custom content URL that is shared
-(void)addContentURL:(NSURL *) url;

// button and textfield callbacks
-(IBAction) cancelButtonPressed;
-(IBAction) publishButtonPressed;
-(IBAction) prefButtonPressed;
-(IBAction) textFieldDoneEditing:(id)sender;
-(IBAction)backgroundTap:(id)sender;

// just to prevent the compiler from warning
-(void) publishPS;

@end
