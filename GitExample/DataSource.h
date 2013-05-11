//
//  DataSource.h
//  Cave
//
//  Created by Mac-1 on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DataSource : UIViewController {
    
}

+(NSMutableArray*)getRecords:(NSString *)arrKeys From:(NSString *)tblName;
+(NSMutableArray*)getAllDataFrom:(NSString *)sqlNsStr;
+(NSMutableArray*)getRecordsFromQuery:(NSString *)sqlNsStrQuery;
+(NSMutableArray*)getDistinctDataFrom:(NSString *)tblName:(NSString *)colName;

+(BOOL)DeletePreviousCopyIfExists:(NSString *)strDBName;

+(void)getDBPath:(NSString *)strDBName;


//+(void)getDBPath ;

+(BOOL)prepareDatabaseForExecuteQuery;
+(void) dehydrateAllAndCloseDB;


-(BOOL)insertArray:(NSMutableArray *)arrData toTable:(NSString *)tableName:(NSString*)IsSynced;
+(BOOL)insertDic:(NSMutableDictionary *)data toTable:(NSString *)tableName;
+(BOOL)updateDic:(NSMutableDictionary *)data toTable:(NSString *)tableName forKey:(NSString *)strCompareKey;

+(BOOL)deleteArray :(NSMutableArray *)arrData toTable:(NSString  *)tableName CompareKey: (NSString *)CompareKeyValue;

+(BOOL)deleteAllRecordFrom:(NSString *)tblName;
+(int)getNumberFromQuery:(NSString*)sqlNsStr;
+(NSString *)getStringFromQuery:(NSString *)sqlNsStrQuery;
+(void)DisableBackup;
+(BOOL)executeQuery:(NSString*)query;
+(BOOL)executeCreateQuery:(NSString*)query;
+(NSInteger)executeInsertQuery :(NSString *)Query:(BOOL)getPreviousId;

@end
