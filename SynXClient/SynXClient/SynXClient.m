//
//  SynXClient.m
//  SynXClient
//
//  Created by Tage Borg on 2011-05-02.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "SynXClient.h"


@implementation SynXClient

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setupEventListener
{
  SCEvents *events = [SCEvents sharedPathWatcher];
  // init with empty cache -- a chanegd files will be seen as new at first change
  cache = [[FileSystemCache alloc] initWithFiles:[[[NSArray alloc] init] autorelease]];
  
  [events setDelegate:self];
  
  NSMutableArray *paths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Sites"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Public"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Movies"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Music"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]];
  [paths addObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]];
  
	[events startWatchingPaths:paths];
  
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 */
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
  NSLog(@"   ");
  NSLog(@"   ");
  NSLog(@"Got event for %@/", event.eventPath);
  NSArray *changed = [[cache filesChangedIn:event.eventPath] retain];
  NSLog(@"%lu file(s) changed: ", [changed count]);
  for (NSString *f in changed) {
    //NSLog(@"   %@", f);
  }
  NSLog(@"   ");
  NSLog(@"   ");
  [changed release];
  changed = nil;
}

@end
