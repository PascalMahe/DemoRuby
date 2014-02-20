jQuery(document).ready(function(){
    var nbSliderItem = jQuery('.view-display-id-slider .item-list li.views-row').length,
        itemsPerPage = 3,
        nbSliderPages = Math.ceil(nbSliderItem / itemsPerPage),
        sliderItemWidth = jQuery('.view-display-id-slider .item-list li.views-row').outerWidth(true),
        sliderWidth = sliderItemWidth * nbSliderItem,
        sliderPageWidth = sliderItemWidth * itemsPerPage;

    //création du pager
    jQuery('.view-display-id-slider').append('<div class="pager"></div>')

    jQuery('.view-display-id-slider').insertAfter('<div class="pager"></div>');
    for (var i = 0; i < nbSliderPages; i++) {
        if (i == 0) {
            jQuery('.pager').append('<span class="selected" data-pos="' + i + '"></span>');
        } else {
            jQuery('.pager').append('<span data-pos="' + i + '"></span>');
        }
    }

    //gestionnaire de click pour gérer le positionnement latéral du slider
    jQuery('.pager span').click(function (event) {
        var currentPagePositionInPixels = jQuery(event.currentTarget).data('pos') * sliderPageWidth;
        jQuery('.view-display-id-slider .item-list').animate({
            'margin-left': -currentPagePositionInPixels
        }, 1000, 'swing');
        jQuery('.pager span').removeClass('selected');
        jQuery(event.currentTarget).addClass('selected');
    });

    var pagerItemWidth = jQuery('.pager span').outerWidth(true);

    //Définitions des largeur du slider et du pager
    jQuery('.view-display-id-slider .item-list').css('width', sliderWidth);
    jQuery('.pager').css('width', pagerItemWidth * nbSliderPages);
  })