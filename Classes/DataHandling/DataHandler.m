//
//  DataHandler.m
//  Mahima
//
//  Created by George, Jidh on 14/01/2013.
//
//

#import "DataHandler.h"
#import "FFSAPICaller.h"
#import "Database.h"

@interface DataHandler()
@property (nonatomic,strong) NSString *language;
@end
@implementation DataHandler
@synthesize  language = _language;
@synthesize  delegate = _delegate;

-(id)initWithDelegate:(id)_delegateObj
{
	if (self = [super init]) {
		self.delegate = _delegateObj;
    }
	
	return self;
}
-(void)showErrorMessage
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"NO CONNECTIVITY"
                                                         message: @"Unable to connect to the network"
                                                        delegate: self
                                               cancelButtonTitle: nil
                                               otherButtonTitles: @"OK", nil];
    
    [alertView show];
    alertView = nil;
}

-(BOOL)requestSongsForlanguages:(NSString*)language
{
    self.language  = language;
    BOOL unableToConnect = NO;
    NSError * error = nil;
    NSString * notificationName  = [[FFSAPICaller sharedCaller] getSongListForLanguage:language error: &error];
    if (!error) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(APICallbackMedia:) name: notificationName object: nil];
    }
    else
    {
        [self showErrorMessage];
        unableToConnect = YES;
    }
    return unableToConnect;
}

- (NSInteger)obtainLanguageForList:(NSArray *)recievedArray
{
    NSInteger language = NSNotFound;
    for( NSDictionary *resultDict in recievedArray)
	{
        if([resultDict objectForKey:keyLanguage])
		{
            self.language = [resultDict objectForKey:keyLanguage];
            language  = ([self.language caseInsensitiveCompare:kLanguageEnglish] == NSOrderedSame) ? kLanguageEnglishID:([self.language caseInsensitiveCompare:kLanguageYoruba]== NSOrderedSame ? kLanguageYorubaID : NSNotFound);
            break;
		}
	}
    return language;
}
- (void)populateCategory:(NSMutableArray *)mediaListArray recievedArray:(NSArray *)recievedArray
{
    for( NSDictionary *resultDict in recievedArray)
	{
		
		if([resultDict objectForKey:keyCategoryNameXML])
		{
			NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init ];
			NSString *stringToAdd = [NSString stringWithFormat:@"%@",[resultDict objectForKey:keyCategoryNameXML]];
            NSString *categoryRange = [NSString stringWithFormat:@"%@",[resultDict objectForKey:keyCategoryRangeXML]];

			BOOL newCategory = YES;
			for(NSDictionary *addedDict in mediaListArray)
			{
				if([stringToAdd isEqualToString: [addedDict objectForKey: keyCategoryNameXML]])
				{
					/// Category Exists in the list hence continue
					newCategory = NO;
					break;
				}
			}
			if(newCategory)
			{
				NSMutableArray *mediaMainArray = [[NSMutableArray alloc]  init];
				[categoryDict setObject:mediaMainArray forKey:keyCategoryArray ];
				[categoryDict setObject:stringToAdd forKey:keyCategoryNameXML ];
				[categoryDict setObject:categoryRange forKey:keyCategoryRangeXML ];
				[mediaListArray addObject:categoryDict];
			}
			
		}
	}
}

