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
//  PSPinkelStarServerDelegate.h
//  pinkelstar

#import <Foundation/Foundation.h>
@class PSPinkelStarServer;

@protocol PSPinkelStarServerDelegate <NSObject>

@optional
// As soon as the server has finised initialization this is called
// useful to update the main view
-(void) psInitFinished:(PSPinkelStarServer *)server;
// Gets called as soon as the server request to publish has been send away
-(void) psPublishRequestSend:(PSPinkelStarServer *) server;
// Gets called as soon as the server has actually responded to a server publish request
-(void) psDidPublish:(PSPinkelStarServer *) psServer;
// Gets called if a server request somehow failed
-(void) psServerRequestFailed:(PSPinkelStarServer *) server;
// Gets called if a server request is finished
-(void) psServerRequestFinished:(PSPinkelStarServer *) server;
// Gets called if the server has provided us with a social network icon
-(void) psServerRequestSocialNetworkIconLoaded:(PSPinkelStarServer *) server;

// Reachabibility
// This fires if the PinkelStar server cannot be reached
-(void) psServerNotAvailable:(PSPinkelStarServer *) server;
// This fires if we do not detect Internet on the phone
-(void) psInternetNotAvailable:(PSPinkelStarServer *) server;

// Unknown Application Key or Secret
// ENTER your registration details in the pinkelstar.plist.
// Otherwise the PinkelStar server will not handle your requests
//
// You can obtain an ApplicationKey and Secret by registering your app at
// www.pinkelstar.com
-(void) psInvalidApplicationKeySecret:(PSPinkelStarServer *) server;

@end
