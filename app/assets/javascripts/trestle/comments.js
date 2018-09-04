$(Trestle).on("init",function() {
  // $(".thread").show();
  // var simplemde = new SimpleMDE({ element: document.getElementById("comment_body") });
  var md = new SimpleMDE(
    { 
        element: document.getElementById("comment_body"),
        autoSuggest: 
        {
            mode: 'markdown',
            startChars: ['@', '#'],
            listCallback: function(stringToTest)
            {
                return [
                        {
                            text: '@Thomas ',
                            displayText: '@Thomas'
                        },
                        {
                            text: '@Maria ',
                            displayText: '@Maria'
                        },
                        {
                            text: '@Peter ',
                            displayText: '@Peter'
                        }
                    ];
            }
        }
    });
  });