//
//  NSString+Documents.m
//  MahimaApp
//
//  Created by Ashley Mills on 20/08/2009.

//

#import "NSString+Documents.h"

@implementation NSString (Documents)

+ (NSString *) documentsFolder
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *) documentsPathForFile: (NSString *) file
{
	return [[NSString documentsFolder] stringByAppendingPathComponent: file];
}

@end
