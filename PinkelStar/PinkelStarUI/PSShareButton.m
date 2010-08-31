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
//  PSShareButton.m
//  pinkelstar

#import "PSShareButton.h"
#import <dlfcn.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static UIAccessibilityTraits *traitImage = nil, *traitButton = nil;

#define kLikeButtonLabel NSLocalizedString(@"Like", @"Like");
#define kShareButtonSmallLabel NSLocalizedString(@"Share", @"Share");
#define kShareButtonMediumLabel NSLocalizedString(@"Share with friends!", @"Share with friends!");
#define kShareButtonLargeLabel NSLocalizedString(@"Share with friends!", @"Share with friends!");

@implementation PSShareButton

@synthesize style = _style;
@synthesize delegate = _delegate;
@synthesize customImageName = _customImageName;
@synthesize customHighlightedImageName = _customHighlightedImageName;
@synthesize buttonTitle = _buttonTitle;
@synthesize buttonTitleFont = _buttonTitleFont;
@synthesize buttonTitleColor = _buttonTitleColor;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

+ (void)initialize {
	if (self == [PSShareButton class]) {
		// Try to load the accessibility trait values on OS 3.0
		traitImage = dlsym(RTLD_SELF, "UIAccessibilityTraitImage");
		traitButton = dlsym(RTLD_SELF, "UIAccessibilityTraitButton");
	}
}

// Temp method needed because Apple hasn't fixed all image functions yet to laod highres images for iPhone 4 when needed
-(UIImage *) getImage:(NSString *) imageName ofType:(NSString *) ofType
{
	
	// iPhone 4 trick, we can remove this as soon as Apple fixes imageWithContentsOfFile to load
	// Highres @2x images automatically
	// iPhone 4	
	if ( [UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 ) 
    {
	    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@", imageName, ofType]];
    }
    else 
    {
	   NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:ofType];
	   return [UIImage imageWithContentsOfFile:imagePath];		
    }
		 
}

// use this to set your frame correctly
-(CGSize) getButtonSize
{
	NSString *imagePath;
	NSArray *arrItems;

	switch (self.style) 
	{
		case PSShareButtonStyleSmallBlack:
		case PSShareButtonStyleSmallGrey:
		case PSShareButtonStyleSmallPink:
		case PSShareButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_black" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_share_button_small_black" ofType:@"png"] size];
			break;
		case PSShareButtonStyleMediumBlack:
		case PSShareButtonStyleMediumGrey:
		case PSShareButtonStyleMediumPink:
		case PSShareButtonStyleMediumPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_black" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_share_button_medium_black" ofType:@"png"] size];
			break;
		case PSShareButtonStyleLargeBlack:
		case PSShareButtonStyleLargeGrey:
		case PSShareButtonStyleLargePinkShine:
		case PSShareButtonStyleLargePink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_black" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_share_button_large_black" ofType:@"png"] size];
			break;
		case PSLikeButtonStyleSmallBlack:
		case PSLikeButtonStyleSmallGrey:
		case PSLikeButtonStyleSmallPink:
		case PSLikeButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_pink" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_like_button_small_pink" ofType:@"png"] size];
			break;
		case PSShareButtonStyleCustom:
			if(_customImageName != nil)
			{				
				arrItems = [_customImageName componentsSeparatedByString:@"."]; // separate extension from filename
				if([arrItems count] > 1)
					imagePath = [[NSBundle mainBundle] pathForResource:[arrItems objectAtIndex:0] ofType:[arrItems objectAtIndex:1]];
				else
					imagePath = [[NSBundle mainBundle] pathForResource:_customImageName ofType:@"png"]; // we try png, if that fails we're dead
				return [[UIImage imageWithContentsOfFile:imagePath] size];
			}
			else
				return CGSizeZero;
			break;
		default:
			return CGSizeZero;
	}	
}

-(CGSize) getButtonIconSize
{
	//NSString *imagePath;
	switch (_style)
	{
		case PSShareButtonStyleMediumGrey:
		case PSShareButtonStyleMediumBlack:
		case PSShareButtonStyleMediumPink:
		case PSShareButtonStyleMediumPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_button_icon_medium" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_button_icon_medium" ofType:@"png"] size];
			break;
		default:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_button_icon_small" ofType:@"png"];
			//return [[UIImage imageWithContentsOfFile:imagePath] size];
			return [[self getImage:@"pinkelstar_button_icon_small" ofType:@"png"] size];
			break;
	}
}

