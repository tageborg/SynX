//
//  TBFileTransfer.h
//  dobjectserver
//
//  Created by Tage Borg on 2011-04-29.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBTransferableFileList
- (bycopy NSDictionary *)attributes;
- (bycopy NSData *)contents;
- (bycopy NSString *)name;
- (bycopy BOOL)next; // returns true if there is another file to receive AND selects that file
@end

@interface TBFileTransfer : NSObject <TBTransferableFileList> {
@private
  NSConnection *connection;
  NSArray *fileList;
  id remote;
  NSUInteger fileCount;
  NSUInteger currentFile;
  BOOL atStartOfList;
}

- (TBFileTransfer *)initWithPort:(int)port;
- (TBFileTransfer *)initWithPort:(int)port andHost:(NSString *)host;

- (BOOL)send:(NSArray *)files;
- (BOOL)receive;
@end
