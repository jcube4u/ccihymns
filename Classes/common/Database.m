//
//  Database.m
//  Mahima
//
//  Created by Jidh on 31/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Database.h"
#import "AppInfo.h"
#import "UIDevice+Multitasking.h"
#import "Constants.h"
#define D_DB_FILE @"hymnsDB26_5.sqlite"

#define loadCategories "select categoryId,name, categoryRange from categories WHERE categoryId BETWEEN ? AND ?"

@implementation Database

- (void)initializeDatabase{
	
	if(!database) {
		@synchronized(self) {
			NSError *error= nil;
			
			// The database is stored in the application bundle. 
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *path = [documentsDirectory stringByAppendingPathComponent:D_DB_FILE];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			
#ifdef D_PURGE_DB
			[fileManager removeItemAtPath:path error:&error];
#endif
			
#ifdef D_LS_DOC_DIRECTORY	
			NSArray* ls = [fileManager directoryContentsAtPath:documentsDirectory];
			DLog(@"contents of documents directory: %@", ls);
			
			for(NSString* file in ls) {
				NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
				NSDictionary* dict = [fileManager attributesOfItemAtPath:filePath error:nil];
				
				DLog(@"%@ Attributes:%@", filePath, dict);
			}
#endif
			
			if (![fileManager fileExistsAtPath:path]) 
			{
				// The writable database does not exist, so copy the default to the appropriate location.
				NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:D_DB_FILE];
				BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:path error:&error];
				
				if (!success) {
					NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
				} else {
					DLog(@"Copied blank DB to %@", path);			
				}
			}
			
			// Open the database. The database was prepared outside the application. Note: If missing this will create an empty one
			if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) 
			{
				// Even though the open failed, call close to properly clean up resources.
				NSAssert1(0, @"Failed to open database. %s", sqlite3_errmsg(database));
				
				sqlite3_close(database);
				database = 0;
			} else {
				DLog(@"Using DB %@", path);
			}
			
			@try {
				//[self checkAndUpgradeDatabase];
			} @catch (NSException* exception) {
				DLog(@"Failed to upgrade d/b. Removing file which is almost certainly corrupted: %@", exception);
				
				sqlite3_close(database);
				
				[fileManager removeItemAtPath:path error:&error];
				
				database = nil;
			}	
		}
	}
}

-(void)executeSQL:(const char*)sql {
	DAssert(sql != nil, @"called with nil SQL");
	
	sqlite3_stmt* sqlStmt = NULL;
	
	BOOL backgroundSupported = [[UIDevice currentDevice] hasMultitaskingOS];
	NSUInteger backgroundTaskIdentifier = 0;
	
	// make sure that if we go into the background we finish this whole method if we can 
	// especially coming out of the sync lock
	if(backgroundSupported) {
		backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
									^{sqlite3_finalize(sqlStmt);}];
	}				
	
	@synchronized(self) {
		// make sure we still have a database now we have a lock
		if(database) {				
			@try {	
				// Prepare the statements
				if (sqlite3_prepare_v2(database, sql, -1, &sqlStmt, NULL) == SQLITE_OK) {
					if (sqlite3_step(sqlStmt) != SQLITE_DONE) 
					{
						NSAssert2(0, @"Failed to execute SQL:%s Reason:%s", sql, sqlite3_errmsg(database));		
					}
					
					DLog(@"sql executed: \"%s\". Rows Updated: %d", sql, sqlite3_changes(database));
				} else {
					NSAssert2(0, @"Failed to prepare SQL:%s Reason: %s", sql, sqlite3_errmsg(database));		
				}
			}
			@catch(NSException* ex) {
				DLog(@"Exception: %@", ex);				
			} 
			@finally {				
				sqlite3_finalize(sqlStmt);
			}
		}
	}
	
	if(backgroundSupported) {
		if(backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
		}
	}
}


