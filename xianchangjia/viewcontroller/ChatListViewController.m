//
//  ChatListViewController.m
//  ISClone
//
//  Created by Molon on 13-12-2.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatList.h"
#import "ChatUserCell.h"
#import "Chat.h"
#import "ChatViewController.h"

@interface ChatListViewController ()

@property (nonatomic, strong) ChatList *chatList;

@end

@implementation ChatListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"消息";
   /*
    self.chatList = [ChatList shareInstance];
    //重新排序
    [self.chatList sortWithAscending:NO];
    //重载TableView
    [self.tableView reloadData];
    
    //KVO监控chatList单例数组
    [self.chatList addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionPrior context:nil];
    
    //给每一个chat添加监控
    for (Chat* chat in self.chatList) {
        [self addObserverOfChat:chat];
    }*/
}

- (void)dealloc {
	//给每一个chatRoom删除Observer
	for (Chat* chat in self.chatList) {
		[self removeObserverOfChat:chat];
	}
	
	//删除Observer
	[self.chatList removeObserver:self forKeyPath:@"array"];
}

//#warning 两个测试事件
- (IBAction)add:(id)sender {
    Chat *chat = [Chat turnObject:@{
                                    @"avatarURL":@"http://tp2.sinaimg.cn/3785688681/50/40034786628/0",
                                    @"name":@"最高滴",
                                    @"latestTime":@1386039348,
                                    @"latestMessage":@"嘛哩嘛哩哄。。",
                                    @"unreadCount":@0
                                    }];
    [self.chatList addChat:chat ascending:NO];
    
//    if (self.chatList.count==0) {
//        return;
//    }
//    NSNumber *origTime = ((Chat *)self.chatList[0]).latestTime;
//    ((Chat *)self.chatList[0]).latestTime = [NSNumber numberWithDouble:[origTime doubleValue]-60];
}
- (IBAction)minus:(id)sender {
    [self.chatList removeObjectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Add Or Remove Observer Of ChatRoom
- (void)addObserverOfChat:(Chat*)chat
{
    //不添加对latestMessage的监视，是因为其变动，latestTime就会监视到，一个就够了。
	[chat addObserver:self forKeyPath:@"latestTime" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	[chat addObserver:self forKeyPath:@"unreadCount" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserverOfChat:(Chat*)chat
{
    [chat removeObserver:self forKeyPath:@"latestTime"];
    [chat removeObserver:self forKeyPath:@"unreadCount"];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
	if ([kind integerValue]==NSKeyValueChangeSetting&& [object isKindOfClass:[Chat class]]){
        //这里unreadCount只处理为0的情况是因为unreadCount增加时候latestTime是肯定会更新的，而设置为0时候则不会,下面判断是用以防止重复reload
        Chat *chat = (Chat*)object;
		if ([keyPath isEqualToString:@"latestTime"]
            ||([keyPath isEqualToString:@"unreadCount"]&&chat.unreadCount<= 0&&[[change objectForKey:NSKeyValueChangeOldKey] unsignedIntegerValue]!=chat.unreadCount)) {
            
			NSUInteger index=[self.chatList indexOfObject:chat];
            if ([keyPath isEqualToString:@"latestTime"]) {
                //判断是否位置应当变动
                NSUInteger newIndex = [self.chatList indexShouldBeSetInListWithChat:chat ascending:NO];
                if (index != newIndex) {
                    //重新排序
                    [self.chatList sortWithAscending:NO];
                    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                    index = newIndex;
                }
            }
            
            NSIndexPath *newPath = [NSIndexPath indexPathForRow:index inSection:0];
			[self.tableView reloadRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationNone];
            
		}
		return;
	}
	
	//元素位置的改变
	BOOL isPrior = [((NSNumber *)[change objectForKey:NSKeyValueChangeNotificationIsPriorKey]) boolValue];//是否是改变之前进来的
	if (isPrior&&[kind integerValue] != NSKeyValueChangeRemoval) {
		return; //改变之前进来却不是Removal操作就忽略
	}
	
	//获取变化值
    NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    if (indices == nil){
        return;
    }
    
    NSUInteger indexCount = [indices count];
    NSUInteger buffer[indexCount];
    [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indexCount; i++) {
        NSUInteger indexPathIndices[2];
        indexPathIndices[0] = 0;
        indexPathIndices[1] = buffer[i];
        NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
        [indexPathArray addObject:newPath];
    }
	//判断值变化是insert、delete、(replace被忽略不需要)。
    if ([kind integerValue] == NSKeyValueChangeInsertion){
		//添加对应的Observer
		for (NSIndexPath *path in indexPathArray) {
			[self addObserverOfChat:self.chatList[path.row]];
		}
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
	}
    else if ([kind integerValue] == NSKeyValueChangeRemoval){
		//改变之前清除Observer，改变之后剔除TableView里数据，其实用old去获取也可以，但是总觉得没这种方法好
		if (isPrior) {
			//删除对应的Observer
			for (NSIndexPath *path in indexPathArray) {
				[self removeObserverOfChat:self.chatList[path.row]];
			}
		}else{
			[self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.chatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatUserCell";
    ChatUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.chat = self.chatList[indexPath.row];
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self performSegueWithIdentifier:@"Chat" sender:self.chatList[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.chatList removeObjectAtIndex:indexPath.row];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Chat"]) {
//        ChatViewController *vc = [segue destinationViewController];
//        vc.chat = (Chat*)sender;
    }
}



@end
