//
//  StubDataSource.m
//  TwitterKit
//
//  Created by Steven Hepting on 4/1/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "TWTRStubTimelineDataSource.h"

@implementation TWTRStubTimelineDataSource
@synthesize APIClient = _APIClient;

- (void)loadPreviousTweetsBeforePosition:(NSString *)position completion:(TWTRLoadTimelineCompletion)completion {
    if (completion) {
        completion(self.tweets, self.cursor, self.error);
    }
}

@end
