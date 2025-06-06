package repository

import (
	"errors"
	"life_app_back/internal/model"
	"time"

	"github.com/rs/xid"
	"gorm.io/gorm"
)

// FamilyRepository 家庭数据访问层
type FamilyRepository struct{}

// Create 创建家庭
func (r FamilyRepository) Create(family model.Family) (id uint, err error) {
	// 生成唯一邀请码
	family.Code = xid.New().String()[:8]
	family.IsActive = true
	family.CreatedAt = time.Now()
	family.UpdatedAt = time.Now()

	err = model.DB.Create(&family).Error
	id = family.ID
	return
}

// FindByID 根据ID查找家庭
func (r FamilyRepository) FindByID(id uint) (family model.Family, err error) {
	if err = model.DB.First(&family, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return model.Family{}, errors.New("家庭不存在")
		}
		return model.Family{}, err
	}
	return
}

// FindByUserID 查找用户创建的所有家庭
func (r FamilyRepository) FindByUserID(userID uint) (families []model.Family, err error) {
	if err = model.DB.Where("user_id = ?", userID).Find(&families).Error; err != nil {
		return nil, err
	}
	return
}

// FindUserFamilies 查找用户所有关联的家庭（创建的+加入的）
func (r FamilyRepository) FindUserFamilies(userID uint) (families []model.Family, err error) {
	// 查询用户创建的家庭
	if err = model.DB.Where("user_id = ?", userID).Find(&families).Error; err != nil {
		return nil, err
	}

	// 查询用户作为成员加入的家庭
	var memberFamilies []model.Family
	err = model.DB.Table("family").
		Joins("JOIN family_members ON family.id = family_members.owner_id").
		Where("family_members.user_id = ? AND family_members.user_id != 0", userID).
		Find(&memberFamilies).Error

	if err != nil {
		return nil, err
	}

	// 合并结果，去重
	familyMap := make(map[uint]model.Family)
	for _, f := range families {
		familyMap[f.ID] = f
	}

	for _, f := range memberFamilies {
		if _, exists := familyMap[f.ID]; !exists {
			familyMap[f.ID] = f
			families = append(families, f)
		}
	}

	return
}

// Update 更新家庭信息
func (r FamilyRepository) Update(family model.Family) error {
	family.UpdatedAt = time.Now()
	return model.DB.Model(&model.Family{}).Where("id = ?", family.ID).Updates(family).Error
}

// Delete 删除家庭
func (r FamilyRepository) Delete(id uint) error {
	return model.DB.Delete(&model.Family{}, id).Error
}

// SetStatus 设置家庭状态
func (r FamilyRepository) SetStatus(id uint, isActive bool) error {
	return model.DB.Model(&model.Family{}).Where("id = ?", id).Update("is_active", isActive).Error
}

// GetMemberCount 获取家庭成员数量
func (r FamilyRepository) GetMemberCount(familyID uint) (int, error) {
	var count int64
	err := model.DB.Model(&model.FamilyMember{}).Where("owner_id = ?", familyID).Count(&count).Error
	return int(count), err
}

// FindByInviteCode 根据邀请码查找家庭
func (r FamilyRepository) FindByInviteCode(code string) (family model.Family, err error) {
	if err = model.DB.Where("code = ?", code).First(&family).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return model.Family{}, errors.New("邀请码无效")
		}
		return model.Family{}, err
	}
	return
}
