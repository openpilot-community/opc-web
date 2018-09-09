$(Trestle).on("init",function() {
    var md = new SimpleMDE(
      { 
        element: document.getElementById("comment_body"),
        status: false,
        autoSuggest: 
        {
            mode: 'markdown',
            startChars: ['@', '#'],
            listCallback: function(stringToTest)
            {
                return [
                        
                    ];
            }
        }
   });
  // $(".thread").show();
  // var simplemde = new SimpleMDE({ element: document.getElementById("comment_body") });
  // var md = new SimpleMDE(
  //   { 
  //       element: document.getElementById("comment_body"),
  //       autoSuggest: 
  //       {
  //           mode: 'markdown',
  //           startChars: ['@', '#'],
  //           listCallback: function(stringToTest)
  //           {
  //               return [
  //                       {
  //                           text: '@Thomas ',
  //                           displayText: '@Thomas'
  //                       },
  //                       {
  //                           text: '@Maria ',
  //                           displayText: '@Maria'
  //                       },
  //                       {
  //                           text: '@Peter ',
  //                           displayText: '@Peter'
  //                       }
  //                   ];
  //           }
  //       }
  //   });
  });