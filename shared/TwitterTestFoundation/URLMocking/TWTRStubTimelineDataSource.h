//
//  StubDataSource.h
//  TwitterKit
//
//  Created by Steven Hepting on 4/1/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWTRTimelineDataSource.h"

/*
 *  Provide a stub implementation of TWTRTimelineDataSource which calls the completion method immediately with any provided properties. Allows testing of classes with depend particularly heavily on the response that a data source provides (e.g. TWTRTimelineViewController).
 */

@class TWTRTimelineFilter;

@interface TWTRStubTimelineDataSource : NSObject <TWTRTimelineDataSource>

@property (nonatomic, assign) TWTRTimelineType timelineType;
@property (nonatomic, copy) TWTRTimelineFilter *timelineFilter;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TWTRTimelineCursor *cursor;
@property (nonatomic, strong) NSError *error;

@end
