//
//  NetworkHandler.m
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkHandler.h"

@implementation NetworkHandler

- (void) connect:(NSString *)ip :(int)port {
    printf("[Network] Connecting.\n");
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (CFStringRef) ip,
                                       port,
                                       &readStream,
                                       &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyShouldCloseNativeSocket,
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream,
                                 kCFStreamPropertyShouldCloseNativeSocket,
                                 kCFBooleanTrue);
        inputStream = (NSInputStream *)readStream;
        [inputStream retain];
        [inputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [inputStream open];
        
        outputStream = (NSOutputStream *)writeStream;
        [outputStream retain];
        [outputStream setDelegate:self];
        [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [outputStream open];
    }    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            printf("[Network] Bytes available.\n");
            
            if(stream == inputStream) {            
                NSMutableData *data = [[NSMutableData alloc] init];                
                uint8_t buffer[1];                
                
                int len = [inputStream read:buffer maxLength:1];              
                [data appendBytes:buffer length:len];                
                
                [self handlePacket: data];
            } 
            break;
        }
        case NSStreamEventNone: {
            printf("[Network] No event occured.\n");
            break;
        }
        case NSStreamEventOpenCompleted: {
            printf("[Network] Open completed.\n");
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            printf("[Network] Space available.\n");
            if(stream == outputStream) {
//                [self sendMat];
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *error = [stream streamError]; 
            printf("[Network] Error: %s.\n", [[error localizedDescription] UTF8String]);
            break;
        }
        case NSStreamEventEndEncountered: {
            printf("[Network] End of stream encountered.\n");
            break;            
        }
    }
}

- (void) handlePacket: (NSMutableData *) data {
    uint8_t received[1];
    [data getBytes:received length:1];
    
    switch(received[0]) {
        case 0x00 : {
            printf("[Network] PING received.\n");
            break;
        }
        case 0x01 : {
            printf("[Network] OK received.\n");
            break;
        }
        case 0x02 : {
            printf("[Network] FAIL received.\n");            
            break;
        }
        case 0x03 : {
            printf("[Network] CLOSE received.\n");            
            break;
        }
        case 0x05 : {
            printf("[Network] MATCH received.\n");
            [self handleMatch];
            break;
        }
        case 0x06 : {
            printf("[Network] NO_MATCH received.\n");            
            break;
        }            
    }
}

- (void) handleMatch {
    printf("[Network] Handling match.\n");
    
    uint8_t buffer[4];                
    
    [inputStream read:buffer maxLength:4];
    
    int length = 0;
    for (int i = 0; i < 4; i++) {
        length |= (buffer[i] & 0xFF) << (i << 3);
    }
    
    uint8_t stringBuffer[length];
    [inputStream read:stringBuffer maxLength:length];
    
    NSString *imageId = [[NSString alloc] initWithBytes:stringBuffer length:length encoding:NSUTF8StringEncoding];
    
    printf("[Network] ID Received: %s\n", [imageId UTF8String]);
}

- (void) sendPing {
    Byte buffer[1];
    buffer[0] = 0x00;                    
    NSMutableData *data = [NSMutableData dataWithCapacity:0];
    [data appendBytes:buffer length:1];
    
    [outputStream write:(const uint8_t *)[data bytes] maxLength:[data length]];
}

- (void) sendMat: (Mat) mat {
    Byte buffer[1];
    buffer[0] = 0x04;                    
    NSMutableData *data = [NSMutableData dataWithCapacity:0];
    [data appendBytes:buffer length:1];
        
    [data appendBytes:&mat.rows length:sizeof(mat.rows)];
    [data appendBytes:&mat.cols length:sizeof(mat.cols)];
        
    for(int i=0; i < mat.rows; i++) {
        for(int j=0; j < mat.cols; j++) {
            int value =  mat.at<unsigned char>(i, j);            
            [data appendBytes:&value length:sizeof(value)]; 
        }
    }
        
    [outputStream write:(const uint8_t *)[data bytes] maxLength:[data length]];   
}

- (NSInputStream *) getInputStream {
    return inputStream;
}

- (NSOutputStream *) getOutputStream {
    return outputStream;
}

@end
