//
//  TBBonjourWrapper.m
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "TBBonjourWrapper.h"

@implementation TBBonjourWrapper

@synthesize services, serviceType=servicetype;

// Publishing instance
- (id)initWithPort:(int)servicePort
{
  self = [super init];
  mode = MODE_UNDEF;
  if (self) {
    port = servicePort;
    NSLog(@"Setting up Bonjour service");
    // find hostname if possible
    NSString *h = [(NSString *)CSCopyMachineName() autorelease];
    service = [[NSNetService alloc] initWithDomain:SERVICE_DOMAIN
                                              type:SERVICE_TYPE
                                              name:h?h:SERVICE_NAME
                                              port:port];
    if(service) {
      mode = MODE_PUBLISH;
      [service setDelegate:self];
      [service publish];
    }
    else {
      NSLog(@"An error occurred initializing the NSNetService object for publishing.");
    }
  }
  return self;
}

// Browsing instance
- (id) initWithType:(NSString *)serviceType
{
  self = [super init];
  mode = MODE_UNDEF;
  if (self) {
    mode = MODE_BROWSE;
    searching = NO;
    
    browser = [[NSNetServiceBrowser alloc] init];
    [self  willChangeValueForKey:@"services"];
    services = [[NSMutableArray alloc] init];
    [self  didChangeValueForKey:@"services"];
    
    if (browser) {
      [browser setDelegate:self];
      [browser searchForServicesOfType:serviceType?serviceType:SERVICE_TYPE 
                              inDomain:SERVICE_DOMAIN];
    }
    self.serviceType = serviceType;
  }
  return self;
}

// Resolving instance
- (id) initWithServer:(NSString *)server andType:(NSString *)serviceType
{
  self = [super init];
  mode = MODE_UNDEF;
  if (self) {
    service = [NSNetService alloc];
    [service initWithDomain:SERVICE_DOMAIN
                       type:serviceType?serviceType:SERVICE_TYPE
                       name:server];
    if (service) {
      mode = MODE_RESOLVE;
      [service setDelegate:self];
      [service resolveWithTimeout:5.0];
    }
    else {
      NSLog(@"An error occurred initializing the NSNetService object for resolution.");
    }
  }
  return self;
}

- (void) dealloc
{
  switch (mode) {
    case MODE_UNDEF:
      NSLog(@"Deallocating TBBonjourWrapper that failed during init.");
      break;
    case MODE_PUBLISH:
      [service stop];
      [service release];
      break;
    case MODE_RESOLVE:
      [service stop];
      [service release];
      [services release];
      break;
    case MODE_BROWSE:
      [browser stop];
      [browser release];
      [services release];
      break;
    default:
      NSLog(@"Deallocating TBBonjourWrapper with invalid mode: %@", mode);
  }
  [super dealloc];
}

- (void)browse
{
  [browser stop];
  for (NSInteger serviceIndex = [self.services count]-1; serviceIndex >= 0; serviceIndex--) {
    NSIndexSet *serviceIndexSet = [NSIndexSet indexSetWithIndex:serviceIndex];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:serviceIndexSet
              forKey:@"services"];
    [services removeObjectAtIndex:serviceIndex];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:serviceIndexSet
             forKey:@"services"];
  }
  
  [browser searchForServicesOfType:self.serviceType
                          inDomain:SERVICE_DOMAIN];
}

// NSNetServiceDelegate

- (void)netServiceWillPublish:(NSNetService *)netService
{
	NSLog(@"netServiceWillPublish");
}

- (void)netService:(NSNetService *)netService
     didNotPublish:(NSDictionary *)errorDict
{
  [self handleServiceError:[errorDict objectForKey:NSNetServicesErrorCode] 
               withService:netService];
}

- (void)netServiceDidStop:(NSNetService *)netService
{
  NSLog(@"netServiceDidStop");
}

- (void)netServiceDidPublish:(NSNetService *)netService
{
	NSLog(@"netServiceDidPublish");
}

- (void)netServiceWillResolve:(NSNetService *)netService
{
	NSLog(@"netServiceWillResolve");
}

- (void)netService:(NSNetService *)netService 
     didNotResolve:(NSDictionary *)errorDict
{
  [self handleServiceError:[errorDict objectForKey:NSNetServicesErrorCode] 
               withService:netService];
  [services removeObject:netService];
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
	NSLog(@"netServiceDidResolveAddress");
  // see if the resolved NSNetService instance is usable
  BOOL complete = NO;
  // TODO determine completeness of records here.
  // TODO find a good way for a user of this class to get to the addresses.
  if (complete) {
    [services addObject:netService];
  }
}

- (void)netService:(NSNetService *)netService didUpdateTXTRecordData:(NSData *)data
{
	NSLog(@"didUpdateTXTRecordData");
}


// NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
  searching = YES;
	NSLog(@"netServiceBrowserWillSearch");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
  searching = NO;
	NSLog(@"netServiceBrowserDidStopSearch");
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
  searching = NO;
	NSLog(@"didNotSearch");
}


// support key-val coding for ui binding
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreComing
{
	NSLog(@"didFindService %@", [netService name]);
  NSIndexSet *insertedIndexes = [NSIndexSet indexSetWithIndex:[services count]];
  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"services"];
  [services addObject:netService];
  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"services"];
}

// support key-val coding for ui binding
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreComing
{
	NSLog(@"didRemoveService");
  NSUInteger serviceIndex = [services indexOfObjectIdenticalTo:netService];
  NSIndexSet *serviceIndexSet = [NSIndexSet indexSetWithIndex:serviceIndex];
  [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:serviceIndexSet
            forKey:@"services"];
  [services removeObject:netService];
  [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:serviceIndexSet
           forKey:@"services"];
}


// utility
- (void)handleServiceError:(NSNumber *)error withService:(NSNetService *)netService
{
  NSLog(@"An error occurred with service %@.%@.%@, error code = %@",
        [netService name], [netService type], [netService domain], error);
  // Handle error here
}

@end