-(CGRect) buttonIconFrame
{
	CGSize buttonSize = [self getButtonSize];
	CGSize buttonIconSize = [self getButtonIconSize];
	
	// center the icon on the y-axis and use the same offset at the left side of the button
	float offset = (buttonSize.height - buttonIconSize.height) / 2.0;
	return	CGRectMake(offset, offset, buttonIconSize.width, buttonIconSize.height);
}

-(UIImage *) buttonIconImage
{
	//NSString *imagePath;
	
	switch (_style) {
		case PSShareButtonStyleMediumGrey:
		case PSShareButtonStyleMediumBlack:
		case PSShareButtonStyleMediumPink:
		case PSShareButtonStyleMediumPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_button_icon_medium" ofType:@"png"];
			// return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_button_icon_medium" ofType:@"png"];
			break;
		default:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_button_icon_small" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_button_icon_small" ofType:@"png"];
			break;
	}
}

- (UIImage*)buttonImage 
{
	NSString *imagePath;
	NSArray *arrItems;
	
	switch (_style) 
	{
		// Share buttons small
		case PSShareButtonStyleSmallBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_black" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_pink" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_pinkshine" ofType:@"png"];
			break;
		// share buttons medium
		case PSShareButtonStyleMediumBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_black" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_pink" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_pinkshine" ofType:@"png"];
			break;
		// share buttons large
		case PSShareButtonStyleLargeBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_black" ofType:@"png"];
			break;
		case PSShareButtonStyleLargeGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleLargePink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_pink" ofType:@"png"];
			break;
		case PSShareButtonStyleLargePinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_pinkshine" ofType:@"png"];
			break;
		// share button custom
		case PSShareButtonStyleCustom:
			if(_customImageName != nil)
			{
				arrItems = [_customImageName componentsSeparatedByString:@"."]; // separate extension from filename
				if([arrItems count] > 1)
					imagePath = [[NSBundle mainBundle] pathForResource:[arrItems objectAtIndex:0] ofType:[arrItems objectAtIndex:1]];
				else
					imagePath = [[NSBundle mainBundle] pathForResource:_customImageName ofType:@"png"]; // we try png, if that fails we're dead
				return [UIImage imageWithContentsOfFile:imagePath];
			}
			else
				return nil;
			break;
		// like buttons
		case PSLikeButtonStyleSmallBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_black" ofType:@"png"];
			break;
		case PSLikeButtonStyleSmallGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_gray" ofType:@"png"];
			break;
		case PSLikeButtonStyleSmallPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_pink" ofType:@"png"];
			break;
		case PSLikeButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_pinkshine" ofType:@"png"];
			break;
			
		default:
			return nil;
			break;
	}
}

- (UIImage*)buttonHighlightedImage 
{
	NSString *imagePath;
	NSArray *arrItems;

	switch (_style) 
	{
			// Share buttons small
		case PSShareButtonStyleSmallBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_black" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_pinkshine" ofType:@"png"];
			break;
		case PSShareButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_small_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_small_pink" ofType:@"png"];
			break;
			// share buttons medium
		case PSShareButtonStyleMediumBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_black" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_pinkshine" ofType:@"png"];
			break;
		case PSShareButtonStyleMediumPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_medium_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_medium_pink" ofType:@"png"];
			break;
			// share buttons large
		case PSShareButtonStyleLargeBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_gray" ofType:@"png"];
			break;
		case PSShareButtonStyleLargeGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_black" ofType:@"png"];
			break;
		case PSShareButtonStyleLargePink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_pinkshine" ofType:@"png"];
			break;
		case PSShareButtonStyleLargePinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_share_button_large_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_share_button_large_pink" ofType:@"png"];
			break;
		// share button custom
		case PSShareButtonStyleCustom:
			if(_customHighlightedImageName != nil)
			{
				arrItems = [_customHighlightedImageName componentsSeparatedByString:@"."]; // separate extension from filename
				if([arrItems count] > 1)
					imagePath = [[NSBundle mainBundle] pathForResource:[arrItems objectAtIndex:0] ofType:[arrItems objectAtIndex:1]];
				else
					imagePath = [[NSBundle mainBundle] pathForResource:_customHighlightedImageName ofType:@"png"]; // we try png, if that fails we're dead
				return [UIImage imageWithContentsOfFile:imagePath];
			}
			else
				return nil;
			break;
			// like buttons
		case PSLikeButtonStyleSmallPink:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_pinkshine" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_pinkshine" ofType:@"png"];
		break;
		case PSLikeButtonStyleSmallGrey:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_black" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_black" ofType:@"png"];
			break;
		case PSLikeButtonStyleSmallBlack:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_gray" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_gray" ofType:@"png"];
			break;
		case PSLikeButtonStyleSmallPinkShine:
			//imagePath = [[NSBundle mainBundle] pathForResource:@"pinkelstar_like_button_small_pink" ofType:@"png"];
			//return [UIImage imageWithContentsOfFile:imagePath];
			return [self getImage:@"pinkelstar_like_button_small_pink" ofType:@"png"];
			break;
			
		default:
			return nil;
			break;
	}
}

