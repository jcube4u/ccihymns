//
//  FFSAPICaller.m
//



#import "FFSAPICaller.h"
#import "AppInfo.h"

#import "TouchXML.h"
#import "Reachability.h"
#import "Constants.h"
NSString * const kAPICallSongListEng = kFileNameSongListEng;
NSString * const kAPICallSongListYoruba = kFileNameSongListYoruba;
NSString * const kAPICallsettings = kFileNameSettings;

NSString * const kAPICallImage = @"image";
NSString * const kAPIKeyCall = @"call";
NSString * const kURLReqestURL = @"url";
NSString * const kURLReqestData = @"data";
NSString * const kURLReqestContext = @"context";
NSString * const kURLRootNode = @"rootNode";

NSString * const kAPIKeyMessage = @"message";

static id _APICaller = nil;

@implementation FFSAPICaller

+ (FFSAPICaller *) sharedCaller 
{
	if (!_APICaller)
		_APICaller = [[FFSAPICaller alloc] init];
	
	return (FFSAPICaller *)_APICaller;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		//*******************************************************
		//* Dictionary for storing NSURLConnections 
		//* Using a CFDictionary so we can use connection as a key
		//* NSDictionary keys must conform to NSCopying
		//*******************************************************
		
		connections = CFDictionaryCreateMutable(kCFAllocatorDefault,
												0,
												&kCFTypeDictionaryKeyCallBacks,
												&kCFTypeDictionaryValueCallBacks);
		ResultBase = 1;
	}
	return self;
}

- (void) dealloc
{
	CFRelease(connections);
	[super dealloc];
}
//*******************************************************
//* getSongList
//*
//* 
//*******************************************************
- (NSString *) getSongListForLanguage:(NSString*)language error:(NSError **) error
{
    
    NSString *languageType =  ([language isEqualToString:kLanguageEnglish]) ? kAPICallSongListEng : kAPICallSongListYoruba;
    
	NSMutableArray * callArray = [[NSMutableArray alloc] initWithObjects: 
								  [NSDictionary dictionaryWithObjectsAndKeys: languageType, kAPIKeyCall, nil], nil];
	
	[self requestWithArray: callArray error: error];
	[callArray release];
	ResultBase = 0;
	
	return  [NSString stringWithFormat: @"%@FinishedNotification", languageType];	
	
	
}

//*******************************************************
//* getSettings
//*x
//* 
//*******************************************************
- (NSString *) getSettings: (NSError **) error
{
	NSMutableArray * callArray = [[NSMutableArray alloc] initWithObjects: 
								  [NSDictionary dictionaryWithObjectsAndKeys: kAPICallsettings, kAPIKeyCall, nil], nil];
	
	[self requestWithArray: callArray error: error];
	[callArray release];
	ResultBase = 0;
	
	return  [NSString stringWithFormat: @"%@FinishedNotification", kAPICallsettings];		
	
	
}
//*******************************************************
//* getXMLFeed:
//* 
//* 
//*******************************************************
- (NSString *) getXMLFeed: (NSString *) feedUrl sourceName:(NSString *)sourceName error: (NSError **) error
{

	NSMutableArray * callArray = [[NSMutableArray alloc] initWithObjects: 
								  [NSDictionary dictionaryWithObjectsAndKeys: sourceName, kAPIKeyCall, nil], 
								  [NSDictionary dictionaryWithObjectsAndKeys: @"channel", kURLRootNode, nil], nil];
	
	[self runAsyncRequestWithURLString: feedUrl context: callArray error: error];
	[callArray release];
	
	return  [NSString stringWithFormat: @"%@FinishedNotification", sourceName];	
}
//*******************************************************
//* getTourDates:
//*
//* 
//*******************************************************
- (NSString *) getImage: (NSString *) imageUrl error: (NSError **) error
{
	NSMutableArray * callArray = [[NSMutableArray alloc] initWithObjects: 
								  [NSDictionary dictionaryWithObjectsAndKeys: kAPICallImage, kAPIKeyCall, nil], nil];
	
	[self runAsyncRequestWithURLString: imageUrl context: callArray error: error];
	[callArray release];
	
	return  [NSString stringWithFormat: @"%@FinishedNotification", kAPICallImage];	
}



