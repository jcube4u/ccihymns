//
//  SongSelectorViewController.m
//  Mahima
//
//  Created by George, Jidh on 28/01/2013.
//
//
#import "Cell.h"
#import "Database.h"
#import "AppInfo.h"
#import "LyricsPageViewController.h"
#import "SongSelectorViewController.h"

NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id

@interface SongSelectorViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic,strong) IBOutlet UIButton *buttonMenu;
@property (nonatomic,strong) IBOutlet UIButton *buttonBack;
@property (nonatomic,strong) IBOutlet UIButton *buttonToggleLanguage;

@end

@implementation SongSelectorViewController
@synthesize buttonMenu= _buttonMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)populateData
{
    NSMutableArray *songList = [NSMutableArray array];
	[[Database instance] loadAllSongs:songList withCategoryId:(-1)];
    self.dataArray =songList;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self populateData];
    
    /* Uncomment this block to use nib-based cells */
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:kCellID];
    /* end of nib-based cells block*/
    NSString *languageSelected =  [[AppInfo sharedInfo] getDefaultsValueForKey:kSavedLanguage];
    
    NSInteger langId = [[AppInfo sharedInfo] getSelectedLanguageId];
    NSString *languageText = (langId == kLanguageYorubaID) ? @"E" : @"Y";
    [self.buttonToggleLanguage setTitle:languageText forState:UIControlStateNormal];
    
    NSString *title =  ([languageSelected isEqualToString:kLanguageYoruba]) ? @"Ymenu" : @"Emenu";
    [self.buttonMenu setTitle:title forState:UIControlStateNormal];
    
    /* uncomment this block to use subclassed cells */
//    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:kCellID];
    /* end of subclass-based cells block */
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(50, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    
    NSDictionary *songDict = [self.dataArray objectAtIndex:indexPath.row];

    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.backgroundColor =  [UIColor whiteColor];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    [titleLabel setText:[songDict objectForKey:keySongNo]];
    titleLabel.textColor = [UIColor blackColor];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    LyricsPageViewController *lyricsPage = nil;
    lyricsPage = [[LyricsPageViewController alloc]initWithArray:self.dataArray sectionId:0 feedId:indexPath.row];
	[[self navigationController] pushViewController:lyricsPage animated:YES];
	lyricsPage =  nil;
	

}

-(IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

-(IBAction)popToRoot:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated: YES];
}
- (IBAction)popToRootWithLanguageToggle:(id)sender
{
    [[AppInfo sharedInfo] toggleSelectedlanguage];
    [self.navigationController popToRootViewControllerAnimated: YES];
}


@end
