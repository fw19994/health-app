package config

import (
	"fmt"
	"strings"
	"time"

	"github.com/spf13/viper"
)

// 构建配置对象
var ConfigData Config

// Config 应用的配置结构
type Config struct {
	App      AppConfig
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	JWT      JWTConfig
	SMS      SMSConfig
	OSS      OSSConfig
}

// AppConfig 应用基本配置
type AppConfig struct {
	Name  string
	Debug bool
	Env   string
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Port    string
	Timeout time.Duration
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Driver          string
	Host            string
	Port            string
	Username        string
	Password        string
	Database        string
	Options         string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

// RedisConfig Redis配置
type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret        string
	AccessExpiry  time.Duration // 短期令牌有效期
	RefreshExpiry time.Duration // 长期刷新令牌有效期
	Issuer        string        // 发行者
}

// SMSConfig 短信配置
type SMSConfig struct {
	Provider   string // 短信服务提供商 (aliyun, tencent, 等)
	AccessKey  string // 访问密钥
	SecretKey  string // 密钥
	SignName   string // 短信签名
	TemplateID string // 短信模板ID
	ExpireTime int    // 验证码有效期(秒)
	CodeLength int    // 验证码长度
	MockInDev  bool   // 开发环境是否模拟短信发送
}

// Load 从配置文件加载配置
func Load() (*Config, error) {
	// 获取并规范化环境
	env := GetEnvironment()

	// 初始化新的viper实例
	v := viper.New()

	// 设置环境变量前缀和分隔符
	v.SetEnvPrefix("LIFEAPP")
	v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	v.AutomaticEnv() // 绑定环境变量
	// 设置环境特定的配置文件
	configName := fmt.Sprintf("config.%s", env)
	v.SetConfigName(configName)
	v.SetConfigType("yaml")
	v.AddConfigPath("./config")
	v.AddConfigPath(".")

	// 尝试读取环境配置文件
	if err := v.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			fmt.Printf("Warning: Config file '%s' not found, using defaults\n", configName)
		} else {
			return nil, fmt.Errorf("error reading environment config file: %w", err)
		}
	} else {
		fmt.Printf("Loaded environment config: %s [%s]\n", v.ConfigFileUsed(), env)
	}

	// 尝试加载模块配置
	moduleConfig := viper.New()
	moduleConfig.SetConfigName("config.module")
	moduleConfig.SetConfigType("yaml")
	moduleConfig.AddConfigPath("./config")
	moduleConfig.AddConfigPath(".")

	if err := moduleConfig.ReadInConfig(); err != nil {
		// 模块配置是可选的，所以不返回错误
		fmt.Println("No module config found, skipping module configuration")
	} else {
		fmt.Printf("Loaded module config: %s\n", moduleConfig.ConfigFileUsed())

		// 将模块配置合并到主配置
		for _, key := range moduleConfig.AllKeys() {
			v.Set(key, moduleConfig.Get(key))
		}
	}

	// 处理配置中的环境变量引用
	for _, k := range v.AllKeys() {
		val := v.GetString(k)
		if strings.HasPrefix(val, "${") && strings.HasSuffix(val, "}") {
			// 使用环境工具函数替换变量引用
			replacedVal := ReplaceEnvVars(val)
			if replacedVal != val {
				v.Set(k, replacedVal)
			}
		}
	}

	if err := v.Unmarshal(&ConfigData); err != nil {
		return nil, fmt.Errorf("unable to decode config into struct: %w", err)
	}

	// 验证配置
	if err := validateConfig(&ConfigData); err != nil {
		return nil, fmt.Errorf("config validation failed: %w", err)
	}

	// 打印环境信息
	fmt.Printf("Configuration loaded: environment=%s, debug=%v, database=%s\n",
		ConfigData.App.Env, ConfigData.App.Debug, ConfigData.Database.Host)

	return &ConfigData, nil
}

// validateConfig 验证配置是否有效
func validateConfig(cfg *Config) error {
	// 验证数据库配置
	if cfg.Database.Host == "" {
		return fmt.Errorf("database host cannot be empty")
	}

	if cfg.Database.Username == "" {
		return fmt.Errorf("database username cannot be empty")
	}

	// 对生产环境有特殊要求
	if IsProduction() {
		// 生产环境不应该启用调试模式
		if cfg.App.Debug {
			fmt.Println("Warning: Debug mode is enabled in production environment")
		}

		// 生产环境应该设置JWT密钥
		if cfg.JWT.Secret == "" || cfg.JWT.Secret == "lifeapp_local_secret_key_change_in_production" {
			return fmt.Errorf("jwt secret must be set in production environment")
		}
	}

	return nil
}
