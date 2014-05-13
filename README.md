May 13, 2014

###来信App文档

1. 网络请求调用方式
2. UIViewController跳转方式
3. 添加新ViewController
4. 添加新Cell
5. 数据存储
6. 数据格式化

------------------------

#####代码结构:


- DBCommon,CustomCell,DAOModel 属于历史遗留部分,一直没有删除,暂时不能删

- Extend->LaixinNetworking是来信网络API及数据存入CoreData部分
- Extend->MyLibs是一些工具类和websocket主要实现类
- Extend->Util是一些Categories类
- Extend->Vendor是数据解析及网络解析

- **Models是CoreData一些实体类,来信主要实体类**

- Application 是来信一些全局变量和公共方法封装

- Additions 是来信用到的所有函数扩展类,工具类

- Support 是第三方工具和效果实现

- SupportView 是第三方各种View实现效果

- ViewController 是来信所有界面

------------------------

#####开启工程:
点击**`laixin.xcworkspace`**即可开启来信工程
主要代码文件放在`xianchangjia`下, `pods`主要放的第三方工程代码,暂时不需要更新
所有布局文件都放在`Main.storyboard`里,来信用到素材都放在`Images.xcassets`里.

------------------------

#####网络请求:

1. 通用`websocket`请求

**`所有操作都是异步`**
例如激活联系人:

```
[[MLNetworkingManager sharedManager] sendWithAction:@"circle.by_user" parameters:@{@"uid": user.uid} success:^(MLRequest *request, id responseObject) {
	//请求成功处理
} failure:^(MLRequest *request, NSError *error) {                        
	//请求失败处理
}];
```


2. `get` 请求

这里是获取该手机的验证码和相关sessionid信息


```
 [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError * error) {
             if (!error) {
                 NSString * yanzhengCode =  [response objectForKey:@"code"];
                 if (yanzhengCode.length > 0) {
                     [SVProgressHUD dismiss];
                     self.button_yanzhengCode.enabled = NO;                     
                     NSString * string = [MobClick getConfigParams:@"AutoFillYanzhengma"];
                     if ([string isEqualToString:@"1"]) {
                         
                         UIView * viewKey = (UIView *) [self.view subviewWithTag:1];
                         UITextField * pwdText = (UITextField *) [viewKey subviewWithTag:3];
                         pwdText.text = yanzhengCode;
                         
                     }
                     
                 }else{
                     self.button_yanzhengCode.enabled = YES;
                     [UIAlertView showAlertViewWithMessage:@"获取验证码失败"];
                 }
             }else{
                 self.button_yanzhengCode.enabled = YES;
                 [UIAlertView showAlertViewWithMessage:@"获取验证码失败"];
             }
        } withParems:[NSString stringWithFormat:@"getcode?phone=%@",phone]];
```



####界面跳转

1. 通过UIStoryboardSegue方式跳转,实现函数...即可

```
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
```

2. 通过Storyboard方式

```
XCJCompleteUserInfoViewController * viewContr = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJCompleteUserInfoViewController"];
                        [self.navigationController pushViewController:viewContr animated:YES];
```
*@"XCJCompleteUserInfoViewController"*是在main.storyboard里设置改viewcontrol的storyboardid对应这个值


####新UITableViewcell

目前直接在界面设计的方式处理,没有单独提取出来



####数据存储

目前有通过CoreData,EGOCache,Plist方式存储

##### * CoreData
存储所有首页messageList,ChatList,ContactsList,MyUserInfo等
结构基本是每个用户信息本地都有根据Userid缓存映射,每次用户在查看用户详细信息时会更新缓存信息
只要主动拉取用户详细信息都回缓存信息.

##### * EGOCache
每条群组里Postid对应的多张图片信息都永久缓存,即使该postid删除了也不会清空掉.

##### * Plist
缓存用户个人照片列表,个人图片信息流




####数据格式化
所有server数据都格式化本地为json数据或者Array方式存储于plist中


###发布AppStore审核流程



```
 #define NEED_OUTPUT_LOG                     0  // 0 relese  1 debug 
```

1. 需要修改Application下XCALbumDefines.h里 

2.  需要修改 `XCJSysSettingsViewController` `XCJSettingsViewController` 里的版本号对应Version 

3. 需要在Xcode Version 5.0.2 (5A3005)下编译出ipa包然后通过Applicatoin loader发布

4. 目前版本只支持7.0以上版本

5. 审核通过后`必须`要在在友盟里设置最新的版本升级提示,地址:<http://www.umeng.com/>


#####账号密码

App 发布地址:<https://itunesconnect.apple.com/>

* email: yaobyte@gmail.com
* pwd: SHxinxi123

umeng:<http://www.umeng.com/>

* email:jiehong.liu@xianchangjia.com
* pwd:123456

#### 第三方库

* MagicalRecord : <https://github.com/magicalpanda/MagicalRecord> 中文说明:<https://www.google.com.hk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CDkQFjAB&url=http%3a%2f%2fwww%2ecnblogs%2ecom%2fmybkn%2fp%2f3328183%2ehtml&ei=mdtxU4rxBs2E8gWo-IDoAQ&usg=AFQjCNHr3s_8Xfvndye2hQmPKokF0-VhEQ&sig2=zOS70JwRpDW4eczuKkJRaQ>
* OHAttributeLabel :<https://github.com/AliSoftware/OHAttributedLabel>



####来信架构图
![image](http://images.cnblogs.com/cnblogs_com/tinkl/253133/o_[W_8L3YMIXH`0EN1FU__O$M.jpg)



.......by tinkl........
