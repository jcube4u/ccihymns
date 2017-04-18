//
//  ModuleButtonController.h



@class MenuSelectionViewController;
@interface ModuleButtonController : UIViewController {
	IBOutlet UIButton * button;
	UILabel * label;
	
	UIImage * buttonImage;
	NSString * title;
	int tag;
	int size;
	id launcher;
}

- (id)initWithModuleLauncher: (ModuleViewController *) controller 
				 buttonImage: (UIImage *) image 
					   label: (NSString *) text
                        tag: (int) aTag
                    fontSize:(int) fontSize;

- (id)initWithModuleSelectionLauncher: (MenuSelectionViewController *) controller
                          buttonImage: (UIImage *) image
                                label: (NSString *) text
                                  tag: (int) aTag
                             fontSize:(int) fontSize;
@end
