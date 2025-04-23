/**
 * 日期选择器组件
 * 一个可复用的日期选择器组件，支持年月日选择
 */
class DatePicker {
  /**
   * 构造函数
   * @param {Object} options - 配置选项
   * @param {String} options.containerId - 容器元素ID
   * @param {Function} options.onDateSelect - 日期选择回调函数
   * @param {Date} options.initialDate - 初始日期，默认为当前日期
   * @param {Number} options.startYear - 起始年份，默认为当前年份减5年
   * @param {Number} options.endYear - 结束年份，默认为当前年份加5年
   */
  constructor(options = {}) {
    // 默认配置
    this.defaults = {
      containerId: 'datePicker',
      onDateSelect: null,
      initialDate: new Date(),
      startYear: new Date().getFullYear() - 5,
      endYear: new Date().getFullYear() + 5
    };

    // 合并选项
    this.options = { ...this.defaults, ...options };
    
    // 获取容器元素
    this.container = document.getElementById(this.options.containerId);
    if (!this.container) {
      console.error(`找不到ID为${this.options.containerId}的容器元素`);
      return;
    }
    
    // 初始化状态
    this.today = new Date();
    this.selectedDate = this.options.initialDate;
    
    // 创建DOM元素
    this.render();
    
    // 初始化事件监听
    this.setupEventListeners();
  }
  
  /**
   * 渲染日期选择器
   */
  render() {
    // 创建HTML结构
    this.container.innerHTML = `
      <div class="date-picker card rounded-xl shadow-lg overflow-hidden">
        <!-- 日期选择器头部 -->
        <div class="date-picker-header">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-bold">选择日期</h2>
            <button class="text-white" id="${this.options.containerId}_closeButton">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="flex items-center justify-between">
            <div class="text-xl font-semibold" id="${this.options.containerId}_selectedDateDisplay"></div>
          </div>
        </div>

        <!-- 日期选择器主体 -->
        <div class="bg-white p-4">
          <!-- 月份和年份选择器 -->
          <div class="flex justify-between gap-3 mb-6">
            <select class="month-year-selector flex-1" id="${this.options.containerId}_yearSelector">
              ${this.generateYearOptions()}
            </select>
            <select class="month-year-selector flex-1" id="${this.options.containerId}_monthSelector">
              ${this.generateMonthOptions()}
            </select>
          </div>

          <!-- 星期标题 -->
          <div class="calendar-grid mb-2">
            <div class="weekday-label">日</div>
            <div class="weekday-label">一</div>
            <div class="weekday-label">二</div>
            <div class="weekday-label">三</div>
            <div class="weekday-label">四</div>
            <div class="weekday-label">五</div>
            <div class="weekday-label">六</div>
          </div>

          <!-- 日历网格 -->
          <div class="calendar-grid" id="${this.options.containerId}_calendarGrid"></div>

          <!-- 快速选择按钮 -->
          <div class="flex flex-wrap gap-2 mt-6 mb-4">
            <button class="px-3 py-1 text-sm border border-gray-200 rounded-full hover:border-orange-500 hover:text-orange-500" data-quick="today">
              今天
            </button>
            <button class="px-3 py-1 text-sm border border-gray-200 rounded-full hover:border-orange-500 hover:text-orange-500" data-quick="tomorrow">
              明天
            </button>
            <button class="px-3 py-1 text-sm border border-gray-200 rounded-full hover:border-orange-500 hover:text-orange-500" data-quick="next-week">
              下周
            </button>
            <button class="px-3 py-1 text-sm border border-gray-200 rounded-full hover:border-orange-500 hover:text-orange-500" data-quick="next-month">
              下个月
            </button>
          </div>

          <!-- 操作按钮 -->
          <div class="grid grid-cols-2 gap-3 mt-6">
            <button class="py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700" id="${this.options.containerId}_cancelButton">
              取消
            </button>
            <button class="py-2.5 bg-orange-500 text-white rounded-lg font-medium" id="${this.options.containerId}_confirmButton">
              确认
            </button>
          </div>
        </div>
      </div>
    `;
    
    // 添加样式
    this.addStyles();
    
    // 获取DOM元素引用
    this.elements = {
      yearSelector: document.getElementById(`${this.options.containerId}_yearSelector`),
      monthSelector: document.getElementById(`${this.options.containerId}_monthSelector`),
      calendarGrid: document.getElementById(`${this.options.containerId}_calendarGrid`),
      selectedDateDisplay: document.getElementById(`${this.options.containerId}_selectedDateDisplay`),
      confirmButton: document.getElementById(`${this.options.containerId}_confirmButton`),
      cancelButton: document.getElementById(`${this.options.containerId}_cancelButton`),
      closeButton: document.getElementById(`${this.options.containerId}_closeButton`),
      quickButtons: this.container.querySelectorAll('[data-quick]')
    };
    
    // 设置下拉菜单初始值
    this.elements.yearSelector.value = this.selectedDate.getFullYear();
    this.elements.monthSelector.value = this.selectedDate.getMonth();
    
    // 初始化日历
    this.updateCalendar();
    this.updateSelectedDateDisplay();
  }
  
