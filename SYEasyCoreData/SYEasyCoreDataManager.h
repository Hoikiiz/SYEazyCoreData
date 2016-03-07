//
//  SYEasyCoreDataManager.h
//  CoreDataMigrateDemo
//
//  Created by WeiCheng—iOS_1 on 16/3/7.
//  Copyright © 2016年 com.WECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
/**
 *  查询时的筛选条件，格式为
 @{
 属性1：值1,
 属性2：值2...
 }
 */
static const NSString *kSYCoreDataQueryParameters = @"kSYCoreDataQueryParameters";
/**
 *  查询时的排序条件，格式为
 @{
 属性名：是否升序（bool）...
 }
 */
static const NSString *kSYCoreDataSortParameters = @"kSYCoreDataSortParameters";

/**
 *  查询时的数量限制
 */
static const NSString *kSYCoreDataQueryLimts = @"kSYCoreDataQueryLimts";

/**
 *  查询时忽略的数目
 */
static const NSString *kSYCoreDataQueryOffset = @"kSYCoreDataQueryOffset";


typedef void(^SYCoreDataManagerCustomQueryHandle)(NSFetchRequest *fetchRequest,NSManagedObjectContext *context);


/**
 *  CoreData的管理类（单例）
 *  主要包括增，删，查
 */

@interface SYEasyCoreDataManager : NSObject
+ (instancetype) sharedCoreDataManager;

/**
 *  根据实体名字返回实体对象
 *
 *  @param entityName 实体名字
 *
 *  @return 实体对象
 */
- (NSManagedObject *)managedObjectWithEntityName:(NSString *)entityName;

/**
 *  查询所有的数据
 */
- (NSArray *)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName;

/**
 *  条件查询
 */
- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName paramters:(NSDictionary *)paramters;

/**
 *  排序查询所有的对象
 *
 *  @param entityName
 *  @param sortParamters @“property”:@(BOOL),
 *  if ascending BOOL is @(true)
 *  if not BOOL is @(false)
 */
- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName sortParamters:(NSDictionary *)sortParamters;
/**
 *  排序查询所有的对象
 *
 *  @param entityName
 *  @param sortParamters @“property”:@(BOOL),
 *  if ascending BOOL is @(true)
 *  if not BOOL is @(false)
 *  @param limit         the count of returened array
 */
- (NSArray *)queryObjectFromCoreDataWithEntityName:(NSString *)entityName sortParamters:(NSDictionary *)sortParamters limit:(NSInteger)limit;

/**
 *  使用可选条件来查询
 *
 *  @param entityName 实体名称
 *  @param options    可选条件
 *
 *  @return 查询结果
 */
- (NSArray *)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName options:(NSDictionary *)options;

- (void)queryAllObjectFromCoreDataWithEntityName:(NSString *)entityName customQueryRequest:(SYCoreDataManagerCustomQueryHandle)queryRequest;

/**
 *  删除指定条件的数据
 *
 *  @param entityName 实体名称
 *  @param paramters  指定条件，格式为@{属性1:值1...}
 *
 */
- (BOOL)deleteObjectFromCoreDataWithEntityName:(NSString *)entityName paramters:(NSDictionary *)paramters;
/**
 *  删除所有该表的信息
 *  @param entityName 表名
 */
- (BOOL)deleteAllObjectFromCoreDataWithEntityName:(NSString *)entityName;
/**
 *  删除指定的数据数组
 *
 *  @param objects 指定的NSManagedObject数组对象
 *
 *  @return 删除是否成功
 */
- (BOOL)deleteAllObjectFromCoreDataWithObjects:(NSArray *)objects;
/**
 *  使用可选条件来删除数据
 *
 *  @param entityName 实体名称
 *  @param options    可选条件
 *
 *  @return 删除是否成功
 */
- (BOOL)deleteObjectFromCoreDataWithEntityName:(NSString *)entityName options:(NSDictionary *)options;
/**
 *  同步数据库
 *
 */
- (BOOL)save;

@end
