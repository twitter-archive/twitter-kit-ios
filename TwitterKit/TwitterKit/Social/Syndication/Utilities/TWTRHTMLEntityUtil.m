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

#import "TWTRHTMLEntityUtil.h"
#import "TWTRStringUtil.h"

typedef struct {
    const char *escapeSequence;
    UniChar character;
} HTMLEscapeSequenceMapItem;

// Generated from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Sorted by escape sequence for binary search
static HTMLEscapeSequenceMapItem escapeSequenceMap[] = {
    {"AElig", 0xc6},     {"Aacute", 0xc1},   {"Acirc", 0xc2},    {"Agrave", 0xc0},   {"Alpha", 0x391},   {"Aring", 0xc5},   {"Atilde", 0xc3}, {"Auml", 0xc4},    {"Beta", 0x392},   {"Ccedil", 0xc7},   {"Chi", 0x3a7},    {"Dagger", 0x2021}, {"Delta", 0x394},   {"ETH", 0xd0},      {"Eacute", 0xc9},    {"Ecirc", 0xca},    {"Egrave", 0xc8},   {"Epsilon", 0x395}, {"Eta", 0x397},     {"Euml", 0xcb},     {"Gamma", 0x393},  {"Iacute", 0xcd},  {"Icirc", 0xce},   {"Igrave", 0xcc},   {"Iota", 0x399},
    {"Iuml", 0xcf},      {"Kappa", 0x39a},   {"Lambda", 0x39b},  {"Mu", 0x39c},      {"Ntilde", 0xd1},   {"Nu", 0x39d},     {"OElig", 0x152}, {"Oacute", 0xd3},  {"Ocirc", 0xd4},   {"Ograve", 0xd2},   {"Omega", 0x3a9},  {"Omicron", 0x39f}, {"Oslash", 0xd8},   {"Otilde", 0xd5},   {"Ouml", 0xd6},      {"Phi", 0x3a6},     {"Pi", 0x3a0},      {"Prime", 0x2033},  {"Psi", 0x3a8},     {"Rho", 0x3a1},     {"Scaron", 0x160}, {"Sigma", 0x3a3},  {"THORN", 0xde},   {"Tau", 0x3a4},     {"Theta", 0x398},
    {"Uacute", 0xda},    {"Ucirc", 0xdb},    {"Ugrave", 0xd9},   {"Upsilon", 0x3a5}, {"Uuml", 0xdc},     {"Xi", 0x39e},     {"Yacute", 0xdd}, {"Yuml", 0x178},   {"Zeta", 0x396},   {"aacute", 0xe1},   {"acirc", 0xe2},   {"acute", 0xb4},    {"aelig", 0xe6},    {"agrave", 0xe0},   {"alefsym", 0x2135}, {"alpha", 0x3b1},   {"and", 0x2227},    {"ang", 0x2220},    {"aring", 0xe5},    {"asymp", 0x2248},  {"atilde", 0xe3},  {"auml", 0xe4},    {"bdquo", 0x201e}, {"beta", 0x3b2},    {"brvbar", 0xa6},
    {"bull", 0x2022},    {"cap", 0x2229},    {"ccedil", 0xe7},   {"cedil", 0xb8},    {"cent", 0xa2},     {"chi", 0x3c7},    {"circ", 0x2c6},  {"clubs", 0x2663}, {"cong", 0x2245},  {"copy", 0xa9},     {"crarr", 0x21b5}, {"cup", 0x222a},    {"curren", 0xa4},   {"dArr", 0x21d3},   {"dagger", 0x2020},  {"darr", 0x2193},   {"deg", 0xb0},      {"delta", 0x3b4},   {"diams", 0x2666},  {"divide", 0xf7},   {"eacute", 0xe9},  {"ecirc", 0xea},   {"egrave", 0xe8},  {"empty", 0x2205},  {"emsp", 0x2003},
    {"ensp", 0x2002},    {"epsilon", 0x3b5}, {"equiv", 0x2261},  {"eta", 0x3b7},     {"eth", 0xf0},      {"euml", 0xeb},    {"euro", 0x20ac}, {"exist", 0x2203}, {"fnof", 0x192},   {"forall", 0x2200}, {"frac12", 0xbd},  {"frac14", 0xbc},   {"frac34", 0xbe},   {"frasl", 0x2044},  {"gamma", 0x3b3},    {"ge", 0x2265},     {"hArr", 0x21d4},   {"harr", 0x2194},   {"hearts", 0x2665}, {"hellip", 0x2026}, {"iacute", 0xed},  {"icirc", 0xee},   {"iexcl", 0xa1},   {"igrave", 0xec},   {"image", 0x2111},
    {"infin", 0x221e},   {"int", 0x222b},    {"iota", 0x3b9},    {"iquest", 0xbf},   {"isin", 0x2208},   {"iuml", 0xef},    {"kappa", 0x3ba}, {"lArr", 0x21d0},  {"lambda", 0x3bb}, {"lang", 0x2329},   {"laquo", 0xab},   {"larr", 0x2190},   {"lceil", 0x2308},  {"ldquo", 0x201c},  {"le", 0x2264},      {"lfloor", 0x230a}, {"lowast", 0x2217}, {"loz", 0x25ca},    {"lrm", 0x200e},    {"lsaquo", 0x2039}, {"lsquo", 0x2018}, {"macr", 0xaf},    {"mdash", 0x2014}, {"micro", 0xb5},    {"middot", 0xb7},
    {"minus", 0x2212},   {"mu", 0x3bc},      {"nabla", 0x2207},  {"nbsp", 0xa0},     {"ndash", 0x2013},  {"ne", 0x2260},    {"ni", 0x220b},   {"not", 0xac},     {"notin", 0x2209}, {"nsub", 0x2284},   {"ntilde", 0xf1},  {"nu", 0x3bd},      {"oacute", 0xf3},   {"ocirc", 0xf4},    {"oelig", 0x153},    {"ograve", 0xf2},   {"oline", 0x203e},  {"omega", 0x3c9},   {"omicron", 0x3bf}, {"oplus", 0x2295},  {"or", 0x2228},    {"ordf", 0xaa},    {"ordm", 0xba},    {"oslash", 0xf8},   {"otilde", 0xf5},
    {"otimes", 0x2297},  {"ouml", 0xf6},     {"para", 0xb6},     {"part", 0x2202},   {"permil", 0x2030}, {"perp", 0x22a5},  {"phi", 0x3c6},   {"pi", 0x3c0},     {"piv", 0x3d6},    {"plusmn", 0xb1},   {"pound", 0xa3},   {"prime", 0x2032},  {"prod", 0x220f},   {"prop", 0x221d},   {"psi", 0x3c8},      {"rArr", 0x21d2},   {"radic", 0x221a},  {"rang", 0x232a},   {"raquo", 0xbb},    {"rarr", 0x2192},   {"rceil", 0x2309}, {"rdquo", 0x201d}, {"real", 0x211c},  {"reg", 0xae},      {"rfloor", 0x230b},
    {"rho", 0x3c1},      {"rlm", 0x200f},    {"rsaquo", 0x203a}, {"rsquo", 0x2019},  {"sbquo", 0x201a},  {"scaron", 0x161}, {"sdot", 0x22c5}, {"sect", 0xa7},    {"shy", 0xad},     {"sigma", 0x3c3},   {"sigmaf", 0x3c2}, {"sim", 0x223c},    {"spades", 0x2660}, {"sub", 0x2282},    {"sube", 0x2286},    {"sum", 0x2211},    {"sup", 0x2283},    {"sup1", 0xb9},     {"sup2", 0xb2},     {"sup3", 0xb3},     {"supe", 0x2287},  {"szlig", 0xdf},   {"tau", 0x3c4},    {"there4", 0x2234}, {"theta", 0x3b8},
    {"thetasym", 0x3d1}, {"thinsp", 0x2009}, {"thorn", 0xfe},    {"tilde", 0x2dc},   {"times", 0xd7},    {"trade", 0x2122}, {"uArr", 0x21d1}, {"uacute", 0xfa},  {"uarr", 0x2191},  {"ucirc", 0xfb},    {"ugrave", 0xf9},  {"uml", 0xa8},      {"upsih", 0x3d2},   {"upsilon", 0x3c5}, {"uuml", 0xfc},      {"weierp", 0x2118}, {"xi", 0x3be},      {"yacute", 0xfd},   {"yen", 0xa5},      {"yuml", 0xff},     {"zeta", 0x3b6},   {"zwj", 0x200d},   {"zwnj", 0x200c}};

