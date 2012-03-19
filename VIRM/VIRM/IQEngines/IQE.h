// --------------------------------------------------------------------------------
//
//  IQE.h
//
//  Copyright (c) 2011-2012 IQ Engines, Inc. All rights reserved.
//
//  Version 1.0
//
// --------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@class IQE;

typedef enum
{
    IQESearchTypeObjectSearch = 1 << 0,
    IQESearchTypeRemoteSearch = 1 << 1,
    IQESearchTypeBarCode      = 1 << 2,
    IQESearchTypeAll          = 0xFFFFFFFF,
} IQESearchType;

typedef enum
{
    IQEStatusUnknown,
    IQEStatusError,
    IQEStatusUploading,
    IQEStatusSearching,
    IQEStatusNotReady,
    IQEStatusComplete,
} IQEStatus;

// --------------------------------------------------------------------------------
//
// IQE Delegate 
//
// --------------------------------------------------------------------------------

@protocol IQEDelegate <NSObject>
@optional
- (void) iqEngines:(IQE*)iqe didCompleteSearch:(IQESearchType)type withResults:(NSDictionary*)results forQID:(NSString*)qid;
- (void) iqEngines:(IQE*)iqe statusDidChange:(IQEStatus)status forQID:(NSString*)qid;
- (void) iqEngines:(IQE*)iqe failedWithError:(NSError*)error;
- (void) iqEngines:(IQE*)iqe didFindBarcodeDescription:(NSString*)desc forUPC:(NSString*)upc;
- (void) iqEngines:(IQE*)iqe didCaptureStillFrame:(UIImage*)image;
@end

// --------------------------------------------------------------------------------
//
// IQE
//
// The IQE class provides an interface for IQ Engines image recognition.
// Remote and local databases can be used to search for image information.
// Encapsulates image capture from the default camera device. 
//
// --------------------------------------------------------------------------------

@interface IQE : NSObject
{
    id<IQEDelegate> mDelegate;
}

- (id)initWithSearchType:(IQESearchType)searchType;
- (id)initWithSearchType:(IQESearchType)searchType apiKey:(NSString*)key apiSecret:(NSString*)secret;

@property(nonatomic, assign) id<IQEDelegate> delegate;

@property(nonatomic, assign)   BOOL     autoDetection; // Automatic local detection. default is YES
@property(nonatomic, readonly) CALayer* previewLayer;  // Previews visual output of the camera device.

- (void)startCamera;
- (void)stopCamera;

- (void)captureStillFrame; // Image returned asynchronously through iqEngines:didCaptureStillFrame:

- (NSString*)searchWithImage:(UIImage*)image;
- (NSString*)searchWithImage:(UIImage*)image atLocation:(CLLocationCoordinate2D)location;
- (void)     searchWithQID:(NSString*)qid;
- (void)     updateResults:(NSDictionary*)results forQID:(NSString*)qid;

@end

// --------------------------------------------------------------------------------

// Dictionary keys for iqEngines:didCompleteSearch: results
extern NSString* const IQEKeyQID;
extern NSString* const IQEKeyQIDData;
extern NSString* const IQEKeyColor;
extern NSString* const IQEKeyISBN;
extern NSString* const IQEKeyLabels;
extern NSString* const IQEKeySKU;
extern NSString* const IQEKeyUPC;
extern NSString* const IQEKeyURL;
extern NSString* const IQEKeyQRCode;
extern NSString* const IQEKeyMeta;
extern NSString* const IQEKeyObjId;

extern NSString* const IQEKeyObjectId;
extern NSString* const IQEKeyObjectName;
extern NSString* const IQEKeyObjectMeta;
extern NSString* const IQEKeyObjectImagePath;

extern NSString* const IQEKeyBarcodeData;
extern NSString* const IQEKeyBarcodeType;

// codeTypes for iqEngines:didDetectBarcode:codeType:
extern NSString* const IQEBarcodeTypeCODE39;
extern NSString* const IQEBarcodeTypeCODE93;
extern NSString* const IQEBarcodeTypeCODE128;
extern NSString* const IQEBarcodeTypeCOMPOSITE;
extern NSString* const IQEBarcodeTypeDATABAR;
extern NSString* const IQEBarcodeTypeDATABAR_EXP;
extern NSString* const IQEBarcodeTypeEAN2;
extern NSString* const IQEBarcodeTypeEAN5;
extern NSString* const IQEBarcodeTypeEAN8;
extern NSString* const IQEBarcodeTypeEAN13;
extern NSString* const IQEBarcodeTypeI25;
extern NSString* const IQEBarcodeTypeISBN10;
extern NSString* const IQEBarcodeTypeISBN13;
extern NSString* const IQEBarcodeTypePDF417;
extern NSString* const IQEBarcodeTypeQRCODE;
extern NSString* const IQEBarcodeTypeUPCA;
extern NSString* const IQEBarcodeTypeUPCE;

// --------------------------------------------------------------------------------
