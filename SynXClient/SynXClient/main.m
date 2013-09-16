//
//  main.m
//  SynXClient
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <TBNetwork/TBBonjourWrapper.h>
#import "SCEvents.h"
#import "SynXClient.h"

int main (int argc, const char * argv[])
{

  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  NSLog(@"SynX client starting");

  TBBonjourWrapper *b = [[TBBonjourWrapper alloc] initWithType:nil];
  #pragma unused(b)
  
  SynXClient *client = [[SynXClient alloc] init];
  
  [client setupEventListener];
  
  [[NSRunLoop currentRunLoop] run];
  
  [client release];
  [pool release];
  
  return 0;
}

