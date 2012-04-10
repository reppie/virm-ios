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
    
    [self addImageToDataset:@"mona_lisa.png"];
    [self addImageToDataset:@"nachtwacht.jpg"];
    
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
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
 
    // Clear previous results.
    keypointsCapture.clear();
    
    // Create matcher.
    BFMatcher matcher(NORM_HAMMING);
    
    // Load capture image.
    IplImage* capture = [self createIplImageFromSampleBuffer:sampleBuffer];
    
    // Resizing.
    IplImage* resizedCapture = cvCreateImage(cvSize(150,150),capture->depth,capture->nChannels);
    cvResize(capture, resizedCapture);
    
    // Convert to Mat.
    Mat image(resizedCapture);   
    
    // Detect keypoints.
    featureDetector.detect(image, keypointsCapture);
    
    // Extract features.
    featureExtractor.compute(image, keypointsCapture, descriptorsCapture);
    
    [self match:descriptorsCapture];

	[pool drain];
}

- (void) match: (Mat) captureInput {
    // Create matcher.
    BFMatcher matcher(NORM_HAMMING);
    
    // Use the matcher.
    for(int i=0; i < dataSetDescriptors.size(); i++) {
        // Clear results & set distances.
        matches.clear();
        goodMatches = 0;
        
        // Set distances.
        double min_dist = 25;
        double max_dist = 0;
        
        // Match.
        matcher.match(captureInput, dataSetDescriptors[i], matches);        
    
        // For every keypoint, check its distance.
    
        for(int j = 0; j < descriptorsCapture.rows; j++) { 
            double dist = matches[j].distance;
            if( dist < min_dist ) min_dist = dist;
            if( dist > max_dist ) max_dist = dist;
        }
    
        // Save good matches (low distance) in list.
        for(int k = 0; k < descriptorsCapture.rows; k++ ) {
            
            if( matches[k].distance < 2*min_dist ) {
                goodMatches++;
                
                if(goodMatches > 30) {
                    [self processMatch:i];
                    break;
                }                
            }
        }
        printf("[OpenCV] Image #%d - Good matches : %d. \n", i, goodMatches);
    }
}

- (void) processMatch: (int) imageId {
//    printf("[OpenCV] Image %d recognized!\n", imageId);
    
    // Temporary hack.
    if(imageId == 0) {
        printf("[OpenCV] Mona Lisa found!\n");
    }
    if(imageId == 1) {
        printf("[OpenCV] Nachtwacht found!\n");
    }
}

- (void) addImageToDataset: (NSString *) filename {
    printf("[OpenCV] Adding image to dataset.\n");
    testKeypoints.clear();
    
    UIImage* testImageUI = [UIImage imageNamed:filename];
    IplImage* testImageColored = [self IplImageFromUIImage:testImageUI]; 
    IplImage* testImageResized = cvCreateImage(cvSize(150,150),testImageColored->depth,testImageColored->nChannels);
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
