//
//  OpenPGPPublicKey.m
//  OpenPGPKeyring
//
//  Created by Marcin Krzyzanowski on 04/05/14.
//  Copyright (c) 2014 Marcin Krzyżanowski. All rights reserved.
//
// Packet tag 6

#import "OpenPGPPublicKey.h"
#import "OpenPGPTypes.h"
#import "OpenPGPMPI.h"

@interface OpenPGPPublicKey ()
@property (assign, readwrite) UInt8 version;
@property (assign, readwrite) UInt32 timestamp;
@property (assign, readwrite) PGPPublicKeyAlgorithm algorithm;
@end

@implementation OpenPGPPublicKey

- (void) readPacketBody:(NSData *)packetBody
{
    //UInt8 *bytes = (UInt8 *)packetBody.bytes;
    // A one-octet version number (4).
    UInt8 version;
    [packetBody getBytes:&version range:(NSRange){0,1}];
    self.version = version;

    // A four-octet number denoting the time that the key was created.
    UInt32 timestamp = 0;
    [packetBody getBytes:&timestamp range:(NSRange){1,4}];
    self.timestamp = CFSwapInt32BigToHost(timestamp);

    // A one-octet number denoting the public-key algorithm of this key.
    UInt8 algorithm = 0;
    [packetBody getBytes:&algorithm range:(NSRange){5,1}];
    self.algorithm = algorithm;

    // A series of multiprecision integers comprising the key material.
    switch (self.algorithm) {
        case PGPPublicKeyAlgorithmRSA:
        case PGPPublicKeyAlgorithmRSAEncryptOnly:
        case PGPPublicKeyAlgorithmRSASignOnly:
        {
            // Algorithm-Specific Fields for RSA public keys:
            NSUInteger position = 6;

            // MPI of RSA public modulus n;
            OpenPGPMPI *mpiN = [[OpenPGPMPI alloc] initWithData:packetBody atPosition:position];
            position = position + mpiN.length;

            // MPI of RSA public encryption exponent e.
            OpenPGPMPI *mpiE = [[OpenPGPMPI alloc] initWithData:packetBody atPosition:position];
            position = position + mpiE.length;
        }
            break;
        case PGPPublicKeyAlgorithmDSA:
        case PGPPublicKeyAlgorithmECDSA:
        {
            //TODO: DSA
            // - MPI of DSA prime p;
            // - MPI of DSA group order q (q is a prime divisor of p-1);
            // - MPI of DSA group generator g;
            // - MPI of DSA public-key value y (= g**x mod p where x is secret).
        }
            break;
        case PGPPublicKeyAlgorithmElgamal:
        case PGPPublicKeyAlgorithmElgamalEncryptOnly:
        {
            //TODO: Elgamal
            // - MPI of Elgamal prime p;
            // - MPI of Elgamal group generator g;
            // - MPI of Elgamal public key value y (= g**x mod p where x is secret).
        }
            break;
        default:
            @throw [NSException exceptionWithName:@"Unknown Algorithm" reason:@"Given algorithm is not supported" userInfo:nil];
            break;
    }

    //
}

@end
