//
//  InfoViewController.h
//  MahimaApp
//
//  Created by Ashley Mills on 27/08/2009.

@protocol InfoViewControllerDelegate;

@interface InfoViewController : UIViewController <UIWebViewDelegate>
{
	id mainMenu;
	UILabel		*titleText;
	UIWebView   *webView;
	NSMutableArray		*displayedObjects;	
}

@property (nonatomic, strong) id mainMenu;

@property (nonatomic, strong) IBOutlet UILabel		*titleText;
@property (nonatomic, strong) IBOutlet UIWebView   *webView;
@property (nonatomic,strong) id <InfoViewControllerDelegate> delegate;
-(IBAction)pop:(id)sender;
@end

@protocol InfoViewControllerDelegate

-(void)dismissInfoView;

@end
