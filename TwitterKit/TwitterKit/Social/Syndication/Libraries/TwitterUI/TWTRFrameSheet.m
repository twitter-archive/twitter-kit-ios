/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// Splits a UIImage containing a grid of images (frames) for an animation
// into an array.

#import "TWTRFrameSheet.h"

@interface TWTRFrameSheet ()
@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;
@property (nonatomic, readonly) NSUInteger frameCount;
@property (nonatomic, readonly) UIImage *frameSheet;
@end

@implementation TWTRFrameSheet

- (instancetype)initWithImage:(UIImage *)image rows:(NSUInteger)rows columns:(NSUInteger)columns frameCount:(NSUInteger)frameCount imageWidth:(NSUInteger)imageWidth imageHeight:(NSUInteger)imageHeight
{
    if ((self = [super init]) != nil) {
        _rows = rows;
        _columns = columns;
        _frameSheet = image;
        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
        _frameCount = frameCount;
    }
    return self;
}

- (NSArray *)frameArray
{
    // Parses a frame sheet of (rectangular) images into an array of images of equal size. Total count
    // specified by frameCount.
    NSMutableArray *frameArray = [[NSMutableArray alloc] initWithCapacity:_frameCount];

    for (NSUInteger i = 0; i < _rows; i++) {
        for (NSUInteger j = 0; j < _columns; j++) {
            if ([frameArray count] == _frameCount) {
                break;
            }
            CGRect frame = CGRectMake(_imageWidth * j * _frameSheet.scale, _imageHeight * i * _frameSheet.scale, _imageWidth * _frameSheet.scale, _imageHeight * _frameSheet.scale);
            CGImageRef imageRef = CGImageCreateWithImageInRect([_frameSheet CGImage], frame);
            [frameArray addObject:[[UIImage imageWithCGImage:imageRef] copy]];
            CGImageRelease(imageRef);
        }
    }
    return frameArray;
}

@end
