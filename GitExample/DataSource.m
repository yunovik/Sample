//
//  DataSource.m
//  Cave
//
//  Created by Mac-1 on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataSource.h"
#import <sqlite3.h>

static sqlite3 *masterDB;
static NSString *dbPath;
sqlite3_stmt *cmp_sqlStmt,*addStmt;
sqlite3 *database;


static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *init_statement_for_Select = nil;

static sqlite3_stmt *hydrate_statement = nil;

@implementation DataSource

#pragma mark --- +(void)getDBPath

#pragma mark --- Delete Previous Database if Exists
+(BOOL)DeletePreviousCopyIfExists:(NSString *)strDBName
{
    NSArray *docPaths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    
	NSString *docDir=[docPaths objectAtIndex:0];
    
    [docDir retain];
	dbPath=[[docDir stringByAppendingPathComponent:strDBName] retain];
    
    BOOL success,isdeleted;
    NSFileManager *fm=[NSFileManager defaultManager];
    success=[fm fileExistsAtPath:dbPath];
    if (success) //already exists
    {       
        NSError *error = nil;
        isdeleted =   [fm removeItemAtPath:dbPath error:&error];
        if (isdeleted)
            NSLog(@"previous copy deleted");
        else 
            NSLog(@"Problem in deletion of previous copy");            
        return isdeleted;
    }
    NSLog(@"previous copy doesnt exists");
    return success;
}

#pragma mark --- +(void)getDBPath


+(void)getDBPath:(NSString *)strDBName
{
	
    NSArray *docPaths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    
	NSString *docDir=[docPaths objectAtIndex:0];
    
    [docDir retain];
	dbPath=[[docDir stringByAppendingPathComponent:strDBName] retain];
    
    
	BOOL success;
    
	NSFileManager *fm=[NSFileManager defaultManager];
    
	success=[fm fileExistsAtPath:dbPath];
    
    
	if(success) 
    {
        [ElogBooksAppDelegate setRefresh:NO];
        return;
    }
    
    [ElogBooksAppDelegate setRefresh:YES];
    
	NSString *dbPathFromApp=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:strDBName];
    
	[fm copyItemAtPath:dbPathFromApp toPath:dbPath error:nil];
    
    
    /*
     
     NSString *dbPath = [NSMutableString stringWithFormat:@"%@/Library/Application Support/", NSHomeDirectory()];
     
     NSURL *guidesURL = [NSURL fileURLWithPath:guidesPath];
     [guidesURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:NULL];
     
     */
    
}

#pragma mark --- Disable Backup
+(void)DisableBackup
{
    //    NSArray *docPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *docDir=@"";
    
    NSString *os5 = @"5.0";
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedAscending) //lower than 4
    {
        docDir = path;
        return ;
    }
    else if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedDescending) //5.0.1 and above
    {
        docDir = path;
    }
    else // IOS 5
    {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
        docDir = path;
    }
    //
    NSArray *libPaths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
	NSString *libDir=[libPaths objectAtIndex:0];
    
    NSError *error = nil;
    NSURL *guidesURL = [NSURL fileURLWithPath:docDir];
    
    BOOL succedded =    [guidesURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:NULL];
    if(!succedded){
        NSLog(@"Error excluding %@ from backup %@", [guidesURL lastPathComponent], error);
    }
    //    
    //    //Disable Library Folder
    guidesURL = [NSURL fileURLWithPath:libDir];
    BOOL succedded1 =    [guidesURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:NULL];
    
    if(!succedded1){
        NSLog(@"Error excluding %@ from backup %@", [guidesURL lastPathComponent], error);
    }
}


#pragma mark ---+(void) initializeDatabase

+(BOOL)prepareDatabaseForExecuteQuery
{
    
	if(sqlite3_open([dbPath UTF8String], &masterDB) == SQLITE_OK){
		NSLog(@"\n Data Base Opened....");
        return YES;
	}
	
    return NO;
    
}

#pragma mark --- -(void) dehydrateAllAndCloseDB
+(void) dehydrateAllAndCloseDB
{
	sqlite3_stmt *pStmt;
	//[self initializeDatabase];
	while((pStmt = sqlite3_next_stmt(masterDB, 0))!=0){
		sqlite3_finalize(pStmt);
	}
	sqlite3_close(masterDB);
}





#pragma mark ---

-(void)didReceiveMemoryWarning 
{
	NSLog(@"Recive memory warning in datasource file... Please fix it first...");
    [super didReceiveMemoryWarning];
}

