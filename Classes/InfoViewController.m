//
//  InfoViewController.m
//  MahimaApp
//
//  Created by Ashley Mills on 27/08/2009.

//

#import "InfoViewController.h"
#import "Constants.h"
#import "AppInfo.h"
#import "UIViewController+NavBar.h"

static NSString * urlInfoText = kInfoUrlApi;

@interface InfoViewController()

@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;

@end


@implementation InfoViewController

@synthesize mainMenu,titleText,webView;
@synthesize buttonMenu = _buttonMenu;
@synthesize buttonToggleLanguage = _buttonToggleLanguage;
@synthesize delegate = _delegate;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	webView.backgroundColor = [UIColor clearColor];
	
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlInfoText]]];
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSString *languageText = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    [self.buttonToggleLanguage setTitle:languageText forState:UIControlStateNormal];
    
    NSString *title =  (langId == kLanguageYorubaID) ? @"Y" : @"E";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];

    
    if(self.delegate)
    {
        self.buttonToggleLanguage.hidden = YES;
        
        self.buttonMenu.hidden = YES;
    }
    
    [self removeShadow];
		
}

- (void)didReceiveMemoryWarning {
	NSLog(@"Memory warning for class %@", [self class]);
    [super didReceiveMemoryWarning];
	
}

	
	
#pragma mark -
#pragma mark UIViewController delegate methods
- (void)viewWillDisappear:(BOOL)animated
{
	[webView stopLoading];	// in case the web view is still loading its content
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

	
#pragma mark -
#pragma mark UIWebViewDelegate
	
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if(displayedObjects == nil)
	{
		displayedObjects = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"InfoPageContent"];
		NSDictionary *dict = [displayedObjects  objectAtIndex:0];
		NSString  *htmlContent = [dict objectForKey:@"Data"];
		[webView loadHTMLString:htmlContent baseURL:nil];
	}
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.titleText = nil;
	webView.delegate = nil;
	self.webView = nil; 
	displayedObjects = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	displayedObjects = nil;
	
	webView.delegate = nil;
	webView = nil;
}

- (void)animateViewRemoval
{
    int numViewControllers = self.navigationController.viewControllers.count;
    UIView *nextView = [[self.navigationController.viewControllers objectAtIndex:numViewControllers - 2] view];
    
    [UIView transitionFromView:self.navigationController.topViewController.view toView:nextView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:false];
    }];
}

-(IBAction)pop:(id)sender
{
    if(![self dismissingViewViaDelegate])
    {
        
        [self animateViewRemoval];
    }
    

}

-(IBAction)popToRoot:(id)sender
{
    if(![self dismissingViewViaDelegate])
    {
        [self animateViewRemoval];
    }

}
- (IBAction)popToRootWithLanguageToggle:(id)sender
{
    [[AppInfo sharedInfo] toggleSelectedlanguage];
    
    if(![self dismissingViewViaDelegate])
    {
        [self animateViewRemoval];
    }
}
-(BOOL)dismissingViewViaDelegate
{
    BOOL dismissViaDelegate = NO;
    if(self.delegate)
    {
        if([(NSObject*)self.delegate respondsToSelector:@selector(dismissInfoView)])
        {
            [self.delegate dismissInfoView];
            dismissViaDelegate = YES;
        }
    }
    return dismissViaDelegate;
}

-(void)removeShadow
{
    if ([[self.webView subviews] count] > 0)
    {
        for (UIView* shadowView in [[[self.webView subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        
        // unhide the last view so it is visible again because it has the content
        [[[[[self.webView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
}
@end
