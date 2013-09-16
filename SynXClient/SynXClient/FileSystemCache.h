//
//  TBFileSystemCache.h
//  SCEvents
//
//  Created by Tage Borg on 2011-05-02.
//  Copyright 2011 Tage Borg. All rights reserved.
//

/*
 cache = new cache(dictionary:files->attibutes)
 
 (...later...)

 path changed = "/Users/tage/Desktop"
 
 array changes = cache.modified(changed)
 
 for (file in changes) do
  changetype = cache.changetype(file)
  switch (changetype)
    case added:
      enqueue(file, write)
      break
    case modified:
      enqueue(file, write)
      break
    case moved:
      topath = cache.newlocation(file)
      if (topath is in monitored paths)
        enqueue(file, move)
      else
        enqueue(file, delete)
      end if
      break
    case deleted:
      enqueue(file, delete)
      break
  end switch
 end for
 */

#import <Foundation/Foundation.h>

#define STORAGE_LOCATION @"~/Library/Application Support/SynX/"
#define STORAGE_FILE @"SynX.cache"

@interface FileSystemCache : NSObject {
@private
  NSMutableDictionary *files; // main cache
  NSString *cacheStorage;
  NSMutableSet *added;
  NSMutableSet *changed;
  NSMutableSet *moved;
  NSMutableDictionary *locations;
}

- (NSString *)cacheStorageLocation;

// inits cache with files from the supplied list; attributes are fetched
- (id)initWithFiles:(NSArray *)cacheKeys;

// inits cache with files and attributes from the supplied list
- (id)initWithState:(NSDictionary *)cache;

// inits cache with contents of previously stored cache
- (id)init;

- (void)dealloc;

// returns an array of files that have changed in the given path
- (NSArray *)filesChangedIn:(NSString *)path;

// stores the cache for later loading
- (void)stop;

// TODO: if a file has been moved, the new path can be found using this call
- (NSString *)newLocationFor:(NSString *)oldFile;

@end
