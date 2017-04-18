//
//  MediaCategoryViewController.m
//  MahimaApp
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SongListViewController.h"
#import "UIViewController+NavBar.h"
#import "AppInfo.h"
#import "Database.h"
#import "Constants.h"
#import "MahimaAppDelegate.h"
#import "LyricsPageViewController.h"

# define NUM_DEFAULT_ROW_COUNT	5
# define NUM_CALLBACKS			3
# define SEARCHBAR_HEIGHT       32.0f
# define SEARCH_HYMN_TITLE      @"Search Hymn"

@implementation SongListViewController
@synthesize titleArray,categoryId,listTable,filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize buttonToggleLanguage = _buttonToggleLanguage;
@synthesize titleLabel = _titleLabel;
@synthesize categoryTitle = _categoryTitle;

-(void)setUpTableStates
{
    self.listTable.delegate = self;
	self.listTable.dataSource = self;
	self.listTable.rowHeight = 40;
	self.listTable.backgroundColor = [UIColor clearColor];
	self.listTable.separatorColor = [UIColor grayColor];
    
    if([self isCategoryController])
    {
        CGRect frame = self.listTable.frame;
        frame.origin.y -= SEARCHBAR_HEIGHT;
        frame.size.height += SEARCHBAR_HEIGHT;
        self.listTable.frame = frame;
    }

}
-(BOOL)isCategoryController
{
    return NO;//(self.categoryId > 0 );
}

-(void)populateTableData
{
    NSMutableArray *songList = [NSMutableArray array];
    
    NSInteger catId = ([self isCategoryController]) ? self.categoryId : -1;
	[[Database instance] loadAllSongs:songList withCategoryId:(catId)];
	DLog(@"%@",songList);
    self.titleArray = songList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchDisplayController.searchBar.hidden = [self isCategoryController];
    [self setUpTableStates];

	[self setResistanceNavBarTitle];
	self.navigationItem.leftBarButtonItem = nil;
    
    self.titleLabel.text =[self isCategoryController] ? [self.categoryTitle capitalizedString] :  SEARCH_HYMN_TITLE;
    
    [self populateTableData];
    
    NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
    self.buttonToggleLanguage.titleLabel.text = ([languageSelected isEqualToString:kLanguageYoruba]) ? @"E" : @"Y";

    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.titleArray count]];
	
    [self updateSearchBarwithSearchTerm];
	
	[self.listTable reloadData];
	
}

 - (void)updateSearchBarwithSearchTerm {
     if (self.savedSearchTerm)
     {
         [self.searchDisplayController setActive:self.searchWasActive];
         [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
         [self.searchDisplayController.searchBar setText:savedSearchTerm];
         
         self.savedSearchTerm = nil;
     }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self updateSearchBarwithSearchTerm];
 }

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Recieved Memeory Warning %@",[self class]);
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
        // Save the state of the search UI so that it can be restored if the view is re-created.
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	
	self.filteredListContent = nil;
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
		cell.backgroundColor = [UIColor whiteColor];
			
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
    
	FontLabel * number = (FontLabel * )[cell viewWithTag: 100];
	number.text = [NSString stringWithFormat:@"%@ %@",[titleDictObject objectForKey:keySongNo],[titleDictObject objectForKey:keySongName]];
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
	lyricsPage =  nil;
	
}

- (void)dealloc {

	
    filteredListContent  = nil;
	self.titleArray = nil;

}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    
	for (NSDictionary *dict in self.titleArray)
	{
            //if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
		{
			NSComparisonResult result = [[dict objectForKey:keySongName] 
										 compare:searchText 
										 options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)  
										range:[[dict objectForKey:keySongName] rangeOfString:searchText 
										options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
														   
            if (result == NSOrderedSame)
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

    [self.navigationController popToRootViewControllerAnimated: YES];
}

@end

