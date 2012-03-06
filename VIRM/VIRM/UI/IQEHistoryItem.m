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

//
//  IQEHistoryItem.m
//

#import "IQEHistoryItem.h"
#import "IQE.h"

#define HISTORYITEM_KEY_TYPE              @"type"
#define HISTORYITEM_KEY_STATE             @"state"
#define HISTORYITEM_KEY_IMAGEFILE         @"imageFile"
#define HISTORYITEM_KEY_THUMBFILE         @"thumbFile"

#define HISTORYITEM_KEY_QID               @"qid"
#define HISTORYITEM_KEY_QIDDATA           @"qidData"

#define HISTORYITEM_KEY_OBJID             @"objId"
#define HISTORYITEM_KEY_OBJNAME           @"objName"
#define HISTORYITEM_KEY_OBJMETA           @"objMeta"

#define HISTORYITEM_KEY_CODEDATA          @"codeData"
#define HISTORYITEM_KEY_CODETYPE          @"codeType"
#define HISTORYITEM_KEY_CODEDESC          @"codeDescription"

#define HISTORYITEM_TYPE_UNKNOWN          @"unknown"
#define HISTORYITEM_TYPE_REMOTE           @"remote"
#define HISTORYITEM_TYPE_LOCAL            @"local"
#define HISTORYITEM_TYPE_BARCODE          @"barcode"

#define HISTORYITEM_STATE_UNKNOWN         @"unknown"
#define HISTORYITEM_STATE_UPLOADING       @"uploading"
#define HISTORYITEM_STATE_SEARCHING       @"searching"
#define HISTORYITEM_STATE_FOUND           @"found"
#define HISTORYITEM_STATE_NOTFOUND        @"notfound"
#define HISTORYITEM_STATE_NOTREADY        @"notready"
#define HISTORYITEM_STATE_NETWORK_PROBLEM @"networkproblem"
#define HISTORYITEM_STATE_TIMEOUT_PROBLEM @"timeoutproblem"

#define BUNDLE_TABLE @"IQE"

NSString* const IQEHistoryItemTitleChangeNotification = @"IQEHistoryItemTitleChangeNotification";
NSString* const IQEHistoryItemStateChangeNotification = @"IQEHistoryItemStateChangeNotification";

@interface IQEHistoryItem ()
@property(nonatomic, retain) NSMutableDictionary* mStates;
- (NSString*)           stringFromState:(IQEHistoryItemState)aState;
- (NSString*)           stringFromType:(IQEHistoryItemType)aType;
- (IQEHistoryItemState) stateFromString:(NSString*)aString;
- (IQEHistoryItemType)  typeFromString:(NSString*)aString;
@end

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark IQEHistoryItem implementation
/* -------------------------------------------------------------------------------- */

@implementation IQEHistoryItem

@synthesize mStates;
@synthesize type;
@synthesize state;
@synthesize imageFile;
@synthesize thumbFile;
@synthesize qid;
@synthesize qidData;
@synthesize objId;
@synthesize objName;
@synthesize objMeta;
@synthesize codeData;
@synthesize codeType;
@synthesize codeDesc;

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark IQEHistoryItem lifecycle
/* -------------------------------------------------------------------------------- */

