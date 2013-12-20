//
//  MessageManager.m
//  xianchangjiaplus
//
//  Created by JIJIA &&&&& apple on 13-3-10.
//
//

#import "MessageManager.h"
#import "GlobalData.h"
#import "XCDataDBFactory.h"
#import "SINGLETONGCD.h"
#import "XCAlbumDefines.h"
#import "JSONKit.h"
#import "Chat.h"

#define maxCount   10000

#define tableDirectMessage @"tableDirectMessage"   //私信拼接表名称

@implementation MessageManager

SINGLETON_GCD(MessageManager);



//更新Chat到数据库
- (void)updateChat:(Chat*)chat
{
    //更新未读列表 名称 内容 时间
	Message_private_list * userlist = [[Message_private_list alloc] init];
	[userlist setMessage_screent_name:chat.name];
	[userlist setSender_profile_image_url:[chat.avatarURL absoluteString]];
	[userlist setLastMessageText:chat.latestMessage];
	[userlist setCreated_at:[NSString stringWithFormat:@"%g",chat.latestTime]];
	[userlist setChildid:chat.uid];
	[userlist setUnreadMessages:chat.unreadCount];
    
	int res = [self QueryUnReadMsgCountInUser:[NSString stringWithFormat:@"%ul",chat.uid]];
	if (res == MINSIGSTKSZ) {
		[[XCDataDBFactory shardDataFactory]  insertToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}else{
		[[XCDataDBFactory shardDataFactory]  updateToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}
}

-(void) insertReceiveMessage_private:(Message_private_user *) privateMsg from:(NSString *) fromId
{
	//插入当前用户列表
	NSString * tableName= [NSString stringWithFormat:@"%@_%@",tableDirectMessage,fromId];
	[[XCDataDBFactory shardDataFactory]  insertToDB:privateMsg Classtype:FSO_Dialogs_Priate_letter_singl tableName:tableName];
}

-(void) updateMsgStutas_privateErrorby:(NSString *) UUID from:(NSString *) fromId
{
	NSString * tableName= [NSString stringWithFormat:@"%@_%@",tableDirectMessage,fromId];	
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:[NSString stringWithFormat:@"msgStutas = %d where msgUUID = \"%@\"",2,UUID] Classtype:FSO_Dialogs_Priate_letter_list tableName:tableName];
}

-(void) updateUnreadMessage_Private:(Message_private_user *) privateMsg to:(NSString *) toID
{
	//更新未读列表 名称 内容 时间
	Message_private_list * userlist = [[Message_private_list alloc] init];
#pragma mark 他的信息
	[userlist setMessage_screent_name:privateMsg.sender_screen_name];
	[userlist setSender_profile_image_url:privateMsg.sender_profile_image_url];
#pragma mark 我发的
	[userlist setLastMessageText:privateMsg.text];
	[userlist setCreated_at:privateMsg.created_at];
	[userlist setChildid:[toID intValue]];
	[userlist setUnreadMessages:0];
	int res = [self QueryUnReadMsgCountInUser:toID];
	if (res == MINSIGSTKSZ) {
		[[XCDataDBFactory shardDataFactory]  insertToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}else{
		[[XCDataDBFactory shardDataFactory]  updateToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}
}
-(void) handleReceivedMessage_Private:(Message_private_user *) privateMsg from:(NSString *) fromID
{
	Message_private_list * userlist = [[Message_private_list alloc] init];
	[userlist setMessage_screent_name:privateMsg.sender_screen_name];
	[userlist setLastMessageText:privateMsg.text];
	[userlist setSender_profile_image_url:privateMsg.sender_profile_image_url];
	[userlist setCreated_at:privateMsg.created_at];
	[userlist setChildid:[fromID intValue]];
	int res = [self QueryUnReadMsgCountInUser:fromID];
	if (res == MINSIGSTKSZ) {
		[userlist setUnreadMessages:1];
		[[XCDataDBFactory shardDataFactory]  insertToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}else{
		res ++;
		[userlist setUnreadMessages:res];
		[[XCDataDBFactory shardDataFactory]  updateToDB:userlist Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
	}
	
	//int userShowView = [USER_DEFAULT integerForKey:[tools NotPushMsgContainsString:[NSString stringWithFormat:@"%@",fromID]]];
	//if (userShowView == 0) {
		//[BWStatusBarOverlay showWithMessage:[NSString stringWithFormat:@"%@(%d)",privateMsg.sender_screen_name,res] loading:YES animated:NO];
	//}
	
	//notify refresh view
	NSString * tableName= [NSString stringWithFormat:@"%@_%@",tableDirectMessage,fromID];
	[[XCDataDBFactory shardDataFactory]  insertToDB:privateMsg Classtype:FSO_Dialogs_Priate_letter_singl tableName:tableName];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GlobalData_XMPP_DIRECT_MESSAGE_REFERESHTABLE object:userlist];
	
	/*TODO: update message total numbers and notification*/
	int UnResadNumber = [self QueryAllUnReadMsgCount];
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:[NSString stringWithFormat:@"unreadNumber = %d where rowid=%d",UnResadNumber,1] Classtype:FSO_Mesage_Music tableName:table_Message_Music];
}
-(NSArray * ) QueryDriectMessageAllfrom:(NSString *) fromID
{
	__block NSArray * resultArray;
	NSString * tableName= [NSString stringWithFormat:@"%@_%@",tableDirectMessage,fromID];
	[[XCDataDBFactory shardDataFactory]  searchAllClasstype:FSO_Dialogs_Priate_letter_singl tableName:tableName block:^(NSArray * result) {
		resultArray = result;
	}];
	return resultArray;
}

-(NSArray * ) QueryDriectMessageWithOffset:(int) offset from:(NSString *) fromID
{
	__block NSArray * resultArray;
	NSString * tableName= [NSString stringWithFormat:@"%@_%@",tableDirectMessage,fromID];
	[[XCDataDBFactory shardDataFactory]  searchWhere:nil orderBy:@" rowid desc" offset:offset count:20 Classtype:FSO_Dialogs_Priate_letter_singl tableName:tableName callback:^(NSArray * result) {
		resultArray = result;
	}];
	return resultArray;
}

-(int)QueryUnReadMsgCountInUser:(NSString *) fromID
{
	__block int unreadNumber = MINSIGSTKSZ;
	NSDictionary * pamers =@{@"childid":fromID};
	[[XCDataDBFactory shardDataFactory] searchWhere:pamers orderBy:nil offset:0 count:maxCount Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_private_list * MessageList = [result lastObject];
			unreadNumber = MessageList.unreadMessages;
		}else{
			unreadNumber = MINSIGSTKSZ;
		}
	}];	
	return unreadNumber;
}

-(int)QueryUnReadMsgCountInUser_activity_msg:(NSInteger) fromID
{
	__block int unreadNumber = MINSIGSTKSZ;
	NSDictionary * pamers =@{@"privateMsgchildid":@(fromID)};
	[[XCDataDBFactory shardDataFactory] searchWhere:pamers orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_activity * MessageList = [result lastObject];
			unreadNumber = MessageList.privateMsgunreadMessages;
		}else{
			unreadNumber = MINSIGSTKSZ;
		}
	}];
	return unreadNumber;
}