//*******************************************************
//* createRequest:
//*
//* 
//*******************************************************
- (void) requestWithArray: (NSMutableArray *) callArray error: (NSError **) error
{
	NSString * requestURL = [NSString stringWithFormat: kUrlApi];

	for (NSDictionary * callValue in callArray) {
		NSString * key = [[callValue allKeys] lastObject];
		NSString * value = [callValue valueForKey: key];
		
		requestURL = [requestURL stringByAppendingPathComponent: value];
	}
	


	
	[callArray addObject: [NSDictionary dictionaryWithObject: @"root" forKey: kURLRootNode]];
	[self runAsyncRequestWithURLString: requestURL context: callArray error: error];
}

//*******************************************************
//* runAsyncRequestWithString:type:
//*
//* 
//*******************************************************
- (void) runAsyncRequestWithURLString: (NSString *) requestString context: (void *) context error: (NSError **) error
{
	NSLog(@"URL request: %@", requestString);

    if ([[AppInfo sharedInfo] remoteHostStatus] == NotReachable) {

        *error = [NSError errorWithDomain: @"FFSAPICallerErrorDomain"
                                    code: 999
                                userInfo: [NSDictionary dictionaryWithObject: @"Connection to server failed." forKey: NSLocalizedDescriptionKey]];
        return;
    }
//
	//NSLog(requestString);
	NSURL * requestUrl = [NSURL URLWithString: requestString];
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0f];
	[request setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1" forHTTPHeaderField:@"User-Agent"];

	NSURLConnection * requestConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
	
	//*******************************************************
	//* Create a dictionary with mutable data for the incoming data,
	//* the url, and a type.
	//*******************************************************
	NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
										   [NSMutableData data], kURLReqestData,
										   requestString, kURLReqestURL, 
										   context, kURLReqestContext, nil];
	[requestConnection release];
	
	CFDictionaryAddValue(connections, requestConnection, connectionDict);
}

#pragma mark -
#pragma mark NSURLConnection delegate methods
//*******************************************************
//* connection:didReceiveResponse:
//*
//* Get ready to receive data
//*******************************************************
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

//*******************************************************
//* connection:didReceiveData:
//*
//* Append incoming data to the existing string
//*******************************************************
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSMutableDictionary * dict = (NSMutableDictionary *)CFDictionaryGetValue(connections, connection);
	NSMutableData *connectionData = [dict objectForKey: kURLReqestData];
	[connectionData appendData: data];
}

//*******************************************************
//* connection:didFailWithError:
//*
//* Handle error
//*******************************************************
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSMutableDictionary * dict = (NSMutableDictionary *)CFDictionaryGetValue(connections, connection);
	NSMutableDictionary * callArray = [dict objectForKey: kURLReqestContext];
	
	NSString *call;
	
	for (NSDictionary * callValue in callArray) {
		NSString * key = [[callValue allKeys] lastObject];
		if ([key isEqualToString: kAPIKeyCall]) {
			call = [callValue valueForKey: key];
		}
	}
	
	[self failedWithError: @"Connection to server failed." name: call];
	//NSLog(call);
	
	CFDictionaryRemoveValue(connections, connection);	
}

//*******************************************************
//* connectionDidFinishLoading:
//*
//* All data has arrived, so process according to type
//*******************************************************
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self performSelectorInBackground: @selector(processRequest:) withObject: connection];	
	

}

//*******************************************************
//* processRequest:
//*
//* 
//*******************************************************
- (void) processRequest: (NSURLConnection *)connection
{ 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary * dict = (NSMutableDictionary *)CFDictionaryGetValue(connections, connection);
	NSMutableArray * callArray = [dict objectForKey: kURLReqestContext];
	
	NSString *call;
	
	for (NSDictionary * callValue in callArray) {
		NSString * key = [[callValue allKeys] lastObject];
		if ([key isEqualToString: kAPIKeyCall]) {
			call = [callValue valueForKey: key];
		}
	}
	
	//NSLog(@"Finished connection call %@", call);
	//*******************************************************
	//* Process the resulting data
	//*******************************************************
	[self processResult: (NSMutableDictionary *)CFDictionaryGetValue(connections, connection)];

	//*******************************************************
	//* We're done with this connection, so remove it from
	//* the dictionary.
	//*******************************************************
	CFDictionaryRemoveValue(connections, connection);	
	
	[pool release];

}