#define SET_CATEGORY "INSERT OR REPLACE INTO \"categories\" (\"categoryId\", \"name\",\"categoryRange\") VALUES (?,?,?)"
-(BOOL)persistSongs:(NSArray*)songlist forLanguageId:(NSInteger)langId{
	
    if(langId < 1)
        return NO;
	
	DAssert(songlist != nil, @"array parameter must not be nil");
	int categoryId = langId,songId = langId + kMAXCATEGORYOFFSET,totalSongsCount = 0;
	for(NSDictionary* category in songlist) {
		categoryId++;
		songId = 0;
        NSString *name =  [category objectForKey:keyCategoryNameXML];
        NSString *range =  [category objectForKey:keyCategoryRangeXML];
		[self persistCategories:name categoryRange:range categoryId:categoryId];
        
		
        NSMutableArray *songsArray = 	[category objectForKey:keyCategoryArray];
        //NSLog(@"===Category Type %@ and Count %d",[category objectForKey:keyCategoryNameXML],[songsArray count]);
        
		for(NSDictionary* songDict in songsArray){
//            NSArray * subArray =  [songDict objectForKey:@"titleArrayKey" ];
//            if(subArray.count == 0)
//            {
//                NSLog(@"%d ) Song %@",songId,[songDict objectForKey:keyTitleName]);    
//            }
            
//            NSDictionary * tempFeedDict =  [subArray objectAtIndex:1];

//            NSLog(@"%d/ %@ ) Song %@",songId,[tempFeedDict objectForKey:kObjectSongNo],[songDict objectForKey:keyTitleName]);
			[self persistEachSong:songDict langId:langId categoryId:categoryId songId:++songId];
			totalSongsCount++;
		}
	}
	
	if(totalSongsCount > MIN_SONGS_TO_SAVE)
		return	YES;
	
	return NO;
}

-(BOOL)persistCategories:(NSString*)categoryname  categoryRange:(NSString *)categoryRange categoryId:(NSInteger)categoryId {
	int success = SQLITE_ERROR;	
	
	@synchronized(self) {
		// make sure we still have a database now we have a lock
		if(database) {			
			sqlite3_stmt* sqlStmt = nil;
			
			if ((success = sqlite3_prepare_v2(database, SET_CATEGORY, -1, &sqlStmt, NULL) == SQLITE_OK)) {
				int columnNumber = 1;
				
				// we could reject the insert at this point based on the nil values but if the database constraints 
				// change then we would have to unroll it here and we almost certainly will forget so we rely on the 
				// database to protect the table integrity
				sqlite3_bind_int(sqlStmt, columnNumber++, (int)categoryId);
				sqlite3_bind_text(sqlStmt, columnNumber++, [categoryname UTF8String], -1, SQLITE_STATIC);
				sqlite3_bind_text(sqlStmt, columnNumber++, [categoryRange UTF8String], -1, SQLITE_STATIC);	
				
				
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == columnNumber), @"Column count in prepared statement does not match the number of columns bound");
				
				success = sqlite3_step(sqlStmt);
				
				sqlite3_finalize(sqlStmt);	
				
				if((success != SQLITE_OK) && (success != SQLITE_DONE))
				{
					DLog(@"Error: failed to execute SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
				}
			} else {
				DLog(@"Error: failed to prepare SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
			}
		}
	}
	
	return ((success == SQLITE_OK) || (success != SQLITE_DONE));
}

#define INSERT_SONG "INSERT OR REPLACE INTO content (name,songNo,langId,lyrics,categoryId) VALUES (?,?,?,?,?)"
-(BOOL)persistEachSong:(NSDictionary*)songDict langId:(NSInteger)langId   categoryId:(NSInteger)categoryId  songId:(NSInteger)songId{
	int success = SQLITE_ERROR;	
	
	@synchronized(self) {
		// make sure we still have a database now we have a lock
		if(database) {		
			sqlite3_stmt* sqlStmt = nil;
			
			if ((success = sqlite3_prepare_v2(database, INSERT_SONG, -1, &sqlStmt, NULL) == SQLITE_OK)) {
				int columnNumber = 1;
				
				sqlite3_bind_text(sqlStmt, columnNumber++, [[songDict objectForKey:keyTitleName] UTF8String], -1, SQLITE_STATIC);

				NSArray * subArray =  [songDict objectForKey:@"titleArrayKey" ];
				NSDictionary * tempFeedDict =  [subArray objectAtIndex:1];
				sqlite3_bind_text(sqlStmt, columnNumber++, [[tempFeedDict objectForKey:kObjectSongNo] UTF8String], -1, SQLITE_STATIC);
				sqlite3_bind_int(sqlStmt, columnNumber++, langId);
				sqlite3_bind_text(sqlStmt, columnNumber++, [[tempFeedDict objectForKey:kLyrics] UTF8String], -1, SQLITE_STATIC);
        		sqlite3_bind_int(sqlStmt, columnNumber++, categoryId);
				
				
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == columnNumber), @"Column count in prepared statement does not match the number of columns bound");
				
				success = sqlite3_step(sqlStmt);
				
				sqlite3_finalize(sqlStmt);	
				
				if((success != SQLITE_OK) && (success != SQLITE_DONE))
				{
					DLog(@"Error: failed to execute SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
				}
			} else {
				DLog(@"Error: failed to prepare SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
			}
		}
	}
	
	return ((success == SQLITE_OK) || (success != SQLITE_DONE));
}

