//
//  MediaCategoryViewController.h
//
//  Created by Jidh on 18/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "DataHandler.h"

@interface LanguageSelectionViewC : UIViewController< UITableViewDelegate, 
													UITableViewDataSource> {

	id		mainMenu;
	NSMutableArray		*categoriesArray;
	UIActivityIndicatorView * activity;
	UITableView			*listTable;
	UIAlertView *alert ;
	BOOL unableToConnect;
	UIView *contentView;
    kLanguagesEnum selectedLanguage;
                                                        
	
}
@property(nonatomic,strong)	NSMutableArray *categoriesArray;
@property(nonatomic,strong)	IBOutlet UITableView	*listTable;
@property (nonatomic, strong) id mainMenu;
@property (nonatomic, assign)   kLanguagesEnum selectedLanguage;
@property (nonatomic, strong) DataHandler *handler;
- (BOOL)loadLanguagesFromDB;
- (IBAction)pop:(id)sender;
- (IBAction)popToRoot:(id)sender;
- (IBAction)popToRootWithLanguageToggle:(id)sender;

@end
