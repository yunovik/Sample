//
//  SignViewController.m
//  Sign
//
//  Created by Mac-1 on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignViewController.h"
#import "AddDescription.h"
@implementation SignViewController
@synthesize strjid,strPoint_id,strOrder,strSchedule_id,strPatrolJobId,dicCurrentPatrolRecord,isUploadingLastPoint,strIsUNorderedPoint;
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
//    [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void)viewDidLoad {
    
    self.title = @"Signature";
    
    [CommonFunctions setTitleView:self amdtitle:@"Signature"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Back Button On Navigation
    [CommonFunctions setBack:self target:@selector(btnBackTapped:)];

  btnSave = [CommonFunctions buttonWithTitle:@"Save Signature" andFrame:CGRectMake(10, 320.0, 150, 35)];
    [btnSave addTarget:self action:@selector(btnSave_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setEnabled: NO];
    [self.view addSubview:btnSave];
    
    
//    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnSave addTarget:self action:@selector(btnSave_Tapped:) forControlEvents:UIControlEventTouchUpInside];
//    [btnSave setBackgroundImage:[UIImage imageNamed:@"RoundedBtn.png"] forState:UIControlStateNormal];
//    [btnSave setTitle:@"Save Signature" forState:UIControlStateNormal];
//    [btnSave.titleLabel setFont:FONT_NEUE_SIZE(14) ];
//    [btnSave setTitleColor:DEFAULT_FONT_COLOR forState:UIControlStateNormal ];
//    btnSave.frame = CGRectMake(5, 320.0, 120, 30.0);
//    [self.view addSubview:btnSave];
    

     btnClear = [CommonFunctions buttonWithTitle:@"Clear" andFrame:CGRectMake(210, 320.0, 100, 35)];
    [btnClear addTarget:self action:@selector(btnClear_Tapped:) forControlEvents:UIControlEventTouchUpInside];
        [btnClear setEnabled:NO];
    [self.view addSubview:btnClear];
    
    
    UIButton *btnUnableToSign = [CommonFunctions buttonWithTitle:@"Unable to obtain signature" andFrame:CGRectMake(10, 360, 175, 50)];
    [btnUnableToSign addTarget:self action:@selector(btnUnableToSignTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnUnableToSign];
    

    UIButton *btnCancel = [CommonFunctions buttonWithTitle:@"Cancel" andFrame:CGRectMake(210, 360, 100, 40)];
    [btnCancel addTarget:self action:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    

    
    drawImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 50, 317, 256)];
    [ drawImage setBackgroundColor:[UIColor clearColor]];
    [drawImage.layer setBorderColor: [[UIColor blackColor] CGColor]];
    drawImage.layer.masksToBounds = YES;
    [drawImage.layer setBorderWidth: 2.0];
    
    [self.view addSubview:drawImage];
    
    //[self.view sendSubviewToBack:drawImage];
    
    //    [drawImage release];
    
    [super viewDidLoad];
}
#pragma mark -btnUnableToSignTapped
-(void)btnUnableToSignTapped:(id)sender
{
    Alert_View =[CommonFunctions AlertWithMessage:@"Please wait..."];
    [self.view addSubview:Alert_View];
    [self MarkPointAsUnableToComplete]; 
}

#pragma mark -buttonTapped Method

-(IBAction)btnBackTapped:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)btnBack_Tapped:(id)Sender{
	//[self.navigationController popViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)btnSave_Tapped:(id)Sender{
	
    
    UIImage *_img = drawImage.image;
    img_ToUpload = drawImage.image;
    [img_ToUpload retain];
    
    if (strjid !=nil)
    {
        
        if (_img!=nil) {
            strImageTitle = [NSString stringWithFormat:@"%@.png",[CommonFunctions getUniqueName]];
            [strImageTitle retain];
            strTimeStampValue = [CommonFunctions getCurrentTimeStamp];
            [strTimeStampValue retain];
            
            if ([CommonFunctions isNetAvailable])
            {
                AlertView = [CommonFunctions AlertWithMessage:@"Please wait..."];
                [self.view addSubview:AlertView];
                
                PutInfoClass *objPutInfo = [[PutInfoClass alloc] init];
                
                //        strImageTitle = [NSString stringWithFormat:@"%@.png",[CommonFunctions getUniqueName]];
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                NSData *_data = UIImagePNGRepresentation(_img);
                NSString *strBase64 = [Base64 encode:_data];
                
                NSString *strUserId = [ElogBooksAppDelegate getValueForKey:USER_ID];
                [dic setObject:strUserId forKey:@"01:uid"];
                [dic setObject:@"image" forKey:@"02:UpdateType"];
                
                NSLog(@"%@",strjid);
                [dic setObject:strjid forKey:@"03:jid"];
                
                [dic setObject:strBase64 forKey:@"04:ImageString"];
                
                [dic setObject:strImageTitle forKey:@"03:Title"];
                
                
                if([strPoint_id length]>0)
                    [dic setObject:strPoint_id forKey:@"04:point_id"];
                
                if([strOrder length]>0)
                    [dic setObject:strOrder forKey:@"03:order"];
                
                if([strSchedule_id length]>0)
                    [dic setObject:strSchedule_id forKey:@"04:schedule_id"];
                
                
                [dic setObject:strTimeStampValue forKey:@"05:tstamp"];
                
                
                objPutInfo = [[PutInfoClass alloc] init];
                objPutInfo.argsDic = dic;
                
                objPutInfo.ParentNode = @"Responses";
                objPutInfo.ChildNode = @"Response";
                
                objPutInfo.strWebService=[NSString stringWithFormat:@"UploadImage"];
                
                objPutInfo.retType=isString;
                
//                objPutInfo.strUrl= @"http://code.elogbooks.co.uk/users/jack/WOM/api/put-info.php";
                
                objPutInfo.strUrl = [NSString stringWithFormat:@"%@%@",[ElogBooksAppDelegate getValueForKey:BASE_URL],PUT_INFO_API];
                objPutInfo._delegate=self;
                [objPutInfo setArrayPOST];
            }
            else
            {
                
                if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strjid,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
                    NSLog(@"Uploaded file details stored in db");
                [self saveImageInLocal:img_ToUpload:strImageTitle];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        }
    }
    else if ( strPatrolJobId!=nil)
    {
        
        
        if (img_ToUpload!=nil)
        {
            Alert_View = [CommonFunctions AlertWithMessage:@"Please wait....."];
            [self.view addSubview:Alert_View];
            strImageTitle = [NSString stringWithFormat:@"%@.png",[CommonFunctions getUniqueName]];
            [strImageTitle retain];
            strTimeStampValue = [CommonFunctions getCurrentTimeStamp];
            [strTimeStampValue retain];
            if ([CommonFunctions isNetAvailable])
            {
                //Complete the job
                AlertView = [CommonFunctions AlertWithMessage:@"Please wait..."];
                [self.view addSubview:AlertView];
                
                PutInfoClass *objPutInfo = [[PutInfoClass alloc] init];
                
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                NSData *_data = UIImagePNGRepresentation(img_ToUpload);
                NSString *strBase64 = [Base64 encode:_data];
                
                NSString *strUserId = [ElogBooksAppDelegate getValueForKey:USER_ID];
                [dic setObject:strUserId forKey:@"01:uid"];
                
                [dic setObject:@"image" forKey:@"02:UpdateType"];
                
                NSLog(@"%@",strjid);
                [dic setObject:strPatrolJobId forKey:@"03:jid"];
                [dic setObject:strBase64 forKey:@"04:ImageString"];
                [dic setObject:strImageTitle forKey:@"03:Title"];
                
                
                if([strPoint_id length]>0)
                    [dic setObject:strPoint_id forKey:@"04:point_id"];
                
                if([strOrder length]>0)
                    [dic setObject:strOrder forKey:@"03:order"];
                
                if([strSchedule_id length]>0)
                    [dic setObject:strSchedule_id forKey:@"04:schedule_id"];
                
                [dic setObject:strTimeStampValue forKey:@"05:tstamp"];
                
                //                  objPutInfo = [[PutInfoClass alloc] init];
                objPutInfo.argsDic = dic;
                
                objPutInfo.ParentNode = @"Responses";
                objPutInfo.ChildNode = @"Response";
                
                objPutInfo.strWebService=[NSString stringWithFormat:@"UploadImage_Patrol"];
                objPutInfo.retType=isString;
//                objPutInfo.strUrl= @"http://code.elogbooks.co.uk/users/jack/WOM/api/put-info.php";
                              objPutInfo.strUrl = [NSString stringWithFormat:@"%@%@",[ElogBooksAppDelegate getValueForKey:BASE_URL],PUT_INFO_API];
                
                objPutInfo._delegate=self;
                [objPutInfo setArrayPOST];
                
                
                
                
            }
            else
            {
                if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,%@,'','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strPatrolJobId,[self ConvertDateToOriginalName:strTimeStampValue:strPatrolJobId],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
                    NSLog(@"Uploaded file details stored in db");
                [self saveImageInLocal:img_ToUpload:strImageTitle];
                
                
                //Complete the job
//                objAlert = [[MEAlertView alloc]initWithMessage:@"As this patrol has  requirement for Photo.Please select the correct option below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unable to complete,Complete"];
//                objAlert.tag= IMAGE_ATT_TAG;
//                
//                objAlert.delegate=self;
//                [objAlert Show];
//                [objAlert release];
                [self MarkPatrolAsDone];
            }
        }
    }
}

-(void)MarkPatrolAsDone 
{
    NSLog(@"btnOk_Tapped Clicked");
    NSString *strCurrentTimeStamp = [CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue];
    [strCurrentTimeStamp retain];
    
    if ([strIsUNorderedPoint isEqualToString:@"YES"])
    {
        
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='N',date_complete ='%@',ManualStatusHandler='COMPLETE' where schedule_id= %@ and point_id = %@ and sort=%@",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]))
        {
            NSLog(@"record updated");
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePoint:dicCurrentPatrolRecord];
            }
            else
            {
                //no internet connection available
                if (isUploadingLastPoint)  //last point row
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [Alert_View removeFromSuperview];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record");
        
    }
    else 
    {
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='N',date_complete ='%@',ManualStatusHandler='COMPLETE' where schedule_id= %@ and point_id = %@ and sort=%@",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]) && ([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET date_complete ='',require_unable='N',ManualStatusHandler='MISSED' where  sort < %@ and ManualStatusHandler != 'NOT_COMPLETE' and  ManualStatusHandler != 'COMPLETE' and schedule_id = %@;",[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT],[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID]]]))
        {
            NSLog(@"record updated");
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePoint:dicCurrentPatrolRecord];
            }
            else
            {
                //no internet connection available
                if (isUploadingLastPoint)  //last point row
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [Alert_View removeFromSuperview];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record");
        
        
    }
    

}
-(void)MarkPointAsUnableToComplete
{
    NSLog(@"btnUnableTocomplete Clicked");
     
    strTimeStampValue = [CommonFunctions getCurrentTimeStamp];
    NSString *strCurrentTimeStamp = [CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue];
    [strCurrentTimeStamp retain];
    
    if ([strIsUNorderedPoint isEqualToString:@"YES"])
    {
       
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='Y',date_complete ='%@',ManualStatusHandler='NOT_COMPLETE' where schedule_id= %@ and point_id = %@ and sort = %@;",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]) )
        {
            NSLog(@"record updated");
            //set current unable feature in the key of the current dictionary
            [dicCurrentPatrolRecord setObject:@"Y" forKey:@"require_unable"];
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePointForIncompletion:dicCurrentPatrolRecord];
            }
            else
            {
                
                //no internet connection available
                if (isUploadingLastPoint)
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    if (Alert_View!=nil)
                        [Alert_View removeFromSuperview];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record ");
        
        
    }
    else {
      
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='Y',date_complete ='%@',ManualStatusHandler='NOT_COMPLETE' where schedule_id= %@ and point_id = %@ and sort = %@;",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]) && ([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET date_complete ='',ManualStatusHandler='MISSED' where  sort < %@ and ManualStatusHandler != 'NOT_COMPLETE' and  ManualStatusHandler != 'COMPLETE' and schedule_id = %@;",[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT],[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID]]]))
        {
            NSLog(@"record updated");
            //set current unable feature in the key of the current dictionary
            [dicCurrentPatrolRecord setObject:@"Y" forKey:@"require_unable"];
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePointForIncompletion:dicCurrentPatrolRecord];
            }
            else
            {
                
                //no internet connection available
                if (isUploadingLastPoint)
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    if (Alert_View!=nil)
                        [Alert_View removeFromSuperview];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record ");
        
        
        
    }
    


}

