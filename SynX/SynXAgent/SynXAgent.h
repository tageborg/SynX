//
//  SynXAgent.h
//  SynX
//
//  Created by Tage Borg on 20110502.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileSystemCache.h"
#import "SCEventListenerProtocol.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "TBBonjourWrapper.h"
#import "GCDAsyncSocket.h"

@interface SynXAgent : NSObject <SCEventListenerProtocol> {
@private
  TBBonjourWrapper *bonjour;
  SCEvents *events;
  FileSystemCache *cache;
  GCDAsyncSocket *socket;
}

- (id)initServer;
- (id)initClient;

@property (assign, readwrite) BOOL isServer; // NO -> client YES -> server

- (void)setupEventListener;
@end
