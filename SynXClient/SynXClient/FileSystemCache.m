//
//  TBFileSystemCache.m
//  SCEvents
//
//  Created by Tage Borg on 2011-05-02.
//  Copyright 2011 Tage Borg. All rights reserved.
//

#import "FileSystemCache.h"


@implementation FileSystemCache

- (id)initWithFiles:(NSArray *)cacheKeys
{
  NSLog(@"Starting cache");
  self = [super init];
  if (self) {
    added = [[NSMutableSet alloc] init];
    changed = [[NSMutableSet alloc] init];
    moved = [[NSMutableSet alloc] init];
    locations = [[NSMutableDictionary alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = STORAGE_LOCATION;
    folder = [folder stringByExpandingTildeInPath];
    if ([fm fileExistsAtPath: folder] == NO) {
      [fm createDirectoryAtPath: folder 
    withIntermediateDirectories:YES 
                     attributes:nil 
                          error:nil];
    }
    NSString *fileName = STORAGE_FILE; 
    cacheStorage = [folder stringByAppendingPathComponent: fileName]; 
    
    files = [[NSMutableDictionary alloc] init];
    for (NSString *file in cacheKeys) {
      NSDictionary *attributes = [fm attributesOfItemAtPath:file error:nil];
      [files setObject:attributes forKey:file];
    }
  }
  return self;
}

- (id)initWithState:(NSDictionary *)cache
{
  NSLog(@"Starting cache");
  self = [super init];
  if (self) {
    added = [[NSMutableSet alloc] init];
    changed = [[NSMutableSet alloc] init];
    moved = [[NSMutableSet alloc] init];
    locations = [[NSMutableDictionary alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = STORAGE_LOCATION;
    folder = [folder stringByExpandingTildeInPath];
    if ([fm fileExistsAtPath: folder] == NO) {
      [fm createDirectoryAtPath: folder 
    withIntermediateDirectories:YES 
                     attributes:nil 
                          error:nil];
    }
    NSString *fileName = STORAGE_FILE; 
    cacheStorage = [folder stringByAppendingPathComponent: fileName];
    
    files = [[NSMutableDictionary alloc] init];
    [files addEntriesFromDictionary:cache];
  }
  return self;
}

- (id)init
{
  NSLog(@"Starting cache");
  self = [super init];
  if (self) {
    added = [[NSMutableSet alloc] init];
    changed = [[NSMutableSet alloc] init];
    moved = [[NSMutableSet alloc] init];
    locations = [[NSMutableDictionary alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = STORAGE_LOCATION;
    folder = [folder stringByExpandingTildeInPath];
    if ([fm fileExistsAtPath: folder] == NO) {
      [fm createDirectoryAtPath: folder 
    withIntermediateDirectories:YES 
                     attributes:nil 
                          error:nil];
    }
    NSString *fileName = STORAGE_FILE; 
    cacheStorage = [folder stringByAppendingPathComponent: fileName]; 
    files = [[NSMutableDictionary alloc] initWithContentsOfFile:cacheStorage];
    NSLog(@"Loaded cache from %@: %@", cacheStorage, files);
  }
  return self;
}

- (NSString *)cacheStorageLocation
{
  return cacheStorage;
}

- (void)dealloc
{
  [files release];
  [super dealloc];
}

- (NSArray *)filesChangedIn:(NSString *)path
{
  [changed removeAllObjects];
  [added removeAllObjects];
  [moved removeAllObjects];
  NSMutableArray *results = [[NSMutableArray alloc] init];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
  
  NSMutableSet *new = [[NSMutableSet alloc] init];
  
  // see if directory contains new or changed files since last cache update
  for (NSString *f in dirContents) {
    NSString *file = [NSString stringWithFormat:@"%@/%@", path, f];
    [new addObject:file]; // for use when checking for deleted files
    NSDictionary *fileAttrs = [files objectForKey:file];
    if (fileAttrs != nil) {
      NSDate* oldDate = [fileAttrs objectForKey:NSFileModificationDate];
      NSDictionary *newAttrs = [fm attributesOfItemAtPath:file error:nil];
      NSDate* newDate = [newAttrs objectForKey:NSFileModificationDate];
      if ([newDate compare:oldDate] == NSOrderedDescending) {
        [changed addObject:file];
        [results addObject:file];
        [files setObject:newAttrs forKey:file];
        NSLog(@"changed %@; old version from %@, new version from %@", file, oldDate, newDate);
      }
    }
    else {
      NSDictionary *attrs = [fm attributesOfItemAtPath:file error:nil];
      if (attrs == nil) {
        NSLog(@"attributes are nil for %@; skipping", file);
      }
      else {
        [files setObject:attrs forKey:file];
        [added addObject:file];
        [results addObject:file];
        NSLog(@"added %@", file);
      }
    }
  }
  
  // see if files in directory have been moved or removed since last cache update
  NSMutableSet *old = [NSMutableSet setWithArray:[files allKeys]];
  [old minusSet:new];
  if ([old count] > 0) {
    for (NSString *file in old) {
      NSLog(@"removed %@", file);
      [files removeObjectForKey:file];
      [moved addObject:file];
      [results addObject:file];
    }
  }
  [new release];
  return [results autorelease];
}

- (void)stop
{
  NSLog(@"Stopping cache...");
  if ([files writeToFile:[self cacheStorageLocation] atomically:YES]) {
    NSLog(@"Cache written to disk at %@: %@", [self cacheStorageLocation], files);
  }
  else {
    NSLog(@"Failed writing cache to disk at %@: %@", [self cacheStorageLocation], files);
  }
}

- (NSString *)newLocationFor:(NSString *)oldFile
{
  return nil;
}


@end
