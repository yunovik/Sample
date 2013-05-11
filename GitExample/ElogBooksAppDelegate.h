//
//  ElogBooksAppDelegate.h
//  ElogBooks
//
//  Created by nayan mistry on 07/12/12.
//  Copyright (c) 2012 nayanmist@gmail.com. All rights reserved.
//
/*
 
 
 As this patrol point has no requirement for a photo signature or a barcode ,
 Please select the correct option below.

 
 
*/

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class SplashScreenViewController;

@interface ElogBooksAppDelegate : UIResponder <UIApplicationDelegate,UIScrollViewDelegate,CLLocationManagerDelegate>
{
    
    UINavigationController *objNavigation;
    
    UIPageControl  *pageControl;
    
    UIView *gridView;
    
    UIButton *btnGrid;
    
    UIScrollView *scrGridView;
    
    UIButton *btnTransparent; 
    
}




@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SplashScreenViewController *viewController;




-(void)setTitleGridView;

+(id)getSyncInBackGroundObj;

+(BOOL)isRefresh;
+(void)setRefresh:(BOOL)isVal;



//Get and Set global Dictionary
+(void)SetGlobalObject:(id)strValueToStore:(NSString*)strKeyForValueToStore;
+(id)getValueForKey:(NSString*)strKeyValueToFetch;

@end
