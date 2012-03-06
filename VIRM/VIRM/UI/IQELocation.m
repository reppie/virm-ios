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
//  IQELocation.m
//

#import "IQELocation.h"

static IQELocation* g_Location = nil;

CLLocationDegrees kIQEInvalidLocationDegrees = MAXFLOAT;

@implementation IQELocation

@synthesize latitude  = mLatitude;
@synthesize longitude = mLongitude;
@synthesize altitude  = mAltitude;
@synthesize coordinates;

- (id)init
{
    self = [super init];
    if (self)
    {
        mLocationManager = nil;
        mLatitude  = kIQEInvalidLocationDegrees;
        mLongitude = kIQEInvalidLocationDegrees;
        mAltitude  = kIQEInvalidLocationDegrees;
        mEnabled   = YES;
    }
    
    return self;
}

- (void)dealloc
{
    if (mLocationManager)
    {
        mLocationManager.delegate = nil;
		[mLocationManager release];
    }
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton methods

+ (IQELocation*)location
{
    @synchronized(self)
    {
        if (g_Location == nil)
            g_Location = [[IQELocation alloc] init];
    }
    
	return g_Location;
}

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self)
    {
        if (g_Location == nil)
        {
            g_Location = [super allocWithZone:zone];
            return g_Location;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Location public methods

- (void) startLocating
{
    if (mEnabled == NO)
        return;
    
	if (mLocationManager)
	{
		[mLocationManager stopUpdatingLocation];
	}
	else
	{
		mLocationManager = [[CLLocationManager alloc] init];
		mLocationManager.delegate = self;
	}

	[mLocationManager startUpdatingLocation];
}

- (void) stopLocating
{
	if (mLocationManager)
	{
		[mLocationManager stopUpdatingLocation];
	}
}

- (CLLocationCoordinate2D) coordinates
{
    CLLocationCoordinate2D locationCoordinates;
    
    locationCoordinates.latitude  = mLatitude;
    locationCoordinates.longitude = mLongitude;
    
    return locationCoordinates;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate implementation

- (void)locationManager:(CLLocationManager*)manager
    didUpdateToLocation:(CLLocation*)newLocation
           fromLocation:(CLLocation*)oldLocation
{
    mLatitude  = newLocation.coordinate.latitude;
    mLongitude = newLocation.coordinate.longitude;
    mAltitude  = newLocation.altitude;
}

- (void)locationManager:(CLLocationManager*)manager
       didFailWithError:(NSError*)error
{
    // This error code is usually returned whenever user taps "Don't Allow"
	if (error.domain == kCLErrorDomain
    &&  error.code   == kCLErrorDenied)
    {
        mEnabled = NO;
    }
}

@end
