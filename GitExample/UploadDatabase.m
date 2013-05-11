//
//  UploadDatabase.m
//  ElogBooks
//
//  Created by i-Verve on 22/12/12.
//  Copyright (c) 2012 nayanmist@gmail.com. All rights reserved.
//

#import "UploadDatabase.h"

@implementation UploadDatabase
@synthesize arrWebServiceObjects,_delegate;


-(void)Uploading:(NSString *)strStatus
{

    if([strStatus isEqualToString:@"START"])
    {
        
//        UIViewController *_self = (UIViewController *)_delegate;
//        AalertView = [self AlertWithMessage:@"Please wait"];
//        [_self.view addSubview:AalertView];

        CurrentUpLoading=0;
        responseDic = [[NSMutableDictionary alloc] init];   
        
        NSLog(@"\n \n Starting......");
    }

    if ([arrWebServiceObjects count]<=CurrentUpLoading)
    {
        NSLog(@"\n \n Comp : %@",[responseDic description]);
//        [AalertView removeFromSuperview];
        [_delegate UploadComplete:responseDic];
        
        [_delegate setProgress:CurrentUpLoading*100.00/[arrWebServiceObjects count] forFlag:@"Uploading Data"];

        return;
    }
    
    lblPercentage.text = [NSString stringWithFormat:@"%d %%",CurrentUpLoading*100/[arrWebServiceObjects count]];
    
    //-(void)setProgress:(float)val forFlag:(NSString *)strFlag
    
    [_delegate setProgress:CurrentUpLoading*100.00/[arrWebServiceObjects count] forFlag:@"Uploading Data"];
    
    
    //NSLog(@"\n \n CURRENT : %d %%" ,CurrentUpLoading*100/[arrWebServiceObjects count]);
    
    PutInfoClass *objService = [arrWebServiceObjects objectAtIndex:CurrentUpLoading];
    
    
    if (!([objService.strWebService rangeOfString:CREATE_JOB].location==NSNotFound))
        objService.retType = isArray;
    else
        objService.retType=isString;
    
    objService._delegate=self;
    
    if(objService.isImage)
    {
        [objService setArrayPOST];
    }else
    {
        [objService setArray];
    }

}
-(void)EndParsingArray:(NSMutableArray *)arrData forFlage:(NSString *)flage
{
     CurrentUpLoading++;
    
    if (!([flage rangeOfString:CREATE_JOB].location==NSNotFound)) 
    {
                
        
        NSString *strtempJid = [[flage componentsSeparatedByString:@":"]objectAtIndex:1];
        NSString *strSid = [[flage componentsSeparatedByString:@":"]objectAtIndex:2];
        NSMutableArray *arrNewJobData = [DataSource getRecordsFromQuery: [NSString stringWithFormat:@"select * from NewJobs where jid = %@",strtempJid]];
        NSMutableDictionary *recDic = nil;
        NSMutableArray *arrAttachments = [[[NSMutableArray alloc]init]autorelease];
        
        
        if ([arrNewJobData count]>0)
            recDic = [arrNewJobData objectAtIndex:0];

        NSString *strCombinedAttachmentString = [recDic valueForKey:@"Attachments"];
        strCombinedAttachmentString = [strCombinedAttachmentString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([strCombinedAttachmentString length]>0)
        {
            arrAttachments =(NSMutableArray *)[strCombinedAttachmentString componentsSeparatedByString:@":"];
        }
        
        if ([arrData count]>1) // job for approval
        {
            
            if ((!([[arrData objectAtIndex:1]rangeOfString:@"Success"].location==NSNotFound)) && (!([[arrData objectAtIndex:1]rangeOfString:@"Approval"].location==NSNotFound)))
            {
                if (!([[arrData objectAtIndex:0]rangeOfString:@"Success"].location==NSNotFound) && (!([[arrData objectAtIndex:0]rangeOfString:@"Raised"].location==NSNotFound)) )
                { 
                    
                    NSString *strReceivedJid = [NSString stringWithFormat:@"%d",[[[[arrData objectAtIndex:0]componentsSeparatedByString:@"-"]objectAtIndex:1]intValue]];
                    //Save the attachments for Put Info in uploaded files Table
                    if ([arrAttachments count]>0)     
                    {
                        NSString *strTimeStampValue = [recDic valueForKey:@"tstamp"]; 
                        for (int i=0;i<[arrAttachments count];i++)
                        {
                            NSString *strImageTitle = [arrAttachments objectAtIndex:i]; 
                            if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strReceivedJid,[CommonFunctions ConvertDateToOriginalName:strTimeStampValue:strReceivedJid],strImageTitle,strTimeStampValue,UN_SYNCED_DATA ]] )
                                NSLog(@"Uploaded file details stored in db");
                        }
                    }
                    
                    //remove the file record from New Jobs table 
                    [DataSource executeQuery:[NSString stringWithFormat:@"Delete from NewJobs where jid = %@",strtempJid]];         
                      
                   
                }
                else 
                {
                    NSLog(@"Problem in job creation webservice for flag :%@",flage);  
                }
            }
        }
        else if ([arrData count]>0)  //job not for approval
        {
            if (!([[arrData objectAtIndex:0]rangeOfString:@"Success"].location==NSNotFound))
            {
                
                
                NSString *strReceivedJid = [NSString stringWithFormat:@"%d",[[[[arrData objectAtIndex:0]componentsSeparatedByString:@"-"]objectAtIndex:1]intValue]]; 
                
  NSString *strIsCustomerRequireApproval = [DataSource getStringFromQuery: [NSString stringWithFormat:@"select apprjid_reqd from Customers where cid=%@",[recDic valueForKey:@"cid"]]];
               
                
                if ([arrAttachments count]>0) 
                {
                    NSString *strTimeStampValue = [recDic valueForKey:@"tstamp"]; 

                    //copy the attachments
                    for (int i =0;i<[arrAttachments count];i++)
                    {
                        NSString *strImageTitle = [arrAttachments objectAtIndex:i]; 
                        if ([DataSource executeQuery:[NSString stringWithFormat:@"INSERT INTO Uploaded_files (fid,uid,cid,iid,as_id,type,doc_type,as_type,expired,reveal,orig_name,title,dir,created,expiry,IsSynced)values('TEMP_FILE_ID',%@,0,0,'%@','','','J','','Y','%@','%@','jobs','%@','',%@)",[ElogBooksAppDelegate getValueForKey:USER_ID],strReceivedJid,[CommonFunctions ConvertDateToOriginalName:strTimeStampValue:strReceivedJid],strImageTitle,strTimeStampValue,UN_SYNCED_DATA ]] )
                            NSLog(@"Uploaded file details stored in db");
                        
                    } 
                    //remove the file record from New Jobs table 
                    [DataSource executeQuery:[NSString stringWithFormat:@"Delete from NewJobs where jid = %@",strtempJid]];  
                }
                
                            
                
                if ((!([strIsCustomerRequireApproval rangeOfString:@"N"].location == NSNotFound)) &&  ([strSid isEqualToString:@"0"]))
                {

                    //insert the raised job in jobs Table tempJid
                    [CommonFunctions changeJobIdToOriginal:[NSString stringWithFormat:@"%@%@",NEW_JOB,strtempJid] :strReceivedJid];
                   

                }
                //delete the moved id
                [DataSource executeQuery:[NSString stringWithFormat:@"Delete from NewJobs where jid = %@",[[flage componentsSeparatedByString:@":"]objectAtIndex:1]]];
                
                
                
                
            }           
        }
        
        flage = CREATE_JOB;
       
    }

    [responseDic setObject: [arrData componentsJoinedByString:@":"] forKey:flage];
    [self Uploading:@"COUNTINUE.."];
}
//-(void)EndParsing:(NSMutableDictionary *)arrData forFlage:(NSString *)flage
-(void)EndParsing:(NSString *)strResponse forFlage:(NSString *)flage
{
    CurrentUpLoading++;

    
    if (!([flage rangeOfString:START_JOB].location==NSNotFound)) 
    {
        if (!([strResponse rangeOfString:@"Success"].location==NSNotFound)) 
        {
            //reset jobs started status
            if([DataSource executeQuery:[NSString stringWithFormat:@"Update Jobs set  IsJobStarted='Y' where jid=%@",[[flage componentsSeparatedByString:@":"]objectAtIndex:1]]])
                NSLog(@"Job :%@:synced",flage); 
            else 
                NSLog(@"Job :%@:failed to synce",flage);  
            
            //successfully started
           if([DataSource executeQuery:[NSString stringWithFormat:@"Update Jobs set  IsSynced=%@ where jid=%@",SYNCED_DATA,[[flage componentsSeparatedByString:@":"]objectAtIndex:1]]])
               NSLog(@"Job :%@:synced",flage); 
            else 
            NSLog(@"Job :%@:failed to synce",flage); 
        }
    }
     else if (!([flage rangeOfString:UPDATE_JOB].location==NSNotFound))
    {
        if (!([strResponse rangeOfString:@"Success"].location==NSNotFound)) 
        {
            //successfully updated
            NSArray *arrUpdateJobInfo = [flage componentsSeparatedByString:@":"];
           if  ([DataSource executeQuery: [NSString stringWithFormat:@"Update Job_lines set IsSynced=%@ where jid=%@ and tstamp='%@'",SYNCED_DATA,[arrUpdateJobInfo objectAtIndex:1],[arrUpdateJobInfo objectAtIndex:2]]])
               NSLog(@"Job :%@:synced",flage); 
           else 
               NSLog(@"Job :%@:failed to synce",flage);
            
        }
    }
     else if (!([flage rangeOfString:COMPLETE_JOB].location==NSNotFound))
    {
        if (!([strResponse rangeOfString:@"Success"].location==NSNotFound)) 
        {
            //successfully started
            NSString *strJid  =  [[flage componentsSeparatedByString:@":"]objectAtIndex:1];
            [DataSource executeQuery:[NSString stringWithFormat:@"DELETE FROM Job_lines WHERE jid= %@",strJid]];
            [DataSource executeQuery:[NSString stringWithFormat:@"DELETE FROM Jobs WHERE jid= %@",strJid]];
            [DataSource executeQuery:[NSString stringWithFormat:@"DELETE FROM Job_materials WHERE jid= %@",strJid]];   
            NSLog(@"Jobcompleted : Uploaded :%@",flage);
        }
    }
    else if (!([flage rangeOfString:UPLOAD_IMAGE].location==NSNotFound))
    {
        if (!([strResponse rangeOfString:@"Success"].location == NSNotFound))
        {
            
            
            NSString *strUniqueTitle = [[flage componentsSeparatedByString:@":"]objectAtIndex:1];
            NSString *strFileId = [[strResponse componentsSeparatedByString:@":"]objectAtIndex:1];
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:UN_SYNCEDIMAGES_FOLDER];
            dataPath = [dataPath stringByAppendingPathComponent:strUniqueTitle];
            NSError *error = nil;
            //delete the file from local
            BOOL isDeleted = [[NSFileManager defaultManager]removeItemAtPath:dataPath error:&error];
            if (!(!isDeleted && error))
            {
                NSLog(@"File deleted from local");
                //update the change in database
                if ([DataSource executeQuery: [NSString stringWithFormat:@"Update Uploaded_files set fid=%@,IsSynced=%@ where title ='%@'",strFileId,SYNCED_DATA,strUniqueTitle]])
                {
                    NSLog(@"Image with file Id %@ synced",strFileId);
                }
                else
                    NSLog(@"Image with file Id %@ failed  to synced",strFileId);
                
                
            }else
                NSLog(@"Problem in file deletion");
            
            
            //Update Uploaded_files set fid=12 where title ='17012013170258.png'
        }
        else
            NSLog(@"Image with file Id failed  to synced");
    }
     else if (!([flage rangeOfString:@"SubAssets"].location==NSNotFound))
    {
        if (!([strResponse rangeOfString:@"Success"].location == NSNotFound))
        {
            // //00-->said ===1-->hiid
           NSString *strsaid = [[flage componentsSeparatedByString:@":"]objectAtIndex:0];
            NSString *strHiid = [[flage componentsSeparatedByString:@":"]objectAtIndex:1];
            if ([DataSource executeQuery: [NSString stringWithFormat:@"Update Assets_sub set IsSynced = %@ where said =%@",SYNCED_DATA,strsaid]])
            NSLog(@"Values Successflully suynced in Assets)sub tabnle ");
            else 
                 NSLog(@"Values failed to  suynced in Assets)sub tabnle ");
            if ([DataSource executeQuery: [NSString stringWithFormat:@"Update Assets_sub_history set IsSynced =%@ where hiid =%@",SYNCED_DATA,strHiid]])
                NSLog(@"Values Successflully suynced in Assets)sub_histroy tabnle ");
            else 
                NSLog(@"Values failed to  suynced in Assets)sub_histroy tabnle ");
            
                
            
            
        }
    }
      else if (!([flage rangeOfString:@"patrol_point"].location==NSNotFound))
      {
          if (!([strResponse rangeOfString:@"Success"].location == NSNotFound))
          {
              
          }
          else 
          {
               NSLog(@"Patrol points failed to sync"); 
          }
      }
    
    [responseDic setObject:strResponse forKey:flage];
    [self Uploading:@"COUNTINUE.."];
}