static UniChar GetUniCharForHTMLEntityBody(const char *str)
{
    if (!str || !*str) {
        return 0;
    }

    // Treat most common cases
    if (strcmp(str, "lt") == 0 || strcmp(str, "LT") == 0) {
        return '<';
    } else if (strcmp(str, "gt") == 0 || strcmp(str, "GT") == 0) {
        return '>';
    } else if (strcmp(str, "amp") == 0 || strcmp(str, "AMP") == 0) {
        return '&';
    } else if (strcmp(str, "quot") == 0 || strcmp(str, "QUOT") == 0) {
        return '"';
    } else if (strcmp(str, "apos") == 0) {
        return '\'';
    }

    // Binary search
    const int linearSearchThreshold = 5;
    int size = sizeof(escapeSequenceMap) / sizeof(HTMLEscapeSequenceMapItem);
    int left = 0;
    int right = size;
    while (left < right - linearSearchThreshold) {
        int center = (left + right) / 2;
        HTMLEscapeSequenceMapItem *item = &escapeSequenceMap[center];
        int compResult = strcmp(item->escapeSequence, str);
        if (compResult > 0) {
            right = center;
        } else if (compResult < 0) {
            left = center + 1;
        } else {
            return item->character;
        }
    }

    // Linear search
    for (int i = left; i < right; i++) {
        HTMLEscapeSequenceMapItem *item = &escapeSequenceMap[i];
        if (strcmp(item->escapeSequence, str) == 0) {
            return item->character;
        }
    }

    return 0;
}