- (id) init
{
    self = [super init];
    if (self)
    {
        type  = IQEHistoryItemTypeUnknown;
        state = IQEHistoryItemStateUnknown;
        
        self.mStates = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)dict
{
    self = [self init];
    if (self)
    {
        NSString* strType = [dict objectForKey:HISTORYITEM_KEY_TYPE];
        type      = [self typeFromString:strType];
        
        NSString* strStatus = [dict objectForKey:HISTORYITEM_KEY_STATE];
        state     = [self stateFromString:strStatus];
                
        self.imageFile = [dict objectForKey:HISTORYITEM_KEY_IMAGEFILE];
        self.thumbFile = [dict objectForKey:HISTORYITEM_KEY_THUMBFILE];

        self.qid       = [dict objectForKey:HISTORYITEM_KEY_QID];
        self.qidData   = [dict objectForKey:HISTORYITEM_KEY_QIDDATA];
        
        self.objId     = [dict objectForKey:HISTORYITEM_KEY_OBJID];
        self.objName   = [dict objectForKey:HISTORYITEM_KEY_OBJNAME];
        self.objMeta   = [dict objectForKey:HISTORYITEM_KEY_OBJMETA];
        
        self.codeData  = [dict objectForKey:HISTORYITEM_KEY_CODEDATA];
        self.codeType  = [dict objectForKey:HISTORYITEM_KEY_CODETYPE];
        self.codeDesc  = [dict objectForKey:HISTORYITEM_KEY_CODEDESC];
    }
    return self;
}

- (void) encodeWithDictionary:(NSMutableDictionary*)dictionary
{
    [dictionary setObject:[self stringFromType:type]   forKey:HISTORYITEM_KEY_TYPE];
    [dictionary setObject:[self stringFromState:state] forKey:HISTORYITEM_KEY_STATE];
        
    if (imageFile)   [dictionary setObject:imageFile   forKey:HISTORYITEM_KEY_IMAGEFILE];
    if (thumbFile)   [dictionary setObject:thumbFile   forKey:HISTORYITEM_KEY_THUMBFILE];
    
    if (qid)         [dictionary setObject:qid         forKey:HISTORYITEM_KEY_QID];
    if (qidData)     [dictionary setObject:qidData     forKey:HISTORYITEM_KEY_QIDDATA];

    if (objId)       [dictionary setObject:objId       forKey:HISTORYITEM_KEY_OBJID];
    if (objName)     [dictionary setObject:objName     forKey:HISTORYITEM_KEY_OBJNAME];
    if (objMeta)     [dictionary setObject:objMeta     forKey:HISTORYITEM_KEY_OBJMETA];

    if (codeData)    [dictionary setObject:codeData    forKey:HISTORYITEM_KEY_CODEDATA];
    if (codeType)    [dictionary setObject:codeType    forKey:HISTORYITEM_KEY_CODETYPE];
    if (codeDesc)    [dictionary setObject:codeDesc    forKey:HISTORYITEM_KEY_CODEDESC];
}

- (void) dealloc
{
    [imageFile release];
    [thumbFile release];
    
    [qid       release];
    [qidData   release];
    
    [objId     release];
    [objName   release];
    [objMeta   release];
    
    [codeData  release];
    [codeType  release];
    [codeDesc  release];
    
    [mStates   release];
    
    [super dealloc];
}

- (BOOL) isEqualToHistoryItem:(IQEHistoryItem*)historyItem
{
    if (historyItem == self)
        return YES;
    
    if (type == IQEHistoryItemTypeRemoteObject
    ||  type == IQEHistoryItemTypeUnknown)
    {
        return ([historyItem.qid isEqualToString:qid]);
    }
    else
    if (type == IQEHistoryItemTypeLocalObject)
    {
        return ([historyItem.objId   isEqualToString:objId]
            &&  [historyItem.objName isEqualToString:objName]
            &&  [historyItem.objMeta isEqualToString:objMeta]);
    }
    else
    if (type == IQEHistoryItemTypeBarCode)
    {
        return ([historyItem.codeData isEqualToString:codeData]
            &&  [historyItem.codeType isEqualToString:codeType]);
    }
    
    return NO;
}
- (NSString*) title
{
    NSString* titleString = nil;
    
    if (type == IQEHistoryItemTypeRemoteObject
    ||  type == IQEHistoryItemTypeUnknown)
    {
        if (state == IQEHistoryItemStateUnknown)        return @"";
        if (state == IQEHistoryItemStateUploading)      return NSLocalizedStringFromTable(@"Uploading...",       BUNDLE_TABLE, @"");
        if (state == IQEHistoryItemStateSearching)      return NSLocalizedStringFromTable(@"Searching...",       BUNDLE_TABLE, @"");
        if (state == IQEHistoryItemStateNotReady)       return NSLocalizedStringFromTable(@"Not Ready",          BUNDLE_TABLE, @"");
        if (state == IQEHistoryItemStateNetworkProblem) return NSLocalizedStringFromTable(@"On Hold",            BUNDLE_TABLE, @"");
        if (state == IQEHistoryItemStateTimeoutProblem) return NSLocalizedStringFromTable(@"Connection Problem", BUNDLE_TABLE, @"");
        if (state == IQEHistoryItemStateFound)
        {
            titleString = [qidData objectForKey:IQEKeyLabels];        
        }
    }
    else
    if (type == IQEHistoryItemTypeLocalObject)
    {
        if (state == IQEHistoryItemStateFound)
            titleString = objName;
    }
    else
    if (type == IQEHistoryItemTypeBarCode)
    {
        if (state == IQEHistoryItemStateFound)
        {
            if (codeDesc && [codeDesc isEqualToString:@""] == NO)
                titleString = codeDesc;
            else
                titleString = codeData;
        }
    }
    
    if (state == IQEHistoryItemStateNotFound)
        titleString = NSLocalizedStringFromTable(@"No Match", BUNDLE_TABLE, @"");            

    return [[titleString retain] autorelease];
}

- (void) setTitle:(NSString*)title
{
    NSString* previous = nil;
    
    if (type == IQEHistoryItemTypeRemoteObject)
    {
        previous = [[qidData objectForKey:IQEKeyLabels] copy];

        NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionaryWithDictionary:qidData];
        
        if (title == nil)
            [dataDictionary removeObjectForKey:IQEKeyLabels];
        else
            [dataDictionary setObject:title forKey:IQEKeyLabels];
        
        self.qidData = dataDictionary;
    }
    else
    if (type == IQEHistoryItemTypeLocalObject)
    {
        previous = [objName copy];

        self.objName = title;
    }
    else
    if (type == IQEHistoryItemTypeBarCode)
    {
        if (codeDesc && [codeDesc isEqualToString:@""] == NO)
        {
            previous = [codeDesc copy];

            self.codeDesc = title;
        }
        else
        {
            previous = [codeData copy];

            self.codeData = title;
        }
    }
    
    if (previous != title && [previous isEqualToString:title] == NO)
        [[NSNotificationCenter defaultCenter] postNotificationName:IQEHistoryItemTitleChangeNotification object:self];
    
    [previous release];
}

