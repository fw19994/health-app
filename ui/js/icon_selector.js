/**
 * 图标选择器模块
 * 实现图标选择、分类筛选和最近使用功能
 */
const iconSelector = {
  // 存储图标数据
  categories: [
    { id: 'all', name: '全部' },
    { id: 'expense', name: '支出' },
    { id: 'income', name: '收入' },
    { id: 'transfer', name: '转账' },
    { id: 'budget', name: '预算' },
    { id: 'custom', name: '自定义' }
  ],
  
  // 系统预设图标
  icons: [
    // 支出图标
    { id: 1, name: '餐饮', icon: 'fas fa-utensils', color: 'red', category: 'expense' },
    { id: 2, name: '购物', icon: 'fas fa-shopping-bag', color: 'blue', category: 'expense' },
    { id: 3, name: '住房', icon: 'fas fa-home', color: 'green', category: 'expense' },
    { id: 4, name: '交通', icon: 'fas fa-car', color: 'purple', category: 'expense' },
    { id: 5, name: '娱乐', icon: 'fas fa-film', color: 'yellow', category: 'expense' },
    { id: 6, name: '医疗', icon: 'fas fa-heartbeat', color: 'pink', category: 'expense' },
    { id: 7, name: '教育', icon: 'fas fa-graduation-cap', color: 'indigo', category: 'expense' },
    { id: 8, name: '礼物', icon: 'fas fa-gift', color: 'gray', category: 'expense' },
    
    // 收入图标
    { id: 9, name: '工资', icon: 'fas fa-money-bill-wave', color: 'green', category: 'income' },
    { id: 10, name: '奖金', icon: 'fas fa-piggy-bank', color: 'blue', category: 'income' },
    { id: 11, name: '投资', icon: 'fas fa-chart-line', color: 'purple', category: 'income' },
    { id: 12, name: '兼职', icon: 'fas fa-hand-holding-usd', color: 'yellow', category: 'income' },
    
    // 转账图标
    { id: 13, name: '转账', icon: 'fas fa-exchange-alt', color: 'indigo', category: 'transfer' },
    { id: 14, name: '信用卡', icon: 'fas fa-credit-card', color: 'pink', category: 'transfer' },
    
    // 预算图标
    { id: 15, name: '预算', icon: 'fas fa-wallet', color: 'red', category: 'budget' },
    { id: 16, name: '统计', icon: 'fas fa-chart-pie', color: 'green', category: 'budget' }
  ],
  
  // 自定义图标 (初始化一些示例)
  customIcons: [
    { id: 101, name: '咖啡', icon: 'fas fa-coffee', color: 'yellow', category: 'custom' },
    { id: 102, name: '旅行', icon: 'fas fa-plane', color: 'pink', category: 'custom' },
    { id: 103, name: '音乐', icon: 'fas fa-music', color: 'indigo', category: 'custom' },
    { id: 104, name: '阅读', icon: 'fas fa-book', color: 'gray', category: 'custom' },
    { id: 105, name: '骑行', icon: 'fas fa-bicycle', color: 'green', category: 'custom' },
    { id: 106, name: '游戏', icon: 'fas fa-gamepad', color: 'blue', category: 'custom' }
  ],
  
  // 最近使用的图标
  recentIcons: [],
  
  // 当前选中的图标
  selectedIcon: null,
  
  // 初始化
  init() {
    this.loadData();
    this.renderCategories();
    this.renderIcons();
    this.renderRecentIcons();
    this.bindEvents();
  },
  
  // 加载数据 (从localStorage获取自定义图标和最近使用的图标)
  loadData() {
    // 尝试从localStorage加载自定义图标
    const storedCustomIcons = localStorage.getItem('customIcons');
    if (storedCustomIcons) {
      this.customIcons = JSON.parse(storedCustomIcons);
    }
    
    // 尝试从localStorage加载最近使用的图标
    const storedRecentIcons = localStorage.getItem('recentIcons');
    if (storedRecentIcons) {
      this.recentIcons = JSON.parse(storedRecentIcons);
    }
  },
  
  // 保存数据到localStorage
  saveData() {
    localStorage.setItem('customIcons', JSON.stringify(this.customIcons));
    localStorage.setItem('recentIcons', JSON.stringify(this.recentIcons));
  },
  
  // 渲染分类标签
  renderCategories() {
    const categoryTabs = document.getElementById('categoryTabs');
    categoryTabs.innerHTML = '';
    
    this.categories.forEach((category, index) => {
      const categoryTab = document.createElement('button');
      categoryTab.className = `category-tab ${index === 0 ? 'active' : ''}`;
      categoryTab.dataset.category = category.id;
      categoryTab.textContent = category.name;
      categoryTab.addEventListener('click', () => this.filterIcons(category.id));
      categoryTabs.appendChild(categoryTab);
    });
  },
  
  // 渲染所有图标
  renderIcons() {
    const iconGrid = document.getElementById('iconGrid');
    iconGrid.innerHTML = '';
    
    // 合并系统图标和自定义图标
    const allIcons = [...this.icons, ...this.customIcons];
    
    allIcons.forEach(icon => {
      const iconItem = document.createElement('div');
      iconItem.className = 'icon-item';
      iconItem.dataset.category = icon.category;
      iconItem.dataset.id = icon.id;
      
      iconItem.innerHTML = `
        <div class="icon-circle bg-${icon.color}-100">
          <i class="${icon.icon} text-${icon.color}-600"></i>
        </div>
        <span class="icon-name">${icon.name}</span>
      `;
      
      iconItem.addEventListener('click', () => this.selectIcon(iconItem, icon));
      iconGrid.appendChild(iconItem);
    });
  },
  
  // 渲染最近使用的图标
  renderRecentIcons() {
    const recentIcons = document.getElementById('recentIcons');
    recentIcons.innerHTML = '';
    
    // 如果没有最近使用的图标，显示提示信息
    if (this.recentIcons.length === 0) {
      recentIcons.innerHTML = '<div class="text-gray-400 text-xs">暂无最近使用的图标</div>';
      return;
    }
    
    // 仅显示最近使用的6个图标
    const recentIconsToShow = this.recentIcons.slice(0, 6);
    
    recentIconsToShow.forEach(recentIcon => {
      const iconItem = document.createElement('div');
      iconItem.className = 'recent-icon-item';
      iconItem.dataset.id = recentIcon.id;
      
      iconItem.innerHTML = `
        <div class="recent-icon-circle bg-${recentIcon.color}-100">
          <i class="${recentIcon.icon} text-${recentIcon.color}-600"></i>
        </div>
        <span class="recent-icon-name">${recentIcon.name}</span>
      `;
      
      iconItem.addEventListener('click', () => this.selectRecentIcon(iconItem, recentIcon));
      recentIcons.appendChild(iconItem);
    });
  },
  
  // 绑定事件
  bindEvents() {
    // 已在渲染过程中绑定了点击事件
  },
  
  // 显示图标选择器
  show() {
    document.getElementById('iconSelector').classList.add('show');
  },
  
  // 隐藏图标选择器
  hide() {
    document.getElementById('iconSelector').classList.remove('show');
  },
  
  // 选择图标
  selectIcon(element, icon) {
    // 移除所有图标的选中状态
    document.querySelectorAll('.icon-item').forEach(item => {
      item.classList.remove('selected');
    });
    
    // 添加当前图标的选中状态
    element.classList.add('selected');
    
    // 存储选中的图标
    this.selectedIcon = icon;
  },
  
  // 选择最近使用的图标
  selectRecentIcon(element, icon) {
    // 查找对应的图标项并选中
    const iconItem = document.querySelector(`.icon-item[data-id="${icon.id}"]`);
    if (iconItem) {
      this.selectIcon(iconItem, icon);
    }
  },
  
  // 过滤图标
  filterIcons(category) {
    // 更新分类标签状态
    document.querySelectorAll('.category-tab').forEach(tab => {
      tab.classList.remove('active');
    });
    document.querySelector(`.category-tab[data-category="${category}"]`).classList.add('active');
    
    // 过滤图标
    document.querySelectorAll('.icon-item').forEach(item => {
      if (category === 'all' || item.dataset.category === category) {
        item.style.display = 'flex';
      } else {
        item.style.display = 'none';
      }
    });
  },
  
  // 确认选择
  confirmSelection() {
    if (this.selectedIcon) {
      // 添加到最近使用
      this.addToRecentIcons(this.selectedIcon);
      
      // 触发选择完成事件
      const event = new CustomEvent('icon-selected', {
        detail: {
          icon: this.selectedIcon
        }
      });
      document.dispatchEvent(event);
      
      // 输出选中的图标信息
      console.log('已选择图标:', this.selectedIcon);
    }
    
    // 关闭选择器
    this.hide();
  },
  
  // 添加到最近使用
  addToRecentIcons(icon) {
    // 移除已存在的相同图标
    this.recentIcons = this.recentIcons.filter(item => item.id !== icon.id);
    
    // 添加到开头
    this.recentIcons.unshift(icon);
    
    // 限制最多保存10个
    if (this.recentIcons.length > 10) {
      this.recentIcons.pop();
    }
    
    // 保存到localStorage
    this.saveData();
    
    // 重新渲染最近使用的图标
    this.renderRecentIcons();
  }
};

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
  iconSelector.init();
}); 