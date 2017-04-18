//
//  MenuSelectionViewController.h
//  Mahima
//
//  Created by George, Jidh on 16/01/2013.
//
//


#import <UIKit/UIKit.h>

@interface MenuSelectionViewController : UIViewController
{
    CGFloat topInset;
    CGFloat borderSpacing;
    CGFloat borderSize;
    CGFloat buttonSize;
    int maxHorizontalButtons;
	id controller;
}

@property (nonatomic, copy) NSArray * modules;
@end
