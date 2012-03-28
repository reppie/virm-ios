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

- (void)viewWillAppear:(BOOL)animated {
    [self setupCaptureSession];
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
    // Create a UIImage from the sample buffer data
//    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    IplImage *capture = [self createIplImageFromSampleBuffer:sampleBuffer];
    
    Mat monaLisa = imread("mona_lisa.png", CV_LOAD_IMAGE_GRAYSCALE);
    if(monaLisa.empty())
    {
        printf("[OpenCV] Can't read image.\n");
    }    
    Mat image(capture);
    
    // Create smart pointer for SIFT feature detector.
    Ptr<FeatureDetector> featureDetector = FeatureDetector::create("ORB");
    
    vector<KeyPoint> keypointsTrained;    
    vector<KeyPoint> keypointsCapture;
    
    // Detect the keypoints
    featureDetector->detect(image, keypointsCapture); // NOTE: featureDetector is a pointer hence the '->'.
    featureDetector->detect(monaLisa, keypointsTrained);
    
    //Similarly, we create a smart pointer to the SIFT extractor.
    Ptr<DescriptorExtractor> featureExtractor = DescriptorExtractor::create("ORB");
    
    // Compute the 128 dimension SIFT descriptor at each keypoint.
    // Each row in "descriptors" correspond to the SIFT descriptor for each keypoint
    Mat descriptorsCapture;
    Mat descriptorsTrained;
    featureExtractor->compute(image, keypointsCapture, descriptorsCapture);
    featureExtractor->compute(monaLisa, keypointsTrained, descriptorsTrained);    
    //    // Add results to image and save.
    //    cv::Mat output;
    //    cv::drawKeypoints(input, keypoints, output);
    //    cv::imwrite("sift_result.jpg", output);
    
    vector<DMatch> matches;
    Ptr<DescriptorMatcher> descriptionMatcher = DescriptorMatcher::create("BruteForce-Hamming");
    descriptionMatcher->match(descriptorsCapture, descriptorsTrained, matches);
    
    printf("[OpenCV] Capture Keypoints size: %lu.\n", keypointsCapture.size());
    printf("[OpenCV] Trained Keypoints size: %lu.\n", keypointsTrained.size());
    printf("[OpenCV] Matches size: %lu.\n", matches.size());
    
	[pool drain];
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