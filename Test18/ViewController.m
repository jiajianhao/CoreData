//
//  ViewController.m
//  Test18
//
//  Created by 小雨科技 on 2017/7/24.
//  Copyright © 2017年 jiajianhao. All rights reserved.
//创建时候
//xcode8上，xcdatamodeld 的 language要选择 Objective-c ,默认是swift的;
//entity 的codegen选择Mannual/None,不然默认选择Class Define，会编译出错。
//进入使用步骤
//增删改查~没啦

#import "ViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Army+CoreDataClass.h"
@interface ViewController (){
 
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     
    
    //初始化数据库
    [self setupContext];
    
    //用来查找沙盒位置
    NSString *homeDirectory = NSHomeDirectory();
    NSLog(@"%@",homeDirectory);
    
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建数据库方法，会自动生成model模型文件下的数据库表
-(void)setupContext{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
 
}

-(IBAction)addData:(id)sender{
    // 传入上下文，创建一个Person实体对象
    NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName:@"Army" inManagedObjectContext:self.managedObjectContext];
    // 设置Person的简单属性
    NSString *str1 = [NSString stringWithFormat:@"MJ%d",arc4random() % 10000];
    [person setValue:str1 forKey:@"name"];
    [person setValue:@"MJ is good" forKey:@"des"];
    [person setValue:@"20" forKey:@"age"];

    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }
    // 如果是想做更新操作：只要在更改了实体对象的属性后调用[context save:&error]，就能将更改的数据同步到数据库
    
}
-(IBAction)deleteData:(id)sender{
    /** 查询要删除带有输入的关键字的对象 */
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",@"MJ"];
    
    
    /** 被管理对象上下文--(获取所有被管理对象的实体) */
    NSManagedObjectContext * context = self.managedObjectContext;
    
    /** 根据上下文获取查询数据库实体的请求参数---要查询的entity(实体) */
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Army" inManagedObjectContext:context];
    
    /** 查询请求 */
    NSFetchRequest * request = [NSFetchRequest new];
    
    /** 根据参数获取查询内容 */
    request.entity = des;
    
    request.predicate = pre;
    
    /**
     1.获取所有被管理对象的实体---根据查询请求取出实体内容
     2.获取的查询内容是数组
     3.删掉所有查询到的内容
     3.1.这里是模糊查询 即 删除包含要查询内容的字母的内容
     */
    NSArray * array = [context executeFetchRequest:request error:NULL];
    
    /** 对查询的内容进行操作 */
    for (Army * p in array) {
        [context deleteObject:p];
    }
     NSError *error = nil;

    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        NSLog(@"删除失败");

        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }
    else{
        NSLog(@"删除完成");

    }
}

-(IBAction)updateData:(id)sender{
    /** 获取输入内容 */
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",@"MJ"];
    
     NSManagedObjectContext * context = self.managedObjectContext;
    NSEntityDescription * des = [NSEntityDescription entityForName:@"Army" inManagedObjectContext:context];
    NSFetchRequest * request = [NSFetchRequest new];
    request.entity = des;
    request.predicate = pre;
    
    NSArray * array = [context executeFetchRequest:request error:NULL];
    
    //这里修改的话把全部查询到的内容修改成了 "张三",可以根据自己的需要进行设置
    for (Army *p in array) {
        p.des = @"MK is good ";
        [context updatedObjects];
    }
    NSError *error = nil;

    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        NSLog(@"修改失败");
        [NSException raise:@"访问数据库错误" format:@"%@", [error localizedDescription]];
    }
    else{
        NSLog(@"修改完成");
        
    }
    
 
}

-(IBAction)queryData:(id)sender{
    // 初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要查询的实体
    request.entity = [NSEntityDescription entityForName:@"Army" inManagedObjectContext:self.managedObjectContext];
    // 设置排序（按照age降序）
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    // 设置条件过滤(搜索name中包含字符串"name1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%name1%应该写成*name1*)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like '*MJ*' "];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH 'MJ' "];

    request.predicate = predicate;
    // 执行请求
    NSError *error = nil;
    NSArray *objs = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    // 遍历数据
    for (NSManagedObject *obj in objs) {
        NSLog(@"name=%@", [obj valueForKey:@"name"] );
        NSLog(@"des =%@", [obj valueForKey:@"des"] );

    }
}
/*
 BEGINSWITH：检查某个字符串是否以指定的字符串开头（如判断字符串是否以a开头：BEGINSWITH 'a'）
 ENDSWITH：检查某个字符串是否以指定的字符串结尾
 CONTAINS：检查某个字符串是否包含指定的字符串
 LIKE：检查某个字符串是否匹配指定的字符串模板。其之后可以跟?代表一个字符和*代表任意多个字符两个通配符。比如"name LIKE '*ac*'"，这表示name的值中包含ac则返回YES；"name LIKE '?ac*'"，表示name的第2、3个字符为ac时返回YES。
 MATCHES：检查某个字符串是否匹配指定的正则表达式。虽然正则表达式的执行效率是最低的，但其功能是最强大的，也是我们最常用的。
 */
#pragma mark -
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"army.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
     NSLog(@"resolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


@end
