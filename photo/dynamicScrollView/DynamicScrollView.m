    //
//  DynamicScrollView.m
//  MeltaDemo
//
//  Created by hejiangshan on 14-8-27.
//  Copyright (c) 2014年 hejiangshan. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "DynamicScrollView.h"
#import "UIImageView+WebCache.h"


@implementation UIImageView (Caches)

- (void)setImageWithCaches:(id)image
{

    if([image isKindOfClass:[UIImage class]])
    {
        [self setImage:image];
    }
    else if ([image isKindOfClass:[NSString class]]){
    
        NSString *imageUrl = image;
        
        if([image hasPrefix:@"http"]){
            
            [self sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"zhanwei"]];
        }
        else{
           
        }
        
    }
    else{
       
    }

}

@end


@interface DynamicScrollView ()



@end

@implementation DynamicScrollView

{
    float width;
    float height;
    NSMutableArray *imageViews;
    float singleWidth;
    BOOL isDeleting;
    CGPoint startPoint;
    CGPoint originPoint;
    BOOL isContain;
    NSMutableArray *imagesAll;
    UIImageView *tap;
    UIButton *actionButton;
}

@synthesize scrollView,imageViews,isDeleting;


- (void)setJustView:(BOOL)justView
{
    if (justView) {
        
        tap.hidden = YES;
        actionButton.enabled = NO;
        actionButton.hidden = YES;
        
    }else{
        tap.hidden = NO;
        actionButton.hidden = NO;
        actionButton.enabled = YES;
    }
}

- (void)addTagert:(id) target andExtrendAction :(SEL) action tag:(NSInteger) tag andImage:(NSString *) imageName
{
    imageName ? [tap setImage:[UIImage imageNamed:imageName]] : nil;
    [actionButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTag:tag];
    [tap setHidden:NO];
    [actionButton setHidden:NO];
}

- (void)setImagesNow:(NSArray *)images isORG:(BOOL)isORG
{
    if(isORG)
    {
        for (UIImageView* imageV in imageViews) {
            [imageV removeFromSuperview];
        }
        [imageViews removeAllObjects];
        [imagesAll removeAllObjects];
    }
    
    if(images == nil){
        [self updateContentView:0];
        return;
    }
    
    if(imageViews == nil){
        imageViews = [[NSMutableArray alloc]init];
    }
    
    NSInteger ogCount = imagesAll.count;
    [imagesAll addObjectsFromArray:images];
   
    [self updateContentView:imagesAll.count + images.count + 1];
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setClipsToBounds:YES];
    
    for(int i = 0;i < images.count;i++)
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake( 10 + ( i + ogCount ) * (self.bounds.size.height + 5.0f), 4, self.scrollView.bounds.size.height - 5, self.scrollView.bounds.size.height - 5)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self updateContentView:(NSInteger)imagesAll.count];
        [imageView setClipsToBounds:YES];
        [imageView setImageWithCaches: images[i]];
        imageView.tag = 888+i;
        [self.scrollView addSubview:imageView];
        [imageView setUserInteractionEnabled:YES];
        [imageViews addObject:imageView];
        
        UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tapPress];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
        [imageView addGestureRecognizer:longPress];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"deletbutton"] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"deletbutton"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (isDeleting) {
            [deleteButton setHidden:NO];
        } else {
            [deleteButton setHidden:YES];
        }
        deleteButton.frame = CGRectMake(imageView.bounds.size.width - 18, 3, 15, 15);
        [imageView addSubview:deleteButton];
    }
}
- (void)tapAction:(UITapGestureRecognizer *)tapx{
    NSInteger aa = tapx.view.tag - 888;
    self.selectedAtIndex((int)aa);
}

- (void)updateContentView:(NSInteger) offset
{
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        self.scrollView.contentSize = CGSizeMake(10 + (offset + 2) * (self.bounds.size.height + 5.0f), self.bounds.size.height - 5);
        tap.center = CGPointMake(10 + (offset + 0.5f)  * (self.bounds.size.height + 5.0f), self.scrollView.contentSize.height / 2.0f + 2);

    }else{
         self.scrollView.contentSize = CGSizeMake(10 + (offset + 1) * (self.bounds.size.height + 5.0f), self.bounds.size.height - 5);
        tap.center = CGPointMake(10 + (offset + 0.5f)  * (self.bounds.size.height + 5.0f), self.scrollView.contentSize.height / 2.0f + 2);

    }
   
    }

- (id)initWithFrame:(CGRect)frame withImages:(NSMutableArray *)images
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScreen *screen = [UIScreen mainScreen];
        width = screen.bounds.size.width;
        height = screen.bounds.size.height;
        imagesAll = [[NSMutableArray alloc]init];
        
        if (self.scrollView == nil) {
            
            self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 2, self.bounds.size.width, self.bounds.size.height - 4.0f)];
            
            [self addSubview:self.scrollView];
            
            [self.scrollView setShowsHorizontalScrollIndicator:NO];
            tap = [[UIImageView alloc]initWithFrame:CGRectMake(2, 4, self.scrollView.bounds.size.height - 5, self.scrollView.bounds.size.height - 5)];
            
            actionButton = [[UIButton alloc]initWithFrame:tap.bounds];
//            [actionButton setTitle:@"添加照片" forState:UIControlStateNormal];
            actionButton.titleLabel.font = [UIFont systemFontOfSize:11];
            [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            actionButton.titleEdgeInsets = UIEdgeInsetsMake(0  , 0, -(self.scrollView.bounds.size.height - 5)/2+2, 0);
            [tap addSubview:actionButton];
            [tap setImage:[UIImage imageNamed:@"tianjiafabu"]];
            [tap setUserInteractionEnabled:YES];
            [self.scrollView addSubview:tap];
    
        }
        isDeleting = YES;
        
    }
    return self;
}

