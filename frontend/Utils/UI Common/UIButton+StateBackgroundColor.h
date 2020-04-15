#import <UIKit/UIKit.h>

@interface UIButton (StateBackgroundColor)

@property (nonatomic, strong, nullable) IBInspectable UIColor *disabledStateBackgroundColor;
@property (nonatomic, strong, nullable) IBInspectable UIColor *highlightedStateBackgroundColor;
@property (nonatomic, strong, nullable) IBInspectable UIColor *selectedStateBackgroundColor;
@property (nonatomic, strong, nullable) IBInspectable UIColor *normalStateBackgroundColor;

@end
