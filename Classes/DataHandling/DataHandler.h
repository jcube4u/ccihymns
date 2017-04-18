//
//  DataHandler.h
//  Mahima
//
//  Created by George, Jidh on 14/01/2013.
//
//
#import "Constants.h"
#import <Foundation/Foundation.h>

typedef enum kLanguagesEnum
{
    kLanguageEnumYoruba = 0,
    kLanguageEnumEnglish = 1,
}kLanguagesEnum;

@class DataHandler;

@protocol DataHandlerDelegate <NSObject>

-(void)dataResponse:(DataHandler *)object successState:(BOOL)state andLanguage:(kLanguagesEnum)language;

@end

@interface DataHandler : NSObject
@property (nonatomic,weak) id <DataHandlerDelegate> delegate;
-(BOOL)requestSongsForlanguages:(NSString*)language;
-(id)initWithDelegate:(id)_delegate;
@end
