//
//  FavoritesViewController.h
//  Mahima
//
//  Created by George, Jidh on 30/01/2013.
//
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController< UITableViewDelegate,
UITableViewDataSource> {
    
	id		mainMenu;
	NSMutableArray		*categoriesArray;
	UIActivityIndicatorView * activity;
	UITableView			*listTable;
	UIAlertView *alert ;
	BOOL unableToConnect;
    
	
}
@property(nonatomic,strong)	NSMutableArray *categoriesArray;
@property(nonatomic,strong) NSMutableArray *expandedFavoritesList;
@property(nonatomic,strong)	IBOutlet UITableView	*listTable;
@property (nonatomic, strong) id mainMenu;
- (IBAction)pop:(id)sender;
- (IBAction)popToRoot:(id)sender;
- (IBAction)popToRootWithLanguageToggle:(id)sender;
@end
