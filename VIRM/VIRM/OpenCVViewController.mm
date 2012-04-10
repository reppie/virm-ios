#import "OpenCVViewController.h"
#import "UIImage+OpenCV.h"

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
		/*We initialize some variables (they might be not initialized depending on what is commented or not)*/
        
		self.previewLayer = nil;
	}
	return self;
}

- (void)viewDidLoad {
    printf("[OpenCV] View loaded.\n");
    [self setupCaptureSession];
    totalMatches = 0;
    totalCaptures = 0;
}

- (void) viewDidDisappear:(BOOL)animated {
    printf("[OpenCV] Capturesession stopped.\n");
    [self.captureSession stopRunning];
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
    [self.view.layer addSublayer: self.previewLayer];
    
    // Start the session running to start the flow of data
    printf("[OpenCV] Capturesession started.\n");
    [self.captureSession startRunning];
    
    // Assign session to an ivar.
    [self setCaptureSession:self.captureSession];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
//    NSDate *start = [NSDate date];
    
    // Create a UIImage from the sample buffer data
    //    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
    IplImage* capture = [self createIplImageFromSampleBuffer:sampleBuffer];
    IplImage* resizedCapture = cvCreateImage(cvSize(150,150),capture->depth,capture->nChannels);
    
    UIImage *uiImage = [UIImage imageNamed:@"mona_lisa.png"];
    IplImage* monaLisaColored = [self IplImageFromUIImage:uiImage];
    IplImage* resizedIplImageColored = cvCreateImage(cvSize(150,150),monaLisaColored->depth,monaLisaColored->nChannels);
    
    // Gray scaling stuff
    //    IplImage *monaLisaGray = cvCreateImage(cvGetSize(monaLisaColored), 8, 1);
    //    IplImage *resizedIplImageGray = cvCreateImage(cvGetSize(resizedIplImageColored), 8, 1);    
    //    cvCvtColor(monaLisaColored,monaLisaGray,CV_BGR2GRAY);
    //    cvCvtColor(resizedIplImageColored,resizedIplImageGray,CV_BGR2GRAY);    
    //    
    cvResize(monaLisaColored, resizedIplImageColored);
    cvResize(capture, resizedCapture);
    
    Mat target(resizedIplImageColored);
    Mat image(resizedCapture);   
    
    // Create smart pointer for ORB feature detector.
    OrbFeatureDetector featureDetector;
    
    vector<KeyPoint> keypointsTrained;    
    vector<KeyPoint> keypointsCapture;
    
    // Detect the keypoints
    featureDetector.detect(image, keypointsCapture);
    featureDetector.detect(target, keypointsTrained);
    
    //Similarly, we create a smart pointer to the ORB extractor.
    OrbDescriptorExtractor featureExtractor;
    
    // Compute the 128 dimension SIFT descriptor at each keypoint.
    // Each row in "descriptors" correspond to the ORB descriptor for each keypoint
    Mat descriptorsCapture;
    Mat descriptorsTrained;
    featureExtractor.compute(image, keypointsCapture, descriptorsCapture);
    featureExtractor.compute(target, keypointsTrained, descriptorsTrained); 
    
    vector<DMatch> matches;
    BFMatcher matcher(NORM_HAMMING);
    matcher.match(descriptorsCapture, descriptorsTrained, matches);
    
    double max_dist = 0; 
    double min_dist = 25;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptorsCapture.rows; i++) { 
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist )
    //-- PS.- radiusMatch can also be used here.
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptorsCapture.rows; i++ ) {
        if( matches[i].distance < 2*min_dist ) {
            good_matches.push_back(matches[i]);
        }
    }
    
    //    printf("[OpenCV] Capture Keypoints size: %lu.\n", keypointsCapture.size());
    //    printf("[OpenCV] Trained Keypoints size: %lu.\n", keypointsTrained.size());
    //    printf("[OpenCV] Matches size: %lu.\n", matches.size());
    //    printf("[OpenCV] Max dist : %f. \n", max_dist);
    //    printf("[OpenCV] Min dist : %f. \n", min_dist);
    printf("[OpenCV] Good matches : %lu. \n", good_matches.size());
    
    //    for( int i = 0; i < good_matches.size(); i++ ) {
    //        printf( "[OpenCV] Good Match [%d] Keypoint 1: %d  -- Keypoint 2: %d.  \n", i, good_matches[i].queryIdx, good_matches[i].trainIdx ); 
    //    }
    
    // Check for result
    if(good_matches.size() > 30) {
        printf("[OpenCV] Mona Lisa recognized!\n");
    }
    
    // Calculate averages
    //    totalMatches = totalMatches + good_matches.size();
    //    totalCaptures++;
    //    
    //    int average = totalMatches / totalCaptures;
    //    printf("[OpenCV] Average number of matches: %i.\n", average);
    
    // Calculate time
//    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    
    //    printf("[OpenCV] FPS: %f.\n", (1 / timeInterval) * -1);
    
	[pool drain];
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
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
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

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.previewLayer = nil;
}

- (void)dealloc {
	[self.captureSession release];
    [super dealloc];
}


@end
