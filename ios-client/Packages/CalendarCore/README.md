# CalendarCore

App 与 Widget 共用的纯原生日期/年度内容分配基础，无第三方依赖。

从仓库根目录执行：

```sh
swift test --package-path ios-client/Packages/CalendarCore
```

当前仅包括公历日期、显式时区转换与版本化年度分配。输入是 365 个稳定内容包 ID；闰年须额外给出独立闰日 ID。同一年度/算法版本和同一 ID 集合不受输入顺序影响。

这不是正式内容库或语录审批工具。Release 内容状态门禁、存储、Widget timeline 与 SwiftUI 实现待后续接入。完整范围与验证记录见 [工程启动文档](../../../docs/engineering/native-startup.md)。
