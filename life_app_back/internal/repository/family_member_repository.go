package repository

import (
	"errors"
	"time"

	"life_app_back/internal/model"
)

// FamilyMemberRepository 家庭成员仓库
type FamilyMemberRepository struct{}

// GetFamilyMembers 获取家庭成员列表
func (r *FamilyMemberRepository) GetFamilyMembers(ownerID uint) ([]model.FamilyMember, error) {
	var members []model.FamilyMember
	db := model.DB
	if err := db.Where("owner_id = ?", ownerID).Find(&members).Error; err != nil {
		return nil, err
	}
	return members, nil
}

// GetFamilyMemberByID 根据ID获取家庭成员
func (r *FamilyMemberRepository) GetFamilyMemberByID(id uint) (*model.FamilyMember, error) {
	var member model.FamilyMember
	db := model.DB
	if err := db.First(&member, id).Error; err != nil {
		return nil, err
	}
	return &member, nil
}

// GetFamilyMemberByUserID 根据用户ID获取家庭成员
func (r *FamilyMemberRepository) GetFamilyMemberByUserID(ownerID, userID uint) (*model.FamilyMember, error) {
	var member model.FamilyMember
	db := model.DB
	if err := db.Where("owner_id = ? AND user_id = ?", ownerID, userID).First(&member).Error; err != nil {
		return nil, err
	}
	return &member, nil
}

// GetFamilyMemberByUserIDDirect 直接根据用户ID获取家庭成员
func (r *FamilyMemberRepository) GetFamilyMemberByUserIDDirect(userID uint) (*model.FamilyMember, error) {
	var member model.FamilyMember
	db := model.DB
	if err := db.Where("user_id = ? and status=1", userID).First(&member).Error; err != nil {
		return nil, err
	}
	return &member, nil
}

// CreateFamilyMember 创建家庭成员
func (r *FamilyMemberRepository) CreateFamilyMember(member *model.FamilyMember) error {
	db := model.DB
	return db.Create(member).Error
}

// UpdateFamilyMember 更新家庭成员
func (r *FamilyMemberRepository) UpdateFamilyMember(member *model.FamilyMember) error {
	db := model.DB
	return db.Save(member).Error
}

// DeleteFamilyMember 删除家庭成员
func (r *FamilyMemberRepository) DeleteFamilyMember(id uint) error {
	db := model.DB
	return db.Delete(&model.FamilyMember{}, id).Error
}

// DeleteByOwnerID 根据家庭ID(owner_id)删除所有成员
func (r *FamilyMemberRepository) DeleteByOwnerID(ownerID uint) error {
	db := model.DB
	return db.Where("owner_id = ?", ownerID).Delete(&model.FamilyMember{}).Error
}

// CreateInvitation 创建邀请
func (r *FamilyMemberRepository) CreateInvitation(invitation *model.Invitation) error {
	db := model.DB
	return db.Create(invitation).Error
}

// GetInvitationByCode 根据邀请码获取邀请
func (r *FamilyMemberRepository) GetInvitationByCode(code string) (*model.Invitation, error) {
	var invitation model.Invitation
	db := model.DB
	if err := db.Where("invite_code = ?", code).First(&invitation).Error; err != nil {
		return nil, err
	}

	// 检查邀请是否过期
	if invitation.ExpireTime.Before(time.Now()) {
		return nil, errors.New("邀请已过期")
	}

	return &invitation, nil
}

// DeleteInvitation 删除邀请
func (r *FamilyMemberRepository) DeleteInvitation(id uint) error {
	db := model.DB
	return db.Delete(&model.Invitation{}, id).Error
}
