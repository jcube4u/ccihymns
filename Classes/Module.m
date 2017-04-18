//
//  Module.m



#import "Module.h"

@implementation Module
@synthesize title;
@synthesize url;
@synthesize icon;
@synthesize controller;
@synthesize modulePosition;

- (id) initWithTitle: (NSString *) aTitle 
				 url: (NSString *) aUrl
				icon: (UIImage *) anIcon 
		  controller: (id) aController 
			position: (position) aPosition
{
	self = [super init];
	if (self != nil) {
		self.title = aTitle;
		self.url = aUrl;
		self.icon = anIcon;
		self.controller = aController;
		self.modulePosition = aPosition;
	}
	return self;
}


@end
