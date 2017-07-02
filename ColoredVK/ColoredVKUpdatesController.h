//
//  ColoredVKUpdatesController.h
//  ColoredVK2
//
//  Created by Даниил on 02.07.17.
//
//

#import <Foundation/Foundation.h>


@interface ColoredVKUpdatesController : NSObject

/**
 *  Defines, if alert with API error should be shown.
 *
 *  --
 *
 *  Определяет, должен ли быть показан алерт с ошибкой API.
 */
@property (assign, nonatomic) BOOL showErrorAlert;

/**
 *  Returns YES, if the tweak version is a beta version, user installed tweak just now, or checking updates is enabled.
 *
 *  --
 *
 *  Возвращает YES, если версия твика является бета-версией, пользователь установил твик только что или включена проверка обновлений.
 */
@property (assign, nonatomic, readonly) BOOL shouldCheckUpdates;

/**
 *  Returns localised time of the last update check.
 *
 *  --
 *
 *  Возвращает локализованное время последней проверки обновлений.
 */
@property (nonatomic, copy, readonly) NSString *localizedLastCheckForUpdates;

/**
 *  Block, which calls in the end of updates checking.
 *
 *  --
 *
 *  Блок, который вызывается в конце проверки обновлений.
 */
@property (nonatomic, copy) void (^checkCompletionHandler)(ColoredVKUpdatesController *controller);

/**
 *  Initializes updates checking algorithm, shows alert if update was found, and calles checkCompletionHandler.
 *
 *  --
 *
 *  Инициализирует алгоритм проверки обновлений, показывает алерт, если найдено обновление и вызывает checkCompletionHandler
 */
- (void)checkUpdates;

@end
