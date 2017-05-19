//
//  MediaCategoryViewController.m
//  MahimaiApp
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SongListViewController.h"
#import "UIViewController+NavBar.h"
#import "Constants.h"
#import "AppInfo.h"
#import "Database.h"
#import "LyricsPageViewController.h"

# define NUM_DEFAULT_ROW_COUNT	5
# define NUM_CALLBACKS			3
# define SEARCH_HYMN_TITLE      @"Search Hymn"

@interface SongListViewController()
@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@property (nonatomic,strong) IBOutlet UIButton *buttonBack;
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;
@end


@implementation SongListViewController
@synthesize titleArray,langCode,listTable,filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize categoryId = _categoryId;
@synthesize categoryTitle = _categoryTitle;
@synthesize  languageButton = _languageButton;
@synthesize buttonMenu = _buttonMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	listTable.delegate = self;
	listTable.dataSource = self;
	self.listTable.rowHeight = 40;
	self.listTable.backgroundColor = [UIColor clearColor];
	self.listTable.separatorColor = [UIColor clearColor];
    
    self.titleLabel.text =[self isCategoryController] ? [self.categoryTitle capitalizedString] :  SEARCH_HYMN_TITLE;
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSString *languageText = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    [self.buttonToggleLanguage setTitle:languageText forState:UIControlStateNormal];
    
    NSString *title =  (langId == kLanguageYorubaID) ? @"Ymenu" : @"Emenu";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];
	
	[self setResistanceNavBarTitle];
	self.navigationItem.leftBarButtonItem = nil;
    [self populateTableData];
    
    
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.titleArray count]];
	
        // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
	
	[self.listTable reloadData];
    
}
-(void)populateTableData
{
    NSMutableArray *songList = [NSMutableArray array];
    
    NSInteger catId = ([self isCategoryController]) ? self.categoryId : -1;
        [[Database instance] loadAllSongs:songList withCategoryId:(catId)];

	DLog(@"%@",songList);
    self.titleArray = songList;
}
-(BOOL)isCategoryController
{
    return (self.categoryId > 0 );
}

- (void)viewDidUnload
{
        // Save the state of the search UI so that it can be restored if the view is re-created.
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	
	self.filteredListContent = nil;
}



 - (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];

     if (self.savedSearchTerm)
     {
         [self.searchDisplayController setActive:self.searchWasActive];
         [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
         [self.searchDisplayController.searchBar setText:savedSearchTerm];
         
         self.savedSearchTerm = nil;
     }

 }


/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Recieved Memeory Warning %@",[self class]);
	
	// Release any cached data, images, etc that aren't in use.
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSArray *titles = [titleDict allKeys];
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
        return [titleArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.backgroundColor = [UIColor clearColor];
        
        UILabel *numberLabel =  [[UILabel alloc] initWithFrame:CGRectMake(LEFT_TEXT_OFFSET_ITEM_NAME, 8, 208, 20)];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.textColor = [UIColor blackColor];
		numberLabel.tag = 100;
		[cell.contentView addSubview: numberLabel];
        
		
		UIImage *accessoryImage = [UIImage imageNamed:@"arrow02_black.png"];
		UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
		accImageView.userInteractionEnabled = YES;
		[accImageView setFrame:CGRectMake(10, 0, 28.0, 13.0)];
		[cell setAccessoryView:accImageView];
		accImageView  =  nil;
	}
	NSDictionary *titleDictObject  = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        titleDictObject = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        titleDictObject = [self.titleArray objectAtIndex:indexPath.row];
    }
    
	UILabel * number = (UILabel * )[cell viewWithTag: 100];
	number.text = [NSString stringWithFormat:@"%@   %@",[titleDictObject objectForKey:keySongNo],[titleDictObject objectForKey:keySongName]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	NSInteger rowid = indexPath.row;
	NSInteger sectionid  = 0;
    LyricsPageViewController *lyricsPage = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        lyricsPage = [[LyricsPageViewController alloc]initWithArray:self.filteredListContent sectionId:sectionid feedId:rowid];
    }
    else
    {
        lyricsPage = [[LyricsPageViewController alloc]initWithArray:self.titleArray sectionId:sectionid feedId:rowid];
    }

	[[self navigationController] pushViewController:lyricsPage animated:YES];
	
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
   
    
	for (NSDictionary *dict in self.titleArray)
	{
            //if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
		{
            
            NSString * titleSearch = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:keySongNo],[dict objectForKey:keySongName]];
//			NSComparisonResult result = [titleSearch compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch| NSNumericSearch| NSLiteralSearch) range:NSMakeRange(0, [searchText length])];
//            if (result == NSOrderedSame)
            
            NSRange descriptionRange = [titleSearch rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(descriptionRange.location != NSNotFound)
			{
				[self.filteredListContent addObject:dict];
            }
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
        // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
        // Return YES to cause the search result table view to be reloaded.
    return YES;
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

