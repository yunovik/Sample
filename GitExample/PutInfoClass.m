//
//  PutInfoClass.m
//  ElogBooks
//
//  Created by i-Verve on 25/12/12.
//  Copyright (c) 2012 nayanmist@gmail.com. All rights reserved.
//

#import "PutInfoClass.h"

@implementation PutInfoClass

@synthesize strUrl,strWebService,argsDic,_delegate;
@synthesize ParentNode,ChildNode;
@synthesize retType,isImage;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
	
}

-(void)setArrayPOST
{
    
	isStart = NO;
	isFound = NO;
    
	
	mainDic=[[NSMutableDictionary alloc] init];
	
	NSURL *url = [NSURL URLWithString:strUrl];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	
	[theRequest setURL:url];
	[theRequest setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithFormat:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
//    mainUrlString = [mainUrlString stringByAppendingFormat:@"app_version=%@&app_device=iPhone",versionString];    

    //    CLLocationCoordinate2D coordinate = [CommonFunctions GetCoordinates];
    //    [dic setObject:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"03:lat"];
    //    [dic setObject:[NSString stringWithFormat:@"%f",coordinate.longitude]forKey:@"04:lon"];
        [argsDic setObject:versionString forKey:@"96:app_version"];
        [argsDic setObject:@"iPhone" forKey:@"97:app_device"];
//static    
//    CLLocationCoordinate2D coordinate = [CommonFunctions GetCoordinates];
//    [argsDic setObject:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"101:lat"];
//    [argsDic setObject:[NSString stringWithFormat:@"%f",coordinate.longitude]forKey:@"102:lon"];
    
    
	NSArray *keys=[[NSArray alloc] initWithArray:[argsDic allKeys]];
	
	NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
	keys=[keys sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
	
	
    NSString *mainUrlString=[[NSString stringWithFormat:@"%@?",strUrl] retain];

	for(int i=0;i<[keys count];i++){
		
		NSString *newStr=[keys objectAtIndex:i];
		NSRange end = [newStr rangeOfString:@":"];
		NSString *Key=[newStr substringFromIndex:end.location+1];
		
        
		if([Key isEqualToString:@"ImageString"] && NO)
        {
			[body appendData:[@"Content-Disposition: form-data; name=\"userfile\";filename=\"ipodfi.pdf\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSLog(@"\n\n  New String : %@",newStr);
            NSLog(@"\n\n  Key String : %@",Key);

            NSString *strBase64 = [argsDic objectForKey:newStr];
            NSLog(@"\n\n  Value String : %@",strBase64);

			[body appendData:[argsDic objectForKey:newStr]];
		}else{
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",Key] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[argsDic objectForKey:newStr] dataUsingEncoding:NSUTF8StringEncoding]];
            
            mainUrlString=[mainUrlString stringByAppendingFormat:@"%@=%@&",Key,[argsDic objectForKey:newStr]];

		}
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
	[theRequest setHTTPBody:body];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    
    NSLog(@"\n\n=================================================================\n\nWeb Service Name: %@ \nFull Url Service: %@ \n\n =================================================================\n\n",strWebService,mainUrlString);
    
    if(theConnection ) {
		webData = [[NSMutableData data] retain];
	}
}


-(void)setArray
{
    
	isStart = NO;
	isFound = NO;
	
	mainDic=[[NSMutableDictionary alloc] init];
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    [argsDic setObject:versionString forKey:@"96:app_version"];
    [argsDic setObject:@"iPhone" forKey:@"97:app_device"];
//static
//CLLocationCoordinate2D coordinate = [CommonFunctions GetCoordinates];
//[argsDic setObject:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"101:lat"];
//[argsDic setObject:[NSString stringWithFormat:@"%f",coordinate.longitude]forKey:@"102:lon"];
    
    
	NSArray *keys=[[NSArray alloc] initWithArray:[argsDic allKeys]];
	
	NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
	keys=[keys sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
	
	
	NSString *mainUrlString=[[NSString stringWithFormat:@"%@?",strUrl] retain];

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
    

    
   
    
    
//    mainUrlString = [mainUrlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString:[mainUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	[theRequest setURL:url];
	[theRequest setHTTPMethod:@"GET"];
    
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	mainUrlString=[mainUrlString substringToIndex:[mainUrlString length]-1];
    
    NSLog(@"\n\n=================================================================\n\nWeb Service Name: %@ \nFull Url Service: %@ \n\n =================================================================\n\n",strWebService,mainUrlString);
    
    
    finalUrl = [mainUrlString retain];
    
	if(theConnection ) {
		webData = [[NSMutableData data] retain];
	}
}



#pragma mark -
#pragma mark Connection methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [response expectedContentLength];
	[webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

	[webData release];
	[connection cancel];
    
	[_delegate filedWithError:@"Make sure that you are connected to the Internet." forFlage:strWebService];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    
NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
 NSLog(@"response found.%@",theXML);
    
	xmlParser = [[NSXMLParser alloc] initWithData: webData];
	[xmlParser setDelegate: self];
	[xmlParser setShouldResolveExternalEntities: YES];
	[xmlParser parse];
	[connection release];
}


#pragma mark -
#pragma mark NSXMLParser methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
    
	NSLog(@"\n\n  \t\t %@" ,elementName);
	
	isFound=NO;
	
    if([elementName isEqualToString:ChildNode]) 
	{
        
	}
    else if([elementName isEqualToString:ParentNode]) {
		
		if(mainDic != nil && [mainDic retainCount] > 0) 
        {
			[mainDic release];
			mainDic = nil;
		}
		mainDic = [[NSMutableDictionary alloc] init];
        
        if(arrMain != nil && [arrMain retainCount] > 0) 
        {
			[arrMain release];
			arrMain = nil;
		}
		arrMain = [[NSMutableArray alloc] init];

        
	}
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
    if ([string isEqualToString:@"\n"]) {
        return;
    }
    
	isStart = YES;
	
	if(isFound){
		string = [[strValue stringByAppendingFormat:@"%@",string] retain];	
		strValue = @"";
		[strValue release];
		strValue = nil;
	}else if(strValue != nil && [strValue retainCount] > 0 ) {
		strValue = @"";
		[strValue release];
		strValue = nil;
	}
	
	strValue = [[[NSString alloc] initWithString:string] retain];
	
	isFound=YES;
	
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	isFound=NO;
    
        
    if([elementName isEqualToString:ParentNode])
    {
        NSLog(@"Over...");
    }
    else
    {
        if(strValue != nil && [strValue retainCount] > 0) {
            
            [mainDic setObject:strValue forKey:elementName];
            
            [arrMain addObject:strValue];
            
            strValue = @"";
            [strValue release];
            strValue = nil;
        }
        else
        {
            [mainDic setObject:@"" forKey:elementName];
        }
    }
}

// Parsing....

-(void)parserDidEndDocument:(NSXMLParser *)parser{
	
    
    NSString *strResponse = [[mainDic objectForKey:ChildNode] retain];
    
    if ([strResponse length]<=0) 
    {
        strResponse = [NSString stringWithFormat:@"ERROR : %@",finalUrl];
    }
    else
    {
        //strResponse = [strResponse stringByAppendingFormat:@"\n URL : %@",finalUrl];
    }
    
    NSLog(@"%@",[arrMain description]);
	
    if(_delegate!=nil)
    {
        switch (retType)
        {
            case isArray:
                [_delegate EndParsingArray:arrMain forFlage:strWebService];
                
                break;
            case isDic:
                [_delegate EndParsingDic:mainDic forFlage:strWebService];
                break;
            case isString:
                [_delegate EndParsing:strResponse forFlage:strWebService];
                break;
                
            default:
                
                [_delegate EndParsing:strResponse forFlage:strWebService];

                break;
        } 
    }
    
    
    [mainDic release];
}


// Other 


@end
