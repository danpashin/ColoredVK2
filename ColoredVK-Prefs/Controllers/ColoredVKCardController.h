//
//  ColoredVKCardController.h
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import <UIKit/UIKit.h>
#import "ColoredVKCard.h"

@interface ColoredVKCardController : UIViewController

- (void)addCard:(ColoredVKCard *)card;
- (void)addCards:(NSArray <ColoredVKCard *> *)cards;

- (void)dismiss;

@end
