//
//  SynXAgent.m
//  SynX
//
//  Created by Tage Borg on 20110502.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "SynXAgent.h"


@implementation SynXAgent

@synthesize isServer;

- (id)initServer
{
  self = [super init];
  if (self) {
    events = [SCEvents sharedPathWatcher];
    cache = [[FileSystemCache alloc] init];
    [events setDelegate:self];
    bonjour = [[TBBonjourWrapper alloc] initWithPort:SERVICE_PORT];
  }
  return self;
}

- (id)initClient
{
  self = [super init];
  if (self) {
    events = [SCEvents sharedPathWatcher];
    cache = [[FileSystemCache alloc] init];
    [events setDelegate:self];
    bonjour = [[TBBonjourWrapper alloc] initWithType:nil];
  }
  return self;
}

- (void)dealloc
{
  [events stopWatchingPaths];
  [cache stop];
  [cache release];
  [bonjour release];
  [events release];
  [super dealloc];
}

- (void)setupEventListener
{
  
  NSMutableArray *paths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Sites"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Public"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Movies"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Music"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Dropbox"]];
  
	[events startWatchingPaths:paths];
  
}

// SCEventListenerProtocol implementation
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
  NSLog(@"   ");
  NSLog(@"   ");
  NSLog(@"Got event for %@/", event.eventPath);
  NSArray *changed = [[cache filesChangedIn:event.eventPath] retain];
  NSLog(@"file(s) changed: %lu", [changed count]);
  for (NSString *f in changed) {
    //NSLog(@"   %@", f);
  }
  NSLog(@"   ");
  NSLog(@"   ");
  [changed release];
  changed = nil;
}

@end
