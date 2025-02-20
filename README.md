# luci-app-campus-network-login

- 本项目由AI生成

### 文档

- [卓智校园网自动登录](https://blog.naokuo.top/p/522a17f8.html)

### 功能说明：
- 校园网登录
- Web界面路径：服务 -> Campus Network Login
- 支持配置所有认证参数和Cron表达式
- 自动生成Cron任务并重启服务
- 脚本自动检测网络状态并进行认证
- 日志文件保存在 /etc/xyw/log.txt

```BASH
luci-app-campus-network-login/
├── Makefile # 作用：用于自动化构建、编译和安装该LuCI应用程序，定义了编译规则、依赖关系以及安装目标等，是项目构建过程中的关键文件。
├── root # 作用：存放与应用相关的各种资源文件，包括配置文件和脚本等。
│   ├── etc
│   │   └── config
│   │       └── campus_network # 作用：存储校园网络相关的配置信息，比如网络认证参数、服务器地址等。
│   └── usr
│       └── bin
│           └── campus_login.sh # 作用：一个Shell脚本，用于执行校园网络的登录操作，可能包含与认证服务器交互的命令等。
├── po
│   ├── zh_Hans
│   │   └── campus_network.po # 作用：存储校园网络相关界面文本的简体中文翻译，用于多语言支持。
│   └── templates
│       └── campus_network.pot # 作用：作为翻译模板文件，为生成不同语言的翻译文件提供基础。
└── luasrc # 作用：存放LuCI应用的Lua源代码，实现应用的业务逻辑和Web界面相关逻辑。
    ├── controller
    │   └── campus_network.lua # 作用：在LuCI框架中，定义与校园网络相关的URL路由规则和对应的处理函数，负责处理用户的请求并返回相应结果。
    └── model
        └── cbi
            └── campus_network
                └── login.lua # 作用：使用LuCI的CBI（Config Browser Interface）框架，定义校园网络登录界面的配置和行为逻辑，例如界面元素的展示、数据验证等。
```