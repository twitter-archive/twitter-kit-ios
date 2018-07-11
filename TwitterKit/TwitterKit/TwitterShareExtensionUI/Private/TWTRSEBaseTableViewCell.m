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

#import "TWTRSEBaseTableViewCell.h"

@implementation TWTRSEBaseTableViewCell

- (instancetype)init
{
    return [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self class].reuseIdentifier];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"This cell doesn't have Nib support");

    return [self init];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [self class].reuseIdentifier;
}

@end
