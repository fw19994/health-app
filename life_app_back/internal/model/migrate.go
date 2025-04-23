package model

import (
	"fmt"
	"gorm.io/gorm"
)

// AutoMigrate 自动创建或更新数据库表结构
func AutoMigrate(db *gorm.DB) error {
	// 创建所有数据表
	err := db.AutoMigrate(
		&User{},
		&UserProfile{},
		&FamilyMember{},
		&Invitation{},
		&SavingsGoal{},
		&BudgetCategory{},
		&SavingsGoal{},
		// 其他表...
	)

	if err != nil {
		return fmt.Errorf("自动创建表失败: %w", err)
	}

	return nil
}
