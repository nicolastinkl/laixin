//
//  MessageManager.h
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-10.
//

#import <Foundation/Foundation.h>
#import "XCModelAllEntity.h"
@class Chat;
/*消息管理中心 msg manager center*/
@interface MessageManager : NSObject

+(MessageManager *)sharedMessageManager;

//更新Chat
- (void)updateChat:(Chat*)chat;


//私信接收器  //插入新的私信
-(void) handleReceivedMessage_Private:(Message_private_user *) privateMsg from:(NSString *) fromID;
//查询某个用户未读消息
-(int)	QueryUnReadMsgCountInUser:(NSString *) fromID;
//查询所有用户未读信息
-(int)	QueryAllUnReadMsgCount;
//查询所有私信
-(NSArray * ) QueryAllUnReadMsg;
//清空某个用户未读消息
-(void)	ClearUnReadMsgCountInUser:(Message_private_list *) privte_list;
// 分页查询所有私信
-(NSArray * ) QueryDriectMessageWithOffset:(int) offset from:(NSString *) fromID;
-(NSArray * ) QueryDriectMessageAllfrom:(NSString *) fromID;
//声波识别信息
-(void) insertCheckHaveMusic_Private:(Message_music_check *) musicMsg;
//查询所有声波信息
-(NSArray * ) QueryAllHavemusicMsg;
//发送私信
-(void) updateUnreadMessage_Private:(Message_private_user *) privateMsg to:(NSString *) toID;
-(void) insertReceiveMessage_private:(Message_private_user *) privateMsg from:(NSString *) fromId;
-(void) updateMsgStutas_privateErrorby:(NSString *) UUID from:(NSString *) fromId;

//获取当天评论信息
-(NSArray * ) QueryALLCommentMsg;
-(NSArray * ) QueryCommentMsg:(int) offset;
//写入评论
-(void) insertComment_Msg_Private:(Message_Comment_postInfo *) postinfo;
//设置已读
-(void) updateCommentMsgAlreadyread:(Message_Comment_postInfo *) postinfo;
//获取上一次最新一条评论ID
-(int) QueryCommentMsgPreDays;
//更新评论未读条数
-(int) updateCommentUnreadNumber:(Message_Comment_unread *) comment_unreadinfo;
//获取未读评论
-(int) querCommentUnreadNumber;
//情况未读评论
-(void) clearCommentUnreadNumber:(Message_Comment_unread *) comment_unreadinfo;

//获取类型一的所有数据
-(NSArray * ) QueryMessageMusic;
-(NSArray * ) QueryMessageVibrate;
-(void) insertMessageTypeMain:(Message_type_Music *) typeMsg;

//获取所有好友
-(NSArray * ) QueryAllXCFriends;
-(void)	insertXCFriends_new_status:(Friend_New_statuss_all *) friends;
-(void) UpdateXCFriendsUserInfo:(Friend_New_statuss_all * )friends;
-(void) UpdateXCFriendsUnread_status:(Friend_New_statuss_all * )friends;
-(void)	handleXCFriends_new_status:(Friend_New_statuss_all *) friends;
-(void)	deleteXCFriends_new_status:(Friend_New_statuss_all *) friends;
-(NSInteger ) QueryAllXCFriendsHasNewStaus;
// 插入被添加好友
-(NSArray * ) QueryAll_newFans;
// 查询所有被添加好友
-(void)	insertXC_newFans:(notify_new_fans *) friends;

//消息提醒 评论和被添加提醒
-(NSArray * ) QueryAllXCMessage_Activity:(int) offset;
-(NSArray * ) QueryAllXCMessage_Activity_PhotoCommitXC:(int) offset; //照片评论列表
-(NSArray * ) QueryAllXCMessage_Activity_SceneUseXC;		//首次登陆 好友使用现场加
-(NSArray * ) QueryAllXCMessage_Activity_withDate:(NSString*) zdate;
-(void)	insertXCMessage_Activity:(Message_activity *) activity;
-(void) handleXCMessage_Activity:(Message_activity * )activity;
-(void) handleXCMessage_ActivityFromMe:(Message_activity * )activity;
-(void) handleXCMessage_ActivityWithSceneUseXC:(Message_activity * )activity;  //首次登陆 好友在使用现场加
-(void) handleXCMessage_ActivityWithPhotoCommit:(Message_activity * )activity;  // 集成照片评论
//-(void) updateHasReadMessage_activity:(NSInteger) childID;
-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID;
-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID withTableName:(NSString *) tableName;
-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID MinusNumber:(int ) number;
-(void) deleteMessage_activity:(Message_activity *) activity;
-(NSArray * ) QueryAllXCRecommentFriendListUnread;
-(int ) QueryAllXCMessage_ActivityUnReadNmbers;
/*保持所有商圈数据*/
-(NSArray * ) QueryAllXCDomainList;
-(void)	insertXCDomainList:(DomainInfoRecomment *) domaininfo;

//根据domainID插入数据
-(NSArray * ) QueryAllXCRecommentSceneWithDomainID:(NSInteger) domainID;
-(void)	insertXCRecommentScene:(RecommentChildScenes *) reScene;

//UserFaviScenes
-(NSArray * ) QueryAllXCFaviList;
-(void)	insertXCFaviList:(UserFaviScenes *) faviscene;
-(void)	deleteXCFaviList:(NSInteger) favisceneID;
//推荐用户 
-(NSArray * ) QueryAllXCRecommentFriendList;
-(Recomment_Friend  * ) QueryAllXCRecommentFriendByUserid:(NSInteger) userid;
-(void)	insertXCRecommentFriend:(Recomment_Friend *) recommentFriend;
-(void) updateXCRecommentFriend:(Recomment_Friend *) recommentFriend;
-(void) updateXCRecommentReadFriend:(Recomment_Friend *) recommentFriend;
@end
