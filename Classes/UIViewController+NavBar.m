//
//  UIViewController+NavBar.m
//  MahimaApp
//
//  Created by Ashley Mills on 17/08/2009.

//

#import "UIViewController+NavBar.h"

@implementation UIViewController (NavBar)


- (void) setResistanceNavBarTitle
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	UIBarButtonItem * menuButton = [[UIBarButtonItem alloc] initWithTitle: @"MENU" style: UIBarButtonItemStylePlain target: self action: @selector(menu:)];
	self.navigationItem.leftBarButtonItem = menuButton;
//	[menuButton release];
    
	CGRect frame = CGRectMake(50, 0, 150 - 30, 44);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	label.text = [self.title uppercaseString];
	
	self.navigationItem.titleView = nil;
	self.navigationItem.titleView = label;
	self.title = nil;

}



#pragma mark -
#pragma mark Action Methods
- (IBAction) menu: (id) sender
{
	if ([(NSObject *)[(id)self mainMenu] respondsToSelector: @selector(closeModule:)])
		[[(id)self mainMenu] closeModule: self];
	else
		[self.navigationController popViewControllerAnimated: YES];
}

- (id) mainMenu {
return nil;

}

@end
