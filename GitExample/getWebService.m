//
//  getWebService.m
//  MedEntry
//
//  Created by Mac-1 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "getWebService.h"

@implementation getWebService

@synthesize strUrl,strParent,strSubParent,strSoapMessage,strWebService,arraySubTags,argsDic,_delegate,arrKeys,strPropertyName,DontShowAlert;

-(NSMutableArray *)getArray{
	return mainArray;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
	
}

-(void)setArray
{
    UIViewController *_self = (UIViewController *)_delegate;
    if (!DontShowAlert)
    {
        AalertView = [CommonFunctions AlertWithMessage:@"Please wait...."];
        [_self.view addSubview:AalertView];
    }
	isStart = NO;
	isFound = NO;
	subCnt=1;
	mainArray=[[NSMutableArray alloc] init];
	mainDic=[[NSMutableDictionary alloc] init];
	subArray=[[NSMutableArray alloc] init];
    
    
	NSArray *keys=[[NSArray alloc] initWithArray:[argsDic allKeys]];
	
	NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
	keys=[keys sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
	
	
	NSString *mainUrlString=[[NSString stringWithFormat:@"%@?",strUrl] retain];
    
    //  NSURL *url = [NSURL URLWithString:mainUrlString]; 
    //  NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    //	[theRequest setURL:url];
    //	[theRequest setHTTPMethod:@"POST"];
    //
    //    
    //    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    //	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    //	[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    //	
    //	NSMutableData *body = [NSMutableData data];
    //	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
	for(int i=0;i<[keys count];i++)
    {
        
		NSString *newStr=[keys objectAtIndex:i];
		NSRange end = [newStr rangeOfString:@":"];
		NSString *temp=[newStr substringFromIndex:end.location+1];
        
        //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",temp] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[argsDic objectForKey:newStr] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        mainUrlString=[mainUrlString stringByAppendingFormat:@"%@=%@&",temp,[argsDic objectForKey:newStr]];
	}
    
    mainUrlString = [mainUrlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString:[mainUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setURL:url];
	[theRequest setHTTPMethod:@"GET"];
    
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	mainUrlString=[mainUrlString substringToIndex:[mainUrlString length]-1];
    
    NSLog(@"\n\n=================================================================\n\nWeb Service Name: %@ \nFull Url Service: %@ \n\n =================================================================\n\n",strWebService,mainUrlString);
    
	if(theConnection ) {
		webData = [[NSMutableData data] retain];
	}
    
}

-(UIView*)AlertWithMessage:(NSString *)msg{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	UIView *alertView = [[UIView alloc] init];
	UIView *tempView = [[UIView alloc] init];
	
	UIView *backImage = [[UIView alloc] init];
	
	actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 50, 20, 20)];
	
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		[alertView setFrame:screenBounds];
		[tempView setFrame:CGRectMake(0, 0, 200, 200)];
		[actView setFrame:CGRectMake(alertView.center.x-20, alertView.center.y-30, 40, 40)];
		[[tempView layer] setCornerRadius:40];
		
 	} else {
        

		[alertView setFrame:screenBounds];
		[tempView setFrame:CGRectMake(0, 0, 100, 100)];
		[actView setFrame:CGRectMake(alertView.center.x-10, alertView.center.y-30, 20, 20)];
		[[tempView layer] setCornerRadius:10];
 	}
	
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