-(BOOL)insertArray:(NSMutableArray *)arrData toTable:(NSString *)tableName:(NSString*)IsSynced
{
    
    //    if ([tableName isEqualToString:TBL_MAI_CAT_TO_CATES])
    //        NSLog(@"TBL_MAI_CAT_TO_CATES table received");
    
	NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
	int bunch = 499;
	
	BOOL newQuery = true;
	
	
	
	NSMutableString *exeQuery = [NSMutableString stringWithFormat:@""];
	
	
	
	NSMutableDictionary *keyData = [arrData objectAtIndex:0];
	
    [keyData setObject:IsSynced forKey:@"IsSynced"];
    //	[keyData removeObjectForKey:@"statement"]; 
    //	[keyData removeObjectForKey:@"datetime_stamp"];
	
	NSMutableArray *keys=[[NSMutableArray alloc] initWithArray:[keyData allKeys]];
	
	
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"Insert into %@ (",tableName];
	
	if(keys!=nil)
	{
		int i=0;
		for(;i<[keys  count]-1;i++)
		{
			[query appendString:[NSString stringWithFormat:@"%@,",[keys objectAtIndex:i]]];
        }
        
		[query appendString:[NSString stringWithFormat:@"%@)",[keys objectAtIndex:i]]];
	}
	
	int m=0;
	
	while ([arrData count]!=0) {
		
        if (newQuery) {
            
            exeQuery = [NSMutableString stringWithFormat: @"%@",query];
            newQuery = false;
            
        }
        else 
        {
            [exeQuery appendString:@" UNION"];
            
        }
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[arrData objectAtIndex:0]];
        
        //        [data removeObjectForKey:@"statement"];
        //        [data removeObjectForKey:@"datetime_stamp"];
        [data setObject:IsSynced forKey:@"IsSynced"];
        
        NSMutableString *strVal = [NSMutableString stringWithFormat:@""];
        NSMutableString *_value = [NSMutableString stringWithFormat:@""];
        
        int i=0;
		for(;i<[keys  count]-1;i++)
		{
			if(_value==nil || _value==NULL){
				_value=[NSMutableString stringWithFormat:@""];
			}
            
            
            
			_value=[NSMutableString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
			[_value replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_value length])];
            
            
            if([_value isEqualToString:@"\n"]) 
            {
             _value=[NSMutableString stringWithFormat:@""];   
            }
			
			[strVal appendString:[NSString stringWithFormat:@"'%@',",_value]];
            
		}
		
        
        if(_value==nil || _value==NULL){
            
			_value=[NSMutableString stringWithFormat:@""];
        }
        
        _value=[NSMutableString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
		
		[_value replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_value length])];
        
        if([_value isEqualToString:@"\n"]) 
        {
            _value=[NSMutableString stringWithFormat:@""];   
        }

		[strVal appendString:[NSString stringWithFormat:@"'%@'",_value]];
        
        
        
        [exeQuery appendString:[NSString stringWithFormat:@" SELECT %@",strVal]];
        
        if (m!=0 && m%bunch==0) {
            
             if  ([DataSource executeQuery:exeQuery])
            NSLog(@"Inserted %d vallues ", m  );
               else 
            NSLog(@"Problem in %d of %@ ", m,tableName  );                   
            newQuery = true;
        }
        
        [data release];
		
        [arrData removeObjectAtIndex:0];
        
        m++;
    }	
	//executing remaining lines
	[keys release];
    if (m%bunch!=0) 
    {
          if   ([DataSource executeQuery:exeQuery])
         NSLog(@"Inserted %d vallues ", m  ); 
        else 
            NSLog(@"Problem in %d of %@ ", m,tableName  );     
    }
	
	[pool drain];
	return YES;
}