  /**
   * 添加样式
   */
  addStyles() {
    const styleId = 'datePickerStyles';
    
    // 检查样式是否已存在
    if (!document.getElementById(styleId)) {
      const style = document.createElement('style');
      style.id = styleId;
      style.textContent = `
        .date-picker-header {
          background: linear-gradient(to right, #f97316, #f59e0b);
          color: white;
          padding: 1rem;
          border-radius: 1rem 1rem 0 0;
        }

        .calendar-grid {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 8px;
        }

        .calendar-day {
          width: 40px;
          height: 40px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 50%;
          cursor: pointer;
          font-size: 14px;
          transition: all 0.2s;
        }

        .calendar-day:hover:not(.day-disabled) {
          background-color: #f3f4f6;
        }

        .day-today {
          border: 1px dashed #f97316;
        }

        .day-selected {
          background-color: #f97316 !important;
          color: white !important;
        }

        .day-disabled {
          color: #d1d5db;
          cursor: not-allowed;
        }

        .month-year-selector {
          border-radius: 8px;
          background-color: #f8fafc;
          padding: 10px 12px;
          cursor: pointer;
          border: 1px solid #e5e7eb;
        }

        .month-year-selector:focus {
          outline: none;
          border-color: #f97316;
          box-shadow: 0 0 0 2px rgba(249, 115, 22, 0.2);
        }

        .weekday-label {
          color: #9ca3af;
          font-size: 12px;
          text-align: center;
          margin-bottom: 8px;
        }
      `;
      document.head.appendChild(style);
    }
  }
  
  /**
   * 生成年份选项
   * @returns {String} 年份选项HTML
   */
  generateYearOptions() {
    let options = '';
    for (let year = this.options.startYear; year <= this.options.endYear; year++) {
      const selected = year === this.selectedDate.getFullYear() ? 'selected' : '';
      options += `<option value="${year}" ${selected}>${year}年</option>`;
    }
    return options;
  }
  
  /**
   * 生成月份选项
   * @returns {String} 月份选项HTML
   */
  generateMonthOptions() {
    const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    let options = '';
    
    months.forEach((month, index) => {
      const selected = index === this.selectedDate.getMonth() ? 'selected' : '';
      options += `<option value="${index}" ${selected}>${month}</option>`;
    });
    
    return options;
  }
  
