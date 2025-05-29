package repository

import "life_app_back/internal/model"

type FamilyRepository struct {
}

func (r FamilyRepository) Create(family model.Family) (id uint, err error) {
	err = model.DB.Create(&family).Error
	id = family.ID
	return
}
