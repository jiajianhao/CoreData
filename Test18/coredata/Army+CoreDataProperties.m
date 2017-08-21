//
//  Army+CoreDataProperties.m
//  Test18
//
//  Created by 小雨科技 on 2017/8/18.
//  Copyright © 2017年 jiajianhao. All rights reserved.
//

#import "Army+CoreDataProperties.h"

@implementation Army (CoreDataProperties)

+ (NSFetchRequest<Army *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Army"];
}

@dynamic name;
@dynamic des;

@end
