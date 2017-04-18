//
//  Module.h


typedef struct _position {
	int x;
	int y;
} position;

@interface Module : NSObject {
	NSString * title;
	NSString * url;
	UIImage * icon;
	id controller;
	position modulePosition;
}

- (id) initWithTitle: (NSString *) aTitle 
				 url: (NSString *) aUrl
				icon: (UIImage *) anIcon 
		  controller: (id) aController 
			position: (position) aPosition;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) UIImage * icon;
@property (nonatomic, strong) id controller;
@property position modulePosition;

@end
