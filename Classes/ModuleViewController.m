


//  ModuleViewController.m
#import "ModuleButtonController.h"
#import "InfoViewController.h"
#import "Module.h"
#import "AppInfo.h"
#import "Constants.h"
#import "FFSAPICaller.h"
#import "Database.h"
#import "NSString+Documents.h"
#import <UIKit/UIKit.h>

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define RANDOM_SEED() srand(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define BETWEEN(arg, v1, v2) ((arg >= v1) && (arg <= v2 ))


NSString * const kHideButtons = @"kHideButtons";
NSString * const kShowButtons = @"kShowButtons";
NSString * const kLaunchModule = @"kLaunchModule";
NSString * const kCloseModule = @"kCloseModule";

@interface ModuleViewController()
@property(nonatomic,strong)    InfoViewController * infoController;
-(void)showMenu;
@end

@implementation ModuleViewController
@synthesize modules,navController,adLabel, centerTextLabel,timer,delayTimer,adText,centerText,detectLink,
webPageLink;//,delegate;
@synthesize infoController = _infoController;

- (id) initWithTopInset: (CGFloat) theTopInset 
		  borderSpacing: (CGFloat) theBorderSpacing 
   maxHorizontalButtons: (int) maxHorizButtons
				modules: (NSArray *) theModules
{
	self = [super init];
	if (self != nil) {
		topInset = theTopInset;
		borderSpacing = theBorderSpacing;
		maxHorizontalButtons = maxHorizButtons;
		modules = theModules;
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	modules = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.5];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
            CGRect frame =self.view.frame;
            frame.size.height = result.height;
            self.view.frame =  frame;
            //self.view.backgroundColor = [UIColor grayColor];
        }
    }
    
    
}

