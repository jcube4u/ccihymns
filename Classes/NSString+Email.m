//
//  NSString+Email.m
//  PixelMags
//
//  Created by Ashley Mills on 22/07/2009.
//

#import "NSString+Email.h"

@implementation NSString (Email)

- (BOOL) isValidEmailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject: self];
}


@end
