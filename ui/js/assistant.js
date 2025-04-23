/**
 * 智能助手全局组件
 * 在所有应用页面中添加悬浮式智能助手按钮和交互界面
 */

class SmartAssistant {
  constructor() {
    this.initialized = false;
    this.isOpen = false;
    this.isListening = false;
    this.recognition = null;
    
    // 初始化语音识别（如果浏览器支持）
    if ('webkitSpeechRecognition' in window) {
      this.recognition = new webkitSpeechRecognition();
      this.recognition.continuous = false;
      this.recognition.interimResults = false;
      this.recognition.lang = 'zh-CN';
      
      this.recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        document.getElementById('assistant-input').value = transcript;
        this.stopListening();
        // 自动发送识别到的内容
        setTimeout(() => this.sendMessage(), 500);
      };
      
      this.recognition.onerror = (event) => {
        console.error('语音识别错误:', event.error);
        this.stopListening();
      };
    }
  }
  
  init() {
    if (this.initialized) return;
    
    // 创建助手悬浮按钮
    const floatingButton = document.createElement('div');
    floatingButton.className = 'assistant-floating-button';
    floatingButton.innerHTML = `
      <div class="assistant-icon">
        <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M18 3.5C9.44 3.5 2.5 10.44 2.5 19C2.5 27.56 9.44 34.5 18 34.5C26.56 34.5 33.5 27.56 33.5 19C33.5 10.44 26.56 3.5 18 3.5Z" fill="#FFF5E0" stroke="#FFFFFF"/>
          <path d="M24.5 13.5C24.5 16.26 22.26 18.5 19.5 18.5C16.74 18.5 14.5 16.26 14.5 13.5C14.5 10.74 16.74 8.5 19.5 8.5C22.26 8.5 24.5 10.74 24.5 13.5Z" fill="#FFCC80"/>
          <path d="M12.5 13C12.5 14.66 11.16 16 9.5 16C7.84 16 6.5 14.66 6.5 13C6.5 11.34 7.84 10 9.5 10C11.16 10 12.5 11.34 12.5 13Z" fill="#FFCC80"/>
          <path d="M8 21.25C8 19.18 9.68 17.5 11.75 17.5H24.25C26.32 17.5 28 19.18 28 21.25V23C28 26.31 25.31 29 22 29H14C10.69 29 8 26.31 8 23V21.25Z" fill="#FFCC80"/>
          <circle cx="10.5" cy="13" r="1.5" fill="#795548"/>
          <circle cx="19.5" cy="13" r="1.5" fill="#795548"/>
          <path d="M14 22C14.5 23 16 24 18 24C20 24 21.5 23 22 22" stroke="#795548" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
      </div>
    `;
    document.body.appendChild(floatingButton);
    
    // 创建助手对话框
    const chatContainer = document.createElement('div');
    chatContainer.className = 'assistant-chat-container';
    chatContainer.style.display = 'none';
    
    chatContainer.innerHTML = `
      <div class="assistant-chat-header">
        <div class="assistant-chat-title">
          <div class="assistant-avatar small">
            <div class="assistant-icon">
              <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M18 3.5C9.44 3.5 2.5 10.44 2.5 19C2.5 27.56 9.44 34.5 18 34.5C26.56 34.5 33.5 27.56 33.5 19C33.5 10.44 26.56 3.5 18 3.5Z" fill="#FFF5E0" stroke="#FFFFFF"/>
                <path d="M24.5 13.5C24.5 16.26 22.26 18.5 19.5 18.5C16.74 18.5 14.5 16.26 14.5 13.5C14.5 10.74 16.74 8.5 19.5 8.5C22.26 8.5 24.5 10.74 24.5 13.5Z" fill="#FFCC80"/>
                <path d="M12.5 13C12.5 14.66 11.16 16 9.5 16C7.84 16 6.5 14.66 6.5 13C6.5 11.34 7.84 10 9.5 10C11.16 10 12.5 11.34 12.5 13Z" fill="#FFCC80"/>
                <path d="M8 21.25C8 19.18 9.68 17.5 11.75 17.5H24.25C26.32 17.5 28 19.18 28 21.25V23C28 26.31 25.31 29 22 29H14C10.69 29 8 26.31 8 23V21.25Z" fill="#FFCC80"/>
                <circle cx="10.5" cy="13" r="1.5" fill="#795548"/>
                <circle cx="19.5" cy="13" r="1.5" fill="#795548"/>
                <path d="M14 22C14.5 23 16 24 18 24C20 24 21.5 23 22 22" stroke="#795548" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </div>
          </div>
          <div>
            <div class="title">小财</div>
            <div class="status">财务小助手</div>
          </div>
        </div>
        <div class="assistant-chat-actions">
          <button class="minimize-button"><i class="fas fa-minus"></i></button>
          <button class="close-button"><i class="fas fa-times"></i></button>
        </div>
      </div>
      <div class="assistant-chat-messages">
        <div class="message assistant">
          <div class="assistant-avatar">
            <div class="assistant-icon">
              <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M18 3.5C9.44 3.5 2.5 10.44 2.5 19C2.5 27.56 9.44 34.5 18 34.5C26.56 34.5 33.5 27.56 33.5 19C33.5 10.44 26.56 3.5 18 3.5Z" fill="#FFF5E0" stroke="#FFFFFF"/>
                <path d="M24.5 13.5C24.5 16.26 22.26 18.5 19.5 18.5C16.74 18.5 14.5 16.26 14.5 13.5C14.5 10.74 16.74 8.5 19.5 8.5C22.26 8.5 24.5 10.74 24.5 13.5Z" fill="#FFCC80"/>
                <path d="M12.5 13C12.5 14.66 11.16 16 9.5 16C7.84 16 6.5 14.66 6.5 13C6.5 11.34 7.84 10 9.5 10C11.16 10 12.5 11.34 12.5 13Z" fill="#FFCC80"/>
                <path d="M8 21.25C8 19.18 9.68 17.5 11.75 17.5H24.25C26.32 17.5 28 19.18 28 21.25V23C28 26.31 25.31 29 22 29H14C10.69 29 8 26.31 8 23V21.25Z" fill="#FFCC80"/>
                <circle cx="10.5" cy="13" r="1.5" fill="#795548"/>
                <circle cx="19.5" cy="13" r="1.5" fill="#795548"/>
                <path d="M14 22C14.5 23 16 24 18 24C20 24 21.5 23 22 22" stroke="#795548" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </div>
          </div>
          <div class="message-content">
            <p>您好，我是小财！您的智能财务助手！我可以帮您：</p>
            <ul class="mt-2 ml-4 list-disc text-sm">
              <li>分析您的支出模式</li>
              <li>提供节省开支的建议</li>
              <li>回答财务相关问题</li>
              <li>提醒您重要的账单日期</li>
            </ul>
            <p class="mt-2">有什么可以帮您的吗？</p>
          </div>
        </div>
      </div>
      <div class="assistant-chat-suggestions">
        <button class="suggestion-chip">分析我的支出</button>
        <button class="suggestion-chip">查看账单提醒</button>
        <button class="suggestion-chip">理财建议</button>
      </div>
      <div class="assistant-chat-input">
        <input type="text" id="assistant-input" placeholder="输入您的问题...">
        <button class="voice-button"><i class="fas fa-microphone"></i></button>
        <button class="send-button"><i class="fas fa-paper-plane"></i></button>
      </div>
    `;
    
    document.body.appendChild(chatContainer);
    
    // 添加样式
    if (!document.getElementById('assistant-styles')) {
      const style = document.createElement('style');
      style.id = 'assistant-styles';
      style.textContent = `
        .assistant-floating-button {
          position: fixed;
          bottom: 80px;
          right: 20px;
          width: 60px;
          height: 60px;
          border-radius: 50%;
          background: linear-gradient(135deg, #5c6bc0, #3949ab);
          color: white;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
          z-index: 1000;
          cursor: pointer;
          transition: transform 0.3s, box-shadow 0.3s;
          border: 2px solid #fff;
        }
        
        .assistant-icon {
          width: 100%;
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .assistant-icon svg {
          width: 90%;
          height: 90%;
        }
        
        .assistant-floating-button:active {
          transform: scale(0.95);
        }
        
        .assistant-floating-button.pulse {
          animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
          0% {
            box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.7);
          }
          70% {
            box-shadow: 0 0 0 10px rgba(99, 102, 241, 0);
          }
          100% {
            box-shadow: 0 0 0 0 rgba(99, 102, 241, 0);
          }
        }
        
        .assistant-chat-container {
          position: fixed;
          bottom: 90px;
          right: 20px;
          width: 320px;
          height: 450px;
          background: white;
          border-radius: 15px;
          box-shadow: 0 5px 25px rgba(0, 0, 0, 0.15);
          display: flex;
          flex-direction: column;
          overflow: hidden;
          z-index: 999;
        }
        
        .assistant-chat-header {
          padding: 15px;
          background: linear-gradient(to right, #5c6bc0, #3949ab);
          color: white;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        
        .assistant-chat-title {
          display: flex;
          align-items: center;
        }
        
        .assistant-chat-title .title {
          font-weight: 600;
          margin-left: 10px;
        }
        
        .assistant-chat-title .status {
          font-size: 12px;
          opacity: 0.8;
          margin-left: 10px;
        }
        
        .assistant-chat-actions button {
          background: none;
          border: none;
          color: white;
          margin-left: 15px;
          cursor: pointer;
          opacity: 0.8;
          transition: opacity 0.2s;
        }
        
        .assistant-chat-actions button:hover {
          opacity: 1;
        }
        
        .assistant-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          background: linear-gradient(135deg, #5c6bc0, #3949ab);
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 20px;
          flex-shrink: 0;
          overflow: hidden;
        }
        
        .assistant-avatar.small {
          width: 32px;
          height: 32px;
          font-size: 16px;
        }
        
        .assistant-chat-messages {
          flex: 1;
          overflow-y: auto;
          padding: 15px;
          background-color: #f9fafb;
        }
        
        .message {
          display: flex;
          margin-bottom: 15px;
          max-width: 85%;
        }
        
        .message.assistant {
          align-self: flex-start;
        }
        
        .message.user {
          flex-direction: row-reverse;
          margin-left: auto;
        }
        
        .message-content {
          background: white;
          border-radius: 15px;
          padding: 10px 12px;
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
          margin: 0 10px;
          font-size: 14px;
        }
        
        .message.user .message-content {
          background: #4f46e5;
          color: white;
        }
        
        .assistant-chat-suggestions {
          padding: 10px 15px;
          display: flex;
          flex-wrap: nowrap;
          overflow-x: auto;
          background-color: white;
          border-top: 1px solid #f0f0f0;
          scrollbar-width: none;
        }
        
        .assistant-chat-suggestions::-webkit-scrollbar {
          display: none;
        }
        
        .suggestion-chip {
          flex-shrink: 0;
          margin-right: 8px;
          padding: 6px 12px;
          background-color: #f3f4f6;
          border-radius: 15px;
          font-size: 13px;
          border: none;
          cursor: pointer;
          white-space: nowrap;
        }
        
        .suggestion-chip:hover {
          background-color: #e5e7eb;
        }
        
        .assistant-chat-input {
          padding: 12px 15px;
          display: flex;
          align-items: center;
          background-color: white;
          border-top: 1px solid #f0f0f0;
        }
        
        .assistant-chat-input input {
          flex: 1;
          border: 1px solid #e5e7eb;
          border-radius: 20px;
          padding: 8px 15px;
          font-size: 14px;
          outline: none;
        }
        
        .assistant-chat-input input:focus {
          border-color: #4f46e5;
        }
        
        .assistant-chat-input button {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          border: none;
          margin-left: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
        }
        
        .voice-button {
          background-color: #f3f4f6;
          color: #4b5563;
          transition: background-color 0.3s;
        }
        
        .voice-button.listening {
          animation: pulse-red 1.5s infinite;
          background-color: #ef4444;
          color: white;
        }
        
        @keyframes pulse-red {
          0% {
            box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.6);
          }
          70% {
            box-shadow: 0 0 0 10px rgba(239, 68, 68, 0);
          }
          100% {
            box-shadow: 0 0 0 0 rgba(239, 68, 68, 0);
          }
        }
        
        .send-button {
          background-color: #4f46e5;
          color: white;
        }
        
        .send-button:disabled {
          background-color: #c7d2fe;
          cursor: not-allowed;
        }
        
        .typing-indicator {
          display: flex;
          align-items: center;
          padding: 10px 15px;
        }
        
        .typing-indicator span {
          height: 8px;
          width: 8px;
          float: left;
          margin: 0 1px;
          background-color: #9ca3af;
          display: block;
          border-radius: 50%;
          opacity: 0.4;
        }
        
        .typing-indicator span:nth-of-type(1) {
          animation: typing 1s infinite 0.2s;
        }
        .typing-indicator span:nth-of-type(2) {
          animation: typing 1s infinite 0.4s;
        }
        .typing-indicator span:nth-of-type(3) {
          animation: typing 1s infinite 0.6s;
        }
        
        @keyframes typing {
          0% { opacity: 0.4; transform: translateY(0); }
          50% { opacity: 0.8; transform: translateY(-5px); }
          100% { opacity: 0.4; transform: translateY(0); }
        }
      `;
      document.head.appendChild(style);
    }
    
    // 添加事件监听
    floatingButton.addEventListener('click', () => this.toggleChat());
    
    const minimizeButton = document.querySelector('.minimize-button');
    const closeButton = document.querySelector('.close-button');
    const sendButton = document.querySelector('.send-button');
    const voiceButton = document.querySelector('.voice-button');
    const inputField = document.getElementById('assistant-input');
    const suggestionChips = document.querySelectorAll('.suggestion-chip');
    
    minimizeButton.addEventListener('click', () => this.toggleChat());
    closeButton.addEventListener('click', () => this.closeChat());
    
    sendButton.addEventListener('click', () => this.sendMessage());
    inputField.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') this.sendMessage();
    });
    
    voiceButton.addEventListener('click', () => this.toggleVoiceInput());
    
    suggestionChips.forEach(chip => {
      chip.addEventListener('click', () => {
        inputField.value = chip.textContent.trim();
        this.sendMessage();
      });
    });
    
    this.initialized = true;
  }
  
  toggleChat() {
    const chatContainer = document.querySelector('.assistant-chat-container');
    const floatingButton = document.querySelector('.assistant-floating-button');
    
    this.isOpen = !this.isOpen;
    
    if (this.isOpen) {
      chatContainer.style.display = 'flex';
      floatingButton.style.display = 'none';
      
      // 滚动到最新消息
      this.scrollToBottom();
      
      // 聚焦输入框
      setTimeout(() => {
        document.getElementById('assistant-input').focus();
      }, 300);
    } else {
      chatContainer.style.display = 'none';
      floatingButton.style.display = 'flex';
      
      // 停止语音识别
      if (this.isListening) {
        this.stopListening();
      }
    }
  }
  
  closeChat() {
    this.isOpen = false;
    document.querySelector('.assistant-chat-container').style.display = 'none';
    document.querySelector('.assistant-floating-button').style.display = 'flex';
    
    // 停止语音识别
    if (this.isListening) {
      this.stopListening();
    }
  }
  
  sendMessage() {
    const input = document.getElementById('assistant-input');
    const message = input.value.trim();
    
    if (!message) return;
    
    const messagesContainer = document.querySelector('.assistant-chat-messages');
    
    // 添加用户消息
    const userMessageElement = document.createElement('div');
    userMessageElement.className = 'message user';
    userMessageElement.innerHTML = `
      <div class="message-content">${message}</div>
    `;
    messagesContainer.appendChild(userMessageElement);
    
    // 清空输入框
    input.value = '';
    
    // 滚动到底部
    this.scrollToBottom();
    
    // 显示"正在输入"指示器
    const typingIndicator = document.createElement('div');
    typingIndicator.className = 'message assistant typing-indicator';
    typingIndicator.innerHTML = `
      <div class="assistant-avatar">
        <div class="assistant-icon">
          <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M18 3.5C9.44 3.5 2.5 10.44 2.5 19C2.5 27.56 9.44 34.5 18 34.5C26.56 34.5 33.5 27.56 33.5 19C33.5 10.44 26.56 3.5 18 3.5Z" fill="#FFF5E0" stroke="#FFFFFF"/>
            <path d="M24.5 13.5C24.5 16.26 22.26 18.5 19.5 18.5C16.74 18.5 14.5 16.26 14.5 13.5C14.5 10.74 16.74 8.5 19.5 8.5C22.26 8.5 24.5 10.74 24.5 13.5Z" fill="#FFCC80"/>
            <path d="M12.5 13C12.5 14.66 11.16 16 9.5 16C7.84 16 6.5 14.66 6.5 13C6.5 11.34 7.84 10 9.5 10C11.16 10 12.5 11.34 12.5 13Z" fill="#FFCC80"/>
            <path d="M8 21.25C8 19.18 9.68 17.5 11.75 17.5H24.25C26.32 17.5 28 19.18 28 21.25V23C28 26.31 25.31 29 22 29H14C10.69 29 8 26.31 8 23V21.25Z" fill="#FFCC80"/>
            <circle cx="10.5" cy="13" r="1.5" fill="#795548"/>
            <circle cx="19.5" cy="13" r="1.5" fill="#795548"/>
            <path d="M14 22C14.5 23 16 24 18 24C20 24 21.5 23 22 22" stroke="#795548" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </div>
      </div>
      <div class="message-content">
        <span></span>
        <span></span>
        <span></span>
      </div>
    `;
    messagesContainer.appendChild(typingIndicator);
    this.scrollToBottom();
    
    // 模拟延迟生成回复
    setTimeout(() => {
      // 移除"正在输入"指示器
      messagesContainer.removeChild(typingIndicator);
      
      // 添加助手回复
      const assistantMessageElement = document.createElement('div');
      assistantMessageElement.className = 'message assistant';
      
      // 根据用户问题模拟智能回复
      let response = '';
      if (message.includes('支出') || message.includes('花费') || message.includes('消费')) {
        response = `
          <p>根据您近期的消费记录，餐饮支出占比最高，约占总支出的36%。</p>
          <p>与上月相比，您的娱乐支出增加了15%，可能需要注意控制。</p>
        `;
      } else if (message.includes('预算') || message.includes('超支')) {
        response = `
          <p>您本月已使用预算的71%，目前状况良好。</p>
          <p>不过餐饮类别已使用了86%的预算，建议接下来两周控制相关支出。</p>
        `;
      } else if (message.includes('账单') || message.includes('提醒')) {
        response = `
          <p>您有2个即将到期的账单：</p>
          <p>- 信用卡还款：4月6日，¥4,235</p>
          <p>- 房租：4月20日，¥2,800</p>
        `;
      } else if (message.includes('理财') || message.includes('投资')) {
        response = `
          <p>基于您的风险偏好和当前财务状况，建议：</p>
          <p>1. 完善您的应急基金，达到3-6个月支出</p>
          <p>2. 考虑配置一些低风险的货币基金或国债</p>
          <p>3. 如有长期理财需求，可适当考虑指数基金</p>
        `;
      } else {
        response = `
          <p>感谢您的提问！我需要更多信息来帮助您。</p>
          <p>您可以询问我关于支出分析、预算管理、账单提醒或理财建议等方面的问题。</p>
        `;
      }
      
      assistantMessageElement.innerHTML = `
        <div class="assistant-avatar">
          <div class="assistant-icon">
            <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M18 3.5C9.44 3.5 2.5 10.44 2.5 19C2.5 27.56 9.44 34.5 18 34.5C26.56 34.5 33.5 27.56 33.5 19C33.5 10.44 26.56 3.5 18 3.5Z" fill="#FFF5E0" stroke="#FFFFFF"/>
              <path d="M24.5 13.5C24.5 16.26 22.26 18.5 19.5 18.5C16.74 18.5 14.5 16.26 14.5 13.5C14.5 10.74 16.74 8.5 19.5 8.5C22.26 8.5 24.5 10.74 24.5 13.5Z" fill="#FFCC80"/>
              <path d="M12.5 13C12.5 14.66 11.16 16 9.5 16C7.84 16 6.5 14.66 6.5 13C6.5 11.34 7.84 10 9.5 10C11.16 10 12.5 11.34 12.5 13Z" fill="#FFCC80"/>
              <path d="M8 21.25C8 19.18 9.68 17.5 11.75 17.5H24.25C26.32 17.5 28 19.18 28 21.25V23C28 26.31 25.31 29 22 29H14C10.69 29 8 26.31 8 23V21.25Z" fill="#FFCC80"/>
              <circle cx="10.5" cy="13" r="1.5" fill="#795548"/>
              <circle cx="19.5" cy="13" r="1.5" fill="#795548"/>
              <path d="M14 22C14.5 23 16 24 18 24C20 24 21.5 23 22 22" stroke="#795548" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
          </div>
        </div>
        <div class="message-content">
          ${response}
        </div>
      `;
      messagesContainer.appendChild(assistantMessageElement);
      
      // 滚动到底部
      this.scrollToBottom();
      
      // 更新建议问题
      this.updateSuggestions(message);
    }, 1500);
  }
  
  updateSuggestions(lastMessage) {
    // 根据上下文更新建议问题
    const suggestionsContainer = document.querySelector('.assistant-chat-suggestions');
    suggestionsContainer.innerHTML = '';
    
    let suggestions = [];
    
    if (lastMessage.includes('支出') || lastMessage.includes('花费') || lastMessage.includes('消费')) {
      suggestions = [
        '我可以在哪里节省开支？',
        '设置餐饮预算提醒',
        '比较我与家人的支出'
      ];
    } else if (lastMessage.includes('预算') || lastMessage.includes('超支')) {
      suggestions = [
        '调整我的预算分配',
        '查看历史预算执行情况',
        '如何避免超支？'
      ];
    } else if (lastMessage.includes('账单') || lastMessage.includes('提醒')) {
      suggestions = [
        '设置新账单提醒',
        '查看本月所有账单',
        '自动付款设置'
      ];
    } else if (lastMessage.includes('理财') || lastMessage.includes('投资')) {
      suggestions = [
        '低风险投资选择',
        '如何开始定投?',
        '适合我的理财产品'
      ];
    } else {
      suggestions = [
        '分析我的月度支出',
        '查看账单提醒',
        '如何合理规划预算?'
      ];
    }
    
    suggestions.forEach(text => {
      const chip = document.createElement('button');
      chip.className = 'suggestion-chip';
      chip.textContent = text;
      chip.addEventListener('click', () => {
        document.getElementById('assistant-input').value = text;
        this.sendMessage();
      });
      suggestionsContainer.appendChild(chip);
    });
  }
  
  toggleVoiceInput() {
    if (!this.recognition) {
      alert('很抱歉，您的浏览器不支持语音识别功能');
      return;
    }
    
    const voiceButton = document.querySelector('.voice-button');
    
    if (this.isListening) {
      this.stopListening();
    } else {
      this.isListening = true;
      voiceButton.classList.add('listening');
      voiceButton.innerHTML = '<i class="fas fa-microphone-slash"></i>';
      
      try {
        this.recognition.start();
      } catch (e) {
        console.error('语音识别启动失败:', e);
      }
    }
  }
  
  stopListening() {
    if (!this.isListening) return;
    
    this.isListening = false;
    const voiceButton = document.querySelector('.voice-button');
    voiceButton.classList.remove('listening');
    voiceButton.innerHTML = '<i class="fas fa-microphone"></i>';
    
    try {
      this.recognition.stop();
    } catch (e) {
      console.error('语音识别停止失败:', e);
    }
  }
  
  scrollToBottom() {
    const messagesContainer = document.querySelector('.assistant-chat-messages');
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
  
  pulse() {
    const button = document.querySelector('.assistant-floating-button');
    button.classList.add('pulse');
    setTimeout(() => {
      button.classList.remove('pulse');
    }, 6000);
  }
}

// 创建全局实例
window.smartAssistant = new SmartAssistant();

// 在页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
  // 初始化智能助手
  window.smartAssistant.init();
  
  // 3秒后让按钮闪烁，提示用户
  setTimeout(() => {
    window.smartAssistant.pulse();
  }, 3000);
});
