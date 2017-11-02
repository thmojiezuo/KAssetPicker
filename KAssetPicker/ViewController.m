//
//  ViewController.m
//  KAssetPicker
//
//  Created by tenghu on 2017/10/28.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import "ViewController.h"
#import "DynamicScrollView.h"
#import "ZYQAssetPickerController.h"
#import "VPImageCropperViewController.h"
#import "UIImage+FixOrientation.h"
#import "SDPhotoBrowser.h"

typedef NS_ENUM(NSInteger, IMGStandard) {
    
    iconIMG = 0,
    IDCardIMG = 1,
    IMG43 = 2
};
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,VPImageCropperDelegate,ZYQAssetPickerControllerDelegate,SDPhotoBrowserDelegate>
{
    NSMutableArray *_imgeArray; //票据图片数组
    NSMutableArray *_imPhotoArr;
}
@property(nonatomic,strong)  DynamicScrollView *photoScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _imgeArray = [[NSMutableArray alloc] init];
    _imPhotoArr = [[NSMutableArray alloc] init];
    //添加图片
    _photoScrollView = [[DynamicScrollView alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width-20, 70) withImages:nil];
    [_photoScrollView addTagert:self andExtrendAction:@selector(addPic:) tag:600 andImage:nil];
    
    __weak typeof(self)weakSelf = self;
    [_photoScrollView setSelectedAtIndex:^(int index) {
        
        [weakSelf getPhotoS:index];
        
    }];
    
    [self.view addSubview:_photoScrollView];
    
    
}
#pragma mark - 展示图片
- (void)getPhotoS:(NSInteger)index{
    [_imPhotoArr removeAllObjects];
    
    NSMutableArray *imArr  = [[NSMutableArray alloc] init];
    NSMutableArray * mutiArr2 = [_photoScrollView getImagesAll];
    for (id object in mutiArr2) {
        if ([object isKindOfClass:[UIImage class]]) {
            [imArr addObject:object];
            [_imPhotoArr addObject:object];
        }else{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:object]];
            UIImage *image = [UIImage imageWithData:data];
            [imArr addObject:image];
            [_imPhotoArr addObject:image];
        }
    }
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = _photoScrollView.scrollView;
    browser.imageCount = imArr.count;
    browser.currentImageIndex = index;
    browser.delegate = self;
    [browser show];
    
}
#pragma mark 上传票据
- (void)addPic:(UIButton*)sender {
    
    [self.view endEditing:YES];
    
    if([self getSelectedImageCountWithTag:sender.tag] >=5){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"图片数量不能大于五张" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    UIActionSheet * ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
    
    ac.tag = sender.tag;
    [ac setDelegate:self];
    [ac showInView:self.view];
    
}
-(NSInteger) getSelectedImageCountWithTag:(NSInteger) tag{
    
    return self.photoScrollView?self.photoScrollView.imageViews.count:0;
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
    {
        return;
    }
    if(buttonIndex == 0){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        [picker setSourceType: (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ])? UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        picker.view.tag = actionSheet.tag;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (buttonIndex == 1){
        
        
        [self mutiPics:actionSheet.tag];
    }
}
-(void) mutiPics:(NSInteger) tag{
    ZYQAssetPickerController *_picker= [[ZYQAssetPickerController alloc] init];
    
    [_picker setTag:tag];
    
    _picker.maximumNumberOfSelection =tag==99?1:5-[self getSelectedImageCountWithTag:tag];
    
    _picker.assetsFilter = [ALAssetsFilter allPhotos];
    _picker.showEmptyGroups=NO;
    _picker.delegate1=self;
    _picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    [self presentViewController:_picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        /*   VPImageCropperViewController * vpCrop = [[VPImageCropperViewController alloc]initWithImage:[UIImage fixOrientation:(UIImage *)[info objectForKey:@"UIImagePickerControllerOriginalImage"]] cropFrame:[self standardizedIconIMGRectWithType:IMG43] limitScaleRatio:3.0f];
         vpCrop.tag = picker.view.tag;
         
         vpCrop.delegate = self;
         [self presentViewController:vpCrop animated:YES completion:nil];
         */
        
        UIImage * edited = [UIImage fixOrientation:(UIImage *)[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
        
        [_imgeArray removeAllObjects];
        
        [_imgeArray addObject:edited];
        
        if (picker.view.tag == 600) {
            [self.photoScrollView setImagesNow:_imgeArray isORG:NO];
            if(self.photoScrollView.imageViews.count == 5){
                self.photoScrollView.justView = YES;
            }
            
        }
        
        
        
    }];
    
}
-(CGRect)standardizedIconIMGRectWithType:(IMGStandard) imgType
{
    CGFloat ratio = 1;
    
    switch (imgType) {
            
        case iconIMG:
        {
            ratio = 140.0f/105.0f;
        }
            break;
            
        case IDCardIMG:
        {
            ratio = 220.0f/340.0f;
        }
            break;
        case IMG43:{
            
            ratio = 300/400.0f;
        }
            break;
        default:
            
            break;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat hight = [UIScreen mainScreen].bounds.size.height;
    
    return CGRectMake(0.1f * width, hight / 2.0f - width * 0.8f * ratio / 2.0f, width * 0.8f, width * 0.8f * ratio);
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    UIImage * edited =  [UIImage imageWithCGImage:editedImage.CGImage scale:1 orientation:UIImageOrientationUp];
    
    [_imgeArray removeAllObjects];
    
    [_imgeArray addObject:edited];
    
    switch (cropperViewController.tag) {
        case 600:
        {
            [self.photoScrollView setImagesNow:_imgeArray isORG:NO];
            if(self.photoScrollView.imageViews.count == 5){
                self.photoScrollView.justView = YES;
            }
        }
            break;
        default:
            
            break;
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - assetPicker
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    
    [_imgeArray removeAllObjects];
    
    
    for (ALAsset * asset in assets) {
        
        
        UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        if (tempImg.size.width<50){
            
            continue;
        }
        
        
        [_imgeArray addObject:tempImg];
    }
    //    if (_imgeArray.count==1) {
    //
    //        [picker dismissViewControllerAnimated:NO completion:^{
    //            VPImageCropperViewController * vpCrop = [[VPImageCropperViewController alloc]initWithImage:[UIImage fixOrientation:[_imgeArray lastObject ]] cropFrame:[self standardizedIconIMGRectWithType:IMG43] limitScaleRatio:3.0f];
    //            vpCrop.tag = picker.tag;
    //
    //            vpCrop.delegate = self;
    //            [self presentViewController:vpCrop animated:YES completion:nil];
    //
    //        }];
    //        return;
    //    }
    NSInteger tag = picker.tag;
    
    switch (tag) {
        case 600:
        {
            if (_imgeArray.count > 0) {
                [self.photoScrollView setImagesNow:_imgeArray isORG:NO];
            }
            
            if(self.photoScrollView.imageViews.count == 5){
                self.photoScrollView.justView = YES;
            }
        }
        default:
            break;
    }
    
}
#pragma mark - photobrowser代理方法
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    
    return _imPhotoArr[index];
    
    //    NSString *urlStr = self.BigimageArray[index] ;
    //
    //    return  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]] scale:0.8];
}


// 返回高质量图片的url
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return _imPhotoArr[index];
    
    //    NSString *urlStr = self.BigimageArray[index] ;
    //    DLog(@"原图：%@",urlStr);
    //
    //    return [NSURL URLWithString:urlStr];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
