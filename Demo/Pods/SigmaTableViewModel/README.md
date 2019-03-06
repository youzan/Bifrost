# 让TableView就像做加法一样简单。

使用文档参考 http://doc.qima-inc.com/pages/viewpage.action?pageId=3773147
或 https://github.com/youzan/SigmaTableViewModel

注：SigmaTableViewModel封装了常用的UITableViewDataSource和delegate方法，如果遇到一些没有封装的，可以subclass或通过YZSTableViewModelDelegate对象来补充。

集成方式：
Podfile中加入
```
source 'http://gitlab.qima-inc.com/AppLib/RenRenPodspecs.git'
pod 'SigmaTableViewModel'
```