#pragma mark -
#pragma mark Connection methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

	[webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  
	[webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    //	[AlertView HideAlert];
    //	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert!!!" message:@"Make sure that you are connected to the Internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //	av.tag = 1;
    //	[av show];
    //	[av release];
    //	[connection release];
	[webData release];
	[connection cancel];
	//if(![strWebService isEqualToString:@"GetCountries"])
    //[AlertView HideAlert];
    if (!DontShowAlert)
        [AalertView removeFromSuperview];
    
	[_delegate filedWithError:@"Make sure that you are connected to the Internet." forFlage:strWebService];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    
    NSString *theXML = [[[NSString alloc]initWithBytes: [webData mutableBytes] length: [webData length] encoding:NSUTF8StringEncoding]autorelease];
    
    NSData *DataToParse =  [[[NSData alloc]initWithData:[theXML dataUsingEncoding:NSUTF8StringEncoding]]autorelease];
//    [DataToParse retain];
	xmlParser = [[NSXMLParser alloc] initWithData: DataToParse] ;

	[xmlParser setDelegate: self];
	[xmlParser setShouldResolveExternalEntities: YES];
	[xmlParser parse];
	[connection release];
    
//NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
// NSLog(@"response found.%@",theXML);
}


#pragma mark -
#pragma mark NSXMLParser methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
    
//	NSLog(@"\n\n  \t\t %@" ,elementName);
	
	isFound=NO;
	
	BOOL isTempParentTag=NO,isTempChildTag=NO;
	
	if([arraySubTags count]>0){  
		
		for(int i=0;i<[arraySubTags count];i++){
			NSMutableDictionary *dic = [arraySubTags objectAtIndex:i];	
			
			if([[dic valueForKey:@"ParentTag"] isEqualToString:elementName]){
				isTempParentTag = YES;
			}else if([[dic valueForKey:@"ChildTag"] isEqualToString:elementName]){
				isTempChildTag = YES;
			}
			//[dic release];
		}
	}
	
	if([elementName isEqualToString:strSubParent]) 
	{
		if(mainDic != nil && [mainDic retainCount] > 0) {
			[mainDic release];
			mainDic = nil;
		}
		
		mainDic = [[NSMutableDictionary alloc] init];
		
	}else if([elementName isEqualToString:strParent]) {
		
		if(mainArray != nil && [mainArray retainCount] > 0) {
			[mainArray release];
			mainArray = nil;
		}
		mainArray = [[NSMutableArray alloc] init];
	}else if(isTempChildTag){
        //else if([elementName isEqualToString:@"Testimonials"] ||[elementName isEqualToString:@"ProviderServiceList"] ) {
		
		isSubDic = YES;
		
		if(subDic != nil && [subDic retainCount] > 0) {
			[subDic release];
			subDic = nil;
		}
		
		subDic = [[NSMutableDictionary alloc] init];
		
	}else if(isTempParentTag){
        //else if([elementName isEqualToString:@"ProviderTestimonials"] || [elementName isEqualToString:@"ServicesList"]) {
		
		if(subArray != nil && [subArray retainCount] > 0) {
			[subArray release];
			subArray = nil;
		}
		subArray = [[NSMutableArray alloc] init];
	}
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	isStart = YES;
	
	isSubStart = NO;
	
	if(isFound){
		string = [[strTemp stringByAppendingFormat:@"%@",string] retain];	
		strTemp = @"";
		[strTemp release];
		strTemp = nil;
	}else if(strTemp != nil && [strTemp retainCount] > 0 ) {
		strTemp = @"";
		[strTemp release];
		strTemp = nil;
	}
	
	strTemp = [[[NSString alloc] initWithString:string] retain];
	
	isFound=YES;
	
	//NSLog(@"strTemp : %@",strTemp);
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	isFound=NO;
	isSubStart = NO;
    
	BOOL isTempParentTag=NO,isTempChildTag=NO;
	
	if([arraySubTags count]>0){  
		
		for(int i=0;i<[arraySubTags count];i++){
			
			NSMutableDictionary *dic = [arraySubTags objectAtIndex:i];	
			if([[dic valueForKey:@"ParentTag"] isEqualToString:elementName]){
				isTempParentTag = YES;
			}else if([[dic valueForKey:@"ChildTag"] isEqualToString:elementName]){
				isTempChildTag = YES;
			}
		}
		
	}
	
	//if([elementName isEqualToString:@"Testimonials"] || [elementName isEqualToString:@"ProviderServiceList"]){
	
	if(isTempChildTag){
		
		//[mainDic setObject:subDic forKey:elementName];
		
		[subArray addObject:subDic];
		
		if(subDic != nil && [subDic retainCount] > 0) {
			[subDic release];
			subDic = nil;
		}
		
		isSubDic = NO;
		
	}//else if([elementName isEqualToString:@"ProviderTestimonials"] ||[elementName isEqualToString:@"ServicesList"]){
	
	else if(isTempParentTag){
		
		[mainDic setObject:subArray forKey:elementName];
		
		if(subArray != nil && [subArray retainCount] > 0) {
			[subArray release];
			subArray = nil;
		}
		
		isSubArr = NO;
		subCnt =1;
		
	}
	else if([elementName isEqualToString:strSubParent]) {
		
		isStart= NO;
        
        [mainArray addObject:mainDic];
        
        if(mainDic != nil && [mainDic retainCount] > 0) {
            [mainDic release];
            mainDic = nil;
        }
        //		}
		
	}else if(strTemp != nil && [strTemp retainCount] > 0) {
		
		if(isSubDic){
			[subDic setObject:strTemp forKey:elementName];
		}else {
			[mainDic setObject:strTemp forKey:elementName];
		}
		strTemp = @"";
		[strTemp release];
		strTemp = nil;
	}
	else {
		if(isSubDic){
			[subDic setObject:@"" forKey:elementName];
		}else {
			[mainDic setObject:@"" forKey:elementName];
		}
	}
}

// Parsing....

-(void)parserDidEndDocument:(NSXMLParser *)parser{
	
	//[alert dismissWithClickedButtonIndex:0 animated:YES];
    if (!DontShowAlert)
        [AalertView removeFromSuperview];
    
	if([strSubParent isEqualToString:@"NULL"])
	{
		[mainArray addObject:mainDic];
	}else if([mainArray count]<=0){
		mainArray=[[NSMutableArray alloc] init];
	}
	
	//NSLog(@"Main Array : %@",[mainArray description]);
	//NSLog(@"Responce : %@",strTemp);
    if(_delegate!=nil)
        [_delegate EndParsing:mainArray	forFlage:strWebService];
}

@end
