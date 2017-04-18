//
//  UIDevice+Multitasking.m
//  Mahima
//
//  Created by Jidh on 02/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDevice+Multitasking.h"

@implementation UIDevice (Multitasking)

-(BOOL)hasMultitaskingOS {
	BOOL hasMultitasking = NO;
	
	if ([self respondsToSelector:@selector(isMultitaskingSupported)]) {
		hasMultitasking = [self isMultitaskingSupported];
	}	
	
	return hasMultitasking;
}

@end
