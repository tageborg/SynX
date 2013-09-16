//
//  TBBonjourWrapper.h
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVICE_DOMAIN @""
#define SERVICE_TYPE @"_synx._tcp"
#define SERVICE_NAME @"SynX Server" // used only if getting the computer name 
                                    // (NOT the hostname) fails
#define SERVICE_PORT 2357

#define MODE_UNDEF 0
#define MODE_PUBLISH 1
#define MODE_BROWSE 2
#define MODE_RESOLVE 3

@interface TBBonjourWrapper : NSObject <NSNetServiceDelegate, 
NSNetServiceBrowserDelegate> {
  int port;
  int mode;
  NSNetService *service;
  NSNetServiceBrowser *browser;
  NSMutableArray *services;
  NSString *servicetype;
  BOOL searching;
}

@property (readwrite, retain)  NSMutableArray *services;
@property (readwrite, copy)  NSString *serviceType;


// Bonjour workings:
// * Bonjour servers publish.
// * Bonjour clients that know what server to use resolve based on previously 
//   saved  info.
// * Bonjour clients that do not know which server to use will first browse, 
//   then resolve one of the servers found by browsing.
//
// This class acts either as a server, a browser or a resolver. One instance
// can handle ONE of these duties, so for a typical client, two instances are 
// required (browse, resolve).

//  All init methods below default to defined variables above, specifically 
//  domain, for which we always default to @"" (local. and Back to my Mac).

// Init a publishing instance
- (id) initWithPort:(int)servicePort; 

// Init a browsing instance
- (id) initWithType:(NSString *)serviceType;

// Init a resolving instance
- (id) initWithServer:(NSString *)server andType:(NSString *)serviceType;

- (void)dealloc;

- (void)browse;

// NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)netService;
- (void)netService:(NSNetService *)netService 
     didNotPublish:(NSDictionary *)errorDict;

- (void)netServiceDidStop:(NSNetService *)netService;

- (void)netServiceDidPublish:(NSNetService *)netService;

- (void)netServiceWillResolve:(NSNetService *)netService;
- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidResolveAddress:(NSNetService *)netService;

- (void)netService:(NSNetService *)netService didUpdateTXTRecordData:(NSData *)data;

// NSNetServiceBrowserDelegate methods for service browsing
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing;

// Utility methods
- (void)handleServiceError:(NSNumber *)error 
               withService:(NSNetService *)service;

@end