+(BOOL)updateDic:(NSMutableDictionary *)data toTable:(NSString *)tableName forKey:(NSString *)strCompareKey
{
    
	BOOL val=YES;
    
    [data removeObjectForKey:@"statement"];
    [data removeObjectForKey:@"datetime_stamp"];
    
    
    
	NSMutableArray *keys=[[NSMutableArray alloc] initWithArray:[data allKeys]];
    
	NSString *query=[NSString stringWithFormat:@"Update %@ set ",tableName];
	NSString *_value=@"";
	
	if(keys!=nil)
	{
		int i=0;
		for(;i<[keys  count]-1;i++)
		{
            
			if(_value==nil || _value==NULL){
				_value=@"";
			}
            
			_value=[NSString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
			_value=[_value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
			
			query=[query stringByAppendingFormat:@"%@='%@',",[keys objectAtIndex:i],_value];
		}
		
		if(_value==nil || _value==NULL)
        {
			_value=@"";
		}
		
		_value=[NSString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
		_value=[_value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		
        query=[query stringByAppendingFormat:@"%@='%@'",[keys objectAtIndex:i],_value];
	}
	
	
    if([strCompareKey length]>0)
    {
        query=[query stringByAppendingFormat:@" Where %@=%@ ",strCompareKey,[data objectForKey:strCompareKey]];
    }
	
	
	//NSLog(@"\n\nQuery :%@",query);
	
	const char *sql = [query cStringUsingEncoding:NSUTF8StringEncoding];
	if (sqlite3_prepare_v2(masterDB, sql, -1, &hydrate_statement, NULL) == SQLITE_OK) {
		int success = sqlite3_step(hydrate_statement);
		sqlite3_reset(hydrate_statement);
		if (success != SQLITE_DONE) {
			//NSLog(@"Error: failed to excecute query domain with message '%s'.", sqlite3_errmsg(masterDB));
			val=NO;
		}
	}
	else
    {
		//NSAssert1(0, @"Error while creating add statement. '%@'", sqlite3_errmsg(masterDB));
		val=NO;
	}
	
	sqlite3_reset(hydrate_statement);
	sqlite3_finalize(hydrate_statement);
	[keys release];
	
    return val;
	
}

+(BOOL)insertDic:(NSMutableDictionary *)data toTable:(NSString *)tableName;
{
	BOOL val=NO;
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        
        val=YES;
        
        NSMutableArray *keys=[[NSMutableArray alloc] initWithArray:[data allKeys]];
        
        NSString *query=[NSString stringWithFormat:@"Insert into %@ (",tableName];
        NSString *append=[NSString stringWithFormat:@"Values ("];
        NSString *_value=@"";
        
        if(keys!=nil)
        {
            int i=0;
            for(;i<[keys  count]-1;i++)
            {
                
                if(_value==nil || _value==NULL){
                    _value=@"";
                }
                
                _value=[NSString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
                _value=[_value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                query=[query stringByAppendingFormat:@"%@,",[keys objectAtIndex:i]];
                append=[append stringByAppendingFormat:@"'%@',",_value];
            }
            
            if(_value==nil || _value==NULL)
            {
                _value=@"";
            }
            
            _value=[NSString stringWithFormat:@"%@",[data objectForKey:[keys objectAtIndex:i]]];
            _value=[_value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            query=[query stringByAppendingFormat:@"%@)",[keys objectAtIndex:i]];
            append=[append stringByAppendingFormat:@"'%@')",_value];
        }
        
        
        query=[query stringByAppendingFormat:@"%@",append];
        
        //NSLog(@"\n\nQuery :%@",query);
        
        const char *sql = [query cStringUsingEncoding:NSUTF8StringEncoding];
        if (sqlite3_prepare_v2(masterDB, sql, -1, &hydrate_statement, NULL) == SQLITE_OK) {
            int success = sqlite3_step(hydrate_statement);
            if (success == SQLITE_DONE)
            {
              int last_id = sqlite3_last_insert_rowid(masterDB);
            }
            sqlite3_reset(hydrate_statement);
            if (success != SQLITE_DONE) {
                //NSLog(@"Error: failed to excecute query domain with message '%s'.", sqlite3_errmsg(masterDB));
                val=NO;
            }
        }
        else{
            //NSAssert1(0, @"Error while creating add statement. '%@'", sqlite3_errmsg(masterDB));
            val=NO;
        }
        
        sqlite3_reset(hydrate_statement);
        sqlite3_finalize(hydrate_statement);
        [keys release];
        
        [self dehydrateAllAndCloseDB];
    }
    
	return val;
	
}

//Select Image from totalImages Where Image='abc';

+(BOOL)checkImage:(NSString *)img
{
	
	int sum=0;
	BOOL val;
	
	NSString *sqlNsStr = [NSString stringWithFormat:@"select count(*) from totalImages where image = '%@'",img];
	
	//NSString *str;
	
	//NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT  sum(Dayrate) FROM tbl_Events where strftime('%m',dStartDate)= '12'"];
	const char *sql = [sqlNsStr cStringUsingEncoding:NSUTF8StringEncoding];
	if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
		while(sqlite3_step(init_statement) == SQLITE_ROW) {
			sum = sqlite3_column_double(init_statement, 0);
		}
		
		
	}
	
	sqlite3_reset(init_statement);
	sqlite3_finalize(init_statement);
	
	if(sum<=0)
	{
		val =NO;
	}else {
		val = YES;
	}
	
	
	//return sum;
	
	return val;
	
}



+(int)getNumberFromQuery:(NSString*)sqlNsStr{
    
    
    int sum=0;
	
	//NSString *sqlNsStr = [NSString stringWithFormat:@"seleCT Count(*) froM %@",tblName];
	//NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT  sum(Dayrate) FROM tbl_Events where strftime('%m',dStartDate)= '12'"];
	const char *sql = [sqlNsStr cStringUsingEncoding:NSUTF8StringEncoding];
    
	if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
		while(sqlite3_step(init_statement) == SQLITE_ROW) {
			sum=sqlite3_column_double(init_statement, 0);
		}
	}
	
	sqlite3_reset(init_statement);
	sqlite3_finalize(init_statement);
	return sum;
    
    // int sum=0;
    
    //	const char *sql = [sqlNsStr cStringUsingEncoding:NSUTF8StringEncoding];
    //    
    //	if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK)
    //    {
    //		while(sqlite3_step(init_statement) == SQLITE_ROW) {
    //			sum=sqlite3_column_double(init_statement, 0);
    //		}
    //	}
    //	
    //	sqlite3_reset(init_statement);
    //	sqlite3_finalize(init_statement);
    //	return sum;
}



+(int)getNumberOfRecords:(NSString*)tblName{
	//[self getDBPath];
	//[self initializeDatabase];
	int sum=0;
	
	NSString *sqlNsStr = [NSString stringWithFormat:@"seleCT Count(*) froM %@",tblName];
	//NSString *sqlNsStr = [NSString stringWithFormat:@"SELECT  sum(Dayrate) FROM tbl_Events where strftime('%m',dStartDate)= '12'"];
	const char *sql = [sqlNsStr cStringUsingEncoding:NSUTF8StringEncoding];
	if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
		while(sqlite3_step(init_statement) == SQLITE_ROW) {
			sum=sqlite3_column_double(init_statement, 0);
		}
		
		
	}
	
	sqlite3_reset(init_statement);
	sqlite3_finalize(init_statement);
	return sum;
}

#pragma mark ---
#pragma mark --- +(BOOL)deleteAllRecordFrom:(NSString *)tblName
//[DataSource deleteArray:arrDelete toTable:strTableNameKey])
+(BOOL)deleteArray :(NSMutableArray *)arrData toTable:(NSString  *)tableName CompareKey: (NSString *)CompareKeyValue
{
        NSAutoreleasePool *pool;
        pool = [[NSAutoreleasePool alloc] init];
        
        
        
        BOOL newQuery = true;
        NSMutableString *exeQuery = [NSMutableString stringWithFormat:@""];
        
        
        int locations_length=[arrData count];
        
        
        NSMutableString *query=[NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE %@ in (",tableName,CompareKeyValue];
        
        int m=0;
        
        for (;m<locations_length; m++) {
            
            
            if (newQuery) {
                
                exeQuery = [NSMutableString stringWithFormat:@"%@",query];
                newQuery = false;
                
            }
            [exeQuery appendString:[NSString stringWithFormat:@"%@,",[[arrData objectAtIndex:m]valueForKey:CompareKeyValue]]];
            
            
            
            if (m!=0 && m%499==0) {
                
                [exeQuery replaceCharactersInRange: NSMakeRange([exeQuery length]-1, 1) withString: @")"];
                if([DataSource executeQuery:exeQuery])
                {
                    NSLog(@"%d : Done",m);
                }else {
                    NSLog(@"%d : Problem",m);
                    
                }
                
                newQuery = true;
            }
        }
        
        //executing remaining lines
        if (m%499!=0) 
        {
            [exeQuery replaceCharactersInRange: NSMakeRange([exeQuery length]-1, 1) withString: @")"];
            
            if([DataSource executeQuery:exeQuery])
            {
                NSLog(@"%d : Done",m);
            }else {
                NSLog(@"%d : Problem",m);
            }  
        }
        [pool drain];
    return YES;
}


+(BOOL)deleteAllRecordFrom:(NSString *)tblName
{
	BOOL val=YES;
	
	NSString *query=[NSString stringWithFormat:@"Delete  from %@",tblName];    
	
	const char *sql = [query cStringUsingEncoding:NSUTF8StringEncoding];
	
	if (sqlite3_prepare_v2(masterDB, sql, -1, &hydrate_statement, NULL) == SQLITE_OK) {
		int success = sqlite3_step(hydrate_statement);
		sqlite3_reset(hydrate_statement);
		if (success != SQLITE_DONE) {
			//NSLog(@"Error: failed to excecute query domain with message '%s'.", sqlite3_errmsg(masterDB));
			val=NO;
		}
	}
	else{
		
		//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(masterDB));
		val=NO;
	}
	
	sqlite3_reset(hydrate_statement);
	sqlite3_finalize(hydrate_statement);
	
	return val;
	
}
#pragma mark ---Execute Create Query 
+(BOOL)executeCreateQuery:(NSString*)query
{
    BOOL isSuccess = TRUE;
    if (sqlite3_open([dbPath UTF8String], &masterDB) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [query UTF8String];
        if (sqlite3_exec(masterDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            isSuccess = FALSE;
            NSLog (@"Failed to create table");
        }
        
        sqlite3_close(masterDB);
    }
    else {
        isSuccess = FALSE;
        NSLog (@"Failed to open/create database");
    } 
    return  isSuccess;
}


#pragma mark --- +(BOOL)executeQuery:(NSString*)query
+(NSInteger)executeInsertQuery :(NSString *)Query:(BOOL)getPreviousId
{
    BOOL val=NO;
    int last_id=0;
    if([self prepareDatabaseForExecuteQuery])    
    {
        val=YES;
        //NSLog(@"\n\nExecuting Query : %@\n\n",query);
        
        const char *sql = [Query cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &hydrate_statement, NULL) == SQLITE_OK) {
            int success = sqlite3_step(hydrate_statement);
            sqlite3_reset(hydrate_statement);
            
            if (getPreviousId)
               last_id  = sqlite3_last_insert_rowid(masterDB);
            if (success != SQLITE_DONE) 
            {
                // 1 Feb // NSLog(@"Error: failed to excecute query domain with message '%s'.", sqlite3_errmsg(masterDB));
                val=NO;
            }
        }
        else{
            // NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(masterDB));
            val=NO;
        }
        
        sqlite3_reset(hydrate_statement);
        sqlite3_finalize(hydrate_statement);
        
        [self dehydrateAllAndCloseDB];
    }
    
    return last_id;

}


+(BOOL)executeQuery:(NSString*)query
{
	
	BOOL val=NO;
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        val=YES;
        //NSLog(@"\n\nExecuting Query : %@\n\n",query);
        
        const char *sql = [query cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &hydrate_statement, NULL) == SQLITE_OK) {
            int success = sqlite3_step(hydrate_statement);
            sqlite3_reset(hydrate_statement);
            
            if (success != SQLITE_DONE) 
            {
                // 1 Feb // NSLog(@"Error: failed to excecute query domain with message '%s'.", sqlite3_errmsg(masterDB));
                val=NO;
            }
        }
        else{
            // NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(masterDB));
            val=NO;
        }
        
        sqlite3_reset(hydrate_statement);
        sqlite3_finalize(hydrate_statement);
        
        [self dehydrateAllAndCloseDB];
    }
    
    return val;
    
}


+(NSString *)getStringFromQuery:(NSString *)sqlNsStrQuery
{
    
    NSString *selectedData=@"";
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        
        const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement_for_Select, NULL) == SQLITE_OK) 
        {
            int cnt=0;
            //NSLog(@"%@",init_statement_for_Select);
            
            while(sqlite3_step(init_statement_for_Select) == SQLITE_ROW) 
            {
                
                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
                //int intCount=sqlite3_column_count(init_statement_for_Select);
                
                
                const char *obj = (const char*)sqlite3_column_text(init_statement_for_Select,0);
                
                if(obj==NULL)
                {
                    selectedData=@"";
                }
                else {
                    selectedData=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement_for_Select,0) encoding:NSUTF8StringEncoding];
                }
                
                
                
                
                
                
                
                [dicSelectedData release];
                cnt++;
            }
        }
        
        sqlite3_reset(init_statement_for_Select);
        sqlite3_finalize(init_statement_for_Select);
        
        [self dehydrateAllAndCloseDB];
        
    }
    return selectedData;
}