static NSRange FindHTMLEntity(NSString *string, NSUInteger start)
{
    NSUInteger len = string.length;
    if (len == 0) {
        return (NSRange){NSNotFound, 0};
    }

    static NSCharacterSet *ampSet = nil;
    static NSCharacterSet *semicolonSet = nil;
    if (!ampSet) {
        ampSet = [NSCharacterSet characterSetWithRange:NSMakeRange('&', 1)];
    }
    if (!semicolonSet) {
        semicolonSet = [NSCharacterSet characterSetWithRange:NSMakeRange(';', 1)];
    }

    NSRange ampRange = [string rangeOfCharacterFromSet:ampSet options:0 range:NSMakeRange(start, len - start)];
    if (ampRange.location != NSNotFound) {
        NSUInteger entityBodyStart = ampRange.location + 1;
        NSRange semicolonRange = [string rangeOfCharacterFromSet:semicolonSet options:0 range:NSMakeRange(entityBodyStart, len - entityBodyStart)];
        if (semicolonRange.location != NSNotFound) {
            return NSMakeRange(ampRange.location, semicolonRange.location + 1 - ampRange.location);
        }
    }

    return (NSRange){NSNotFound, 0};
}

@implementation TWTRHTMLEntityUtil

+ (NSString *)unescapedHTMLEntitiesStringWithString:(NSString *)originalString
{
    NSMutableString *string = [originalString mutableCopy];

    if (string.length == 0) {
        return string;
    }

    NSUInteger position = 0;

    while (1) {
        NSRange range = FindHTMLEntity(string, position);
        if (range.location == NSNotFound) {
            break;
        }

        if (range.length <= 2) {
            position = range.location + 1;
            continue;
        }

        NSString *newContent = nil;
        NSString *content = [string substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
        if ([content hasPrefix:@"#"]) {
            // &#x27; or &#39;
            UTF32Char codePoint = 0;
            content = [content substringFromIndex:1];
            if ([content rangeOfString:@"x" options:NSCaseInsensitiveSearch | NSAnchoredSearch].location == 0) {
                // &#x27;
                content = [content substringFromIndex:1];
                if ([TWTRStringUtil stringContainsOnlyHexNumbers:content]) {
                    codePoint = (UTF32Char)[TWTRStringUtil hexIntegerValueWithString:content];
                }
            } else if ([TWTRStringUtil stringContainsOnlyNumbers:content]) {
                // &#39;
                codePoint = [content intValue];
            }

            if ((0x20 <= codePoint && codePoint < 0xD800) || (0xDFFF < codePoint && codePoint <= 0x10FFFF)) {
                if (codePoint <= 0xFFFF) {
                    // BMP characters
                    UniChar buffer = codePoint;
                    newContent = [NSString stringWithCharacters:&buffer length:1];
                } else {
                    // Non BMP characters
                    UniChar buffer[2];
                    if (CFStringGetSurrogatePairForLongCharacter(codePoint, buffer)) {
                        newContent = [NSString stringWithCharacters:buffer length:2];
                    }
                }
            }
        } else {
            // Normal HTML entities
            // &lt; &gt; &amp; &quot; etc.
            UniChar c = GetUniCharForHTMLEntityBody([content UTF8String]);
            if (c) {
                newContent = [NSString stringWithCharacters:&c length:1];
            }
        }

        if (newContent) {
            // Replace HTML entity
            [string replaceCharactersInRange:range withString:newContent];

            position = range.location + newContent.length;
        } else {
            position = range.location + 1;
        }
    }

    return string;
}

@end