#pragma mark Data processing methods
//*******************************************************
//* processCreateUser:
//*
//* Parse and process received data
//*******************************************************
- (void) processResult: (NSMutableDictionary *) dict 
{
	NSData * resultData = [dict objectForKey: kURLReqestData];
	NSString * resultString = nil;
	//  for Iso-8859
	
	NSMutableArray * callArray = [dict objectForKey: kURLReqestContext];
	
	NSString *call;
	NSString *root;
	
	for (NSDictionary * callValue in callArray) {
		NSString * key = [[callValue allKeys] lastObject];
		if ([key isEqualToString: kAPIKeyCall]) {
			call = [callValue valueForKey: key];
		}
		if ([key isEqualToString: kURLRootNode]) {
			root = [callValue valueForKey: key];
		}
	}

	resultString = [[[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding] autorelease];
		
	id queryResult = nil;
	NSError * error = nil;

	if ([call isEqualToString: kAPICallImage]) {
		queryResult = [self extractImageDictFromDict: dict error: error];
	}
	else
	{
		queryResult = [self extractResultsFromXML: resultString rootNode: root error: error];
	}
	
	if (error) {
		[self failedWithError: [error localizedDescription] name: call];
	} else {
		NSString * notificationName = [NSString stringWithFormat: @"%@FinishedNotification", call];
		
		NSDictionary * notificationData = [NSDictionary dictionaryWithObjectsAndKeys: 
										   notificationName, @"name",
										   queryResult, @"queryResult", nil];
		
		[self performSelectorOnMainThread: @selector(postNotification:) withObject: notificationData waitUntilDone: NO];	
	}
}

//****************************************************************************************************
//* extractImageDictFromDict:error:
//*
//* Return image data from request
//* 
//* Parameters 
//* ==========
//*  dict: Connection dictionary
//* error: error returned
//* 
//* Returns 
//* ========
//* NSDictionary - kURLReqestData: image data
//*                 kURLReqestURL: original request URL
//* 
//****************************************************************************************************
- (NSDictionary *) extractImageDictFromDict: (NSMutableDictionary *) dict error: (NSError *) error
{
	//NSLog(@"image dict");
	if (![dict objectForKey: kURLReqestData])
		error = [NSError errorWithDomain: @"FFSAPICallerErrorDomain" 
									code: 999 
								userInfo: [NSDictionary dictionaryWithObject: @"No image data returned" forKey: NSLocalizedDescriptionKey]];
		
	NSDictionary * imageDict = [NSDictionary dictionaryWithObjectsAndKeys: [dict objectForKey: kURLReqestData], kURLReqestData,
								[dict objectForKey: kURLReqestURL], kURLReqestURL, nil];
	
	return imageDict;
}	

//****************************************************************************************************
//* extractResultsFromXML:rootNode:error:
//*
//* Parse the results into a dictionary or array
//* 
//* Parameters 
//* ==========
//* resultString: XML string returned from the reqeuest.
//*     rootNode: Top level node of the XML from which to begin parsing
//*        error: error returned from XML parser
//* 
//* Returns 
//* ========
//* NSDictionary parsed from input string
//* 
//****************************************************************************************************
- (NSDictionary *) extractResultsFromXML: (NSString *) resultString rootNode: (NSString *) rootNode error: (NSError *) error
{
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithXMLString: resultString options: 0 error: &error] autorelease];
	
    NSArray * resultNodes = [rssParser nodesForXPath: [NSString stringWithFormat: @"//%@", rootNode] error: &error];
	id queryResult = [self parseNodes: [[resultNodes lastObject] children] level: 0];
    NSLog(@"Query Result %@",queryResult);
	
	return queryResult;
}	

