//
//  MKMapView+ZoomLevel.h
//  laixin
//
//  Created by apple on 14-1-25.
//  Copyright (c) 2014年 jijia. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
