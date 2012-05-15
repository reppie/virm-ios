//
//  Utils.m
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

using namespace std;
using namespace cv;

@implementation Utils

- (id) init {
    if(self = [super init]) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (vector<NSString*>) getFileNames {  
    return fileNames;
}

- (vector<Mat>)getDescriptorsFromImageFiles:(BOOL)saveToMat {
    vector<Mat> dataSetDescriptors;
    
    vector<KeyPoint> keypoints;
    OrbFeatureDetector featureDetector;
    OrbDescriptorExtractor featureExtractor;    
    Mat descriptors;

    for(NSString *filename in imageList) {
    
        keypoints.clear();
    
        UIImage* imageUI = [UIImage imageNamed:filename];
        IplImage* imageColored = [self IplImageFromUIImage:imageUI]; 
        IplImage* imageResized = cvCreateImage(cvSize(appDelegate.imageDimensions,appDelegate.imageDimensions),imageColored->depth,imageColored->nChannels);
        cvResize(imageColored, imageResized);
    
        Mat image(imageResized);
        Mat imageGray;
    
        cvtColor(image, imageGray, CV_RGB2GRAY);
    
        featureDetector.detect(imageGray, keypoints);
        featureExtractor.compute(imageGray, keypoints, descriptors); 
    
        // Save the image as .mat file
        if(saveToMat) {
            [self saveDescriptorsToFile:descriptors fileName:filename];
        }
    
        dataSetDescriptors.push_back(descriptors);    
    }
    return dataSetDescriptors;
}

- (vector<Mat>)getDescriptorsFromMatFiles {
    
    vector<Mat> dataSetDescriptors;
    
    for(NSString *filename in imageList) {
    
        filename = [filename substringToIndex:[filename length] - 4];
    
        NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"mat"];
    
        NSData *content = [NSData dataWithContentsOfFile:filePath];
    
        uint32_t rows; 
        [content getBytes:&rows range:NSMakeRange(0, 4)]; 
    
        uint32_t cols;    
        [content getBytes:&cols range:NSMakeRange(4, 4)];         
    
        Mat descriptors(rows, cols, CV_8U);
    
        int startPos = 8;
        for(int i=0; i < rows; i++) {
            for(int j=0; j < cols; j++) {
                uint32_t value;
                [content getBytes:&value range:NSMakeRange(startPos, 4)];                
                descriptors.row(i).col(j) = value;             
                startPos +=  4;
            }
        }
        dataSetDescriptors.push_back(descriptors);
    }
    
    return dataSetDescriptors;
}

- (void)saveDescriptorsToFile: (Mat)descriptors fileName:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&descriptors.rows length:sizeof(descriptors.rows)];
    [data appendBytes:&descriptors.cols length:sizeof(descriptors.cols)];   
    
    for(int i=0; i < descriptors.rows; i++) {
        for(int j=0; j < descriptors.cols; j++) {
            int value =  descriptors.at<unsigned char>(i, j);            
            [data appendBytes:&value length:sizeof(value)];            
        }
    }
    
    [data writeToFile:filePath atomically:YES];
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

