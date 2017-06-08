//
//  DroiPushViewController.m
//  DroiPushDemo
//
//  Created by Jon on 16/7/13.
//  Copyright © 2016年 Droi. All rights reserved.
//

#import "DroiPushViewController.h"
#import <DroiPush/DroiPush.h>
#import "AppDelegate.h"

@interface DroiPushViewController ()
@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UILabel *cidLabel;
@property (weak, nonatomic) IBOutlet UILabel *secretLabel;
@property (weak, nonatomic) IBOutlet UITextField *tag1TF;
@property (weak, nonatomic) IBOutlet UITextField *tag2TF;
@property (weak, nonatomic) IBOutlet UITextField *badgeTF;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

    @property (weak, nonatomic) IBOutlet UILabel *tokenLabel;

@end

@implementation DroiPushViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceTokenSucess) name:kDroiPushGetDeviceTokenSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceIdSucess) name:kDroiPushGetDeviceIdSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLongMessage:) name:kDroiPushReceiveLongMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSilentMessage:) name:kDroiPushReceiveSilentNotification object:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"CopyToken" style:UIBarButtonItemStylePlain target:self action:@selector(copyToken)];
    self.appIdLabel.text = [DroiPush getAppId];
    self.channelLabel.text = [DroiPush getAppChannel];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)getDeviceIdSucess{
    self.cidLabel.text = [DroiPush getDeviceId];
}

- (void)getDeviceTokenSucess{
    self.tokenLabel.text = [DroiPush getDeviceToken];
}

- (void)copyToken{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[DroiPush getDeviceToken]];
}

- (void)receiveSilentMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    [self alertString:[NSString stringWithFormat:@"接收到透传消息:%@",[userInfo description]]];
}

- (void)receiveLongMessage:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    [self alertString:[NSString stringWithFormat:@"接收到长消息:%@",[userInfo description]]];
}

- (void)alertString:(NSString *)String{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:String preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)setTag:(id)sender {
    NSString *tag1 = self.tag1TF.text;
    NSString *tag2 = self.tag2TF.text;
    //设置标签
    NSMutableSet *set = [[NSMutableSet alloc] init];
    if (![tag1 isEqualToString:@""]) {[set addObject:tag1];}
    if (![tag2 isEqualToString:@""]) {[set addObject:tag2];}
    [self LogString:@"设置中..."];
    [DroiPush setTags:set completionHandler:^(BOOL result) {
        result?[self LogString:@"设置成功"]:[self LogString:@"设置失败"];
    }];
}

- (IBAction)clearTag:(id)sender {
    [self LogString:@"设置中..."];
    //清空标签
    [DroiPush resetTags:^(BOOL result) {
        result?[self LogString:@"设置成功"]:[self LogString:@"设置失败"];
    }];
}

- (IBAction)setBadge:(id)sender {
    NSInteger badge = [self.badgeTF.text integerValue];
    //设置badge
    [self LogString:@"设置中..."];
    [DroiPush setBadge:badge completionHandler:^(BOOL result) {
        result?[self LogString:@"设置成功"]:[self LogString:@"设置失败"];
    }];
}

- (IBAction)getTag:(UIButton *)sender {
    [self LogString:@"获取中..."];
    [DroiPush getTag:^(BOOL result, NSString *tag) {
        result?[self LogString:[NSString stringWithFormat:@"获取成功：%@",tag]]:[self LogString:@"获取失败"];
    }];
}

- (void)LogString:(NSString *)string{
    self.infoLabel.text = string;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
