//
//  LoadingPage.m
//  MuseiApp
//
//  Created by Jidh on 04/11/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingPage.h"
#import "Constants.h"


@implementation LoadingPage

@synthesize activity,message,messageText;

- (id)initWithFrame:(CGRect)frame  text:(NSString *)text {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        messageText = [[NSString alloc] initWithFormat:@"%@",text];
		[self showPage];

    }
    return self;
}
-(void)showPage
{
	self.backgroundColor = [UIColor clearColor];

    NSInteger sizeWidth     =  100;
    NSInteger sizeHeight    =  50;
    NSInteger offsetFactor =  30;
	
    NSInteger posX     =  self.bounds.size.width/2 -  sizeWidth/2;
    NSInteger posY     =  self.bounds.size.height/2 -   self.bounds.size.height/3 - sizeHeight/2;/// now at 25 % height

	message = [[UILabel alloc] initWithFrame: CGRectMake(posX , posY- sizeHeight/4 , sizeWidth, sizeHeight)];
	message.backgroundColor =[UIColor clearColor];
	message.font = [UIFont systemFontOfSize:14];
	message.text = self.messageText;
	message.textAlignment = NSTextAlignmentCenter;
	message.textColor = [UIColor whiteColor];
	
	[self addSubview:message];
	
    
    NSInteger sizeActivity = 25;
    posX = self.frame.size.width/2 - sizeActivity/2 ;
    //posY = self.frame.size.height/2 - sizeActivity/2 ;
    
    
	activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(posX  , posY + offsetFactor, sizeActivity, sizeActivity)];
	activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[activity startAnimating];
	[self addSubview:activity];
    

	
}
-(void)unload
{
	
	if(activity)
	{
		[activity stopAnimating];
		[activity  removeFromSuperview];
		activity =  nil;
		activity = nil;
	}
	if(message)
	{
		[message  removeFromSuperview];
		//[message release];
		message = nil;
	}

    messageText =  nil;
	
	
	
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	//if(message)
	//	[message release];
	message = nil;

}


@end
