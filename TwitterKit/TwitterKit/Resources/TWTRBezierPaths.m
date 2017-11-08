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

#import "TWTRBezierPaths.h"

@implementation TWTRBezierPaths

// Implementation taken from Twitter for iOS, but converted to not use categories
+ (UIBezierPath *)twitterLogo
{
    static dispatch_once_t onceToken;
    static UIBezierPath *logoPath;

    dispatch_once(&onceToken, ^{
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:(CGPoint){.x = 1.0000, .y = 0.1899}];
        [path addCurveToPoint:(CGPoint){.x = 0.8822, .y = 0.2222} controlPoint1:(CGPoint){.x = 0.9632, .y = 0.2062} controlPoint2:(CGPoint){.x = 0.9237, .y = 0.2172}];
        [path addCurveToPoint:(CGPoint){.x = 0.9724, .y = 0.1086} controlPoint1:(CGPoint){.x = 0.9245, .y = 0.1968} controlPoint2:(CGPoint){.x = 0.9571, .y = 0.1565}];
        [path addCurveToPoint:(CGPoint){.x = 0.8421, .y = 0.1584} controlPoint1:(CGPoint){.x = 0.9327, .y = 0.1321} controlPoint2:(CGPoint){.x = 0.8888, .y = 0.1493}];
        [path addCurveToPoint:(CGPoint){.x = 0.6923, .y = 0.0936} controlPoint1:(CGPoint){.x = 0.8047, .y = 0.1186} controlPoint2:(CGPoint){.x = 0.7514, .y = 0.0936}];
        [path addCurveToPoint:(CGPoint){.x = 0.4872, .y = 0.2988} controlPoint1:(CGPoint){.x = 0.5791, .y = 0.0936} controlPoint2:(CGPoint){.x = 0.4872, .y = 0.1855}];
        [path addCurveToPoint:(CGPoint){.x = 0.4925, .y = 0.3456} controlPoint1:(CGPoint){.x = 0.4872, .y = 0.3149} controlPoint2:(CGPoint){.x = 0.4890, .y = 0.3305}];
        [path addCurveToPoint:(CGPoint){.x = 0.0696, .y = 0.1312} controlPoint1:(CGPoint){.x = 0.3219, .y = 0.3370} controlPoint2:(CGPoint){.x = 0.1708, .y = 0.2553}];
        [path addCurveToPoint:(CGPoint){.x = 0.0419, .y = 0.2343} controlPoint1:(CGPoint){.x = 0.0519, .y = 0.1615} controlPoint2:(CGPoint){.x = 0.0419, .y = 0.1968}];
        [path addCurveToPoint:(CGPoint){.x = 0.1331, .y = 0.4051} controlPoint1:(CGPoint){.x = 0.0419, .y = 0.3055} controlPoint2:(CGPoint){.x = 0.0781, .y = 0.3683}];
        [path addCurveToPoint:(CGPoint){.x = 0.0402, .y = 0.3795} controlPoint1:(CGPoint){.x = 0.0995, .y = 0.4041} controlPoint2:(CGPoint){.x = 0.0678, .y = 0.3948}];
        [path addCurveToPoint:(CGPoint){.x = 0.0402, .y = 0.3820} controlPoint1:(CGPoint){.x = 0.0402, .y = 0.3803} controlPoint2:(CGPoint){.x = 0.0402, .y = 0.3812}];
        [path addCurveToPoint:(CGPoint){.x = 0.2048, .y = 0.5832} controlPoint1:(CGPoint){.x = 0.0402, .y = 0.4814} controlPoint2:(CGPoint){.x = 0.1109, .y = 0.5644}];
        [path addCurveToPoint:(CGPoint){.x = 0.1507, .y = 0.5904} controlPoint1:(CGPoint){.x = 0.1875, .y = 0.5879} controlPoint2:(CGPoint){.x = 0.1694, .y = 0.5904}];
        [path addCurveToPoint:(CGPoint){.x = 0.1121, .y = 0.5867} controlPoint1:(CGPoint){.x = 0.1375, .y = 0.5904} controlPoint2:(CGPoint){.x = 0.1246, .y = 0.5891}];
        [path addCurveToPoint:(CGPoint){.x = 0.3037, .y = 0.7292} controlPoint1:(CGPoint){.x = 0.1382, .y = 0.6682} controlPoint2:(CGPoint){.x = 0.2139, .y = 0.7276}];
        [path addCurveToPoint:(CGPoint){.x = 0.0489, .y = 0.8170} controlPoint1:(CGPoint){.x = 0.2335, .y = 0.7842} controlPoint2:(CGPoint){.x = 0.1450, .y = 0.8170}];
        [path addCurveToPoint:(CGPoint){.x = 0.0000, .y = 0.8142} controlPoint1:(CGPoint){.x = 0.0324, .y = 0.8170} controlPoint2:(CGPoint){.x = 0.0161, .y = 0.8161}];
        [path addCurveToPoint:(CGPoint){.x = 0.3145, .y = 0.9064} controlPoint1:(CGPoint){.x = 0.0908, .y = 0.8724} controlPoint2:(CGPoint){.x = 0.1986, .y = 0.9064}];
        [path addCurveToPoint:(CGPoint){.x = 0.8982, .y = 0.3226} controlPoint1:(CGPoint){.x = 0.6919, .y = 0.9064} controlPoint2:(CGPoint){.x = 0.8982, .y = 0.5937}];
        [path addCurveToPoint:(CGPoint){.x = 0.8976, .y = 0.2961} controlPoint1:(CGPoint){.x = 0.8982, .y = 0.3137} controlPoint2:(CGPoint){.x = 0.8980, .y = 0.3049}];
        [path addCurveToPoint:(CGPoint){.x = 1.0000, .y = 0.1899} controlPoint1:(CGPoint){.x = 0.9377, .y = 0.2671} controlPoint2:(CGPoint){.x = 0.9725, .y = 0.2310}];
        [path closePath];
        logoPath = path;
    });

    // UIBezierPath is a mutable object.
    // Since we have a static instance, we must return a copy to make sure the caller doesn't make changes for everyone
    return logoPath.copy;
}

@end
