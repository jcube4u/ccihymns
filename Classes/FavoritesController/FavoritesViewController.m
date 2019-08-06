//
//  FavoritesViewController.m
//  Mahima
//
//  Created by George, Jidh on 30/01/2013.
//
//
#import "LyricsPageViewController.h"
#import "UIViewController+NavBar.h"
#import "DataHandler.h"
#import "Database.h"
#import "FFSAPICaller.h"
#import "MahimaAppDelegate.h"
#import "AppInfo.h"
#import "FavoritesViewController.h"

/// Attribute Elements


# define NUM_DEFAULT_ROW_COUNT	5
# define NUM_CALLBACKS			3

@interface FavoritesViewController()


@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@property (nonatomic,strong) IBOutlet UIButton *buttonBack;
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;

@property (nonatomic,strong) IBOutlet UILabel *noResultsText;

@end

@implementation FavoritesViewController
@synthesize mainMenu,listTable,categoriesArray;
@synthesize buttonToggleLanguage = _buttonToggleLanguage;
@synthesize buttonMenu = _buttonMenu;
@synthesize noResultsText = _noResultsText;
-(void)setUpTableStates
{
    listTable.delegate = self;
	listTable.dataSource = self;
	self.listTable.rowHeight = 40;
	self.listTable.backgroundColor = [UIColor clearColor];
	self.listTable.separatorColor = [UIColor blackColor];
}

- (void)addActivityIndicator {
    activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activity.center = self.view.center;
    [activity startAnimating];
    [self.view addSubview:activity];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTableStates];
    
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:	104.0/255.0 green:58.0/255.0 blue:22.0/255.0 alpha:1.0];
    [self loadFavoritesFromDB];
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSString *languageText = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    [self.buttonToggleLanguage setTitle:languageText forState:UIControlStateNormal];
    ;
    NSString *title =  (langId == kLanguageYorubaID) ? @"Ymenu" : @"Emenu";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];

    if([categoriesArray count] !=0)
        self.noResultsText.hidden = YES;
    
	[self.listTable reloadData];
    
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
        
        UILabel *numberLabel =  [[UILabel alloc] initWithFrame:CGRectMake(LEFT_TEXT_OFFSET_ITEM_NAME, 8, self.view.frame.size.width - (3 * LEFT_TEXT_OFFSET_ITEM_NAME), 20)];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.textColor = [UIColor blackColor];
		numberLabel.tag = 100;
		[cell.contentView addSubview: numberLabel];
		
		UIImage *accessoryImage = [UIImage imageNamed:@"arrow02_black.png"];
		UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		accImageView.userInteractionEnabled = YES;
		[accImageView setFrame:CGRectMake(10, 0, 28.0, 13.0)];
		[cell setAccessoryView:accImageView];
		accImageView= nil;
	}
	NSDictionary *langDict =  [categoriesArray objectAtIndex: indexPath.row];
	UILabel * langaugeName = (UILabel * )[cell viewWithTag: 100];
	langaugeName.text = [[langDict objectForKey:keyCategoryNameDB] capitalizedString];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	NSInteger rowid = indexPath.row;
	NSInteger sectionid  = 0;
    LyricsPageViewController *lyricsPage = nil;

    NSMutableArray *songsList = [NSMutableArray array];
    
    
    for(int i = 0; i< self.categoriesArray.count;i++)
    {
        NSDictionary *langDict =  [categoriesArray objectAtIndex:i];
        NSString *name = [langDict objectForKey:keyCategoryNameDB];
        [[Database instance] loadSong:songsList withName:name];
    }
    
    lyricsPage = [[LyricsPageViewController alloc]initWithArray:songsList sectionId:sectionid feedId:rowid];
    
	[[self navigationController] pushViewController:lyricsPage animated:YES];
}

- (void)dealloc {
	
	categoriesArray = nil;
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
}

// Load Favorites From DB
-(BOOL)loadFavoritesFromDB{
	
	BOOL languagesLoaded =  NO;
	/// Load Languages from DB
	NSMutableArray *categoriesList = [NSMutableArray array];
	[[Database instance] loadAllFavorites:categoriesList];
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
