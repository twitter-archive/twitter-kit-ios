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

#import "TWTRImageSequenceConfiguration.h"
#import "TWTRImages.h"

@interface TWTRImageSequenceConfiguration ()

@property (nonatomic) UIImage *imageSheet;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;
@property (nonatomic) NSUInteger frameCount;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGFloat duration;

@end

@implementation TWTRImageSequenceConfiguration

+ (TWTRImageSequenceConfiguration *)heartImageSequenceConfigurationWithSize:(TWTRHeartImageSequenceSize)size
{
    switch (size) {
        case TWTRHeartImageSequenceSizeRegular:
            return [self heartImageSequenceConfigurationWithRegularSize];
            break;
        case TWTRHeartImageSequenceSizeLarge:
            return [self heartImageSequenceConfigurationWithLargeSize];
            break;
    }
}

+ (TWTRImageSequenceConfiguration *)heartImageSequenceConfigurationWithRegularSize
{
    static TWTRImageSequenceConfiguration *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *imageSheet = [TWTRImages likeImageSheet];
        CGSize imageSize = CGSizeMake(42, 42);
        config = [self heartSequenceConfigurationWithImageSheet:imageSheet imageSize:imageSize];
    });
    return config;
}

+ (TWTRImageSequenceConfiguration *)heartImageSequenceConfigurationWithLargeSize
{
    static TWTRImageSequenceConfiguration *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *imageSheet = [TWTRImages likeImageSheetLarge];
        CGSize imageSize = CGSizeMake(63, 63);
        config = [self heartSequenceConfigurationWithImageSheet:imageSheet imageSize:imageSize];
    });
    return config;
}

+ (TWTRImageSequenceConfiguration *)heartSequenceConfigurationWithImageSheet:(UIImage *)imageSheet imageSize:(CGSize)imageSize
{
    TWTRImageSequenceConfiguration *config = [[TWTRImageSequenceConfiguration alloc] init];
    config.imageSheet = imageSheet;
    config.rows = 8;
    config.columns = 8;
    config.frameCount = 57;
    config.imageSize = imageSize;
    config.duration = 0.9;

    return config;
}

@end
