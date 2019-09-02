//
//  ModuleButtonController.m


#import "ModuleButtonController.h"
#import "Constants.h"


@implementation ModuleButtonController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithModuleLauncher: (ModuleViewController *) controller 
				 buttonImage: (UIImage *) image 
					   label: (NSString *) text
						 tag: (int) aTag
                    fontSize:(int)fontSize
{
    if (self = [super init]) {
        launcher = (ModuleViewController *)controller ;
		buttonImage = image;
		title = [text copy];
		tag = aTag;
        size =fontSize;
    }
    return self;
}
- (id)initWithModuleSelectionLauncher: (MenuSelectionViewController *) controller
				 buttonImage: (UIImage *) image
					   label: (NSString *) text
						 tag: (int) aTag
                    fontSize:(int)fontSize
{
    if (self = [super init]) {
        launcher = (MenuSelectionViewController *)controller ;
		buttonImage = image;
		title = [text copy];
		tag = aTag;
        size = fontSize;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[button setBackgroundImage: buttonImage forState: UIControlStateNormal];
	button.imageView.image = buttonImage;
	button.tag = tag;
	self.view.tag = tag;
	[button addTarget: launcher action: @selector(launchModule:) forControlEvents: UIControlEventTouchUpInside];
	
	label = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, 200, (kDefaultMenuFontSize + 6))];
	label.text = title;
    label.font = [UIFont fontWithName:@"TrebuchetMS" size:size];
	label.textColor = [UIColor darkGrayColor];
	label.backgroundColor = [UIColor clearColor];
	label. textAlignment = NSTextAlignmentCenter;
    label.layer.shadowOpacity = 1.0;
    label.layer.shadowRadius = 0.0;
    label.layer.shadowColor = [UIColor brownColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, -1.0);
	[self.view addSubview: label];
//	[label release];
}


- (void)didReceiveMemoryWarning {
	NSLog(@"Memory warning for class %@", [self class]);
    [super didReceiveMemoryWarning];
	
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}




@end
