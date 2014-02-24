//
//  XCJSendMapViewController.m
//  laixin
//
//  Created by apple on 14-1-25.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import "XCJSendMapViewController.h"
#import "XCJAboutViewController.h"
#import "XCAlbumAdditions.h"
#import <MapKit/MapKit.h>
#import "MMLocationManager.h"
#import "MKMapView+ZoomLevel.h"
#import "UIImage+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

@interface XCJSendMapViewController ()
{
    NSString * strAddresss;
    double lat;
    double log;
    MKMapView * CurrentMapview;
}
@end

@implementation XCJSendMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MKMapView * mapview = (MKMapView *)[self.view subviewWithTag:1];
    CurrentMapview = mapview;
    if (self.isSeeTaMap) {
        CurrentMapview.showsUserLocation = YES;
        CurrentMapview.zoomEnabled  = YES;
        self.navigationItem.rightBarButtonItem = Nil;
        [self SetMapPoint:self.TCoordinate whitTitle:self.title subTitle:self.subtitle];
        
        self.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismissThis:)];
        self.navigationItem.leftBarButtonItem = leftBar;
    }else{
        double delayInSeconds = .1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            __block NSString *string;
            //    __block __weak XCJSendMapViewController *wself = self;
            [[MMLocationManager shareLocation] getLocationCoordinate:^(CLLocationCoordinate2D locationCorrrdinate) {
                log =locationCorrrdinate.longitude;
                
                lat = locationCorrrdinate.latitude;
                string = [NSString stringWithFormat:@"%f %f",locationCorrrdinate.latitude,locationCorrrdinate.longitude];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                SLog(@"string :%@",string);
                [mapview setCenterCoordinate:locationCorrrdinate zoomLevel:30 animated:YES];
                mapview.zoomEnabled  = YES;
            } withAddress:^(NSString *addressString) {
                strAddresss = addressString;
                //[NSString stringWithFormat:@"%@\n%@",string,addressString];
                SLog(@"string :%@",string);
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }];
            
        });
    }
    
    
    
}

-(IBAction)dismissThis:(id)sender
{
    CurrentMapview  = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

//截图
- (UIImage *)viewToImage:(UIView *)view
{
    
    //支持retina高分的关键
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    
    //获取图像
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    
}

-(IBAction)cancelClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation whitTitle:(NSString*) title subTitle:(NSString *) subtitle
{
    
    POI* m_poi = [[POI alloc]initWithCoords:myLocation];
    m_poi.title = title;
    m_poi.subtitle = subtitle;
    [CurrentMapview addAnnotation:m_poi];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myLocation;
    [CurrentMapview setZoomEnabled:YES];
    [CurrentMapview setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [CurrentMapview setRegion:theRegion animated:YES];
}


-(IBAction)SureClick:(id)sender
{
    MKMapView * mapview = (MKMapView *)[self.view subviewWithTag:1];
    UIImage * image = [self viewToImage:mapview];
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self cancelClick:sender];
    NSString * newstr  ;
    if (strAddresss) {
        newstr = [strAddresss stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    }
    NSDictionary *dict = @{@"image":image,@"strAddresss":newstr,@"lat":@(lat),@"log":@(log)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostChatLoacation" object:nil userInfo:dict];
    
    //UIViewma [self.view subviewWithTag:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end




@implementation POI

@synthesize coordinate,subtitle,title;

- (id) initWithCoords:(CLLocationCoordinate2D) coords{
    
    self = [super init];
    
    if (self != nil) {
        
        coordinate = coords;
        
    }
    
    return self;
    
}

//- (void) dealloc
//
//{
//    [title release];
//    [subtitle release];
//    [super dealloc];
//}

@end

