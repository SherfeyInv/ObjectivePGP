//
//  PGPCompoundKey.m
//  ObjectivePGP
//
//  Created by Marcin Krzyzanowski on 31/05/2017.
//  Copyright © 2017 Marcin Krzyżanowski. All rights reserved.
//

#import "PGPCompoundKey.h"
#import "PGPCompoundKey+Private.h"
#import "PGPSubKey.h"
#import "PGPSecretKeyPacket.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PGPCompoundKey

- (instancetype)initWithSecretKey:(nullable PGPKey *)secretKey publicKey:(nullable PGPKey *)publicKey {
    if ((self = [super init])) {
        _secretKey = secretKey;
        _publicKey = publicKey;
    }
    return self;
}

- (nullable PGPSecretKeyPacket *)signingSecretKey {
    if (!self.secretKey) {
        PGPLogDebug(@"Need secret key to sign");
        return nil;
    }

    // find secret key based on the public key signature (unless self signed secret key)
    let signingPacket = PGPCast(self.secretKey.signingKeyPacket,PGPSecretKeyPacket);
    if (!signingPacket) {
        PGPLogWarning(@"Need secret key to sign");
    }

    return signingPacket;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }

    let other = PGPCast(object, PGPCompoundKey);
    if (!other) {
        return NO;
    }

    return [self.secretKey isEqual:other.secretKey] && [self.publicKey isEqual:other.publicKey];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.secretKey.hash;
    result = prime * result + self.publicKey.hash;
    return result;
}

@end

NS_ASSUME_NONNULL_END
