//
//  XCDataDBFactory.m
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-9.
//
//

#import "XCDataDBFactory.h"
#import "LKDaoBase.h"
#import "XCAlbumDefines.h"
#import "GlobalData.h"

//#define GetDataBasePath [SandboxFile GetPathForCaches:@"xianchangjia_ForCache5.db" inDir:@"DataBaseCache"]
static FMDatabaseQueue* queue;
@interface XCDataDBFactory()
{
	NSString * GetDataBasePath;
}
@end
@implementation XCDataDBFactory
@synthesize classValues;
+(XCDataDBFactory *)shardDataFactory
{
    static id ShardInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ShardInstance=[[self alloc] init];
    });
    return ShardInstance;
}

-(BOOL)IsDataBase:(NSString *) databasename
{
	GetDataBasePath = [SandboxFile GetPathForCaches:databasename inDir:@"DataBaseCache"];
    BOOL Value=NO;
    if (![SandboxFile IsFileExists:GetDataBasePath])
    {
        Value=YES;
    }
    return Value;
}

-(void) closeDatabase
{
	if (queue) {
		[queue close];
		SLog(@"closeDatabase databaseName");
	}
}

-(void)CreateDataBase:(NSString *) databasename
{
	GetDataBasePath = [SandboxFile GetPathForCaches:databasename inDir:@"DataBaseCache"];
    queue=[[FMDatabaseQueue alloc] initWithPath:GetDataBasePath];
}


-(void)CreateTableClasstype:(FSO)type tableName:(NSString*) name
{ 
}

-(id)Factory:(FSO)type tableName:(NSString*) name
{
    id result;
    queue=[[FMDatabaseQueue alloc]initWithPath:GetDataBasePath];
    switch (type)
    {
        case FSO_Kidswant_Table:
//            result=[[LKDAOBase alloc] initWithDBQueue:queue tableName:name model:[KidswantDBModels class]];
            break;
		
        default:
            break;
    }
    return result;
}
 
//添加数据
-(void)insertToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
    [classValues insertToDB:Model callback:^(BOOL Values)
     {
         NSLog(@"insert ok");
     }];
}

-(void)updateToDBWithSql:(NSString *)update Classtype:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
	[classValues updateToDBWithSql:update callback:^(BOOL Values) {
	}];
}
//修改数据
-(void)updateToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
    [classValues updateToDB:Model callback:^(BOOL Values)
     { 
		
     }];
}
//删除单条数据
-(void)deleteToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
    [classValues deleteToDB:Model callback:^(BOOL Values)
     {
         NSLog(@"删除 BOOL:%d  name :%@",Values,name);
     }];
}
//删除表的数据
-(void)clearTableData:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
    [classValues clearTableData];
    NSLog(@"删除全部数据");
}
//根据条件删除数据
-(void)deleteWhereData:(NSDictionary *)Model Classtype:(FSO)type tableName:(NSString*) name
{
	self.classValues=[self Factory:type tableName:name];
    [classValues deleteToDBWithWhereDic:Model callback:^(BOOL Values)
     {
         NSLog(@"删除成功");
     }];
}
//查找数据
-(void)searchWhere:(NSDictionary *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type tableName:(NSString*) name callback:(void(^)(NSArray *))result
{
	self.classValues=[self Factory:type tableName:name];
    [classValues searchWhereDic:where orderBy:columeName offset:offset count:count callback:^(NSArray *array)
     {
         result(array);
     }];
}

-(void)searchAllClasstype:(FSO)type tableName:(NSString*) name block:(void(^)(NSArray*))callback
{
	self.classValues=[self Factory:type tableName:name];
    [classValues searchAll:^(NSArray * array) {
		callback(array);
	}];
}
-(void)searchWhereBySql:(NSString *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type tableName:(NSString*) name callback:(void(^)(NSArray *))result
{
	self.classValues=[self Factory:type tableName:name];
    [classValues searchWhere:where orderBy:columeName offset:offset count:count callback:^(NSArray * result_new) {
		result(result_new);
	}];
}
 
@end


