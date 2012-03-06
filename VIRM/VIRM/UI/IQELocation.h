/*
 Copyright (c) 2010-2011 IQ Engines, Inc.
 
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
//  IQELocation.h
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface IQELocation : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager* mLocationManager;
    
    CLLocationDegrees  mLatitude;
    CLLocationDegrees  mLongitude;
    CLLocationDistance mAltitude;
    BOOL               mEnabled;
}

@property(nonatomic, assign, readonly) CLLocationDegrees      latitude;
@property(nonatomic, assign, readonly) CLLocationDegrees      longitude;
@property(nonatomic, assign, readonly) CLLocationDistance     altitude;
@property(nonatomic, assign, readonly) CLLocationCoordinate2D coordinates;

+ (IQELocation*)location;

- (void) startLocating;
- (void) stopLocating;

extern CLLocationDegrees kIQEInvalidLocationDegrees;

@end
