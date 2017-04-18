//
//  AppInfo.h
//  MahimaApp
//
//  Created by Jidh on 23/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "Reachability.h"

@interface AppInfo : NSObject {

	NetworkStatus _remoteHostStatus;
	BOOL			shakenOnce;

}

+ (id) sharedInfo;

- (NSString *) urlForModuleTitle: (NSString *) title;
- (NSMutableArray *) getModuleNames:(NSString*)key;
@property NetworkStatus remoteHostStatus;
@property BOOL			shakenOnce;

-(id)getDefaultsValueForKey:(NSString *)key;
-(void)setDefaultsValueForKey:(NSString *)key withValue:(id)value;
-(NSString*)toggleSelectedlanguage;
-(NSInteger)getSelectedLanguageId;
@end
	