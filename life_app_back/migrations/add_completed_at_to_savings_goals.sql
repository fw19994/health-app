-- 为savings_goals表添加completed_at列
ALTER TABLE savings_goals ADD COLUMN completed_at TIMESTAMP NULL;

-- 为已完成状态的储蓄目标设置completed_at为updated_at
UPDATE savings_goals 
SET completed_at = updated_at 
WHERE status = 'completed' AND completed_at IS NULL;

-- 添加索引以提高查询性能
CREATE INDEX idx_savings_goals_completed_at ON savings_goals(completed_at); 