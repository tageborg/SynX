//
//  SynXGuiAppDelegate.m
//  SynXGui
//
//  Created by Tage Borg on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynXGuiAppDelegate.h"

@implementation SynXGuiAppDelegate

@synthesize agentstatus;
@synthesize controlstatus;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	agentController = [[SynXDOControl alloc] initBuyer];
}

- (IBAction)start:(id)sender
{
  NSString *path = [[[NSBundle bundleForClass:[SynXGuiAppDelegate class]] bundlePath] stringByAppendingString:@"/Contents/MacOS/SynXAgent.sh"];
  NSLog(@"Executable path: %@", path);
  NSLog(@"Starting SynXAgent");
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(agentDidStartNotification:)
                                               name:NSTaskDidTerminateNotification
                                             object:nil];
  [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"start", @"client", nil]];
}

- (IBAction)stop:(id)sender
{
	NSLog(@"Stopping SynXAgent");
	[agentController stopAgent];
  NSString *path = [[[NSBundle bundleForClass:[SynXGuiAppDelegate class]] bundlePath] stringByAppendingString:@"/Contents/MacOS/SynXAgent.sh"];
  NSLog(@"Executable path: %@", path);
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(agentDidStopNotification:)
                                               name:NSTaskDidTerminateNotification
                                             object:nil];
  [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"stop", nil]];
}

- (void)agentDidStartNotification:(NSNotification *)notification
{
	NSLog(@"Agent started");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  agentController = [[SynXDOControl alloc] initBuyer];
  if ([agentController agentStarted]) {
    [agentstatus setStringValue:@"Started"];
  }
  else {
    [agentstatus setStringValue:@"Stopped (but agentDidStartNotification?)"];
  }
}

- (void)agentDidStopNotification:(NSNotification *)notification
{
	NSLog(@"Agent stopped");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [agentstatus setStringValue:@"Stopped"];
}

@end
