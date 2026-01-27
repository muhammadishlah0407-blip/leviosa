// Debug configuration for Flutter web
window.addEventListener('load', function() {
  // Disable Chrome DevTools Protocol errors
  if (window.chrome && window.chrome.webstore) {
    // Chrome-specific fixes
    console.log('Chrome detected, applying debug fixes');
  }
  
  // Handle Flutter web initialization
  if (typeof _flutter !== 'undefined') {
    console.log('Flutter web loader detected');
  }
});

// Override console.error to filter out ChromeProxyService errors
const originalConsoleError = console.error;
console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('ChromeProxyService') || 
      message.includes('InvalidInputError') ||
      message.includes('Failed to evaluate expression')) {
    // Filter out these specific errors
    return;
  }
  originalConsoleError.apply(console, args);
};

// Handle unhandled promise rejections
window.addEventListener('unhandledrejection', function(event) {
  if (event.reason && event.reason.message && 
      (event.reason.message.includes('ChromeProxyService') ||
       event.reason.message.includes('InvalidInputError'))) {
    event.preventDefault();
    return;
  }
}); 