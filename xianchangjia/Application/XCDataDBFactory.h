//
//  XCDataDBFactory.h
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-9.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "SandboxFile.h"
#import "FMDatabaseQueue.h"


typedef enum
{
    FSO_Dialogs_Priate_letter_singl,	//私信单个信息
	FSO_Dialogs_Priate_letter_list,		//私信列表（多人）  包括未读消息
	FSO_Dialogs_Priate_Browse_info,		//浏览好友信息
	FSO_Dialogs_Priate_letter_Attent,   //添加好友提醒
	FSO_Dialogs_Priate_Browse_letter,   //浏览好友资料提醒
	FSO_Dialogs_Comment_unread,			//评论 未读
	FSO_Dialogs_Comment_list,			//评论列表 信息提醒
	FSO_Have_music_check,				//声波识别
	FSO_Mesage_Music,					//种类型
	FSO_All_XCfriend,					//所有现场加好友
	FSO_New_fans,						//新被添加好友
	FSO_Message_activity,				//新动态 多类型结构
	FSO_Domain_scenses,					//商圈
	FSO_scense_single,					//推荐现场对应商圈
	FSO_scense_favi,					//收藏现场
	FSO_Recomment_user,					//推荐用户
    FSO_Kidswant_Table,
}
FSO;//这个是枚举是区别不同的实体
 

//现场加 数据工厂处理类
@interface XCDataDBFactory : NSObject
@property(retain,nonatomic)id classValues;
+(XCDataDBFactory *)shardDataFactory;
//是否存在数据库
-(BOOL)IsDataBase:(NSString *) databasename;
//创建数据库
-(void)CreateDataBase:(NSString *) databasename;
//创建表
//-(void)CreateTableClasstype:(FSO)type tableName:(NSString*) name;
//添加数据
-(void)insertToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name;
//修改数据
-(void)updateToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name;
-(void)updateToDBWithSql:(NSString *)update Classtype:(FSO)type tableName:(NSString*) name;
//删除单条数据
-(void)deleteToDB:(id)Model Classtype:(FSO)type tableName:(NSString*) name;
//删除表的数据
-(void)clearTableData:(FSO)type tableName:(NSString*) name;
//根据条件删除数据
-(void)deleteWhereData:(NSDictionary *)Model Classtype:(FSO)type tableName:(NSString*) name;
//查找数据
-(void)searchWhere:(NSDictionary *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type tableName:(NSString*) name callback:(void(^)(NSArray *))result;
-(void)searchWhereBySql:(NSString *)where orderBy:(NSString *)columeName offset:(int)offset count:(int)count Classtype:(FSO)type tableName:(NSString*) name callback:(void(^)(NSArray *))result;
-(void)searchAllClasstype:(FSO)type tableName:(NSString*) name block:(void(^)(NSArray*))callback;
-(void) closeDatabase;

@end
