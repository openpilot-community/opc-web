$(Trestle).on("init",function() {
  hljs.configure({
    classPrefix: 'language-'
  })
  
  $('pre code').each(function(i, block) {
    hljs.highlightBlock(block);
  });
});