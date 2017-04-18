//
//  MediaCategoryViewController.h
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface SongListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
											UISearchDisplayDelegate, UISearchBarDelegate> {
	NSMutableArray	*titleArray;
	NSInteger		categoryId;
	UITableView		*listTable;
    
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	
        // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    UIButton        *buttonToggleLanguage;
    NSString		*categoryTitle;
}

@property(nonatomic,strong)	NSMutableArray	*titleArray;
@property NSInteger		categoryId;
@property(nonatomic,retain) IBOutlet UILabel            *titleLabel;
@property(nonatomic,retain) IBOutlet UITableView		*listTable;
@property (nonatomic, strong) NSString *categoryTitle;

@property (nonatomic, strong) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, strong) IBOutlet UIButton *buttonToggleLanguage;

- (IBAction)pop:(id)sender;
- (IBAction)popToRoot:(id)sender;
- (IBAction)popToRootWithLanguageToggle:(id)sender;

@end