// ( "name"   VARCHAR , "songNo"  VARCHAR, "langId"  NUMERIC, "lyrics"  VARCHAR , "forceAlternateURL" , "alternateURL"  VARCHAR)
//#define INSERT_S       (name,songNo,langId,lyrics,forceAlternateURL,alternateURL) VALUES (?,?,?,?,?,?)"
#define queryloadFullListSongs   "SELECT rowid,name,songNo,langId,lyrics,categoryId FROM content WHERE langId = ?"
#define queryLoadSongForCategory "SELECT rowid,name,songNo,langId,lyrics,categoryId FROM content WHERE categoryId=?"
-(void)loadAllSongs:(NSMutableArray*)songs withCategoryId:(NSInteger)categoryId
{

                
    NSInteger languageId = [[AppInfo sharedInfo] getSelectedLanguageId];
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {					
			sqlite3_stmt* sqlStmt = NULL;
            
           const char* query = (categoryId > 0) ?  queryLoadSongForCategory : queryloadFullListSongs;
			int success = sqlite3_prepare_v2(database, query, -1, &sqlStmt, NULL);
			
			if(success == SQLITE_OK) {
				
                if(categoryId > 0)
                {
                    sqlite3_bind_int(sqlStmt, 1, categoryId);
                    DAssert((sqlite3_bind_parameter_count(sqlStmt) == 1), @"Column count in prepared statement does not match the number of columns bound");
                }
				else
                {
                    sqlite3_bind_int(sqlStmt, 1, languageId);
                    DAssert((sqlite3_bind_parameter_count(sqlStmt) == 1), @"Column count in prepared statement does not match the number of columns bound");
                }
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {
					int coloumnId = 0;
					NSMutableDictionary *songDict = [NSMutableDictionary dictionary];
					int rowId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:rowId] forKey:@"songRowId"];
					
					const char* data1 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data1) [songDict setObject:[NSString stringWithCString: data1 encoding:NSUTF8StringEncoding] forKey:@"songName"];
					
					const char* data_1 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data_1) [songDict setObject:[NSString stringWithCString: data_1 encoding:NSUTF8StringEncoding] forKey:keySongNo];
					
					int langId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:langId] forKey:@"LangId"];
					
					const char* data2 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data2) [songDict setObject:[NSString stringWithCString: data2 encoding:NSUTF8StringEncoding] forKey:@"lyric"];
                    
                    int categoryId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:categoryId] forKey:@"CategoryId"];

					
					if(songDict)
						[songs addObject:songDict];
					else {
						DAssert([songDict count] != 0, @"songDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare kSelectTable. %s", sqlite3_errmsg(database));
			}
		}
	}	
}

#define queryLoadSongForName "SELECT rowid,name,songNo,langId,lyrics,categoryId FROM content WHERE name=?"
-(void)loadSong:(NSMutableArray*)songs withName:(NSString*)name
{
	//NSMutableArray* songs = [NSMutableArray arrayWithCapacity:0];
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = NULL;
            
            const char* query = queryLoadSongForName;
			int success = sqlite3_prepare_v2(database, query, -1, &sqlStmt, NULL);
			
			if(success == SQLITE_OK) {
				
                if(name)
                {
                    sqlite3_bind_text(sqlStmt, 1, [name UTF8String], -1,SQLITE_STATIC);
                    DAssert((sqlite3_bind_parameter_count(sqlStmt) == 1), @"Column count in prepared statement does not match the number of columns bound");
                }
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {
					int coloumnId = 0;
					NSMutableDictionary *songDict = [NSMutableDictionary dictionary];
					int rowId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:rowId] forKey:@"songRowId"];
					
					const char* data1 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data1) [songDict setObject:[NSString stringWithCString: data1 encoding:NSUTF8StringEncoding] forKey:@"songName"];
					
					const char* data_1 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data_1) [songDict setObject:[NSString stringWithCString: data_1 encoding:NSUTF8StringEncoding] forKey:keySongNo];
					
					int langId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:langId] forKey:@"LangId"];
					
					const char* data2 = (const char*)sqlite3_column_text(sqlStmt,  coloumnId++);
					if (data2) [songDict setObject:[NSString stringWithCString: data2 encoding:NSUTF8StringEncoding] forKey:@"lyric"];
                    
                    int categoryId = sqlite3_column_int(sqlStmt,  coloumnId++);
					[songDict setObject:[NSNumber numberWithInt:categoryId] forKey:@"CategoryId"];
                    
					
					if(songDict)
						[songs addObject:songDict];
					else {
						DAssert([songDict count] != 0, @"songDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare kSelectTable. %s", sqlite3_errmsg(database));
			}
		}
	}	
}

