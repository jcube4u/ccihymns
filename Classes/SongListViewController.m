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
@property (nonatomic) BOOL isSearching;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end


@implementation SongListViewController
@synthesize titleArray,langCode,listTable,filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize categoryId = _categoryId;
@synthesize categoryTitle = _categoryTitle;
@synthesize  buttonToggleLanguage = _buttonToggleLanguage;
@synthesize buttonMenu = _buttonMenu;
@synthesize searchController = _searchController;
@synthesize searchBar = _searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	listTable.delegate = self;
	listTable.dataSource = self;
	self.listTable.rowHeight = 40;
	self.listTable.backgroundColor = [UIColor clearColor];
	self.listTable.separatorColor = [UIColor clearColor];
    self.isSearching = FALSE;
    
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
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = FALSE;
    self.searchController.searchBar.delegate = self;
    

    
    if (@available(iOS 11.0, *)) {
        //self.navigationItem.searchController = searchController;
        //self.searchBar = self.searchController.searchBar;
        self.searchBar.showsCancelButton = YES;
        self.searchBar.delegate = self;
    } else {
        self.listTable.tableHeaderView =  self.searchController.searchBar;
    }
    self.definesPresentationContext = true;
	
        // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{

        [self.searchController setActive:self.searchWasActive];
        [self.searchController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchController.searchBar setText:savedSearchTerm];

        
        self.savedSearchTerm = nil;
    }
	
	[self.listTable reloadData];
    
}

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

// called when text starts editing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // adjust layout for keyboard display
     //NSLog(@"searchBarTextDidEndEditing %lu",(unsigned long)self.filteredListContent.count);
    self.searchBar = searchBar;
}

// return NO to not resign first responder
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    // adjust layout for no keyboar
    
    [searchBar resignFirstResponder];
    return YES;
}

// called when text ends editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //NSLog(@"searchBarTextDidEndEditing %lu",(unsigned long)self.filteredListContent.count);
    NSString *searchString = searchController.searchBar.text;
    if (searchString != nil) {
        [self filterContentForSearchText:searchString scope:
         [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
        
    }
    
    [self.listTable reloadData];
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"did change");
    NSString *searchString = searchText;
    if (searchString != nil && searchText.length > 0) {
        [self filterContentForSearchText:searchString scope:
         [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
        
    }
    if (self.filteredListContent.count > 0 )
        self.isSearching = YES;
    else {
        [searchBar resignFirstResponder];
        [self.filteredListContent removeAllObjects];
        self.isSearching = FALSE;
    }
    
    [self.listTable reloadData];
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    //NSLog(@"Clicked");
    [searchBar resignFirstResponder];
    [searchBar endEditing:YES];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"Clicked");
    self.isSearching = NO;
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [searchBar endEditing:YES];
    
}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar

-(void)populateTableData
{
    NSMutableArray *songList = [NSMutableArray array];
    
    NSInteger catId = ([self isCategoryController]) ? self.categoryId : -1;
        [[Database instance] loadAllSongs:songList withCategoryId:(catId)];

	//DLog(@"%@",songList);
    self.titleArray = songList;
}
-(BOOL)isCategoryController
{
    return (self.categoryId > 0 );
}

- (void)viewDidUnload
{
        // Save the state of the search UI so that it can be restored if the view is re-created.
    self.searchWasActive = [self.searchController isActive];
    self.savedSearchTerm = [self.searchController.searchBar text];
    self.savedScopeButtonIndex = [self.searchController.searchBar selectedScopeButtonIndex];
    
	
	self.filteredListContent = nil;
}

 - (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     [self.filteredListContent removeAllObjects];
     [self.searchBar resignFirstResponder];
     
     if (self.savedSearchTerm)
     {
         [self.searchController setActive:self.searchWasActive];
         [self.searchController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
         [self.searchController.searchBar setText:savedSearchTerm];
         
         self.savedSearchTerm = nil;
     }

 }

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
    
    //NSLog(@"tableView numberOfRowsI  %lu",(unsigned long)self.filteredListContent.count);
    if ([self isFiltering])
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
        
        UILabel *numberLabel =  [[UILabel alloc] initWithFrame:CGRectMake(LEFT_TEXT_OFFSET_ITEM_NAME, 8, self.view.frame.size.width - (LEFT_TEXT_OFFSET_ITEM_NAME + 25), kDefaultCellFontSize)];
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
    if ([self isFiltering])
	{
       // NSLog(@"tableView cellForRowAtIndexPath   filtering  %lu  / %lu    ",(unsigned long)self.filteredListContent.count,(unsigned long)indexPath.row);
        titleDictObject = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        titleDictObject = [self.titleArray objectAtIndex:indexPath.row];
       // NSLog(@"tableView cellForRowAtIndexPath  %@",titleDictObject );
    }
    
	UILabel * number = (UILabel * )[cell viewWithTag: 100];
	number.text = [NSString stringWithFormat:@"%@   %@",[titleDictObject objectForKey:keySongNo],[titleDictObject objectForKey:keySongName]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [self.searchBar endEditing:YES];
    [self.searchController.searchBar endEditing:YES];
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
    
	NSInteger rowid = indexPath.row;
	NSInteger sectionid  = 0;
    LyricsPageViewController *lyricsPage = nil;
    if ([self isFiltering])
	{
           // NSLog(@"tableView didSelectRowAtIndexPath  %lu",(unsigned long)self.filteredListContent.count);
        lyricsPage = [[LyricsPageViewController alloc]initWithArray:self.filteredListContent sectionId:sectionid feedId:rowid];
    }
    else
    {
       // NSLog(@"tableView didSelectRowAtIndexPath  Not filtering  %lu",(unsigned long)self.filteredListContent.count);
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
            
            NSRange descriptionRange = [titleSearch rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(descriptionRange.location != NSNotFound)
			{
				[self.filteredListContent addObject:dict];
            }
		}
	}
    
    //NSLog(@"Filer COunt %lu",(unsigned long)self.filteredListContent.count);
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
   
      //NSLog(@"updateSearchResultsForSearchController %lu",(unsigned long)self.filteredListContent.count);
    
    NSString *searchString = searchController.searchBar.text;
    if (searchString != nil) {
        [self filterContentForSearchText:searchString scope:
         [[self.searchController.searchBar scopeButtonTitles] objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
        
    }
    
    [self.listTable reloadData];
}

-(BOOL) isFiltering  {

   //BOOL isFiltering  = self.searchController.isActive && (![self searchBarIsEmpty]);
    return self.isSearching;
//
//    BOOL isFiltering  = self.searchBar.isActive && (![self searchBarIsEmpty]);
//     NSLog(@"isFiltering %lu",(unsigned long)isFiltering);
//    return isFiltering;
}

-(BOOL) searchBarIsEmpty{
    return (self.searchController.searchBar.text.length == 0) ;
}

#pragma mark -
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

