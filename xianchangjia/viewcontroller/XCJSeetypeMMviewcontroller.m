//
//  XCJSeetypeMMviewcontroller.m
//  laixin
//
//  Created by apple on 3/10/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJSeetypeMMviewcontroller.h"
#import "XCAlbumAdditions.h"
#import "UITableViewCell+TKCategory.h"
#import "UIButton+WebCache.h"
#import "UIButton+AFNetworking.h"

@interface XCJSeetypeMMviewcontroller ()
{
     
        NSMutableArray *HotTypeOfMMArray;
    
}
@end

@implementation XCJSeetypeMMviewcontroller

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
    
    {   NSMutableArray * array =   [[NSMutableArray alloc] init];
        HotTypeOfMMArray = array ;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"K歌指导员列表";
    
    {
        NSString * strJson = [MobClick getConfigParams:@"HotTypeOfMM"];
        NSData* datajson = [strJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray * array = [datajson  objectFromJSONData] ;
        
        NSDictionary * parames = @{@"uid":array};
        [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
            // "users":[....]
            NSDictionary * userinfo = responseObject[@"result"];
            NSArray * userArray = userinfo[@"users"];
            [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
                if (currentUser) {
                    [HotTypeOfMMArray addObject:currentUser];
                }
            }];
            [self.tableView reloadData];
        } failure:^(MLRequest *request, NSError *error) {
        }];
        
        
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return HotTypeOfMMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIButton * imageview = (UIButton * )  [cell.contentView subviewWithTag:1];
    UILabel * label_name = (UILabel * )  [cell.contentView subviewWithTag:2];
    UILabel * label_content = (UILabel * )  [cell.contentView subviewWithTag:3];
    UIButton * button = (UIButton * )  [cell.contentView subviewWithTag:4];
    LXUser *currentUser =  HotTypeOfMMArray[indexPath.row];
    imageview.layer.cornerRadius = imageview.height/2;
    imageview.layer.masksToBounds = YES;
    
    [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:currentUser.headpic Size:100]] forState:UIControlStateNormal   placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    label_name.text = currentUser.nick;
    label_content.text = currentUser.signature.length<=0?@"Ta什么都没说":currentUser.signature;
    NSMutableDictionary * keymuta  = [[NSMutableDictionary alloc] initWithObjectsAndKeys:currentUser,@"userinfo", nil];
    [cell setUserInfo:keymuta];
    
    
    UIImageView * imageview1 = (UIImageView * )  [cell.contentView subviewWithTag:5];
    UIImageView * imageview2 = (UIImageView * )  [cell.contentView subviewWithTag:6];
    UIImageView * imageview3 = (UIImageView * )  [cell.contentView subviewWithTag:7];
    
    imageview1.layer.cornerRadius = 2;
    imageview1.layer.masksToBounds = YES;
    
    imageview2.layer.cornerRadius = 2;
    imageview2.layer.masksToBounds = YES;
    
    imageview3.layer.cornerRadius = 2;
    imageview3.layer.masksToBounds = YES;
    
    if (indexPath.row == 0) {
        
        [imageview1 setImageWithURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/w%3D2048/sign=4b896f8ecbea15ce41eee70982383bf3/00e93901213fb80e335e60dc34d12f2eb9389429.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview2 setImageWithURL:[NSURL URLWithString:@"http://h.hiphotos.baidu.com/image/w%3D2048/sign=87cb024a8418367aad8978dd1a4b8ad4/09fa513d269759ee0af7afa8b0fb43166d22df2a.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview3 setImageWithURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/w%3D2048/sign=7a3c52c9d5ca7bcb7d7bc02f8a316a63/9213b07eca80653804e5cf1995dda144ad3482a8.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        
    } else  if (indexPath.row == 1) {
        
        [imageview1 setImageWithURL:[NSURL URLWithString:@"http://h.hiphotos.baidu.com/image/w%3D2048/sign=3c570f339045d688a302b5a490fa7c1e/a50f4bfbfbedab64fce58bc0f536afc379311e1f.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview2 setImageWithURL:[NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/w%3D2048/sign=022720314e086e066aa8384b36307af4/7acb0a46f21fbe09d1dd7f1469600c338744ad2b.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview3 setImageWithURL:[NSURL URLWithString:@"http://g.hiphotos.baidu.com/image/w%3D2048/sign=80cd02e4b11c8701d6b6b5e613479f2f/b3fb43166d224f4a8e1acf130bf790529822d12b.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        
    } else  if (indexPath.row == 2) {
        
        [imageview1 setImageWithURL:[NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=40afb41569600c33f079d9c82e74500f/a044ad345982b2b7fb6e4ec533adcbef76099b39.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview2 setImageWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=1f09578e08d162d985ee651c25e7a8ec/6a600c338744ebf8074d7d75dbf9d72a6059a7bf.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview3 setImageWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=afa74c4e0ed79123e0e09374990c5882/cf1b9d16fdfaaf5196f99df98e5494eef01f7a59.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        
    }else{
        [imageview1 setImageWithURL:[NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/w%3D2048/sign=40afb41569600c33f079d9c82e74500f/a044ad345982b2b7fb6e4ec533adcbef76099b39.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview2 setImageWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=1f09578e08d162d985ee651c25e7a8ec/6a600c338744ebf8074d7d75dbf9d72a6059a7bf.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        [imageview3 setImageWithURL:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D2048/sign=afa74c4e0ed79123e0e09374990c5882/cf1b9d16fdfaaf5196f99df98e5494eef01f7a59.jpg"] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
    }
    
    UILabel * label_more = (UILabel * )  [cell.contentView subviewWithTag:8];
    label_more.text = @"AndyCreation国际造型团队,带你近距离感受真正的时尚大片魅力.";
    
    [button addTarget:self action:@selector(attentClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 246.0f;
}


-(IBAction)attentClick:(id)sender
{
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
