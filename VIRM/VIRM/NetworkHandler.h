//
//  NetworkHandler.h
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace cv;

@interface NetworkHandler : NSObject <NSStreamDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}

- (NSOutputStream *) getOutputStream;
- (NSInputStream *) getInputStream;

- (void) connect: (NSString *) ip: (int) port;
- (void) handlePacket: (NSMutableData *) data;
- (void) handleMatch;
- (void) sendMat: (Mat) mat;
- (void) sendPing;

@end
