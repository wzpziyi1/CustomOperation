//
//  ViewController.m
//  CustomOperationForDownLoadImage
//
//  Created by 王志盼 on 15/7/23.
//  Copyright (c) 2015年 王志盼. All rights reserved.
//

#import "ViewController.h"
#import "ZYApp.h"
#import "ZYDownLoadImageOperation.h"
#import "ZYFileTool.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, ZYDownLoadImageOperationDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *apps;

@property (nonatomic, strong) NSOperationQueue *queue;

//  key:图片的url  values: 相对应的operation对象  （判断该operation下载操作是否正在执行，当同一个url地址的图片正在下载，那么不需要再次下载，以免重复下载，当下载操作执行完，需要移除）
@property (nonatomic, strong) NSMutableDictionary *operations;

//  key:图片的url  values: 相对应的图片        （缓存，当下载操作完成，需要将所下载的图片放到缓存中，以免同一个url地址的图片重复下载）
@property (nonatomic, strong) NSMutableDictionary *images;
@end

@implementation ViewController

#define ZYCellIdentifier  @"ZYCellIdentifier"
- (NSArray *)apps
{
    if (_apps == nil)
    {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray)
        {
            ZYApp *app = [ZYApp appWithDict:dict];
            [tmpArray addObject:app];
        }
        _apps = tmpArray;
    }
    return _apps;
}

- (NSOperationQueue *)queue
{
    if (_queue == nil)
    {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (NSMutableDictionary *)operations
{
    if (_operations == nil)
    {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}

- (NSMutableDictionary *)images
{
    if (_images == nil) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setupView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ZYCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ZYCellIdentifier];
    }
    ZYApp *app = self.apps[indexPath.row];
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    UIImage *image = self.images[app.icon];   //优先从内存缓存中读取图片
    
    if (image)     //如果内存缓存中有
    {
        cell.imageView.image = image;
    }
    else
    {
        //如果内存缓存中没有，那么从本地缓存中读取
        NSData *imageData = [ZYFileTool readDataWithFileName:app.icon type:ZYFileToolTypeCache];
        
        if (imageData)  //如果本地缓存中有图片，则直接读取，更新
        {
            UIImage *image = [UIImage imageWithData:imageData];
            self.images[app.icon] = image;
            cell.imageView.image = image;
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"TestMam"];
            ZYDownLoadImageOperation *operation = self.operations[app.icon];
            if (operation)
            {  //正在下载（可以在里面取消下载）
            }
            else
            { //没有在下载
                operation = [[ZYDownLoadImageOperation alloc] init];
                operation.delegate = self;
                operation.url = app.icon;
                operation.indexPath = indexPath;
                [self.queue addOperation:operation];  //异步下载
                
                
                self.operations[app.icon] = operation;  //加入字典，表示正在执行此次操作
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark -- ZYDownLoadImageOperationDelegate
- (void)DownLoadImageOperation:(ZYDownLoadImageOperation *)operation didFinishDownLoadImage:(UIImage *)image
{
    [self.operations removeObjectForKey:operation.url];    //下载操作完成，所以把它清掉，表示没有正在下载
    
    if (image){
        self.images[operation.url] = image;    //下载完毕，放入缓存，免得重复下载
        
        [self.tableView reloadRowsAtIndexPaths:@[operation.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView  //设置优先级别，效果是，最先下载展示在屏幕上的图片（本例子中图片太小了，没有明显的效果出现，可以设置更多的一些高清大图）
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(self.apps.count, queue, ^(size_t i) {
        ZYApp *appTmp = self.apps[i];
        NSString *urlStr = appTmp.icon;

        ZYDownLoadImageOperation *operation = self.operations[urlStr];
        if (operation)
        {
            operation.queuePriority = NSOperationQueuePriorityNormal;
        }
    });
    
    NSArray *tempArray = [self.tableView indexPathsForVisibleRows];
    
    dispatch_apply(tempArray.count, queue, ^(size_t i) {
        NSIndexPath *indexPath = tempArray[i];

        ZYApp *appTmp = self.apps[indexPath.row];
        NSString *urlStr = appTmp.icon;
        ZYDownLoadImageOperation *operation = self.operations[urlStr];
        if (operation)
        {
            operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        }
    });
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.queue.suspended = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.queue.suspended = NO;
}
@end