  /**
   * 设置事件监听器
   */
  setupEventListeners() {
    // 年份和月份变化事件
    this.elements.yearSelector.addEventListener('change', () => this.updateCalendar());
    this.elements.monthSelector.addEventListener('change', () => this.updateCalendar());
    
    // 快速选择按钮点击事件
    this.elements.quickButtons.forEach(button => {
      button.addEventListener('click', () => {
        const action = button.getAttribute('data-quick');
        const newDate = new Date();
        
        switch(action) {
          case 'today':
            this.selectedDate = new Date();
            break;
          case 'tomorrow':
            newDate.setDate(newDate.getDate() + 1);
            this.selectedDate = newDate;
            break;
          case 'next-week':
            newDate.setDate(newDate.getDate() + 7);
            this.selectedDate = newDate;
            break;
          case 'next-month':
            newDate.setMonth(newDate.getMonth() + 1);
            this.selectedDate = newDate;
            break;
        }
        
        // 更新选择器和日历
        this.elements.yearSelector.value = this.selectedDate.getFullYear();
        this.elements.monthSelector.value = this.selectedDate.getMonth();
        this.updateCalendar();
        this.updateSelectedDateDisplay();
      });
    });
    
    // 确认按钮点击事件
    this.elements.confirmButton.addEventListener('click', () => {
      if (typeof this.options.onDateSelect === 'function') {
        this.options.onDateSelect(this.selectedDate);
      }
    });
    
    // 取消按钮点击事件
    this.elements.cancelButton.addEventListener('click', () => {
      this.selectedDate = new Date();
      this.elements.yearSelector.value = this.selectedDate.getFullYear();
      this.elements.monthSelector.value = this.selectedDate.getMonth();
      this.updateCalendar();
      this.updateSelectedDateDisplay();
    });
    
    // 关闭按钮点击事件
    this.elements.closeButton.addEventListener('click', () => {
      this.hide();
    });
  }
  
  /**
   * 更新日历
   */
  updateCalendar() {
    const year = parseInt(this.elements.yearSelector.value);
    const month = parseInt(this.elements.monthSelector.value);
    
    // 清空日历
    this.elements.calendarGrid.innerHTML = '';
    
    // 获取月份第一天和最后一天
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    
    // 添加月份第一天之前的空单元格
    const firstDayOfWeek = firstDay.getDay();
    for (let i = 0; i < firstDayOfWeek; i++) {
      const emptyCell = document.createElement('div');
      this.elements.calendarGrid.appendChild(emptyCell);
    }
    
    // 添加月份中的日期
    for (let day = 1; day <= lastDay.getDate(); day++) {
      const dayCell = document.createElement('div');
      dayCell.classList.add('calendar-day');
      dayCell.textContent = day;
      
      const currentDate = new Date(year, month, day);
      
      // 检查是否为今天
      if (year === this.today.getFullYear() && 
          month === this.today.getMonth() && 
          day === this.today.getDate()) {
        dayCell.classList.add('day-today');
      }
      
      // 检查是否为选中日期
      if (year === this.selectedDate.getFullYear() && 
          month === this.selectedDate.getMonth() && 
          day === this.selectedDate.getDate()) {
        dayCell.classList.add('day-selected');
      }
      
      // 添加点击事件
      dayCell.addEventListener('click', () => {
        // 移除之前选中日期的样式
        const previouslySelected = this.elements.calendarGrid.querySelector('.day-selected');
        if (previouslySelected) {
          previouslySelected.classList.remove('day-selected');
        }
        
        // 添加新选中日期的样式
        dayCell.classList.add('day-selected');
        
        // 更新选中日期
        this.selectedDate = new Date(year, month, day);
        this.updateSelectedDateDisplay();
      });
      
      this.elements.calendarGrid.appendChild(dayCell);
    }
  }
  
  /**
   * 更新选中日期显示
   */
  updateSelectedDateDisplay() {
    const year = this.selectedDate.getFullYear();
    const month = this.selectedDate.getMonth() + 1;
    const day = this.selectedDate.getDate();
    this.elements.selectedDateDisplay.textContent = `${year}年${month}月${day}日`;
  }
  
  /**
   * 设置日期
   * @param {Date} date - 要设置的日期
   */
  setDate(date) {
    this.selectedDate = date;
    this.elements.yearSelector.value = this.selectedDate.getFullYear();
    this.elements.monthSelector.value = this.selectedDate.getMonth();
    this.updateCalendar();
    this.updateSelectedDateDisplay();
  }
  
  /**
   * 获取选中的日期
   * @returns {Date} 选中的日期
   */
  getDate() {
    return this.selectedDate;
  }
  
  /**
   * 显示日期选择器
   */
  show() {
    this.container.style.display = 'block';
  }
  
  /**
   * 隐藏日期选择器
   */
  hide() {
    this.container.style.display = 'none';
  }
}

// 导出组件
window.DatePicker = DatePicker; 