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
    
    width = 150;
    height = 150;
    
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
    
    NSDate* start = [NSDate date];
    
    NSMutableArray *imageList = [[NSMutableArray alloc] init];
    [imageList addObject:@"IMG_20120328_133650.jpg"];
    [imageList addObject:@"IMG_20120328_133717.jpg"];
    [imageList addObject:@"IMG_20120328_133800.jpg"];
    [imageList addObject:@"IMG_20120328_133813.jpg"];
    [imageList addObject:@"IMG_20120328_133844.jpg"];
    [imageList addObject:@"IMG_20120328_133855.jpg"];
    [imageList addObject:@"IMG_20120328_133903.jpg"];
    [imageList addObject:@"IMG_20120328_134104.jpg"];
    [imageList addObject:@"IMG_20120328_134112.jpg"];
    [imageList addObject:@"IMG_20120328_134125.jpg"];
    [imageList addObject:@"IMG_20120328_134135.jpg"];
    [imageList addObject:@"IMG_20120328_134143.jpg"];
    [imageList addObject:@"IMG_20120328_134152.jpg"];
    [imageList addObject:@"IMG_20120328_134208.jpg"];
    [imageList addObject:@"IMG_20120328_134301.jpg"];
    [imageList addObject:@"IMG_20120328_134320.jpg"];
    [imageList addObject:@"IMG_20120328_134432.jpg"];
    [imageList addObject:@"IMG_20120328_134446.jpg"];
    [imageList addObject:@"IMG_20120328_134503.jpg"];
    [imageList addObject:@"IMG_20120328_134513.jpg"];
    [imageList addObject:@"IMG_20120328_134521.jpg"];
    [imageList addObject:@"IMG_20120328_134529.jpg"];
    [imageList addObject:@"IMG_20120328_134544.jpg"];
    [imageList addObject:@"IMG_20120328_134551.jpg"];
    [imageList addObject:@"IMG_20120328_134601.jpg"];
    [imageList addObject:@"IMG_20120328_134610.jpg"];
    [imageList addObject:@"IMG_20120328_134621.jpg"];
    [imageList addObject:@"IMG_20120328_134629.jpg"];
    [imageList addObject:@"IMG_20120328_134705.jpg"];
    [imageList addObject:@"IMG_20120328_134719.jpg"];
    [imageList addObject:@"IMG_20120328_134727.jpg"];
    [imageList addObject:@"IMG_20120328_134750.jpg"];
    [imageList addObject:@"IMG_20120328_134801.jpg"];
    [imageList addObject:@"IMG_20120328_134811.jpg"];
    [imageList addObject:@"IMG_20120328_134823.jpg"];
    [imageList addObject:@"IMG_20120328_134832.jpg"];
    [imageList addObject:@"IMG_20120328_134840.jpg"];
    [imageList addObject:@"IMG_20120328_134849.jpg"];
    [imageList addObject:@"IMG_20120328_134934.jpg"];
    [imageList addObject:@"IMG_20120328_134948.jpg"];
    [imageList addObject:@"IMG_20120328_134955.jpg"];
    [imageList addObject:@"IMG_20120328_135004.jpg"];
    
    // No .mat files for these images yet.
//    [self addImageToDataset:@"IMG_20120328_135012.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135021.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135036.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135059.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135112.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135135.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135226.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135601.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135613.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135628.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135646.jpg"];
//    [self addImageToDataset:@"IMG_20120328_135941.jpg"];
    
    for(NSString *filename in imageList) {
        [self createDescriptorsFromFile:filename];
//        [self addImageToDataset:filename];        
    }
    
    printf("[OpenCV] Finished adding images. Dataset: %lu images.\n", dataSetDescriptors.size());
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    printf("[OpenCV] Time to load: %f.\n", timeInterval);
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
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
 
    // Clear previous results.
    keypointsCapture.clear();
    
    // Load capture image.
    UIImage* captureUI = [self imageFromSampleBuffer:sampleBuffer];
    Mat capture = [self MatFromUIImage:captureUI];
    Mat image(width, height, CV_8UC3);
    
    Mat imageGray;
    
    cvtColor(image, imageGray, CV_RGB2GRAY);    
    
    // Resizing.
    cv::resize(capture, imageGray, image.size());
    
    // Detect keypoints.
    featureDetector.detect(imageGray, keypointsCapture);
    
    // Extract features.
    featureExtractor.compute(imageGray, keypointsCapture, descriptorsCapture);
    
    [self match:descriptorsCapture];

	[pool drain];
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
            if( matches[k].distance < 35 ) {
                goodMatches++;   
            }
        }
        
        if(goodMatches > bestMatch) {
            bestMatch = goodMatches;
            imageId = i;
        }
        
        if(goodMatches > 12) {
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
    Mat testImageGray;
    
    cvtColor(testImage, testImageGray, CV_RGB2GRAY);
    
    featureDetector.detect(testImageGray, testKeypoints);
    featureExtractor.compute(testImageGray, testKeypoints, testDescriptors); 
    
    // Save the image as .mat file
//    [self saveDescriptorsToFile:testDescriptors fileName:filename];

    printf("[OpenCV] Rows size: %d.\n", testDescriptors.rows);
    printf("[OpenCV] Column size: %d.\n", testDescriptors.cols);
    
    dataSetDescriptors.push_back(testDescriptors);
}

- (void)createDescriptorsFromFile: (NSString *) filename {
    fileNames.push_back(filename);
    
    filename = [filename substringToIndex:[filename length] - 4];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"mat"];
    NSString *file = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];

    NSArray *content = [file componentsSeparatedByString: @","];
    
    int rows = [[content objectAtIndex:0] intValue];
    int cols = [[content objectAtIndex:1] intValue];
    
    Mat descriptors(rows, cols, CV_8U);
    
    for(int i=0; i < rows; i++) {
        for(int j=0; j < cols; j++) {

            descriptors.row(i).col(j) = [[content objectAtIndex:(i*cols)+j+2] intValue];
        }
    }
    dataSetDescriptors.push_back(descriptors);
}

- (void)saveDescriptorsToFile: (Mat)descriptors fileName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSString *content = @"";
    NSString *rows = [NSString stringWithFormat:@"%d,", descriptors.rows];
    NSString *cols = [NSString stringWithFormat:@"%d,", descriptors.cols];
    
    // Save the rows & cols.
    content = [content stringByAppendingString:rows];
    content = [content stringByAppendingString:cols];
    
    for(int i=0; i < descriptors.rows; i++) {
        for(int j=0; j < descriptors.cols; j++) {
            NSString *value = [NSString stringWithFormat: @"%d,", descriptors.at<unsigned char>(i, j)];
            content = [content stringByAppendingString:value];
        }
    }
    
    [content writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
    printf("[OpenCV] Saved image: %s.\n", [filename UTF8String]);
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
