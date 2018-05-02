//
//  SCParser.h
//  SCParser
//
//  Created by Даниил on 01.05.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCParser : NSObject

- (_Nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 *  Выполняет парсинг embedded.mobilprovision, находящийся в главной директории приложения, и вызывает completion блок.
 */
- (void)parseAppProvisionWithCompletion:(void (^_Nonnull)(NSDictionary * _Nullable provisionDict, NSError * _Nullable error))completion;

/**
 *  Выполняет парсинг данных, подписанных с помощью CMS, и вызывает completion блок.
 */
- (void)parseSignedData:(nullable NSData *)signedData completion:(void (^ _Nonnull)(NSDictionary * _Nullable plist, NSError * _Nullable error))completion;

@end