-(IBAction)btnUnableTocomplete:(UIButton *)Sender andTag:(int)alertTag
{
    NSLog(@"btnUnableTocomplete Clicked");
    NSString *strCurrentTimeStamp = [CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue];
    [strCurrentTimeStamp retain];
    
    if ([strIsUNorderedPoint isEqualToString:@"YES"])
    {
        
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='Y',date_complete ='%@',ManualStatusHandler='NOT_COMPLETE' where schedule_id= %@ and point_id = %@ and sort = %@;",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]))
        {
            NSLog(@"record updated");
            //set current unable feature in the key of the current dictionary
            [dicCurrentPatrolRecord setObject:@"Y" forKey:@"require_unable"];
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePointForIncompletion:dicCurrentPatrolRecord];
            }
            else
            {
                
                //no internet connection available
                if (isUploadingLastPoint)
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record ");
    }
    else 
    {
        
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='Y',date_complete ='%@',ManualStatusHandler='NOT_COMPLETE' where schedule_id= %@ and point_id = %@ and sort = %@;",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]) && ([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET date_complete ='',ManualStatusHandler='MISSED' where  sort < %@ and ManualStatusHandler != 'NOT_COMPLETE' and  ManualStatusHandler != 'COMPLETE' and schedule_id = %@;",[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT],[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID]]]))
        {
            NSLog(@"record updated");
            //set current unable feature in the key of the current dictionary
            [dicCurrentPatrolRecord setObject:@"Y" forKey:@"require_unable"];
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePointForIncompletion:dicCurrentPatrolRecord];
            }
            else
            {
                
                //no internet connection available
                if (isUploadingLastPoint)
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record "); 
    }

    
}
-(IBAction)btnOk_Tapped:(UIButton *)Sender andTag:(int)alertTag
{
    NSLog(@"btnOk_Tapped Clicked");
    NSString *strCurrentTimeStamp = [CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue];
    [strCurrentTimeStamp retain];
    
    if ([strIsUNorderedPoint isEqualToString:@"YES"])
    {
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='N',date_complete ='%@',ManualStatusHandler='COMPLETE' where schedule_id= %@ and point_id = %@ and sort=%@",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]))
        {
            NSLog(@"record updated");
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePoint:dicCurrentPatrolRecord];
            }
            else
            {
                //no internet connection available
                if (isUploadingLastPoint)  //last point row
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record");
    }
    else 
    {
        if (([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET IsSynced=%@,require_unable='N',date_complete ='%@',ManualStatusHandler='COMPLETE' where schedule_id= %@ and point_id = %@ and sort=%@",UN_SYNCED_DATA,strCurrentTimeStamp,[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID],[dicCurrentPatrolRecord objectForKey:POINT_ID],[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]]]) && ([DataSource executeQuery:[NSString stringWithFormat:@"Update Job_patrol_schedule_points SET date_complete ='',require_unable='N',ManualStatusHandler='MISSED' where  sort < %@ and ManualStatusHandler != 'NOT_COMPLETE' and  ManualStatusHandler != 'COMPLETE' and schedule_id = %@;",[dicCurrentPatrolRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT],[dicCurrentPatrolRecord objectForKey:SCHEDULE_ID]]]))
        {
            NSLog(@"record updated");
            
            if ([CommonFunctions isNetAvailable])
            {
                [self completePoint:dicCurrentPatrolRecord];
            }
            else
            {
                //no internet connection available
                if (isUploadingLastPoint)  //last point row
                {
                    //Complete Patrol
                    [self CompletePatrol:dicCurrentPatrolRecord];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
            NSLog(@"Unable to update the record");   
    }
    

}
-(IBAction)btnCancel_Tapped:(UIButton *)Sender andTag:(int)alertTag
{
    
}

#pragma mark completePoint
-(void)completePoint:(NSMutableDictionary *)dicCurrentRecord
{
    /*http://code.elogbooks.co.uk/users/jack/WOM/api/put-info.php?uid=38&UpdateType=patrol_point&qd=Update&tstamp=27/12/2012%2018:35:20&jid=7811&point_id=50&order=3&schedule_id=240&unable=N */
    
    
    
    PutInfoClass  *objService=[[PutInfoClass alloc] init];
    objService._delegate=self;
    objService.retType=isArray;
    NSMutableDictionary *dicc=[[[NSMutableDictionary alloc] init]autorelease];
    [dicc setObject:[ElogBooksAppDelegate getValueForKey:USER_ID] forKey:USER_ID];
    [dicc setObject:@"patrol_point" forKey:@"UpdateType"];
    [dicc setObject:@"Update" forKey:@"qd"];
    [dicc setObject: strTimeStampValue forKey:@"tstamp"];
    [dicc setObject:strPatrolJobId forKey:JOBS_ID];
    
    
    [dicc setObject:[dicCurrentRecord objectForKey:POINT_ID]  forKey:POINT_ID];
    [dicc setObject:[dicCurrentRecord objectForKey:SCHEDULE_ID]  forKey:SCHEDULE_ID];
    [dicc setObject:[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]  forKey:@"order"];
    [dicc setObject:[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_REQUIRE_UNABLE]  forKey:@"unable"];
    
    
    objService.argsDic=[CommonFunctions getDicAsParameter:dicc] ;
    //point_id-->1 ===SCHEDULE_ID-->3 ====sort-->5
    objService.strWebService=[NSString stringWithFormat:@"point_id:%@:schedule_id:%@:sort:%@",[dicCurrentRecord objectForKey:POINT_ID],[dicCurrentRecord objectForKey:SCHEDULE_ID],[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]];
    objService.strUrl= [NSString stringWithFormat:@"%@%@",[ElogBooksAppDelegate getValueForKey:BASE_URL],PUT_INFO_API];
    objService.ParentNode=@"Responses";
    objService.ChildNode=@"Response";
    [objService performSelector:@selector(setArray) withObject:nil afterDelay:0.1];
    
    
}

#pragma mark CompletePatrol
-(void)CompletePatrol:(NSMutableDictionary *)dicSelected
{
    //update the schedule as unsynced
    //Check whether any unsynced point exists ,if yes then set schedule_id as unsynced
    //select COUNT(Job_patrol_schedule_points.point_id) from Jobs join Job_patrol_schedules on Jobs.jid = Job_patrol_schedules.jid join Job_patrol_schedule_points on Job_patrol_schedule_points.schedule_id=Job_patrol_schedules.schedule_id where jobs.jid=7798 and Job_patrol_schedule_points.IsSynced=0
    
    
    int UnsyncedDatacount =  [[DataSource getStringFromQuery:[NSString stringWithFormat:@"select COUNT(Job_patrol_schedule_points.point_id) from Jobs join Job_patrol_schedules on Jobs.jid = Job_patrol_schedules.jid join Job_patrol_schedule_points on Job_patrol_schedule_points.schedule_id=Job_patrol_schedules.schedule_id where jobs.jid=%@ and Job_patrol_schedule_points.IsSynced=%@",strPatrolJobId,UN_SYNCED_DATA]]intValue];
    if (UnsyncedDatacount >0) //Check any unsynced data available
    {
        if ([DataSource executeQuery:[NSString stringWithFormat:@"update Job_patrol_schedules set IsSynced=%@ where schedule_id=%@",UN_SYNCED_DATA,[dicSelected objectForKey:SCHEDULE_ID]]])
            NSLog(@"Patrol Point updated");
        else
            NSLog(@"Failed to update the current schedule_id");
    }
    
    int MissedValuesCount = [[DataSource getStringFromQuery:[NSString stringWithFormat:@" select COUNT(*) as MissedCount from Jobs join Job_patrol_schedules on Jobs.jid = Job_patrol_schedules.jid join Job_patrol_schedule_points on Job_patrol_schedule_points.schedule_id=Job_patrol_schedules.schedule_id where                                                             jobs.jid='%@' and  ( Job_patrol_schedule_points.ManualStatusHandler ='NOT_COMPLETE' or Job_patrol_schedule_points.ManualStatusHandler = 'MISSED' )",strPatrolJobId]]intValue];

    
    //Call webservice here
    NSLog(@"Value updated");
    if (strPatrolJobId!=nil)
    {
    if (Alert_View)
    [Alert_View removeFromSuperview];
    }
    AddDescription* objNav=[[AddDescription alloc] initWithNibName:@"AddDescription" bundle:nil];
    objNav.strJid=strPatrolJobId;
    objNav.dicRecord = dicSelected;
    if (MissedValuesCount == 0)
    {
        objNav.isNotMissedAnyPoint = YES;   
    }
    [self.navigationController pushViewController:objNav animated:YES];
    [objNav release];
    
    
    
}

#pragma mark CompletePointforIncompletion
-(void)completePointForIncompletion:(NSMutableDictionary *)dicCurrentRecord
{
    PutInfoClass  *objService=[[PutInfoClass alloc] init];
    objService._delegate=self;
    objService.retType=isArray;
    NSMutableDictionary *dicc=[[[NSMutableDictionary alloc] init]autorelease];
    [dicc setObject:[ElogBooksAppDelegate getValueForKey:USER_ID] forKey:USER_ID];
    [dicc setObject:@"patrol_point" forKey:@"UpdateType"];
    [dicc setObject:@"Update" forKey:@"qd"];
    [dicc setObject:strTimeStampValue forKey:@"tstamp"];
    [dicc setObject:strPatrolJobId forKey:JOBS_ID];
    
    //    if (strScannedCode!=nil)
    //        [dicc setObject:strScannedCode  forKey:SCHEDULE_BARCODE];
    [dicc setObject:[dicCurrentRecord objectForKey:POINT_ID]  forKey:POINT_ID];
    [dicc setObject:[dicCurrentRecord objectForKey:SCHEDULE_ID]  forKey:SCHEDULE_ID];
    [dicc setObject:[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]  forKey:@"order"];
    [dicc setObject:[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_REQUIRE_UNABLE]  forKey:@"unable"];
    
    
    objService.argsDic=[CommonFunctions getDicAsParameter:dicc] ;
    //point_id-->1 ===SCHEDULE_ID-->3 ====sort-->5
    objService.strWebService=[NSString stringWithFormat:@"point_id:%@:schedule_id:%@:sort:%@",[dicCurrentRecord objectForKey:POINT_ID],[dicCurrentRecord objectForKey:SCHEDULE_ID],[dicCurrentRecord objectForKey:JOB_PATROL_SCHEDULE_POINT_SORT]];
    objService.strUrl= [NSString stringWithFormat:@"%@%@",[ElogBooksAppDelegate getValueForKey:BASE_URL],PUT_INFO_API];
    objService.ParentNode=@"Responses";
    objService.ChildNode=@"Response";
    [objService performSelector:@selector(setArray) withObject:nil afterDelay:0.1];
}
-(void)saveImageInLocal :(UIImage *)Img_ToLocal:(NSString *)Unique_imgName
{
    NSError*error;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:UN_SYNCEDIMAGES_FOLDER];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager]createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString*strTemp = [dataPath stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"%@",Unique_imgName]];
    UIImage *image  = Img_ToLocal;
    [UIImagePNGRepresentation(image) writeToFile:strTemp atomically:YES];
}



-(void)EndParsingArray:(NSMutableArray *)arrData forFlage:(NSString *)flage
{
    if (!([flage rangeOfString:@"schedule_id"].location == NSNotFound))
    {
        if ([arrData count]>0)
        {
            if (!([[arrData objectAtIndex:0]rangeOfString:@"Success"].location==NSNotFound))
            {
                if ([flage length]>0) // if success
                {
                    NSArray *arrIdValues = [flage componentsSeparatedByString:@":"];
                    NSString *strPointId=[arrIdValues objectAtIndex:1];
                    NSString *strScheduleId=[arrIdValues objectAtIndex:3];
                    NSString *strSortValue=[arrIdValues objectAtIndex:3];
                    if ([DataSource executeQuery:[NSString stringWithFormat:@"update Job_patrol_schedule_points set IsSynced=%@ where schedule_id=%@ and point_id=%@ and sort=%@",SYNCED_DATA,strScheduleId,strPointId,strSortValue]])
                        NSLog(@"pointId :%@ synced from webservice to local",strPointId);
                    else
                        NSLog(@"pointId :%@  not synced",strPointId);
                }
            }
        }
        
        if (isUploadingLastPoint)
            [self CompletePatrol:dicCurrentPatrolRecord];
        else
        {   
            if (Alert_View!=nil)
            [Alert_View removeFromSuperview];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
-(void)EndParsing:(NSString *)strResponse forFlage:(NSString *)flage
{
    if (strjid !=nil)
    {
        NSLog(@"%@:%@",flage,strResponse);
        
        NSRange rng = [strResponse rangeOfString:@":"];
        NSString *strIsSuccess = [strResponse substringToIndex:rng.location];
        NSString *strFId = [strResponse substringFromIndex:rng.location+1];
        
        NSLog(@"%@:%@",strIsSuccess,strFId);
        
        if([strIsSuccess isEqualToString:@"Success"])
        {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:APP_TITLE
                                  message:@"Image uploaded successfully"
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
            [alert show];
            
            if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values(%@,%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",strFId,[ElogBooksAppDelegate getValueForKey:USER_ID],strjid,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],SYNCED_DATA ]] )
                NSLog(@"Uploaded file details stored in db");
            
            
            
            //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            //        [dic release];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:APP_TITLE
                                  message:@"Image could not be uploaded"
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
            [alert show];
            
            if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strjid,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
                NSLog(@"Uploaded file details stored in db");
            [self saveImageInLocal:img_ToUpload:strImageTitle];
            
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        [AlertView removeFromSuperview];
    }
    else if (strPatrolJobId !=nil)
    {
        NSLog(@"%@:%@",flage,strResponse);
        [AlertView removeFromSuperview];
        NSRange rng = [strResponse rangeOfString:@":"];
        NSString *strIsSuccess = [strResponse substringToIndex:rng.location];
        NSString *strFId = [strResponse substringFromIndex:rng.location+1];
        
        NSLog(@"%@:%@",strIsSuccess,strFId);
        if([strIsSuccess isEqualToString:@"Success"])
        {
            
            if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values(%@,%@,0,0,%@,'','','J','','Y','%@','%@','jobs','%@','',%@)",strFId,[ElogBooksAppDelegate getValueForKey:USER_ID],strPatrolJobId,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],SYNCED_DATA ]] )
                NSLog(@"Uploaded file details stored in db");
            
            
            
//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle:APP_TITLE
//                                  message:@"Image uploaded successfully"
//                                  delegate:nil
//                                  cancelButtonTitle:@"Ok"
//                                  otherButtonTitles:nil];
//            [alert show];
//            
            
            
            // TABLE "Uploaded_files"
            
            //"fid" //
            //"uid" //
            //"cid" //
            //"iid"  // Assets ID
            //"as_id" //jid
            //"type"
            //"doc_type"
            //"as_type"
            //"expired"
            //"reveal"
            //"orig_name"
            //"title"
            //"dir"
            //"created"
            //"expiry"
            //"IsSynced"
            
            
            
            //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            //        [dic release];
            
        }
        else
        {
            [self saveImageInLocal:img_ToUpload:strImageTitle];
            if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strPatrolJobId,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
                NSLog(@"Uploaded file details stored in db");
            
        }
        if (strPatrolJobId != nil)
        {
            //Complete the job
            
            [self MarkPatrolAsDone];
            
//            objAlert = [[MEAlertView alloc]initWithMessage:@"As this patrol has  requirement for Photo.Please select the correct option below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unable to complete,Complete"];
//            objAlert.tag= IMAGE_ATT_TAG;
//            objAlert.delegate=self;
//            [objAlert Show];
//            [objAlert release];
        }
        
        
    }
}
-(void)filedWithError:(NSString *)strMsg forFlage:(NSString *)flage
{
    if (!([flage rangeOfString:@"schedule_id"].location == NSNotFound))
    {
        if (isUploadingLastPoint)
            [self CompletePatrol:dicCurrentPatrolRecord];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
    else if (strjid!=nil)
    {
        NSLog(@"%@:%@",flage,strMsg);
        [self saveImageInLocal:img_ToUpload:strImageTitle];
        if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strjid,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
            NSLog(@"Uploaded file details stored in db");
         [AlertView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
       
    }
    else  if (strPatrolJobId!=nil) //save for patrol image details
    {
        [self saveImageInLocal:img_ToUpload:strImageTitle];
        [AlertView removeFromSuperview];
        if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,%@,'','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strPatrolJobId,[self ConvertDateToOriginalName:strTimeStampValue:strjid],strImageTitle,[CommonFunctions getCurrentTimeStampForDatabaseInsertion:strTimeStampValue ],UN_SYNCED_DATA ]] )
            NSLog(@"Uploaded file details stored in db");
        
        if (strPatrolJobId !=nil)
        {
            //Complete the job
            [self MarkPatrolAsDone];
//            objAlert = [[MEAlertView alloc]initWithMessage:@"As this patrol has  requirement for Photo.Please select the correct option below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unable to complete,Complete"];
//            objAlert.tag= IMAGE_ATT_TAG;
//            objAlert.delegate=self;
//            [objAlert Show];
//            [objAlert release];
        }
    }
}
-(IBAction)btnClear_Tapped:(id)Sender{
	drawImage.image = nil;
    [btnClear setEnabled:NO];
    [btnSave setEnabled: NO];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        //        drawImage.image = nil;
             //   return;
    }
	 CGPoint point = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(drawImage.frame, point))
    {
        [btnClear setEnabled:YES];
        [btnSave setEnabled: YES];
    }
    
    lastPoint = [touch locationInView:self.view];
    lastPoint.y -=44;
}


-(NSString *)ConvertDateToOriginalName:(NSString *)strReceivedDate:(NSString *)strJid
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyyHH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:strReceivedDate];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *strOriginalName = [NSString stringWithFormat:@"%@-%@.png",[dateFormatter stringFromDate:date],strJid];
    //    NSLog(@"dateWithNewFormat: %@", dateWithNewFormat);
    return strOriginalName;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];
    currentPoint.y -=44;
    
    UIGraphicsBeginImageContext(drawImage.frame.size);
    [drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//       CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
   CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
	
    mouseMoved++;
    
    if (mouseMoved == 10) {
        mouseMoved = 0;
    }
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        //        drawImage.image = nil;
        //        return;
    }
    
    
    if(!mouseSwiped) {
		
		UITouch *touch = [touches anyObject];
		currentPoint = [touch locationInView:self.view];
		currentPoint.y -=44;
		
		UIGraphicsBeginImageContext(drawImage.frame.size);
		[drawImage.image drawInRect:CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height)];
		CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
		CGContextBeginPath(UIGraphicsGetCurrentContext());
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//          CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    

}

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	//NSLog(@"EXC_BAD_ACCESS :%d",toInterfaceOrientation);
    
    
    
	
}
#pragma mark -
#pragma mark UIAlertView Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag== 111){
		switch(buttonIndex) {
			case 0:
                
				[self dismissModalViewControllerAnimated:YES];
				// the cancel button was pressed, so there is nothing to do
				break;
			case 1:
				// this means the "ok" button was pressed. Do whatever you want with the text
				break;
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    strjid = nil;
    strPatrolJobId = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
