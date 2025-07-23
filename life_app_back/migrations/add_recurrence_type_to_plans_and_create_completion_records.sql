-- 向计划表添加重复类型字段
ALTER TABLE plan ADD COLUMN recurrence_type VARCHAR(20) DEFAULT 'once' COMMENT '重复类型 (once, daily, weekly, monthly, weekdays, weekends)';

-- 创建计划完成记录表
CREATE TABLE IF NOT EXISTS plan_completion_records (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    plan_id INT UNSIGNED NOT NULL COMMENT '关联的计划ID',
    user_id INT UNSIGNED NOT NULL COMMENT '完成用户ID',
    date DATETIME NOT NULL COMMENT '完成日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_plan_id (plan_id),
    INDEX idx_user_id (user_id),
    INDEX idx_date (date),
    FOREIGN KEY (plan_id) REFERENCES plan(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='计划完成记录表'; 