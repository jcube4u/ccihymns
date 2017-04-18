//
//  MediaCategoryViewController.h
//  MahimaiApp
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SongListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate, UISearchBarDelegate> {
    
	NSMutableArray	*titleArray;
	
    NSInteger		langCode;
	
    UITableView		*listTable;
    
    NSInteger		categoryId;
    
    NSString		*categoryTitle;
    
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	
    // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    
    NSInteger		savedScopeButtonIndex;
    
    BOOL			searchWasActive;
}


@property(nonatomic,strong)	NSMutableArray	*titleArray;

@property NSInteger		langCode;

@property(nonatomic,retain) IBOutlet UITableView		*listTable;

@property(nonatomic,retain) IBOutlet UILabel            *titleLabel;

@property(nonatomic,retain) IBOutlet UIButton            *languageButton;

@property (nonatomic, retain) NSMutableArray *filteredListContent;

@property (nonatomic, assign) NSInteger		categoryId;

@property (nonatomic, strong) NSString      *categoryTitle;

@property (nonatomic, copy) NSString *savedSearchTerm;

@property (nonatomic) NSInteger savedScopeButtonIndex;

@property (nonatomic) BOOL searchWasActive;

- (IBAction)pop:(id)sender;
- (IBAction)popToRoot:(id)sender;
- (IBAction)popToRootWithLanguageToggle:(id)sender;

@end