- (void) initializeImageList {
    imageList = [[NSMutableArray alloc] init];
    
    [imageList addObject:@"IMG_20120328_133650.jpg"];
    [imageList addObject:@"IMG_20120328_133717.jpg"];
    [imageList addObject:@"IMG_20120328_133800.jpg"];
//    [imageList addObject:@"IMG_20120328_133813.jpg"];
//    [imageList addObject:@"IMG_20120328_133844.jpg"];
//    [imageList addObject:@"IMG_20120328_133855.jpg"];
//    [imageList addObject:@"IMG_20120328_133903.jpg"];
//    [imageList addObject:@"IMG_20120328_134104.jpg"];
//    [imageList addObject:@"IMG_20120328_134112.jpg"];
//    [imageList addObject:@"IMG_20120328_134125.jpg"];
//    [imageList addObject:@"IMG_20120328_134135.jpg"];
//    [imageList addObject:@"IMG_20120328_134143.jpg"];
//    [imageList addObject:@"IMG_20120328_134152.jpg"];
//    [imageList addObject:@"IMG_20120328_134208.jpg"];
//    [imageList addObject:@"IMG_20120328_134301.jpg"];
//    [imageList addObject:@"IMG_20120328_134320.jpg"];
//    [imageList addObject:@"IMG_20120328_134432.jpg"];
//    [imageList addObject:@"IMG_20120328_134446.jpg"];
//    [imageList addObject:@"IMG_20120328_134503.jpg"];
//    [imageList addObject:@"IMG_20120328_134513.jpg"];
//    [imageList addObject:@"IMG_20120328_134521.jpg"];
//    [imageList addObject:@"IMG_20120328_134529.jpg"];
//    [imageList addObject:@"IMG_20120328_134544.jpg"];
//    [imageList addObject:@"IMG_20120328_134551.jpg"];
//    [imageList addObject:@"IMG_20120328_134601.jpg"];
//    [imageList addObject:@"IMG_20120328_134610.jpg"];
//    [imageList addObject:@"IMG_20120328_134621.jpg"];
//    [imageList addObject:@"IMG_20120328_134629.jpg"];
//    [imageList addObject:@"IMG_20120328_134705.jpg"];
//    [imageList addObject:@"IMG_20120328_134719.jpg"];
//    [imageList addObject:@"IMG_20120328_134727.jpg"];
//    [imageList addObject:@"IMG_20120328_134750.jpg"];
//    [imageList addObject:@"IMG_20120328_134801.jpg"];
//    [imageList addObject:@"IMG_20120328_134811.jpg"];
//    [imageList addObject:@"IMG_20120328_134823.jpg"];
//    [imageList addObject:@"IMG_20120328_134832.jpg"];
//    [imageList addObject:@"IMG_20120328_134840.jpg"];
//    [imageList addObject:@"IMG_20120328_134849.jpg"];
//    [imageList addObject:@"IMG_20120328_134934.jpg"];
//    [imageList addObject:@"IMG_20120328_134948.jpg"];
//    [imageList addObject:@"IMG_20120328_134955.jpg"];
//    [imageList addObject:@"IMG_20120328_135004.jpg"];
//    [imageList addObject:@"IMG_20120328_135012.jpg"];
//    [imageList addObject:@"IMG_20120328_135021.jpg"];
//    [imageList addObject:@"IMG_20120328_135036.jpg"];
//    [imageList addObject:@"IMG_20120328_135059.jpg"];
//    [imageList addObject:@"IMG_20120328_135112.jpg"];
//    [imageList addObject:@"IMG_20120328_135135.jpg"];
//    [imageList addObject:@"IMG_20120328_135226.jpg"];
//    [imageList addObject:@"IMG_20120328_135601.jpg"];
//    [imageList addObject:@"IMG_20120328_135613.jpg"];
//    [imageList addObject:@"IMG_20120328_135628.jpg"];
//    [imageList addObject:@"IMG_20120328_135646.jpg"];
//    [imageList addObject:@"IMG_20120328_135941.jpg"];
//    
//    // Museum #2
//    [imageList addObject:@"IMG_20120502_134328.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134336.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134349.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134358.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134407.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134418.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134433.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134440.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134447.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134455.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134526.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134534.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134541.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134547.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134557.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134605.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134612.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134619.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134626.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134647.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134653.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134700.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134707.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134713.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134720.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134755.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134803.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134812.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134822.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134834.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134842.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134850.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134859.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134907.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134914.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134939.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134948.jpg"]; 
//    [imageList addObject:@"IMG_20120502_134957.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135009.jpg"];
//    [imageList addObject:@"IMG_20120502_135018.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135027.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135050.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135057.jpg"];    
//    [imageList addObject:@"IMG_20120502_135126.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135140.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135152.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135200.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135207.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135215.jpg"]; 
//    [imageList addObject:@"IMG_20120502_135224.jpg"];    
    
    for(NSString *filename in imageList) {
        fileNames.push_back(filename);        
    }    
}

@end
