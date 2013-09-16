//
//  TBServer.h
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "TBBonjourWrapper.h"

#define SERVICE_PORT 2357

@class TBConnection;

@interface TBServer : NSObject {
	int port;
  NSSocketPort *socket;
  NSFileHandle *handle;
  TBBonjourWrapper *bonjour;
}

- (id) initWithPort:(int)listenPort;
- (void)dealloc;

- (void) listen;
- (void) connectionReceivedNotification:(NSNotification *)notification;
- (void) closeConnection:(TBConnection *)closableConnection;

@end
