//
//  TBServer.m
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "TBServer.h"
#import "TBConnection.h"

@implementation TBServer

- (id) initWithPort:(int)listenPort
{
  self = [super init];
  if (self) {
    port = listenPort;
  }
  return self;
}

- (void)dealloc
{
  [socket release];
  [handle release];
  [super dealloc];
}

- (void)listen
{
	if(!socket)
	{
		NSLog(@"setting up socket");
		socket = [[NSSocketPort alloc] initWithTCPPort:SERVICE_PORT];
		
		struct sockaddr *addr = (struct sockaddr *)[[socket address] bytes];
		if(addr->sa_family == AF_INET)
		{
			port = ntohs(((struct sockaddr_in *)addr)->sin_port);
		}
		else if(addr->sa_family == AF_INET6)
		{
			port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
		}
		else
		{
			[socket release];
			socket = nil;
			NSLog(@"Unknown address family - neither IPV4 or IPV6.");
		}
	}
	else
	{
		NSLog(@"Error: strangely, there was already a socket.");
	}
	
	if(socket)
	{
    NSLog(@"Setting up Bonjour service");
    bonjour = [[TBBonjourWrapper alloc] initWithPort:SERVICE_PORT];
    if (bonjour) {
      int fd = [socket socket];
      handle = [[NSFileHandle alloc] initWithFileDescriptor:fd
                                             closeOnDealloc:YES];
      
      // register for notifications of accepted connections
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      [nc addObserver:self 
             selector:@selector(newConnection:)
                 name:NSFileHandleConnectionAcceptedNotification
               object:nil];
      
      // start accepting connections
      [handle acceptConnectionInBackgroundAndNotify];
		}
		else
		{
			NSLog(@"Error publishing service over Bonjour.");
		}
	}
	else
	{
		NSLog(@"Error initializing socket.");
	}	  
}

- (void) connectionReceivedNotification:(NSNotification *)notification
{
  
}

- (void) closeConnection:(TBConnection *)closableConnection
{
  
}

@end
