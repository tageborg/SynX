//
//  main.m
//  SynXAgent
//
//  Created by Tage Borg on 20110502.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynXAgent.h"

int main (int argc, const char * argv[])
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
  NSLog(@"SynXAgent starting");
	
  SynXAgent *agent;
  
  if (argc > 1) {
    if (argv[1][0] == 's') {
      agent = [[SynXAgent alloc] initServer];
    }
    else {
      agent = [[SynXAgent alloc] initClient];
    }
  }
  else {
    agent = [[SynXAgent alloc] initClient];
  }
  
  [agent setupEventListener];
  
  [[NSRunLoop currentRunLoop] run];
  
  [agent release];
	
	[pool drain];
  NSLog(@"Returning 0");
	return 0;
}