- (void) viewWillAppear: (BOOL) animated 
{
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:frank@wwdcdemo.example.com"]];
	[super viewWillAppear: YES];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"Memory warning for class %@", [self class]);
	NSLog(@"REMOVING SCROLL VIEW" );

	
    [super didReceiveMemoryWarning];
	
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
		if(elapsedTime > (24*60*60 *1))
		{
			refreshData = YES;
		}
	}
	else
		refreshData = YES;
	
    if([fileManager fileExistsAtPath:path isDirectory:&isDir]  )
	{
		NSArray *settingsDataArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
            //self.countries = tempArray;       
		adText = [[NSMutableArray alloc] init];
		centerText =  [[NSMutableArray alloc] init];
		
		for (NSMutableDictionary * infoDict in settingsDataArray) {
			
			NSString *attribute =  [infoDict objectForKey: @"attribute"] ;
            if([attribute isEqualToString:@"ListUpdateVersion"]){
                NSString *versionNum = [infoDict objectForKey: @"versionNumber"];
				if(versionNum)
				 [[NSUserDefaults standardUserDefaults] setObject:versionNum forKey:@"SavedListVersionNumber"];
			}
		}
		if([centerText count] > 1)
		{
			srand(time((time_t *)NULL));
			int randValue =  (rand() % ([centerText count]-1)) + 1;
			centerTextLabel.text = [[centerText objectAtIndex:randValue] objectForKey:@"description"];
		}
			//releaseMapCities = YES;
	}

	if(refreshData)
	{
		self.timer = [NSTimer scheduledTimerWithTimeInterval: 3.001 target: self selector: @selector(getSettings) userInfo: nil repeats: NO];
		[UIView beginAnimations: kLaunchModule context: nil];
		[UIView setAnimationDuration: 0.5];
		[navController.view setAlpha: 1.0];
		[UIView commitAnimations];
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
-(void)showMenu
{

    self.modules =  [[AppInfo sharedInfo] getModuleNames:kModuleListLanguages];
    [self layoutButtons];
}

-(void) updateLanguageSelection:(id)sender
{
    if(sender)
    {
        
        UIButton * button = (UIButton *) sender;
        NSString * selectedLanguage = [(Module*)[modules objectAtIndex: button.tag] title];
        [[AppInfo sharedInfo] setDefaultsValueForKey:kSavedLanguage withValue:selectedLanguage];
    }
}

#pragma mark -
#pragma mark Action methods
- (void) launchModule: (id) sender
{

    [self updateLanguageSelection:sender];
	/// TODO Check for memory leak for navcontroller
	//* Create a nav controller with the module as the root contoller
	UINavigationController * oldnavController = [controller navigationController];
	if(oldnavController)
	{	[[Database instance] initializeDatabase];
		oldnavController = nil;
	}
	
	//* Get the module class name from the module list
	UIButton * button = (UIButton *) sender;
	NSString * controllerClassName = [(Module*)[modules objectAtIndex: button.tag] controller];
	
	Class controllerClass = NSClassFromString(controllerClassName);
	
	//* Alloc/init an instance of the module's class
	controller = [controllerClass alloc] ;
	[controller setTitle: [[modules objectAtIndex: button.tag] title]];
	
	
	navController = [[UINavigationController alloc] initWithRootViewController: controller];
	[navController setNavigationBarHidden:YES];
	[navController.view setAlpha: 0.0];
	[controller viewWillAppear: YES];
	
	[self.view addSubview: navController.view];
	
	[controller viewDidAppear: YES];
	controller  = nil;
		
	[UIView beginAnimations: kLaunchModule context: nil];
	[UIView setAnimationDuration: 0.5];
	[navController.view setAlpha: 1.0];
	[UIView commitAnimations];

}
-(NSString *) GetUrl:(NSString *)moduleName tagId:(NSInteger) tagId
{
	NSString *urlString = nil;
	
	if([moduleName isEqualToString:@"MUSE STORE"])
	{
		NSString *sessionKey = nil;
		sessionKey = [[NSUserDefaults standardUserDefaults] objectForKey: kSessionKey];
		/// We didnt manage to get the session id so sign in the respective class
		if(sessionKey == nil)
			urlString = [NSString stringWithFormat:@"%@=", [[modules objectAtIndex: tagId] url]];
		else
			urlString = [NSString stringWithFormat:@"%@=%@", [[modules objectAtIndex: tagId] url], sessionKey];
		NSLog(@"URL - %@",urlString);
	}
	else
	{
	   urlString  =  [NSString stringWithFormat:@"%@",[[modules objectAtIndex: tagId] url]];
	}
	
	return urlString;
	
}

- (void) closeModule: (id) module
{
	int posy = self.view.frame.origin.y; 
	if(posy != 0)
	{

		[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	}	
	
	[UIView beginAnimations: kCloseModule context: (void*)module];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration: 0.5];
	
	[[[module navigationController] view] setAlpha: 0.0];
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Other methods
- (void) setModules: (NSArray *) newModules
{
	modules = newModules;
	[self layoutButtons];
	
}

- (void) layoutButtons
{
	for (int i = 0; i < [modules count]; i++) {
		Module * module = [modules objectAtIndex: i];
		
		//*******************************************************
		//* Create module border image view
		//*******************************************************
		ModuleButtonController * buttonController = [[ModuleButtonController alloc] initWithModuleLauncher: self
																							   buttonImage: module.icon 
																									 label: module.title 
																									   tag: i
                                                                                                  fontSize:28];

		CGRect buttonFrame = buttonController.view.frame;
		
		CGFloat leftInset = (self.view.frame.size.width - (maxHorizontalButtons * buttonFrame.size.width) - 
							 ((maxHorizontalButtons - 1) * borderSpacing)) / 2.0;
		
		buttonController.view.frame = CGRectMake(leftInset + module.modulePosition.x * (buttonFrame.size.width + borderSpacing), 
												 topInset + module.modulePosition.y * (buttonFrame.size.height + borderSpacing), 
												 buttonFrame.size.width, 
												 buttonFrame.size.height);
		
		buttonController.view.alpha = 0.0;
		buttonController.view.tag = 100;
		[self.view addSubview: buttonController.view];
		
		buttonController = nil;
	}
	
	[UIView beginAnimations: @"ShowButtons" context: nil];
	[UIView setAnimationDuration: 1.0];
	for (UIView * view in self.view.subviews) {
		if (view.tag == 100)
			view.alpha = 1.0;
	}
	[UIView commitAnimations];
}
	
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString: kCloseModule]) {
		[navController.view removeFromSuperview];
		navController = nil;
		controller = nil;

	}
}


#pragma mark -
#pragma mark Rotation methods
//*******************************************************
//* shouldAutorotateToInterfaceOrientation:
//*
//* 
//*******************************************************
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if (interfaceOrientation == UIDeviceOrientationPortrait) 
		return YES;
	else 
		return NO;
}

-(void)allowChangeOrientation
{
	allowRotation = YES;
}
//*******************************************************
//* HandleInfo Page
//*
//* 
//*******************************************************
- (void) HandleInfoPage: (NSNotification *) notification
{
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[infoPageViewController.view removeFromSuperview];
		infoPageViewController = nil;

}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	

}

-(IBAction)infoButtonTapped:(id)sender
{
    if(nil==self.infoController)
    {     
        self.infoController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
       
        self.infoController.delegate = self;
    }
	CGRect frame = self.infoController.view.frame;
    frame.origin.y = 20;;
    self.infoController.view.frame = frame;
    
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                    animations:^ { [self.view addSubview:self.infoController.view]; }
                    completion:nil];


    
}
-(void)dismissInfoView
{
    
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                    animations:^ {
                        
                        [self.infoController.view removeFromSuperview];
                        
                        self.infoController.delegate = nil;
                        
                        self.infoController = nil;
                    }
                    completion:nil];
  
}

@end
