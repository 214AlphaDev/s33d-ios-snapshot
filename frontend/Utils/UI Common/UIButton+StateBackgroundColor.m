#import "UIButton+StateBackgroundColor.h"
#import <objc/runtime.h>

@implementation UIButton (StateBackgroundColor)

static char * const kHighlightedStateBackgroundColorKey = "HighlighteddStateBackgroundColorKey";
static char * const kSelectedStateBackgroundColorKey = "SelectedStateBackgroundColorKey";
static char * const kNormalStateBackgroundColorKey = "NormalStateBackgroundColorKey";
static char * const kDisabledStateBackgroundColorKey = "DisabledStateBackgroundColorKey";

- (void)setHighlightedStateBackgroundColor:(UIColor *)highlightedStateBackgroundColor {
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    objc_setAssociatedObject(self, &kHighlightedStateBackgroundColorKey, highlightedStateBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)highlightedStateBackgroundColor {
    return objc_getAssociatedObject(self, &kHighlightedStateBackgroundColorKey);
}

- (void)setSelectedStateBackgroundColor:(UIColor *)selectedStateBackgroundColor {
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    objc_setAssociatedObject(self, &kSelectedStateBackgroundColorKey, selectedStateBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)selectedStateBackgroundColor {
    return objc_getAssociatedObject(self, &kSelectedStateBackgroundColorKey);
}

- (void)setNormalStateBackgroundColor:(UIColor *)normalStateBackgroundColor {
    objc_setAssociatedObject(self, &kNormalStateBackgroundColorKey, normalStateBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)normalStateBackgroundColor {
    return objc_getAssociatedObject(self, &kNormalStateBackgroundColorKey);
}

- (void)setDisabledStateBackgroundColor:(UIColor *)disabledStateBackgroundColor {
    [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    objc_setAssociatedObject(self, &kDisabledStateBackgroundColorKey, disabledStateBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)disabledStateBackgroundColor {
    return objc_getAssociatedObject(self, &kDisabledStateBackgroundColorKey);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    UIColor *finishColor = self.normalStateBackgroundColor;
    if (!self.enabled) {
        finishColor = self.disabledStateBackgroundColor;
    } else if (self.selected) {
        finishColor = self.selectedStateBackgroundColor;
    } else if (self.highlighted) {
        finishColor = self.highlightedStateBackgroundColor;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = finishColor;
    }];
}

- (void)dealloc {
    if (self.disabledStateBackgroundColor) {
        [self removeObserver:self forKeyPath:@"enabled"];
    }
    if (self.selectedStateBackgroundColor) {
        [self removeObserver:self forKeyPath:@"selected"];
    }
    if (self.highlightedStateBackgroundColor) {
        [self removeObserver:self forKeyPath:@"highlighted"];
    }
}

@end
