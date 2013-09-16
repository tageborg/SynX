//
//  SynX.h
//  SynX
//
//  Created by Tage Borg on 20110410.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "TBBonjourWrapper.h"

@interface SynX : NSPreferencePane <NSApplicationDelegate>
{
  @public
  TBBonjourWrapper *bonjour;
  BOOL isRunning;
  BOOL isServer;
  
  @private
  IBOutlet NSMatrix *typeRadioMatrix;
	IBOutlet NSImageView *runStatusIndicator;
  IBOutlet NSTabView *tabView;
  IBOutlet NSProgressIndicator *startSpinner;
  IBOutlet NSProgressIndicator *stopSpinner;
  IBOutlet NSButton *startButton;
  IBOutlet NSButton *stopButton;
}

@property (assign, readwrite) TBBonjourWrapper *bonjour;
@property (assign, readwrite) BOOL isRunning;
@property (assign, readwrite) BOOL isServer;
@property (assign) IBOutlet NSMatrix *typeRadioMatrix;
@property (assign, readwrite) IBOutlet NSImageView *runStatusIndicator;

- (void)mainViewDidLoad;
- (void)dealloc;

- (IBAction)doRefresh:(id)sender;

- (IBAction)setAsServer:(id)sender;
- (IBAction)setAsClient:(id)sender;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)setStartSystem:(id)sender;
- (IBAction)setStartLogin:(id)sender;

- (void)serverDidStartNotification:(NSNotification *)notification;
- (void)clientDidStartNotification:(NSNotification *)notification;
- (void)agentDidStopNotification:(NSNotification *)notification;
- (void)agentStatusNotification:(NSNotification *)notification;

@end
