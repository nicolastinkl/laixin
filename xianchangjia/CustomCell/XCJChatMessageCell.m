//
//  XCJChatMessageCell.m
//  laixin
//
//  Created by apple on 13-12-25.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "XCJChatMessageCell.h"
#import "RemoteImgListOperator.h"
#import "FCMessage.h"
#import "CoreData+MagicalRecord.h"
#import <Foundation/Foundation.h>
#import "LXAPIController.h"
#import "XCAlbumDefines.h"
#import "Conversation.h"
#import "DataHelper.h"
#import "XCAlbumAdditions.h"
#import "MLCanPopUpImageView.h"
@implementation XCJChatMessageCell
@synthesize m_objRemoteImgListOper = _objRemoteImgListOper;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) SendMessageRemoteImgOper:(RemoteImgListOperator *)objOper WithMessage:(NSMutableDictionary *) dict type:(int) type
{

    NSString * guid =  dict[@"MESSAGE_GUID"];
    [self setRemoteImgOper:objOper withGUID:guid];
    SLLog(@"SendMessageRemoteImgOper guid : %@",guid);
    __block NSMutableDictionary *blockDict = [dict mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_objRemoteImgListOper)
        {
            [_objRemoteImgListOper sendMessageGUID:guid ByDict:blockDict withProgress:nil];
        }
    });
  
    
    /*
     
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     dispatch_async(dispatch_get_main_queue(), ^{
     if (_objRemoteImgListOper)
     {
     [_objRemoteImgListOper sendMessageGUID:guid ByDict:blockDict withProgress:nil];
     }else{
     // local
     
     }
     });
     });
     });
     */
    
    
}

- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper  withGUID:(NSString * ) guid
{
    
    NSString * _strSuccNotificationName = [NSString stringWithFormat:@"RemoteImgOperListSucc%@", guid];
    NSString * _strFailedNotificationName = [NSString stringWithFormat:@"RemoteImgOperListFailed%@", guid];
   
        if (_objRemoteImgListOper)
        {
            SLog(@"register not ");            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_strSuccNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_strFailedNotificationName object:nil];
        }else{}
        
        _objRemoteImgListOper = objOper;
        
        if (_objRemoteImgListOper)
        {
            SLog(@"register    %@",_strSuccNotificationName);
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(sendMessageSucc:)
                                                         name:_strSuccNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(sendMessageFail:)
                                                         name:_strFailedNotificationName
                                                       object:nil];
        }
}

#pragma mark - RemoteImgListOper notification
// 响应下载完成的通知，并显示图片。
- (void)sendMessageSucc:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        NSDictionary *dataImg;
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        dataImg = [noti.userInfo objectForKey:strURL];
        if (dataImg) {

            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSInteger indexMsgID = [DataHelper getIntegerValue:dataImg[@"messageId"] defaultValue:0];
            NSString * guid = dataImg[@"MESSAGE_GUID"];
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            NSString * messageId = dataImg[@"messageId"];
            NSString * url = [DataHelper getStringValue:dataImg[@"url"] defaultValue:@""];
            switch ([dataImg[@"messagetype"] intValue]) {
                case messageType_text:
                {
                }
                    break;
                case messageType_image:
                case messageType_map:
                {
                    self.currentMessage.imageUrl = url;
                     UIImageView * imageview_Img = (UIImageView *)[self.contentView subviewWithTag:5];
                    [imageview_Img setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:url Size:160]] placeholderImage:[UIImage imageNamed:@"aio_image_default"]];
//                    imageview_Img.fullScreenImageURL = [NSURL URLWithString:url];
                }
                    break;
                case messageType_audio:
                {
//                    self.currentMessage.audioUrl = url;
//                    NSNumber * audiolength = @([DataHelper getIntegerValue:dataImg[@"length"] defaultValue:0]);
//                    self.currentMessage.audioLength = audiolength;
                }
                    break;
                    
                default:
                    break;
            }
            
            self.currentMessage.messageId = messageId;
            self.currentMessage.messageSendStatus = @0;
            UIActivityIndicatorView * indictorView = (UIActivityIndicatorView *) [self.contentView subviewWithTag:9];
            indictorView.hidden = YES;
            
            UIButton * retryButton = (UIButton *) [self.contentView subviewWithTag:10];
            retryButton.hidden = YES;
            
            NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"messageguid == %@",guid];
            FCMessage * groupMessage = [FCMessage MR_findFirstWithPredicate:parCMDss ];
            if (groupMessage) {
                
                // first delete and  insert
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = self.currentMessage.text;
                msg.sentDate = self.currentMessage.sentDate;
                msg.messageType = self.currentMessage.messageType;
                // message did not come, this will be on rigth
                msg.messageStatus = self.currentMessage.messageStatus;
                msg.messageSendStatus = @(0);
                msg.messageUser = self.currentMessage.messageUser;
                msg.imageUrl = url;
                msg.audioUrl = self.currentMessage.audioUrl;
                msg.videoUrl = self.currentMessage.videoUrl;
                msg.read = self.currentMessage.read;
                msg.latitude = self.currentMessage.latitude;
                msg.longitude =self.currentMessage.longitude;
                msg.messageId = messageId;
                msg.messageguid = guid;
                msg.audioLength = self.currentMessage.audioLength;
                [self.conversation addMessagesObject:msg];
                [self.conversation removeMessagesObject:self.currentMessage];
                [localContext MR_saveToPersistentStoreAndWait];

                SLLog(@"send ok");
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strSuccNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strFailedNotificationName object:nil];
        }
    }
}

- (void)sendMessageFail:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        NSDictionary *dataImg;
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        dataImg = [noti.userInfo objectForKey:strURL];
        
        UIButton * retryButton = (UIButton *) [self.contentView subviewWithTag:10];
        retryButton.hidden = NO;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSString * guid = dataImg[@"MESSAGE_GUID"];
        self.currentMessage.messageSendStatus = @2; //error
        UIActivityIndicatorView * indictorView = (UIActivityIndicatorView *) [self.contentView subviewWithTag:9];
        indictorView.hidden = YES;
        
        NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"messageguid == %@",guid];
        FCMessage * groupMessage = [FCMessage MR_findFirstWithPredicate:parCMDss ];
        if (groupMessage) {
            
            // first delete and  insert
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = self.currentMessage.text;
            msg.sentDate = self.currentMessage.sentDate;
            msg.messageType = self.currentMessage.messageType;
            // message did not come, this will be on rigth
            msg.messageStatus = self.currentMessage.messageStatus;
            msg.messageSendStatus = @(2);
            msg.messageUser = self.currentMessage.messageUser;
            msg.imageUrl = self.currentMessage.imageUrl;
            msg.audioUrl = self.currentMessage.audioUrl;
            msg.videoUrl = self.currentMessage.videoUrl;
            msg.read = self.currentMessage.read;
            msg.latitude = self.currentMessage.latitude;
            msg.longitude =self.currentMessage.longitude;
            msg.messageId = @"";
            msg.messageguid = guid;
            self.conversation.messageStutes = @(messageStutes_error);
            
            [self.conversation addMessagesObject:msg];
            [self.conversation removeMessagesObject:self.currentMessage];
            [localContext MR_saveToPersistentStoreAndWait];
            
             SLLog(@"send error");
        }
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strSuccNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strFailedNotificationName object:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// 
@end
