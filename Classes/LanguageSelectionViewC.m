    
//
//  MediaCategoryViewController.m
//  MahimaApp
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "LanguageSelectionViewC.h"
#import "UIViewController+NavBar.h"
#import "SongListViewController.h"
#import "DataHandler.h"
#import "Database.h"
#import "FFSAPICaller.h"
#import "MahimaAppDelegate.h"
#import "AppInfo.h"


/// Attribute Elements


# define NUM_DEFAULT_ROW_COUNT	5
# define NUM_CALLBACKS			3

@interface LanguageSelectionViewC()
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;
@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@end

@implementation LanguageSelectionViewC
@synthesize mainMenu,listTable,categoriesArray;
@synthesize selectedLanguage = _selectedLanguage;
@synthesize handler =  _handler;
@synthesize buttonToggleLanguage = _buttonToggleLanguage;
@synthesize buttonMenu= _buttonMenu;

-(void)setUpTableStates
{
    listTable.delegate = self;
	listTable.dataSource = self;
	self.listTable.rowHeight = 40;
	self.listTable.backgroundColor = [UIColor clearColor];
	self.listTable.separatorColor = [UIColor clearColor];
}

- (void)addActivityIndicator {
    activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activity.frame = CGRectMake(ACTIVITY_INDICATOR_LEFTOFFSET, ACTIVITY_INDICATOR_HEIGHT_OFFSET, ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE);
    [activity startAnimating];
    [self.view addSubview:activity];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTableStates];

	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:	104.0/255.0 green:58.0/255.0 blue:22.0/255.0 alpha:1.0];
	
	[self setResistanceNavBarTitle];
	
    [self loadLanguagesFromDB];
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    self.buttonToggleLanguage.titleLabel.text = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    ;
    NSString *title =  (langId == kLanguageYorubaID) ? @"Ymenu" : @"Emenu";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];

    
	[self.listTable reloadData];

}

-(IBAction)refreshAction:(id)sender
{
	if(!activity){
		unableToConnect = NO;
		if(1)
        {
            NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
            NSString *language = [languageSelected isEqualToString:kLanguageYoruba] ? kLanguageYoruba:kLanguageEnglish;
            [self.handler requestSongsForlanguages:language];
        }
        else
            unableToConnect = YES;
        
        if( unableToConnect == NO)
        {
            
            [self addActivityIndicator];
        }
		[self.listTable reloadData];
		
	}
}


-(void)dataResponse:(DataHandler *)object successState:(BOOL)state andLanguage:(kLanguagesEnum)language
{
    /// We need not show the activity indicator now
	if(activity)
	{
		[activity stopAnimating];
		[activity  removeFromSuperview];
		activity = nil;
	}
    if(state)
    {
        [self loadLanguagesFromDB];
		NSMutableArray *songList = [NSMutableArray array];
		[[Database instance] loadAllSongs:songList withCategoryId:1];
		DLog(@"%@",songList);
        self.selectedLanguage = language;
    
    }
    [self.listTable reloadData];
//    NSLog(@"Finished Reading %d",state);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Recieved Memeory Warning %@",[self class]);
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categoriesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.backgroundColor = [UIColor clearColor];
        
        UILabel *numberLabel =  [[UILabel alloc] initWithFrame:CGRectMake(LEFT_TEXT_OFFSET_ITEM_NAME, 8, 170, 20)];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.textColor = [UIColor blackColor];
		numberLabel.tag = 100;
		[cell.contentView addSubview: numberLabel];
        
        UILabel *rangeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(175, 8, 70, 20)];
		rangeLabel.backgroundColor = [UIColor clearColor];
		rangeLabel.textColor = [UIColor blackColor];
        rangeLabel.textAlignment = NSTextAlignmentRight;
		rangeLabel.tag = 101;
		[cell.contentView addSubview: rangeLabel];
		
		UIImage *accessoryImage = [UIImage imageNamed:@"arrow02_black.png"];
		UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		accImageView.userInteractionEnabled = YES;
		[accImageView setFrame:CGRectMake(10, 0, 28.0, 13.0)];
		[cell setAccessoryView:accImageView];
		accImageView= nil;
	}
	NSDictionary *langDict =  [categoriesArray objectAtIndex: indexPath.row];
	UILabel * langaugeName = (UILabel * )[cell viewWithTag: 100];
	UILabel * rangeLabel = (UILabel * )[cell viewWithTag: 101];
	langaugeName.text = [[langDict objectForKey:keyCategoryNameDB]capitalizedString] ;
	rangeLabel.text = [[langDict objectForKey:keyCategoryRangeXML]capitalizedString] ;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    SongListViewController * detailsViewController = [[SongListViewController alloc] initWithNibName:nil bundle:nil ];
	NSDictionary *catDict =  [categoriesArray objectAtIndex: indexPath.row];
    detailsViewController.categoryId = [[catDict objectForKey:keyCategoryId] integerValue];
    detailsViewController.categoryTitle = [catDict objectForKey:keyCategoryNameDB];
    [self.navigationController pushViewController:detailsViewController animated:YES];
    detailsViewController = nil;
}

- (void)dealloc {
	
	categoriesArray = nil;
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
}


/// Load Languages From DB
-(BOOL)loadLanguagesFromDB{
	
	BOOL languagesLoaded =  NO;
	/// Load Languages from DB
	NSMutableArray *categoriesList = [NSMutableArray array];
	[[Database instance] loadAllCategories:categoriesList];
	if([categoriesList count] > 0){
		self.categoriesArray =  [[NSMutableArray alloc] initWithArray:categoriesList];
		return !languagesLoaded;
	}
    
	
	DLog(@"%@",categoriesList);
	
	return languagesLoaded;
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
@end
