//
//  XCJSendMapViewController.h
//  laixin
//
//  Created by apple on 14-1-25.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface XCJSendMapViewController : UIViewController
@property (nonatomic,assign) CLLocationCoordinate2D TCoordinate;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) BOOL isSeeTaMap;
@end

@interface POI : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    NSString *subtitle;
    NSString *title;
}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *title;

-(id) initWithCoords:(CLLocationCoordinate2D) coords;
@end