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
//  PSPinkelStarServer.h
//  pinkelstar

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PSServerRequestDelegate.h"
#import "PSPinkelStarServerDelegate.h"

// ENTER your registration details in the pinkelstar.plist.
// Otherwise the PinkelStar server will not handle your requests
//
// You can obtain an ApplicationKey and Secret by registering your app at
// www.pinkelstar.com

typedef enum {
	PSSocialNetworkIconSmall,
	PSSocialNetworkIconMedium,
} PSSocialNetworkIconSize;

@class PSReachability;
@class PSSocialNetworks;

@interface PSPinkelStarServer : NSObject 
<PSServerRequestDelegate> {
	id<PSPinkelStarServerDelegate> _delegate;

	NSString *_psSessionKey;
	NSString *_applicationName;
	NSString *_developerName;
	UIImage *_applicationIcon;
	NSMutableArray *_psSocialNetworkList;
	NSMutableDictionary *_psSocialNetworkIcons;
	
	BOOL _developerAccepted;
	NSMutableArray *_canPublishToNetworks;
	NSMutableArray *_serverRequests;
	
	// Code reused from Apple that tells us if there is an internet connection
	// and if the PinkelStar server is available or not
	// renamed to avoid any kind of linking conflict
	PSReachability* hostReach;
    PSReachability* internetReach;
    PSReachability* wifiReach;
	
	BOOL _initialized; // set to TRUE if the server initalization has been succesfully completed
}

@property (nonatomic, retain) id<PSPinkelStarServerDelegate> delegate;
@property (nonatomic, retain) NSString *applicationName;
@property (nonatomic, retain) UIImage *applicationIcon;
@property (nonatomic, retain) NSString *developerName;
@property (nonatomic, retain) NSString *psSessionKey;
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL developerAccepted;

// Singleton implementation of the PinkelStar server
+ (PSPinkelStarServer *)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (NSUInteger)retainCount;
- (void)release;
- (id)autorelease;

/////////////////////////////////////////////////////////////////////////////////////////////////
//
// PinkelStar Client UTILITY methods, useful for UI
//
/////////////////////////////////////////////////////////////////////////////////////////////////

// returns the version nr of the library
- (NSString *) currentVersion;

// UI information getters
-(NSString*)getApplicationName;
-(NSString*)getDeveloperName;
-(UIImage*)getApplicationIcon;
-(void)downloadCustomImage:(NSString *) imageURLString;
// returns a list of supported social networks
-(NSArray *) getSupportedSocialNetworks;
-(int) numberOfSupportedSocialNetworks;
-(UIImage *) getSocialNetworkIconPS:(NSString *)networkName size:(PSSocialNetworkIconSize)size;


/////////////////////////////////////////////////////////////////////////////////////////////////
//
// PinkelStar Client Server API
//
/////////////////////////////////////////////////////////////////////////////////////////////////

// Do we have user permission to allow PS to publish on his behalf?
-(BOOL) canPublishPS:(NSString *) networkName;
// Publish
-(void) publishPS:(NSString *) userMessage eventMessage:(NSString *) eventMessage contentUrl:(NSURL *)url imageUrl:(NSURL *) imUrl networkList:(NSArray *)networkList;
// Local storage only, this just caches the fact that we just got the permission formt he user in a dialogue locally
// the server already knows this
-(void) storePermissionPS:(NSString *)networkName;
// Tell the server to remove permission keys
-(void) revokePermissionPS:(NSString *)networkName;
// User cancels the PS process. Used for stats purposes
-(void) userCancelsPS;

@end