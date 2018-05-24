//
//  AppDelegate.m
//  MenubarTicker
//
//  Created by Serban Giuroiu on 6/3/12.
//  Copyright (c) 2012 Serban Giuroiu. All rights reserved.
//

#import "AppDelegate.h"

#import "iTunes.h"

const NSTimeInterval kPollingInterval = 10.0;

@interface AppDelegate ()

@property(nonatomic, retain) iTunesApplication *iTunes;

@property(nonatomic, retain) NSStatusItem *statusItem;
@property(nonatomic, retain) NSTimer *timer;

@end

@implementation AppDelegate

@synthesize iTunes;

@synthesize statusItem;
@synthesize statusMenu;
@synthesize timer;

- (void)dealloc {
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                             name:nil
                                                           object:nil];

  self.iTunes = nil;

  self.statusItem = nil;
  self.statusMenu = nil;

  [self.timer invalidate];
  self.timer = nil;

  [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval
                                                target:self
                                              selector:@selector(timerDidFire:)
                                              userInfo:nil
                                               repeats:YES];

  [[NSDistributedNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(didReceivePlayerNotification:)
             name:@"com.apple.iTunes.playerInfo"
           object:nil];
}

- (void)awakeFromNib {
  self.iTunes =
      [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

  self.statusItem = [[NSStatusBar systemStatusBar]
      statusItemWithLength:NSVariableStatusItemLength];
  self.statusItem.menu = self.statusMenu;
  self.statusItem.highlightMode = YES;
  self.statusItem.toolTip = @"Menu Bar Ticker";

  [self updateTrackInfo];
}

- (void)updateTrackInfo {
  id currentTrack = nil;

  if ([self.iTunes isRunning] &&
      [self.iTunes playerState] == iTunesEPlSPlaying) {
    currentTrack = [self.iTunes currentTrack];
  }

  statusItem.title =
      currentTrack
          ? [NSString stringWithFormat:@"%@ - %@", [currentTrack artist],
                                       [currentTrack name]]
          : @"♫"; // 🎵 or 🎶 or ♫
}

- (void)timerDidFire:(NSTimer *)theTimer {
  [self updateTrackInfo];
}

- (void)didReceivePlayerNotification:(NSNotification *)notification {
  [self updateTrackInfo];
}

@end
