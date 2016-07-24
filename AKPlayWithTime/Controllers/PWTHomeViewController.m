//
//  PWTHomeViewController.m
//  AKPlayWithTime
//
//  Created by lisaike on 16/7/11.
//  Copyright © 2016年 lisaike. All rights reserved.
//

#import "PWTHomeViewController.h"
//viewmodel
#import "PWTHomeViewModel.h"

static NSString * const kUserDefaultsStartTimeKey = @"kUserDefaultsStartTimeKey";
@interface PWTHomeViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) PWTHomeViewModel *viewModel;

@end

@implementation PWTHomeViewController

- (void)dealloc {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _startTime = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsStartTimeKey];
        _started = _startTime ? YES : NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.button];
    [self.navigationController.view addSubview:self.maskView];
    [self.navigationController.view addSubview:self.textView];
    [self setupClearEventsButton];
    [self setButtonStatus:_started];
    [self reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.button.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetHeight(self.view.bounds) - 130);
    self.tableView.frame = self.view.bounds;
}

#pragma mark - textView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.viewModel addEventWithContent:self.textView.text startTime:_startTime endTime:_endTime];
        [self reloadData];
        _startTime = nil;
        _endTime = nil;
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kUserDefaultsStartTimeKey];
        [self hideAndClearTextView];
        return NO;
    }
    return YES;
}

#pragma makr - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const reuseIdentifier = @"com.ake.playWithTime.homePageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = self.viewModel.events[indexPath.row].text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
// copy/paste
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        [UIPasteboard generalPasteboard].string = self.viewModel.events[indexPath.row].text;
    }
}
// delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Event *event = self.viewModel.events[indexPath.row];
        [self.viewModel removeEvent:event];
        //UI
        NSMutableArray *tempArray = [self.viewModel.events mutableCopy];
        [tempArray removeObjectAtIndex:indexPath.row];
        self.viewModel.events = [tempArray copy];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - action

- (void)buttonAction:(UIButton *)button {
    if (_started) {
        _endTime = [NSDate date];
        if ([_endTime timeIntervalSinceDate:_startTime] < 60.0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未超过一分钟不予以记录！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            [self showTextView];
        }
    }
    else {
        _startTime = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setValue:_startTime forKey:kUserDefaultsStartTimeKey];
    }
    [self setButtonStatus:!_started];
    _started = !_started;
}

- (void)maskTapped:(UITapGestureRecognizer *)recognizer {
    [self hideAndClearTextView];
}

- (void)clearEvents {
    [self.viewModel removeAllEvents];
    [self reloadData];
}

#pragma mark - private

- (void)showTextView {
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0.9;
        CGRect rect = self.textView.frame;
        rect.origin.y = 100;
        self.textView.frame = rect;
    }];
    [self.textView becomeFirstResponder];
}

- (void)hideAndClearTextView {
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0;
        CGRect rect = self.textView.frame;
        rect.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds);
        self.textView.frame = rect;
    }];
    self.textView.text = nil;
    [self.textView resignFirstResponder];
}

- (void)setButtonStatus:(BOOL)on {
    if (on) {
        self.button.backgroundColor = [UIColor colorWithRed:255/255.0 green:22/255.0 blue:11/255.0 alpha:1];
        [self.button setTitle:@"停止" forState:UIControlStateNormal];
    }
    else {
        self.button.backgroundColor = [UIColor colorWithRed:84/255.0 green:255/255.0 blue:209/255.0 alpha:1];
        [self.button setTitle:@"开始" forState:UIControlStateNormal];
    }
}

- (void)setupClearEventsButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空列表" style:UIBarButtonItemStylePlain target:self action:@selector(clearEvents)];
}

- (void)reloadData {
    [self.viewModel reloadDataWithCompletion:^(NSError *error, NSArray<Event *> *array) {
        self.viewModel.events = array;
        [self.tableView reloadData];
    }];
}

#pragma mark - getter

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        _button.layer.cornerRadius = 35;
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor grayColor];
        _maskView.alpha = 0;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapped:)]];
    }
    return _maskView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 100)];
        _textView.layer.cornerRadius = 6;
        _textView.font = [UIFont systemFontOfSize:25];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.delegate = self;
    }
    return _textView;
}

- (PWTHomeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [PWTHomeViewModel new];
    }
    return _viewModel;
}

@end
