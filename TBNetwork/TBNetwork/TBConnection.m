//
//  TBConnection.m
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "TBConnection.h"
#import "TBServer.h"

@implementation TBConnection

- (id)initWithFileHandle:(NSFileHandle *)fileHandle 
               andServer:(TBServer *)owningServer
{
  self = [super init];
  if (self) {
    server = [owningServer retain];
    handle = [fileHandle retain];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(dataReceivedNotification:)
               name:NSFileHandleReadCompletionNotification
             object:handle];
    [handle readInBackgroundAndNotify];
  }
  return self;
}

- (void)dealloc
{
  [handle release];
  [server release];
  [super dealloc];
}

// This basic logging implementation should be overridden by subclasses. 
- (void) dataReceivedNotification:(NSNotification *)notification
{
  NSData *data = [[notification userInfo] objectForKey:
                  NSFileHandleNotificationDataItem];
  
  if ([data length] == 0) {
    [server closeConnection:self];
  }
  else {
    [handle readInBackgroundAndNotify];
    NSString *s = [[NSString alloc] initWithData:data 
                                        encoding:NSASCIIStringEncoding];
    NSLog(@"TBConnection: %@",s);
    [s autorelease];
  }  
}

@end
