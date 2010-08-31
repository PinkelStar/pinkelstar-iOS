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
//  PSPermissionView.h
//  pinkelstar

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PSPermissionViewDelegate.h"

@protocol PSPermissionViewDelegate;

@interface PSPermissionView : UIView 
<UIWebViewDelegate> {
	id<PSPermissionViewDelegate> _delegate;
	NSURL* _loadingURL;
	UIWebView* _webView;
	UIActivityIndicatorView* _spinner;
	UIImageView* _iconView;
	UILabel* _titleLabel;
	UIButton* _closeButton;
	UIDeviceOrientation _orientation;
	BOOL _showingKeyboard;
	NSString *_networkName;
	NSString *_sessionKey;
}

@property(nonatomic,assign) id<PSPermissionViewDelegate> delegate;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,retain) NSString* networkName;
@property(nonatomic,retain) NSString* sessionKey;

// Create without displaying it
- (id)initWithDelegate:(id)delegate;
// display at top of key window
- (void)show;

//Hides the view and notifies delegates of success or cancellation.
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

// Hides the view and notifies delegates of an error.
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;

//Subclasses may override to perform actions just prior to showing the dialog.
- (void)dialogWillAppear;

//Subclasses may override to perform actions just after the dialog is hidden.
- (void)dialogWillDisappear;

//Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
- (void)dialogDidSucceed:(NSURL*)url;

@end

