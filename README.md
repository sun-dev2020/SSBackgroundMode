# SSBackgroundMode
长时间后台运行的2种，audio session And background fetch

* Audio Session  音频播放 
* Background fetch  后台请求
* Location updates   更新定位
* Voice over IP   
* Remote notification  带特定键值的推送通知

1.
NSURLSessionConfiguration工作模式分为：    
Default sessions - 默认类型，支持（disk-based cache）和（store credentials in the user’s keychain）
Ephemeral sessions - 此类型不会在硬盘中存储数据，所有的cache、credential stores等都保留在RAM中，当session失效时自动被清除
Background sessions - 和默认类型很相似，但是会采用单独的进程管理数据传输，实现后台允许

* 在使用downloadTask时:   
如果是background模式使用-downloadTaskWithRequest completionHandler block回调会crash。使用-downloadTaskWithRequest ，配合delegate代替。 App在前台时也能使用后台模式     

* 在使用uploadTask时:   
如果是background模式只能使用-uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData;     
如果是default模式可以使用fromData 和 fromFile两种方式


