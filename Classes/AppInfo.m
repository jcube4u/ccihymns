//
//  AppInfo.m
//  MahimaApp
//
//  Created by Jidh on 23/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppInfo.h"
#import "FFSAPICaller.h"
#import "NSString+Documents.h"
#import "Constants.h"
#import "Module.h"
#import <CoreLocation/CoreLocation.h>

NSString * const kModuleUrl = @"url";

static id _appInfo = nil;

@implementation AppInfo


@synthesize remoteHostStatus = _remoteHostStatus;
@synthesize shakenOnce;
+ (id) sharedInfo 
{
	if (!_appInfo) {
		_appInfo = [[AppInfo alloc] init];
	}
	
	return _appInfo;
}

- (id) init
{
	if (self = [super init]) {
		shakenOnce = NO;
		}
	
	return self;
}
- (NSString *) urlForModuleTitle: (NSString *) title
{
	
	NSArray * moduleList = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Module List"];
	
	for (NSDictionary * moduleDict in moduleList) {
		if ([[moduleDict objectForKey: @"title"] isEqualToString: title])
			return [moduleDict objectForKey: kModuleUrl];
	}
	
	return nil;
}


- (NSMutableArray *) getModuleNames:(NSString*)key
{
    NSMutableArray *modules = [NSMutableArray array];
	
	for (NSDictionary * moduleDict in [[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
		
		position pos = {[[moduleDict objectForKey: @"positionX"] intValue], [[moduleDict objectForKey: @"positionY"] intValue]};
		Module * module = [[Module alloc] initWithTitle: [moduleDict objectForKey: @"title"]
													url: [moduleDict objectForKey: kModuleUrl]
												   icon: [UIImage imageNamed: [moduleDict objectForKey: @"icon"]]
											 controller: [moduleDict objectForKey: @"controller"]
											   position: pos];
		[modules addObject: module];
		module = nil;
	}
    
    return modules;
}

#pragma Convinience methods
-(id)getDefaultsValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
-(void)setDefaultsValueForKey:(NSString *)key withValue:(id)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

-(NSString*)toggleSelectedlanguage
{
    NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
    
    if(languageSelected)
    {
        if([languageSelected isEqualToString:kLanguageEnglish])
        {
            [[AppInfo sharedInfo] setDefaultsValueForKey:kSavedLanguage withValue:kLanguageYoruba];
        }
        else
        {
            [[AppInfo sharedInfo] setDefaultsValueForKey:kSavedLanguage withValue:kLanguageEnglish];
        }
    }
    languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
    
    return languageSelected;
}
-(NSInteger)getSelectedLanguageId
{
    NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
 
    NSInteger languageId  = ([languageSelected caseInsensitiveCompare:kLanguageEnglish] == NSOrderedSame) ? kLanguageEnglishID:([languageSelected caseInsensitiveCompare:kLanguageYoruba]== NSOrderedSame ? kLanguageYorubaID : NSNotFound);
    return languageId;
 }

@end