-(CGRect) buttonTitleFrame
{
	CGSize buttonSize = [self getButtonSize];
	CGSize buttonIconSize = [self getButtonIconSize];
	
	// we should prob take the font and size out of here
	CGSize labelSize = [_buttonTitle.text sizeWithFont:_buttonTitleFont];
	
	float xIconOffset  = (buttonSize.height - buttonIconSize.height) / 2.0;
	float xOffset = 2.0 * xIconOffset + buttonIconSize.width;
	float yOffset = (buttonSize.height - labelSize.height) / 2.0;
	
	// we need to constrain the button title within the button
	// if needed we'll add an extra line, but if that fails too, we'll truncate
	float xSpace = (buttonSize.width - xOffset);
	float ySpace =  (buttonSize.height -  yOffset);
					 
	if(labelSize.width > xSpace)
	{
		if((labelSize.height * 2) < ySpace)
		{
			// Not a 100% working solution, but it will fit standard PinkelStar cases
			// we add an extra line to the label
			_buttonTitle.numberOfLines = 2;
			// we decrease the font size 1 pt
			if(_buttonTitleFont)
				[_buttonTitleFont release];
			self.buttonTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:(11.0)];
			_buttonTitle.font = _buttonTitleFont;
			// recalculate values
			labelSize = [_buttonTitle.text sizeWithFont:_buttonTitleFont];
			yOffset = (buttonSize.height - 2 * labelSize.height) / 2.0;
			return CGRectMake(xOffset, yOffset, xSpace - xIconOffset, 2 * labelSize.height);
		}
		// adding an extra line is not an option, we truncate
		CGRectMake(xOffset, yOffset, xSpace - xIconOffset, labelSize.height);
	}
	// label fits, no issue then
	return CGRectMake(xOffset, yOffset, labelSize.width, labelSize.height);
}

-(UIColor *) getButtonTitleColor
{
	switch (_style) {
		case PSLikeButtonStyleSmallGrey:
		case PSShareButtonStyleSmallGrey:
		case PSShareButtonStyleMediumGrey:
		case PSShareButtonStyleLargeGrey:
			// set shadow oppposite
			_buttonTitle.shadowColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
			return [UIColor blackColor];
			break;
			
		default:
			// set shadow oppposite
			_buttonTitle.shadowColor = [UIColor grayColor];
			return [UIColor whiteColor];
			break;
	}
}



-(void) setButtonTitle
{
	switch (_style) {
		case PSLikeButtonStyleSmallPink:
		case PSLikeButtonStyleSmallBlack:
		case PSLikeButtonStyleSmallGrey:
		case PSLikeButtonStyleSmallPinkShine:
			_buttonTitle.text = kLikeButtonLabel;
			break;
		case PSShareButtonStyleSmallGrey:
		case PSShareButtonStyleSmallBlack:
		case PSShareButtonStyleSmallPink:
		case PSShareButtonStyleSmallPinkShine:
			_buttonTitle.text = kShareButtonSmallLabel;
			break;
		case PSShareButtonStyleMediumGrey:
		case PSShareButtonStyleMediumBlack:
		case PSShareButtonStyleMediumPink:
		case PSShareButtonStyleMediumPinkShine:
			_buttonTitle.text = kShareButtonMediumLabel;
			break;
		case PSShareButtonStyleLargeGrey:
		case PSShareButtonStyleLargeBlack:
		case PSShareButtonStyleLargePink:
		case PSShareButtonStyleLargePinkShine:
			_buttonTitle.text = kShareButtonLargeLabel;
			break;
			
		default:
			// If it is custom, the label can be overwritten later by the dev
			// for now we do nothing
			break;
	}
}

