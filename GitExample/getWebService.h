//
//  getWebService.h
//  MedEntry
//
//  Created by Mac-1 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MYXMLParserDelegate

@optional

-(void)EndParsing:(NSMutableArray *)arrData forFlage:(NSString *)flage;
//-(void)filedWithError:(NSString *)strMsg;
-(void)filedWithError:(NSString *)strMsg forFlage:(NSString *)flage;
@end


@interface getWebService : NSObject <NSXMLParserDelegate>{
	
	///UIAlertView *alert;
	
	id<MYXMLParserDelegate> _delegate;
    
    UIActivityIndicatorView *actView;
    UIView *AalertView;
    
	NSString *strParent,*strSubParent,*strSoapMessage,*strWebService,*strUrl;
	
	NSMutableArray *mainArray,*arrKeys,*subArray;
	NSMutableDictionary *mainDic,*argsDic,*subDic;
	
	BOOL isFound,isTag,isSubDic,isSubArr;
	
	NSMutableArray *arraySubTags;
	
	NSString *strSubDicTag,*strSubArrTag;
	
	BOOL isSubStart,isStart;
	int subCnt;
	
	NSMutableData *webData; 
	NSXMLParser *xmlParser;	
	NSString *strTemp; 
    
	NSString *strPropertyName; 
}

@property (nonatomic, assign) id<MYXMLParserDelegate> _delegate;
@property (nonatomic, assign) BOOL DontShowAlert;
@property (nonatomic, retain) NSString *strParent,*strSubParent,*strSoapMessage,*strWebService,*strPropertyName,*strUrl;
@property (nonatomic, retain) NSDictionary *argsDic;
@property (nonatomic, retain) NSMutableArray *arrKeys,*arraySubTags;



-(NSMutableArray *)getArray;
-(void)setArray;
//-(void)getArray;
@end
