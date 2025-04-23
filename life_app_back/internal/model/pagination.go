package model

// Pagination 分页数据结构
type Pagination struct {
	Page       int `json:"page"`       // 当前页码
	PageSize   int `json:"page_size"`  // 每页记录数
	TotalPages int `json:"total_pages"` // 总页数
	TotalItems int `json:"total_items"` // 总记录数
	HasMore    bool `json:"has_more"`   // 是否有更多记录
}

// NewPagination 创建新的分页对象
func NewPagination(page, pageSize, totalItems int) Pagination {
	totalPages := (totalItems + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	
	return Pagination{
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
		TotalItems: totalItems,
		HasMore:    page < totalPages,
	}
}

// GetOffset 获取分页偏移量
func (p Pagination) GetOffset() int {
	return (p.Page - 1) * p.PageSize
}

// GetLimit 获取分页限制
func (p Pagination) GetLimit() int {
	return p.PageSize
} 