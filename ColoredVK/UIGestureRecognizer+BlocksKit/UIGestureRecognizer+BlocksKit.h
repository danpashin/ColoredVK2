//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

//#import "BKDefines.h"
#import <UIKit/UIKit.h>

#if !defined(BK_INITIALIZER)
# if __has_attribute(objc_method_family)
#  define BK_INITIALIZER __attribute__((objc_method_family(init)))
# else
#  define BK_INITIALIZER
# endif
#endif

NS_ASSUME_NONNULL_BEGIN

/** Block functionality for UIGestureRecognizer.

 Use of the delay property is pretty straightforward, although
 cancellation might be a little harder to swallow.  An example
 follows:
	 UITapGestureRecognizer *singleTap = [UITapGestureRecognizer recognizerWithHandler:^(id sender) {
		 NSLog(@"Single tap.");
	 } delay:0.18];
	 [self addGestureRecognizer:singleTap];
 
	 UITapGestureRecognizer *doubleTap = [UITapGestureRecognizer recognizerWithHandler:^(id sender) {
		[singleTap cancel];
		NSLog(@"Double tap.");
	 }];
	 doubleTap.numberOfTapsRequired = 2;
	 [self addGestureRecognizer:doubleTap];

 Believe it or not, the above code is fully memory-safe and efficient.  Eagle-eyed coders
 will notice that this setup emulates UIGestureRecognizer's requireGestureRecognizerToFail:,
 and, yes, it totally apes it.  Not only is this setup much faster on the user's end of
 things, it is more flexible and allows for much more complicated setups.

 Includes code by the following:

 - [Kevin O'Neill](https://github.com/kevinoneill)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @warning UIGestureRecognizer is only available on a platform with UIKit.
 
 @warning It is not recommended to use the Apple-supplied locationInView and state
 methods on a *delayed* block-backed gesture recognizer, as these properties are
 likely to have been cleared by the time by the block fires.  It is instead recommended
 to use the arguments provided to the block.
 */

@interface UIGestureRecognizer (BlocksKit)

/** An autoreleased gesture recognizer that will call the given block.
 
 For convenience and compatibility reasons, this method is indentical
 to using recognizerWithHandler:delay: with a delay of 0.0.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer
 subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (instancetype)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender))block;

/** Initializes an allocated gesture recognizer that will call the given block.
 
 This method is indentical to calling initWithHandler:delay: with a delay of 0.0.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (instancetype)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender))block BK_INITIALIZER;

/** Allows the block that will be fired by the gesture recognizer
 to be modified after the fact.
 */
@property (nonatomic, copy, setter = bk_setHandler:, nullable) void (^bk_handler)(UIGestureRecognizer *sender);

/** If the recognizer happens to be fired, calling this method
 will stop it from firing, but only if a delay is set.

 @warning This method is not for arbitrarily canceling the
 firing of a recognizer, but will only function for a block
 handler *after the recognizer has already been fired*.  Be
 sure to make your delay times accomodate this likelihood.
 */
- (void)bk_cancel;

@end

NS_ASSUME_NONNULL_END