- (void) setState:(IQEHistoryItemState)newState
{
    if (state == newState)
        return;
    
    state = newState;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IQEHistoryItemStateChangeNotification object:self];
}

- (void) setState:(IQEHistoryItemState)aState forType:(IQEHistoryItemType)aType
{
    [mStates setObject:[self stringFromState:aState] forKey:[self stringFromType:aType]];
}

- (BOOL) complete
{
    if (mStates == nil || mStates.count == 0)
        return state == IQEHistoryItemStateFound;
    
    NSInteger count = 0;
    
    for (NSString* theType in [mStates allKeys])
    {
        NSString* theState = [mStates objectForKey:theType];
        
        if ([theState isEqualToString:HISTORYITEM_STATE_FOUND]
        ||  [theState isEqualToString:HISTORYITEM_STATE_NOTFOUND])
            count++;
    }
    
    if (count == mStates.count)
        return YES;
    
    return NO;
}

- (BOOL) found
{
    if (mStates == nil || mStates.count == 0)
        return state == IQEHistoryItemStateFound;
    
    for (NSString* theType in [mStates allKeys])
    {
        NSString* theState = [mStates objectForKey:theType];
        
        if ([theState isEqualToString:HISTORYITEM_STATE_FOUND])
            return YES;
    }
    
    return NO;
}

- (NSString*) description
{
    NSMutableDictionary* dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self encodeWithDictionary:dictionary];
    
    return [dictionary description];
}

- (NSString*) stringFromState:(IQEHistoryItemState)aState
{
    if (aState == IQEHistoryItemStateUnknown)        return HISTORYITEM_STATE_UNKNOWN;         else
    if (aState == IQEHistoryItemStateUploading)      return HISTORYITEM_STATE_UPLOADING;       else
    if (aState == IQEHistoryItemStateSearching)      return HISTORYITEM_STATE_SEARCHING;       else
    if (aState == IQEHistoryItemStateFound)          return HISTORYITEM_STATE_FOUND;           else
    if (aState == IQEHistoryItemStateNotFound)       return HISTORYITEM_STATE_NOTFOUND;        else
    if (aState == IQEHistoryItemStateNotReady)       return HISTORYITEM_STATE_NOTREADY;        else
    if (aState == IQEHistoryItemStateNetworkProblem) return HISTORYITEM_STATE_NETWORK_PROBLEM; else
    if (aState == IQEHistoryItemStateTimeoutProblem) return HISTORYITEM_STATE_TIMEOUT_PROBLEM;
    
    NSAssert(NO, @"Unknown IQEHistoryItemState");
    return @"";
}

