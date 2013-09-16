//
//SynX.m
//SynX
//
//Created by Tage Borg on 20110410.
//Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynX.h"

@implementation SynX
@synthesize runStatusIndicator;

@synthesize bonjour, isRunning, isServer, typeRadioMatrix;

- (void)updateRunStatus
{
	NSBundle *SynXBundle = [NSBundle bundleForClass:[SynX class]];
	NSString *name = isRunning?@"started.tiff":@"stopped.tiff";
	NSImage *image = [[[NSImage alloc] initByReferencingFile:[SynXBundle pathForImageResource:name]] autorelease];
	NSLog(@"image named %@: %@", name, image);
	[runStatusIndicator setImage:image];
}

- (void)mainViewDidLoad
{
  [startSpinner startAnimation:self];
  [stopSpinner startAnimation:self];
  [stopButton setEnabled:NO];
  [startButton setEnabled:NO];
  
  NSLog(@"Querying SynXAgent status");
  NSString *path = [[[NSBundle bundleForClass:[SynX class]] bundlePath] stringByAppendingString:@"/Contents/MacOS/SynXControl.sh"];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(agentStatusNotification:)
                                               name:NSTaskDidTerminateNotification
                                             object:nil];
  [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"status", nil]];
  self.bonjour = [[TBBonjourWrapper alloc] initWithType:SERVICE_TYPE];
}

- (void)dealloc
{
	NSLog(@"killing SynX prefpane");
	[bonjour release];
	[super dealloc];
}

- (IBAction)doRefresh:(id)sender {
  [bonjour browse];
}

- (IBAction)setAsServer:(id)sender
{
  isServer = YES;
  [tabView selectFirstTabViewItem:sender];
}

- (IBAction)setAsClient:(id)sender
{
  isServer = NO;
  [tabView selectLastTabViewItem:sender];
}

- (IBAction)start:(id)sender
{
  [startSpinner startAnimation:self];
  NSString *path = [[[NSBundle bundleForClass:[SynX class]] bundlePath] stringByAppendingString:@"/Contents/MacOS/SynXControl.sh"];
  NSLog(@"Executable path: %@", path);
  if (isServer) {
    NSLog(@"Starting SynXAgent in server mode");
    // start the agent with a shell script
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverDidStartNotification:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"start", @"server", nil]];
  }
  else {
    NSLog(@"Starting SynXAgent in client mode");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidStartNotification:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"start", @"client", nil]];
  }
}

- (IBAction)stop:(id)sender
{
  NSLog(@"Stopping SynXAgent in %@ mode.", isServer?@"server":@"client");
  [stopSpinner startAnimation:self];
  NSString *path = [[[NSBundle bundleForClass:[SynX class]] bundlePath] stringByAppendingString:@"/Contents/MacOS/SynXControl.sh"];
  NSLog(@"Executable path: %@", path);
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(agentDidStopNotification:)
                                               name:NSTaskDidTerminateNotification
                                             object:nil];
  [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects:path, @"stop", nil]];
}

