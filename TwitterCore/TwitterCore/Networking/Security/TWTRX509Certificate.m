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

#import "TWTRX509Certificate.h"
#import <CommonCrypto/CommonDigest.h>
#import <Security/SecCertificate.h>
#import <Security/Security.h>

@implementation TWTRX509Certificate {
    NSString *_fingerprint;
    NSData *_publicKey;
    CFDataRef _certificateDataRef;
    CFIndex _certificateLength;
    const UInt8 *_certificateBytes;
}

static UInt8 RSA_OID_BYTES[] = {0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01};

- (instancetype)initWithCertificate:(SecCertificateRef)certificate
{
    self = [super init];

    if (self) {
        _certificateDataRef = SecCertificateCopyData(certificate);
        _certificateLength = CFDataGetLength(_certificateDataRef);
        _certificateBytes = CFDataGetBytePtr(_certificateDataRef);
    }

    return self;
}

- (NSString *)fingerprint
{
    if (_fingerprint) {
        return _fingerprint;
    }

    unsigned char sha1[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(_certificateBytes, (CC_LONG)_certificateLength, sha1);

    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [fingerprint appendFormat:@"%02x", sha1[i]];
    }

    _fingerprint = fingerprint;
    return _fingerprint;
}

- (NSData *)publicKey
{
    if (_publicKey) {
        return _publicKey;
    }

    int rsaOidOffset = [self findRsaOidOffset:_certificateBytes length:_certificateLength];

    if (rsaOidOffset == -1) {
        return nil;
    }

    int enclosingSequenceOffset = [self findEnclosingSequence:_certificateBytes offset:rsaOidOffset];

    if (enclosingSequenceOffset == -1) {
        return nil;
    }
    enclosingSequenceOffset = [self findEnclosingSequence:_certificateBytes offset:enclosingSequenceOffset];

    if (enclosingSequenceOffset == -1) {
        return nil;
    }

    int totalSequenceLength = [self parseSequenceLength:_certificateBytes offset:enclosingSequenceOffset length:_certificateLength];

    if (totalSequenceLength < 0 || totalSequenceLength > _certificateLength - enclosingSequenceOffset) {
        return nil;
    }

    _publicKey = [NSData dataWithBytes:(UInt8 *)_certificateBytes + enclosingSequenceOffset length:(NSUInteger)totalSequenceLength];
    return _publicKey;
}

- (int)parseSequenceLength:(const UInt8 *)bytes offset:(int)offset length:(CFIndex)length
{
    if (bytes[offset] != 0x30 || offset + 1 >= length) {
        return -1;
    }

    int lengthLength = bytes[offset + 1];

    if (lengthLength < 128) {
        return lengthLength + 2;
    }

    lengthLength = lengthLength & 0x7F;

    if ((offset + 1 + lengthLength >= length) || (lengthLength > 4)) {
        return -1;
    }

    int lengthValue = 0;

    for (int i = 0; i < lengthLength; i++) {
        lengthValue |= ((bytes[offset + 2 + i]) << ((lengthLength - 1 - i) * 8));
    }

    return lengthValue + 2 + lengthLength;
}

- (int)findEnclosingSequence:(const UInt8 *)bytes offset:(int)offset
{
    for (int i = offset - 1; i >= 0; i--) {
        if (bytes[i] == 0x30) {
            return i;
        }
    }

    return -1;
}

- (int)findRsaOidOffset:(const UInt8 *)bytes length:(CFIndex)length
{
    for (int i = 0; i < length; i++) {
        if ((bytes[i] == RSA_OID_BYTES[0]) && (memcmp(bytes + i, RSA_OID_BYTES, sizeof(RSA_OID_BYTES)) == 0)) {
            return i;
        }
    }

    return -1;
}

- (void)dealloc
{
    if (_certificateDataRef) {
        CFRelease(_certificateDataRef);
    }
}

@end
