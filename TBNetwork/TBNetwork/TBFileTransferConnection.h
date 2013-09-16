//
//  TBFileTransferConnection.h
//  TBNetwork
//
//  Created by Tage Borg on 20110407.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBConnection.h"


@interface TBFileTransferConnection : TBConnection {
    
}

- (id)initWithFileHandle:(NSFileHandle *)fileHandle andServer:(TBServer *)owningServer;
- (void)dealloc;

- (void) dataReceivedNotification:(NSNotification *)notification;

@end
