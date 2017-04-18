
//
//  MenuSelectionViewController.m
//  Mahima
//
//  Created by George, Jidh on 16/01/2013.
//
//

#import "Constants.h"
#import "AppInfo.h"
#import "DataHandler.h"
#import "Database.h"
#import "Module.h"
#import "ModuleButtonController.h"
#import "MenuSelectionViewController.h"
#import <UIKit/UIKit.h>

@interface MenuSelectionViewController ()
@property (nonatomic, strong) DataHandler *handler;
@property (nonatomic, strong) UIActivityIndicatorView * activity;
@property (nonatomic, strong) IBOutlet UILabel        * languageLabel;

@property (nonatomic, assign) BOOL unableToConnect;
-(IBAction)infoButtonTapped:(id)sender;
@end

@implementation MenuSelectionViewController
@synthesize modules = _modules;
@synthesize handler =  _handler;
@synthesize languageLabel = _languageLabel;
@synthesize activity = _activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    topInset = self.view.frame.size.height * 0.347f;

    borderSpacing =  4.0;
    maxHorizontalButtons =  3;
    
    if(!self.handler)
    {
        self.handler = [[DataHandler alloc] initWithDelegate:self];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect titleFrame = CGRectMake(64.0f,70.0f,193.0f,36.0f);
    titleFrame.origin.y =  self.view.frame.size.height * 0.2145f;
    self.languageLabel.frame = titleFrame;
    
    if(maxHorizontalButtons < 1)
        return;

    BOOL isFetching =  [self loadDataIfNeeded];
    
    if(!isFetching)
    {
        if([self loadCategoriesFromDB])
        {
            [self updateViewIfNeeded];
        }
        else
        {
            [self loadDataIfNeeded];
        }
    }
}