-(int)QueryUnReadMsgCountInUser_activity_msgByPKID:(NSString *) PKID
{
	__block int unreadNumber = MINSIGSTKSZ;
	NSDictionary * pamers =@{@"zPKID":PKID};
	[[XCDataDBFactory shardDataFactory] searchWhere:pamers orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_activity * MessageList = [result lastObject];
			unreadNumber = MessageList.privateMsgunreadMessages;
		}else{
			unreadNumber = MINSIGSTKSZ;
		}
	}];
	return unreadNumber;
}

-(int)QueryUnReadMsgCountInUser_activity_msgByPKID:(NSString *) PKID withtableName:(NSString *) tableName
{
	__block int unreadNumber = MINSIGSTKSZ;
	NSDictionary * pamers =@{@"zPKID":PKID};
	[[XCDataDBFactory shardDataFactory] searchWhere:pamers orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:tableName callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_activity * MessageList = [result lastObject];
			unreadNumber = MessageList.privateMsgunreadMessages;
		}else{
			unreadNumber = MINSIGSTKSZ;
		}
	}];
	return unreadNumber;
}
-(int)	QueryAllUnReadMsgCount
{
	__block int umreadNumber  = 0 ;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info block:^(NSArray * result) {
		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			Message_private_list * MessageList = obj;
				umreadNumber += MessageList.unreadMessages;
		}];
	}];
	return  umreadNumber;
}

