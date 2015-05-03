/*!
 @header	TBCSliderReturnController.m
 @abstract	滑动返回
 @discussion
 @author	dequan
 @copyright	baidu
 @version	4.0.0 2013-03-18 21:44:15 Creation
 */

#import "TBCSliderReturnController.h"
#import "UIView+IDPExtension.h"

//返回上一个视图移动的距离
#define TB_PB_MOVELENGHT 100

@interface TBCSliderReturnController()

@property (nonatomic, retain) UIImageView *lastScreenShotView;
@property (nonatomic, retain) UIView *mongoliaLayerView;
@property (nonatomic, retain) UIView *lastBackGroudView;
@property (nonatomic, assign) CGPoint firstTouchPoint;
@property (nonatomic, retain) UIPanGestureRecognizer *slidGesture;
@property (nonatomic, assign) UINavigationController *iNvigationController;

/*!
 @method
 @abstract	屏幕截图
 @discussion
 @result	返回截图的image
 */
- (UIImage *)screenShot;

@end

@implementation TBCSliderReturnController
@synthesize lastScreenShotView;
@synthesize mongoliaLayerView;
@synthesize lastBackGroudView;
@synthesize firstTouchPoint;
@synthesize slidGesture;
@synthesize iNvigationController;


//析构函数
- (void)dealloc
{
    self.lastBackGroudView = nil;
    self.lastScreenShotView = nil;
    self.mongoliaLayerView = nil;
    self.slidGesture = nil;
    self.navigationBar = nil;
    _navgationBarImage = nil;
}

//初始化方法
- (id)init
{
  if (self = [super init])
  {
    self.slidGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slidPBView:)];
    self.slidGesture.delegate = self;
  }
  return self;
}


