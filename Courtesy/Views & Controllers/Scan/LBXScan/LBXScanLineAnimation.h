#import <UIKit/UIKit.h>

@interface LBXScanLineAnimation : UIImageView
- (void)startAnimatingWithRect:(CGRect)animationRect
                        InView:(UIView*)parentView
                         Image:(UIImage*)image;
- (void)stopAnimating;

@end