-(NSArray * ) QueryAllUnReadMsg
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(void)	ClearUnReadMsgCountInUser:(Message_private_list *) privte_list
{
//	[privte_list setUnreadMessages:0];
	[[XCDataDBFactory shardDataFactory]  updateToDB:privte_list Classtype:FSO_Dialogs_Priate_letter_list tableName:table_chat_message_list_info];
}

-(void) insertCheckHaveMusic_Private:(Message_music_check *) musicMsg
{
	[[XCDataDBFactory shardDataFactory] insertToDB:musicMsg Classtype:FSO_Have_music_check tableName:table_Have_check_message];
	
}

-(NSArray * ) QueryAllHavemusicMsg
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Have_music_check tableName:table_Have_check_message block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}


-(NSArray * ) QueryALLCommentMsg
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory]  searchAllClasstype:FSO_Dialogs_Comment_list tableName:table_commit_photo_message block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(NSArray * ) QueryCommentMsg:(int) offset
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhere:nil orderBy:nil offset:offset count:10 Classtype:FSO_Dialogs_Comment_list tableName:table_commit_photo_message callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

//写入评论
-(void)insertComment_Msg_Private:(Message_Comment_postInfo *) postinfo
{
	[[XCDataDBFactory shardDataFactory] insertToDB:postinfo Classtype:FSO_Dialogs_Comment_list tableName:table_commit_photo_message];
}

-(void) updateCommentMsgAlreadyread:(Message_Comment_postInfo *) postinfo
{
	[[XCDataDBFactory shardDataFactory] updateToDB:postinfo Classtype:FSO_Dialogs_Comment_list tableName:table_commit_photo_message];
}

-(int) QueryCommentMsgPreDays
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhere:nil orderBy:@" rowid desc" offset:0 count:1 Classtype:FSO_Dialogs_Comment_list tableName:table_commit_photo_message callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	if (msgArray && msgArray.count > 0) {
		Message_Comment_postInfo *postinfo = [msgArray lastObject];
		return postinfo.comment_id;
	}
	return 0;
}

-(int) updateCommentUnreadNumber:(Message_Comment_unread *) comment_unreadinfo
{
	__block int blockunreadNumber;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Dialogs_Comment_unread tableName:table_commit_photo_message_Unread block:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_Comment_unread * unreadInfo = [result objectAtIndex:0];
			int unreadNumber = unreadInfo.comment_unread_number;
			unreadNumber += comment_unreadinfo.comment_unread_number;
			comment_unreadinfo.comment_unread_number = unreadNumber;// update unread numbers
			blockunreadNumber = unreadNumber;
			[[XCDataDBFactory shardDataFactory] updateToDB:comment_unreadinfo Classtype:FSO_Dialogs_Comment_unread tableName:table_commit_photo_message_Unread];
			
		}else{
			[[XCDataDBFactory shardDataFactory] insertToDB:comment_unreadinfo Classtype:FSO_Dialogs_Comment_unread tableName:table_commit_photo_message_Unread];
			blockunreadNumber = comment_unreadinfo.comment_unread_number;
		}
	}];
	return blockunreadNumber;
	
}
-(int) querCommentUnreadNumber
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Dialogs_Comment_unread tableName:table_commit_photo_message_Unread block:^(NSArray * result) {
		msgArray = result;
	}];

	if (msgArray && msgArray.count > 0) {
		Message_Comment_unread *postinfo = [msgArray lastObject];
		return postinfo.comment_unread_number;
	}
	return 0;
}

-(void) clearCommentUnreadNumber:(Message_Comment_unread *) comment_unreadinfo
{
	[[XCDataDBFactory shardDataFactory] updateToDB:comment_unreadinfo Classtype:FSO_Dialogs_Comment_unread tableName:table_commit_photo_message_Unread];
}

-(void) insertMessageTypeMain:(Message_type_Music *) typeMsg
{
	[[XCDataDBFactory shardDataFactory] insertToDB:typeMsg Classtype:FSO_Mesage_Music tableName:table_Message_Music];
}