- (void)_initScrollView
{
    if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
      
    }
}

- (void)_initViewsByName:(BOOL) byImage
{
    for (int i = 0; i < self.images.count; i++) {
        NSString *imageName = self.images[i];
        [self createImageViews:i withImageName:imageName];
    }
    if ([UIScreen mainScreen].bounds.size.width == 320) {
       self.scrollView.contentSize = CGSizeMake((self.images.count+2) * singleWidth, self.scrollView.frame.size.height);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.images.count * singleWidth, self.scrollView.frame.size.height);
    }
    
}

- (void)createImageViews:(NSInteger)i withImageName:(NSString *)imageName
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgView.frame = CGRectMake(singleWidth * i,0, singleWidth, self.scrollView.frame.size.height);
    imgView.userInteractionEnabled = YES;
    [self.scrollView addSubview:imgView];
    [imageViews addObject:imgView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    [imgView addGestureRecognizer:longPress];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"deletbutton.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    if (isDeleting) {
        [deleteButton setHidden:NO];
    } else {
        [deleteButton setHidden:YES];
    }
    deleteButton.frame = CGRectMake(0, 0, 25, 25);
    deleteButton.backgroundColor = [UIColor clearColor];
    [imgView addSubview:deleteButton];
}

//长按调用的方法
- (void)longAction:(UILongPressGestureRecognizer *)recognizer
{
    UIImageView *imageView = (UIImageView *)recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan) {//长按开始
        startPoint = [recognizer locationInView:recognizer.view];
        originPoint = imageView.center;
//        isDeleting = !isDeleting;
        [UIView animateWithDuration:0.3 animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
        for (UIImageView *imageView in imageViews) {
            UIButton *deleteButton = (UIButton *)imageView.subviews[0];
            if (isDeleting) {
                deleteButton.hidden = NO;
            } else {
                deleteButton.hidden = YES;
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {//长按移动
        CGPoint newPoint = [recognizer locationInView:recognizer.view];
        CGFloat deltaX = newPoint.x - startPoint.x;
        CGFloat deltaY = newPoint.y - startPoint.y;
        imageView.center = CGPointMake(imageView.center.x + deltaX, imageView.center.y + deltaY);
        NSInteger index = [self indexOfPoint:imageView.center withView:imageView];
        if (index < 0) {
            isContain = NO;
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                CGPoint temp = CGPointZero;
                UIImageView *currentImagView = imageViews[index];
                NSInteger idx = [imageViews indexOfObject:imageView];
                temp = currentImagView.center;
                currentImagView.center = originPoint;
                imageView.center = temp;
                originPoint = imageView.center;
                isContain = YES;
                [imageViews exchangeObjectAtIndex:idx withObjectAtIndex:index];
            } completion:^(BOOL finished) {
            }];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {//长按结束
        [UIView animateWithDuration:0.3 animations:^{
            imageView.transform = CGAffineTransformIdentity;
            if (!isContain) {
                imageView.center = originPoint;
            }
        }];
    }
}

//获取view在imageViews中的位置
- (NSInteger)indexOfPoint:(CGPoint)point withView:(UIView *)view
{
    UIImageView *originImageView = (UIImageView *)view;
    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *otherImageView = imageViews[i];
        if (otherImageView != originImageView) {
            if (CGRectContainsPoint(otherImageView.frame, point)) {
                return i;
            }
        }
    }
    return - 1;
}

- (void)deleteAction:(UIButton *)button
{
    isDeleting = YES;   //正处于删除状态
    
    UIImageView *imageView = (UIImageView *)button.superview;
   
    __block NSInteger index = [imageViews indexOfObject:imageView];
    
    if(index >= 0){
        [imagesAll removeObjectAtIndex:index];
    }
    
    __block CGRect rect = imageView.frame;
    __block UIScrollView *weakScroll = scrollView;
    
    [UIView animateWithDuration:0.3f animations:^{
        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
    
        [imageView removeFromSuperview];
        [imageViews removeObject:imageView];
        [UIView animateWithDuration:0.3f animations:^{
            
            for (NSInteger i = index; i < imageViews.count; i++) {
        
                UIImageView *otherImageView = imageViews[i];
                CGRect originRect = otherImageView.frame;
                otherImageView.frame = rect;
                rect = originRect;
                [otherImageView setFrame:CGRectMake(10 + i * (self.bounds.size.height + 5.0f), 4, self.scrollView.bounds.size.height - 5, self.scrollView.bounds.size.height - 5)];
                
            }
            
        } completion:^(BOOL finished) {
            
            if (imageViews.count > 4) {
                [weakScroll setContentSize:CGSizeMake(10 + imagesAll.count * (self.bounds.size.height + 5.0f), self.bounds.size.height - 5)];
            }
            [self updateContentView:(NSInteger)imagesAll.count];
            self.justView = NO;
            
        }];
        
    }];
    
}

//添加一个新图片
- (void)addImageView:(NSString *)imageName
{
    [self createImageViews:imageViews.count withImageName:imageName];
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        self.scrollView.contentSize = CGSizeMake(singleWidth * (imageViews.count+2), self.scrollView.frame.size.height);
    }else{
         self.scrollView.contentSize = CGSizeMake(singleWidth * imageViews.count, self.scrollView.frame.size.height);
    }
   
    if (imageViews.count > 4) {
        [self.scrollView setContentOffset:CGPointMake((imageViews.count - 4) * singleWidth, 0) animated:YES];
    }
}

- (NSMutableArray*)getImagesAll
{
    return imagesAll;
}

@end
