# Apple 客户端

本目录统一管理 iOS/iPadOS、macOS App 与 Widget 扩展代码。目录名称遵循项目约定 `ios-client`，也包含原生 Mac 客户端。

- 工程：`MaoStyleCalendar.xcodeproj`。
- 共享 schemes：`MaoStyleCalendar-iOS`、`MaoStyleCalendar-macOS`。
- 最低系统：iOS/iPadOS 17、macOS 14。
- 本地核心包：`Packages/CalendarCore`，无第三方依赖。
- 字体与许可：工程通过 `../docs/design/handoff/v2/` 引用公共归档，构建时打包到各 target。

结构、依赖关系与从仓库根目录运行的构建命令见 [仓库结构说明](../docs/engineering/repository-structure.md)；阶段验证见 [工程启动记录](../docs/engineering/native-startup.md)。