-(NSArray * ) QueryMessageVibrate
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"type":@"1"} orderBy:nil offset:0 count:10 Classtype:FSO_Mesage_Music tableName:table_Message_Music callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(NSArray * ) QueryMessageMusic
{
	__block NSArray * msgArray; 
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"type":@"0"} orderBy:nil offset:0 count:10 Classtype:FSO_Mesage_Music tableName:table_Message_Music callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(NSArray * ) QueryAllXCFriends
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhere:nil orderBy:@" user_update_time desc" offset:0 count:maxCount Classtype:FSO_All_XCfriend tableName:table_All_XCFriends  callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;	
}

//提示好友新动态
-(NSInteger ) QueryAllXCFriendsHasNewStaus
{
	//Select * from table_All_XCFriends where user_unReadNumber > "0"
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhereBySql:@" user_unReadNumber > 0" orderBy:nil offset:0 count:maxCount Classtype:FSO_All_XCfriend tableName:table_All_XCFriends  callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	
	 NSArray * msgAddFriendArray = [self QueryAllXCRecommentFriendListUnread];
		
	return msgArray.count + msgAddFriendArray.count;
}

-(void)	insertXCFriends_new_status:(Friend_New_statuss_all *) friends
{
	[[XCDataDBFactory shardDataFactory] insertToDB:friends Classtype:FSO_All_XCfriend tableName:table_All_XCFriends];
}

-(void)	handleXCFriends_new_status:(Friend_New_statuss_all *) friends
{
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"user_id":@(friends.user_id)} orderBy:nil offset:0 count:1 Classtype:FSO_All_XCfriend tableName:table_All_XCFriends  callback:^(NSArray * result) {
		if (result.count <= 0) {			
			[[XCDataDBFactory shardDataFactory] insertToDB:friends Classtype:FSO_All_XCfriend tableName:table_All_XCFriends];
		}
	}];
}

-(void)	deleteXCFriends_new_status:(Friend_New_statuss_all *) friends
{
	[[XCDataDBFactory shardDataFactory] deleteToDB:friends Classtype:FSO_All_XCfriend tableName:table_All_XCFriends];
}

-(void) UpdateXCFriendsUserInfo:(Friend_New_statuss_all * )friends
{			
	NSString *  updateSQL = [NSString stringWithFormat:@" user_json='%@', user_name='%@',user_sign='%@',user_url='%@' where user_id='%d'",friends.user_json,friends.user_name,friends.user_sign,friends.user_url,friends.user_id];
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:updateSQL Classtype:FSO_All_XCfriend tableName:table_All_XCFriends];
}

-(void) UpdateXCFriendsUnread_status:(Friend_New_statuss_all * )friends
{
	//update table_All_XCFriends set user_unReadNumber = 2 ,user_photo_ids=1069778,user_update_time='2013-03-25 07:55:24',user_hasread = 1   where user_id = "198"
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:[NSString stringWithFormat:@"user_unReadNumber = %d , user_hasread = %d , user_update_time='%@' , user_photo_ids='%@' where user_id=%d",friends.user_unReadNumber,friends.user_hasread,friends.user_update_time,friends.user_photo_ids,friends.user_id] Classtype:FSO_All_XCfriend tableName:table_All_XCFriends];
}

// 插入被添加好友
-(NSArray * ) QueryAll_newFans
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_New_fans tableName:table_All_XCNewFans block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

// 查询所有被添加好友
-(void)	insertXC_newFans:(notify_new_fans *) friends
{
	[[XCDataDBFactory shardDataFactory] insertToDB:friends Classtype:FSO_New_fans tableName:table_All_XCNewFans];
}

-(NSArray * ) QueryAllXCMessage_Activity:(int) offset
{
	__block NSArray * resultArray;
	[[XCDataDBFactory shardDataFactory]  searchWhere:nil orderBy:@" zdate desc" offset:offset count:maxCount Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		resultArray = result;
	}];
	return resultArray;
}

-(NSArray * ) QueryAllXCMessage_Activity_SceneUseXC		//首次登陆 好友使用现场加
{
	__block NSArray * resultArray;
	[[XCDataDBFactory shardDataFactory]  searchWhere:nil orderBy:@" zdate desc" offset:0 count:maxCount Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_UserUseXC callback:^(NSArray * result) {
		resultArray = result;
	}];
	return resultArray;
}
-(NSArray * ) QueryAllXCMessage_Activity_PhotoCommitXC:(int) offset //照片评论列表
{
	__block NSArray * resultArray;
	[[XCDataDBFactory shardDataFactory]  searchWhere:nil orderBy:@" zdate desc" offset:offset count:10 Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_PhotoCommit callback:^(NSArray * result) {
		resultArray = result;
	}];
	return resultArray;
}