//+(NSString *)getStringFromQuery:(NSString *)sqlNsStrQuery
//{
//    
//	NSString *selectedData=@"";
//    
//    if([self prepareDatabaseForExecuteQuery])    
//    {
//        
//        const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
//        
//        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement_for_Select, NULL) == SQLITE_OK) 
//        {
//            int cnt=0;
//            //NSLog(@"%@",init_statement_for_Select);
//            
//            while(sqlite3_step(init_statement_for_Select) == SQLITE_ROW) 
//            {
//                
//                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
//                //int intCount=sqlite3_column_count(init_statement_for_Select);
//                
//                selectedData=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement_for_Select,0) encoding:NSUTF8StringEncoding];
//                
//                [dicSelectedData release];
//                cnt++;
//            }
//        } 
//        
//        sqlite3_reset(init_statement_for_Select);
//        sqlite3_finalize(init_statement_for_Select);
//        
//        [self dehydrateAllAndCloseDB];
//        
//	}
//	return selectedData;
//}


+(NSMutableArray*)getRecordsFromQuery:(NSString *)sqlNsStrQuery
{
    
	NSMutableArray *selectedData=[[NSMutableArray alloc] init];
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        
		const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement_for_Select, NULL) == SQLITE_OK) 
        {
            int cnt=0;
            //NSLog(@"%@",init_statement_for_Select);
            //int temp = sqlite3_step(init_statement_for_Select);
            while(sqlite3_step(init_statement_for_Select) == SQLITE_ROW) 
            {
                
                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
                int intCount=sqlite3_column_count(init_statement_for_Select);
                NSString *strObject=@"";
                NSString *strKey=@"";
                
                NSLog(@"\n==========================================================: %d ",cnt);
                
                if(cnt==805)
                {
                    NSLog(@"add");
                }
                
                for (int k=0; k<intCount; k++) {    
                    
                    @try 
                    {
                        // do something
                        strKey=[NSString stringWithCString:(const char *)sqlite3_column_name(init_statement_for_Select, k)  encoding:NSUTF8StringEncoding];
                        
                    }
                    @catch (NSException *exception)
                    {
                        // error happened! do something about the error state
                        NSLog(@"Error...");
                    }
                    @finally
                    {
                        const char *obj = (const char*)sqlite3_column_text(init_statement_for_Select,k);
                        
                        if(obj==NULL)
                        {
                            strObject=@"";
                        }
                        else {
                            strObject=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement_for_Select,k) encoding:NSUTF8StringEncoding];
                        }
                        
                        //              strObject =[NSString stringWithFormat:@"%i",sqlite3_column_int(init_statement_for_Select, k)];
                        
                        if([strObject length]<=0)
                        {
                            strObject=@"";
                        }
                        
                        [dicSelectedData setObject:strObject forKey:strKey];
                        
                        // do something to keep the program still running properly
                    }
                }
                
                [selectedData addObject:dicSelectedData];
                
                [dicSelectedData release];
                cnt++;
            }
        }
        
        sqlite3_reset(init_statement_for_Select);
        sqlite3_finalize(init_statement_for_Select);
        
        [self dehydrateAllAndCloseDB];
        
    }
	return selectedData;
}



