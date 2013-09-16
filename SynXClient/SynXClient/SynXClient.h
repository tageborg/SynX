//
//  SynXClient.h
//  SynXClient
//
//  Created by Tage Borg on 2011-05-02.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import "SCEventListenerProtocol.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "FileSystemCache.h"

@interface SynXClient : NSObject <SCEventListenerProtocol> {
@private
  FileSystemCache *cache;
}

- (void)setupEventListener;

@end
