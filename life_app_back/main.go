package main

import (
	"context"
	"fmt"
	"life_app_back/internal/middleware"
	"life_app_back/internal/router"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"life_app_back/internal/config"
	"life_app_back/internal/handler"
	"life_app_back/internal/model"
)

func main() {
	// 输出当前环境
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "dev"
		fmt.Println("未检测到APP_ENV环境变量，默认使用本地环境配置")
	} else {
		fmt.Printf("当前运行环境: %s\n", env)
	}

	// 加载配置
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 将配置设置为全局变量
	handler.Cfg = cfg

	// 输出应用信息
	fmt.Printf("启动应用: %s (调试模式: %v)\n", cfg.App.Name, cfg.App.Debug)
	fmt.Printf("监听端口: %s\n", cfg.Server.Port)

	// 设置应用运行模式
	if cfg.App.Debug {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	// 初始化数据库连接
	if err := model.InitDB(cfg.Database); err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	//// 初始化Redis连接
	//if err := model.InitRedis(cfg.Redis); err != nil {
	//	log.Fatalf("Failed to connect to Redis: %v", err)
	//}

	// 创建Gin实例，取消默认中间件，改用自定义处理
	setupRouter := gin.New()

	// 添加自定义中间件
	setupRouter.Use(gin.Logger())                 // 日志中间件
	setupRouter.Use(middleware.ErrorHandler())    // 全局错误处理中间件
	setupRouter.Use(middleware.ResponseHandler()) // 统一响应处理

	// 设置未找到路由和不支持方法的处理函数
	setupRouter.NoRoute(middleware.NotFound)
	setupRouter.NoMethod(middleware.MethodNotAllowed)

	// 初始化路由
	setupRouter = router.SetupRouter(setupRouter)

	// 创建HTTP服务器
	srv := &http.Server{
		Addr:    ":" + cfg.Server.Port,
		Handler: setupRouter,
	}

	// 在goroutine中启动服务器，以便不阻塞优雅关闭处理
	go func() {
		log.Printf("Server is running on port %s", cfg.Server.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// 等待中断信号以优雅地关闭服务器
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// 使用等待超时的上下文设置关闭超时
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}

	log.Println("Server exiting")
}