-(void)loadAllCategories:(NSMutableArray*)categories{
    
    NSInteger languageId = [[AppInfo sharedInfo] getSelectedLanguageId];
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {					
			sqlite3_stmt* sqlStmt = NULL;
			int success = sqlite3_prepare_v2(database, loadCategories, -1, &sqlStmt, NULL);
			
            if(success == SQLITE_OK) {
				
				sqlite3_bind_int(sqlStmt, 1, languageId);
				sqlite3_bind_int(sqlStmt, 2, languageId*2);

				DAssert((sqlite3_bind_parameter_count(sqlStmt) == column), @"Column count in prepared statement does not match the number of columns bound");
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {
					NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];
					int rowId = sqlite3_column_int(sqlStmt,  0);
					[categoryDict setObject:[NSNumber numberWithInt:rowId] forKey:keyCategoryId];
					
					const char* data1 = (const char*)sqlite3_column_text(sqlStmt,  1);
					if (data1) [categoryDict setObject:[NSString stringWithCString: data1 encoding:NSUTF8StringEncoding] forKey:keyCategoryNameDB];

                    const char* data2 = (const char*)sqlite3_column_text(sqlStmt,  2);
					if (data2) [categoryDict setObject:[NSString stringWithCString: data2 encoding:NSUTF8StringEncoding] forKey:keyCategoryRangeXML];

					if(categoryDict)
						[categories addObject:categoryDict];
					else {
						DAssert([languageDict count] != 0, @"languageDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare loadLanguages. %s", sqlite3_errmsg(database));
			}
		}
	}	
}

#define INSERT_FAVORITE "INSERT OR REPLACE INTO favorites (name,langId) VALUES (?,?)"
-(BOOL)persistFavorite:(NSString*)name withLangId:(NSInteger) langId{
	int success = SQLITE_ERROR;
	@synchronized(self) {
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = nil;
			
			if ((success = sqlite3_prepare_v2(database, INSERT_FAVORITE, -1, &sqlStmt, NULL) == SQLITE_OK)) {
				int columnNumber = 1;
				sqlite3_bind_text(sqlStmt, columnNumber++, [name UTF8String], -1, SQLITE_STATIC);
                
				sqlite3_bind_int(sqlStmt, columnNumber++, langId);
                
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == columnNumber), @"Column count in prepared statement does not match the number of columns bound");
				success = sqlite3_step(sqlStmt);
				
				sqlite3_finalize(sqlStmt);
				
				if((success != SQLITE_OK) && (success != SQLITE_DONE))
				{
					DLog(@"Error: failed to execute SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
				}
			} else {
				DLog(@"Error: failed to prepare SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
			}
		}
	}
	
	return ((success == SQLITE_OK) || (success != SQLITE_DONE));
}
#define DELETE_FAVORITE "Delete from favorites WHERE name=?"
-(BOOL)deleteFavorite:(NSString*)name{
	int success = SQLITE_ERROR;
	@synchronized(self) {
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = nil;
			
			if ((success = sqlite3_prepare_v2(database, DELETE_FAVORITE, -1, &sqlStmt, NULL) == SQLITE_OK)) {
				int columnNumber = 1;
				sqlite3_bind_text(sqlStmt, columnNumber++, [name UTF8String], -1, SQLITE_STATIC);
                
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == columnNumber), @"Column count in prepared statement does not match the number of columns bound");
				success = sqlite3_step(sqlStmt);
				
				sqlite3_finalize(sqlStmt);
				
				if((success != SQLITE_OK) && (success != SQLITE_DONE))
				{
					DLog(@"Error: failed to execute SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
				}
			} else {
				DLog(@"Error: failed to prepare SET_ADDON_RESULT_PARSER. %s", sqlite3_errmsg(database));
			}
		}
	}
	
	return ((success == SQLITE_OK) || (success != SQLITE_DONE));
}
#define queryloadAllFavorites "select * from favorites WHERE langId=?"
-(void)loadAllFavorites:(NSMutableArray*)favorites{
    
    NSInteger languageId = [[AppInfo sharedInfo] getSelectedLanguageId];
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = NULL;
			int success = sqlite3_prepare_v2(database, queryloadAllFavorites, -1, &sqlStmt, NULL);
			
            if(success == SQLITE_OK) {
                sqlite3_bind_int(sqlStmt, 1, languageId);
                
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == column), @"Column count in prepared statement does not match the number of columns bound");
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {
					NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];

					const char* data1 = (const char*)sqlite3_column_text(sqlStmt,  0);
					if (data1) [categoryDict setObject:[NSString stringWithCString: data1 encoding:NSUTF8StringEncoding] forKey:keyFavoritesNameDB];
					
					if(categoryDict)
						[favorites addObject:categoryDict];
					else {
						DAssert([languageDict count] != 0, @"languageDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare loadLanguages. %s", sqlite3_errmsg(database));
			}
		}
	}	
}



