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
//  PSSocialNetworks.h
//  pinkelstar

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// This is a local copy of the server info related to the social
// networks that are supported
// We maintain a list of social networks that the user has selected
// and a list of network we have permission to publish too
@interface PSSocialNetworks : NSObject {
	// pairs of <networkName, (bool) is_selected>
	NSMutableDictionary *selectedSocialNetworkList;
	
	// If we have permission to publish AND the user has pressed the Publish button
	// we start keeping track of networks in this list. This ensures
	// that we don't publish more than once to a network
	// pairs of <networkName, (bool) will_publish>
	NSMutableDictionary *willPublishToSocialNetworkList;
}

@property (nonatomic, retain) NSMutableDictionary *selectedSocialNetworkList;
@property (nonatomic, retain) NSMutableDictionary *willPublishToSocialNetworkList;

// supported social networks
// When the server sends us the list of supported networks we call this
// to copy that list locally
-(void) updateSocialNetworks:(NSArray *) networkList;
//convenient getters
-(NSArray *) getSupportedSocialNetworks;
-(NSString *) getNetworkNameFromIndex:(NSUInteger) theIndex;
-(NSString *) getNextSelectedSocialNetwork;
// returns NSNotFound if object not found
-(NSUInteger) getIndexFromNetworkName:(NSString *) networkName;
-(int) numberOfSupportedSocialNetworks;

// Social Network selection
-(BOOL) isSocialNetworkSelected:(NSString *) networkName;
-(BOOL) isAnySocialNetworkSelected;
-(void) setSocialNetworkSelection:(NSString *) networkName selected:(BOOL) selected;

// Keep track of what networks w have permission to publish too
-(void) setWillPublishToNetwork:(NSString *) networkName done:(BOOL)done;

// returns an array with all networknames that have been marked to publish too
// nil if none were selected
-(NSArray *) getListOfNetworksWillPublish;
// this resets the list of Networks that we want to publish to to nil
-(void) willPublishNow;
 
@end