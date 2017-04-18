//
//  FFSAPICaller.h
//

#import "Constants.h"

@interface FFSAPICaller : NSObject {
	CFMutableDictionaryRef connections;	
	int	ResultBase;
}

+ (FFSAPICaller *) sharedCaller;
- (NSString *) getSongListForLanguage:(NSString*)language error:(NSError **) error;
- (NSString *) getSettings: (NSError **) error;
- (NSString *) getImage: (NSString *) imageUrl error: (NSError **) error;
- (NSString *) getXMLFeed: (NSString *) feedUrl sourceName:(NSString *)sourceName error: (NSError **) error;

- (void) requestWithArray: (NSMutableArray *) callArray error: (NSError **) error;

- (void) runAsyncRequestWithURLString: (NSString *) requestString context: (void *) context error: (NSError **) error;

- (void) processResult: (NSMutableDictionary *) dict;

- (NSDictionary *) extractImageDictFromDict: (NSMutableDictionary *) dict error: (NSError *) error;
- (NSDictionary *) extractResultsFromXML: (NSString *) resultString rootNode: (NSString *) rootNode error: (NSError *) error;
- (id) parseNodes: (NSArray *) resultNodes level: (int) level;

- (void) failedWithError: (NSString *) errorMessage name: (NSString *) name;


@end
