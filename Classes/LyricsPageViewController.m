/*
 Copyright (C) Jidh George, Inc. 2012. All rights reserved.
 */

#import "Constants.h"
#import "AppInfo.h"
#import "Database.h"
#import "UIViewController+NavBar.h"
#import "MahimaAppDelegate.h"

#import "LyricsPageViewController.h"

@interface LyricsPageViewController()

@property (nonatomic,assign) NSInteger fontSize;
@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;

-(void)updateWebView;
@end

@implementation LyricsPageViewController
@synthesize feedTitle,feedTitleLabel,footerText,feedDict,urlLink,webView,dataArray;
@synthesize  feedDescription = _feedDescription;
@synthesize fontSize = _fontSize;
@synthesize favoriteButton = _favoriteButton;
@synthesize songNumber = _songNumber;
@synthesize buttonMenu = _buttonMenu;


#pragma mark -
- (void)dealloc
{
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	webView.delegate = nil;
	webView  = nil;
	
	feedTitleLabel = nil;
	feedTitle		= nil;
	favoriteButton = nil;
	feedDescription	= nil;
	footerText		= nil;
	urlLink			= nil;
	self.feedDict = nil;
	 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		feedTitle		= @"";
		feedDescription	= @"";
		footerText		= @"";
		urlLink		= @"";
	
	}
	return self;
}
- (id)initWithArray:(NSArray *)array sectionId:(NSInteger)sectionId feedId:(NSInteger)feedId
{
	if (array) {
		self.dataArray =  array;
		currentFeedId = feedId;
		currentSectionId =  sectionId;
        

	}
	return self;
}


#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidLoad
{
    if(!self.dataArray)
    {
        NSMutableArray *songList = [NSMutableArray array];
        [[Database instance] loadAllSongs:songList withCategoryId:-1];
        self.dataArray = songList;
        currentFeedId = rand() % (songList.count - 1);
		currentSectionId =  0;

    }
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSString *languageText = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    [self.buttonToggleLanguage setTitle:languageText forState:UIControlStateNormal];
    ;
    NSString *title =  (langId == kLanguageYorubaID) ? @"Ymenu" : @"Emenu";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];

    NSString *fontSize =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedFontSize];
    self.fontSize =  (nil == fontSize) ? 14 :[fontSize integerValue];
    [self loadFeed:currentFeedId];
    
    
    [self removeShadow];

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

-(void)updateFavoriteState
{
    NSMutableArray *array = [NSMutableArray array];
    [[Database instance] loadAllFavorites:array];
    
    NSMutableDictionary		*dict		= [self.dataArray objectAtIndex:currentFeedId];
	if([dict valueForKey:keySongName])
	{
		NSString *name = [dict valueForKey:keySongName];
        __block BOOL found = NO;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *nameDict = (NSDictionary *)obj;
            if([[nameDict valueForKey:keyFavoritesNameDB] isEqualToString:name])
            {
                *stop = YES;
                found = YES;
            }
        }];
        
        self.favoriteButton.selected = found;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
	NSLog(@"Memory warning for class %@", [self class]);
    [super didReceiveMemoryWarning];
	
}