+(NSMutableArray*)getDistinctDataFrom:(NSString *)tblName:(NSString *)colName
{
	
	NSMutableArray *selectedData=[[NSMutableArray alloc] init];
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        
        NSString *sqlNsStrQuery = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@",colName,tblName];
        
        const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
        
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
            int cnt=0;
            while(sqlite3_step(init_statement) == SQLITE_ROW) {
                
                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
                int intCount=sqlite3_column_count(init_statement);
                NSString *strObject=@"";
                NSString *strKey=@"";
                
                NSLog(@"\n==========================================================: %d ",cnt);
                
                for (int k=0; k<intCount; k++) {    
                    
                    strKey=[NSString stringWithCString:(const char *)sqlite3_column_name(init_statement, k)  encoding:NSUTF8StringEncoding];
                    
                    const char *obj = (const char*)sqlite3_column_text(init_statement,k);
                    
                    if(obj==NULL)
                    {
                        strObject=@"";
                    }
                    else {
                        strObject=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement,k) encoding:NSUTF8StringEncoding];
                    }
                    
                    //              strObject =[NSString stringWithFormat:@"%i",sqlite3_column_int(init_statement, k)];
                    
                    if([strObject length]<=0)
                    {
                        strObject=@"";
                    }
                    
                    [dicSelectedData setObject:strObject forKey:strKey];
                }
                [selectedData addObject:dicSelectedData];
                
                [dicSelectedData release];
                cnt++;
            }
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        
        [self dehydrateAllAndCloseDB];
    }
    
	
	return selectedData;
}






