#import <UIKit/UIKit.h>

static void applyTabBarStyle(UITabBar *tabBar) {
    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.backgroundColor = UIColor.clearColor;
    tabBar.clipsToBounds = NO;

    for (UIView *sub in tabBar.subviews) {
        if (sub.bounds.size.height < 3 || [sub isKindOfClass:[UIVisualEffectView class]]) {
            sub.hidden = YES;
        }
    }

    CGRect frame = UIEdgeInsetsInsetRect(tabBar.bounds, UIEdgeInsetsMake(0, 20, 20, 20));
    CGFloat radius = 24;

    UIBlurEffect *blur;
    if (@available(iOS 13, *)) {
        if (tabBar.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
        } else {
            blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialLight];
        }
    } else {
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }

    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
    glass.frame = frame;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.layer.cornerRadius = radius;
    glass.layer.masksToBounds = YES;
    glass.userInteractionEnabled = NO;

    glass.layer.shadowColor = UIColor.blackColor.CGColor;
    glass.layer.shadowOpacity = 0.3;
    glass.layer.shadowRadius = 12;
    glass.layer.shadowOffset = CGSizeMake(0, 6);

    for (UIView *v in tabBar.subviews) {
        if ([v isKindOfClass:[UIVisualEffectView class]]) {
            [v removeFromSuperview];
        }
    }
    [tabBar insertSubview:glass atIndex:0];
}

static void traverseViews(UIView *view) {
    if (!view) return;
    if ([view isKindOfClass:[UITabBar class]]) {
        applyTabBarStyle((UITabBar *)view);
    }
    for (UIView *sub in view.subviews) traverseViews(sub);
}

%ctor {
    if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.tencent.xinWeChat"]) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    traverseViews(window);
                }
            }
        }
    });
}