//****************************************************************************************************
//* parseNodes:level:
//*
//* Recursively parse an XML node
//* 
//* Parameters 
//* ==========
//* resultNodes: Array of XML nodes to parse
//*       level: Hierarchy level
//* 
//* Returns 
//* ========
//* NSArray/NSString parsed from input nodes
//* 
//****************************************************************************************************
- (id) parseNodes: (NSArray *) resultNodes level: (int) level
{
	if (!resultNodes)
		return nil;
	
	id resultObject = nil;

	if ([resultNodes count] > ResultBase) {
		//**************************************************************
		//* If level > 0 or more than 1 node, return an array
		//**************************************************************
		resultObject = [NSMutableArray array];
		
		for (int i = 0; i < [resultNodes count]; i++) {
			
			CXMLElement *resultElement = [resultNodes objectAtIndex: i];
			CXMLNodeKind elementKind = [resultElement kind];
			
			NSMutableDictionary * attributesDict = [NSMutableDictionary dictionary];
			
			if (elementKind == CXMLTextKind) {
				[attributesDict setObject: [resultElement stringValue] forKey: [resultElement name]];
			} else {
				if ([resultElement childCount]) 
				{
					id object = [self parseNodes: [resultElement children] level: level + 1];
					if(object == nil)
					{
						//id object = [self parseNodes: [resultElement children] level: level ];
						//NSString *elementName = [resultElement name];
						//NSString *elementName = [resultElement name];
						//NSInteger count = [resultElement childCount];
                        //NSLog(@"Parsing ERROR SKIPPING Object %@  - %ld",elementName,(long)count);
						//continue;
						//[attributesDict setObject: [resultElement name] forKey: [resultElement name]];
						
					}
					else
						[attributesDict setObject: object forKey: [resultElement name]];
				}
				
				if ([(NSObject *)resultElement respondsToSelector: @selector(attributes)]) {
					
					NSArray * elementAttributes = [resultElement attributes];
					
					for (int i = 0; i < [elementAttributes count]; i++) {
						CXMLNode * attribute = [elementAttributes objectAtIndex: i];
						
						[attributesDict setObject: [attribute stringValue] forKey: [attribute name]];
					}
				}
			}
			[resultObject addObject: attributesDict];
		}
	} else {
		CXMLElement *resultElement = [resultNodes lastObject];
		
		if ([resultElement kind] == CXMLTextKind)
				return [resultElement stringValue];
	}
    NSLog(@"Query Result Obejct %@",resultObject);
	return resultObject;
}

//****************************************************************************************************
//* extractResultsFromJSON:error:
//*
//* Parse the results into a dictionary
//* 
//* Parameters 
//* ==========
//* queryResult: JSON string returned from the reqeuest.
//*       error: error returned from JSON parser
//* 
//* Returns 
//* ========
//* NSDictionary parsed from input string
//* 
//****************************************************************************************************

//****************************************************************************************************
//* failedWithError:name:
//*
//* Display an error message for a failed request and post the failure notification.
//* 
//* Parameters 
//* ==========
//* errorMessage: The failure error message
//*         name: The call name 
//* 
//****************************************************************************************************

- (void) failedWithError: (NSString *) errorMessage name: (NSString *) name
{
	if (![errorMessage isEqualToString: @""]) {
		//NSString * title = [NSString stringWithFormat: @"%@ call failed", name];
		NSString * title = [NSString stringWithFormat: @"Connectivity Error"];
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: title message: errorMessage delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alertView show];
		[alertView release];
	}
	
	NSDictionary * notificationData = [NSDictionary dictionaryWithObjectsAndKeys: 
									   [NSString stringWithFormat: @"%@NotificationFail", name], @"name",
									   nil];
	
	[self performSelectorOnMainThread: @selector(postNotification:) withObject: notificationData waitUntilDone: NO];
	
	
}

//****************************************************************************************************
//* postNotification:
//*
//* Posts the notification passed in the notificationData dictionary.
//* 
//* Parameters 
//* ==========
//* notificationData - queryResult: Object returned from the reqeuest (dictionary/array/image data).
//*                           name: The notification name
//* 
//****************************************************************************************************
- (void) postNotification: (NSDictionary *) notificationData
{
	NSDictionary * userInfo = nil;
	
	if ([notificationData objectForKey: @"queryResult"])
		userInfo = [NSDictionary dictionaryWithObject: [notificationData objectForKey: @"queryResult"] forKey: @"result"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: [notificationData objectForKey: @"name"] 
														object: self 
													  userInfo: userInfo];
	ResultBase = 1;
}



@end
