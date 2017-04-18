//
//  SingletonBoilerPlate.m
//  Mahima
//
//  Created by Jidh on 31/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingletonBoilerPlate.h"



@implementation SingletonBoilerPlate
static NSMutableDictionary  *s_AbstractSingleton_singletons = nil;
+ (void)initialize
{
    @synchronized([SingletonBoilerPlate class]) {
		
        if (s_AbstractSingleton_singletons == nil) {
			
            s_AbstractSingleton_singletons = [[NSMutableDictionary alloc] init];
			
        }
		
    }
	
}


// Should be considered private to the abstract singleton class, 
// wrap with a "sharedXxx" class method
+ (id)singleton
{
    return [self singletonWithZone:[self zone]];
}
// Should be considered private to the abstract singleton class
+ (id)singletonWithZone:(NSZone*)zone
{
    id singleton = nil;
    Class class = [self class];
    if (class == [SingletonBoilerPlate class]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Not valid to request the abstract singleton."];
		
    }
    @synchronized([SingletonBoilerPlate class]) {
        singleton = [s_AbstractSingleton_singletons objectForKey:class];
        if (singleton == nil) {
			// the analyhzer thinks this is a leak because singleton is not retained
			// but the setObject below will retain it
			singleton = NSAllocateObject(class, 0U, zone);
			NSIncrementExtraRefCount(singleton);
            if ((singleton = [singleton initSingleton]) != nil) {
	              [s_AbstractSingleton_singletons setObject:singleton forKey:class];
	        }
			NSDecrementExtraRefCountWasZero(singleton);
			
        }
		
    }
    return singleton;
	
}
// Designated initializer for instances. If subclasses override they

// must call this implementation.
- (id)initSingleton
{
   return [super init];
	
}
// Disallow the normal default initializer for instances.
- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
	
}
// ------------------------------------------------------------------------------
// The following overrides attempt to enforce singleton behavior.
+ (id)new
{
    return [self singleton];
}
+ (id)allocWithZone:(NSZone *)zone
{
    return [self singletonWithZone:zone];
}

+ (id)alloc
{
    return [self singleton];
}
- (id)copy
{
    //[self doesNotRecognizeSelector:_cmd]; //optional, do if you want to force certain usage pattern
    return self;
	
}
- (id)copyWithZone:(NSZone *)zone
{
    //[self doesNotRecognizeSelector:_cmd]; //optional, do if you want to force certain usage pattern
    return self;
}
- (id)mutableCopy
{
    //[self doesNotRecognizeSelector:_cmd]; //optional, do if you want to force certain usage pattern
    return self;	
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    //[self doesNotRecognizeSelector:_cmd]; //optional, do if you want to force certain usage pattern
    return self;
}
@end
