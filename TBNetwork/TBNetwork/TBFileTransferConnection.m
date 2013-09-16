//
//  TBFileTransferConnection.m
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "TBFileTransferConnection.h"
#import "TBServer.h"

@implementation TBFileTransferConnection

- (id)initWithFileHandle:(NSFileHandle *)fileHandle 
               andServer:(TBServer *)owningServer
{
  return [super initWithFileHandle:fileHandle andServer:owningServer];
}


- (void)dealloc
{
  [super dealloc];
}


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
    NSLog(@"TBFileTransferConnection: %@",s);
    [s autorelease];
  }  
}
@end
