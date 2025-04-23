# 悦管家后端服务

悦管家应用的Go后端服务，提供用户认证、短信验证码、家庭成员管理等功能。

## 环境配置说明

本项目支持多环境配置，可以轻松地在开发环境和生产环境之间切换。

### 配置文件

配置文件位于 `config` 目录下：

- `config.local.yaml` - 本地开发环境配置
- `config.prod.yaml` - 生产环境配置

### 环境变量

使用 `APP_ENV` 环境变量来指定运行环境：

```bash
# 本地环境（默认）
APP_ENV=local go run cmd/api/main.go

# 生产环境
APP_ENV=prod go run cmd/api/main.go
```

### 环境变量替换

在配置文件中，你可以使用 `${ENV_VAR}` 语法来引用环境变量：

```yaml
database:
  password: "${DB_PASSWORD}"  # 将使用环境变量DB_PASSWORD的值
```

这对于生产环境中的敏感信息（如密码、API密钥等）非常有用。

### 配置覆盖

配置加载优先级（从高到低）：

1. 环境变量
2. 配置文件
3. 代码中的默认值

所有以 `LIFEAPP_` 开头的环境变量都可以覆盖配置文件中的值。例如：

```bash
# 设置数据库密码
LIFEAPP_DATABASE_PASSWORD=mypassword go run cmd/api/main.go

# 设置应用端口
LIFEAPP_SERVER_PORT=9000 go run cmd/api/main.go
```

## 运行应用

### 前置条件

- Go 1.16+
- MySQL 5.7+
- Redis 6.0+

### 开发环境

```bash
# 克隆仓库
git clone <repository-url>
cd life_app_back

# 安装依赖
go mod tidy

# 运行应用（使用本地配置）
go run cmd/api/main.go
```

### 生产环境

```bash
# 编译应用
go build -o lifeapp-api cmd/api/main.go

# 运行应用（使用生产配置）
APP_ENV=prod ./lifeapp-api
```

## 主要功能

- 手机号验证码登录
- 用户注册和管理
- JWT认证
- 家庭成员管理
- 财务记录与统计
