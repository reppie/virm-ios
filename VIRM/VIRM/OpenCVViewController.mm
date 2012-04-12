#import "OpenCVViewController.h"
#import "UIImage+OpenCV.h"
#import "AppDelegate.h"
#import "HistoryItemViewController.h"
#import "HistoryItem.h"

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
    
    width = 100;
    height = 100;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    finishedLaunching = NO;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:HUD];

    HUD.labelText = @"Loading images..";
    [HUD showWhileExecuting:@selector(setupApplication) onTarget:self withObject:nil animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (finishedLaunching && self.captureSession.isRunning == FALSE) { 
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:HUD];    
        
        HUD.labelText = @"Loading camera";
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
    [self setupCaptureSession];
    [self loadImages];
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

- (void)loadImages {
    printf("[OpenCV] Adding images to dataset.\n");
    
    [self addImageToDataset:@"IMG_20120328_133650.jpg"];
    [self addImageToDataset:@"IMG_20120328_133717.jpg"];
    [self addImageToDataset:@"IMG_20120328_133800.jpg"];
    [self addImageToDataset:@"IMG_20120328_133813.jpg"];
    [self addImageToDataset:@"IMG_20120328_133844.jpg"];
    [self addImageToDataset:@"IMG_20120328_133855.jpg"];
    [self addImageToDataset:@"IMG_20120328_133903.jpg"];
    [self addImageToDataset:@"IMG_20120328_134104.jpg"];
    [self addImageToDataset:@"IMG_20120328_134112.jpg"];
    [self addImageToDataset:@"IMG_20120328_134125.jpg"];
    [self addImageToDataset:@"IMG_20120328_134135.jpg"];
    [self addImageToDataset:@"IMG_20120328_134143.jpg"];
    [self addImageToDataset:@"IMG_20120328_134152.jpg"];
    [self addImageToDataset:@"IMG_20120328_134208.jpg"];
    [self addImageToDataset:@"IMG_20120328_134301.jpg"];
    [self addImageToDataset:@"IMG_20120328_134320.jpg"];
    [self addImageToDataset:@"IMG_20120328_134432.jpg"];
    [self addImageToDataset:@"IMG_20120328_134446.jpg"];
    [self addImageToDataset:@"IMG_20120328_134503.jpg"];
    [self addImageToDataset:@"IMG_20120328_134513.jpg"];
    [self addImageToDataset:@"IMG_20120328_134521.jpg"];
    [self addImageToDataset:@"IMG_20120328_134529.jpg"];
    [self addImageToDataset:@"IMG_20120328_134544.jpg"];
    [self addImageToDataset:@"IMG_20120328_134551.jpg"];
    [self addImageToDataset:@"IMG_20120328_134601.jpg"];
    [self addImageToDataset:@"IMG_20120328_134610.jpg"];
    [self addImageToDataset:@"IMG_20120328_134621.jpg"];
    [self addImageToDataset:@"IMG_20120328_134629.jpg"];
    [self addImageToDataset:@"IMG_20120328_134705.jpg"];
    [self addImageToDataset:@"IMG_20120328_134719.jpg"];
    [self addImageToDataset:@"IMG_20120328_134727.jpg"];
    [self addImageToDataset:@"IMG_20120328_134750.jpg"];
    [self addImageToDataset:@"IMG_20120328_134801.jpg"];
    [self addImageToDataset:@"IMG_20120328_134811.jpg"];
    [self addImageToDataset:@"IMG_20120328_134823.jpg"];
    [self addImageToDataset:@"IMG_20120328_134832.jpg"];
    [self addImageToDataset:@"IMG_20120328_134840.jpg"];
    [self addImageToDataset:@"IMG_20120328_134849.jpg"];
    [self addImageToDataset:@"IMG_20120328_134934.jpg"];
    [self addImageToDataset:@"IMG_20120328_134948.jpg"];
    [self addImageToDataset:@"IMG_20120328_134955.jpg"];
    [self addImageToDataset:@"IMG_20120328_135004.jpg"];
    [self addImageToDataset:@"IMG_20120328_135012.jpg"];
    [self addImageToDataset:@"IMG_20120328_135036.jpg"];
    [self addImageToDataset:@"IMG_20120328_135059.jpg"];
    [self addImageToDataset:@"IMG_20120328_135112.jpg"];
    [self addImageToDataset:@"IMG_20120328_135135.jpg"];
    [self addImageToDataset:@"IMG_20120328_135226.jpg"];
    [self addImageToDataset:@"IMG_20120328_135601.jpg"];
    [self addImageToDataset:@"IMG_20120328_135613.jpg"];
    [self addImageToDataset:@"IMG_20120328_135628.jpg"];
    [self addImageToDataset:@"IMG_20120328_135646.jpg"];
    [self addImageToDataset:@"IMG_20120328_135941.jpg"];
    
    printf("[OpenCV] Finished adding images. Dataset: %lu images.\n", dataSetDescriptors.size());
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
       fromConnection:(AVCaptureConnection *)connection
{
    NSDate *start = [NSDate date];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
 
    // Clear previous results.
    keypointsCapture.clear();
    
    // Load capture image.
    UIImage* captureUI = [self imageFromSampleBuffer:sampleBuffer];
    Mat capture = [self MatFromUIImage:captureUI];
    Mat image(width, height, CV_8UC1);
    
    // Resizing.
    cv::resize(capture, image, image.size());
    
    // Detect keypoints.
    featureDetector.detect(image, keypointsCapture);
    
    // Extract features.
    featureExtractor.compute(image, keypointsCapture, descriptorsCapture);
    
    [self match:descriptorsCapture];

	[pool drain];
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    printf("[OpenCV] Time elapsed: %f.\n", timeInterval);
}

- (void) match: (Mat) captureInput {    
    // Create matcher.
    BFMatcher matcher(NORM_HAMMING);
    int bestMatch = 0;
    int imageId = 0;
    
    // Use the matcher.
    for(int i=0; i < dataSetDescriptors.size(); i++) {
        // Clear results & set distances.
        matches.clear();
        goodMatches = 0;
        
        // Match.
        matcher.match(captureInput, dataSetDescriptors[i], matches);        
    
        // Save good matches (low distance) in list.
        for(int k = 0; k < descriptorsCapture.rows; k++ ) {
            if( matches[k].distance < 50 ) {
                goodMatches++;   
            }
        }
        
        if(goodMatches > bestMatch) {
            bestMatch = goodMatches;
            imageId = i;
        }
        
        if(goodMatches > 30) {
            [self processMatch:imageId];
            break;
        }
        
    }
    printf("[OpenCV] Image ID : %d (%d matches) \n", imageId, bestMatch);
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

- (void) addImageToDataset: (NSString *) filename {
    fileNames.push_back(filename);
    
    testKeypoints.clear();
    
    UIImage* testImageUI = [UIImage imageNamed:filename];
    IplImage* testImageColored = [self IplImageFromUIImage:testImageUI]; 
    IplImage* testImageResized = cvCreateImage(cvSize(width,height),testImageColored->depth,testImageColored->nChannels);
    cvResize(testImageColored, testImageResized);
    
    Mat testImage(testImageResized);
    
    featureDetector.detect(testImage, testKeypoints);
    featureExtractor.compute(testImage, testKeypoints, testDescriptors); 
    
    dataSetDescriptors.push_back(testDescriptors);
}

- (Mat)MatFromUIImage:(UIImage *)image
{
    IplImage *iplImage = [self IplImageFromUIImage:image];
    Mat result(iplImage, true);
    cvReleaseImage(&iplImage);
    return result;
}

- (IplImage *)IplImageFromUIImage:(UIImage *)image 
{
    // NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2RGB);
    
    cvReleaseImage(&iplimage);
    
    return ret;
}

- (IplImage *)createIplImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    IplImage *iplimage = 0;
    if (sampleBuffer) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // get information of the image in the buffer
        uint8_t *bufferBaseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bufferWidth = CVPixelBufferGetWidth(imageBuffer);
        size_t bufferHeight = CVPixelBufferGetHeight(imageBuffer);
        
        // create IplImage
        if (bufferBaseAddress) {
            iplimage = cvCreateImage(cvSize(bufferWidth, bufferHeight), IPL_DEPTH_8U, 4);
            iplimage->imageData = (char*)bufferBaseAddress;
        }
        
        // release memory
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    else {
        printf("[OpenCV] Error: No sample buffer.\n");
    }
    
    return iplimage;
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t bWidth = CVPixelBufferGetWidth(imageBuffer); 
    size_t bHeight = CVPixelBufferGetHeight(imageBuffer); 
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, bWidth, bHeight, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)didReceiveMemoryWarning {
    printf("[OpenCV] Memory warning!");
}

- (void)viewDidUnload {
	self.previewLayer = nil;
}

- (void)dealloc {
	[self.captureSession release];
    [super dealloc];
}


@end
