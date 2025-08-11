$(document).ready(function() {
  // Remove fancybox wrapper from images with data-no-fancybox
  $('img[no-fancybox]').each(function() {
    if ($(this).parent().hasClass('fancybox')) {
      $(this).unwrap();
    }
  });
}); 