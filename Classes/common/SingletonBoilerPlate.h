//
//  SingletonBoilerPlate.h
//  Mahima
//
//  Created by Jidh on 31/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SingletonBoilerPlate : NSObject {
	
	
}
+ (id)singleton;

+ (id)singletonWithZone:(NSZone*)zone;

//designated initializer, subclasses must implement and call supers implementation
- (id)initSingleton; 
@end

