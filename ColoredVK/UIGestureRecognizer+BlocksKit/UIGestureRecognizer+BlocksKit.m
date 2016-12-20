//
//  UIGestureRecognizer+BlocksKit.m
//  BlocksKit
//

#import "UIGestureRecognizer+BlocksKit.h"
#import <objc/runtime.h>

static const void *BKGestureRecognizerBlockKey = &BKGestureRecognizerBlockKey;
static const void *BKGestureRecognizerShouldHandleActionKey = &BKGestureRecognizerShouldHandleActionKey;

@interface UIGestureRecognizer (BlocksKitInternal)

@property (nonatomic, setter = bk_setShouldHandleAction:) BOOL bk_shouldHandleAction;

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlocksKit)

+ (instancetype)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender))block
{
	return [[self alloc] bk_recognizerWithHandler:block];
}

- (instancetype)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender))block
{
    self = [self initWithTarget:self action:@selector(bk_handleAction:)];
    if (!self) return nil;
    
    self.bk_handler = block;
    
    return self;
}

- (void)bk_handleAction:(UIGestureRecognizer *)recognizer
{
	void (^handler)(UIGestureRecognizer *sender) = recognizer.bk_handler;
	if (!handler) return;
	
	void (^block)(void) = ^{
		if (!self.bk_shouldHandleAction) return;
		handler(self);
	};

	self.bk_shouldHandleAction = YES;
    
    block();
}

- (void)bk_setHandler:(void (^)(UIGestureRecognizer *sender))handler
{
	objc_setAssociatedObject(self, BKGestureRecognizerBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIGestureRecognizer *sender))bk_handler
{
	return objc_getAssociatedObject(self, BKGestureRecognizerBlockKey);
}

- (void)bk_setShouldHandleAction:(BOOL)flag
{
	objc_setAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey, @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)bk_shouldHandleAction
{
	return [objc_getAssociatedObject(self, BKGestureRecognizerShouldHandleActionKey) boolValue];
}

- (void)bk_cancel
{
	self.bk_shouldHandleAction = NO;
}

@end
