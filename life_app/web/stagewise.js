// Initialize stagewise toolbar in development mode
(function() {
  if (process.env.NODE_ENV === 'development') {
    const stagewiseConfig = {
      plugins: []
    };

    // Import and initialize stagewise toolbar
    import('@stagewise/toolbar').then(({ initToolbar }) => {
      initToolbar(stagewiseConfig);
    }).catch(console.error);
  }
})(); 