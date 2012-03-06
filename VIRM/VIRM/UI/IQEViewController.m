/*
 Copyright (c) 2011-2012 IQ Engines, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

//
//  IQEViewController.m
//

#import "IQEViewController.h"
#import "IQEHistoryTableViewCell.h"
#import "IQEHistoryItem.h"
#import "IQELocation.h"
#import "UIImage+IQE.h"

#define STR_DATADIR           @"iqe"
#define STR_DATAFILE          @"IQEData.plist"
#define STR_DATAFILE_VER      @"1.0"
#define STR_KEY_VERSION       @"version"
#define STR_KEY_HISTORY       @"history"

#define BUNDLE_TABLE          @"IQE"

#define DEFAULTS_KEY_RUNCOUNT @"IQERunCount"

#define CELL_HEIGHT           60
#define MAX_DISPLAYCELLS      3
#define THUMB_WIDTH           50
#define THUMB_HEIGHT          50
#define SWIPE_HORIZ_MAX       40
#define SWIPE_VERT_MIN        40

typedef enum 
{
    ListDisplayModeNone,
    ListDisplayModeResult,
    ListDisplayModeHistory,
} ListDisplayMode;

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark IQEViewController Private interface
/* -------------------------------------------------------------------------------- */

@interface IQEViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
- (void)   updateView;
- (void)   updateToolbar;
- (void)   loadState;
- (void)   saveState;
- (void)   applicationDidEnterBackground;
- (void)   applicationWillEnterForeground;
- (void)   processUnfinishedHistoryItems:(BOOL)search;
- (CGRect) historyListRect;
- (CGSize) thumbSize;
- (void)   historyItemTitleChange:(NSNotification*)n;
- (void)   historyItemStateChange:(NSNotification*)n;
- (void)   startSearchForHistoryItem:(IQEHistoryItem*)historyItem withImage:(UIImage*)image;
- (void)   saveImageFiles:(IQEHistoryItem*)historyItem forImage:(UIImage*)image;
- (void)   removeImageFiles:(IQEHistoryItem*)historyItem;
@property(nonatomic, assign) IQESearchType          mSearchType;
@property(nonatomic, retain) UITableView*           mTableView;
@property(nonatomic, retain) UIView*                mPreviewView;
@property(nonatomic, retain) UIToolbar*             mToolBar;
@property(nonatomic, retain) UIBarButtonItem*       mBackButton;
@property(nonatomic, retain) UIButton*              mCameraButton;
@property(nonatomic, retain) UIBarButtonItem*       mHistoryButton;
@property(nonatomic, assign) BOOL                   mFirstViewLoad;
@property(nonatomic, retain) NSMutableArray*        mHistory;
@property(nonatomic, retain) NSString*              mDocumentPath;
@property(nonatomic, retain) NSString*              mDataPath;
@property(nonatomic, assign) CGPoint                mStartTouchPosition;
@property(nonatomic, assign) ListDisplayMode        mListDisplayMode;
@end

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark IQEViewController implementation
/* -------------------------------------------------------------------------------- */

@implementation IQEViewController

@synthesize delegate = mDelegate;
@synthesize hidesBackButton;
@synthesize locationEnabled;
@synthesize mPreviewView;
@synthesize mBackButton;
@synthesize mCameraButton;
@synthesize mHistoryButton;
@synthesize mFirstViewLoad;
@synthesize mToolBar;
@synthesize mSearchType;
@synthesize mTableView;
@synthesize mHistory;
@synthesize mDocumentPath;
@synthesize mDataPath;
@synthesize mStartTouchPosition;
@synthesize mListDisplayMode;

- (id)initWithSearchType:(IQESearchType)searchType
{
    return [self initWithSearchType:searchType apiKey:nil apiSecret:nil];
}

