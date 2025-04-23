// Main JavaScript file for the Life Management App

document.addEventListener('DOMContentLoaded', function() {
  // Initialize current date and time for the status bar
  updateStatusBarTime();
  setInterval(updateStatusBarTime, 60000); // Update time every minute
  
  // Add any click event listeners for interactive elements
  setupEventListeners();
});

// Update the status bar time
function updateStatusBarTime() {
  const timeElements = document.querySelectorAll('.status-bar-time');
  if (timeElements.length) {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const timeString = `${hours}:${minutes}`;
    
    timeElements.forEach(el => {
      el.textContent = timeString;
    });
  }
}

// Setup event listeners for interactive elements
function setupEventListeners() {
  // Handle tab navigation if we're in an iframe context
  const tabItems = document.querySelectorAll('.tab-item');
  tabItems.forEach(tab => {
    tab.addEventListener('click', function(e) {
      if (window.parent !== window) {
        // We're in an iframe, so we need to ensure the link works properly
        e.preventDefault();
        const href = this.getAttribute('href');
        if (href) {
          const iframe = window.parent.document.querySelector(`iframe[src='${window.location.pathname}']`);
          if (iframe) {
            const basePath = window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1);
            iframe.setAttribute('src', basePath + href);
          }
        }
      }
    });
  });
  
  // Setup expense tracking category selection
  const categoryIcons = document.querySelectorAll('.expense-category');
  categoryIcons.forEach(icon => {
    icon.addEventListener('click', function() {
      // Remove active class from all icons
      document.querySelectorAll('.expense-category').forEach(i => {
        if (i.querySelector('div')) {
          i.querySelector('div').classList.remove('border-2', 'border-orange-500');
        }
        if (i.querySelector('span')) {
          i.querySelector('span').classList.remove('font-medium', 'text-orange-600');
          i.querySelector('span').classList.add('text-gray-600');
        }
      });
      
      // Add active class to clicked icon
      if (this.querySelector('div')) {
        this.querySelector('div').classList.add('border-2', 'border-orange-500');
      }
      if (this.querySelector('span')) {
        this.querySelector('span').classList.add('font-medium', 'text-orange-600');
        this.querySelector('span').classList.remove('text-gray-600');
      }
    });
  });
  
  // Handle meal and exercise plan day selection
  const dayButtons = document.querySelectorAll('.day-selector button');
  dayButtons.forEach(button => {
    button.addEventListener('click', function() {
      document.querySelectorAll('.day-selector button').forEach(btn => {
        btn.classList.remove('bg-indigo-600', 'bg-green-600', 'text-white');
        btn.classList.add('bg-gray-100', 'text-gray-700');
      });
      
      this.classList.remove('bg-gray-100', 'text-gray-700');
      this.classList.add('bg-indigo-600', 'text-white');
    });
  });
}
