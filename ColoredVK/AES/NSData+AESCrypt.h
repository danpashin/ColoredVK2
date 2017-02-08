//
//  NSData+AESCrypt.h
//
//  AES Encrypt/Decrypt
//  Created by Jim Dovey and 'Jean'
//  See http://iphonedevelopment.blogspot.com/2009/02/strong-encryption-for-cocoa-cocoa-touch.html
//
//  BASE64 Encoding/Decoding
//  Copyright (c) 2001 Kyle Hammond. All rights reserved.
//  Original development by Dave Winer.
//
//  Put together by Michael Sedlaczek, Gone Coding on 2011-02-22
//

#import <Foundation/Foundation.h>

@interface NSData (AESCrypt)
	
@property (nonatomic, readonly, copy) NSString *base64Encoding;
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;

@end
