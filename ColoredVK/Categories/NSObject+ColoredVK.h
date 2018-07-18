//
//  NSObject+ColoredVK.h
//  ColoredVK2
//
//  Created by Даниил on 09.04.18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (ColoredVK)

/**
 *  Асинхронно выполняет блок типа void на главном потоке.
 */
+ (void)cvk_runBlockOnMainThread:(void(^)(void))block;

/**
 *  Выполняет заданный селектор у объекта. Является аналогом objc_msgSend.
 *  
 *  @param selector Селектор обьекта
 *  @param argument Список аргументов для выполения. Может быть nil, если селектор не принимает аргументов
 *
 *  @return Возвращает значение выполняемого селектора
 */
- (nullable void *)cvk_executeSelector:(SEL)selector arguments:(nullable id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Выполняет заданный селектор у объекта. Является аналогом objc_msgSend.
 *  
 *  @param selector Селектор обьекта
 *
 *  @return Возвращает значение выполняемого селектора
 */
- (nullable void *)cvk_executeSelector:(SEL)selector;

@end
NS_ASSUME_NONNULL_END
