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
//  PSMailViewController.h
//  pinkelstar
//
//  Created by Alexander van Elsas on 10/8/10.


#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PSMailViewControllerDelegate.h"

@interface PSMailViewController : MFMailComposeViewController
<MFMailComposeViewControllerDelegate> 
{
	id<PSMailViewControllerDelegate> _psMailDelegate;
	NSString *_body;
	NSString *_subj;
	NSData *_data;
	UIImage *_image;
	NSString *_urlString;
	NSString *_fileName;
	NSString *_mimeType;
	NSString *_appName;
}

@property(nonatomic, retain) id<PSMailViewControllerDelegate> psMailDelegate;
@property(nonatomic, retain) NSString *body;
@property(nonatomic, retain) NSString *subj;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *urlString;
@property(nonatomic, retain) NSString *fileName;
@property(nonatomic, retain) NSString *mimeType;
@property(nonatomic, retain) NSString *appName;

-(BOOL) setupMailView;

@end
