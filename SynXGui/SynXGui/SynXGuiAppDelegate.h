//
//  SynXGuiAppDelegate.h
//  SynXGui
//
//  Created by Tage Borg on 2011-05-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SynXDOControl.h"

@interface SynXGuiAppDelegate : NSObject <NSApplicationDelegate> {
@private
  SynXDOControl *agentController;
  NSWindow *window;
  NSTextField *agentstatus;
  NSTextField *controlstatus;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *agentstatus;
@property (assign) IBOutlet NSTextField *controlstatus;

- (IBAction)stop:(id)sender;
- (IBAction)start:(id)sender;


- (void)agentDidStartNotification:(NSNotification *)notification;
- (void)agentDidStopNotification:(NSNotification *)notification;

@end