+(NSMutableArray*)getRecords:(NSString *)arrKeys From:(NSString *)tblName
{
    
	
	NSMutableArray *selectedData=[[NSMutableArray alloc] init];
    
    if([self prepareDatabaseForExecuteQuery])    
    {
        
        NSString *sqlNsStrQuery = [NSString stringWithFormat:@"SELECT %@ FROM %@",arrKeys,tblName];
        
        const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
        
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
            
            int cnt=0;
            
            while(sqlite3_step(init_statement) == SQLITE_ROW) 
            {
                
                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
                int intCount=sqlite3_column_count(init_statement);
                NSString *strObject=@"";
                NSString *strKey=@"";
                
                NSLog(@"\n==========================================================: %d ",cnt);
                
                if(cnt==805)
                {
                    NSLog(@"add");
                }
                
                for (int k=0; k<intCount; k++) {    
                    
                    
                    strKey=[NSString stringWithCString:(const char *)sqlite3_column_name(init_statement, k)  encoding:NSUTF8StringEncoding];
                    
                    const char *obj = (const char*)sqlite3_column_text(init_statement,k);
                    
                    if(obj==NULL)
                    {
                        strObject=@"";
                    }
                    else {
                        strObject=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement,k) encoding:NSUTF8StringEncoding];
                    }
                    
                    //              strObject =[NSString stringWithFormat:@"%i",sqlite3_column_int(init_statement, k)];
                    
                    if([strObject length]<=0)
                    {
                        strObject=@"";
                    }
                    
                    [dicSelectedData setObject:strObject forKey:strKey];
                }
                
                [selectedData addObject:dicSelectedData];
                [dicSelectedData release];
                
                cnt++;
            }
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        
        [self dehydrateAllAndCloseDB];
    }
    
	
	return selectedData;
	
}


