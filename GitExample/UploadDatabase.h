//
//  UploadDatabase.h
//  ElogBooks
//
//  Created by i-Verve on 22/12/12.
//  Copyright (c) 2012 nayanmist@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadDataBaseDelegate

-(void)UploadComplete:(NSMutableDictionary *)_responceDic;
-(void)setProgress:(float)val forFlag:(NSString *)strFlag;

@end

@interface UploadDatabase : NSObject<PutInfoDelegate>
{

    int CurrentUpLoading;
    
    UIView *AalertView;
    UIActivityIndicatorView *actView;
    UILabel *lblPercentage;

    NSMutableArray *arrWebServiceObjects;
    NSMutableDictionary *responseDic;

    id<UploadDataBaseDelegate> _delegate;
    NSMutableArray *arrPickerData;
}

-(void)Uploading:(NSString *)strStatus;

@property(retain,nonatomic)NSMutableArray *arrWebServiceObjects;
@property (nonatomic, assign) id<UploadDataBaseDelegate> _delegate;



@end