//截取顶部navigtaionbar
- (void)screenShotTop
{
    CGSize imageSize = self.navigationBar.size;
    if (NULL != /* DISABLES CODE */ (/* DISABLES CODE */ (&UIGraphicsBeginImageContextWithOptions)))
    {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(context, 0, self.navigationBar.y);
    //CGContextConcatCTM(context, [self.navigationBar transform]);
    [[self.navigationBar layer] renderInContext:context];
    
    _navgationBarImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

}
//上一个视图截屏
- (void)startLastViewScreenShot
{
  //截取上个viewcontroller的截图
  self.lastScreenShotView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.lastScreenShotView.image = [self screenShot];
  
  
  self.mongoliaLayerView = [[UIView alloc] initWithFrame:self.lastScreenShotView.bounds];
  self.mongoliaLayerView.backgroundColor = [UIColor blackColor];
  self.mongoliaLayerView.alpha = 0.5f;
  
  self.lastBackGroudView = [[UIView alloc] initWithFrame:self.lastScreenShotView.frame];
  self.lastBackGroudView.backgroundColor = [UIColor blackColor];
  [self.lastBackGroudView addSubview:self.lastScreenShotView];
  [self.lastBackGroudView addSubview:self.mongoliaLayerView];
  
  self.lastScreenShotView.transform = CGAffineTransformMakeScale(0.95f,0.95f);
}

//添加滑动视图
- (void)addSlidAnimationView
{
  UIView *backView = self.iNvigationController.view;
  if (!self.lastBackGroudView.superview)
  {
    [backView.superview insertSubview:self.lastBackGroudView belowSubview:backView];
  }
}

//移除滑动视图
- (void)removeSlidAnimationView
{
  self.iNvigationController.view.frame = [UIScreen mainScreen].bounds;
  [self.lastBackGroudView removeFromSuperview];
}

//添加滑动手势
- (void)addPanGestureTo:(UIView *)aView andNavigationController:(UINavigationController *)aNavigationController
{
  self.iNvigationController = aNavigationController;
  [aView addGestureRecognizer:self.slidGesture];
}
#pragma mark -
#pragma mark - TBCSliderReturnController() methods

//视图的截屏
- (UIImage *)screenShot
{
  CGSize imageSize = [[UIScreen mainScreen] bounds].size;
  if (NULL != &UIGraphicsBeginImageContextWithOptions)
  {
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
  }
  else
  {
    UIGraphicsBeginImageContext(imageSize);
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, imageSize.height - self.viewInBackGround.height);
  CGContextConcatCTM(context, [self.viewInBackGround transform]);
  [[self.viewInBackGround layer] renderInContext:context];
  CGContextRestoreGState(context);
 
//  CGContextTranslateCTM(context, [self.navigationBar center].x, [self.navigationBar center].y);
    CGContextTranslateCTM(context, 0, imageSize.height - self.viewInBackGround.height );
  CGContextConcatCTM(context, [self.navigationBar transform]);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextDrawImage(context,self.navigationBar.bounds,_navgationBarImage.CGImage);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  return image;
}




//滑动手势处理
- (void)slidPBView:(UIPanGestureRecognizer*)aGestureRecognizer
{
  CGPoint point = [aGestureRecognizer locationInView:self.iNvigationController.view.window];
  CGFloat distance = point.x - self.firstTouchPoint.x;
  switch (aGestureRecognizer.state)
  {
    case UIGestureRecognizerStateChanged:
    {
      if (distance < 0)
      {
        return;
      }
      
      CGRect frame = self.iNvigationController.view.frame;
      frame.origin.x = distance;
      self.iNvigationController.view.frame = frame;
      
      CGRect lastScreenFrame = [[UIScreen mainScreen] bounds];
      CGFloat increment = 0.05f*distance/320;
      CGAffineTransform lastScreenTransform = CGAffineTransformMakeScale(0.95f+increment,0.95f+increment);
      CGRect currentLastFrame = CGRectApplyAffineTransform(lastScreenFrame,lastScreenTransform);
      self.lastScreenShotView.frame = currentLastFrame;
      self.lastScreenShotView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,
                                               [[UIScreen mainScreen] bounds].size.height/2);
      
      self.mongoliaLayerView.alpha = 0.5f - 0.5f*distance/320;
    }
      break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
    case UIGestureRecognizerStateFailed:
    {
      if (distance < TB_PB_MOVELENGHT)
      {
        
        [UIView animateWithDuration:distance/450.0f
                         animations:^{
                           self.lastScreenShotView.transform = CGAffineTransformMakeScale(0.95f,0.95f);
                           
                           CGRect frame = self.iNvigationController.view.frame;
                           frame.origin.x = 0;
                           self.iNvigationController.view.frame = frame;
                           
                           self.mongoliaLayerView.alpha = 0.5f;
                         }
                         completion:^(BOOL isFinished){
                           [self removeSlidAnimationView];
                         }];
      }
      else
      {
        [UIView animateWithDuration:(320 -distance)/450.0f
                         animations:^{
                           self.lastScreenShotView.frame = [UIScreen mainScreen].bounds;
                           
                           CGRect frame = self.iNvigationController.view.frame;
                           frame.origin.x = 320;
                           self.iNvigationController.view.frame = frame;
                           
                           self.mongoliaLayerView.alpha = 0.0f;
                         }
                         completion:^(BOOL isFinished){
                             
                             if (_target && _cleanSelector) {
                                 [_target performSelector:_cleanSelector];
                             }
                           [self.iNvigationController popViewControllerAnimated:NO];
                           
                           [self removeSlidAnimationView];
                         }];
      }
      
    }
      break;
    default:
      break;
  }
}
-(void)addCleanSelector:(SEL)sel target:(id)target
{
    _target =target;
    _cleanSelector = sel;
}
#pragma mark -
#pragma mark - UIGestureRecognizerDelegate methods
//是否手势开始
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
  {
    return NO;
  }
  UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
  CGPoint speedPoint = [panGestureRecognizer velocityInView:gestureRecognizer.view];
  if (fabs(speedPoint.x)> fabs(speedPoint.y))
  {
    CGPoint point = [gestureRecognizer locationInView:self.iNvigationController.view.window];
    self.firstTouchPoint = point;
    [self addSlidAnimationView];
    
    return YES;
  }
  else
  {
    return NO;
  }
}

@end
