/**
 * Copyright (c) 2012 Moodstocks SAS
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MSViewController.h"
#import "MSImage.h"
#import "AppDelegate.h"

#include "moodstocks_sdk.h"

#if MS_HAS_AVFF
/* Auto-sync feature (when app starts or re-enters foreground) */
static const BOOL kMSScannerAutoSync = YES;
#endif

/* Private stuff */
@interface MSViewController()

#if MS_HAS_AVFF
- (void)deviceOrientationDidChange;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)backFacingCamera;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
#endif

- (void)startCapture;
- (void)stopCapture;

- (void)sync;
- (void)backgroundSync;

@end


@implementation MSViewController

@synthesize videoPreviewView = _videoPreviewView;
#if MS_HAS_AVFF
@synthesize captureSession;
@synthesize previewLayer;
@synthesize orientation;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    recognized = NO;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _processFrames = NO;
        _ts = -1;
    }
    return self;
}

- (void)dealloc
{
    [self stopCapture];
    
    [_result release];
    _result = nil;
    
    [super dealloc];
}

#if MS_HAS_AVFF
- (void)deviceOrientationDidChange {	
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		self.orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		self.orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		self.orientation = AVCaptureVideoOrientationLandscapeLeft;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

- (void)applicationDidEnterBackground {
    // Nothing to do so far
}

- (void)applicationWillEnterForeground {
    if (!kMSScannerAutoSync) return;
    [self backgroundSync];
}
#endif

- (void)startCapture {
#if MS_HAS_AVFF
    NSInteger count = [[MSScanner sharedInstance] count:nil];
    if (count <= 0)
        [self sync];
    else {
        if (kMSScannerAutoSync) [self backgroundSync];
        _processFrames = YES;
    }
    
    // Notifications setup
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.orientation = AVCaptureVideoOrientationPortrait;
    
    // Camera setup
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto])
                [[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
    
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto])
                [[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
    
    // Capture session
    AVCaptureDeviceInput* newVideoInput            = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    AVCaptureVideoDataOutput *newCaptureOutput     = [[AVCaptureVideoDataOutput alloc] init];
    newCaptureOutput.alwaysDiscardsLateVideoFrames = YES; 
    videoDataOutputQueue = dispatch_queue_create("MSViewController", DISPATCH_QUEUE_SERIAL);
    [newCaptureOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    NSDictionary *outputSettings                   = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [newCaptureOutput setVideoSettings:outputSettings];
    
    AVCaptureSession* cSession = [[AVCaptureSession alloc] init];
    self.captureSession = cSession;
    [cSession release];
    
    // Resolution
    // These are recommended settings: do not change
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    
    if ([self.captureSession canAddInput:newVideoInput]) {
        [self.captureSession addInput:newVideoInput];
    }
    else {
        // Fallback to 480x360 (e.g. on 3GS devices)
        if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
            [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
        if ([self.captureSession canAddInput:newVideoInput]) {
            [self.captureSession addInput:newVideoInput];
        }
    }
    
    if ([self.captureSession canAddOutput:newCaptureOutput])
        [self.captureSession addOutput:newCaptureOutput];
    
    [newVideoInput release];
    [newCaptureOutput release];
    
    // Video preview
    if (!self.previewLayer)
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    CALayer* viewLayer = [_videoPreviewView layer];
    [viewLayer setMasksToBounds:YES];
    
    [self.previewLayer setFrame:[_videoPreviewView bounds]];
    
    if ([self.previewLayer isOrientationSupported])
        [self.previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    
    [self.captureSession startRunning];    
#endif
}

- (void)stopCapture {
#if MS_HAS_AVFF
    [captureSession stopRunning];
    
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*) [captureSession.outputs objectAtIndex:0];
    [captureSession removeOutput:output];
    
    if (videoDataOutputQueue)
		dispatch_release(videoDataOutputQueue);
    
    [self.previewLayer removeFromSuperlayer];
    
    self.previewLayer = nil;
    self.captureSession = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#endif
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

#if MS_HAS_AVFF
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!_processFrames)
        return;
    
    // Variables that hold *current* scanning result
    NSString *result = nil;
    MSResultType resultType = MSSCANNER_NONE;
    
    // -------------------------------------------------
    // Frame conversion
    // -------------------------------------------------
    MSScanner *scanner = [MSScanner sharedInstance];
    MSImage *qry = [[MSImage alloc] initWithBuffer:sampleBuffer orientation:self.orientation];
    
    // -------------------------------------------------
    // Previous result locking
    // -------------------------------------------------
    BOOL lock = NO;
    if (_result != nil && _losts < 2) {
        NSInteger found = 0;
        if (_resultType == MSSCANNER_IMAGE) {
            found = [scanner match:qry uid:_result error:nil] ? 1 : -1;
        }
        
        if (found == 1) {
            // The current frame matches with the previous result
            lock = YES;
            _losts = 0;
        }
        else if (found == -1) {
            // The current frame looks different so release the lock
            // if there is enough consecutive "no match"
            _losts++;
            lock = (_losts >= 2) ? NO : YES;
        }
    }
    
    if (lock) {
        // Re-use the previous result and skip searching / decoding
        // the current frame
        result = _result;
        resultType = _resultType;
    }
    
    BOOL freshResult = NO;
    
    // -------------------------------------------------
    // Image search
    // -------------------------------------------------
    if (result == nil) {
        NSError *err  = nil;
        // The actual query to Moodstocks
        NSString *imageID = [scanner search:qry error:&err];
        if (err != nil) {
            ms_errcode ecode = [err code];
            if (ecode != MS_EMPTY) {
                NSString *errStr = [NSString stringWithCString:ms_errmsg(ecode) encoding:NSUTF8StringEncoding];
                NSLog(@" SEARCH ERROR: %@", errStr);
            }
        }
        
        if (imageID != nil) {
            // The actual result
            freshResult = YES;
            result = imageID;
            resultType = MSSCANNER_IMAGE;
            
            [self processResult:imageID];
        }
    }
    
    
    // -------------------------------------------------
    // Notify the overlay
    // -------------------------------------------------
    if (result != nil) {
        _ts = [[NSDate date] timeIntervalSince1970];
        if (freshResult) _losts = 0;
        
        // Refresh the UI if a *new* result has been found
        if (![_result isEqualToString:result]) {
            [_result release];
            _result = [result copy];
            _resultType = resultType;
            _losts = 0;
        }
    }
    else if (_ts > 0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now - _ts >= 1.5 /* seconds */) {
            // This UI action must be dispatched into the main thread
            CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            });
            
            [_result release];
            _result = nil;   
            _resultType = MSSCANNER_NONE;
            
            _ts = -1;
        }
    }
    
    [qry release];
    return;
}
#endif


