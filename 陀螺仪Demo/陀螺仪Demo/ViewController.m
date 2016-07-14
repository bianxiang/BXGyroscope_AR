//
//  ViewController.m
//  陀螺仪Demo
//
//  Created by xiaoxiao on 16/7/13.
//  Copyright © 2016年 xiaoxiao. All rights reserved.
//

#import "ViewController.h"
#import "FINCamera.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,FINCameraDelagate,BMKLocationServiceDelegate,UIAccelerometerDelegate>{
    BMKLocationService* _locService;
    CMMotionManager *manager;
    
    float _previousY;
}
@property(nonatomic,strong)FINCamera * camera;

@property (weak, nonatomic) IBOutlet UILabel *lbLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbHeading;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self openCamera];
   
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    _previousY = 0.14;
    [self imageimageimage];
    
    
    
}
-(void)imageimageimage
{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"222"]];
    imageView.frame = CGRectMake(-self.view.frame.size.width, -(self.view.frame.size.height/2), self.view.frame.size.width*3, self.view.frame.size.height*2);
    imageView.center = self.view.center;
    [self.view insertSubview:imageView atIndex:1];
//    [self.view addSubview:imageView];
    //判断手机陀螺仪能否使用
    if (!manager) {
        manager = [[CMMotionManager alloc]init];
        //更新频率
        manager.gyroUpdateInterval = 1/100;
    }
    if (![manager isGyroActive] &&[manager isGyroAvailable]) {
        [manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            NSLog(@"%f,%f",5*gyroData.rotationRate.y,5*gyroData.rotationRate.x);
            
            if (fabs(5*gyroData.rotationRate.y - _previousY) <0.02) {
                NSLog(@"位移太小,作废");
                return ;
            }else {
                NSLog(@"位移足够,不作废");
            }
            _previousY =5*gyroData.rotationRate.y;
            
            
            CGFloat rotationRateX =  imageView.center.x+5*gyroData.rotationRate.y;
            CGFloat rotationRateY = imageView.center.y+5*gyroData.rotationRate.x;
            if (rotationRateX > self.view.frame.size.width*3/2) {
//                NSLog(@"rotationRateX > self.view.frame.size.width*3/2");
                rotationRateX =self.view.frame.size.width*3/2;
            }
            if(rotationRateX < (-self.view.frame.size.width/2)){
//                NSLog(@"rotationRateX < (-self.view.frame.size.width/2)");
                rotationRateX=(-self.view.frame.size.width/2);
            }
            if (rotationRateY > self.view.frame.size.height) {
//                NSLog(@"rotationRateY > self.view.frame.size.height");
                rotationRateY= self.view.frame.size.height;
            }
            if (rotationRateY < 0) {
//                NSLog(@"rotationRateY < 0");
                rotationRateY=0;
            }
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [imageView setCenter:CGPointMake(rotationRateX, rotationRateY)];
                             }
                             completion:nil];
            
            
            
        }];
    }
    
    
    
}



#pragma mark - 相机
- (void)openCamera {
    __weak typeof(self) weakSelf = self;
    self.camera =[FINCamera createWithBuilder:^(FINCamera *builder) {
        // input
        [builder useBackCamera];
        // output
        [builder useVideoDataOutputWithDelegate:weakSelf];
        // delegate
        [builder setDelegate:weakSelf];
        // setting
        [builder setPreset:AVCaptureSessionPresetPhoto];
    }];
    [self.camera startSession];
//    [self.view addSubview:[self.camera previewWithFrame:self.view.frame]];
    [self.view insertSubview:[self.camera previewWithFrame:self.view.frame] atIndex:0];
    
//    UIImageView *cover = [[UIImageView alloc] initWithFrame:self.view.frame];
//    cover.image = [UIImage imageNamed:@"cover"];
//    [self.view addSubview:cover];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
//    NSLog(@"TEST");
}
-(void)camera:(FINCamera *)camera adjustingFocus:(BOOL)adjustingFocus{
//    NSLog(@"%@",adjustingFocus?@"正在对焦":@"对焦完毕");
}


#pragma mark - 相机
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    [_mapView updateLocationData:userLocation];
    NSLog(@"地磁北极:%.0f 真正北极:%.0f 偏移:%.0f x:%.1f y:%.1f z:%.1f",userLocation.heading.magneticHeading,
           userLocation.heading.trueHeading,
           userLocation.heading.headingAccuracy,
           userLocation.heading.x,userLocation.heading.y,userLocation.heading.z);
    self.lbHeading.text = [NSString stringWithFormat:@"地磁北极:%.0f \n真正北极:%.0f \n偏移:%.0f \nx:%.1f \ny:%.1f \nz:%.1f",userLocation.heading.magneticHeading,
                           userLocation.heading.trueHeading,
                           userLocation.heading.headingAccuracy,
                           userLocation.heading.x,userLocation.heading.y,userLocation.heading.z];
    
//    heading is magneticHeading 102.66 trueHeading 96.82 accuracy 25.00 x -18.890 y -4.079 z -34.157 @ 2016-07-13 08:03:59 +0000
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //    [_mapView updateLocationData:userLocation];
    NSLog(@"经度:%f 纬度:%f 高度:%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude,userLocation.location.altitude);
    self.lbLocation.text = [NSString stringWithFormat:@"经度:%f\n纬度:%f\n高度:%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude,userLocation.location.altitude];
    
    //lat 31.248189,long 121.473826

}
@end
