//
//  Army+CoreDataProperties.h
//  Test18
//
//  Created by 小雨科技 on 2017/8/18.
//  Copyright © 2017年 jiajianhao. All rights reserved.
//

#import "Army+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Army (CoreDataProperties)

+ (NSFetchRequest<Army *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *des;

@end

NS_ASSUME_NONNULL_END
