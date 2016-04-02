//
//  ViewController.m
//  GameKitDemo
//
//  Created by ZhaoHanjun on 16/4/2.
//  Copyright © 2016年 https://github.com/CoderHJZhao. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<GKPeerPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *imageBtn;

@property (nonatomic, strong) GKSession *session;/**<会话 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buildConnect:(UIButton *)sender {
    //初始化一个附近设备的搜索提示框
    GKPeerPickerController *peerPickerVc = [[GKPeerPickerController alloc] init];
    //设置代理
    peerPickerVc.delegate = self;
    //展示
    [peerPickerVc show];
}

- (IBAction)sendData:(UIButton *)sender {
    //判断是否有数据
    if (!self.imageBtn.currentBackgroundImage) return;
    NSError *error;
    //发送数据
    BOOL sendState = [self.session sendDataToAllPeers:UIImagePNGRepresentation(self.imageBtn.currentBackgroundImage) withDataMode:GKSendDataReliable error:&error];
    //判断是否发送成功
    if (!sendState) {
        NSLog(@"send error:%@",error.localizedDescription);
    }
}

- (IBAction)selectPhotoFromLibrary:(UIButton *)sender
{
    //判断相册是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //设置相片访问源
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //设置相片质量
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    //设置代理
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// 选择图片完毕调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 让picker消失
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"%s, line = %d, info= %@", __FUNCTION__, __LINE__, info);
    // 让选中的图片显示在icon上
    [self.imageBtn setBackgroundImage:info[UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
    
}

#pragma mark - GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    //首先让搜索框消失
    [picker dismiss];
    //标记会话
    self.session = session;
    //设置接收数据，设置完接受者后，接收数据会触发: SEL = -receiveData:fromPeer:inSession:context:
    [self.session setDataReceiveHandler:self withContext:nil];

}


#pragma mark - 蓝牙设备接收到数据时,就会调用

- (void)receiveData:(NSData *)data // 数据
           fromPeer:(NSString *)peer // 来自哪个设备
          inSession:(GKSession *)session // 连接会话
            context:(void *)context
{
    NSLog(@"%s, line = %d, data = %@, peer = %@, sessoing = %@", __FUNCTION__, __LINE__, data, peer, session);
    //讲接受到的数据展示在频幕上
    [self.imageBtn setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    //将相片存入相册
    UIImageWriteToSavedPhotosAlbum(self.imageBtn.currentBackgroundImage, nil, nil, nil);
}











@end
