#import "OpenCVViewController.h"
#import "UIImage+OpenCV.h"
#import "AppDelegate.h"
#import "HistoryItemViewController.h"
#import "HistoryItem.h"
#import "Recognizer.h"

#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <vector>

using namespace std;
using namespace cv;

@implementation OpenCVViewController

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;

#pragma mark -
#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		self.previewLayer = nil;
	}
	return self;
}

- (void)viewDidLoad {
    printf("[OpenCV] View loaded.\n");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    finishedLaunching = NO;
    
    eventQueue = [[NSMutableData alloc] init];
    counter = 0;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:HUD];     
    
    HUD.labelText = @"Loading images..";
    [HUD showWhileExecuting:@selector(setupApplication) onTarget:self withObject:nil animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (finishedLaunching && self.captureSession.isRunning == FALSE) { 
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:HUD];    
        
        HUD.labelText = @"Loading camera..";
        [HUD showWhileExecuting:@selector(startCapture) onTarget:self withObject:nil animated:YES];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    printf("[OpenCV] Capturesession stopped.\n");
    [self.captureSession stopRunning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void) setupApplication {   
    
    utils = [[Utils alloc] init];
    [utils initializeImageList];
    
    fileNames = [utils getFileNames];
    recognizer = [[Recognizer alloc] initWithDataSet:[utils getDescriptorsFromMatFiles]];
    
//    [self setupNetwork]; 
//    
//    // Temporary - network testing.
//    event[0] = 0x10;
//    [eventQueue appendBytes:event length:1];
//    
//    for(int i=0; i < INT_MAX; i++) {
//        [self sendMat];
//        [NSThread sleepForTimeInterval:1];        
//    }
    
    printf("[OpenCV] Adding capture to queue.\n");     
    
    [self setupCaptureSession];
    [self startCamera];
    finishedLaunching = YES;   
}

- (void) startCapture {
    printf("[OpenCV] Capturesession started.\n");        
    [self.captureSession startRunning]; 
}

- (void) startCamera {
    [self.view.layer addSublayer: self.previewLayer];
    
    // Start the session running to start the flow of data
    printf("[OpenCV] Initial capturesession started.\n");
    [self.captureSession startRunning];
    
    // Assign session to an ivar.
    [self setCaptureSession:self.captureSession];    
}

- (void)setupNetwork {
    printf("[Network] Setting up connection.\n");
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (CFStringRef) @"172.19.2.62",
                                       1337,
                                       &readStream,
                                       &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyShouldCloseNativeSocket,
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream,
                                 kCFStreamPropertyShouldCloseNativeSocket,
                                 kCFBooleanTrue);
        iStream = (NSInputStream *)readStream;
        [iStream retain];
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [iStream open];
        oStream = (NSOutputStream *)writeStream;
        [oStream retain];
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [oStream open];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            printf("[Network] Bytes available.\n");

            if(stream == iStream) {            
                NSMutableData *data = [[NSMutableData alloc] init];                
                uint8_t buffer[1];                
                
                int len = [iStream read:buffer maxLength:1];              
                [data appendBytes:buffer length:len];                
                
                [self handlePacket: data];
            } 
            break;
        }
        case NSStreamEventNone: {
            printf("[Network] No event occured.\n");
            break;
        }
        case NSStreamEventOpenCompleted: {
            printf("[Network] Open completed.\n");
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            printf("[Network] Space available.\n");
            if(stream == oStream) {
                
//                [self sendMat];
                
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *error = [stream streamError]; 
            printf("[Network] Error: %s.\n", [[error localizedDescription] UTF8String]);
            break;
        }
        case NSStreamEventEndEncountered: {
            printf("[Network] End of stream encountered.\n");
            break;            
        }
    }
}