+(NSMutableArray*)getAllDataFrom:(NSString *)tblName
{
	NSMutableArray *selectedData=[[NSMutableArray alloc] init];
	
    if([self prepareDatabaseForExecuteQuery])    
    {
        NSString *sqlNsStrQuery = [NSString stringWithFormat:@"SELECT * FROM %@",tblName];
        
        const char *sql = [sqlNsStrQuery cStringUsingEncoding:NSUTF8StringEncoding];
        
        
        if (sqlite3_prepare_v2(masterDB, sql, -1, &init_statement, NULL) == SQLITE_OK) {
            int cnt=0;
            while(sqlite3_step(init_statement) == SQLITE_ROW) {
                
                NSMutableDictionary *dicSelectedData=[[NSMutableDictionary alloc] init];
                int intCount=sqlite3_column_count(init_statement);
                NSString *strObject=@"";
                NSString *strKey=@"";
                
                NSLog(@"\n==========================================================: %d ",cnt);
                
                for (int k=0; k<intCount; k++) {    
                    
                    strKey=[NSString stringWithCString:(const char *)sqlite3_column_name(init_statement, k)  encoding:NSUTF8StringEncoding];
                    
                    const char *obj = (const char*)sqlite3_column_text(init_statement,k);
                    
                    if(obj==NULL)
                    {
                        strObject=@"";
                    }
                    else {
                        strObject=[NSString stringWithCString:(const char*)sqlite3_column_text(init_statement,k) encoding:NSUTF8StringEncoding];
                    }
                    
                    //              strObject =[NSString stringWithFormat:@"%i",sqlite3_column_int(init_statement, k)];
                    
                    if([strObject length]<=0)
                    {
                        strObject=@"";
                    }
                    
                    [dicSelectedData setObject:strObject forKey:strKey];
                }
                [selectedData addObject:dicSelectedData];
                
                [dicSelectedData release];
                cnt++;
            }
        }
        
        sqlite3_reset(init_statement);
        sqlite3_finalize(init_statement);
        
        
        [self dehydrateAllAndCloseDB];
    }
    
	
	return selectedData;
}


-(void)dealloc {
    
	[super dealloc];
    
}

@end