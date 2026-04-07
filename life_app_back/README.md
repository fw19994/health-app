# 悦管家后端服务

悦管家应用的 Go 后端服务，提供用户认证、短信验证码、家庭成员管理等功能。

## 配置文件（开源仓库）

**仓库中不包含真实配置文件**，只提供示例。请在本机复制后填写自己的数据库、密钥等：

```bash
cd config
cp config.dev.yaml.example config.dev.yaml
# 按需编辑 config.dev.yaml（或使用环境变量 LIFEAPP_* 覆盖）

# 生产环境同理
cp config.prod.yaml.example config.prod.yaml
```

以下文件已被 `.gitignore` 忽略，**切勿**将含真实密码的版本提交到 Git：

- `config/config.dev.yaml`
- `config/config.prod.yaml`
- `config/config.local.yaml`（若你自行使用本地环境名）

示例文件说明：

- `config.dev.yaml.example` — 开发环境
- `config.prod.yaml.example` — 生产环境（敏感项建议全部用环境变量）

### 环境变量

使用 `APP_ENV` 指定运行环境（与 `internal/config` 中的命名一致：`dev` / `prod` / `local`）：

```bash
# 开发配置（对应 config.dev.yaml）
APP_ENV=dev go run main.go

# 生产配置（对应 config.prod.yaml）
APP_ENV=prod go run main.go
```

### 环境变量替换

配置文件中可使用 `${ENV_VAR}` 或 `${ENV_VAR:-默认值}` 引用环境变量（见 `internal/config/env.go`）。

### 配置覆盖

所有以 **`LIFEAPP_`** 开头的环境变量可覆盖配置文件中的值（Viper），例如：

```bash
LIFEAPP_DATABASE_PASSWORD=mypassword APP_ENV=dev go run main.go
LIFEAPP_SERVER_PORT=9000 APP_ENV=dev go run main.go
```

## 运行应用

### 前置条件

- Go 1.20+（见 `go.mod`）
- MySQL 5.7+
- Redis 6.0+（若代码中启用）

### 开发环境

```bash
git clone <repository-url>
cd life_app_back
go mod tidy

cp config/config.dev.yaml.example config/config.dev.yaml
# 编辑 config/config.dev.yaml

APP_ENV=dev go run main.go
```

### 生产环境

```bash
go build -o lifeapp-api main.go
APP_ENV=prod ./lifeapp-api
```

## 主要功能

- 手机号验证码登录
- 用户注册和管理
- JWT 认证
- 家庭成员管理
- 财务记录与统计
