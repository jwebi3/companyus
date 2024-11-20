(function( $ ) {
	'use strict';

	$(document).ready(function() {
		jQuery(document).ready(function($) {
            $('.cacwp_text').on('click', function() {
                // Get the text to copy
                let text = '';
                let $element = $(this);
                function myFunction() {
                  let dataContent = $element.attr('data-content');
                  if (dataContent != '') {
                    text = dataContent;
                  } else {
                    text = $element.attr('data-text');
                  }
                }
                myFunction();
                
                // Create a temporary element to copy the text
                let $tempElement = $('<textarea>');
                $tempElement.val(text);
                $tempElement.attr('readonly', '');
                $tempElement.css({
                    position: 'absolute',
                    left: '-9999px'
                });

                $('body').append($tempElement);

                // Select the text in the temporary element
                let selected = document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;
                $tempElement.select();

                // Copy the text to the clipboard
                document.execCommand('copy');

                // Remove the temporary element
                $tempElement.remove();

                // Apply the provided CSS styles to the existing element
                let $copiedMessage = $('<div class="catcwp-after-copy-text">Copied to Clipboard!</div>');
                $copiedMessage.css({
                    'top': '36px',
                    'z-index': '9999',
                    'position': 'fixed',
                    'width': '250px',
                    'left': '50%',
                    'transform': 'translateX(-50%)',
                    'font-size': '14px',
                    'font-weight': '400',
                    'text-transform': 'capitalize',
                    'text-align': 'center',
                    'padding': '13px 15px',
                    'line-height': '15px',
                    'color': '#5db62e',
                    'border-radius': '4px',
                    'background': '#eaf8e1',
                    'border': '1px solid #a2de83'
                });

                $(this).append($copiedMessage);
                // Hide the "Copied" message after 2 seconds
                setTimeout(function () {
                    $copiedMessage.remove();
                }, 2000);
            });
        });
		  
	  });
	  

})( jQuery );
