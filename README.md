# SYEazyCoreData
简单的coredata管理类

1.使用sharedCoreDataManager方法来创建

2.主要包括添加查询和删除数据的功能

3.options参数为可选条件，包括
    kSYCoreDataQueryParameters 查询时通过模型属性筛选的条件(字典)
    kSYCoreDataSortParameters  查询时通过模型属性排序的条件（字典）
    kSYCoreDataQueryLimts      查询时每次返回的数量限制（默认为0）
    kSYCoreDataQueryOffset     查询时忽略的数量（默认为0）


