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
//  PSShareButton.h
//  pinkelstar

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PSShareButtonDelegate.h"


// which button style
typedef enum {
	PSShareButtonStyleSmallBlack,
	PSShareButtonStyleSmallGrey,
	PSShareButtonStyleSmallPink,
	PSShareButtonStyleSmallPinkShine,
	PSShareButtonStyleMediumBlack,
	PSShareButtonStyleMediumGrey,
	PSShareButtonStyleMediumPink,
	PSShareButtonStyleMediumPinkShine,
	PSShareButtonStyleLargeBlack,
	PSShareButtonStyleLargeGrey,
	PSShareButtonStyleLargePink,
	PSShareButtonStyleLargePinkShine,
	PSLikeButtonStyleSmallBlack,
	PSLikeButtonStyleSmallGrey,
	PSLikeButtonStyleSmallPink,
	PSLikeButtonStyleSmallPinkShine,
	PSShareButtonStyleCustom,
} PSShareButtonStyle;


// Standard buttton that can be used to start the sharing process
@interface PSShareButton : UIControl {
	id<PSShareButtonDelegate> _delegate;
	
	PSShareButtonStyle _style;
	UIImageView *_imageView;
	NSString *_customImageName;
	NSString *_customHighlightedImageName;
	UIImageView *_pinkelStarIconView;
	UILabel *_buttonTitle;
	UIFont *_buttonTitleFont;
	UIColor*_buttonTitleColor;
	BOOL _pinkelStarIcon;
	
}
//the delegate
@property(nonatomic,assign) id<PSShareButtonDelegate> delegate;

@property(nonatomic) PSShareButtonStyle style;
@property(nonatomic, retain) NSString *customImageName;
@property(nonatomic, retain) NSString *customHighlightedImageName;
@property(nonatomic, retain) UILabel *buttonTitle;
@property(nonatomic, retain) UIFont *buttonTitleFont;
@property(nonatomic, retain) UIColor *buttonTitleColor;
@property(nonatomic, retain) UIImageView *pinkelstarIconView;

-(void)setCustomButtonImageName:(NSString *)imageName;
-(void)setCustomButtonHighlightedImageName:(NSString *)imageName;
// Call this if you have your own custom button, but you would like to use the
// PinkelStar icon on it
-(void)usePinkelStarIcon:(BOOL)use;

- (void)setStyle:(PSShareButtonStyle)style;

-(void) setButtonPosition:(CGPoint) p;
-(CGSize) getButtonSize;

@end