#import <UIKit/UIKit.h>

@interface UIImageView (Caches)

@end

@interface DynamicScrollView : UIView



@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) NSMutableArray *images;
@property(nonatomic,strong) NSMutableArray *imageAll;
@property(nonatomic,strong) NSMutableArray *imageViews;

@property(nonatomic,assign) BOOL isDeleting;
@property(nonatomic,assign) BOOL justView;


@property (nonatomic, copy) void (^selectedAtIndex)(int index);

- (id)initWithFrame:(CGRect)frame withImages:(NSMutableArray *)images;
//添加一个新图片
- (void)setImagesNow:(NSArray *)images isORG:(BOOL) isORG;
- (void)addImageView:(NSString *)imageName;
- (void)addTagert:(id) target andExtrendAction :(SEL) action tag:(NSInteger) tag andImage:(NSString *) imageName;
- (NSMutableArray*)getImagesAll;

@end