- (void)updateImage {
	if (self.highlighted) {
		_imageView.image = [self buttonHighlightedImage];
	} else {
		_imageView.image = [self buttonImage];
		if(_style != PSShareButtonStyleCustom)
		{
			_pinkelStarIconView.image = [self buttonIconImage];
			_pinkelStarIconView.frame = [self buttonIconFrame];
			_buttonTitle.frame = [self buttonTitleFrame];
		}
		else {
			[_pinkelStarIconView removeFromSuperview]; // we don't need it anymore
			_pinkelStarIconView = nil;
		}


		[_buttonTitleColor release];
		self.buttonTitleColor = [self getButtonTitleColor];
		_buttonTitle.textColor = _buttonTitleColor;
	}
}

// here we connect the pinkelstar call
- (void)touchUpInside {
	if([_delegate respondsToSelector:@selector(psSharebutonPressed:)])
		[_delegate psSharebutonPressed:self];

}

- (void)initButton {
	_style = PSShareButtonStyleSmallBlack;
	
	_imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	_imageView.contentMode = UIViewContentModeCenter;
	[self addSubview:_imageView];
	
	// add a buttonTitel and an icon
	_pinkelStarIconView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	_pinkelStarIconView.contentMode = UIViewContentModeCenter;
	_pinkelStarIconView.image = [self buttonIconImage];
	[self addSubview:_pinkelStarIconView];
	
	// set the label
	self.buttonTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:(12.0)];
	self.buttonTitleColor = [UIColor whiteColor];
	
	_buttonTitle = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	//_buttonTitle.text = pShareButtonSmallLabel; // this will be set later
	_buttonTitle.font = _buttonTitleFont;
	_buttonTitle.shadowColor = [UIColor grayColor];
	_buttonTitle.shadowOffset = CGSizeMake(-1, -1);
	_buttonTitle.backgroundColor = [UIColor clearColor];
	_buttonTitle.textColor = _buttonTitleColor;
	_buttonTitle.numberOfLines = 1;
	
	[self addSubview:_buttonTitle];
	
	self.backgroundColor = [UIColor clearColor];
	[self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self initButton];
		if (CGRectIsEmpty(frame)) {
			[self sizeToFit];
		}
	}
	
	return self;
}

- (void)awakeFromNib {
	[self initButton];
}

- (void)dealloc {
	[_customImageName release];
	[_customHighlightedImageName release];
	[_buttonTitleFont release];
	[_buttonTitleColor release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (CGSize)sizeThatFits:(CGSize)size {
	return _imageView.image.size;
}

- (void)layoutSubviews {
	_imageView.frame = self.bounds;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self updateImage];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAccessibility informal protocol (on 3.0 only)

- (BOOL)isAccessibilityElement {
	return YES;
}

- (UIAccessibilityTraits)accessibilityTraits {
	if (traitImage && traitButton)
		return [super accessibilityTraits]|*traitImage|*traitButton;
	else
		return [super accessibilityTraits];
}

- (NSString *)accessibilityLabel {
	return NSLocalizedString(@"share with your friends", @"Accessibility label");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public
- (void)setStyle:(PSShareButtonStyle)style 
{
	_style = style;
	
	// depending on the style we need to set the label of the button
	[self setButtonTitle];
	[self updateImage];
}

-(void)setCustomButtonImageName:(NSString *)imageName
{
	if(_customImageName)
		[_customImageName release];
	_customImageName = [imageName copy];
	[self updateImage];
}

-(void)setCustomButtonHighlightedImageName:(NSString *)imageName
{
	if(_customHighlightedImageName)
		[_customHighlightedImageName release];
	_customHighlightedImageName = [imageName copy];
	[self updateImage];
}

-(void) setButtonPosition:(CGPoint) p
{
	self.frame = CGRectMake(p.x, p.y, self.getButtonSize.width, self.getButtonSize.height);
	[self updateImage];
}

@end
