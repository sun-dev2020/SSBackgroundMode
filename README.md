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
