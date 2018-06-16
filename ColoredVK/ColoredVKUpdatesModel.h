//
//  ColoredVKUpdatesModel.h
//  ColoredVK2
//
//  Created by Даниил on 02.07.17.
//
//

#import <Foundation/NSObject.h>


@interface ColoredVKUpdatesModel : NSObject

/**
 *  Возвращает YES, если версия твика является бета-версией, пользователь установил твик только что или включена проверка обновлений.
 */
@property (assign, nonatomic, readonly) BOOL shouldCheckUpdates;

/**
 *  Возвращает локализованное время последней проверки обновлений.
 */
@property (nonatomic, copy, readonly) NSString *localizedLastCheckForUpdates;

/**
 *  Блок, который вызывается в конце проверки обновлений.
 */
@property (nonatomic, copy) void (^checkCompletionHandler)(ColoredVKUpdatesModel *model);

@property (assign, nonatomic) BOOL checkedAutomatically;

/**
 *  Инициализирует алгоритм проверки обновлений, показывает алерт, если найдено обновление и вызывает checkCompletionHandler
 */
- (void)checkUpdates;

@end