- (void)processResult:(NSString *)id{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    printf("[Moodstocks] Found image.\n");
    [appDelegate processResult: id];
    
    [self stopCapture];

    [self performSelectorOnMainThread:@selector(switchToPaintingView) withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(loadListHomesViewNext) withObject:nil afterDelay:0.25];
    
}

-(void)switchToPaintingView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PaintingViewController *paintingViewController =[storyboard instantiateViewControllerWithIdentifier:@"paintingViewController"];
    
    [self.navigationController pushViewController:paintingViewController animated:YES];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    _videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _videoPreviewView.backgroundColor = [UIColor blackColor];
    _videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _videoPreviewView.autoresizesSubviews = YES;
    [self.view addSubview:_videoPreviewView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MSScanner *scanner = [MSScanner sharedInstance];
    [scanner open:nil];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self startCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_videoPreviewView release];
    _videoPreviewView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Synchronization

- (void)sync {
#if MS_HAS_AVFF
    [[MSScanner sharedInstance] syncWithDelegate:self];
    printf("[Moodstocks] Synced.\n");
#endif
}

- (void)backgroundSync {
#if MS_HAS_AVFF
    MSScanner *scanner = [MSScanner sharedInstance];
    if (![scanner isSyncing]) {
        [scanner syncWithDelegate:self];
        printf("[Moodstocks] Synced.\n");
    }
#endif
}

#pragma mark - MSScannerDelegate

#if MS_HAS_AVFF
-(void)scannerWillSync:(MSScanner *)scanner {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSInteger count = [[MSScanner sharedInstance] count:nil];
    NSMutableDictionary *state = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"syncing"];
    [state setValue:[NSNumber numberWithInteger:count] forKey:@"images"];
}

- (void)scannerDidSync:(MSScanner *)scanner {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    NSInteger count = [[MSScanner sharedInstance] count:nil];
    NSMutableDictionary *state = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"syncing"];
    [state setValue:[NSNumber numberWithInteger:count] forKey:@"images"];
    if (_processFrames == NO) {
        [state setValue:[NSNumber numberWithBool:YES] forKey:@"ready"];
        _processFrames = YES;
    }
}

- (void)scanner:(MSScanner *)scanner failedToSyncWithError:(NSError *)error {
    [self scannerDidSync:scanner];
    
    ms_errcode ecode = [error code];
    // NOTE: ignore negative error codes which are not returned by the SDK
    //       but application specific (e.g. so far -1 is returned when cancelling)
    if (ecode >= 0) {
        NSString *errStr;
        if (ecode == MS_BUSY)
            errStr = @"A sync is pending";
        else
            errStr = [NSString stringWithCString:ms_errmsg(ecode) encoding:NSUTF8StringEncoding];
        
        [[[[UIAlertView alloc] initWithTitle:@"Sync error"
                                     message:errStr
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
    }
}
#endif
@end
