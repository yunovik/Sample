//
//  SignViewController.h
//  Sign
//
//  Created by Mac-1 on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEAlertView.h"
#import "PutInfoClass.h"
@interface SignViewController : UIViewController<PutInfoDelegate,MEAlertViewDelegate > {
	IBOutlet UIImageView *drawImage;
    
	CGPoint  currentPoint,lastPoint;
	BOOL mouseSwiped;
    UIView *AlertView,*Alert_View;
    NSString *strImageTitle,*strTimeStampValue;
    
    //	IBOutlet UIButton *btnSave,*btnClear,*btnBack;
	UIButton *btnClear;
	int mouseMoved;
    UIImage *img_ToUpload;
    MEAlertView *objAlert;
    UIButton *btnSave;
    
}                

@property(retain,nonatomic)NSString *strjid,*strIsUNorderedPoint;

@property(retain,nonatomic)NSString *strPoint_id;
@property(retain,nonatomic)NSString *strOrder;
@property(retain,nonatomic)NSString *strSchedule_id;
@property(nonatomic,retain)NSString *strPatrolJobId;
@property(nonatomic,retain)NSMutableDictionary *dicCurrentPatrolRecord;
@property (nonatomic,assign)BOOL isUploadingLastPoint;

-(IBAction)btnBack_Tapped:(id)Sender;
-(IBAction)btnSave_Tapped:(id)Sender;
-(IBAction)btnClear_Tapped:(id)Sender;

@end

