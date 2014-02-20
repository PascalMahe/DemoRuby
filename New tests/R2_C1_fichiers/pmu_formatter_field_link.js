
(function($){
$(document).ready(function(){

$('a[class="window-open-popup"]').click(function() {
   var popupWidth = $(this).attr('data-popup-width');
   var popupHeight = $(this).attr('data-popup-height');
   var popupLeft = (screen.width / 2) - (popupWidth / 2);
   var popupTop = (screen.height / 2) - (popupHeight / 2);

   window.open($(this).attr('href'), 'pmu_popup_window', 'top=' + popupTop + ', left=' + popupLeft + ', width=' + popupWidth + ', height=' + popupHeight + ', resizable=no, location=no, directories=no, menubar=no, status=no, scrollbars=no, menubar=no, location=no');
   return false;
});

});
})(jQuery);
