//
//  PSCommon.h
//  pinkelstar
//
//  Created by Alexander van Elsas on 9/22/10.
//  Copyright 2010 PinkelStar. All rights reserved.
//



// we use this label to ensure we do not conflict with others setting up a debug label
// Make sure you include this header file in your projects' .pch file
// In Project settings add -DPS_DEBUG_MODE to "other C flags" if you want to use this macro
#ifdef PS_DEBUG_MODE
#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... ) 
#endif