-(void)filedWithError:(NSString *)strMsg forFlage:(NSString *)flage
{
     CurrentUpLoading++;
    [responseDic setObject:strMsg forKey:[NSString stringWithFormat:@"%@",flage]];
    [self Uploading:@"COUNTINUE.."];  
}



-(UIView*)AlertWithMessage:(NSString *)msg
{
	
	UIView *alertView = [[UIView alloc] init];
    
    [alertView setBackgroundColor:[UIColor clearColor]];
    
	UIView *tempView = [[UIView alloc] init];
	
	UIView *backImage = [[UIView alloc] init];
	
	actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 50, 20, 20)];
	
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		[alertView setFrame:screenBounds];
		[tempView setFrame:CGRectMake(0, 0, 200, 200)];
		[actView setFrame:CGRectMake(alertView.center.x-20, alertView.center.y-30, 40, 40)];
		[[tempView layer] setCornerRadius:40];
 	}
    else
    {

		[alertView setFrame:screenBounds];
		[tempView setFrame:CGRectMake(0, 0, 100, 100)];
		[actView setFrame:CGRectMake(alertView.center.x-10, alertView.center.y-30, 20, 20)];
		[[tempView layer] setCornerRadius:10];
        
        lblPercentage = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,44)];
        lblPercentage.text = [NSString stringWithFormat:@"%d %%",00];
        
        [lblPercentage setTextColor:[UIColor whiteColor]];
        [lblPercentage setBackgroundColor:[UIColor purpleColor]];
        
 	}
    
    [alertView addSubview:lblPercentage];
	
	[backImage setFrame:[alertView frame]];
	[backImage setBackgroundColor:[UIColor blackColor]];
    [backImage setAlpha:0.5];
	[alertView addSubview:backImage];
	
	[tempView setBackgroundColor:[UIColor blackColor]];
	
	tempView.center = alertView.center;
	UILabel *lblMessage = [CommonFunctions LabelWithText:msg andFrame:0 :tempView.frame.size.height-50 :tempView.frame.size.width :50];
	[lblMessage setTextColor:[UIColor whiteColor]];
	[lblMessage setTextAlignment:UITextAlignmentCenter];
	[tempView addSubview:lblMessage];
	
	[alertView addSubview:tempView];
	[alertView addSubview:actView];
    
	[actView startAnimating];
	
	[lblMessage release];
	[backImage release];
	return alertView;
    
}


@end
