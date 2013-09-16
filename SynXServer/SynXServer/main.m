//
//  main.m
//  SynXServer
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <TBNetwork/TBBonjourWrapper.h>

int main (int argc, const char * argv[])
{
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // insert code here...
  NSLog(@"SynX server starting");
  
  TBBonjourWrapper *b = [[TBBonjourWrapper alloc] initWithPort:SERVICE_PORT];
  #pragma unused(b)
  
  [[NSApplication sharedApplication] run];
  
  
  [pool drain];
  return 0;
}
