//
//  Constants.h
//  MahimaApp
//
//  Created by Jidh on 23/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#define ACTIVITY_INDICATOR_LEFTOFFSET		140
#define ACTIVITY_INDICATOR_HEIGHT_OFFSET	180
#define ACTIVITY_INDICATOR_SIZE			40

#define	LEFT_TEXT_OFFSET_ITEM_NAME  15		

#ifdef CONFIGURATION_Debug  
#define DLog(fmt, ...) NSLog((@"object:%p %s [Line %d] " fmt), self,  __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define DLogC(fmt, ...) NSLog((@"%s [Line %d] " fmt),  __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)		// no self
#else  
#define DLog(...)  
#define DLogC(...)  
#endif 

#ifdef CONFIGURATION_Debug  
#define DAssert(ass,msg) NSAssert(ass,msg)
#else  
#define DAssert(ass,msg)
#endif  


#define APP_VERSION				@"1.0.0"

//http://yeshumasiha.com/Test/mobile/ios/songbook/BenHymnsEng.xml
//#define kUrlApi					@"http://www.ourcss.com/ccci-hymns/"
//#define kInfoUrlApi				@"http://www.ourcss.com/ccci-hymns/info.html";

//#define kUrlApi					@"http://ourcss.com/mobile/iPhone/cccihymns/"
//#define kInfoUrlApi				@"http://ourcss.com/mobile/iPhone/cccihymns/info.html";
#define kUrlApi                    @"https://hayngels.com/ccihymns/1.0/"
#define kInfoUrlApi                @"https://hayngels.com/ccihymns/1.0/info/info.html";

#define kFileNameSongListEng			@"English.xml"
#define kFileNameSongListYoruba			@"Yourba.xml"
#define kFileNameSettings			@"settings.xml"


#define	MIN_SONGS_TO_SAVE			10
extern NSString * const kSessionKey;

extern NSString * const kModuleUrl;
extern NSString * const keyTitleName;



#define kMedia				@"media"

#define keyLanguage			@"language"
/// Accesing Keys
#define  keyCategoryArray	@"categoryArrayKey"
#define keyCategoryNameXML		@"category"
#define keyCategoryRangeXML		@"categoryRange"

#define keyTitle			@"title"
#define keyTitleArray		@"titleArrayKey"

#define keyTitleName		@"TitleName"
#define keySongNo			@"songNo"

#define kMediaObjectDict	@"MediaObjectKey"
#define kDuration			@"DurationKey"


#define kForceAlternateURL			@"forceAlternateURL"
#define kAlternateURL			@"alternateURL"

#define kLyrics             @"LyricsKey"
#define kMediaObjectTitle	@"MediaObjectTitleKey"
#define kObjectSongNo       @"ObjectSongNoKey"
#define kMediaObjectArray	@"kMediaObjectArrayKey"

/// General List Version
#define kSavedListVersionNumber	@"SavedListVersionNumber"
#define kListVersionChanged		@"ListVersionChanged"
#define kListUpdatedOnClientForEnglish	@"ListUpdatedOnClientForEnglish"
#define kListUpdatedOnClientForYoruba	@"ListUpdatedOnClientForYoruba"

// FontSixe
#define kSavedFontSize          @"SavedFontSize"

// Languages
#define kSavedLanguage          @"SavedLanguage"
#define kLanguageYoruba         @"Yoruba"
#define kLanguageEnglish        @"English"
#define kLanguageEnglishID      1000
#define kLanguageYorubaID       2000
#define kMAXCATEGORYOFFSET      10


#define kModuleListYoruba       @"ModuleListYoruba"
#define kModuleListEnglish      @"ModuleListEnglish"
#define kModuleListLanguages    @"ModuleListLanguages"

#define keyCategoryId           @"categoryId"
#define keyCategoryNameDB		@"name"
#define keyFavoritesNameDB		@"name"
#define keySongName             @"songName"
#define keySongLyric            @"lyric"