-(void)loadFeed:(NSInteger)feedId
{
    
	NSMutableDictionary		*dict		= [self.dataArray objectAtIndex:currentFeedId];
	if([dict valueForKey:keySongName])
	{
		NSString *_titleString = [dict valueForKey:keySongName];
		if( _titleString != nil)
			feedTitle =  [[NSString alloc] initWithFormat:@"%@ - Hymn",[dict valueForKey:keySongNo]];
		else
			feedTitle =  [NSString stringWithFormat:@""];
        
        [self.feedTitleLabel setText:feedTitle];
        [self.songNumber setText:[dict valueForKey:keySongNo]];
	}

	if([dict valueForKey:keySongLyric])
	{
		//// Special Case if Description is not available for the given feed show the title as the description
		//feedDescription =  [[NSString stringWithFormat:@"%@",[tempFeedDict valueForKey:descriptionKey]] retain];
		NSString *_DescrString = [dict valueForKey:keySongLyric];
         NSMutableString *mString = [_DescrString mutableCopy];
        [mString replaceOccurrencesOfString:@"2." withString:@"=2." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"3." withString:@"=3." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"4." withString:@"=4." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"5." withString:@"=5." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"6." withString:@"=6." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"7." withString:@"=7." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"8." withString:@"=8." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"9." withString:@"=9." options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        [mString replaceOccurrencesOfString:@"Chorus:" withString:@"=Chorus:" options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        

        [mString replaceOccurrencesOfString:@"=" withString:@"<br/>" options:NSCaseInsensitiveSearch range:(NSRange){0,[mString length]}];
        mString = [ NSString stringWithString:  mString  ];
		if( _DescrString != nil)
			self.feedDescription =  [NSString stringWithFormat:@"%@",mString];
	}
	
	NSString *_titleText = [NSString stringWithFormat:@"%@", [dict objectForKey:keySongName]];
	self.title = _titleText;
	[self setResistanceNavBarTitle];

    [self updateWebView];
    [self updateFavoriteState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

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
    // Disable user selection
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

	

}
-(void)updateWebView
{
    NSString	*HeaderHTMLContent = [NSString stringWithFormat:@"<style type='text/css'> body {color:#00000; font-size:%dpt; font-family:book antiqua; text-align:center} a {color:#ff6600; text-decoration:underline;} </style>",self.fontSize];
	NSString	*HtmlContent = [HeaderHTMLContent stringByAppendingString:self.feedDescription];
	webView.delegate = self;
	[webView loadHTMLString:HtmlContent baseURL:nil];
	webView.dataDetectorTypes = UIDataDetectorTypeLink;
	webView.backgroundColor =[UIColor clearColor];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *requestURL = [ request URL ] ;
	// Check to see what protocol/scheme the requested URL is.
	if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ]
		  || [ [ requestURL scheme ] isEqualToString: @"https" ] )
		&& ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
		
		NSString * message = [NSString stringWithFormat: @"Click OK to exit the application and launch the link in Safari"]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Continue" message:message
													   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		[alert show];
		alert  = nil;
		savedRequestURL =  [ request URL ] ;
		return YES;//![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];
	}
	// Auto release
	requestURL = nil;
	// If request url is something other than http or https it will open in UIWebView.
	return YES;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+2 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[aWebView loadHTMLString:errorString baseURL:nil];
}
- (void)viewDidUnload
{
	self.feedTitleLabel = nil;
	self.favoriteButton = nil;
	
}
-(void)setFontSize:(NSInteger)fontSize
{
    _fontSize = fontSize;
}


-(IBAction)increaseFontSize:(id)sender
{
    if(self.fontSize < 20)
    {
        self.fontSize++;
        
        [[AppInfo sharedInfo] setDefaultsValueForKey:kSavedFontSize withValue:[NSString stringWithFormat:@"%d",self.fontSize]];
        
        [self updateWebView];
    }
}

-(IBAction)decreaseFontSize:(id)sender
{
    if(self.fontSize >8 )
    {
        self.fontSize--;
        
        [[AppInfo sharedInfo] setDefaultsValueForKey:kSavedFontSize withValue:[NSString stringWithFormat:@"%d",self.fontSize]];
        [self updateWebView];
    }

}

-(IBAction)moveNext:(id)sender
{
    if(currentFeedId < ([dataArray count] - 1))
    {
        currentFeedId++;
    }
    [self loadFeed:currentFeedId];
}

-(IBAction)movePrev:(id)sender
{
    if(currentFeedId > 0)
    {
        currentFeedId--;
    }
    [self loadFeed:currentFeedId];
}

-(IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

-(IBAction)popToRoot:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated: YES];
}
- (IBAction)popToRootWithLanguageToggle:(id)sender
{
    [[AppInfo sharedInfo] toggleSelectedlanguage];
    [self.navigationController popToRootViewControllerAnimated: YES];
}

-(IBAction)setFavorites:(id)sender
{
    self.favoriteButton.selected = !self.favoriteButton.selected;
    NSMutableDictionary		*dict		= [self.dataArray objectAtIndex:currentFeedId];
	if([dict valueForKey:keySongName])
	{
		NSString *songName = [dict valueForKey:keySongName];
        NSInteger languageId = [[AppInfo sharedInfo] getSelectedLanguageId];
        
        if(self.favoriteButton.selected)
        {
            [[Database instance] persistFavorite:songName withLangId:languageId];
        }
        else
        {
            [[Database instance] deleteFavorite:songName];
        }
    }
    NSMutableArray *array = [NSMutableArray array];
    [[Database instance] loadAllFavorites:array];
//    NSLog(@"List %@",array);

}
@end