-(void)deleteSongsforLanguage:(NSInteger)languageId{

    [self deleteFromTableCategories:languageId];
    [self deleteFromTableContent:languageId];

}

#define deleteCategories "delete  from categories WHERE categoryId BETWEEN ? AND ?"
#define deleteContent  "delete  from content WHERE langId = ?"
-(void)deleteFromTableCategories:(NSInteger)languageId{
    
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = NULL;
			int success = sqlite3_prepare_v2(database, deleteCategories, -1, &sqlStmt, NULL);
			
            if(success == SQLITE_OK) {
				
				sqlite3_bind_int(sqlStmt, 1, languageId);
				sqlite3_bind_int(sqlStmt, 2, languageId*2);
                
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == column), @"Column count in prepared statement does not match the number of columns bound");
//                int row =0;
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {

					if (1)
                    {
//                        NSLog(@"DeletingCategories for lang %d row %d",languageId, row++);
                    }
					else {
						DAssert([languageDict count] != 0, @"languageDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare loadLanguages. %s", sqlite3_errmsg(database));
			}
		}
	}	
}

-(void)deleteFromTableContent:(NSInteger)languageId{
    
	@synchronized(self)
	{
		// make sure we still have a database now we have a lock
		if(database) {
			sqlite3_stmt* sqlStmt = NULL;
			int success = sqlite3_prepare_v2(database, deleteContent, -1, &sqlStmt, NULL);
			
            if(success == SQLITE_OK) {
				
				sqlite3_bind_int(sqlStmt, 1, languageId);
                
				DAssert((sqlite3_bind_parameter_count(sqlStmt) == column), @"Column count in prepared statement does not match the number of columns bound");
//                int row =0;
				while(sqlite3_step(sqlStmt) == SQLITE_ROW) {
                    
					if (1)
                    {
//                        NSLog(@"deleteFromTableContent for lang %d row %d",languageId, row++);
                    }
					else {
						DAssert([languageDict count] != 0, @"languageDict is nil");
					}
				}
				sqlite3_finalize(sqlStmt);
				// for each result, create a requestResult and add it to the array
			} else {
				DLog(@"Error: failed to prepare loadLanguages. %s", sqlite3_errmsg(database));
			}
		}
	}	
}


+ (Database*)instance
{
	static Database *s_Database = nil;

    if (s_Database == nil) {
		
		@synchronized([Database class]) {	
			
			s_Database = [self singleton];
			
		}
	}
	
    return s_Database;
}

- (void) dealloc
{
	[self shutDown];
}

-(void)shutDown
{
	DLog(@"");

	if (database)		
	{
		
		@synchronized(self) 

		{
			// I think alot of these queries are done so irregularly that we shouln't kepe them around for the 
			
			// whole time and just create/destroy as needed	
			

			
			sqlite3_close(database);
			
			database = NULL;
			
		}

	}

}


@end