//http://yeshumasiha.com/Test/mobile/ios/songbook/BenHymnsEng.xml
- (void) APICallbackMedia: (NSNotification *) notification
{
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: [notification name] object: nil];
    
	NSArray *recievedArray =  [[notification userInfo] objectForKey: @"result"];
	NSMutableArray *mediaListArray = [[NSMutableArray alloc] init];
   
    
    NSInteger languageId = [self obtainLanguageForList:recievedArray];
    if(0 && languageId == 1000)
    {
        
        [self printTitle:recievedArray];
        
    }
	[self populateCategory:mediaListArray recievedArray:recievedArray];
    
	// iterate again the group all the song/ Title  Set that belong to the category / language
	for( NSDictionary *resultDict in recievedArray)
	{
		NSMutableArray *categoryArray;
        
		if([resultDict objectForKey:keyCategoryNameXML])
		{
			NSString *category = [resultDict objectForKey:keyCategoryNameXML];
            //	NSLog(@"--- %@",category);
            
			for(NSDictionary *dict in mediaListArray)
			{
				if([category isEqualToString: [dict objectForKey: keyCategoryNameXML]])
				{
					categoryArray = [dict objectForKey: keyCategoryArray];
					break;
				}
			}
            
		}
		
		if(categoryArray)
		{
			if([resultDict objectForKey: @"title"])
			{
				NSMutableDictionary *titleDict = [[NSMutableDictionary alloc] init ];
				NSMutableArray *titleArray = [[NSMutableArray alloc] init ];
                NSString *title= [resultDict objectForKey: @"title"];
				[titleDict setObject:title forKey:keyTitleName];
				[titleDict setObject: titleArray forKey:keyTitleArray];
				
				/// Obtain the dictionary just added / to use it in to add the tracks for the title
				[categoryArray addObject:titleDict];
			}
			
		}
	}
	
	for( NSDictionary *resultDict in recievedArray)
	{

        NSMutableArray *categoryArray = nil;
        NSMutableArray *tracksArray = nil;
        
        if([resultDict objectForKey:keyCategoryNameXML])
        {
            NSString *category = [resultDict objectForKey:keyCategoryNameXML];
            //NSLog(@"--- %@",category);
            
            for(NSDictionary *dict in mediaListArray)
            {
                if([category isEqualToString: [dict objectForKey: keyCategoryNameXML]])
                {
                    categoryArray = [dict objectForKey:keyCategoryArray];
                    break;
                }
            }
            
        }
        
        if(categoryArray)
        {
            if([resultDict objectForKey: @"title"])
            {
                
                NSString *titleName = [resultDict objectForKey: @"title"];
                for(NSDictionary *dict in categoryArray)
                {
                    if([titleName isEqualToString: [dict objectForKey: keyTitleName]])
                    {
                        tracksArray = [dict objectForKey: keyTitleArray];
                        break;
                    }
                }
                
            }
            
        }
        if(tracksArray)
            if([resultDict objectForKey: kMedia])
            {
                
                NSArray *mediaArray =  [resultDict valueForKey: @"media"];
                for(int j = 0; j< [mediaArray count]; j++)
                {
                    NSDictionary *mediaDict =  [mediaArray objectAtIndex:j];
                    
                    NSMutableDictionary		*mediaObjectDict = [NSMutableDictionary dictionary];/// with  4 items
                                     
                    if([mediaDict objectForKey: @"lyrics"])
                    {
                        NSString *itemText = [mediaDict objectForKey: @"lyrics"];
                        //NSLog(@"/ %d - %@", j, itemText);
                        NSMutableString *stringToAdd = [NSMutableString stringWithFormat:@"%@",itemText];
                        [mediaObjectDict setObject:stringToAdd forKey:kLyrics ];
                    }
                    if([mediaDict objectForKey: keySongNo])
                    {
                        NSString *itemText = [mediaDict objectForKey:keySongNo];
                        //NSLog(@" / %d - %@", j, itemText);
                        NSMutableString *stringToAdd = [NSMutableString stringWithFormat:@"%@",itemText];
                        [mediaObjectDict setObject:stringToAdd forKey:kObjectSongNo];
                    }
                    [tracksArray addObject:mediaObjectDict];
                }
                
            }

		
	}
    
//	NSLog(@"Finished Reading");
	DLog(@"Retrieved  %@",mediaListArray);
	
	if(mediaListArray)
    {
		/// We can safely say that the contents
		[[Database instance] deleteSongsforLanguage:languageId];
	}
	BOOL saveSuccess = [[Database instance] persistSongs:mediaListArray forLanguageId:languageId];
	if(saveSuccess){

		
        if(languageId == kLanguageYorubaID)
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kListUpdatedOnClientForYoruba];
        if(languageId == kLanguageEnglishID)
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kListUpdatedOnClientForEnglish];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForEnglish] boolValue] &&
           [[[NSUserDefaults standardUserDefaults] objectForKey:kListUpdatedOnClientForYoruba] boolValue])
        {
            NSDate *cutOffDate =  [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject: cutOffDate forKey: @"lastLoadedDate"];   
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kListVersionChanged];
        }
	}
    if([self.delegate respondsToSelector:@selector(dataResponse:successState:andLanguage:)])
    {
        kLanguagesEnum language = (kLanguagesEnum)[self.language isEqualToString:kLanguageEnglish] ? kLanguageEnumEnglish : kLanguageEnumYoruba;
            
        [self.delegate dataResponse:self successState:saveSuccess andLanguage:language];
    }

}

-(void)printTitle:(NSArray *)recievedArray
{
    NSMutableString *songList = [[NSMutableString alloc] init];
    
    for( NSDictionary *resultDict in recievedArray)
	{

        
        NSArray *mediaArray =  [resultDict valueForKey: @"media"];
        NSString *lyrics = nil;
        NSString *songNo = nil;
        
        for(int j = 0; j< [mediaArray count]; j++)
        {
            NSDictionary *mediaDict =  [mediaArray objectAtIndex:j];
            if([mediaDict objectForKey: @"lyrics"])
            {
                lyrics = [mediaDict objectForKey: @"lyrics"];


            }
            if([mediaDict objectForKey: keySongNo])
            {
                songNo = [mediaDict objectForKey:keySongNo];
            }

        }
        NSString *newTitle =nil;
        NSArray *lines = [lyrics componentsSeparatedByString:@"="];
        if(lines.count >0)
        {
            newTitle = [lines objectAtIndex:0];
            NSString *trimmedString = [newTitle stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceCharacterSet]];
        
        
            NSString *song = [NSString stringWithFormat:@"<media title=\"%@\" category=\"%@\">\n <song songNo=\"%@\" writer =\"Holy Spirit\" lyrics=\"\n%@\n\"/>\n</media>\n",trimmedString,[resultDict objectForKey:keyCategoryNameXML],songNo,lyrics ];
            [songList appendString:song];
        }
    }
//    NSLog(@"SongList  %@",songList);

}


@end
