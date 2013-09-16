//
//  SynXDOControl.m
//  SynX
//
//  Created by Tage Borg on 20110502.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "SynXDOControl.h"


@implementation SynXDOControl

- (void)dealloc
{
	if (_remote != nil) {
		[_remote release];
	}
	if (_delegate != nil) {
		[_delegate release];
	}
	if (_connection != nil) {
    [_connection registerName:nil];
		[_connection release];
	}
	[super dealloc];
}


- (SynXDOControl *)initVendorWithDelegate:(id)delegate
{
	self = [super init];
	if (self) {
		_remote = nil;
		_delegate = [delegate retain];
		NSPort	*receivePort = nil;
		
		receivePort	=	[[NSMachPort alloc] init];
		_connection = [[NSConnection alloc] initWithReceivePort:receivePort 
																									 sendPort:nil];
		[_connection setRootObject:self];
		
		if (![_connection registerName:NAME]) {
			printf("[SynXDOControl initWithDelegate:]: registerName: failed\n");
		}
		NSLog(@"SynXDOControl server initialized.");
	}
	return self;
	
}

- (SynXDOControl *)initBuyer;
{
	self = [super init];
	if (self) {
    _remote = nil;
		_delegate = nil;
		NSPort	*sendPort = nil;
		
		sendPort = [[NSMachBootstrapServer sharedInstance] portForName:NAME host:nil];
		
		NS_DURING
		_connection = [[NSConnection alloc] initWithReceivePort:(NSPort*)[[sendPort class] port] 
																									 sendPort:sendPort];
		_remote = [_connection rootProxy];
		NS_HANDLER
		_remote = nil;
		_connection = nil;
		NSLog(@"[SynXDOControl getController] Failed to connect to vendor");
		NS_ENDHANDLER
		
		if (_remote == nil) {
			NSLog(@"[SynXDOControl getController] failed to get remote object.");
		}
		[_remote setProtocolForProxy:@protocol(SynXControlProtocol)];
		
		NSLog(@"SynXDOControl client initialized.");
	}
	return self;
}

- (BOOL)connected
{
  BOOL returnval = NO;
  if (_delegate) {
    returnval = [[_connection receivePort] isValid];
  }
  else if (_remote) {
    returnval = [[_connection sendPort] isValid];
  }
  else {
    NSLog(@"SynxDOControl is in a bad state in connected -- no delegate, no remote.");
  }
  return returnval;
}


- (void)close
{
  [_connection registerName:nil];
  if (_delegate) {
    [[_connection receivePort] invalidate];
  }
  else if (_remote) {
    [[_connection sendPort] invalidate];
  }
  else {
    NSLog(@"SynxDOControl is in a bad state when closing -- no delegate, no remote.");
  }
}

// SynXControlProtocol implementation


- (bycopy BOOL)makeServer
{
	if(_delegate) {
		NSLog(@"calling [_delegate makeServerImpl]");
		return [_delegate makeServerImpl];
	}
	else if (_remote) {
		NSLog(@"calling [_remote makeServer]");
		return [_remote makeServer];
	}
	else {
		NSLog(@"Cannot determine if I am remote or local!");
		return NO;
	}
}

- (bycopy BOOL)makeClient
{
	if(_delegate) {
		NSLog(@"calling [_delegate makeClientImpl]");
		return [_delegate makeClientImpl];
	}
	else if (_remote)  {
		NSLog(@"calling [_remote makeClient]");
		return [_remote makeClient];
	}
	else {
		NSLog(@"Cannot determine if I am remote or local!");
		return NO;
	}
}

- (void)stopAgent
{
	if(_delegate) {
		NSLog(@"calling [_delegate stopAgentImpl]");
		[_delegate stopAgentImpl];
	}
	else if (_remote)  {
		NSLog(@"calling [_remote stopAgent]");
		[_remote stopAgent];
	}
	else {
		NSLog(@"Cannot determine if I am remote or local!");
	}
}

- (BOOL)agentStarted
{
	if(_delegate) {
		NSLog(@"calling [_delegate agentStartedImpl]");
		return [_delegate agentStartedImpl];
	}
	else if (_remote)  {
		NSLog(@"calling [_remote agentStarted]");
		return [_remote agentStarted];
	}
	else {
		NSLog(@"agentStarted: Agent down or no connection to agent.");
		return NO;
	}
}

- (BOOL)isServer
{
	if(_delegate) {
		NSLog(@"calling [_delegate isServerImpl]");
		return [_delegate isServerImpl];
	}
	else if (_remote)  {
		NSLog(@"calling [_remote isServer]");
		return [_remote isServer];
	}
	else {
		NSLog(@"isServer: Agent down or no connection to agent.");
		return NO;
	}  
}

@end