- (id)initWithSearchType:(IQESearchType)searchType apiKey:(NSString*)key apiSecret:(NSString*)secret
{
    self = [super initWithNibName:@"IQEViewController" bundle:nil];
    if (self)
    {
        //
        // Create directory to store files.
        //
        
        NSArray*  paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentPath = [paths objectAtIndex:0];
        NSString* dataPath     = [documentPath stringByAppendingPathComponent:STR_DATADIR];
        NSError*  error        = nil;
        
        if ([[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error] == NO)
        {
            NSLog(@"IQEViewController: Error creating directory %@: %@", dataPath, error.localizedDescription);
        }
        
        //
        // Initialize state variables.
        //
        
        self.mDocumentPath    = documentPath;
        self.mDataPath        = dataPath;
        self.mHistory         = [NSMutableArray arrayWithCapacity:0];
        self.mSearchType      = searchType;
        self.mListDisplayMode = ListDisplayModeNone;
        self.hidesBackButton  = NO;
        self.locationEnabled  = NO;
        self.mFirstViewLoad   = YES;
        
        //
        // Init IQE.
        //
        
        mIQE = [[IQE alloc] initWithSearchType:searchType
                                        apiKey:key
                                     apiSecret:secret];
        
        mIQE.delegate = self;
        
        //
        // Register notification message for history item changes.
        //
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self
                               selector:@selector(historyItemTitleChange:) 
                                   name:IQEHistoryItemTitleChangeNotification
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(historyItemStateChange:) 
                                   name:IQEHistoryItemStateChangeNotification
                                 object:nil];
        
        //
        // Set up application notifications for saving/restoring state.
        //
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]
        &&  [[UIDevice currentDevice] isMultitaskingSupported])
        {
            [notificationCenter addObserver:self
                                   selector:@selector(applicationDidEnterBackground)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
            
            [notificationCenter addObserver:self
                                   selector:@selector(applicationWillEnterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
        }
        else
        {
            [notificationCenter addObserver:self
                                   selector:@selector(applicationDidEnterBackground)
                                       name:UIApplicationWillTerminateNotification
                                     object:nil];
        }
        
        //
        // Load data from storage.
        //
        
        [self loadState];
        
        //
        // Start GPS
        //
        
        if ((mSearchType & IQESearchTypeRemoteSearch) && self.locationEnabled)
            [[IQELocation location] startLocating];
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    mIQE.delegate = nil;
    [mIQE stopCamera];
    
    mTableView.delegate   = nil;
    mTableView.dataSource = nil;

    [self applicationDidEnterBackground];

    [mIQE           release];
    [mPreviewView   release];
    [mToolBar       release];
    [mBackButton    release];
    [mCameraButton  release];
    [mHistoryButton release];
    [mTableView     release];
    [mHistory       release];
    [mDocumentPath  release];
    [mDataPath      release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"%s", __func__);

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark UIViewController
/* -------------------------------------------------------------------------------- */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Set up video preview layer.
    //
    
    CGRect layerRect = mPreviewView.layer.bounds;
    mIQE.previewLayer.bounds   = layerRect;
    mIQE.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
    
    [mPreviewView.layer insertSublayer:mIQE.previewLayer atIndex:0];
    
    mPreviewView.backgroundColor = [UIColor blackColor];
    mPreviewView.clipsToBounds   = YES;
    
    //
    // History list.
    //
    
    CGRect historyRect = [self historyListRect];
    
    self.mTableView = [[[UITableView alloc] initWithFrame:historyRect style:UITableViewStylePlain] autorelease];
    
    mTableView.separatorColor   = [UIColor colorWithWhite:0.5 alpha:0.25];
    mTableView.rowHeight        = CELL_HEIGHT;
    mTableView.backgroundColor  = [UIColor clearColor];
    mTableView.delegate         = self;
    mTableView.dataSource       = self;
    mTableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [mPreviewView addSubview:mTableView];
    
    //
    // Accessibility.
    //
    
    [mCameraButton  setAccessibilityLabel:NSLocalizedStringFromTable(@"Take Picture", BUNDLE_TABLE, @"")];
    [mBackButton    setAccessibilityLabel:NSLocalizedStringFromTable(@"Back",         BUNDLE_TABLE, @"")];
    [mHistoryButton setAccessibilityLabel:NSLocalizedStringFromTable(@"History",      BUNDLE_TABLE, @"")];
    [mPreviewView   setAccessibilityLabel:NSLocalizedStringFromTable(@"Viewfinder",   BUNDLE_TABLE, @"")];
    
    [self updateToolbar];
    [self updateView];
    
    //
    // Run on the first view load.
    //
    
    if (mFirstViewLoad)
    {
        //
        // Handle unfinished searches.
        //
        
        [self processUnfinishedHistoryItems:YES];
        
        mFirstViewLoad = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    mTableView.delegate   = nil;
    mTableView.dataSource = nil;

    self.mTableView     = nil;
    self.mPreviewView   = nil;
    self.mToolBar       = nil;
    self.mBackButton    = nil;
    self.mCameraButton  = nil;
    self.mHistoryButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [mIQE startCamera];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [mIQE stopCamera];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [mTableView setEditing:editing animated:animated];
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark UIResponder implementation
/* -------------------------------------------------------------------------------- */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    if ([touch.view isEqual:mPreviewView] == NO)
        return;
    
    mStartTouchPosition = [touch locationInView:mPreviewView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    if ([touch.view isEqual:mPreviewView] == NO)
        return;
    
    CGPoint currentTouchPosition = [touch locationInView:mPreviewView];
    
    if (fabsf(mStartTouchPosition.y - currentTouchPosition.y) >= SWIPE_VERT_MIN
    &&  fabsf(mStartTouchPosition.x - currentTouchPosition.x) <= SWIPE_HORIZ_MAX)
    {
        if (mStartTouchPosition.y < currentTouchPosition.y)
        {
            // Down swipe. Bring down history or result view.
            mListDisplayMode = ListDisplayModeNone;
        }
        else
        {
            // Up swipe. Bring up history list.
            mListDisplayMode = ListDisplayModeHistory;
        }
        
        [self updateView];
        [self updateToolbar];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    mStartTouchPosition = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    mStartTouchPosition = CGPointZero;
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark Actions
/* -------------------------------------------------------------------------------- */

- (IBAction)onCameraButton:(id)sender
{
    [mIQE captureStillFrame];
    
    [self updateView];
}

- (IBAction)onCancel:(id)sender
{
    if ([mDelegate respondsToSelector:@selector(iqeViewControllerDidCancel:)])
        [mDelegate iqeViewControllerDidCancel:self];
}

- (IBAction)onHistory:(id)sender
{
    if (mListDisplayMode == ListDisplayModeHistory)
        mListDisplayMode = ListDisplayModeNone;
    else
    if (mListDisplayMode == ListDisplayModeResult)
        mListDisplayMode = ListDisplayModeHistory;
    else
    if (mListDisplayMode == ListDisplayModeNone)
        mListDisplayMode = ListDisplayModeHistory;
    
    [self updateView];
    [self updateToolbar];
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark Application lifecycle
/* -------------------------------------------------------------------------------- */

- (void)applicationDidEnterBackground
{
    [self saveState];
    
    [[IQELocation location] stopLocating];
}

- (void)applicationWillEnterForeground
{
    [self loadState];
    
    if (mSearchType & IQESearchTypeRemoteSearch && self.locationEnabled)
        [[IQELocation location] startLocating];
    
    [self processUnfinishedHistoryItems:NO];
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark Public methods
/* -------------------------------------------------------------------------------- */

- (BOOL)autoDetection
{
    return mIQE.autoDetection;
}

- (void)setAutoDetection:(BOOL)detectionOn
{
    if (mIQE.autoDetection == detectionOn)
        return;

    mIQE.autoDetection = detectionOn;
    
    [self updateToolbar];
}

- (void)setHidesBackButton:(BOOL)hidden
{
    if (hidesBackButton == hidden)
        return;
    
    hidesBackButton = hidden;
    
    [self updateToolbar];
}

- (void)setLocationEnabled:(BOOL)enable
{
    if (locationEnabled == enable)
        return;
    
    locationEnabled = enable;
    
    if (mSearchType & IQESearchTypeRemoteSearch && self.locationEnabled)
        [[IQELocation location] startLocating];
    else
        [[IQELocation location] stopLocating];
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark Private methods
/* -------------------------------------------------------------------------------- */

- (void)updateView
{
    //
    // History TableView.
    //
    
    // Don't scroll in result display mode.
    if (mListDisplayMode == ListDisplayModeHistory)
        mTableView.scrollEnabled = YES;
    else
    if (mListDisplayMode == ListDisplayModeResult)
        mTableView.scrollEnabled = NO;
    
    // Move history list in/out of view.
    CGRect historyRect = [self historyListRect];
    if (CGRectEqualToRect(mTableView.frame, historyRect) == NO)
    {
        if (mTableView.contentOffset.y < 0.0)
            mTableView.frame = CGRectOffset(mTableView.frame, 0.0, - mTableView.contentOffset.y);
        else
        if (mTableView.contentOffset.y > mTableView.contentSize.height - mTableView.frame.size.height)
            [mTableView setContentOffset:CGPointMake(mTableView.contentOffset.x, mTableView.contentSize.height - mTableView.frame.size.height)
                                animated:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        
        mTableView.frame = historyRect;
        
        [UIView commitAnimations];
        
        if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
    
    // Edit only when displaying history. 
    if (mListDisplayMode != ListDisplayModeHistory)
        [self setEditing:NO animated:NO];
}

- (void)updateToolbar
{
    //
    // ToolBar buttons.
    //
    
    if (mToolBar)
    {
        // Back button.
        NSInteger backButtonIndex = [mToolBar.items indexOfObject:mBackButton];
        if (self.hidesBackButton)
        {
            if (backButtonIndex != NSNotFound)
            {
                NSMutableArray* array = [NSMutableArray arrayWithArray:mToolBar.items];
                
                [array removeObjectAtIndex:backButtonIndex];
                [mToolBar setItems:array];
            }
        }
        else
        {        
            if (backButtonIndex == NSNotFound)
            {
                NSMutableArray* array = [NSMutableArray arrayWithArray:mToolBar.items];
                
                [array insertObject:mBackButton atIndex:0]; // Left position.
                [mToolBar setItems:array];
            }
        }
        
        // Show an edit button so VoiceOver users can delete.
        if (UIAccessibilityIsVoiceOverRunning != nil && UIAccessibilityIsVoiceOverRunning())
        {
            // Show edit button when history is shown.
            NSInteger editButtonIndex = [mToolBar.items indexOfObject:self.editButtonItem];
            if (mListDisplayMode == ListDisplayModeHistory)
            {
                if (editButtonIndex == NSNotFound)
                {
                    NSInteger historyButtonIndex = [mToolBar.items indexOfObject:mHistoryButton];
                    
                    NSUInteger index = self.hidesBackButton ? 0 : historyButtonIndex;
                    NSMutableArray* array = [NSMutableArray arrayWithArray:mToolBar.items];
                    
                    [array insertObject:self.editButtonItem atIndex:index];
                    [mToolBar setItems:array animated:YES];
                }
            }
            else
            {
                if (editButtonIndex != NSNotFound)
                {
                    NSMutableArray* array = [NSMutableArray arrayWithArray:mToolBar.items];
                    
                    [array removeObjectAtIndex:editButtonIndex];
                    [mToolBar setItems:array animated:YES];
                }
            }
        }
    }
    
    //
    // History button.
    //
    
    if (mListDisplayMode == ListDisplayModeHistory)
        [mHistoryButton setAccessibilityLabel:NSLocalizedStringFromTable(@"History off", BUNDLE_TABLE, @"")];
    else
        [mHistoryButton setAccessibilityLabel:NSLocalizedStringFromTable(@"History on",  BUNDLE_TABLE, @"")];
    
    //
    // Camera button when remote and not running automatic local detection.
    //
    
    BOOL remote =  mSearchType & IQESearchTypeRemoteSearch;
    BOOL local  = (mSearchType & IQESearchTypeObjectSearch)
                ||(mSearchType & IQESearchTypeBarCode);
    
    if (local && !remote && mIQE.autoDetection == YES)
        mCameraButton.hidden = YES;
    else
        mCameraButton.hidden = NO;
}

// Load persistant data from plist.
- (void)loadState
{
    NSString* dataFilePath = [mDataPath stringByAppendingPathComponent:STR_DATAFILE];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dataFilePath] == NO)
    {
        // Set default values if file doesn't exist.
        self.mHistory = [NSMutableArray arrayWithCapacity:0];
    }
    else
    {
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:dataFilePath];
        
        NSArray* historyArray = [dict objectForKey:STR_KEY_HISTORY];
        if (historyArray)
        {
            self.mHistory = [[[NSMutableArray alloc] initWithNSArray:historyArray] autorelease];
        }
    }
}

// Save persistant data to plist.
- (void)saveState
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:STR_DATAFILE_VER forKey:STR_KEY_VERSION];

    if (mHistory)
    {
        NSMutableArray* historyArray = [NSMutableArray arrayWithCapacity:mHistory.count];
        [mHistory encodeWithNSArray:historyArray];
        
        [dict setObject:historyArray forKey:STR_KEY_HISTORY];
    }
    
    NSString* dataFilePath = [mDataPath stringByAppendingPathComponent:STR_DATAFILE];
    [dict writeToFile:dataFilePath atomically:YES];
}

/*
    History items may be in an unfinished state under normal circumstances.
    For instance, when the view is deallocated, or the app goes into the background.
    This method will go through the history list and restart them.
*/

- (void)processUnfinishedHistoryItems:(BOOL)search
{
    for (IQEHistoryItem* historyItem in mHistory)
    {
        // HistoryItem type is unknown until a successful image search/detection.
        if (historyItem.type  == IQEHistoryItemTypeUnknown
        &&  historyItem.state != IQEHistoryItemStateNotFound)
        {
            if (mSearchType & IQESearchTypeRemoteSearch)
            {
                // Remote search disconnects from server when in the background.
                
                if ((historyItem.state == IQEHistoryItemStateUploading
                ||   historyItem.state == IQEHistoryItemStateNetworkProblem))
                {
                    //
                    // Image may not have made it to the server. Try again.
                    //
                    
                    NSString* imagePath = [mDocumentPath stringByAppendingPathComponent:historyItem.imageFile];
                    UIImage*  image     = [UIImage imageWithContentsOfFile:imagePath];
                    
                    if (image)
                        [self startSearchForHistoryItem:historyItem withImage:image];
                }
                else
                if ((historyItem.state == IQEHistoryItemStateSearching
                ||   historyItem.state == IQEHistoryItemStateNotReady))
                {
                    //
                    // Results may be available if the app was closed
                    // before getting the results, so check for them.
                    //
                    
                    [mIQE searchWithQID:historyItem.qid];
                }
            }
            else
            if (mSearchType & IQESearchTypeObjectSearch
            ||  mSearchType & IQESearchTypeBarCode)
            {
                if (search)
                {
                    //
                    // Resubmit image when initial search for this item is no longer running.
                    //
                    
                    NSString* imagePath = [mDocumentPath stringByAppendingPathComponent:historyItem.imageFile];
                    UIImage*  image     = [UIImage imageWithContentsOfFile:imagePath];
                    
                    if (image)
                        [self startSearchForHistoryItem:historyItem withImage:image];
                }
            }
        }
    }
}

- (CGRect)historyListRect
{
    CGRect  historyRect;
    CGFloat historyHeight = MIN(mHistory.count, MAX_DISPLAYCELLS) * CELL_HEIGHT;
    
    if (mListDisplayMode == ListDisplayModeHistory)
    {
        mTableView.scrollEnabled = YES;
        historyRect = CGRectMake(0, mPreviewView.frame.size.height - historyHeight, mPreviewView.frame.size.width, historyHeight);
    }
    else
    if (mListDisplayMode == ListDisplayModeResult)
    {
        mTableView.scrollEnabled = NO;
        historyRect = CGRectMake(0, mPreviewView.frame.size.height - CELL_HEIGHT, mPreviewView.frame.size.width, CELL_HEIGHT);   
    }
    else
    if (mListDisplayMode == ListDisplayModeNone)
    {
        historyRect = CGRectMake(0, mPreviewView.frame.size.height, mPreviewView.frame.size.width, 0);
    }
    
    return historyRect;
}

- (CGSize)thumbSize
{
    CGFloat screenScale = 1.0;
    
    // Retina display.
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)])
        screenScale = [UIScreen mainScreen].scale;
    
    return CGSizeMake(THUMB_WIDTH * screenScale, THUMB_HEIGHT * screenScale);
}

- (void)historyItemTitleChange:(NSNotification*)n
{
    [self retain];
    
    IQEHistoryItem* historyItem = n.object;
    
    // Save new result data to data source.
    if (historyItem.type == IQEHistoryItemTypeRemoteObject)
        [mIQE updateResults:historyItem.qidData forQID:historyItem.qid];
    
    [mTableView reloadData];
    [self updateView];
    
    [self autorelease];
}

- (void)historyItemStateChange:(NSNotification*)n
{
    [self retain];
    
    IQEHistoryItem* historyItem = n.object;
    
    if (historyItem.state == IQEHistoryItemStateFound
    ||  historyItem.state == IQEHistoryItemStateNotFound)
    {
        //
        // Call delegate when an item is complete.
        //
        
        if ([mDelegate respondsToSelector:@selector(iqeViewController:didCompleteSearch:)])
            [mDelegate iqeViewController:self didCompleteSearch:historyItem];
    }
    
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, historyItem.title);

    [mTableView reloadData];
    [self updateView];

    [self autorelease];
}

- (void)startSearchForHistoryItem:(IQEHistoryItem*)historyItem withImage:(UIImage*)image
{
    if (mSearchType & IQESearchTypeBarCode)      [historyItem setState:IQEHistoryItemStateUnknown forType:IQEHistoryItemTypeBarCode];
    if (mSearchType & IQESearchTypeObjectSearch) [historyItem setState:IQEHistoryItemStateUnknown forType:IQEHistoryItemTypeLocalObject];
    if (mSearchType & IQESearchTypeRemoteSearch) [historyItem setState:IQEHistoryItemStateUnknown forType:IQEHistoryItemTypeRemoteObject];
    
    //
    // Start image detection. The result will be returned via the IQEDelegate protocol.
    //
    
    NSString* qid = [mIQE searchWithImage:image atLocation:[IQELocation location].coordinates];
    
    if (qid)
    {
        historyItem.qid = qid;
        
        if (mSearchType & IQESearchTypeRemoteSearch)
            historyItem.state = IQEHistoryItemStateUploading;
        else
            historyItem.state = IQEHistoryItemStateSearching;
    }
    else
    {
        historyItem.state = IQEHistoryItemStateNotFound;
        historyItem.type  = IQEHistoryItemTypeUnknown;
    }
}

- (void)saveImageFiles:(IQEHistoryItem*)historyItem forImage:(UIImage*)image
{
    NSString* uniqueName = [UIImage uniqueName];
    NSString* imageName  = [NSString stringWithFormat:@"%@.jpg",      uniqueName];
    NSString* thumbName  = [NSString stringWithFormat:@"%@thumb.jpg", uniqueName];
    
    // /.../Documents/iqe/*.jpg
    [image saveAsJPEGinDirectory:mDataPath withName:imageName];
    [image saveAsJPEGinDirectory:mDataPath withName:thumbName size:[self thumbSize]];
    
    // iqe/*.jpg
    historyItem.imageFile = [STR_DATADIR stringByAppendingPathComponent:imageName];
    historyItem.thumbFile = [STR_DATADIR stringByAppendingPathComponent:thumbName];
}

- (void)removeImageFiles:(IQEHistoryItem*)historyItem
{
    NSString* imagePath = [mDocumentPath stringByAppendingPathComponent:historyItem.imageFile];
    NSString* thumbPath = [mDocumentPath stringByAppendingPathComponent:historyItem.thumbFile];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (historyItem.imageFile && ![historyItem.imageFile isEqualToString:@""]) 
        [fileManager removeItemAtPath:imagePath error:nil];
    
    if (historyItem.thumbFile && ![historyItem.thumbFile isEqualToString:@""])
        [fileManager removeItemAtPath:thumbPath error:nil];
    
    historyItem.imageFile = nil;
    historyItem.thumbFile = nil;
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark <IQEDelegate> implementation
/* -------------------------------------------------------------------------------- */

- (void)iqEngines:(IQE*)iqe didCompleteSearch:(IQESearchType)type withResults:(NSDictionary*)results forQID:(NSString*)qid
{
    IQEHistoryItem* historyItem = nil;
    NSUInteger      scrollIndex = NSNotFound;
    
    if (qid)
    {
        historyItem = [mHistory historyItemForQID:qid];
        if (!historyItem)
            return; // historyItem for this qid has been deleted. Ignore result.
    }
    
    //
    // Deal with searches that have no results.
    //
    
    if (historyItem && results.count == 0)
    {
        if (type == IQESearchTypeRemoteSearch)
            [historyItem setState:IQEHistoryItemStateNotFound forType:IQEHistoryItemTypeRemoteObject];
        else
        if (type == IQESearchTypeObjectSearch)
            [historyItem setState:IQEHistoryItemStateNotFound forType:IQEHistoryItemTypeLocalObject];
        else
        if (type == IQESearchTypeBarCode)
            [historyItem setState:IQEHistoryItemStateNotFound forType:IQEHistoryItemTypeBarCode];
        
        // If the search is complete, find out if there are any results found.
        if ([historyItem complete] == YES
        &&  [historyItem found]    == NO)
        {
            historyItem.type  = IQEHistoryItemTypeUnknown;
            historyItem.state = IQEHistoryItemStateNotFound;
        }
        
        return;
    }
    
    if (type == IQESearchTypeRemoteSearch)
    {
        if (historyItem)
        {
            [historyItem setState:IQEHistoryItemStateFound forType:IQEHistoryItemTypeRemoteObject];
            
            // Ignore remote result if local or barcode is already finished.
            if (historyItem.type == IQEHistoryItemTypeBarCode
            ||  historyItem.type == IQEHistoryItemTypeLocalObject)
                return;
            
            if (historyItem.state != IQEHistoryItemStateFound)
                scrollIndex = [mHistory indexOfObject:historyItem];
            
            historyItem.qidData = results;
            historyItem.type    = IQEHistoryItemTypeRemoteObject;
            historyItem.state   = IQEHistoryItemStateFound;
            
            [mTableView reloadData];
        }
    }
    else
    if (type == IQESearchTypeObjectSearch)
    {
        NSString* objId     = [results objectForKey:IQEKeyObjectId];
        NSString* objName   = [results objectForKey:IQEKeyObjectName];
        NSString* objMeta   = [results objectForKey:IQEKeyObjectMeta];
        NSString* imagePath = [results objectForKey:IQEKeyObjectImagePath];
        
        if (historyItem)
        {
            [historyItem setState:IQEHistoryItemStateFound forType:IQEHistoryItemTypeLocalObject];
            
            // Remove images. Local Object item uses images in local files.
            [self removeImageFiles:historyItem];
            
            // Use local object images
            UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
            [self saveImageFiles:historyItem forImage:image];
            
            historyItem.qidData = nil; // local results overwrite remote object
            historyItem.objId   = objId;
            historyItem.objName = objName;
            historyItem.objMeta = objMeta;
            historyItem.type    = IQEHistoryItemTypeLocalObject;
            historyItem.state   = IQEHistoryItemStateFound;
            
            scrollIndex = [mHistory indexOfObject:historyItem];
        }
        else
        {
            // Automatic detect.
            
            IQEHistoryItem* item = [[[IQEHistoryItem alloc] init] autorelease];
            
            item.objId   = objId;
            item.objName = objName;
            item.objMeta = objMeta;
            item.type    = IQEHistoryItemTypeLocalObject;
            
            IQEHistoryItem* latestItem = [mHistory firstObject];
            if (latestItem == nil || [latestItem isEqualToHistoryItem:item] == NO)
            {
                UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
                [self saveImageFiles:item forImage:image];
                
                item.state = IQEHistoryItemStateFound;
                
                [mHistory insertObject:item atIndex:0];
                [mTableView reloadData];
            }
            else
            {
                if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, latestItem.title);
            }
            
            scrollIndex = 0;
        }
    }
    else
    if (type == IQESearchTypeBarCode)
    {
        NSString* barData = [results objectForKey:IQEKeyBarcodeData];
        NSString* barType = [results objectForKey:IQEKeyBarcodeType];
        
        if (historyItem)
        {
            [historyItem setState:IQEHistoryItemStateFound forType:IQEHistoryItemTypeBarCode];
            
            // Remove images. Barcode item uses default images in bundle.
            [self removeImageFiles:historyItem];
            
            historyItem.qidData  = nil; // local results overwrite remote object
            historyItem.codeData = barData;
            historyItem.codeType = barType;
            historyItem.type     = IQEHistoryItemTypeBarCode;
            historyItem.state    = IQEHistoryItemStateFound;
            
            scrollIndex = [mHistory indexOfObject:historyItem];
        }
        else
        {
            // Automatic detect.
            
            IQEHistoryItem* item = [[[IQEHistoryItem alloc] init] autorelease];
            
            item.codeData = barData;
            item.codeType = barType;
            item.type     = IQEHistoryItemTypeBarCode;
            
            IQEHistoryItem* latestItem = [mHistory firstObject];
            if (latestItem == nil || [latestItem isEqualToHistoryItem:item] == NO)
            {                
                item.state = IQEHistoryItemStateFound;
                
                [mHistory insertObject:item atIndex:0];
                [mTableView reloadData];
            }
            
            scrollIndex = 0;
        }
    }
    
    //
    // Update UI:
    // - Scroll list to historyItem
    // - Show list
    //
    
    if (scrollIndex != NSNotFound && [mTableView numberOfRowsInSection:0] > 0)
    {
        [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scrollIndex inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
        
        if (mListDisplayMode == ListDisplayModeNone)
            mListDisplayMode = ListDisplayModeResult;
        
        [self updateView];
    }
}

- (void)iqEngines:(IQE*)iqe didCaptureStillFrame:(UIImage*)image
{
    IQEHistoryItem* historyItem = [[IQEHistoryItem alloc] init];
    
    [self startSearchForHistoryItem:historyItem withImage:image];
    
    [mHistory insertObject:historyItem atIndex:0];
    
    [self saveImageFiles:historyItem forImage:image];
    
    [mTableView reloadData];
    [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
    
    if (mListDisplayMode == ListDisplayModeNone)
        mListDisplayMode = ListDisplayModeResult;
    
    [self updateView];
    
    [historyItem release];
}

- (void)iqEngines:(IQE*)iqe statusDidChange:(IQEStatus)status forQID:(NSString *)qid
{
    IQEHistoryItem* historyItem = [mHistory historyItemForQID:qid];
    
    if (historyItem == nil)
        return;
    
    // Ignore remote status if local or barcode is already finished.
    if (historyItem.type == IQEHistoryItemTypeBarCode
    ||  historyItem.type == IQEHistoryItemTypeLocalObject)
        return;

    switch (status)
    {
        case IQEStatusUnknown:
            historyItem.state = IQEHistoryItemStateUnknown;
            break;
            
        case IQEStatusError:
            historyItem.state = IQEHistoryItemStateNetworkProblem;
            break;

        case IQEStatusUploading:
            historyItem.state = IQEHistoryItemStateUploading;
            break;
            
        case IQEStatusSearching:
            historyItem.state = IQEHistoryItemStateSearching;
            break;
            
        case IQEStatusNotReady:
            historyItem.state = IQEHistoryItemStateNotReady;
            break;
            
        default:
            break;
    }
}

- (void) iqEngines:(IQE*)iqe didFindBarcodeDescription:(NSString*)desc forUPC:(NSString*)upc
{
    if (desc == nil || [desc isEqualToString:@""])
        return;
    
    for (IQEHistoryItem* historyItem in mHistory)
    {
        if (historyItem.type == IQEHistoryItemTypeBarCode
        && [historyItem.codeData isEqualToString:upc]  == YES
        && [historyItem.codeDesc isEqualToString:desc] == NO)
        {
            historyItem.codeDesc = desc;
            
            [mTableView reloadData];
            
            if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, historyItem.title);

            break;
        }
    }
}

- (void)iqEngines:(IQE*)iqe failedWithError:(NSError*)error
{
    NSLog(@"failedWithError: %@", error.localizedDescription);
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark <UITableViewDataSource> implementation
/* -------------------------------------------------------------------------------- */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IQEHistoryTableViewCell* cell = nil;
    
    static NSString* cellIdentifier = @"HistoryCell";
    
    cell = (IQEHistoryTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[[IQEHistoryTableViewCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
    
    IQEHistoryItem* historyItem = [mHistory objectAtIndex:indexPath.row];
    
    cell.textLabel.text                 = historyItem.title;
    cell.textLabel.font                 = (historyItem.state == IQEHistoryItemStateFound) ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines        = 1;
    cell.textLabel.textColor            = [UIColor whiteColor];
    cell.backgroundView                 = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
    cell.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
    cell.imageViewSize                  = CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT);
    
    // Use a white arrow for accessory disclosure indicator.
    if (historyItem.state == IQEHistoryItemStateFound)
    {
        UIImage*     arrowImage         = [UIImage imageNamed:@"IQEAccessoryDisclosureArrow.png"];
        UIImageView* accessoryImageView = [[UIImageView alloc] initWithImage:arrowImage];
        
        [accessoryImageView sizeToFit];
        
        cell.accessoryView = accessoryImageView;
        
        [accessoryImageView release];
    }
    else
    {
        cell.accessoryView = nil;
    }
    
    //
    // Set thumbnail image.
    //
    
    cell.imageView.contentMode   = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    if (historyItem.type == IQEHistoryItemTypeBarCode)
    {
        if ([historyItem.codeType isEqualToString:IQEBarcodeTypeQRCODE])
            cell.imageView.image = [UIImage imageNamed:@"IQEQRCode.png"];
        else
            cell.imageView.image = [UIImage imageNamed:@"IQEBarcode.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[mDocumentPath stringByAppendingPathComponent:historyItem.thumbFile]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //
        // Remove image and thumbnail files. Then remove item from history.
        //
        
        IQEHistoryItem* historyItem = [mHistory objectAtIndex:indexPath.row];
        if (historyItem == nil)
            return;
            
        [self removeImageFiles:historyItem];
        
        [mHistory removeObjectAtIndex:indexPath.row];
        
        if (mListDisplayMode == ListDisplayModeResult)
            mListDisplayMode = ListDisplayModeNone;
        
        [self updateView];
    }
    
    [mTableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark <UITableDelegate> implementation
/* -------------------------------------------------------------------------------- */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Notify delegate of item selection
    
    IQEHistoryItem* historyItem = [mHistory objectAtIndex:indexPath.row];

    if (historyItem.state == IQEHistoryItemStateFound)
    {
        if ([mDelegate respondsToSelector:@selector(iqeViewController:didSelectItem:atIndex:)])
            [mDelegate iqeViewController:self didSelectItem:historyItem atIndex:indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark <UIScrollViewDelegate> implementation
/* -------------------------------------------------------------------------------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (scrollView.dragging)
    {
        if (scrollView.contentOffset.y < - scrollView.frame.size.height / 3.0)
        {
            mListDisplayMode = ListDisplayModeNone;
            
            [self updateView];
            [self updateToolbar];
        }
    }
}

@end