-(void)updateViewIfNeeded{
    NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
    
    if(![self.languageLabel.text isEqualToString:[languageSelected uppercaseString]] || self.modules == nil)
    {

        NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
        self.languageLabel.text = [languageSelected uppercaseString];
        NSString *language = [languageSelected isEqualToString:kLanguageYoruba] ? kModuleListYoruba:kModuleListEnglish;
        self.modules = nil;
        self.modules =  [[AppInfo sharedInfo] getModuleNames:language];
        [self layoutButtons];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) layoutButtons
{
    for (UIView * view in self.view.subviews) {
        if(view.tag == 100)
            [view removeFromSuperview];
	}
    
	for (int i = 0; i < [self.modules count]; i++) {
		Module * module = [self.modules objectAtIndex: i];
//		
//		//*******************************************************
//		//* Create module border image view
//		//*******************************************************
        NSString *title = module.title;
        ModuleButtonController * buttonController = [[ModuleButtonController alloc] initWithModuleSelectionLauncher:self buttonImage:module.icon label:title tag:i fontSize:22];
       
		CGRect buttonFrame = buttonController.view.frame;
		
		CGFloat leftInset = (self.view.frame.size.width - (maxHorizontalButtons * buttonFrame.size.width) -
							 ((maxHorizontalButtons - 1) * borderSpacing)) / 2.0;
        CGFloat xPosition = leftInset + module.modulePosition.x * (buttonFrame.size.width + borderSpacing);
        NSLog(@"Left Inset %f pos x %f",leftInset, xPosition);
		buttonController.view.frame = CGRectMake(xPosition,
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



#pragma mark -
#pragma mark Action methods
- (void) launchModule: (id) sender
{
	//* Get the module class name from the module list
	UIButton * button = (UIButton *) sender;
	NSString * controllerClassName = [(Module*)[self.modules objectAtIndex: button.tag] controller];
	
	Class controllerClass = NSClassFromString(controllerClassName);
	
	//* Alloc/init an instance of the module's class
	controller = [controllerClass alloc] ;
	[controller setTitle: [[self.modules objectAtIndex: button.tag] title]];
	
	[controller viewWillAppear: YES];
	
    [self.navigationController pushViewController:controller animated:YES];
	
	[controller viewDidAppear: YES];
	controller  = nil;
    
}
- (void)addActivityIndicator {
    
    if(!self.activity)
    {
        self.activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, 50, 50, 50)];
        self.activity.hidesWhenStopped = YES;
        self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
       self.activity.frame = CGRectMake(ACTIVITY_INDICATOR_LEFTOFFSET, ACTIVITY_INDICATOR_HEIGHT_OFFSET, ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE);
        
        [self.view addSubview: self.activity];


    }
    [self.activity startAnimating];
    self.activity.hidden = NO;
}
/// Load Languages From DB
-(BOOL)loadCategoriesFromDB{
	
	BOOL languagesLoaded =  NO;
	/// Load Languages from DB
	NSMutableArray *categoriesList = [NSMutableArray array];
    
    NSInteger langId  = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSInteger catId =  langId + 1;
	[[Database instance] loadAllSongs:categoriesList withCategoryId:catId];
	if([categoriesList count] > 0){
		return !languagesLoaded;
	}
	DLog(@"%@",categoriesList);
	
	return languagesLoaded;
}

-(BOOL)loadDataIfNeeded
{
    
    BOOL fetching = NO;
    NSDate *savedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoadedDate"];
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
	
	refreshData = ![self loadCategoriesFromDB];
	BOOL versionChanged = [[[NSUserDefaults standardUserDefaults] objectForKey:kListVersionChanged] boolValue];

	if(refreshData  || versionChanged)
	{
        NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
        NSString *language = [languageSelected isEqualToString:kLanguageYoruba] ? kLanguageYoruba:kLanguageEnglish;
        
        //select the opposite language if needed
        if([[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForEnglish] boolValue] &&
           [languageSelected isEqualToString:kLanguageEnglish])
        {
            language = kLanguageYoruba;
        }
        else if([[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForYoruba] boolValue] &&
           [languageSelected isEqualToString:kLanguageYoruba])
        {
            language = kLanguageEnglish;
        }
        

        [self.handler requestSongsForlanguages:language];
        [self addActivityIndicator];
        fetching =  YES;
	}
	else
		self.unableToConnect = YES;
    
    
    return fetching;
	

}
-(void)removeActivityIndicator
{
    if(self.activity)
	{
		[self.activity stopAnimating];
        self.activity.hidden = YES;
		[self.activity  removeFromSuperview];
		self.activity = nil;
	}
}

-(void)dataResponse:(DataHandler *)object successState:(BOOL)state andLanguage:(kLanguagesEnum)language
{
//    /// We need not show the activity indicator now
    [self removeActivityIndicator];
    if(state)
    {
        [self loadCategoriesFromDB];
		NSMutableArray *songList = [NSMutableArray array];
		[[Database instance] loadAllSongs:songList withCategoryId:1];
		DLog(@"%@",songList);
        [self updateViewIfNeeded];
        
    }
//    NSLog(@"Finished Reading %d",state);
}
-(IBAction)refreshAction:(id)sender
{
	if(!self.activity.isAnimating){
		self.unableToConnect = NO;
		if(1)
        {
            NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
            NSString *language = [languageSelected isEqualToString:kLanguageYoruba] ? kLanguageYoruba:kLanguageEnglish;
            self.unableToConnect = [self.handler requestSongsForlanguages:language];
        }
        else
            self.unableToConnect = YES;
        
        if( self.unableToConnect == NO)
        {
            
            [self addActivityIndicator];
        }
    [self updateViewIfNeeded];
		
	}
}
-(IBAction)infoButtonTapped:(id)sender
{
    InfoViewController * infoController  = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    
    [UIView transitionFromView:self.navigationController.topViewController.view toView:infoController.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController pushViewController:infoController animated:false];
    }];
    
}
@end
