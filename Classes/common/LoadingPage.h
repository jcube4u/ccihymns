//
//  LoadingPage.h
//  Bandcentral
//
//  Created by Jidh on 23/4/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingPage : UIView {

	UIActivityIndicatorView *activity;
	UILabel					*message;
    NSString                *messageText;
}
@property(nonatomic,retain) UIActivityIndicatorView *activity;
@property(nonatomic,retain) UILabel *message;
@property(nonatomic,retain) NSString                *messageText;


- (id)initWithFrame:(CGRect)frame  text:(NSString *)text ;
-(void)showPage;
-(void)unload;


@end
