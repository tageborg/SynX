//
//  TBFileTransfer.m
//  dobjectserver
//
//  Created by Tage Borg on 2011-04-29.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "TBFileTransfer.h"

@implementation TBFileTransfer

- (void)dealloc
{  
  [connection release];
  [fileList release];
  [super dealloc];
}


- (TBFileTransfer *)initWithPort:(int)port andHost:(NSString *)host
{
  self = [super init];
  if (self) {
    NSSocketPort	*sendPort;
    NS_DURING
    sendPort	=	[[NSSocketPort alloc] initRemoteWithTCPPort:port host:host];
    NS_HANDLER
    NSLog(@"[TBFileFransfer initWithPort:] Failed to connect to %@:%d", host, port);
    NS_ENDHANDLER
    connection = [[NSConnection alloc] initWithReceivePort:nil 
                                                  sendPort:sendPort]; 
    [sendPort release];
    fileList = nil;
    remote = nil;
    fileCount = 0;
    currentFile = 0;
    atStartOfList = YES;
  }
  return self;
}

- (TBFileTransfer *)initWithPort:(int)port
{
  self = [super init];
  if (self) {
    NSSocketPort	*receivePort;
    NS_DURING
    receivePort	=	[[NSSocketPort alloc] initWithTCPPort : port];
    NS_HANDLER
    NSLog(@"[TBFileFransfer initWithPort:] Failed to bind port %d", port);
    NS_ENDHANDLER
    connection = [[NSConnection alloc] initWithReceivePort:receivePort 
                                                  sendPort:nil];
    [receivePort release];
    fileList = nil;
    remote = nil;
    fileCount = 0;
    currentFile = 0;
    atStartOfList = YES;
  }
  return self;
}


- (BOOL)send:(NSArray *)files
{
  BOOL success = NO;
  
  if (fileList != nil) {
    [fileList release];
    fileList = nil;
  }
  fileList = [files retain];
  fileCount = [files count];
  currentFile = 0;
  atStartOfList = YES;
  
  NS_DURING
  [connection setRootObject:self];
  success = YES;
  NS_HANDLER
  NSLog(@"[TBFileTransfer send:files] Connection broken.");
  NS_ENDHANDLER
  
  return success;
}


- (BOOL)receive
{
  BOOL success = NO;
  NS_DURING
  remote = [connection rootProxy];
  [remote setProtocolForProxy:@protocol(TBTransferableFileList)];
  if (remote) {
    success = YES;
  }
  NS_HANDLER
  NSLog(@"[TBFileTransfer receive] Server is most likely not up, or not ready to send.");
  NS_ENDHANDLER
  return success;
}


/*
 TBTransferableFileList Protocol Compliance
 */

- (bycopy NSDictionary *)attributes
{
  if (atStartOfList) {
    return nil;
  }

  // TODO: error handling
  return [[NSFileManager defaultManager] attributesOfItemAtPath:[fileList objectAtIndex:currentFile] error:nil];
}

- (bycopy NSData *)contents
{
  if (atStartOfList) {
    return nil;
  }
  
	return [[NSFileManager defaultManager] contentsAtPath:[fileList objectAtIndex:currentFile]];
}

- (bycopy NSString *)name
{
  if (atStartOfList) {
    return nil;
  }
  
  return [fileList objectAtIndex:currentFile];
}


- (BOOL)next
{
  BOOL hasNext = NO;
  if (currentFile < fileCount) {
    if (atStartOfList) {
      atStartOfList = NO;
    }
    else {
      currentFile++;
    }
    hasNext = YES;
  }
  return hasNext;
}

@end
