/*!
 @header	TBCSliderReturnController.h
 @abstract	滑动返回
 @discussion
 @author	dequan
 @copyright	baidu
 @version	4.0.0 2013-03-18 21:44:15 Creation
 */

#import <Foundation/Foundation.h>


@interface TBCSliderReturnController : NSObject<UIGestureRecognizerDelegate>
{
    id       _target;
    SEL      _cleanSelector;
}

@property UIImage* navgationBarImage;


/*!
 @method
 @abstract	上一个视图截屏
 @discussion
 */
- (void)startLastViewScreenShot;

/*!
 @method
 @abstract	添加滑动视图
 @discussion
 */
- (void)addSlidAnimationView;

/*!
 @method
 @abstract  移除滑动视图
 @discussion
 */
- (void)removeSlidAnimationView;

/*!
 	@method
 	@abstract	view添加滑动手势
 	@discussion
 	@param 	aView 	要添加手势的view
  @param  aNavigationController 导航站
 */
- (void)addPanGestureTo:(UIView *)aView andNavigationController:(UINavigationController *)aNavigationController;

//截取顶部
- (void)screenShotTop;

//增加资源清理的selector
-(void)addCleanSelector:(SEL)sel target:(id)target;

//背景View
@property (nonatomic,assign) UIView* viewInBackGround;
@property (nonatomic,assign) UINavigationBar* navigationBar;
@end
