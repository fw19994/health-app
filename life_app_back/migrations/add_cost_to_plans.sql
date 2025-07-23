-- 为plan表添加cost字段
ALTER TABLE plan ADD COLUMN cost DECIMAL(10, 2) DEFAULT 0.00 AFTER recurrence_type;

-- 更新注释
COMMENT ON COLUMN plan.cost IS '费用'; 