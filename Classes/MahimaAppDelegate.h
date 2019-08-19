//
//  MahimaAppDelegate.h
//  Mahima
//
//  Created by Jidh George on 19/07/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


#define SharedAdBannerView ((MahimaAppDelegate *)[[UIApplication sharedApplication] delegate]).adBanner

@interface MahimaAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate,UIAccelerometerDelegate> {
	UIWindow *window;
	
	ModuleViewController * moduleViewController;
	
	NetworkStatus remoteHostStatus;
	NSTimeInterval updateInterval;
}

- (void) getModuleNames;
- (void) checkUserDetails;
- (void) updateStatus;


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property NetworkStatus remoteHostStatus;

@end

