//
//  ColoredVKScrollViewController.h
//  ColoredVK2
//
//  Created by Даниил on 01/02/2018.
//

#import <UIKit/UIKit.h>

@interface ColoredVKScrollViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

/*
 *  По умолчанию возвращает YES.
 */
@property (assign, nonatomic, readonly) BOOL controllerShouldPop;

@property (strong, nonatomic) NSBundle *cvkBundle;

@end