- (void)sendMat {
    uint8_t currentEvent[1];
    [eventQueue getBytes:currentEvent length: 1];
    
    if(currentEvent[0] == 0x10) {
        
        Byte buffer[1];
        buffer[0] = 0x04;                    
        NSMutableData *data = [NSMutableData dataWithCapacity:0];
        [data appendBytes:buffer length:1];
        
        [data appendBytes:&dataSetDescriptors[0].rows length:sizeof(dataSetDescriptors[0].rows)];
        [data appendBytes:&dataSetDescriptors[0].cols length:sizeof(dataSetDescriptors[0].cols)];
        
        for(int i=0; i < dataSetDescriptors[0].rows; i++) {
            for(int j=0; j < dataSetDescriptors[0].cols; j++) {
                int value =  dataSetDescriptors[0].at<unsigned char>(i, j);            
                [data appendBytes:&value length:sizeof(value)]; 
            }
        }
        
        int err = [oStream write:(const uint8_t *)[data bytes] maxLength:[data length]];
        counter++;
        
        if(err >= 0) {
            printf("[Network] MAT sent [%i] times.\n", counter);  
        }
        
//        [eventQueue replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];    
    }     
}

- (void)handlePacket: (NSMutableData *) data {
    uint8_t received[1];
    [data getBytes:received length:1];
    
    switch(received[0]) {
        case 0x00 : {
            printf("[Network] PING received.\n");
            break;
        }
        case 0x01 : {
            printf("[Network] OK received.\n");
            break;
        }
        case 0x02 : {
            printf("[Network] FAIL received.\n");            
            break;
        }
        case 0x03 : {
            printf("[Network] CLOSE received.\n");            
            break;
        }
        case 0x05 : {
            printf("[Network] MATCH received.\n");
            [self handleMatch];
            break;
        }
        case 0x06 : {
            printf("[Network] NO_MATCH received.\n");            
            break;
        }            
    }
}

- (void)handleMatch {
    printf("[Network] Handling match.\n");
                   
    uint8_t buffer[4];                
    
    [iStream read:buffer maxLength:4];
                 
    int length = 0;
    for (int i = 0; i < 4; i++) {
        length |= (buffer[i] & 0xFF) << (i << 3);
    }
    
    uint8_t stringBuffer[length];
    [iStream read:stringBuffer maxLength:length];
    
    NSString *imageId = [[NSString alloc] initWithBytes:stringBuffer length:length encoding:NSUTF8StringEncoding];
    
    printf("[Network] ID Received: %s\n", [imageId UTF8String]);
}

- (void)setupCaptureSession 
{
    NSError *error = nil;
    
    // Create the session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [self.captureSession addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [self.captureSession addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings = 
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    AVCaptureConnection *conn = [output connectionWithMediaType:AVMediaTypeVideo];
    
    if (conn.supportsVideoMinFrameDuration)
        conn.videoMinFrameDuration = CMTimeMake(1,15);
    if (conn.supportsVideoMaxFrameDuration)
        conn.videoMaxFrameDuration = CMTimeMake(1,15);
    
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession]];
    self.previewLayer.orientation = UIInterfaceOrientationPortrait;
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CGRect layerRect = [[self view] bounds];
	[self.previewLayer setBounds:layerRect];
    [self.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection {
    
    UIImage* captureUI = [utils imageFromSampleBuffer:sampleBuffer];
    int match = [recognizer recognize:captureUI];
    
    if(match > -1) {
        [self processMatch:match];
    }
}

- (void) processMatch: (int) imageId {
    printf("[OpenCV] Image %d recognized!\n", imageId);
    
    [self.captureSession stopRunning];
    printf("[OpenCV] Capturesession stopped.\n");

    NSString* fileName = fileNames[imageId];
    
    UIImage *img = [UIImage imageNamed:fileName];
    
    [appDelegate.historyItemDataController addHistoryItem:fileName painter:fileName image:img];
    
    [self performSelectorOnMainThread:@selector(switchToPaintingView) withObject:nil waitUntilDone:NO];
}

-(void)switchToPaintingView{
    printf("[OpenCV] Switching to paintingview.\n");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    HistoryItemViewController *paintingViewController =[storyboard instantiateViewControllerWithIdentifier:@"paintingViewController"];
    
    paintingViewController.historyItem = [appDelegate.historyItemDataController getLastAddedHistoryItem];
    
    [self.navigationController pushViewController:paintingViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    printf("[OpenCV] Memory warning!\n");
}

- (void)viewDidUnload {
	self.previewLayer = nil;
}

- (void)dealloc {
	[self.captureSession release];
    [super dealloc];
}


@end
