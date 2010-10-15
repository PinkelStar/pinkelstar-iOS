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
//  PSMailViewController.m
//  pinkelstar
//
//  Created by Alexander van Elsas on 10/8/10.
#import "PSMailViewController.h"


@implementation PSMailViewController
@synthesize psMailDelegate = _psMailDelegate;
@synthesize body = _body, subj = _subj, data = _data, image = _image, urlString = _urlString, fileName = _fileName, mimeType = _mimeType, appName = _appName;

// if the iPhone/iPad is not set up for Mail, this will return NO and the viewController will never display
+ (BOOL)canMail
{
	return [MFMailComposeViewController canSendMail];
}

-(void) sendDidFinish
{
	DebugLog(@"Sending of e-mail succeeded");
	if ([_psMailDelegate respondsToSelector:@selector(psMailSendDidFinish:)])
		[_psMailDelegate psMailSendDidFinish:self];
	else
		DebugLog(@"PSMailViewController: _psMailDelegate doesn't respond to psMailSendDidFinish?");	
}

-(void) sendDidCancel
{
	DebugLog(@"Sending of e-mail was canceled");
	
}

-(void) sendDidFail
{
	DebugLog(@"Sending of e-mail Failed");
	
}

- (id)init
{
	if (self = [super initWithNibName:nil bundle:nil])
	{
		self.mailComposeDelegate = self;
		
		//self.modalPresentationStyle = UIModalPresentationFormSheet;
		//self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		
		// Make sure you set the data of the e-mail before you call sendMail
		// e.g. [mailViewController setBody:@"whatever the body text needs to be"
		// Recipe
		// 1. init
		// 2. set mail data
		// 3. setupMailView
		// 4. pop up the controller

	}
	return self;
}

-(BOOL) setupMailView
{
	if(![MFMailComposeViewController canSendMail])
	   return NO;
	   
	if (_urlString)
	{			
		if (_body != nil)
			_body = [_body stringByAppendingFormat:@"<br/><br/>%@", _urlString];		
		else
			_body = _urlString;
	}
		
	if (_data)
	{
		NSString *attachedStr = [NSString stringWithFormat:@"Attached: %@", _fileName];
			
		if (_body != nil)
			_body = [_body stringByAppendingFormat:@"<br/><br/>%@", attachedStr];
			
		else
			_body = attachedStr;
			
		[self addAttachmentData:_data mimeType:_mimeType fileName:_fileName];
	}
		
	if (_image)
		[self addAttachmentData:UIImageJPEGRepresentation(_image, 1) mimeType:@"image/jpeg" fileName:@"Image.jpg"];		

	if (_body == nil)
		_body = @"";
		
	_body = [_body stringByAppendingString:@"<br/><br/>"];
	_body = [_body stringByAppendingFormat:@"Shared from %@", _appName];

	[self setSubject:_subj];
	[self setMessageBody:_body isHTML:YES];

	return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	switch (result) 
	{
		case MFMailComposeResultSent:
			[self sendDidFinish];
			break;
		case MFMailComposeResultSaved:
			[self sendDidFinish];
			break;
		case MFMailComposeResultCancelled:
			[self sendDidCancel];
			break;
		case MFMailComposeResultFailed:
			[self sendDidFail];
			break;
	}
}

-(void) dealloc
{
	[super dealloc];
}


@end
