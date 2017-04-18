//
//  Database.h
//  Mahima
//
//  Created by Jidh on 31/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SingletonBoilerPlate.h"
#import "LanguageSelectionViewC.h"

#import <sqlite3.h>

@interface Database : SingletonBoilerPlate {
		sqlite3 *database;
}

+ (Database*)instance;

// you need to call these when you want to open/close the database
- (void)initializeDatabase;

- (void)shutDown;

-(BOOL)persistSongs:(NSArray*)songlist forLanguageId:(NSInteger)langId;
-(BOOL)persistCategories:(NSString*)categoryName categoryRange:(NSString *)categoryRange categoryId:(NSInteger)categoryId;
-(BOOL)persistEachSong:(NSDictionary*)songDict langId:(NSInteger)langId   categoryId:(NSInteger)categoryId  songId:(NSInteger)songId;

-(void)loadAllCategories:(NSMutableArray*)categories;
-(void)loadAllSongs:(NSMutableArray*)songs withCategoryId:(NSInteger)categoryId;

//-(void)deleteSongs;
-(void)deleteSongsforLanguage:(NSInteger)languageId;
-(BOOL)persistFavorite:(NSString*)name withLangId:(NSInteger) langId;
-(BOOL)deleteFavorite:(NSString*)name;
-(void)loadAllFavorites:(NSMutableArray*)favorites;
-(void)loadSong:(NSMutableArray*)songs withName:(NSString*)name;
@end