- (IBAction)setStartSystem:(id)sender
{
  // get rights to write to Library/LaunchAgents and write the following plist there:
  /*
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
   <key>Disabled</key>
   <false/>
   <key>KeepAlive</key>
   <false/>
   <key>Label</key>
   <string>se.tbef.SynXServer</string>
   <key>ProgramArguments</key>
   <array>
   <string>PATH/TO/SERVER/EXECUTABLE</string>
   </array>
   <key>QueueDirectories</key>
   <array/>
   <key>RunAtLoad</key>
   <true/>
   <key>WatchPaths</key>
   <array/>
   </dict>
   </plist>	 
   */
  NSLog(@"setStartSystem");
  // https://github.com/notbrien/OSXSlightlyBetterAuth/blob/master/OSXSlightlyBetterAuth.m
  // http://developer.apple.com/documentation/Security/Reference/authorization_ref/Reference/reference.html#//apple_ref/doc/uid/TP30000826-CH4g-CJBEABHG
  OSStatus status;
  AuthorizationRef authRef;
  
  status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
  if (status != errAuthorizationSuccess) {
    NSLog(@"Error Creating Initial Authorization: %d", status);
    status = AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
    return;
  }
  
  AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
  AuthorizationRights rights = {1, &right};
  AuthorizationFlags flags = kAuthorizationFlagDefaults |
  kAuthorizationFlagInteractionAllowed |
  kAuthorizationFlagPreAuthorize |
  kAuthorizationFlagExtendRights;
  
  status = AuthorizationCopyRights(authRef, &rights, NULL, flags, NULL);
  if (status != errAuthorizationSuccess) {
    NSLog(@"Copy Rights Unsuccessful: %d", status);
    status = AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
    return;
  }
  
  char *tool = "/sbin/dmesg";
  char *args[] = {NULL};
  FILE *pipe = NULL;
  
  status = AuthorizationExecuteWithPrivileges(authRef, tool, kAuthorizationFlagDefaults, args, &pipe);
  if (status != errAuthorizationSuccess) {
    NSLog(@"Error: %d", status);
    status = AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);
    return;
  }
  
  char readBuffer[128];
  if (status == errAuthorizationSuccess) {
    for (;;) {
      ssize_t bytesRead = read(fileno(pipe), readBuffer, sizeof(readBuffer));
      if (bytesRead < 1) break;
      write(fileno(stderr), readBuffer, bytesRead);
    }
  }
  status = AuthorizationFree(authRef, kAuthorizationFlagDestroyRights);	
}

- (IBAction)setStartLogin:(id)sender
{
  // write the above plist to ~Library/LaunchAgents
  NSLog(@"setStartLogin");
}


- (BOOL)isServerRunning
{
  return (isServer && isRunning);
}

- (BOOL)isClientRunning
{
  return (!isServer && isRunning);
}

- (void)serverDidStartNotification:(NSNotification *)notification
{
  NSLog(@"Server started");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [startSpinner stopAnimation:self];
  [stopButton setEnabled:YES];
  [startButton setEnabled:NO];
	isRunning = YES;
	[self updateRunStatus];
}

- (void)clientDidStartNotification:(NSNotification *)notification
{
  NSLog(@"Client started");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [startSpinner stopAnimation:self];
  [stopButton setEnabled:YES];
  [startButton setEnabled:NO];
	isRunning = YES;
	[self updateRunStatus];
}

- (void)agentDidStopNotification:(NSNotification *)notification
{
  NSLog(@"Agent stopped");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [stopSpinner stopAnimation:self];
  [stopButton setEnabled:NO];
  [startButton setEnabled:YES];
	isRunning = NO;
	[self updateRunStatus];
}

- (void)agentStatusNotification:(NSNotification *)notification
{
  int status = [[notification object] terminationStatus];
  NSLog(@"Agent status: %d", status);
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
  [startSpinner stopAnimation:self];
  [stopSpinner stopAnimation:self];
  switch (status) {
    case 0:
      isRunning = NO;
      isServer = NO;
      [tabView selectLastTabViewItem:self];
			[typeRadioMatrix setState:1 atRow:1 column:0];
			NSLog(@"[typeRadioMatrix setState:1 atRow:1 column:0];");
      [stopButton setEnabled:NO];
      [startButton setEnabled:YES];
      break;
    case 1:
      isRunning = YES;
      isServer = NO;
      [tabView selectLastTabViewItem:self];
			[typeRadioMatrix setState:1 atRow:1 column:0];
			NSLog(@"[typeRadioMatrix setState:1 atRow:1 column:0];");
      [stopButton setEnabled:YES];
      [startButton setEnabled:NO];
      break;
    case 2:
      isRunning = YES;
      isServer = YES;
      [tabView selectFirstTabViewItem:self];
			[typeRadioMatrix setState:1 atRow:0 column:0];
			NSLog(@"[typeRadioMatrix setState:1 atRow:0 column:0];");
      [stopButton setEnabled:YES];
      [startButton setEnabled:NO];
      break;
    default:
      NSLog(@"Unknown exit code for status check: %d", status);
      break;
  }
	[self updateRunStatus];
}


@end
