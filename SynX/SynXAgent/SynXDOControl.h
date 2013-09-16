//
//  SynXDOControl.h
//  SynX
//
//  Created by Tage Borg on 20110502.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NAME @"SynXDOControl"

@protocol SynXControlProtocol
- (bycopy BOOL)makeServer;
- (bycopy BOOL)makeClient;
- (void)stopAgent;
- (bycopy BOOL)agentStarted;
- (bycopy BOOL)isServer;
@end


@protocol SynXDOControlDelegate
- (BOOL)makeServerImpl;
- (BOOL)makeClientImpl;
- (void)stopAgentImpl;
- (BOOL)agentStartedImpl;
- (BOOL)isServerImpl;
@end

@interface SynXDOControl : NSObject <SynXControlProtocol> {
@private
  NSConnection *_connection;
  id _remote;
	id _delegate;
}


// init server
- (SynXDOControl *)initVendorWithDelegate:(id)delegate;

// init client
- (SynXDOControl *)initBuyer;

// validity of connection
- (BOOL)connected;

// shut down
- (void)close;

@end
