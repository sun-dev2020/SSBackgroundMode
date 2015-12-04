# SSBackgroundMode
长时间后台运行的2种，audio session And background fetch

* Audio Session  音频播放 
* Background fetch  后台请求
* Location updates   更新定位
* Voice over IP   
* Remote notification  带特定键值的推送通知

1.
NSURLSessionConfiguration工作模式分为：    
一般模式（default）：工作模式类似于原来的NSURLConnection，可以使用缓存的Cache，Cookie，鉴权。    
及时模式（ephemeral）：不使用缓存的Cache，Cookie，鉴权。      
后台模式（background）：在后台完成上传下载，创建Configuration对象的时候需要给一个NSString的ID用于追踪完成工作的Session是哪一个。    

*在使用downloadTask时:   
如果是background模式使用-downloadTaskWithRequest completionHandler block回调会crash。使用-downloadTaskWithRequest ，配合delegate代替。 App在前台时也能使用后台模式     

*在使用uploadTask时:   
如果是background模式只能使用-uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData;     
如果是default模式可以使用fromData 和 fromFile两种方式


