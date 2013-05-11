//
//  PutInfoClass.h
//  ElogBooks
//
//  Created by i-Verve on 25/12/12.
//  Copyright (c) 2012 nayanmist@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PutInfoDelegate

@optional

-(void)EndParsingDic:(NSMutableDictionary *)arrData forFlage:(NSString *)flage;
-(void)EndParsingArray:(NSMutableArray *)arrData forFlage:(NSString *)flage;

-(void)EndParsing:(NSString *)strResponse forFlage:(NSString *)flage;

-(void)filedWithError:(NSString *)strMsg forFlage:(NSString *)flage;


@end

typedef enum {
    isArray,
    isDic,
    isString,
} returnType;


@interface PutInfoClass : NSObject <NSXMLParserDelegate>
{
    
    id<PutInfoDelegate> _delegate;
    
    
    NSString *strParent,*strSubParent,*strWebService,*strUrl;
    
    NSString *strKey;
    
    NSMutableArray *arrKeys,*arrMain;
    
    
    NSMutableDictionary *mainDic,*argsDic,*subDic;
    
    BOOL isFound,isTag;
    
    BOOL isStart;
    
    NSMutableData *webData;
    NSXMLParser *xmlParser;	
    NSString *strValue;
    
    NSString *strPropertyName;
    
    
    NSString *finalUrl;
}


@property (nonatomic, assign) id<PutInfoDelegate> _delegate;

@property (assign,nonatomic) returnType retType;

@property (assign,nonatomic) BOOL isImage;


@property (nonatomic, retain) NSString *strWebService,*strUrl;
@property (nonatomic, retain) NSString *ParentNode,*ChildNode;

@property (nonatomic, retain) NSDictionary *argsDic;

-(void)setArray;
-(void)setArrayPOST;

@end
