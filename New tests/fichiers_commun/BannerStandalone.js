
define('src/common/bandeau_message/BandeauMessageOffView',['src/common/bandeau_message/BandeauMessageView'], function (BandeauMessageView) {
    
    return Backbone.View.extend({

        initialize: function () {
            this.listenTo(Backbone, 'menu:error', this.renderError);
            this.listenTo(Backbone, 'menu:warning', this.renderWarning);
        },

        renderError: function (message) {
            new BandeauMessageView({
                model: new Backbone.Model({content: message}),
                $target: $('#bloc-erreur'),
                inline: true
            }).error();
        },

        renderWarning: function (message) {
            new BandeauMessageView({
                model: new Backbone.Model({content: message, notclosable: true}),
                $target: $('#bloc-erreur'),
                inline: true
            }).warning();
        }
    });
});
define('BannerStandalone',['require','core','src/common/bandeau_message/BandeauMessageOffView'],function (require) {
    

    require('core');
    var BandeauMessageOffView = require('src/common/bandeau_message/BandeauMessageOffView'),
        bandeauMessageOffView;

    bandeauMessageOffView = new BandeauMessageOffView();
});