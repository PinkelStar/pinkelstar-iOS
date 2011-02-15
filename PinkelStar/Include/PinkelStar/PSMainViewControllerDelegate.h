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
//  PSMainViewControllerDelegate.h
//  pinkelstar

#import <Foundation/Foundation.h>

@class PSMainViewController;

@protocol PSMainViewControllerDelegate <NSObject>

@optional


//Called as soon as the pinkelstar process is finished
- (void)psFinished:(PSMainViewController *)vController;

// Gets called as soon as the server request to publish has been send away
-(void) psPublishRequestSend:(PSMainViewController *) vController;
// Gets called as soon as the server has actually responded to a server publish request
-(void) psDidPublish:(PSMainViewController *) vController;
// Gets called if a server request somehow failed
-(void) psServerRequestFailed:(PSMainViewController *) vController;
// Gets called if a server request is finished
-(void) psServerRequestFinished:(PSMainViewController *) vController;

// Reachabibility
// This fires if the PinkelStar server cannot be reached
-(void) psServerNotAvailable:(PSMainViewController *) vController;
// This fires if we do not detect Internet on the phone
-(void) psInternetNotAvailable:(PSMainViewController *) vController;
// This fires if we do detect Internet on the phone (possibly after the connection was down before)
-(void) psInternetAvailable:(PSMainViewController *) vController;

// Unknown Application Key or Secret
// ENTER your registration details in the pinkelstar.plist.
// Otherwise the PinkelStar server will not handle your requests
//
// You can obtain an ApplicationKey and Secret by registering your app at
// www.pinkelstar.com
-(void) psInvalidApplicationKeySecret:(PSMainViewController *) vController;

@end
