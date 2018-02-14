//
//  ColoredVKCard.h
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ColoredVKCard : NSObject

/**
 *  Устанавливает текст заголовка в карточке. Может быть nil
 */
@property (copy, nonatomic, nullable) NSString *title;
/**
 *  Устанавливает цвет текста заголовка. По умолчанию белый
 */
@property (strong, nonatomic, null_resettable) UIColor *titleColor;

/**
 *  Устанавливает аттрибутированый текст тела карточки. Может быть nil
 */
@property (copy, nonatomic, nullable) NSAttributedString *attributedBody;


/**
 *  Устанавливает простой текст для кнопки внизу. Может быть nil
 */
@property (copy, nonatomic, nullable) NSString *buttonText;
/**
 *  Устанавливает цвет текста и границ для кнопки внизу. По умолчанию RGB 248 148 6
 */
@property (strong, nonatomic, null_resettable) UIColor *buttonTintColor;

/**
 *  Устанавливает цель для кнопки. По умолчанию nil
 */
@property (weak, nonatomic, nullable) id buttonTarget;
/**
 *  Устанавливает селектор для кнопки. По умолчанию nil
 */
@property (assign, nonatomic, nullable) SEL buttonAction;


/**
 *  Устанавливает фоновый цвет для карточки. По умолчанию белый
 */
@property (strong, nonatomic, null_resettable) UIColor *backgroundColor;

/**
 *  Устанавливают фоновое изображение и его прозрачность. По умолчанию nil
 */
@property (strong, nonatomic, nullable) UIImage *backgroundImage;
/**
 *  Устанавливает прозрачность фонового изображения. По умолчанию 0.5
 */
@property (assign, nonatomic) CGFloat backgroundImageAlpha;

@end