-(int ) QueryAllXCMessage_ActivityUnReadNmbers
{
	__block int unread;
	unread = 0;
	[[XCDataDBFactory shardDataFactory]  searchWhereBySql:@" privateMsgunreadMessages > 0" orderBy:nil offset:0 count:maxCount Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		if (result.count > 0 ) {
			[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				Message_activity *objmsg = obj;
				int unreadnumber = objmsg.privateMsgunreadMessages;
				unread += unreadnumber; 
			}];
		}else{
			unread = 0;
		}
	}];
	
	return unread;
}


-(NSArray * ) QueryAllXCMessage_Activity_withDate:(NSString*) zdate
{	
	__block NSArray * resultArray;
	[[XCDataDBFactory shardDataFactory]  searchWhereBySql:[NSString stringWithFormat:@"zdate > '%@'",zdate] orderBy:nil offset:0 count:maxCount Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		resultArray = result;
	}];
	 
	return resultArray;
}

-(void)	insertXCMessage_Activity:(Message_activity *) activity
{
	[[XCDataDBFactory shardDataFactory] insertToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
}

//从我发出私信
-(void) handleXCMessage_ActivityFromMe:(Message_activity * )activity
{
	NSString * str;
	NSDictionary * parems = @{@"zPKID":activity.zPKID};
	int nums = [self querySomeXCMessage_Activity:parems];
	if (nums == MINSIGSTKSZ) {
		str = @"add";
		[[XCDataDBFactory shardDataFactory] insertToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
	}else{
		str = @"update";
		[[XCDataDBFactory shardDataFactory]  updateToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];		
	}
	NSDictionary * dic = @{@"type":@(XCMessageActivity_photocomment),@"key":str,@"value":activity};
	[[NSNotificationCenter defaultCenter] postNotificationName:GlobalData_XMPP_COMMITPHOTO object:nil userInfo:dic];
}

-(void) handleXCMessage_Activity:(Message_activity * )activity
{
	NSString * str;
	NSDictionary * parems = @{@"zPKID":activity.zPKID};
	int nums = [self querySomeXCMessage_Activity:parems];
	if (nums == MINSIGSTKSZ) {
		//insert
		str = @"add";
		switch (activity.zmessagetypeid) {
			case XCMessageActivity_UserPrivateMessage:
			case XCMessageActivity_SceneBusniessMessage:
			case XCMessageActivity_SceneSmallanchor:
			{
				[activity setPrivateMsgunreadMessages:1];
				NSData * data = [activity.zother_json dataUsingEncoding:NSUTF8StringEncoding];
				NSDictionary *resjson=[data objectFromJSONData];
				Message_private_user * privateMsg ;
				if (resjson) {
					privateMsg = [[Message_private_user alloc] initWithJsonDictionary:resjson];
				}else{
					privateMsg = [[Message_private_user alloc] init];
					//created_at,text,recipient_id,sender_id,sender_profile_image_url,sender_screen_name;
					privateMsg.created_at = activity.zdate;
					privateMsg.text = activity.privateMsgLastMessageText;
					privateMsg.recipient_id = [USER_DEFAULT integerForKey:GlobalData_user_id];
					privateMsg.sender_id = activity.privateMsgchildid;
					privateMsg.sender_profile_image_url = activity.privateMsgSendUrl;
					privateMsg.sender_screen_name = activity.privateMsg_screent_name;
				}
				activity.zmessageHasread = 0;
				NSString * tableName= [NSString stringWithFormat:@"%@_%d",tableDirectMessage,activity.privateMsgchildid];
				[[XCDataDBFactory shardDataFactory]  insertToDB:privateMsg Classtype:FSO_Dialogs_Priate_letter_singl tableName:tableName];
			}
				break;
				default:
			{
					activity.zmessageHasread = 0;
					[activity setPrivateMsgunreadMessages:1];
			}
				break;
		} 
		[[XCDataDBFactory shardDataFactory] insertToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
	}else{
		//update
		str = @"update";
		activity.zmessageHasread = 0;
		switch (activity.zmessagetypeid) {
			case XCMessageActivity_UserPrivateMessage:   //私信消息
			case XCMessageActivity_SceneBusniessMessage: //商家消息
			case XCMessageActivity_SceneSmallanchor:	 //小主播消息
			{
				int res = [self QueryUnReadMsgCountInUser_activity_msg:activity.privateMsgchildid];
				res ++;
				[activity setPrivateMsgunreadMessages:res];
				
				NSData * data = [activity.zother_json dataUsingEncoding:NSUTF8StringEncoding];
				NSDictionary *resjson=[data objectFromJSONData];
				Message_private_user * privateMsg ;
				if (resjson) {
					privateMsg = [[Message_private_user alloc] initWithJsonDictionary:resjson];
				}else{
					privateMsg = [[Message_private_user alloc] init];
//					created_at,text,recipient_id,sender_id,sender_profile_image_url,sender_screen_name;
					privateMsg.created_at = activity.zdate;
					privateMsg.text = activity.privateMsgLastMessageText;
					privateMsg.recipient_id = [USER_DEFAULT integerForKey:GlobalData_user_id];
					privateMsg.sender_id = activity.privateMsgchildid;
					privateMsg.sender_profile_image_url = activity.privateMsgSendUrl;
					privateMsg.sender_screen_name = activity.privateMsg_screent_name;
				}
				
				NSString * tableName= [NSString stringWithFormat:@"%@_%d",tableDirectMessage,activity.privateMsgchildid];
				[[XCDataDBFactory shardDataFactory]  insertToDB:privateMsg Classtype:FSO_Dialogs_Priate_letter_singl tableName:tableName];
			}
				break;
			case XCMessageActivity_beingAddingFriends:  //被添加好友信息
			case XCMessageActivity_photocomment:		//评论
			case XCMessageActivity_MusicCheckin:		//声波签到
			{
				activity.zmessageHasread = 0;
				int res = [self QueryUnReadMsgCountInUser_activity_msgByPKID:activity.zPKID];
				res ++;
				[activity setPrivateMsgunreadMessages:res];
			}
				break;
			case XCMessageActivity_NotityUserUseXC:  //首次登陆提示那些 好友正在使用现场加
			{
				activity.zmessageHasread = 0;
				[activity setPrivateMsgunreadMessages:1];
			}
				break;
			default:
				break;
		} 
	}
	[[XCDataDBFactory shardDataFactory]  updateToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
	NSDictionary * dic = @{@"type":@(XCMessageActivity_photocomment),@"key":str,@"value":activity};
	[[NSNotificationCenter defaultCenter] postNotificationName:GlobalData_XMPP_COMMITPHOTO object:nil userInfo:dic];
}

-(void) handleXCMessage_ActivityWithSceneUseXC:(Message_activity * )activity  //首次登陆 好友在使用现场加
{
	NSString * str;
	NSDictionary * parems = @{@"zPKID":activity.zPKID};
	int nums = [self querySomeXCMessage_Activity:parems withTableName:table_All__Notity_Message_activity_UserUseXC];
	if (nums == MINSIGSTKSZ) {
		//insert
		str = @"add";
		activity.zmessageHasread = 0;
		[activity setPrivateMsgunreadMessages:1];
		[[XCDataDBFactory shardDataFactory] insertToDB:activity Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_UserUseXC];
	}else{
		//update
		str = @"update";
		activity.zmessageHasread = 0;		
		[activity setPrivateMsgunreadMessages:1];
	}
	[[XCDataDBFactory shardDataFactory]  updateToDB:activity Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_UserUseXC];
//	NSDictionary * dic = @{@"type":@(XCMessageActivity_photocomment),@"key":str,@"value":activity};
//	[[NSNotificationCenter defaultCenter] postNotificationName:GlobalData_XMPP_COMMITPHOTO object:nil userInfo:dic];
}

-(void) handleXCMessage_ActivityWithPhotoCommit:(Message_activity * )activity  // 集成照片评论
{
	NSString * str;
	NSDictionary * parems = @{@"zPKID":activity.zPKID};
	int nums = [self querySomeXCMessage_Activity:parems withTableName:table_All__Notity_Message_activity_PhotoCommit];
	if (nums == MINSIGSTKSZ) {
		//insert
		str = @"add";
		activity.zmessageHasread = 0;
		[activity setPrivateMsgunreadMessages:1];
		[[XCDataDBFactory shardDataFactory] insertToDB:activity Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_PhotoCommit];
	}else{
		//update
		str = @"update";
		activity.zmessageHasread = 0;
		int res = [self QueryUnReadMsgCountInUser_activity_msgByPKID:activity.zPKID withtableName:table_All__Notity_Message_activity_PhotoCommit];
		res ++;
		[activity setPrivateMsgunreadMessages:res];
	}
	[[XCDataDBFactory shardDataFactory]  updateToDB:activity Classtype:FSO_Message_activity tableName:table_All__Notity_Message_activity_PhotoCommit];
}

-(void) deleteMessage_activity:(Message_activity *) activity
{
	[[XCDataDBFactory shardDataFactory] deleteToDB:activity Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
}

-(int) querySomeXCMessage_Activity:(NSDictionary * ) parems
{
	__block int querynumber = MINSIGSTKSZ;
	[[XCDataDBFactory shardDataFactory] searchWhere:parems orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_activity * MessageList = [result lastObject];
			querynumber = MessageList.rowid;
		}else{
			querynumber = MINSIGSTKSZ;
		}
	}];
	return querynumber;
}

-(int) querySomeXCMessage_Activity:(NSDictionary * ) parems withTableName:(NSString *) tableName
{
	__block int querynumber = MINSIGSTKSZ;
	[[XCDataDBFactory shardDataFactory] searchWhere:parems orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:tableName callback:^(NSArray * result) {
		if (result && result.count > 0) {
			Message_activity * MessageList = [result lastObject];
			querynumber = MessageList.rowid;
		}else{
			querynumber = MINSIGSTKSZ;
		}
	}];
	return querynumber;
}
-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID withTableName:(NSString *) tableName
{
	NSString * sql = [NSString stringWithFormat:@"privateMsgunreadMessages = 0,zmessageHasread = 1 where zPKID = '%@'",PKID];
	[[XCDataDBFactory shardDataFactory]  updateToDBWithSql:sql Classtype:FSO_Message_activity tableName:tableName];
}

//减去评论数量
-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID MinusNumber:(int ) number
{
	//privateMsgunreadMessages > 0 where
	__block int unread;
	unread = 0;
	[[XCDataDBFactory shardDataFactory]  searchWhereBySql:[NSString stringWithFormat:@" zPKID = '%@'",PKID] orderBy:nil offset:0 count:1 Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity callback:^(NSArray * result) {
		if (result.count > 0 ) {
			Message_activity *objmsg = result[0];
			unread = objmsg.privateMsgunreadMessages;
		}else{
			unread = 0;
		}
	}];
	unread -= number;
	if (unread>=0) {
		NSString * sql;
		if (unread == 0) {
			sql = [NSString stringWithFormat:@"privateMsgunreadMessages = %d,zmessageHasread = 1 where zPKID = '%@'",unread,PKID];
		}else{
			sql = [NSString stringWithFormat:@"privateMsgunreadMessages = %d where zPKID = '%@'",unread,PKID];
		}
		[[XCDataDBFactory shardDataFactory]  updateToDBWithSql:sql Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
	}
}

-(void) updateHasReadMessage_activityWithPKID:(NSString *) PKID
{
	//zPKID,zmessageHasread
	NSString * sql = [NSString stringWithFormat:@"privateMsgunreadMessages = 0,zmessageHasread = 1 where zPKID = '%@'",PKID];
	[[XCDataDBFactory shardDataFactory]  updateToDBWithSql:sql Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
}

//修改已读状态
-(void) updateHasReadMessage_activity:(NSInteger) childID
{
	NSString * sql = [NSString stringWithFormat:@"privateMsgunreadMessages = 0,zmessageHasread = 1 where privateMsgchildid = %d",childID];
	[[XCDataDBFactory shardDataFactory]  updateToDBWithSql:sql Classtype:FSO_Message_activity tableName:table_All_XCMessage_activity];
}


-(NSArray * ) QueryAllXCDomainList
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_Domain_scenses tableName:table_All_XCDomain_scense block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(void)	insertXCDomainList:(DomainInfoRecomment *) domaininfo
{
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"area_id":@(domaininfo.area_id)} orderBy:@"" offset:0 count:1 Classtype:FSO_Domain_scenses tableName:table_All_XCDomain_scense callback:^(NSArray * result)
	{
		if (result && result.count > 0) {
			// filter duplicate data ...
		}else{
			[[XCDataDBFactory shardDataFactory] insertToDB:domaininfo Classtype:FSO_Domain_scenses tableName:table_All_XCDomain_scense];
		}
	}];
}

//根据domainID插入数据
-(NSArray * ) QueryAllXCRecommentSceneWithDomainID:(NSInteger) domainID
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"area_paretID":@(domainID)} orderBy:@"" offset:0 count:100 Classtype:FSO_scense_single tableName:table_All_XCRecomment_scense callback:^(NSArray * result)
	 {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(void)	insertXCRecommentScene:(RecommentChildScenes *) reScene
{ 
	[[XCDataDBFactory shardDataFactory] searchWhere:@{@"sceneID":@(reScene.sceneID)} orderBy:@"" offset:0 count:1 Classtype:FSO_scense_single tableName:table_All_XCRecomment_scense callback:^(NSArray * result)
	 {
		 if (result && result.count > 0) {
			 // filter duplicate data ...
		 }else{
//			 [tools playVibrate];
			 [[XCDataDBFactory shardDataFactory] insertToDB:reScene Classtype:FSO_scense_single tableName:table_All_XCRecomment_scense];
		 }
	 }];
}



-(NSArray * ) QueryAllXCFaviList
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory] searchAllClasstype:FSO_scense_favi tableName:table_All_XCFavi_scense block:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}
-(void)	insertXCFaviList:(UserFaviScenes *) faviscene
{
	[[XCDataDBFactory shardDataFactory] insertToDB:faviscene Classtype:FSO_scense_favi tableName:table_All_XCFavi_scense];
}

-(void)	deleteXCFaviList:(NSInteger) favisceneID
{
	[[XCDataDBFactory shardDataFactory] deleteWhereData:@{@"sceneID":@(favisceneID)} Classtype:FSO_scense_favi tableName:table_All_XCFavi_scense];
}

-(NSArray * ) QueryAllXCRecommentFriendList
{
	__block NSArray * msgArray; 
	[[XCDataDBFactory shardDataFactory]  searchWhere:nil orderBy:@" user_update_time desc" offset:0 count:maxCount  Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(NSArray * ) QueryAllXCRecommentFriendListUnread
{
	__block NSArray * msgArray;
	[[XCDataDBFactory shardDataFactory]  searchWhere:@{@"user_hasread":@(0)} orderBy:nil offset:0 count:maxCount  Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user callback:^(NSArray * result) {
		if (result) {
			msgArray = result;
		}
	}];
	return msgArray;
}

-(Recomment_Friend  * ) QueryAllXCRecommentFriendByUserid:(NSInteger) userid
{
	__block Recomment_Friend* returnFriend;
	[[XCDataDBFactory shardDataFactory] searchWhereBySql:[NSString stringWithFormat:@" user_id = %d",userid] orderBy:nil offset:0 count:1 Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user callback:^(NSArray * result)
	 {
		 if (result && result.count > 0) {
			 // filter duplicate data ...
			 returnFriend = result[0];
		 }
	 }];
	return returnFriend;
}

-(void)	insertXCRecommentFriend:(Recomment_Friend *) recommentFriend
{
	Recomment_Friend* returnFriend = [self QueryAllXCRecommentFriendByUserid:recommentFriend.user_id];
	if (returnFriend && returnFriend.user_id > 0) {
	}else{

		[[XCDataDBFactory shardDataFactory] insertToDB:recommentFriend Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user];
		[[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_recommentNewUser" object:recommentFriend]; 
//		[BWStatusBarOverlay showWithMessage:@"为您推荐了一位好友" loading:YES animated:NO];
	}

}

//设置已读状态
-(void) updateXCRecommentReadFriend:(Recomment_Friend *) recommentFriend
{
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:[NSString stringWithFormat:@"user_hasread = 1 where user_id = %d",recommentFriend.user_id] Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user];
}

-(void) updateXCRecommentFriend:(Recomment_Friend *) recommentFriend
{
	[[XCDataDBFactory shardDataFactory] updateToDBWithSql:[NSString stringWithFormat:@"user_hasBeingAdd = 1 where user_id = %d",recommentFriend.user_id] Classtype:FSO_Recomment_user tableName:table_All_XCRecomment_user];
}

@end
