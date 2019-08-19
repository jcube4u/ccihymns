//
//  ModuleViewController.h
//  MahimaApp
//
//  Created by Jidh.

//

#import "InfoViewController.h"
#import <AVFoundation/AVAudioPlayer.h>


#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


typedef enum  {
    NONE    = 0,
    SHARE_WITH_FRIENDS  = 1,
    REQUEST_SONG        ,
    LEAVE_FEEDBACK      ,
    FEEDBACK            ,
    WEBSITE            
} SelectionState;


@interface ModuleViewController : UIViewController<InfoViewControllerDelegate> {


	CGFloat topInset;
	CGFloat borderSpacing;
	CGFloat borderSize;
	CGFloat buttonSize;
	int maxHorizontalButtons;
    
	UINavigationController * navController;
	NSArray * modules;

	id controller;
	UIButton *infoButton;
	InfoViewController * infoPageViewController;
	BOOL allowRotation ;
	NSTimer *timer;
	NSTimer *delayTimer;
	
	UILabel *adLabel;
	UILabel *centerTextLabel;
	NSMutableArray *adText;
	NSMutableArray *centerText;
	NSInteger	waitedCycles;
	UIButton *detectLink;
    NSString    *webPageLink;


}

- (id) initWithTopInset: (CGFloat) theTopInset 
		  borderSpacing: (CGFloat) theBorderSpacing 
   maxHorizontalButtons: (int) maxHorizButtons
				modules: (NSArray *) theModules;
-(void)readFromFile;
- (void) layoutButtons;
- (void) closeModule: (id) sender;


-(NSString *) GetUrl:(NSString *)moduleName tagId:(NSInteger) tagId;

@property (nonatomic, copy) NSArray * modules;
@property (nonatomic, retain) UINavigationController * navController;
@property (nonatomic, retain) IBOutlet UILabel *adLabel;
@property (nonatomic, retain) IBOutlet UILabel *centerTextLabel;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSTimer *delayTimer;
@property (nonatomic, retain) NSMutableArray *adText;
@property (nonatomic, retain) NSMutableArray *centerText;
@property (nonatomic, retain) IBOutlet UIButton *detectLink;
@property (nonatomic, copy)   NSString    *webPageLink;


@end

@protocol ModuleViewControllerMainMenu

- (void) closeModule: (id) module; 

@end

