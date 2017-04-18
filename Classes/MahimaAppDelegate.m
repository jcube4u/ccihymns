//
//  MahimaAppDelegate.m
//  Mahima
//
//  Created by Jidh George on 19/07/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MahimaAppDelegate.h"



#import "AppInfo.h"

#import "Module.h"
#import "Constants.h"
#import "FFSAPICaller.h"
#import "Database.h"
#import "NSString+Documents.h"

static int networkChecks = 0;

NSString * const kSessionKey			= @"sessionKey";

#define REACHABILITY_ALERT 3001
#define BETWEEN(arg, v1, v2) ((arg >= v1) && (arg <= v2 ))

@implementation MahimaAppDelegate

@synthesize window;
//@synthesize navigationController;
@synthesize remoteHostStatus;

#pragma mark -
#pragma mark Application lifecycle

+ (void)initialize
{
}

#pragma mark -
#pragma mark UIApplication Lifecycle Methods

-(void)prepareApplication:(NSURL*)url {

       @autoreleasepool {
           [[Database instance] initializeDatabase];
       }
//	[pool drain];
}
//*******************************************************
//* awakeFromNib
//*
//* 
//*******************************************************
- (void) awakeFromNib
{
    [super awakeFromNib];
	[[Reachability sharedReachability] setHostName: @"google.co.uk"];
	[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled: YES];
	[self updateStatus];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
}	

//*******************************************************
//* applicationDidFinishLaunching:
//*
//* 
//*******************************************************
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	[[NSUserDefaults standardUserDefaults] setObject: nil forKey: kSessionKey];
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
	
    CGFloat topInset = self.window.frame.size.height * 0.2125f;

    //*********************************************************
	//* Create array for modules and assign to module controller
	//*********************************************************
	
    
	modules = [[NSMutableArray alloc] init];
	
	[self getModuleNames];
	
    
	moduleViewController = [[ModuleViewController alloc] initWithTopInset: topInset 
															borderSpacing: 4.0
													 maxHorizontalButtons: 3 
                                                          modules: modules];
	
    //UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:moduleViewController];
    
    [self.window setRootViewController:moduleViewController];
	
	[self checkUserDetails];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
        }
        if(result.height == 568)
        {
            // iPhone 5
            CGRect frame =self.window.frame;
            frame.size.height = result.height ;
            self.window.frame =  frame;
            self.window.backgroundColor = [UIColor yellowColor];
        }
    }
    [window addSubview: moduleViewController.view];
    [window makeKeyAndVisible];


	// in case it was deferred because we started in the background
    @autoreleasepool {
        [[Database instance] initializeDatabase];
    }
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self readFromFile];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	moduleViewController = nil;
	modules  = nil;
	window  = nil;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (alertView.tag == REACHABILITY_ALERT) {
		if ([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString: @"Exit"])
			exit (0);
	}
	
}



#pragma mark -
#pragma mark Other methods
- (void) getModuleNames
{
	[modules removeAllObjects];
	
	for (NSDictionary * moduleDict in [[NSBundle mainBundle] objectForInfoDictionaryKey: @"ModuleListLanguages"]) {
		
		position pos = {[[moduleDict objectForKey: @"positionX"] intValue], [[moduleDict objectForKey: @"positionY"] intValue]};
		Module * module = [[Module alloc] initWithTitle: [moduleDict objectForKey: @"title"]
													url: [moduleDict objectForKey: kModuleUrl]
												   icon: [UIImage imageNamed: [moduleDict objectForKey: @"icon"]]
											 controller: [moduleDict objectForKey: @"controller"]
											   position: pos];
		[modules addObject: module];
		module = nil;
	}
}

- (void) checkUserDetails
{
	
	return;
	
}

//*******************************************************
//* updateStatus
//*
//* 
//*******************************************************
- (void)updateStatus
{
    self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
    
	[[AppInfo sharedInfo] setRemoteHostStatus: self.remoteHostStatus];
	
    switch (self.remoteHostStatus)
    {
        case NotReachable:
            NSLog(@"Status changed - host not reachable");
            break;
            
        case ReachableViaCarrierDataNetwork:
            NSLog(@"Status changed - host reachable via carrier");
            break;
            
        case ReachableViaWiFiNetwork:
            NSLog(@"Status changed - host reachable via wifi");         
            break;
            
        default:
            NSLog(@"Status changed - some new network status");
            break;
	}
	
	if (++networkChecks == 2) {
		if (self.remoteHostStatus == NotReachable) {
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: [NSString stringWithFormat: @"App needs a network connection to load the latest data."] 
																 message: @"Please connect to the network." 
																delegate: self 
													   cancelButtonTitle: @"Exit" 
													   otherButtonTitles: @"OK", nil];
			alertView.tag = REACHABILITY_ALERT;
			[alertView show];
			alertView = nil;
		} 
	} 
}