- (NSString*) stringFromType:(IQEHistoryItemType)aType
{
    if (aType == IQEHistoryItemTypeUnknown)      return HISTORYITEM_TYPE_UNKNOWN; else
    if (aType == IQEHistoryItemTypeRemoteObject) return HISTORYITEM_TYPE_REMOTE;  else
    if (aType == IQEHistoryItemTypeLocalObject)  return HISTORYITEM_TYPE_LOCAL;   else
    if (aType == IQEHistoryItemTypeBarCode)      return HISTORYITEM_TYPE_BARCODE;

    NSAssert(NO, @"Unknown IQEHistoryItemType");
    return @"";
}

- (IQEHistoryItemState) stateFromString:(NSString*)aString
{
    if ([aString isEqualToString:HISTORYITEM_STATE_UNKNOWN])         return IQEHistoryItemStateUnknown;        else
    if ([aString isEqualToString:HISTORYITEM_STATE_UPLOADING])       return IQEHistoryItemStateUploading;      else
    if ([aString isEqualToString:HISTORYITEM_STATE_SEARCHING])       return IQEHistoryItemStateSearching;      else
    if ([aString isEqualToString:HISTORYITEM_STATE_FOUND])           return IQEHistoryItemStateFound;          else
    if ([aString isEqualToString:HISTORYITEM_STATE_NOTFOUND])        return IQEHistoryItemStateNotFound;       else
    if ([aString isEqualToString:HISTORYITEM_STATE_NOTREADY])        return IQEHistoryItemStateNotReady;       else
    if ([aString isEqualToString:HISTORYITEM_STATE_NETWORK_PROBLEM]) return IQEHistoryItemStateNetworkProblem; else
    if ([aString isEqualToString:HISTORYITEM_STATE_TIMEOUT_PROBLEM]) return IQEHistoryItemStateTimeoutProblem;
    
    NSAssert(NO, @"Unknown state");
    return IQEHistoryItemStateUnknown;
}

- (IQEHistoryItemType) typeFromString:(NSString*)aString
{
    if ([aString isEqualToString:HISTORYITEM_TYPE_UNKNOWN]) return IQEHistoryItemTypeUnknown;      else
    if ([aString isEqualToString:HISTORYITEM_TYPE_REMOTE])  return IQEHistoryItemTypeRemoteObject; else
    if ([aString isEqualToString:HISTORYITEM_TYPE_LOCAL])   return IQEHistoryItemTypeLocalObject;  else
    if ([aString isEqualToString:HISTORYITEM_TYPE_BARCODE]) return IQEHistoryItemTypeBarCode;
    
    NSAssert(NO, @"Unknown type");
    return IQEHistoryItemTypeUnknown;
}

@end

/* -------------------------------------------------------------------------------- */
#pragma mark -
#pragma mark NSMutableArray (HistoryItem)
/* -------------------------------------------------------------------------------- */

@implementation NSMutableArray (HistoryItem)

- (id) initWithNSArray:(NSArray*)array
{
    self = [self initWithCapacity:array.count];
    if (self)
    {
        for (NSDictionary* historyDictionary in array)
        {
            IQEHistoryItem* historyItem = [[IQEHistoryItem alloc] initWithDictionary:historyDictionary];
            [self addObject:historyItem];
            [historyItem release];
        }
    }
    return self;
}

- (void) encodeWithNSArray:(NSMutableArray*)array
{
    for (IQEHistoryItem* historyItem in self)
    {
        NSMutableDictionary* historyDictionary = [NSMutableDictionary dictionary];
        [historyItem encodeWithDictionary:historyDictionary];
        
        [array addObject:historyDictionary];
    }
}

- (IQEHistoryItem*) historyItemForQID:(NSString*)qid
{
    for (IQEHistoryItem* historyItem in self)
    {
        if ([historyItem.qid isEqualToString:qid])
            return historyItem;
    }
    
    return nil;
}

- (id) firstObject
{
    id firstItem = nil;
    if (self.count > 0)
        firstItem = [self objectAtIndex:0];
    
    return firstItem;
}

@end
