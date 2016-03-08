//
//  SYEasyCoreDataManager.m
//  CoreDataMigrateDemo
//
//  Created by SunYang on 16/3/7.
//  Copyright © 2016年 com.sunyang. All rights reserved.
//

#import "SYEasyCoreDataManager.h"
#import "AppDelegate.h"
@implementation SYEasyCoreDataManager
+ (instancetype) sharedCoreDataManager
{
    static SYEasyCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

#pragma mark - 增

/**
 *  根据实体名字返回实体对象
 *
 *  @param entityName 实体名字
 *
 *  @return 实体对象
 */
- (NSManagedObject *)managedObjectWithEntityName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self context]];
}

#pragma mark - 查

- (NSArray *)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName options:(NSDictionary *)options {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    //    获取所有关键字
    NSArray *allKeys = options.allKeys;
    //    查询限制
    if ([allKeys containsObject:kSYCoreDataQueryLimts]) {
        request.fetchLimit = [options[kSYCoreDataQueryLimts] integerValue];
    }
    //    查询过滤
    if ([allKeys containsObject:kSYCoreDataQueryOffset]) {
        request.fetchOffset = [options[kSYCoreDataQueryOffset] integerValue];
    }
    //    查询条件
    if ([allKeys containsObject:kSYCoreDataQueryParameters]) {
        request.predicate = [self queryParametersHandle:options[kSYCoreDataQueryParameters]];
    }
    //    排序条件
    if ([allKeys containsObject:kSYCoreDataSortParameters]) {
        request.sortDescriptors = [self querySortParametersHandle:options[kSYCoreDataSortParameters]];
    }
    return [[self context] executeFetchRequest:request error:nil];
}

- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName sortParamters:(NSArray *)sortParamters
{
    return [self queryObjectFromCoreDataWithEntityName:entityName sortParamters:sortParamters limit:0];
}


- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName sortParamters:(NSArray *)sortParamters limit:(NSInteger)limit {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (limit) {
        request.fetchLimit = limit;
    }
    if (sortParamters) {
        //设置排序条件
        request.sortDescriptors = [self querySortParametersHandle:sortParamters];
    }
    return [[self context] executeFetchRequest:request error:nil];
    
}



- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName paramters:(NSArray *)paramters
{
    //查询对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    //如果有参数
    if (paramters)
    {
        request.predicate = [self queryParametersHandle:paramters];
    }
    
    //执行查询
    return [[self context] executeFetchRequest:request error:nil];
}

- (NSArray *)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName
{
    return [self queryObjectFromCoreDataWithEntityName:entityName paramters:nil];
}

- (void)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName customQueryRequest:(SYCoreDataManagerCustomQueryHandle)queryRequest {
    NSFetchRequest *fetchRequst = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (queryRequest) {
        queryRequest(fetchRequst,[self context]);
    }
}

#pragma mark - 删

- (BOOL)deleteObjectFromCoreDataWithEntityName:(NSString *)entityName options:(NSDictionary *)options {
    NSArray *deleteObjects = [self queryAllObjectFromCoreDataWithEntityName:entityName options:options];
    for (NSManagedObject *obj in deleteObjects)
    {
        [[self context] deleteObject:obj];
    }
    return [self save];
}

- (BOOL)deleteObjectFromCoreDataWithEntityName:(NSString *)entityName paramters:(NSArray *)paramters
{
    //1.先找到要删除的对象
    NSArray *deleteObjects = [self queryObjectFromCoreDataWithEntityName:entityName paramters:paramters];
    
    //2.从内存中删除
    for (NSManagedObject *obj in deleteObjects)
    {
        [[self context] deleteObject:obj];
    }
    
    //3.同步数据库
    return [self save];
}


- (BOOL)deleteAllObjectFromCoreDataWithEntityName:(NSString *)entityName {
    return [self deleteObjectFromCoreDataWithEntityName:entityName paramters:nil];
}

- (BOOL)deleteAllObjectFromCoreDataWithObjects:(NSArray *)objects {
    for (NSManagedObject *obj in objects) {
        [[self context] deleteObject:obj];
    }
    return [self save];
}


- (BOOL)save
{
    return [[self context] save:NULL];
}

#pragma mark - other handles

/**
 *  根据传入字典返回对应的查询谓词,默认为复合查询
 *
 *  @param parameters 条件字典
 *
 *  @return 查询谓词
 */
- (NSPredicate *)queryParametersHandle:(NSArray *)parameters {
    //存在NSPredicate对象
    NSMutableArray *predicates = [NSMutableArray array];
    
    //遍历参数
    for (SYEasyCoreDataQueryParameter *queryParameter in parameters)
    {
        //初始化条件对象
        //key = 'value'
        NSString *key = queryParameter.key;
        NSString *value = queryParameter.value;
        NSString *predicateString;
        switch (queryParameter.compare) {
            case SYEasyCoreDataQueryParameterCompareLess:
                predicateString = [NSString stringWithFormat:@"%@<'%@'",key,value];
                break;
            case SYEasyCoreDataQueryParameterCompareEqual:
                predicateString = [NSString stringWithFormat:@"%@='%@'",key,value];
                break;
            case SYEasyCoreDataQueryParameterCompareMore:
                predicateString = [NSString stringWithFormat:@"%@>'%@'",key,value];
                break;
            case SYEasyCoreDataQueryParameterCompareLessOrEqual:
                predicateString = [NSString stringWithFormat:@"%@<='%@'",key,value];
                break;
            case SYEasyCoreDataQueryParameterCompareMoreOrEqual:
                predicateString = [NSString stringWithFormat:@"%@>='%@'",key,value];
                break;
            default:
                break;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        
        [predicates addObject:predicate];
    }
    
    
    //复合条件
    //and
    NSCompoundPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    //        compound = [NSCompoundPredicate notPredicateWithSubpredicate:compound];
    
    //设置查询条件
    return compound;
}


/**
 *  根据传入的字典返回排序条件的数组NSArray<NSSortDescriptor *>
 *
 *  @param sortParameters 排序字典
 *
 *  @return NSArray<NSSortDescriptor *>
 */
- (NSArray *)querySortParametersHandle:(NSArray *)sortParameters {
    //存放排序对象
    NSMutableArray *sortArray = [NSMutableArray array];
    
    //
    for (SYEasyCoreDataSortParameter *sortParameter in sortParameters)
    {
        //取值
        BOOL ascend = sortParameter.acsend;
        NSString *proper = sortParameter.proper;
        
        //排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:proper ascending:ascend];
        
        [sortArray addObject:sort];
    }
    return [sortArray copy];
}

/**
 *  返回CoreData上下文
 *
 *  @return coreData上下文
 */
- (NSManagedObjectContext *)context
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    return  app.managedObjectContext;
}


@end

#pragma mark - SYEasyCoreDataQueryParameter

@implementation SYEasyCoreDataQueryParameter

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value compare:(SYEasyCoreDataQueryParameterCompare)compare {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
        self.compare = compare;
    }
    return self;
}
@end

#pragma mark - SYEasyCoreDataSortParameter

@implementation SYEasyCoreDataSortParameter

- (instancetype)initWithProper:(NSString *)proper acsend:(BOOL)acsend {
    if (self = [super init]) {
        self.proper = proper;
        self.acsend = acsend;
    }
    return self;
}

@end






