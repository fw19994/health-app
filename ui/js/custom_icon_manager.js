/**
 * 自定义图标管理器
 * 处理自定义图标的创建、编辑和删除
 */
const customIconManager = {
  // 可供选择的图标集合
  availableIcons: [
    'fas fa-cookie', 'fas fa-pizza-slice', 'fas fa-candy-cane', 'fas fa-ice-cream', 
    'fas fa-hamburger', 'fas fa-wine-glass', 'fas fa-cocktail', 'fas fa-coffee',
    'fas fa-dog', 'fas fa-cat', 'fas fa-fish', 'fas fa-horse', 'fas fa-paw',
    'fas fa-tshirt', 'fas fa-socks', 'fas fa-hat-wizard', 'fas fa-glasses',
    'fas fa-plane', 'fas fa-train', 'fas fa-subway', 'fas fa-ship', 'fas fa-motorcycle',
    'fas fa-bicycle', 'fas fa-running', 'fas fa-hiking', 'fas fa-skating',
    'fas fa-laptop', 'fas fa-mobile-alt', 'fas fa-headphones', 'fas fa-camera',
    'fas fa-tv', 'fas fa-gamepad', 'fas fa-dice', 'fas fa-chess',
    'fas fa-book', 'fas fa-newspaper', 'fas fa-pen', 'fas fa-paint-brush',
    'fas fa-music', 'fas fa-guitar', 'fas fa-film', 'fas fa-theater-masks'
  ],
  
  // 可供选择的颜色集合
  availableColors: [
    'red', 'orange', 'yellow', 'green', 'teal', 'blue', 
    'indigo', 'purple', 'pink', 'gray'
  ],
  
  // 当前选中的图标和颜色
  selectedIcon: null,
  selectedColor: 'red',
  
  // 初始化
  init() {
    this.renderIconSelection();
    this.renderColorSelection();
    this.bindEvents();
  },
  
  // 渲染图标选择网格
  renderIconSelection() {
    const iconSelectionGrid = document.getElementById('iconSelectionGrid');
    iconSelectionGrid.innerHTML = '';
    
    this.availableIcons.forEach(icon => {
      const iconItem = document.createElement('div');
      iconItem.className = 'icon-selection-item';
      iconItem.dataset.icon = icon;
      iconItem.innerHTML = `<i class="${icon}"></i>`;
      
      iconItem.addEventListener('click', () => this.selectIconOption(iconItem, icon));
      iconSelectionGrid.appendChild(iconItem);
    });
  },
  
  // 渲染颜色选择网格
  renderColorSelection() {
    const colorSelectionGrid = document.getElementById('colorSelectionGrid');
    colorSelectionGrid.innerHTML = '';
    
    this.availableColors.forEach(color => {
      const colorOption = document.createElement('div');
      colorOption.className = `color-option bg-${color}-500`;
      colorOption.dataset.color = color;
      
      colorOption.addEventListener('click', () => this.selectColorOption(colorOption, color));
      colorSelectionGrid.appendChild(colorOption);
    });
    
    // 默认选中第一个颜色
    const firstColorOption = colorSelectionGrid.querySelector('.color-option');
    if (firstColorOption) {
      this.selectColorOption(firstColorOption, this.availableColors[0]);
    }
  },
  
  // 绑定事件
  bindEvents() {
    // 在渲染过程中已经绑定了点击事件
  },
  
  // 显示添加自定义图标表单
  showAddForm() {
    // 重置表单
    document.getElementById('iconName').value = '';
    this.selectedIcon = null;
    this.selectedColor = 'red';
    
    // 清除选中状态
    document.querySelectorAll('.icon-selection-item').forEach(item => {
      item.classList.remove('selected');
    });
    
    // 显示表单
    document.getElementById('customIconForm').classList.add('show');
  },
  
  // 隐藏添加自定义图标表单
  hideForm() {
    document.getElementById('customIconForm').classList.remove('show');
  },
  
  // 选择图标选项
  selectIconOption(element, icon) {
    // 移除其他图标的选中状态
    document.querySelectorAll('.icon-selection-item').forEach(item => {
      item.classList.remove('selected');
    });
    
    // 添加当前图标的选中状态
    element.classList.add('selected');
    
    // 存储选中的图标
    this.selectedIcon = icon;
  },
  
  // 选择颜色选项
  selectColorOption(element, color) {
    // 移除其他颜色的选中状态
    document.querySelectorAll('.color-option').forEach(item => {
      item.classList.remove('selected');
    });
    
    // 添加当前颜色的选中状态
    element.classList.add('selected');
    
    // 存储选中的颜色
    this.selectedColor = color;
  },
  
  // 保存自定义图标
  saveCustomIcon() {
    const iconName = document.getElementById('iconName').value.trim();
    
    // 验证输入
    if (!iconName) {
      alert('请输入图标名称');
      return;
    }
    
    if (!this.selectedIcon) {
      alert('请选择一个图标');
      return;
    }
    
    // 生成唯一ID (当前时间戳)
    const id = 1000 + Date.now() % 10000;
    
    // 创建新的自定义图标
    const newCustomIcon = {
      id,
      name: iconName,
      icon: this.selectedIcon,
      color: this.selectedColor,
      category: 'custom'
    };
    
    // 添加到自定义图标列表
    iconSelector.customIcons.push(newCustomIcon);
    
    // 保存到localStorage
    iconSelector.saveData();
    
    // 重新渲染图标网格
    iconSelector.renderIcons();
    
    // 切换到自定义图标分类
    iconSelector.filterIcons('custom');
    
    // 隐藏表单
    this.hideForm();
    
    // 显示成功消息
    this.showSuccessMessage('自定义图标已创建');
  },
  
  // 显示成功消息
  showSuccessMessage(message) {
    // 创建消息元素
    const messageElement = document.createElement('div');
    messageElement.className = 'success-message';
    messageElement.innerHTML = `
      <div class="success-content">
        <i class="fas fa-check-circle"></i>
        <span>${message}</span>
      </div>
    `;
    
    // 添加到页面
    document.body.appendChild(messageElement);
    
    // 添加显示的类名
    setTimeout(() => {
      messageElement.classList.add('show');
    }, 10);
    
    // 2秒后移除
    setTimeout(() => {
      messageElement.classList.remove('show');
      
      // 动画结束后移除元素
      setTimeout(() => {
        document.body.removeChild(messageElement);
      }, 300);
    }, 2000);
  }
};

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
  customIconManager.init();
  
  // 添加成功消息样式
  const style = document.createElement('style');
  style.textContent = `
    .success-message {
      position: fixed;
      top: 20px;
      left: 50%;
      transform: translateX(-50%) translateY(-100px);
      background-color: #10b981;
      color: white;
      padding: 12px 24px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      z-index: 2000;
      transition: transform 0.3s ease-out;
    }
    
    .success-message.show {
      transform: translateX(-50%) translateY(0);
    }
    
    .success-content {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .success-content i {
      font-size: 1.25rem;
    }
  `;
  
  document.head.appendChild(style);
}); 