#pragma mark -
#pragma mark NSNotification methods
//*******************************************************
//* 
//*
//* 
//*******************************************************
- (void)reachabilityChanged:(NSNotification *)notification
{
    [self updateStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application {
   // [[Beacon shared] endBeacon];
//    NSLog(@"Exiting Application with device id: %@", [UIDevice currentDevice].uniqueIdentifier);
}

-(void)readFromFile
{
	///// Obtain the settings for the page
	NSArray *paths = NSSearchPathForDirectoriesInDomains
	(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//make a file name to write the data to using the
	//documents directory:
	BOOL isDir;
	NSString *path= [documentsDirectory stringByAppendingString:@"/settings.plist"];
	NSFileManager *fileManager  = [NSFileManager defaultManager];
	
	NSDate *savedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoadedDate_settings"];
	BOOL refreshData = NO;
	if(savedDate)
	{
		int elapsedTime = -[savedDate timeIntervalSinceNow];
		/// Is the last loaded data older than a  30 days
		if(elapsedTime > (24*60*60 *0))
		{
			refreshData = YES;
		}
	}
	else
		refreshData = YES;
	
    if([fileManager fileExistsAtPath:path isDirectory:&isDir]  )
	{
		NSArray *settingsDataArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    	
		for (NSMutableDictionary * infoDict in settingsDataArray) {
			
			NSString *attribute =  [infoDict objectForKey: @"attribute"] ;
            
            if([attribute isEqualToString:@"ListUpdateVersion"]){
                NSString *versionNum = [infoDict objectForKey: @"versionNumber"];
				if(versionNum)
                    [[NSUserDefaults standardUserDefaults] setObject:versionNum forKey:@"SavedListVersionNumber"];
			}
		}
	}
    
	if(refreshData)
	{
		[self performSelector:@selector(getSettings)  withObject:nil afterDelay:1.00f];
	}
}

-(void)getSettings
{
	NSError *error = nil;
	NSString * notificationName = [[FFSAPICaller sharedCaller] getSettings: &error];
	if (!error)
	{
		//unableToConnect = YES;
		[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(settingsCallback:) name: notificationName object: nil];
	} else
		NSLog(@"%@",[error localizedDescription]);
	
    
}

- (void) settingsCallback: (NSNotification *) notification
{
	NSArray * data = [[notification userInfo] objectForKey: @"result"];
	NSMutableArray *array = [NSMutableArray array];	
	for (NSMutableDictionary * countryDict in data) {
        NSMutableDictionary * dict = nil;

        if([countryDict objectForKey: @"ListUpdateVersion"] )
        {
            [dict setObject:[countryDict objectForKey: @"versionNumber"] forKey: @"versionNumber"];
        }
        
        if(dict)
        {
            [array addObject:dict];
            
        }
        NSString *string = [countryDict objectForKey: @"attribute"];
        if([string isEqualToString:@"ListUpdateVersion"]){
            NSString *versionNum = [countryDict objectForKey: @"versionNumber"];

            NSString *savedVersionNum = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedListVersionNumber];
//            NSLog(@"New Data Version %@  -> %@",savedVersionNum,versionNum);
            if(versionNum)
                [[NSUserDefaults standardUserDefaults] setObject:versionNum forKey:kSavedListVersionNumber];
            if(!savedVersionNum  || ![versionNum isEqualToString:savedVersionNum] )
            {
//                NSLog(@"Data Version Changed  -> %@",versionNum);
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kListVersionChanged];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kListUpdatedOnClientForEnglish];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kListUpdatedOnClientForYoruba];
            }
            else {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForEnglish] boolValue] &&
                   [[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForYoruba] boolValue])
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kListVersionChanged];
            }
            
            
        }
	}
	
	NSString * docsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString * cityFilePath = [docsFolder stringByAppendingPathComponent: @"settings.plist"];
	[array writeToFile: cityFilePath atomically: YES];
	
	
	NSDate *cutOffDate =  [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject: cutOffDate forKey: @"lastLoadedDate_settings"];
    
}


@end

