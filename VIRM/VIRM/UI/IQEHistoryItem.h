/*
 Copyright (c) 2011-2012 IQ Engines, Inc.
 
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

// --------------------------------------------------------------------------------
//
//  IQEHistoryItem.h
//
// --------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef enum
{
    IQEHistoryItemTypeUnknown,
    IQEHistoryItemTypeRemoteObject,
    IQEHistoryItemTypeLocalObject,
    IQEHistoryItemTypeBarCode
} IQEHistoryItemType;

typedef enum
{
    IQEHistoryItemStateUnknown,
    IQEHistoryItemStateUploading,
    IQEHistoryItemStateSearching,
    IQEHistoryItemStateNotReady,
    IQEHistoryItemStateFound,
    IQEHistoryItemStateNotFound,
    IQEHistoryItemStateNetworkProblem,
    IQEHistoryItemStateTimeoutProblem
} IQEHistoryItemState;

// --------------------------------------------------------------------------------
//
// IQEHistoryItem
//
// --------------------------------------------------------------------------------

@interface IQEHistoryItem : NSObject
{
    
}

- (BOOL) isEqualToHistoryItem:(IQEHistoryItem*)historyItem;

@property(nonatomic, retain) NSString*            title;

@property(nonatomic, assign) IQEHistoryItemType   type;
@property(nonatomic, assign) IQEHistoryItemState  state;
@property(nonatomic, retain) NSString*            imageFile;
@property(nonatomic, retain) NSString*            thumbFile;

// Remote Object
@property(nonatomic, retain) NSString*            qid;
@property(nonatomic, retain) NSDictionary*        qidData;
// Local Object
@property(nonatomic, retain) NSString*            objId;
@property(nonatomic, retain) NSString*            objName;
@property(nonatomic, retain) NSString*            objMeta;
// BarCode
@property(nonatomic, retain) NSString*            codeData;
@property(nonatomic, retain) NSString*            codeType;
@property(nonatomic, retain) NSString*            codeDesc;

// Encode/decode as a property list.
- (id)   initWithDictionary:(NSDictionary*)dictionary;
- (void) encodeWithDictionary:(NSMutableDictionary*)dictionary;

// Multi-type state logic.
- (void) setState:(IQEHistoryItemState)state forType:(IQEHistoryItemType)type;
- (BOOL) complete;
- (BOOL) found;

@end

extern NSString* const IQEHistoryItemTitleChangeNotification;
extern NSString* const IQEHistoryItemStateChangeNotification;

// --------------------------------------------------------------------------------
//
// HistoryArray
//
// --------------------------------------------------------------------------------

@interface NSMutableArray (IQEHistoryItem)

// Encode/decode as a property list.
- (id)   initWithNSArray:(NSArray*)array;
- (void) encodeWithNSArray:(NSMutableArray*)array;

- (IQEHistoryItem*) historyItemForQID:(NSString*)qid;
- (id)              firstObject;

@end

// --------------------------------------------------------------------------------

