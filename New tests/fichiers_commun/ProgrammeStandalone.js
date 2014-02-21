
define('text!src/programme/templates/programme.html',[],function () { return '<div id="left-panel" class="left-side unit">\n    <div id="programme-calendar-widget"></div>\n</div>\n<div id="timeline-wrapper" class="timeline-wrapper">\n    <span id="timeline-back" class="timeline-nav back"> </span>\n    <span id="timeline-forward" class="timeline-nav forward"> </span>\n\n    <div class="absolute-border top"></div>\n    <div class="absolute-border right"></div>\n    <div class="absolute-border bottom"></div>\n    <div class="absolute-border left"></div>\n</div>\n<div id="footer-programme"></div>\n';});

define('text!src/programme/templates/programme-footer.hbs',[],function () { return '<ul class="footer-legende">\n    {{#if hasProchaineCourseProgramme}}\n    <li><span class="prochaine-course-programme">Prochaine course<br/> du programme</span></li>\n    {{/if}}\n    {{#if hasProchaineCourseReunion}}\n    <li><span class="prochaine-course-reunion">Prochaine course<br/> de la réunion</span></li>\n    {{/if}}\n    {{#if hasDepart3Minutes}}\n    <li><span class="trois-minutes">Départ <br/>dans 3 minutes</span></li>\n    {{/if}}\n    {{#if hasCourseEnCours}}\n    <li><span class="en-cours">Course <br/>en cours</span></li>\n    {{/if}}\n    {{#if hasReunionTerminee}}\n    <li><span class="terminee">Réunion <br/>terminée</span></li>\n    {{/if}}\n</ul>\n<div id="timeline-zoom" class="buttonGroup">\n    <a class="btn btn-selected" data-mode="big">Programme en détails</a>\n    <a class="btn unzoom" data-mode="small">Tout le programme</a>\n</div>\n';});

define('text!src/programme/templates/programme-loading.html',[],function () { return '<div class="programme-loading">\n</div>';});

define('src/programme/ProgrammeModel',['defaults', 'messages'], function (defaults, messages) {
    

    return Backbone.Model.extend({

        url: function () {
            return this.date ? defaults.PROGRAMME_DATE_URL.replace('{date}', this.date) : defaults.PROGRAMME_ACTIF_URL;
        },

        initialize: function (attributes, options) {
            this.date = options.date;
        },

        parse: function (res) {
            if (!res) {
                // Si content empty (status === 204)
                // vide les données à afficher
                this.clear();
                return res;
            }

            _.each(res.programme.reunions, function (reunion) {
                _.each(reunion.courses, function (course) {
                    course.disciplineStr = messages.get('COURSE.DISCIPLINE.' + course.discipline);
                    course.categorieStr = messages.get('COURSE.CATEGORIE.' + course.categorieParticularite);

                    if (reunion.audience === "NATIONAL" && reunion.offresInternet === false) {
                        course.paris = _.reject(course.paris, function (pari) { return pari.audience === "REGIONAL"; });
                    }
                });
            });
            return res;
        }

    });
});

define('text!src/programme/templates/programme-calendar.html',[],function () { return '<a id="calendar-previous" class="button previous"></a>\n<div id="calendar-widget" class="">\n    <div class="date">\n        <input type="text" id="calendar-input" value="" readonly="readonly" />\n        <div class="cal"></div>\n    </div>\n</div>\n<a id="calendar-next" class="button next"></a>\n\n<div id="calendar-today">\n    <div>Aujourd\'hui</div>\n</div>\n<div id="calendar-all-month" class="invisible">\n    <div>Tout le mois</div>\n</div>\n\n';});

define('src/programme/calendrier_reunions/FilterEnum',{
    Tous: 'Tous',
    Toutes: 'Toutes',
    completeMonth: 'completeMonth'
});

define('lib/pmu/jquery.ui.datepicker-fr',['jquery'], function ($) {
    

    /* French initialisation for the jQuery UI date picker plugin. */
    /* Written by Keith Wood (kbwood{at}iinet.com.au),
     Stéphane Nahmani (sholby@sholby.net),
     Stéphane Raimbault <stephane.raimbault@gmail.com> */

    $.datepicker.regional.fr = {
        closeText: 'Fermer',
        prevText: 'Précédent',
        nextText: 'Suivant',
        currentText: 'Aujourd\'hui',
        monthNames: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
            'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
        monthNamesShort: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
            'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
        dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
        dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
        dayNamesMin: ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
        weekHeader: 'Sem.',
        dateFormat: 'dd/mm/yy',
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ''
    };
    $.datepicker.setDefaults($.datepicker.regional.fr);

    return $;
});
define('src/programme/CalendarView',[
    'defaults',
    'text!./templates/programme-calendar.html',
    'src/programme/calendrier_reunions/FilterEnum',
    'timeManager',
    'conf',
    'lib/pmu/jquery.ui.datepicker-fr'
],
    /**
     * Peut prendre une date lors de l'instanciation de la vue (timestamp ou dd/mm/yyyy) pour initialiser la date
     * @param programmeCalendar
     * @return {*}
     */
        function (defaults, programmeCalendar, FilterEnum, timeManager, conf) {
        

        return Backbone.View.extend({

            id: 'calendar-view',

            events: {
                'click #calendar-previous': 'goToPreviousDay',
                'click #calendar-next': 'goToNextDay',
                'change #calendar-input': '_setCurrentDate',
                'click .date': 'showCalendar',
                'click #calendar-today': 'goToToday',
                'click #calendar-all-month': '_getFullMonth'
            },

            initialize: function () {
                this.debug('init CalendarView');

                this.boundaries = {};
                this.moment = this.options.moment || this._today();
                this.setBoundaries();
            },

            pickerOptions: {
                defaultDate: new Date()
            },

            setBoundaries: function () {
                var self = this;

                this.boundaries = {
                    min: timeManager.momentWithOffset(conf.CALENDAR_BORNE.dateMinProgrammes),
                    max: timeManager.momentWithOffset(conf.CALENDAR_BORNE.dateMaxProgrammes)
                };
                _.extend(this.pickerOptions, {
                    minDate: this.boundaries.min.toDate(),
                    maxDate: this.boundaries.max.toDate()
                });
                _.defer(function () {
                    self.dateInput.datepicker('option', self.pickerOptions);
                });
                this.trigger('boundaries:update', this.boundaries);
            },

            renderDate: function () {
                this.dateInput.datepicker($.datepicker.regional.fr);
                _.extend(this.pickerOptions, {
                    dayNamesMin: $.datepicker.regional.fr.dayNamesShort,
                    dateFormat: 'd M yy',
                    onSelect: _.bind(this.selectDate, this)
                });
                this.dateInput.datepicker('option', this.pickerOptions);
                this.dateInput.datepicker('setDate', this.moment.toDate());

                this.setDateInputIndex();
            },

            selectDate: function (date, inst) {
                this.moment = moment([inst.selectedYear, inst.selectedMonth, inst.selectedDay]);
                this._changeDate();
            },

            render: function () {
                this.$el.html(programmeCalendar);

                this.dateInput = this.$el.find('input');
                this.renderDate();
                this._showTodayButtonIfNeeded();
                return this;
            },

            /*
             * Fix Offline: calendrier passe en dessous du breadcrumb (Correction PCOF-36)
             */
            setDateInputIndex: function () {
                var zIndexBreadcrumb1 = $('#breadcrumb-1').zIndex();
                if (zIndexBreadcrumb1 > 1) {
                    this.dateInput.zIndex(zIndexBreadcrumb1);
                }
            },

            showCalendar: function () {
                this.dateInput.datepicker('show');
            },

            goToNextDay: function () {
                if (this.boundaries.max && this.boundaries.max.diff(this.moment, 'days') < 1) {
                    return;
                }
                this.moment.add('d', 1);
                this.dateInput.datepicker('setDate', this.moment.toDate());
                this._changeDate();
            },

            goToPreviousDay: function () {
                if (this.boundaries.min && this.boundaries.min.diff(this.moment, 'days') > -1) {
                    return;
                }
                this.moment.subtract('d', 1);
                this.dateInput.datepicker('setDate', this.moment.toDate());
                this._changeDate();
            },

            goToLastDay: function () {
                this.moment = this.boundaries.max;
                this.dateInput.datepicker('setDate', this.moment.toDate());
                this._changeDate();
            },

            goToToday: function () {
                this.moment = this._today();
                this.dateInput.datepicker('setDate', this.moment.toDate());
                this._changeDate();
            },

            _today: function () {
                return timeManager.momentWithOffset().hours(0).minutes(0).seconds(0).milliseconds(0);
            },

            _setCurrentDate: function () {
                this.moment = this._getMomentFromInput();
                this._changeDate();
            },

            _changeDate: _.debounce(function () {
                this._showTodayButtonIfNeeded();
                this.trigger('dateChanged', this.moment.format(timeManager.ft.DAY_MONTH_YEAR));
            }, 300),

            _getFullMonth: function () {
                this._showTodayButtonIfNeeded();
                this.trigger('dateChanged', FilterEnum.completeMonth);
            },

            _showTodayButtonIfNeeded: function () {
                if (this.moment.diff(this._today(), 'days') === 0) {
                    this.$('#calendar-today').hide();
                } else {
                    this.$('#calendar-today').show();
                }
            },

            _getMomentFromInput: function () {
                return timeManager.momentWithOffset(this.dateInput.datepicker('getDate'));
            },

            beforeClose: function () {
                this.dateInput.datepicker('destroy');
            }
        });
    });

define('text!src/course/templates/course.hbs',[],function () { return '<div class="course-evenement"></div>\n<div class="top">\n    <span class="num-externe">{{numExterne}}</span>\n    <span class="libelle"><span>{{formatLibelleHip libelleCourt}}</span></span>\n</div>\n\n{{#is categorieStatut \'EN_COURS\'}}\n    <span class="statut-course">Les chevaux sont partis !</span>\n{{else}}\n    {{#is categorieStatut \'SUSPENDU\'}}\n        <span class="statut-course">Les chevaux sont partis !</span>\n    {{else}}\n        {{#is categorieStatut \'ANNULEE\'}}\n            <span class="statut-course">Course annulée</span>\n        {{else}}\n            {{#is categorieStatut \'ARRIVEE\'}}\n                {{#if isArriveeProvisoire}}\n                    <span class="arrivee">\n                        <span class="libelle">Arrivée provisoire</span>\n                        <span>{{{arriveeFormattee}}}</span>\n                    </span>\n                {{else}}\n                    <span class="arrivee">\n                        <span class="libelle">Arrivée définitive</span>\n                        <span>{{{arriveeFormattee}}}</span>\n                    </span>\n                {{/if}}\n            {{else}}\n                {{#is categorieStatut \'A_PARTIR\'}}\n                    <span class="infos-course">\n                        {{formatMomentWithOffsetDate heureDepart timezoneOffset \'HH\\hmm\'}} {{getMessage discipline}} {{distance}}m<br/>{{nombreDeclaresPartants}} partants\n                    </span>\n                {{else}}\n                    {{#is categorieStatut \'INCONNU\'}}\n                        <span class="infos-course">\n                            {{formatMomentWithOffsetDate heureDepart timezoneOffset \'HH\\hmm\'}} {{getMessage discipline}} {{distance}}m<br/>{{nombreDeclaresPartants}} partants\n                        </span>\n                    {{/is}}\n                {{/is}}\n            {{/is}}\n        {{/is}}\n    {{/is}}\n{{/is}}';});

define('text!src/course/templates/course-popin-full.hbs',[],function () { return '<div>\n    <p>\n        <span class="prix">PRIX {{libelleCourt}}</span>\n        <br/>\n        <span class="starting-date">{{formatMomentWithOffsetDate heureDepart timezoneOffset \'HH\\hmm\'}}</span>\n        -\n        <!-- TODO: faire le traitement de chaine dans la view -->\n        <span>\n            {{#if disciplineStr}}\n                {{substr disciplineStr 0 7}}\n            {{else}}\n                ERR\n            {{/if}}\n            {{#if categorieParticularite}}\n                - {{categorieStr}}\n            {{/if}}\n        </span>\n        <br/>\n        <span class="price">{{montantTotalOffert}} €</span>\n        -\n        <span>{{distance}}m</span>\n        -\n        <span>{{nombreDeclaresPartants}} partants</span>\n    </p>\n    {{#unless isNoBetYet}}\n        <ul class="inline-list">\n            {{#each parisFamiliesUIData}}\n            <li>\n                <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"\n                   href="{{findUrl \'course\' ../momentWithOffsetUrl ../numReunion ../numOrdre}}"></a>\n            </li>\n            {{/each}}\n            <li>\n                <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'course\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n            </li>\n        </ul>\n    {{else}}\n        <ul class="inline-list">\n            {{#each parisFamiliesUIData}}\n            <li>\n                <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"\n                   href="{{findUrl \'pari\' ../momentWithOffsetUrl ../numReunion ../numOrdre family}}"></a>\n            </li>\n            {{/each}}\n            <li>\n                <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'pari-spot\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n            </li>\n        </ul>\n    {{/unless}}\n</div>\n';});

define('text!src/course/templates/course-popin-short.hbs',[],function () { return '{{#isSiteOnline}}\n<div>\n    <strong>\n        {{#if categorieParticularite}}{{categorieStr}} -{{/if}} {{montantTotalOffert}} €\n    </strong>\n\n    {{#unless isNoBetYet}}\n        <ul class="inline-list">\n                {{#each parisFamiliesUIData}}\n                <li>\n                    <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}" href="{{findUrl \'course\' ../momentWithOffsetUrl ../numReunion ../numOrdre}}"></a>\n                </li>\n                {{/each}}\n                <li>\n                    <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'course\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n                </li>\n        </ul>\n    {{else}}\n        <ul class="inline-list">\n            {{#each parisFamiliesUIData}}\n            <li>\n                <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"\n                   href="{{findUrl \'pari\' ../momentWithOffsetUrl ../numReunion ../numOrdre family}}"></a>\n            </li>\n            {{/each}}\n            <li>\n                <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'pari-spot\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n            </li>\n        </ul>\n    {{/unless}}\n</div>\n{{/isSiteOnline}}\n\n{{#isSiteOffline}}\n<a href="{{findUrl \'course\' ../momentWithOffsetUrl ../numReunion ../numOrdre}}">\n    <div>\n        <strong>\n            {{#if categorieParticularite}}{{categorieStr}} -{{/if}} {{montantTotalOffert}} €\n        </strong>\n\n        {{#unless isNoBetYet}}\n            <ul class="inline-list">\n                    {{#each parisFamiliesUIData}}\n                    <li>\n                        <span class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"></span>\n                    </li>\n                    {{/each}}\n                    <li>\n                        <span class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}"></span>\n                    </li>\n            </ul>\n        {{else}}\n            <ul class="inline-list">\n                {{#each parisFamiliesUIData}}\n                <li>\n                    <span class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"></span>\n                </li>\n                {{/each}}\n                <li>\n                    <span class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}"></span>\n                </li>\n            </ul>\n        {{/unless}}\n    </div>\n</a>\n{{/isSiteOffline}}\n';});

define('text!src/common/modal/templates/modal.hbs',[],function () { return '<div class="pointer"></div>\n<div class="inner">\n    {{#if title}}\n    <div class="title-bar">\n        <span class="title">{{{title}}}</span>\n        <div class="popin-close" id="popin-close">×</div>\n    </div>\n    {{/if}}\n    <div class="content">\n        {{#if contentClosable}}\n            <div class="popin-close" id="popin-close">×</div>\n        {{/if}}\n\n        {{#is type \'confirm\'}}\n            <p class="confirm-message">Êtes-vous sûr de vouloir continuer ?</p>\n            <div id="popin-confirm" class="confirm-button">Confirmer</div>\n            <div id="popin-cancel" class="cancel-button">Annuler</div>\n        {{/is}}\n\n        {{#is type \'dialog\'}}\n            <div id="popin-ok" class="confirm-button">Ok</div>\n        {{/is}}\n    </div>\n</div>\n';});

define('src/common/modal/ModalView',['backbone', 'template!./templates/modal.hbs' ], function (Backbone, template) {
    

    return Backbone.View.extend({
        events: {
            'click .confirm-button': 'accept',
            'click .popin-close': 'cancel',
            'click .cancel-button': 'cancel'
        },
        initialize: function () {
            var self;

            this.options = _.extend({
                content: null,
                offset: {x: 0, y: 0},
                cssClass: 'popin',
                position: 'bottom',
                layer: false,
                loading: false,
                width: 'auto',
                maxWidth: 'none',
                minWidth: 'none',
                fxIn: 'fadeIn',
                fxDurationIn: 0,
                fxOut: 'fadeOut',
                fxDurationOut: 0,
                onConfirm: $.noop,
                onCancel: $.noop,
                onShow: $.noop,
                onHide: $.noop,
                callbacksContext: undefined,
                closeOnConfirm: false,
                onConfirmArgs: [],
                autoShow: true,
                contentClosable: false
            }, this.options);

            if (this.options.content) {
                this._setContent(this.options.content);
            }

            self = this;
            if (this.options.autoShow) {
                // somehow, this wait until the view is attached to the dom, so the computed position is correct
                _.defer(function () {
                    self.show();
                    self._handleLayer();
                });
            }
        },
        accept: function () {
            this.options.onConfirm.apply(this.options.callbacksContext, this.options.onConfirmArgs || []);
            if (this.options.closeOnConfirm) {
                this.close();
            } else {
                this.loading();
            }
        },
        loading: function () {
            this.$el.remove();
            this._selector().find('.layer-popin').addClass('wait');
        },
        beforeClose: function () {
            this.trigger('close', this);
        },
        show: function () {
            this.stopHiding();

            var pos = this._position();
            this.$el.css({top: pos.top, left: pos.left}).stop(false, false)[this.options.fxIn](this.options.fxDurationIn, this.options.onShow);
        },
        hide: function () {
            var self = this;
            this.timeout = setTimeout(function () {
                self.$el.stop(false, false)[self.options.fxOut](self.options.fxDurationOut, self.options.onHide);
            }, 10);
        },
        stopHiding: function () {
            clearTimeout(this.timeout);
        },
        category: function () {
            return this.options.category;
        },
        cancel: function () {
            this.options.onCancel.apply(this.options.callbacksContext);
            this.close();
        },
        close: function () {
            var self = this;
            if (this.options.$target) {
                this._selector().off('.modal-tooltip');
                this.$el.off('.modal-tooltip');
            }

            this.$el.stop(false, false)[this.options.fxOut](this.options.fxDurationOut, function () {
                self._selector().find('.layer-popin').remove();
                Backbone.View.prototype.close.apply(self);
            });
        },
        _setContent: function (content) {
            var html = template({
                type: this.options.type,
                title: this.options.title,
                contentClosable: this.options.contentClosable
            });

            this._handleContent(html, content);
            this._handleType(content);
        },
        _handleContent: function (html, content) {
            var $html;

            this.subViews = [];
            if (content && content.el) {
                this.subViews.push(content);
                content = content.el;
            }

            $html = $(html);
            $html.find('.content').prepend(content);

            this.$el.hide().width(this.options.width)
                .html($html)
                .removeClass()
                .css('maxWidth', this.options.maxWidth)
                .css('minWidth', this.options.minWidth)
                .addClass(this.options.cssClass)
                .addClass(this.options.position);
        },
        _handleLayer: function () {
            if (this.options.layer) {
                this._selector().prepend('<div class="layer-popin"></div>');

                if (this.options.loading) {
                    this._selector().find('.layer-popin').addClass('wait');
                }
            }
        },
        _handleType: function (content) {
            switch (this.options.type) {
            case 'tooltip':
                this._selector()
                    .on('mouseenter.modal-tooltip', _.bind(this.show, this))
                    .on('mouseleave.modal-tooltip', _.bind(this.hide, this));

                this.$el
                    .on('mouseenter.modal-tooltip', _.bind(this.stopHiding, this))
                    .on('mouseleave.modal-tooltip', _.bind(this.hide, this));
                break;

            case 'pane':
                if (content.promise) {
                    var self = this,
                        $content = this.$('.content');

                    $content.addClass('wait');
                    content.promise().always(function () {
                        self.show();
                        $content.removeClass('wait');
                    });
                }
                break;
            }
        },
        _position: function () {
            var $target = this._selector(),
                pos = $target.offset(),
                verticalCenterPos = (this.$el.height() / 2) - ($target.outerHeight(true) / 2),
                horizontalCenterPos = (this.$el.width() / 2) - ($target.outerWidth(true) / 2),
                pointerWidth = this.$el.find('.pointer').width(),
                pointerHeight = this.$el.find('.pointer').height();

            switch (this.options.position) {
            case 'center':
                pos.top -= verticalCenterPos;
                pos.left -= horizontalCenterPos;
                break;
            case 'bottom':
                pos.top += $target.outerHeight(true) + pointerHeight;
                pos.left -= horizontalCenterPos;
                break;
            case 'top':
                pos.top -= this.$el.height() + pointerHeight;
                pos.left -= horizontalCenterPos;
                break;
            case 'left':
                pos.top -= verticalCenterPos;
                pos.left -= this.$el.width() + pointerWidth;
                break;
            case 'right':
                pos.top -= verticalCenterPos;
                pos.left += ($target.outerWidth(true)) + pointerWidth;
                break;
            }

            pos.top -= this._extractMargin($target, 'Top');
            pos.left -= this._extractMargin($target, 'Left');

            pos.top += this.options.offset.x;
            pos.left += this.options.offset.y;

            return pos;
        },
        // Margin fallback for ie7, http://stackoverflow.com/questions/10130771/css-margin-top-not-working-in-ie7
        _extractMargin: function (selector, direction) {
            var margin = selector.css('margin' + direction);
            return margin === 'auto' ? 0 : margin.replace('px', '');
        },
        _selector: function () {
            var selector;
            if (_.str.startsWith(this.options.category, 'pari')) {
                // handle when initial selector was executed out of dom — needed for pariPopin
                selector = $(this.options.$target.selector, this.options.$target.context);
            } else {
                // handle with the use of $('..').parent() and co.
                selector = this.options.$target;
            }
            return selector;
        }
    });
});

define('modalManager',['backbone', 'underscore', 'src/common/modal/ModalView'], function (Backbone, _, Modal) {
    

    var modalManager = {};
    _.extend(modalManager, Backbone.Events, {
        modals: [],
        modal: function (options) {
            var modal = new Modal(options);
            $('body').append(modal.el);

            this.closeCategory(modal.category());

            this.modals.push(modal);
            this.listenTo(modal, 'close', this._closeOne);

            return modal;
        },
        dialog: function (content, $target, successCallback, options) {
            return this.modal(_.extend({
                content: content,
                layer: true,
                position: 'center',
                $target: $target,
                onConfirm: successCallback,
                type: 'dialog'
            }, options));
        },
        confirm: function (content, $target, successCallback, options) {
            return this.modal(_.extend({
                content: content,
                layer: true,
                position: 'center',
                $target: $target,
                onConfirm: successCallback,
                type: 'confirm'
            }, options));
        },
        forbid: function (content, $target, forbidType, options) {
            forbidType = forbidType || 'warning';

            return this.modal(_.extend({
                content: content,
                position: 'center',
                cssClass: 'popin ' + forbidType,
                $target: $target,
                layer: true
            }, options));
        },
        tooltip: function (content, $target, options) {
            return this.modal(_.extend({
                content: content,
                $target: $target,
                autoShow: false,
                fxDurationIn: 100,
                fxDurationOut: 100,
                type: 'tooltip'
            }, options));
        },
        pane: function (content, $target, title, options) {
            return this.modal(_.extend({
                title: title,
                content: content,
                $target: $target,
                type: 'pane'
            }, options));
        },
        layer: function ($target, options) {
            return this.modal(_.extend({
                $target: $target,
                layer: true,
                loading: true
            }, options));
        },
        hasCategory: function (category) {
            return _.any(this.modals, function (modal) {
                return modal.category() === category;
            });
        },
        closeCategory: function (category) {
            if (_.isUndefined(category)) {
                return;
            }

            _.each(this.modals, function (modal) {
                if (modal.category() === category) {
                    modal.close();
                }
            });
            this._compact();
        },
        _closeAll: function () {
            _.invoke(this.modals, 'close');
            this._compact();
        },
        _closeOne: function (modal) {
            this._cleanup(modal);
            this._compact();
        },
        _cleanup: function (modal) {
            var index = _.indexOf(this.modals, modal);
            this.modals[index] = undefined;
        },
        _compact: function () {
            this.modals = _.without(this.modals, undefined);
        }
    });

    modalManager.listenTo(Backbone, 'course:change', modalManager._closeAll);
    modalManager.listenTo(Backbone.history, 'beforeroute', modalManager._closeAll);

    return modalManager;
});

define('src/programme/timeline/CourseView',[
    'template!../../course/templates/course.hbs',
    'template!../../course/templates/course-popin-full.hbs',
    'template!../../course/templates/course-popin-short.hbs',
    'utils',
    'formatter',
    'messages',
    'links',
    'timeManager',
    'modalManager'
], function (courseTmpl, coursePopinFullTmpl, coursePopinShortTmpl, utils, formatter, messages, links, timeManager, modalManager) {
    

    return Backbone.View.extend({

        tagName: 'a',
        className: 'course',

        render: function () {
            var dateCourse = this.model.get('heureDepart'),
                offsetCourse = this.model.get('timezoneOffset');

            this.$el.attr('data-numOrdre', this.model.get('numOrdre'));
            this._addHref();
            this.$el.addClass(this.model.get('categorieStatut'));

            if (this.model.get('departImminent')) {
                this.$el.addClass('depart-imminent');
            } else {
                this.$el.removeClass('depart-imminent');
            }

            this.$el.addClass(this.getCourseEvenement());
            this.$el.css('left', this._dateAsPixels(dateCourse, offsetCourse));
            this.$el.html(courseTmpl(this.jsonForTemplate()));

            if (this.model.get('categorieStatut') === 'A_PARTIR') {
                modalManager.tooltip(this._scaledTooltipTmpl()(this.prepareTooltipJson()), this.$el, {maxWidth: 242, cssClass: 'popin infocourse', offset: {x: -1, y: 0}});
            }

            return this;
        },

        prepareTooltipJson: function () {
            var courseJson = this.model.attributes,
                date = this.options.dateProgramme.format(timeManager.ft.DAY_MONTH_YEAR);

            return _.extend({}, courseJson, {
                parisFamiliesUIData: utils.serviceMapper.createUIFamiliesData(courseJson.paris),
                isAtLeastOneSpot: utils.somePariSpot(this.model.get('paris')),
                isNoBetYet: utils.somePariEnVente(this.model.get('paris')),
                momentWithOffsetUrl: date
            });
        },

        _addHref: function () {
            if (this.model.get('categorieStatut') === 'ANNULEE') {
                return;
            }

            var reunionId = this.model.get('numReunion'),
                date = this.options.dateProgramme.format(timeManager.ft.DAY_MONTH_YEAR);

            this.$el.attr('href', links.get('course', date, reunionId, this.model.get('numOrdre')));
        },

        jsonForTemplate: function () {
            var json = this.model.attributes;

            if (json.categorieStatut === 'ARRIVEE') {
                json.isArriveeProvisoire = _.contains(['ARRIVEE_PROVISOIRE', 'ARRIVEE_PROVISOIRE_NON_VALIDEE', 'ARRIVEE_PROVISOIRE_AVEC_PHOTO'], json.statut);
                json.arriveeFormattee = formatter.truncateAndFormatArrivee(json.ordreArrivee);
                if (json.arriveeFormattee === '') {
                    json.arriveeFormattee = messages.get('COURSE.ARRIVEE_INDISPONIBLE');
                }
            }

            return json;
        },

        getCourseEvenement: function () {
            var paris = this.model.get('paris'),
                parisEvenement = {QUINTE_PLUS: 'QUINTE_PLUS', PICK5: 'PICK5'},
                currentPariEvenement = '';

            _.each(paris, function (pari) {
                switch (pari.codePari) {
                case parisEvenement.QUINTE_PLUS:
                    currentPariEvenement = parisEvenement.QUINTE_PLUS;
                    break;
                case parisEvenement.PICK5:
                    currentPariEvenement = parisEvenement.PICK5;
                    break;
                }
            }, this);

            return currentPariEvenement;
        },

        _dateAsPixels: function (date, offset) {
            return timeManager.momentWithOffset(date, offset).diff(this.options.dateProgramme, 'minutes') * this.options.scale;
        },

        _scaledTooltipTmpl: function () {
            return this.options.scale > 1 ? coursePopinShortTmpl : coursePopinFullTmpl;
        }
    });
});

define('src/programme/timeline/TimelineLineView',[
    './CourseView'
], function (CourseView) {
    

    return Backbone.View.extend({

        className: 'course-line',

        render: function () {
            var courses = new Backbone.Collection(this.model.get('courses')),
                courseView;

            this.$el.css("height", this.options.height);

            courses.each(function (model) {
                courseView = new CourseView({
                    model: model,
                    scale: this.options.scale,
                    dateProgramme: this.options.dateProgramme
                });
                this.$el.append(courseView.render().el);

            }, this);

            return this;
        }

    });
});

define('text!src/programme/timeline/templates/timeline-header.html',[],function () { return '<div id="timeline-hours" class="timeline-hours"></div>\n<div id="timeline-handle" class="timeline-handle"></div>';});

define('src/programme/timeline/TimelineView',[
    './TimelineLineView',
    'text!./templates/timeline-header.html',
    'timeManager'
], function (TimelineLineView, timelineHeaderTmpl, timeManager) {
    

    var MINUTES_BY_HOUR = 60,
        HOURS_BY_DAY = 24,
        LABEL_BLOC_HEIGHT = 35, // Hauteur du bloc contenant les labels et boutons scroll
        SCROLL_DURATION = 1000, // Durée de l'animation lors d'un scroll
        FOCUS_MINUTES = 10, // Partie visible de la timeline où seul le curseur bouge en mn //TODO: change name
        SCROLL_JUMP_LENGTH = 60, // Longueur d'un saut dans le timeline (en mn).
        START_HOURS = 0,
        END_HOURS = 28,
        TIMELINE_LEFT_LIMIT = 30, // Nombre de minutes à retrancher pour la limite de la partie gauche de la timeline (scroll left)
        TIMELINE_RIGHT_LIMIT = 45, // Nombre de minutes à rajouter pour la limite de la partie droite de la timeline (scroll right)
        TIMELINE_WRAPPER_WIDTH = 628, // @see css .timeline-wrapper
        TIMELINE_PROPERTIES = { // Proprietes definies en fonction du mode de la timeline
            small: {
                scale: 1,
                hourScale: 1,
                reunionHeight: 39
            },
            big: {
                scale: 7,
                hourScale: 0.5,
                reunionHeight: 69
            }
        };

    return Backbone.View.extend({

        id: 'timeline-view',

        className: 'timeline timeline-big',

        currentTimelineMode: 'big',

        timelineLineViews: [],

        initialize: function () {
            this._initListeners();
        },

        _initListeners: function () {
            this.listenTo(Backbone, 'nextcourse:click', this.focusTimelineOnCourse); //see ReunionsInfosLineView
        },

        addDraggableComportement: function () {
            var self = this;

            this.$el.draggable({
                axis: 'x',
                start: function () {
                    self.$el.clearQueue(); // On vide la queue des scrolls
                    self.$el.stop(true); // On stoppe les précédentes animations
                },
                drag: function (event, ui) {
                    self.$el.data('ui-draggable').position.left = self.getAbscisseToScrollDependsOnLimits(ui.position.left);
                },
                stop: function (event, ui) {
                    self.trigger('refresh:arrows', ui.position.left);
                }
            });
        },

        render: function () {
            var reunions = this.collection,
                lastReunionId = 1,
                numOfficielReunion,
                reunionTimelineRendered,
                reunionView;

            this.closeTimelineLineViews(); // TODO réutiliser les mêmes TimelineLineView
            this.$el.html(timelineHeaderTmpl);

            reunions.each(function (model) {
                lastReunionId = lastReunionId + 1;
                numOfficielReunion = model.get('numOfficiel');

                //TODO: revoir ce passage de paramètres
                reunionView = new TimelineLineView({
                    model: model,
                    id: 'numOfficiel-' + numOfficielReunion,
                    height: TIMELINE_PROPERTIES[this.currentTimelineMode].reunionHeight,
                    scale: TIMELINE_PROPERTIES[this.currentTimelineMode].scale,
                    dateProgramme: this.dateProgramme
                });
                this.timelineLineViews.push(reunionView);

                reunionTimelineRendered = reunionView.render().el;
                this.$el.append(reunionTimelineRendered);
            }, this);

            this.modifyTimelineWidth();
            this.modifyTimelineHeight(reunions.length);
            this.adjustScrollLimits();
            this.addCursorElement();
            this.addLabelsAndMarks();
            this.applyURLScale();

            this.listenTo(timeManager, 'minute', this.tick);

            this.addDraggableComportement();

            return this;
        },

        _computeTimelineWidth: function (startHours, endHours, scale) {
            return (endHours - startHours) * MINUTES_BY_HOUR * scale;
        },

        //TODO: calculer la taille réelle en fonction de course min et course max
        modifyTimelineWidth: function () {
            var scale = TIMELINE_PROPERTIES[this.currentTimelineMode].scale,
                width = this._computeTimelineWidth(START_HOURS, END_HOURS, scale);

            this.$el.width(width);
        },

        modifyTimelineHeight: function (nbReunions) {
            var currentReunionHeight = TIMELINE_PROPERTIES[this.currentTimelineMode].reunionHeight;
            this.$el.height(
                nbReunions * (currentReunionHeight + 1)
            );
        },

        adjustScrollLimits: function () {
            var scale = TIMELINE_PROPERTIES[this.currentTimelineMode].scale,
                first = this.collection.getFirstCourse().heureDepart,
                last = this.collection.getLastCourse().heureDepart,
                offset = this.collection.getFirstCourse().timezoneOffset,
                diff;

            this.leftScrollLimit = -(timeManager.momentWithOffset(first, offset).diff(this.dateProgramme, 'minutes') - TIMELINE_LEFT_LIMIT) * scale;
            this.rightScrollLimit = -(timeManager.momentWithOffset(last, offset).diff(this.dateProgramme, 'minutes') + TIMELINE_RIGHT_LIMIT) * scale + TIMELINE_WRAPPER_WIDTH;

            if (-this.rightScrollLimit < -this.leftScrollLimit) { // Les courses ne s'étalent pas sur toute la timeline
                diff = this.rightScrollLimit - this.leftScrollLimit;
                this.leftScrollLimit += diff / 2;
                this.rightScrollLimit -= diff / 2;
            }
        },

        addCursorElement: function () {
            this.lastUpdate = timeManager.date();

            this.$cursor = $('<div class="cursor"></div>');
            this.$cursor.height(this.$el.height() + LABEL_BLOC_HEIGHT);
            this.$cursor.css('left', this._dateAsPixels(this.lastUpdate));

            if (moment(this.dateProgramme).format("MM-DD-YYYY") != timeManager.momentWithOffset().format("MM-DD-YYYY")) {
                this.$cursor.hide();
            }
            this.$el.append(this.$cursor);
        },

        setDate: function (date, offset) {
            this.dateProgramme = timeManager.momentWithOffset(date, offset);
            return this;
        },

        /**
         * Transforme la date en pixel pour le positionnement du curseur
         * @param date
         * @return {*}
         * @private
         */
        //TODO: factoriser avec le code présent dans course_view.js !!
        _dateAsPixels: function (date) {
            var hoursAsPixels = (date.getHours() - START_HOURS) * MINUTES_BY_HOUR * TIMELINE_PROPERTIES[this.currentTimelineMode].scale,
                minutesAsPixel = date.getMinutes() * TIMELINE_PROPERTIES[this.currentTimelineMode].scale;
            return hoursAsPixels + minutesAsPixel;
        },

        addLabelsAndMarks: function () {
            var hourScale = TIMELINE_PROPERTIES[this.currentTimelineMode].hourScale,
                range = END_HOURS - START_HOURS,
                i = 0;

            while (i < range + 1) {
                this.addMarkElement(i);
                this.addLabelElement(i);
                i += hourScale;
            }
        },

        addMarkElement: function (num) {
            var mark = $('<div class="mark"></div>');

            mark.height(this.$el.height())
                .css('left', num * MINUTES_BY_HOUR * TIMELINE_PROPERTIES[this.currentTimelineMode].scale);
            this.$el.append(mark);
        },

        addLabelElement: function (num) {
            var labelClassName = (num % 1 !== 0 ? 'half-hour' : ''),
                labelDOMelement = $('<div class="label ' + labelClassName + '">' + this.getLabelText(num) + '</div>');

            labelDOMelement.css('left', (num * MINUTES_BY_HOUR * TIMELINE_PROPERTIES[this.currentTimelineMode].scale) - labelDOMelement.width() / 2);//TODO: factoriser avec cursor etc.
            this.$el.append(labelDOMelement);
        },

        getLabelText: function (num) {
            var unites = Math.floor(num + START_HOURS) % HOURS_BY_DAY,
                decimales = num % 1;

            return unites + 'h' + (decimales ? MINUTES_BY_HOUR * decimales : '');
        },

        focusTimelineOnFirstCourseAPartirOrFirstCourse: function (animated) {
            var prochainesCourses = this.options.prochainesCourses,
                prochaineCourse,
                firstCourse;

            if (prochainesCourses && !_.isEmpty(prochainesCourses)) {
                prochaineCourse = prochainesCourses[0];
                this.focusTimelineOnCourse(prochaineCourse.numReunion, prochaineCourse.numCourse, animated);
            } else {
                firstCourse = this.collection.getFirstCourse();
                this.focusTimelineOnCourse(firstCourse.numReunion, firstCourse.numOrdre, animated);
            }
        },

        focusTimelineOnCourse: function (numOfficielReunion, numOrdreCourse, animated) {
            var $course = this.$('#numOfficiel-' + numOfficielReunion + ' a[data-numordre=' + numOrdreCourse + ']');
            if ($course && $course.position()) {
                this.scrollOnCourse($course, animated);
            } else {
                this.error('Impossible de positionner la timeline sur la course ' + numOrdreCourse + ' de la réunion ' + numOfficielReunion);
            }
        },

        scrollOnCourse: function ($element, animated) {
            var abscisseToScroll = this.getAbscissePositionWithMargin($element.position().left);
            this.scroll(abscisseToScroll, animated);
            this.trigger('refresh:arrows', abscisseToScroll);
        },

        /**
         * Calcule une abscisse en fonction de la marge de positionnement de la timeline et de son échelle
         * @param abscisse
         * @return Number abscisse voulue avec la marge de la timeline
         */
        getAbscissePositionWithMargin: function (abscisse) {
            return FOCUS_MINUTES * TIMELINE_PROPERTIES[this.currentTimelineMode].scale - abscisse;//absisse negatif (voir attribut css left)
        },

        scroll: function (abscisse, animated) {
            abscisse = this.getAbscisseToScrollDependsOnLimits(abscisse);

            // La timeline ne bouge pas quand l'utilisateur drag
            if (!this.$el.hasClass('ui-draggable-dragging')) {//TODO: Feature Inference! touver un autre moyen + externaliser ce code
                this.$el.stop(true); // On stoppe les précédentes animations
                this.$el.animate({
                    left: abscisse
                }, {
                    duration: animated ? SCROLL_DURATION : 0
                });
            }
        },

        /**
         * Permet de limiter le scroll en fonction de l'abscisse
         * @param abscisse
         * @return {*}
         */
        getAbscisseToScrollDependsOnLimits: function (abscisse) {
            if (abscisse > this.leftScrollLimit) { return this.leftScrollLimit; }
            if (abscisse < this.rightScrollLimit) { return this.rightScrollLimit; }
            return abscisse;
        },

        scrollLeft: function () {
            var abscisse = this.$el.position().left + TIMELINE_PROPERTIES[this.currentTimelineMode].scale * SCROLL_JUMP_LENGTH;
            this.scroll(abscisse, true);
            return abscisse;
        },

        scrollRight: function () {
            var abscisse = this.$el.position().left - TIMELINE_PROPERTIES[this.currentTimelineMode].scale * SCROLL_JUMP_LENGTH;
            this.scroll(abscisse, true);
            return abscisse;
        },

        switchTimelineMode: function (mode) {
            this.currentTimelineMode = mode;
            this.$el.removeClass('timeline-big')
                .removeClass('timeline-small')
                .addClass('timeline-' + mode);
            this.addScaleToURL(mode);
            this.render();
        },

        addScaleToURL: function (mode) {
            if (_.isUndefined(Backbone.history.fragment)) { return; }

            var currentUrlDate = Backbone.history.fragment.split('?')[0];
            Backbone.history.navigate(currentUrlDate + '?scale=' + mode, {trigger: false});
        },

        applyURLScale: function () {
            var fragment = Backbone.history.fragment,
                URLScale = _.str.strRight(fragment, 'scale=');
            if ((URLScale === 'big' || URLScale === 'small') && this.currentTimelineMode !== URLScale) {
                this.trigger('scale:change', URLScale);
            }
        },

        //TIMELINE

        /**
         * Déplace le cursor et la timeline au cours du temps
         */
        tick: function (model) {
            this.lastUpdate = model.date();
            this.$cursor.animate({
                'left': this._dateAsPixels(this.lastUpdate) + 'px'
            }, SCROLL_DURATION);

            if (this.currentTimelineMode === 'big') {
                this.autoScroll();
            }
        },

        autoScroll: function () {
            var scale = TIMELINE_PROPERTIES[this.currentTimelineMode].scale,
                timelineLeftPosition = this.$el.position().left,
                distance;

            if (this.$el.queue().length === 0) {//il n'y a pas d'évenement attaché à la timeline @see jquery queue()
                distance = this.$cursor.position().left + timelineLeftPosition;
                if (distance > scale * FOCUS_MINUTES) {
                    this.scroll(timelineLeftPosition - scale, true);
                    this.trigger('refresh:arrows', timelineLeftPosition - scale);
                }
            }
        },

        closeTimelineLineViews: function () {
            _.invoke(this.timelineLineViews, 'close');
            this.timelineLineViews = [];
        },

        beforeClose: function () {
            this.closeTimelineLineViews();
        }
    });
});

define('src/programme/ReunionsCollection',['timeManager'], function (timeManager) {
    

    return Backbone.Collection.extend({
        getFirstCourse: function () {
            return _.first(this.allCoursesSorted);
        },

        getLastCourse: function () {
            return _.last(this.allCoursesSorted);
        },

        initialize: function () {
            this.on('reset', this._sort);
        },

        _sort: function () {
            var allCourses = _.flatten(this.pluck('courses'));

            this.allCoursesSorted = _.sortBy(allCourses, function (course) {
                return course.heureDepart;
            });
        }
    });
});

define('text!src/programme/reunions_infos/templates/reunion.hbs',[],function () { return '<div class="reunion-line {{reunionIcone}}"\n     data-reunionid="{{reunion.numOfficiel}}">\n    <div class="top">\n        <div class="infos-reunion">\n            <span class="num-reunion">R{{reunion.numExterne}}</span>\n            <p class="hippodrome" data-reunionid="{{reunion.numOfficiel}}">\n                {{#if reunion.hippodrome}}\n                    {{#if reunion.hippodrome.libelleCourt}}\n                    <strong title="{{reunion.hippodrome.libelleLong}}">{{truncate reunion.hippodrome.libelleCourt 14}}\n                        {{#is reunion.statut \'ANNULEE\'}}\n                            <br/>Réunion annulée\n                        {{/is}}\n                    </strong>\n                    {{/if}}\n                {{/if}}\n                {{#if reunion.penetrometre}}\n                    {{#if reunion.penetrometre.intitule}}\n                        <span class="etat-terrain">Terrain {{getMessage reunion.penetrometre.intitule}}</span>\n                    {{/if}}\n                {{/if}}\n            </p>\n            <div class="paris-evenements">\n                {{#each parisEvenements}}\n                    <div class="picto-pari picto-pari-action mini {{codePari}}"\n                        data-date="{{../date}}"\n                        data-courseid="{{numOrdre}}"\n                        data-reunionid="{{../reunion.numOfficiel}}"\n                        data-family="{{codePari}}"\n                    ></div>\n                {{/each}}\n            </div>\n        </div>\n        <div class="statut-box">\n            <span> </span>\n        </div>\n    </div>\n\n    <div class="bottom">\n        <ul class="inline-list disciplines"> </ul>\n        <div class="picto-meteo {{#if reunion.meteo}}{{reunion.meteo.nebulositeCode}}{{/if}}"></div>\n        {{#if reunion.prochaineCourse}}\n            <div class="next-course-button{{#if hasProchaineCourseProgramme}} next-course-programme-button{{/if}}"\n                 data-reunionid="{{reunion.numOfficiel}}"\n                 data-numordrenextcourse="{{reunion.prochaineCourse}}">\n                <a href="#"> </a>\n            </div>\n        {{else}}\n            <div class="next-course-nobutton"></div>\n        {{/if}}\n    </div>\n</div>\n';});

define('text!src/programme/reunions_infos/templates/disciplines.hbs',[],function () { return '{{#each disciplinesMere}}\n    <li class="picto-discipline {{lowercase this}}">\n        <span title="{{capitalizeFirst this}}"> </span>\n    </li>\n{{/each}}\n';});

define('text!src/programme/reunions_infos/templates/typePari.hbs',[],function () { return '<div class="picto-pari picto-pari-action big block {{.}}"></div>';});

define('text!src/programme/reunions_infos/templates/meteo.hbs',[],function () { return 'Temp :&nbsp;&nbsp;&nbsp;{{temperature}}\n<br/>Vent :&nbsp;&nbsp;&nbsp;&nbsp;{{forceVent}}\n\n';});

define('manager',['backbone', 'underscore-mixins'], function (Backbone, _) {
    

    return {
        extend: function (obj) {
            return _.extend(obj, Backbone.Events);
        }
    };
});
define('src/course/liste_courses/ReunionModel',['utils', 'defaults', 'timeManager', 'messages'], function (utils, defaults, timeManager, messages) {
    

    return Backbone.Model.extend({
        idAttribute: 'numExterne',

        url: function () {
            return defaults.REUNION_URL
                .replace('{date}', this.date)
                .replace('{numReunion}', this.reunionId);
        },

        setUrlParams: function (date, reunionId) {
            this.date = date;
            this.reunionId = reunionId;
        },

        parse: function (json) {
            if (_.isNull(json)) {
                return [];
            }

            return this.processJSON(json);
        },

        processJSON: function (reunion) {
            reunion.courseEvenement = 0;
            reunion.disciplinesPicto = utils.serviceMapper.uniqDisciplines(reunion.disciplines);
            reunion.dateFr = timeManager.momentWithOffset(reunion.dateReunion, reunion.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);

            _.each(reunion.courses, function (course) {
                var evenement = utils.serviceMapper.getPariEvenement(course.paris);
                course.evenement = evenement;
                if (evenement) {
                    reunion.courseEvenement = {
                        codePari: evenement,
                        numCourse: course.numOrdre
                    };
                }
                course.categorieStr = messages.get('COURSE.CATEGORIE.' + course.categorieParticularite);
                course.disciplineStr = messages.get('COURSE.DISCIPLINE.' + course.discipline);
                if (reunion.audience === "NATIONAL" && reunion.offresInternet === false) {
                    course.paris = _.reject(course.paris, { audience: "REGIONAL" });
                }
            });

            return reunion;
        },

        getCourseById: function (id) {
            var courses = this.get('courses');
            return _.find(courses, function (course) {
                return id === course.numExterne;
            });
        },

        getFirstCourse: function () {
            return this.courses.sortBy(function (course) {
                return course.get('heureDepart');
            })[0];
        },

        getLastCourse: function () {
            return this.courses.sortBy(function (course) {
                return course.get('heureDepart');
            })[this.courses.length - 1];
        }
    });
});

define('src/course/liste_courses/reunionManager',[
    'manager',
    'underscore-mixins',
    'backbone',
    'links',
    'src/course/liste_courses/ReunionModel'
], function (Manager, _, Backbone, links, ReunionModel) {
    

    var manager = null;

    return function () {
        if (manager === null) {
            manager = Manager.extend({
                _model: null,

                getReunion: function (refresh) {
                    if (!this._model || refresh) {
                        if (this._model) {
                            this.stopListening(this._model);
                        }

                        this._model = new ReunionModel();
                        this.listenTo(this._model, 'change:numOfficiel', this._changeReunion);
                    }

                    return this._model;
                },

                setCurrentCourseId: function (courseId) {
                    this._currentCourseId = courseId;
                },

                getCurrentCourseId: function () {
                    var course = this._currentCourseId;

                    if (!course && this.get('courses').length > 0) {
                        course = this.getProchaineCourse();
                    }

                    return course;
                },

                getNbMaxChevauxFromCurrentCourse: function () {
                    var currentCourse = _.findWhere(this.get('courses'), {
                        numExterne: this.getCurrentCourseId()
                    });

                    return currentCourse.nombreDeclaresPartants;
                },

                setCurrentCourseDate: function (date) {
                    this._currentCourseDate = date;
                },

                getCurrentCourseDate: function () {
                    return this._currentCourseDate;
                },

                _changeReunion: function () {
                    this.trigger('changeReunion', this.getReunion());
                },

                changeCourse: function (course, pari) {
                    var date,
                        reunion;

                    date = this.getCurrentCourseDate();
                    reunion = this.get('numOfficiel');

                    Backbone.history.navigate(
                        links.get('pari', date, reunion, course, pari),
                        {trigger: false}
                    );
                    Backbone.trigger('course:change', date, reunion, course, pari);
                },

                getProchaineCourse: function () {
                    return this.get('prochaineCourse') || this.getFirstCourse();
                },

                getFirstCourse: function () {
                    if (this.get('courses')) {
                        return this.get('courses')[0].numOrdre;
                    }
                },

                get: function () {
                    return this.getReunion().get.apply(this.getReunion(), arguments);
                },

                set: function () {
                    return this.getReunion().set.apply(this.getReunion(), arguments);
                }
            });
        }

        return manager;
    };
});

define('src/course/pari/formulationPariHelper',['paris', 'src/course/liste_courses/reunionManager'], function (pari, reunionManager) {
    

    return {
        getCorrelationId: function () {
            var str = '';
            _.times(7, function () {
                str += Math.random() > 0.5 ? Math.round(Math.random() * 10) : String.fromCharCode(97 + Math.ceil(Math.random() * 25));
            });
            return str;
        },

        _createMultipleFormulationsPari: function (model) {
            var self = this,
                formulationsParisToSend = [],
                formulationPariToComplete = {},
                chevauxBases = model.get(pari.BASE),
                attributesToAdd,
                attributesToRemove = [];

            this._formulationPariInitialization(model, formulationPariToComplete);

            _.each(chevauxBases, function (base) {

                attributesToAdd = {
                    'bases': [base],
                    'formule': pari.UNITAIRE,
                    'correlationId': self.getCorrelationId()
                };

                self._populateFormulationAndAddToFormulations(
                    attributesToAdd,
                    attributesToRemove,
                    formulationPariToComplete,
                    formulationsParisToSend,
                    model
                );
            });

            return formulationsParisToSend;
        },

        _createFormulationPari: function (model) {
            var formulationsParisToSend = [],
                formulationPariToComplete = {},
                chevauxBases = model._replaceCrossOrQuestionMarkOnBaseToSend(model.get(pari.BASE)),
                infosPari = model.getInfosPariFromModel(),
                attributesToAdd = {
                    'bases': _.rpad(chevauxBases, infosPari.nbChevauxReglementaire),
                    'correlationId': this.getCorrelationId()
                },
                i,
                l,
                attributesToRemove = [];

            this._formulationPariInitialization(model, formulationPariToComplete);

            if (model.get('isSpot')) {

                if (model.isToutAuto()) {
                    chevauxBases = null;
                    formulationPariToComplete.risque = null;
                }

                for (i = 0, l = model.get('nbParisSpot'); i < l; i++) {
                    attributesToAdd.bases = chevauxBases;
                    attributesToAdd.correlationId = this.getCorrelationId();
                    attributesToAdd.spot = true;
                    attributesToRemove.push('nbMise');
                    this._populateFormulationAndAddToFormulations(
                        attributesToAdd,
                        attributesToRemove,
                        formulationPariToComplete,
                        formulationsParisToSend,
                        model
                    );
                }
            } else {
                this._populateFormulationAndAddToFormulations(
                    attributesToAdd,
                    attributesToRemove,
                    formulationPariToComplete,
                    formulationsParisToSend,
                    model
                );
            }

            return formulationsParisToSend;
        },

        _createFormulationPariReport: function (pariModelCollection) {
            var self = this,
                firstPari = pariModelCollection.first(),
                typeMise = firstPari.get(pari.TYPE_MISE),
                formulationPari = {};

            formulationPari.correlationId = this.getCorrelationId();
            formulationPari.pari = 'REPORT';
            formulationPari.formule = pari.UNITAIRE;
            formulationPari.numeroReunion = firstPari.get('numeroReunion');
            formulationPari.dateReunion = firstPari.get('dateReunion');
            formulationPari[typeMise] = firstPari.getMise();

            formulationPari.formulationsReport = pariModelCollection.map(
                self._createFormulationReport
            );

            return [formulationPari];
        },

        _createFormulationReport: function (pariModel, index) {
            var formulationReport = {},
                infosPari = pariModel.getInfosPariFromModel(),
                codesPari = infosPari.codesPari;

            if (index) {
                if (pariModel.get('tauxReport')) {
                    formulationReport.tauxReport = pariModel.get('tauxReport');
                }
                if (pariModel.get('nbMiseReport')) {
                    formulationReport.nbMiseReport = pariModel.get('nbMiseReport');
                }
            }
            formulationReport.numeroCourse = pariModel.get('numeroCourse');
            formulationReport.formulations = _.flatten(_.map(pariModel.get(pari.BASE), function (base) {
                return _.map(codesPari, function (codePari) {
                    return {
                        'pari': codePari,
                        'formule': pariModel.get(pari.FORMULE),
                        'bases': [base]
                    };
                });
            }));
            return formulationReport;
        },

        /**
         *
         * @param formulationPari
         */
        _formulationPariInitialization: function (model, formulationPari) {
            var associate = model.get(pari.ASSOCIATE) || null,
                complementary = model.get(pari.COMPLEMENTARY) || null,
                typeMise = model.get(pari.TYPE_MISE),
                dtlo = model.get(pari.DTLO),
                infosPari = model.getInfosPariFromModel(),
                codesPari = infosPari.codesPari;

            formulationPari.numeroReunion = model.get('numeroReunion');
            formulationPari.numeroCourse = model.get('numeroCourse');
            formulationPari.dateReunion = model.get('dateReunion');
            formulationPari.associes = associate;
            formulationPari.complement = +complementary || null; // +['1'] === 1;
            formulationPari.paris = codesPari;
            formulationPari.formule = model.get(pari.FORMULE);
            formulationPari.dtlo = dtlo;
            formulationPari[typeMise] = model.getMise();
            formulationPari.risque = model.get(pari.RISQUE);
        },

        _populateFormulationAndAddToFormulations: function (attributesToAdd, attributesToRemove, formulationPariIncomplete, formulationsParis, model) {
            var _attributesToRemove = _.union(attributesToRemove, ['paris']);

            _.each(formulationPariIncomplete.paris, function (pari) {
                var _attributesToAdd = _.extend({}, attributesToAdd, {
                        'pari': pari
                    }),
                    formulation = _.clone(formulationPariIncomplete),
                    infosPari = model.getInfosPariFromCodePari(pari);

                formulation = _.omit(formulation, _attributesToRemove);
                formulation = _.extend({}, formulation, _attributesToAdd);

                if (!infosPari.ordre && formulation.dtlo !== undefined) {
                    delete formulation.dtlo;
                }

                if (!infosPari.complement && formulation.complement !== undefined) {
                    delete formulation.complement;
                }

                formulationsParis.push(formulation);
            });
        }
    };

});
define('src/course/pari/PariModel',[
    'utils',
    'paris',
    'defaults',
    'timeManager',
    './formulationPariHelper'
], function (Utils, pari, defaults, timeManager, formulationPariHelper) {
    

    var significantBetAttributs;

    significantBetAttributs = [
        pari.BASE,
        pari.ASSOCIATE,
        pari.COMPLEMENTARY,
        pari.FAMILY
    ];

    return Backbone.Model.extend({

        url: defaults.PARIER_URL,

        TOUT_AUTO: 'toutAuto',

        defaults: {
            // Attributs metier
            base: [],
            associate: [],
            complementary: [],

            typeMise: pari.NBMISE,
            nbMise: 1,
            flexi: 0,
            valeur: 0,

            family: null,
            variants: [],
            risque: null,
            formule: pari.UNITAIRE,

            coherence: true,

            isSpot: false,
            nbParisSpot: 1,

            // Report
            tauxReport: null,
            nbMiseReport: null
        },

        initialize: function (attributes, options) {
            Backbone.Model.prototype.initialize.apply(this);
        },

        setParticipants: function (participants) {
            this.participants = participants;
        },

        setParis: function (paris) {
            this.paris = paris;
        },

        selectParticipantsFromBase: function () {
            if (this.participants) {
                this.participants.each(function (participant) {
                    var contains = _.contains(this.get(pari.BASE), participant.get('numPmu')) && participant.get('statut') != 'NON_PARTANT';
                    participant.set('baseSelected', contains);
                }, this);
            }
        },

        selectParticipantsFromAssocie: function () {
            if (this.participants) {
                _.each(this.get(pari.ASSOCIATE), function (numCheval) {
                    if (this.participants.get(numCheval) && this.participants.get(numCheval).get('statut') != 'NON_PARTANT') {
                        this.participants.get(numCheval).set('associateSelected', true);
                    }
                }, this);
            }
        },

        /**
         * Ajoute un numéro de participant dans une des selections.
         * Le numéro est placé à la place du 1er élément null si il existe
         * ou à la fin de la liste.
         * @param type Le type de la selection
         * @param num Le numéro de participant à ajouter.
         */
        addSelection: function (type, num) {
            var list = _.clone(this.get(type)) || [],
                i;
            if (!_.isNumber(num) || !_.contains(list, num)) {
                i = _.indexOf(list, null);
                if (i !== -1) {
                    list[i] = num;
                } else {
                    list.push(num);
                }
                this.set(type, list);
            }
        },

        /**
         * Enlève un numéro dans une des selections.
         * Le comportement est différent selon le type de liste.
         * @param type Le type de la selection
         * @param num Le numéro de participant à enlever.
         */
        removeSelection: function (type, num) {
            var list = _.clone(this.get(type)) || [],
                i = _.lastIndexOf(list, num);

            // Removing something in the middle
            if (i !== (list.length - 1) || this.get('isSpotMixte')) {
                list[i] = null;
            } else {
                list.pop();
            }
            this.set(type, list);
        },

        getMise: function () {
            var typeMise = this.get(pari.TYPE_MISE);
            return this.get(typeMise) * ((typeMise === pari.VALEUR) ? 100 : 1);
        },

        /**
         * Remplace les 'X' des chevaux de bases par null
         * @param chevauxBases
         * @return chevauxBases
         * @private
         */
        _replaceCrossOrQuestionMarkOnBaseToSend: function (chevauxBases) {
            _.each(chevauxBases, function (num) {
                if (num === pari.X || num === pari.INTERROGATION) {
                    chevauxBases[_.indexOf(chevauxBases, num)] = null;
                }
            });
            return chevauxBases;
        },

        /*
         * Complète le retour du pari en ajoutant des informations complémentaires (montant, nombre d'erreurs ...)
         * @param retoursPari : retour du service
         * @return retour du service + d'attibuts
         * */
        computeAndAddAttributes: function (parisResponse) {
            var montantAndErrors = this._addFormuleAndComputeErrorAndMontant(parisResponse);
            this._addMontantAndErrors(montantAndErrors, parisResponse);

            return parisResponse;
        },

        _addFormuleAndComputeErrorAndMontant: function (parisResponse) {
            var montantEnjeuTotalEncaisse = 0,
                nbParisError = 0,
                lastError = 0;

            _.each(parisResponse, function (pari) {
                if (pari.errors.length > 0) {
                    nbParisError += 1;
                    lastError = pari.errors[0].codeErreur;
                } else {
                    montantEnjeuTotalEncaisse += pari.montantEnjeuEncaisse;
                }
            }, this);

            return {
                'montantEnjeuTotalEncaisse': montantEnjeuTotalEncaisse,
                'nbParisError': nbParisError,
                'lastError': lastError
            };
        },

        _addMontantAndErrors: function (attributesToAdd, pariResponse) {
            pariResponse.montantEnjeuTotalEncaisse = attributesToAdd.montantEnjeuTotalEncaisse;
            pariResponse.nbParisError = attributesToAdd.nbParisError;
            pariResponse.lastError = attributesToAdd.lastError;
            pariResponse.isPariSimple = this.isPariSimple();
        },

        isToutAuto: function () {
            return this.get('risque') === this.TOUT_AUTO;
        },

        isChamp: function () {
            var formule = this.get(pari.FORMULE);
            return formule === pari.CHAMP_REDUIT || formule === pari.CHAMP_TOTAL;
        },

        isChampReduit: function () {
            var formule = this.get(pari.FORMULE);
            return formule === pari.CHAMP_REDUIT;
        },

        /**
         * DOC + TU
         * @return true si le pari est sauvegardable
         */
        isSaveable: function () {
            return _.any(significantBetAttributs, function (attribut) {
                var value = this.get(attribut),
                    isSaveable;

                if (_.isArray(value)) {
                    isSaveable = value.length > 0;
                } else {
                    isSaveable = value;
                }
                return isSaveable;
            }, this);
        },

        save: function () {
            var self = this;
            if (!this.get('isSpot') && !this.get('isReport')) {
                this.modelHistory = this.toJSON();
                _.each(this.modelHistory, function (model) {
                    model.flexi = self.get('flexi');
                    model.valeur = self.get('valeur');
                    model.typeMise = self.get('typeMise');
                    model.variants = self.get('variants');
                });
            } else {
                this.modelHistory = false;
            }
            return Backbone.Model.prototype.save.apply(this, arguments);
        },

        /**
         * Calcule le nombre de chevaux d'un pari en formule unitaire
         * Ex: Multi en 5       => 5 (risque)
         *      Couplé Ordre    => 2 (nbChevauxReglementaires)
         * @return {Number or undefined}
         */
        getNbChvxFormuleUnitaire: function () {
            var nbChevauxReglementaires,
                family = this.get(pari.FAMILY),
                infosFamily = Utils.serviceMapper.getSettingsFamillePari(this.paris, family);

            if (infosFamily) {
                if (this.isToutAuto()) {
                    nbChevauxReglementaires = 0;
                } else if (this.get(pari.RISQUE)) {
                    nbChevauxReglementaires = this.get(pari.RISQUE);
                } else {
                    nbChevauxReglementaires = infosFamily.nbChevauxReglementaire;
                }
            }
            return nbChevauxReglementaires || -1;
        },

        /**
         * @return {Boolean} true si l'offre de pari est un pari simple
         */
        isPariSimple: function () {
            return this.get(pari.FAMILY) === pari.SIMPLE &&
                this.get(pari.VARIANTS).length > 0;
        },

        /**
         * @return {Boolean} true si l'offre de pari est un pari Tic_Trois
         */
        isPariTic3: function () {
            return this.get(pari.FAMILY) === pari.TIC_TROIS;
        },

        nbSelected: function (type) {
            return _.filter(this.get(type), function (item) {
                return item;
            }).length;
        },

        nbSelectedBase: function () {
            return _.filter(this.get(pari.BASE), function (item) {
                return parseInt(item, 10) && !isNaN(item);
            }).length;
        },

        nbSelectedX: function () {
            return _.filter(this.get(pari.BASE), function (item) {
                return item === pari.X;
            }).length;
        },

        nbSelectedY: function () {
            return _.filter(this.get(pari.BASE), function (item) {
                return item === pari.INTERROGATION;
            }).length;
        },

        nbSelectedAssocie: function () {
            return _.filter(this.get(pari.ASSOCIATE), function (item) {
                return parseInt(item, 10) && !isNaN(item);
            }).length;
        },

        availableBase: function (max) {
            if (!max) {
                if (this.get('isSpot') && this.get('isSpotMixte')) {
                    max = this.get('nbChevaux');
                } else {
                    max = this.getNbChvxFormuleUnitaire();
                }
            }
            return max - this.nbSelected(pari.BASE);
        },

        compactBaseAccordingToMax: function (max, collection, willNotHandleChamp) {
            var selected = _.compact(this.get(pari.BASE)),
                length = this.nbSelected(pari.BASE),
                i;

            for (i = length; i > max; i--) {
                this._uncheckBase(selected[i - 1], collection);
            }
            if (!willNotHandleChamp) {
                this._handleLast(selected[i - 1], collection, max);
            }
        },

        getInfosPariFromModel: function () {
            var family = this.get(pari.FAMILY),
                variants = this.get(pari.VARIANTS);

            return Utils.serviceMapper.getInfosPari(this.paris, family, variants);
        },

        getNbParis: function () {
            var infosParieuse = this.getInfosPariFromModel(),
                base = this.get(pari.BASE) || [],
                associate = this.get(pari.ASSOCIATE) || [],
                baseLength;

            if (!infosParieuse) {
                return 0;
            }

            if (this.get('isSpot')) {
                if (this.isToutAuto()) {
                    return 1;
                }
                baseLength = base.length;
            } else {
                baseLength = _.compact(_.without(base, pari.X)).length;
            }

            return _.reduce(infosParieuse.codesPari, function (sum, codePari) {
                var _infoPari = this.getInfosPariFromCodePari(codePari);

                return sum + Utils.calculateNbParis(
                    _infoPari.ordre,
                    this.get(pari.FORMULE),
                    this.getNbChvxFormuleUnitaire(),
                    baseLength,
                    associate.length,
                    _infoPari.ordre ? this.get(pari.DTLO) : false,
                    this.participants.getPartants().length
                );
            }, 0, this);
        },

        _handleLast: function (numCheval, collection, max) {
            if (this.availableBase(max) === 0 && (max === this.nbSelectedBase() || max === this.nbSelectedX())) {
                this._uncheckBase(numCheval, collection);
            }
        },

        _uncheckBase: function (numCheval, collection) {
            if (numCheval === pari.X) {
                this.removeSelection(pari.BASE, pari.X);
            } else {
                collection.get(numCheval).set('baseSelected', false);
            }
        },

        _uncheckAllBase: function () {
            this.participants.each(function (participant) {
                participant.set('baseSelected', false);
            });
        },

        setChevauxCoches: function () {
            this.participants.each(function (participant) {
                participant.set('baseSelected', _.contains(this.chevauxCoches, participant.get('numPmu')) && participant.get('statut') != 'NON_PARTANT');
                participant.set('associateSelected', false);
            }, this);
            this.set(pari.COMPLEMENTARY, []);
            this.set('formule', pari.UNITAIRE);
        },

        _truncateBase: function (nbChevaux) {
            var num,
                base = _.clone(this.get(pari.BASE));
            while (base.length > nbChevaux) {
                if (_.isNumber(num = base.pop())) {
                    this._uncheckBase(num, this.participants);
                }
            }
            if (!this._isSpotBaseWellFilled(base)) {
                if (_.isNumber(base[base.length - 1])) {
                    this._uncheckBase(base[base.length - 1], this.participants);
                }
                base[base.length - 1] = null;
            }
            this.set(pari.BASE, base);
        },

        _isSpotBaseWellFilled: function (base) {
            return !(_.every(base, function (value) {
                return _.isNumber(value);
            }) || _.every(base, function (value) {
                return value === pari.INTERROGATION;
            }));
        },

        /**
         * Evite de multiplier les events en faisant un clear suivi d'un set.
         */
        clear: function (attributes, options) {
            var attrs = {},
                result;

            _.each(_.keys(this.attributes), function (key) {
                attrs[key] = undefined;
            });

            result = this.set(
                _.extend(attrs, attributes),
                options
            );

            this.trigger('clear');

            return result;
        },

        setReportFormulations: function (formulations) {
            this.reportFormulations = formulations;
        },

        addVariant: function (variant) {
            var variants = this.get(pari.VARIANTS),
                possibleVariants = Utils.serviceMapper.simplifyVariants(this.paris)[this.get(pari.FAMILY)];

            if (_.indexOf(variants, variant) < 0) {
                this.set(pari.VARIANTS, _.sortBy(_.union(variants, [variant]), function (variant) {
                    return _.indexOf(possibleVariants, variant);
                }));
                this.trigger('change:variants', this.get(pari.VARIANTS));
            }
        },

        removeVariant: function (variant) {
            var variants = this.get(pari.VARIANTS);

            this.set(pari.VARIANTS, _.without(variants, variant));
            this.trigger('change:variants', this.get(pari.VARIANTS));
        },

        getInfosPariFromCodePari: function (codePari) {
            return _.findWhere(this.paris, { codePari: codePari });
        },

        toJSON: function () {
            if (this.get('isReport')) {
                return formulationPariHelper._createFormulationPariReport(this.reportFormulations);
            }
            if (this.isPariSimple()) {
                return formulationPariHelper._createMultipleFormulationsPari(this);
            }
            return formulationPariHelper._createFormulationPari(this);
        }
    });
});

define('src/course/pari/pariManager',[
    'manager',
    'underscore-mixins',
    'backbone',
    'src/course/pari/PariModel',
    'src/course/liste_courses/reunionManager',
    'paris',
    'utils',
    'messages'
], function (Manager, _, Backbone, PariModel, reunionManager, pari, utils, messages) {
    

    var manager = null;

    return function () {
        if (manager === null) {
            manager = Manager.extend({
                _pariModel: null,
                _sauvegardes: {},
                _restaurationEnCours: false,

                getPari: function (refresh) {
                    if (this._pariModel === null || refresh) {
                        if (this._pariModel) {
                            this.stopListening(this._pariModel);
                        }

                        this.clear();
                        this._pariModel = new PariModel();

                        this.initListeners();
                    }
                    return this._pariModel;
                },

                initListeners: function () {
                    this.listenTo(this._pariModel, 'change:family', this.onFamilyChange);
                    this.listenTo(this._pariModel, 'change:variants change:base', this.corrigeFormule);
                    this.listenTo(this._pariModel, 'change:formule', this.corrigeNbChevaux);
                    this.listenTo(this._pariModel, 'change:isSpot', this.onSpotChange);
                    this.listenTo(this._pariModel, 'change:nbChevaux', this.corrigeBase);
                    this.listenTo(this._pariModel, 'change:risque', this.onRisqueChange);

                    this.listenTo(this._pariModel, 'change:isReport', function () {
                        this.trigger.apply(this, _.union(['change:isReport'], arguments));
                    });

                    this.initSauvegardeListeners();

                    this.listenTo(this._pariModel, 'clear', this._sauvegardeClear);
                },

                initSauvegardeListeners: function () {
                    var self = this;
                    this.listenTo(Backbone, 'course:change', _.bind(this._sauvegarder, this));
                    this.listenTo(Backbone.history, 'all', function (event, router, route) {
                        if (this.previousRoute === 'courseReunionCourse' ||
                                this.previousRoute === 'courseReunionCourseSpot' ||
                                this.previousRoute === 'courseReunionCoursePari') {

                            self._sauvegarder();
                        }
                        this.previousRoute = route;
                    });
                },

                get: function () {
                    return this.getPari().get.apply(this.getPari(), arguments);
                },

                set: function () {
                    return this.getPari().set.apply(this.getPari(), arguments);
                },

                ////////////////////////////////////////////////////
                // Définitions handlers changements sur le modèle //
                ////////////////////////////////////////////////////

                onFamilyChange: function () {
                    this.corrigeFormule();
                    this.corrigeNbChevaux();
                    this.corrigeVariante();
                },

                onRisqueChange: function () {
                    this.corrigeFormule();
                    this.corrigeNbChevaux();
                },

                onSpotChange: function () {
                    this.corrigeReport();
                    this.corrigeFormule();
                    this.corrigeNbChevaux();
                    this.corrigeDtlo();
                },

                ////////////////////////////////////////////////////
                // Définitions correcteurs                        //
                ////////////////////////////////////////////////////

                // Correcteurs
                corrigeBase: function () {
                    if (this.getPari().get('isSpot') && this.getPari().get('isSpotMixte')) {
                        this.getPari()._truncateBase(this.getPari().get('nbChevaux'));
                    }
                },

                corrigeReport: function () {
                    if (this.getPari().get('isSpot')) {
                        this.getPari().set('isReport', false);
                    }
                },

                corrigeFormule: function () {
                    var base, regl, baseLength,
                        family = this.getPari().get(pari.FAMILY),
                        formule = this.getPari().get(pari.FORMULE);

                    if (family) {
                        if (family === pari.SIMPLE || family === pari.TIC_TROIS || this.getPari().isToutAuto()) {
                            this.getPari().set(pari.FORMULE, pari.UNITAIRE);

                        } else if (!this.getPari().get('isSpot') &&
                                (formule === pari.UNITAIRE || formule === pari.COMBINAISON)) {

                            base = this.get(pari.BASE);
                            regl = this.getPari().getNbChvxFormuleUnitaire();
                            baseLength = _.compact(base).length;
                            if (baseLength <= regl) {
                                this.getPari().set(pari.FORMULE, pari.UNITAIRE);
                            } else {
                                this.getPari().set(pari.FORMULE, pari.COMBINAISON);
                            }
                        } else if (this.getPari().get('isSpot') && formule !== pari.COMBINAISON) {
                            this.getPari().set(pari.FORMULE, pari.UNITAIRE);
                        }
                    }
                },

                corrigeNbChevaux: function () {
                    var nbChvxFormuleUnitaire,
                        nbChevauxMin,
                        nbChevaux,
                        formule;
                    if (this.getPari().get('isSpot')) {
                        formule = this.getPari().get(pari.FORMULE);
                        nbChvxFormuleUnitaire = this.getPari().getNbChvxFormuleUnitaire();
                        nbChevaux = this.getPari().get('nbChevaux');
                        if (formule === pari.UNITAIRE) {
                            nbChevauxMin = nbChvxFormuleUnitaire;

                            if (nbChevaux != nbChevauxMin) {
                                this.getPari().set('nbChevaux', nbChevauxMin);
                            }
                        } else if (this.getPari().get(pari.FORMULE) === pari.COMBINAISON) {
                            nbChevauxMin = nbChvxFormuleUnitaire + 1;

                            if (!nbChevaux || nbChevaux < nbChevauxMin) {
                                this.getPari().set('nbChevaux', nbChevauxMin);
                            }
                        }
                    }
                },

                corrigeDtlo: function () {
                    if (this.getPari().get('isSpot')) {
                        this.getPari().set(pari.DTLO, false);
                    }
                },

                corrigeVariante: function () {
                    var attrs = {},
                        variants;
                    if (!this.get('isReport')) {
                        variants = this.getVariantesForCurrentPari();

                        attrs.variants = [];

                        if (!_.isEmpty(variants) && variants.length === 1) {
                            attrs.variants.push(variants[0]);
                        }
                    }
                    this.set(attrs);
                },

                getVariantesForCurrentPari: function () {
                    var family = this.get('family'),
                        paris = this.getPari().paris;

                    return utils.serviceMapper.simplifyVariants(paris)[family];
                },

                clear: function () {
                    if (this._pariModel !== null) {
                        this.stopListening(this._pariModel);
                    }
                    this.trigger('clear');
                },

                pariRestoreToPariModel: function (pariToRestore) {
                    this.getPari().set(pari.ASSOCIATE, pariToRestore.associes);
                    this.getPari().set(pari.FAMILY, utils.serviceMapper.getFamilyFromCodePari(pariToRestore.pari));
                    this.getPari().set(pari.VARIANTS, _.compact(pariToRestore.variants));
                    this.getPari().set(pari.FORMULE, pariToRestore.formule);

                    this.getPari().set(pari.COMPLEMENTARY, [pariToRestore.complement]);
                    if (pariToRestore.complement) {
                        this.getPari().set("complementarySelected", true);
                        Backbone.trigger("complementary:updtae", pariToRestore.complement);
                    }

                    this.getPari().set(pari.RISQUE, pariToRestore.risque);
                    this.getPari().set(pari.BASE, pariToRestore.bases);
                    this.getPari().set(pari.FLEXI, pariToRestore.flexi);
                    this.getPari().set(pari.TYPE_MISE, pariToRestore.typeMise);
                    this.getPari().set(pari.NBMISE, pariToRestore.nbMise);
                    this.getPari().set(pari.VALEUR, pariToRestore.valeur);
                    this.getPari().set(pari.DTLO, pariToRestore.dtlo);
                },

                _sauvegarder: function () {
                    var reunion = reunionManager().get('numOfficiel'),
                        course = reunionManager().getCurrentCourseId(),
                        date = reunionManager().getReunion().date;

                    if (!this._isSauvegardable()) {
                        return;
                    }

                    if (!this._sauvegardes[date]) {
                        this._sauvegardes[date] = {};
                    }

                    if (!this._sauvegardes[date][reunion]) {
                        this._sauvegardes[date][reunion] = {};
                    }

                    // => Backbone.Model.clone ne fonctionne pas sur PhantomJS
                    // => voir https://github.com/ariya/phantomjs/issues/10935
                    this._sauvegardes[date][reunion][course] = new PariModel(this.getPari().attributes);
                },

                _isSauvegardable: function () {
                    return !this._restaurationEnCours && (!_.isEmpty(this.get(pari.BASE)) || this.get(pari.FAMILY));
                },

                _sauvegardeClear: function () {
                    if (this._sauvegardeExiste()) {
                        this._supprimerSauvegarde();
                    }

                    this._supprimerSauvegardesReport();
                },

                _supprimerSauvegarde: function () {
                    var reunion = reunionManager().get('numOfficiel'),
                        course = reunionManager().getCurrentCourseId(),
                        date = reunionManager().getReunion().date;

                    this._supprimerSauvegardePourCourse(date, reunion, course);
                },

                _supprimerSauvegardesReport: function () {
                    var date = reunionManager().getReunion().date;

                    _.each(this._sauvegardes[date], function (sauvegardeReunion, reunion) {
                        _.each(sauvegardeReunion, function (sauvegarde, course) {
                            if (this._sauvegardes[date][reunion][course].get('isReport')) {
                                this._supprimerSauvegardePourCourse(date, reunion, course);
                            }
                        }, this);
                    }, this);
                },

                _supprimerSauvegardePourCourse: function (date, reunion, course) {
                    delete this._sauvegardes[date][reunion][course];

                    if (_.isEmpty(this._sauvegardes[date][reunion])) {
                        delete this._sauvegardes[date][reunion];
                    }

                    if (_.isEmpty(this._sauvegardes[date])) {
                        delete this._sauvegardes[date];
                    }
                },

                _sauvegardeExiste: function () {
                    var reunion = reunionManager().get('numOfficiel'),
                        course = reunionManager().getCurrentCourseId(),
                        date = reunionManager().getReunion().date;

                    return this._sauvegardes[date] && this._sauvegardes[date][reunion] && this._sauvegardes[date][reunion][course];
                },

                restaurer: function () {
                    var reunion = reunionManager().get('numOfficiel'),
                        course = reunionManager().getCurrentCourseId(),
                        date = reunionManager().getReunion().date,
                        champsARestaurer = [
                            pari.ASSOCIATE,
                            pari.FAMILY,
                            'isSpot',
                            pari.VARIANTS,
                            pari.FORMULE,
                            pari.COMPLEMENTARY,
                            pari.RISQUE,
                            pari.BASE,
                            pari.FLEXI,
                            pari.TYPE_MISE,
                            pari.NBMISE,
                            pari.VALEUR,
                            pari.DTLO,
                            'nbParisSpot',
                            'nbChevaux'
                        ];

                    if (!this.get('isReport')) {
                        this._resetSauvegardesReport();
                    }

                    if (!this._isRestaurable()) {
                        return;
                    }

                    this._restaurationEnCours = true;
                    _.each(champsARestaurer, function (champ) {
                        this.set(champ, this._sauvegardes[date][reunion][course].get(champ));
                    }, this);
                    this._restaurationEnCours = false;
                },

                _isRestaurable: function () {
                    return !this.get('isReport') && this._sauvegardeExiste();
                },

                _resetSauvegardesReport: function () {
                    var date = reunionManager().getReunion().date;

                    _.each(this._sauvegardes[date], function (sauvegardeReunion, reunion) {
                        _.each(sauvegardeReunion, function (sauvegarde, course) {
                            if (this._sauvegardes[date][reunion][course].get('isReport')) {
                                this._sauvegardes[date][reunion][course].set('isReport', false);
                            }
                        }, this);
                    }, this);
                },

                getDefaultsAttributes: function () {
                    return {
                        dateReunion: reunionManager().getReunion().get('dateReunion'),
                        numeroReunion: reunionManager().get('numOfficiel'),
                        numeroCourse: reunionManager().getCurrentCourseId(),
                        formule: this.getPari().defaults.formule,
                        typeMise: this.getPari().defaults.typeMise
                    };
                },

                _modelClear: function () {
                    this.getPari()._uncheckAllBase();
                    this.getPari().clear(_.extend({}, this.getPari().defaults, this.getDefaultsAttributes()));
                }
            });
        }

        return manager;
    };
});
define('src/course/pari/PariReportFormulationModel',[
    'backbone',
    'underscore-mixins',
    'paris'
], function (Backbone, _, pari) {
    

    return Backbone.Model.extend({
        model: null,
        courseId: -1,

        initialize: function (attrs, options) {
            this.model = options.model;
            this.courseId = options.courseId;
        },

        isValid: function () {
            var selectedBase = this.model.nbSelectedBase();

            return selectedBase > 0 &&
                selectedBase <= 3 &&
                this.get('variants').length > 0;
        },

        isStarted: function () {
            return this.get(pari.VARIANTS).length > 0 || this.model.nbSelectedBase() > 0;
        },

        get: function () {
            return (this.model ? this.model.get.apply(this.model, arguments) : null);
        },

        set: function () {
            return (this.model ? this.model.set.apply(this.model, arguments) : null);
        }
    });
});
define('src/course/pari/pariPopin',[
    'messages',
    'modalManager'
], function (messages, modalManager) {
    

    var pariBox = '#pari-box',
        layer = '#pari-box .layer-popin';

    return {
        showConfirmation: function (successCallback) {
            modalManager.confirm(
                messages.get('validation.front.3008'),
                $(pariBox),
                this._noopIfUndefined(successCallback),
                {
                    onConfirmArgs: _.rest(arguments),
                    closeOnConfirm: true,
                    category: 'pari',
                    maxWidth: 242
                }
            );
        },
        showConfirm: function (options) {
            modalManager.confirm(
                options.message || messages.get('validation.front.3008'),
                $(pariBox),
                this._noopIfUndefined(options.confirmCallback),
                {
                    onConfirmArgs: options.successCallbackArgs,
                    closeOnConfirm: true,
                    onCancel: this._noopIfUndefined(options.cancelCallback),
                    category: 'pari',
                    maxWidth: 242
                }
            );
        },
        showDialog: function (options) {
            modalManager.dialog(
                options.message,
                $(pariBox),
                this._noopIfUndefined(options.confirmCallback),
                {
                    onConfirmArgs: options.successCallbackArgs,
                    closeOnConfirm: true,
                    category: 'pari',
                    maxWidth: 242
                }
            );
        },
        showError: function (message, isWarning, is401) {
            this._showError(message, isWarning, is401, true);
        },
        showWarning: function (message) {
            this._showError(message, true, false, true);
        },
        showFixedWarning: function (message) {
            this._showError(message, true, false, false);
        },
        showFixedError: function (message) {
            this._showError(message, false, false, false);
        },
        _showError: function (message, isWarning, is401, isClosable) {
            _.defer(function () {
                modalManager.forbid(message, $(pariBox), 'pari ' + (is401 ? '401 ' : '') + (isWarning || false ? 'warning' : 'error'),
                    {
                        closeOnConfirm: true,
                        contentClosable: isClosable,
                        category: 'pari' + (is401 ? ' 401' : ''),
                        maxWidth: 242
                    });
            });
        },
        showAlert: function (message, confirm, options) {
            modalManager.dialog(
                message,
                $(pariBox),
                this._noopIfUndefined(confirm),
                _.extend({maxWidth: 242, closeOnConfirm: true}, options)
            );
        },
        showLayerAttente: function (options) {
            modalManager.pane('', $(pariBox), '', _.extend({}, {
                loading: true,
                maxWidth: 242,
                category: 'pari',
                layer: true,
                position: 'center',
                type: 'pane'
            }, options));
        },
        hide: function () {
            var $layer = $(layer);

            if ($layer.is(':visible')) {
                modalManager.closeCategory('pari');
                modalManager.closeCategory('pari 401');
                $layer.hide();
                $layer.removeClass('wait');
            }
        },
        closeAuthenticationError: function () {
            if (modalManager.hasCategory('pari 401')) {
                this.hide();
            }
        },
        _noopIfUndefined: function (func) {
            return _.isFunction(func) ? func : $.noop;
        }
    };
});

define('src/course/pari/pariReportManager',[
    'manager',
    'underscore-mixins',
    'backbone',
    'src/course/pari/pariManager',
    'src/course/liste_courses/reunionManager',
    'src/course/pari/PariReportFormulationModel',
    'src/course/pari/PariModel',
    'paris',
    'src/course/pari/pariPopin',
    'messages'
], function (Manager, _, Backbone, pariManager, reunionManager, PariReportFormulmationModel, PariModel, pari, pariPopin, messages) {
    

    var pariReportManager = null;

    return function () {
        if (pariReportManager === null) {
            pariReportManager = {};

            _.each(pariManager(), function (value, champ) {
                if (_.isFunction(value)) {
                    pariReportManager[champ] = _.bind(value, pariManager());
                }
            });

            pariReportManager = Manager.extend(_.extend(pariReportManager, {
                _collection: null,

                enumMiseReport: {
                    '%100':  'La totalité du gain',
                    '%50':   'La moitié du gain',
                    'x1':    '1 * la mise',
                    'x2':    '2 * la mise',
                    'x3':    '3 * la mise',
                    'x4':    '4 * la mise',
                    'x5':    '5 * la mise',
                    'x10':   '10 * la mise',
                    'x20':   '20 * la mise',
                    'x50':   '50 * la mise',
                    'x100':  '100 * la mise',
                    'x200':  '200 * la mise',
                    'x500':  '500 * la mise',
                    'x1000': '1000 * la mise'
                },

                getCoursesReportables: function () {
                    return _.filter(reunionManager().get('courses'), function (course) {
                        return _.contains(['A_PARTIR', 'INCONNU'], course.categorieStatut) && _.find(course.paris, function (currentPari) {
                            return currentPari.codePari === 'REPORT';
                        }, this);
                    }, this);
                },

                getFormulationsListe: function () {
                    if (!this._collection) {
                        this._collection = new Backbone.Collection();
                        this._collection.comparator = function (formulation) {
                            return _.findWhere(reunionManager().get('courses'), { numOrdre: formulation.courseId }).heureDepart;
                        };
                    }
                    return this._collection;
                },

                getFormulationsListeSize: function () {
                    return this._collection.length;
                },

                getFormulationByNumOrdre: function (numOrdre) {
                    return this.getFormulationsListe().find(function (formulation) {
                        return numOrdre === formulation.get('numeroCourse');
                    });
                },

                getFormulationActive: function () {
                    return this._formulationActive;
                },

                setFormulationActive: function (_pari, _course, _reset) {
                    var json,
                        course = _course || _pari.get('numeroCourse'),
                        paris;

                    if (this._formulationActive) {
                        this._formulationActive.stopListening();
                        paris = _.clone(this._formulationActive.model.paris);
                        // new PariModel(this._formulationActive.model.attributes) === this._formulationActive.model.clone()
                        // => Backbone.Model.clone ne fonctionne pas sur PhantomJS
                        // => voir https://github.com/ariya/phantomjs/issues/10935
                        this._formulationActive.model = new PariModel(this._formulationActive.model.attributes);
                        this._formulationActive.model.paris = paris;
                    }

                    if (_reset) {
                        this.getPari().set(_.omit(this.getPari().defaults, pari.FAMILY));
                    }

                    // Change de course
                    if (reunionManager().getCurrentCourseId() !== course) {
                        reunionManager().changeCourse(course, pari.REPORT);
                    } else {
                        this.getPari().selectParticipantsFromBase();
                    }

                    // Ajoute les options de la formule au pari courant si elles sont valides
                    this._formulationActive = _pari;
                    json = Backbone.Model.prototype.toJSON.apply(_pari.model, []);
                    this._formulationActive.model = this.getPari();
                    this._formulationActive.model.set(json);

                    this.trigger('change:formulationActive', this._formulationActive);

                    this._formulationActive.listenTo(this.getPari(), 'all', function () {
                        _pari.trigger.apply(_pari, arguments);
                    });

                    return this._formulationActive;
                },

                add: function (course) {
                    var _pari;

                    // Ajout de la formulation
                    _pari = new PariReportFormulmationModel({}, {
                        model: this.getPari(),
                        courseId: course
                    });

                    // supprime la formulation active si elle n'est pas modifiée
                    if (this.getFormulationActive() && !this.getFormulationActive().isStarted()) {
                        this.getFormulationsListe().remove(this.getFormulationActive());
                    }

                    this.getFormulationsListe().add(_pari);
                    this.setFormulationActive(_pari, course, true);
                },

                isValid: function () {
                    var isValid = true,
                        collection = this.getFormulationsListe();

                    isValid = isValid && this.getFormulationsListeSize() > 1;
                    collection.each(function (formulation) {
                        isValid = isValid && formulation.isValid();
                    });

                    return isValid;
                },

                remove: function (pari) {
                    pari.stopListening();
                    this.getFormulationsListe().remove(pari);
                },

                clear: function () {
                    this._formulationActive = null;
                    if (this._collection) {
                        this._collection.reset();
                    }
                    this.trigger('report:clear');
                },

                _toggleReport: function () {
                    if (this.get('isReport')) {
                        this.add(reunionManager().getCurrentCourseId());
                    } else {
                        this.clear();
                    }
                },

                lastReportableRace: function () {
                    var courses = this.getCoursesReportables();

                    return courses[courses.length - 1].numOrdre;
                },

                manageAlertingCourse: function (message) {
                    var formulation = this.getFormulationByNumOrdre(message.context.course),
                        reunion = reunionManager().getReunion(),
                        timestampReunion = moment(reunion.date, 'DDMMYYYY').toDate().getTime(),// FIXME : offset en param
                        courseMessage;

                    if (message.context.dateProgramme != timestampReunion ||
                            message.context.reunion != reunion.id) {

                        // L'alerting ne concerne pas la réunion courante
                        return;
                    }

                    courseMessage = this.getCourseMessage(message);

                    if (formulation) {
                        this.manageFormulationImminente(message, courseMessage);
                    }

                    this.majCourse(courseMessage, message);

                    if (formulation) {
                        this.manageSuppressionFormulation(formulation, courseMessage);
                    }

                    this.managePlusDeCourseReportable(courseMessage);
                },

                getCourseMessage: function (message) {
                    return _.find(reunionManager().get('courses'), function (course) {
                        return course.numOrdre === message.context.course;
                    });
                },

                majCourse: function (course, message) {
                    course.departImminent = message.context.departImminent;
                    course.statut = message.context.statut;
                    course.categorieStatut = message.context.categorieStatut;
                },

                manageFormulationImminente: function (message, courseMessage) {
                    var course = this.getCourseMessage(message);

                    if (message.context.departImminent && // course en départ imminent
                            course.departImminent != message.context.departImminent && // popin pas encore affichée
                            _.contains(['A_PARTIR', 'INCONNU'], message.context.categorieStatut)) {

                        pariPopin.showWarning(messages.get('validation.front.5006', courseMessage.numExterne));
                    }
                },

                manageSuppressionFormulation: function (formulation, courseMessage) {
                    if (courseMessage.categorieStatut &&
                            !_.contains(['A_PARTIR', 'INCONNU'], courseMessage.categorieStatut)) {

                        this.remove(formulation);
                        this.showPopinSuppressionFormulation(courseMessage);
                    }
                },

                showPopinSuppressionFormulation: function (courseMessage) {
                    var textMessage;

                    if (!this.getFormulationsListe().isEmpty() &&
                            this.getFormulationsListe().first().get('numeroCourse') > courseMessage.numOrdre) {
                        // On a enlevé la 1ère formulation
                        textMessage = messages.get('validation.front.5007', courseMessage.numExterne);
                    } else {
                        textMessage = messages.get('validation.front.5008', courseMessage.numExterne);
                    }

                    pariPopin.showWarning(textMessage);
                },

                managePlusDeCourseReportable: function (courseMessage) {
                    if (this.get('isReport') && this.getCoursesReportables().length === 1) {
                        this.set(pari.FAMILY, null);
                        this.set('isReport', false);
                        pariPopin.showWarning(
                            messages.get('validation.front.5009', courseMessage.numExterne)
                        );
                    }
                },

                initListeners: function () {
                    this.on('clear', this.clear);
                    this.listenTo(reunionManager(), 'changeReunion', this.clear);
                    this.listenTo(this, 'change:isReport', this._toggleReport);
                    this.listenTo(Backbone, 'course:alert', this.manageAlertingCourse);
                },

                getPariModelCollection: function () {
                    var pariModelArray = this._collection.map(function (pariReportFormulationModel) {
                        return pariReportFormulationModel.model;
                    });
                    return new Backbone.Collection(pariModelArray);
                },

                isEmpty: function () {
                    return !this.get('isReport') ||
                        (this.getFormulationsListeSize() <= 1 && this.getPari().nbSelectedBase() === 0 && this.get(pari.VARIANTS).length === 0);
                }
            }));

            // Propagation des évènements de pariManager
            pariReportManager.listenTo(pariManager(), 'all', function () {
                this.trigger.apply(this, arguments);
            });

            // Gestion des évènements
            pariReportManager.initListeners();
        }

        return pariReportManager;
    };
});
define('src/session/SessionModel',['backbone', 'underscore', 'jquery', 'defaults', 'messages', 'links', 'formatter', 'cookie'], function (Backbone, _, $, defaults, messages, links, formatter) {
    

    return Backbone.Model.extend({

        url: defaults.SESSION_URL_POST,

        token: defaults.AUTH_TOKEN,

        idAttribute: 'nom',

        _deferredInit: null,

        initialize: function () {
            if (!_.isArray(this.token)) {
                this.token = [this.token];
            }

            this.on('request', function () {
                this._deferredInit = $.Deferred();
            });

            this.on('sync', function () {
                if (this.wasDelete()) {
                    this.loggedOut();
                    this._deferredInit.reject();
                } else if (this.hasAuthenticationToken() && !this.isNew()) {
                    if (this.wasPost()) {
                        this.unset('codeConf', {silent: true});
                        this.trigger('login', this);
                    }
                    this._deferredInit.resolve(this);
                } else {
                    this._deferredInit.reject();
                }
            });

            this.on('error', function (model, response) {
                if (response.status === 401) {
                    this.loggedOut();
                }
                this._deferredInit.reject();
            });

            if (this.hasAuthenticationToken()) {
                this.fetch();
            } else {
                this._deferredInit = $.Deferred();
                this._deferredInit.reject();
            }
        },

        loggedOut: function () {
            this.clear();
            this.trigger('logout', this);
        },

        requestAccess: function (successCb, failureCb, context) {
            this.getDeferred()
                .done(function (session) {
                    if (successCb) { successCb.call(context, session); }
                })
                .fail(function () {
                    if (failureCb) { failureCb.apply(context); }
                });
        },

        login: function (obj, options) {
            this.save(obj, options);
        },

        hasAuthenticationToken: function () {
            var hasToken = _.reduce(this.token, function (memo, token) {
                return memo || $.cookie(token);
            }, false);
            return Boolean(hasToken);
        },

        hasMessage: function () {
            return this.get('messages') === true;
        },

        wasPost: function () {
            return this.lastMethod === 'create';
        },

        wasDelete: function () {
            return this.lastMethod === 'delete';
        },

        keepAlive: function () {
            $.get(defaults.SESSION_KEEPALIVE_URL);
        },

        isAwaitingDocuments: function () {
            return this._isStateMatching('TEMPORAIRE', 'EN_ATTENTE', false, false, false) ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, true, false) ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, false, true) ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, true, true);
        },

        isAwaitingDocumentsLater: function () {
            return this._isStateMatching('TEMPORAIRE', 'EN_ATTENTE', false, false, false, 'IDENTITE') ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, true, false, 'IDENTITE') ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, false, true, 'IDENTITE') ||
                this._isStateMatching('TEMPORAIRE', 'KO', false, true, true, 'IDENTITE');
        },

        isAwaitingCode: function () {
            return this._isStateMatching('TEMPORAIRE', 'OK', true, false, false);
        },

        isAwaitingCodeForAdresse: function () {
            return this._isStateMatching('CONFIRME', 'OK', true, false, false);
        },

        hasBirthInformationsMissing: function () {
            return this.get('lieuNaissanceManquant');
        },

        isAutolilimitationsMissing: function () {
            return this.get('autolimitationsManquantes');
        },

        isRibMissing: function () {
            return this.get('ribManquant');
        },

        getDeferred: function () {
            return this._deferredInit.promise();
        },

        _isStateMatching: function (etatCompte, etatPiecesJustificatives, codeSecretManquant, ribManquant, pieceIdentiteManquante, blocage) {

            var _isStateMatching = this.get('etatCompte') === etatCompte &&
                this.get('etatPiecesJustificatives') === etatPiecesJustificatives &&
                this.get('codeSecretManquant') === codeSecretManquant &&
                this.get('ribManquant') === ribManquant &&
                this.get('pieceIdentiteManquante') === pieceIdentiteManquante;

            if (blocage) {
                _isStateMatching = _isStateMatching && _.contains(this.get('blocages'), blocage);
            }

            return _isStateMatching;
        },

        canAccessRetrait: function () {
            return this.get('droits').retrait.autorise;
        },

        canAccessAppro: function () {
            return this.get('droits').approvisionnement.autorise;
        },

        canAccessPari: function () {
            return this.get('droits').pari.autorise || this.get('droits').pari.cause === 'MESSAGE_A_ACQUITTER';
        },

        canAccessCloture: function () {
            return this.get('etatCompte') === 'CONFIRME';
        },

        getApproErrorMessage: function () {
            var messagesDroits = {
                'IDENTITE': messages.get('validation.front.2500', formatter.formatDayCount(this.get('nombreJoursAvantBlocage'))),
                'BLOCAGE:IDENTITE': messages.get('validation.front.2505', formatter.formatDayCount(this.get('nombreJoursAvantBlocage'))),
                'AUTOLIMITATION_APPRO_MANQUANTES': messages.get('AUTOLIM.ERROR.EMPTY', links.get('compteAutolimitations')),
                'BLOCAGE:JRE_BLCK_APPRO': messages.get('validation.front.2010'),
                'BLOCAGE:JRE_BLCK_APPRO_PARI': messages.get('validation.front.2010'),
                'BLOCAGE:JRE_BLCK_TOTAL': messages.get('validation.front.2010')
            };

            return messagesDroits[this.get('droits').approvisionnement.cause];
        },

        getPariErrorMessage: function () {
            var messagesDroits = {
                'AUTOLIMITATION_MANQUANTES': messages.get('validation.front.3003'),
                'MESSAGE_A_ACQUITTER': messages.get('PARI.ERROR.MESSAGE_A_ACQUITTER'),
                'BLOCAGE:JRE_BLCK_APPRO_PARI': messages.get('validation.front.3300'),
                'BLOCAGE:JRE_BLCK_TOTAL': messages.get('validation.front.3300')
            };

            return messagesDroits[this.get('droits').pari.cause];
        },

        getRetraitErrorMessage: function () {
            var messagesDroits,
                retraitErrorMessage = this.isAwaitingCode() ? 'validation.front.2504' : 'validation.front.2500';

            messagesDroits = {
                'ETAT_COMPTE:TEMPORAIRE': messages.get(retraitErrorMessage, formatter.formatDayCount(this.get('nombreJoursAvantBlocage'))),
                'AUTOLIMITATION_MANQUANTES': messages.get('RETRAIT.AUTOLIMITATIONS_VIDES', links.get('compteAutolimitations')),
                'BLOCAGE:JRE_BLCK_TOTAL': messages.get('validation.front.2102')
            };

            return messagesDroits[this.get('droits').retrait.cause];
        },

        isMultiComptes: function () {
            return !!this.get('compte1985Associe') || !!this.get('compte2010Associe');
        },

        toJSON: function () {
            var json = Backbone.Model.prototype.toJSON.apply(this);

            if (json && json.numeroExterne) {
                json.numeroExterne = _.str.trim(json.numeroExterne);
            }

            return json;
        },

        sync: function (method, model, options) {
            this.lastMethod = method;
            if (method === 'read' || method === 'delete') {
                options = options || {};
                options.url = defaults.SESSION_URL;
                if (typeof options.url === 'function') {
                    options.url = options.url.call(model);
                }
            }
            Backbone.Model.prototype.sync.call(this, method, model, options);
        }
    });
});

define('sessionManager',['backbone', 'underscore', 'src/session/SessionModel'], function (Backbone, _, SessionModel) {
    

    var sessionManager = {};
    _.extend(sessionManager, Backbone.Events, {
        requestAccess: function () {
            var session = this._getSession();
            return session.requestAccess.apply(session, arguments);
        },

        requestFreshAccess: function () {
            var session = this._getSession();
            if (session.hasAuthenticationToken()) {
                session.fetch();
                return session.requestAccess.apply(session, arguments);
            }
        },

        logoutIfNoCookie: function () {
            var session = this._getSession();
            if (!session.hasAuthenticationToken()) {
                session.loggedOut();
            }
        },

        login: function () {
            var session = this._getSession();
            return session.login.apply(session, arguments);
        },

        setSolde: function (solde) {
            this._getSession().set('soldeDisponiblePari', solde);
        },

        getRetraitErrorMessage: function () {
            return this._getSession().getRetraitErrorMessage();
        },

        getApproErrorMessage: function () {
            return this._getSession().getApproErrorMessage();
        },

        getPariErrorMessage: function () {
            return this._getSession().getPariErrorMessage();
        },

        keepAlive: function () {
            this._getSession().keepAlive();
        },

        _getSession: function () {
            if (!this.sessionModel) {
                this.sessionModel = new SessionModel();

                this.listenTo(this.sessionModel, 'login', function (session) {
                    this.trigger('login', session);
                });

                this.listenTo(this.sessionModel, 'logout', function () {
                    this.trigger('logout');
                });
            }
            return this.sessionModel;
        },

        isMultiComptes: function () {
            return this._getSession().isMultiComptes();
        },

        isRibMissing: function () {
            return this._getSession().isRibMissing();
        },

        get: function () {
            return this._getSession().get.apply(this._getSession(), arguments);
        }
    });

    return sessionManager;
});

/*
 * tagContainer Generator v2.1.6 Beta
 * Copyright Tag Commander
 * http://www.tagcommander.com/
 * Generated: 2013-09-30 10:45:19 Europe/Paris
 * ---
 * Version	: 1.04
 * IDTC 	: 2
 * IDS		: 866
 */
/*!compressed by YUI*/
var T = true, F = false, _U = "undefined", _N = null;
if (typeof tC == _U) {
    if (typeof document.domain == _U || typeof document.referrer == _U) {document = window.document}
    if (typeof console == _U || typeof console.log == _U) {
        var console = {log: function () {
        }, error: function () {
        }, warn: function () {
        }}
    }
    (function (n, l) {
        var k, s, z = n.document, a = n.location, e = n.navigator, y = n.tC, w = n.$, J = Array.prototype.push, b = Array.prototype.slice, v = Array.prototype.indexOf, g = Object.prototype.toString, j = Object.prototype.hasOwnProperty, p = String.prototype.trim, c = function (L, M) {
            return new c.fn.init(L, M, k)
        }, C = /[\-+]?(?:\d*\.|)\d+(?:[eE][\-+]?\d+|)/.source, r = /\S/, u = /\s+/, d = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, x = /^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/, m = /^<(\w+)\s*\/?>(?:<\/\1>|)$/, E = /^[\],:{}\s]*$/, A = /(?:^|:|,)(?:\s*\[)+/g, I = /\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g, G = /"[^"\\\r\n]*"|true|false|null|-?(?:\d\d*\.|)\d+(?:[eE][\-+]?\d+|)/g, K = /^-ms-/, q = /-([\da-z])/gi, H = function (L, M) {
            return(M + "").toUpperCase()
        }, f = {};
        c.fn = c.prototype = {constructor: c, init: function (L, O, R) {
            var N, P, M, Q;
            if (!L) {return this}
            if (L.nodeType) {
                this.context = this[0] = L;
                this.length = 1;
                return this
            }
            if (typeof L === "string") {
                if (L.charAt(0) === "<" && L.charAt(L.length - 1) === ">" && L.length >= 3) {N = [_N, L, _N]} else {N = x.exec(L)}
                if (N && (N[1] || !O)) {
                    if (N[1]) {
                        O = O instanceof c ? O[0] : O;
                        Q = (O && O.nodeType ? O.ownerDocument || O : z);
                        L = c.parseHTML(N[1], Q, T);
                        if (m.test(N[1]) && c.isPlainObject(O)) {this.attr.call(L, O, T)}
                        return c.merge(this, L)
                    } else {
                        P = z.getElementById(N[2]);
                        if (P && P.parentNode) {
                            if (P.id !== N[2]) {return R.find(L)}
                            this.length = 1;
                            this[0] = P
                        }
                        this.context = z;
                        this.selector = L;
                        return this
                    }
                } else {if (!O || O.tC) {return(O || R).find(L)} else {return this.constructor(O).find(L)}}
            } else {if (c.isFunction(L)) {return R.ready(L)}}
            if (L.selector !== l) {
                this.selector = L.selector;
                this.context = L.context
            }
            return c.makeArray(L, this)
        }, each: function (M, L) {
            return c.each(this, M, L)
        }, ready: function (L) {
            c.ready.promise(L);
            return this
        }};
        c.fn.init.prototype = c.fn;
        c.extend = c.fn.extend = function () {
            var V, N, L, M, R, S, Q = arguments[0] || {}, P = 1, O = arguments.length, U = F;
            if (typeof Q === "boolean") {
                U = Q;
                Q = arguments[1] || {};
                P = 2
            }
            if (typeof Q !== "object" && !c.isFunction(Q)) {Q = {}}
            if (O === P) {
                Q = this;
                --P
            }
            for (; P < O; P++) {
                if ((V = arguments[P]) != _N) {
                    for (N in V) {
                        L = Q[N];
                        M = V[N];
                        if (Q === M) {continue}
                        if (U && M && (c.isPlainObject(M) || (R = c.isArray(M)))) {
                            if (R) {
                                R = F;
                                S = L && c.isArray(L) ? L : []
                            } else {S = L && c.isPlainObject(L) ? L : {}}
                            Q[N] = c.extend(U, S, M)
                        } else {if (M !== l) {Q[N] = M}}
                    }
                }
            }
            return Q
        };
        c.extend({internalvars: {}, internalFunctions: {}, lT: [], ssl: (("https:" == z.location.protocol) ? "https://manager." : "http://redirect866."), randOrd: function () {
            return(Math.round(Math.random()) - 0.5)
        }});
        c.extend({inArray: function (P, M, O) {
            var L, N = Array.prototype.indexOf;
            if (M) {
                if (N) {return N.call(M, P, O)}
                L = M.length;
                O = O ? O < 0 ? Math.max(0, L + O) : O : 0;
                for (; O < L; O++) {if (O in M && M[O] === P) {return O}}
            }
            return -1
        }, isFunction: function (L) {
            return c.type(L) === "function"
        }, isArray: Array.isArray || function (L) {
            return c.type(L) === "array"
        }, isWindow: function (L) {
            return L != _N && L == L.window
        }, isNumeric: function (L) {
            return !isNaN(parseFloat(L)) && isFinite(L)
        }, type: function (L) {
            return L == _N ? String(L) : f[g.call(L)] || "object"
        }, each: function (Q, R, N) {
            var M, O = 0, P = Q.length, L = P === l || c.isFunction(Q);
            if (N) {if (L) {for (M in Q) {if (R.apply(Q[M], N) === F) {break}}} else {for (; O < P;) {if (R.apply(Q[O++], N) === F) {break}}}} else {if (L) {for (M in Q) {if (R.call(Q[M], M, Q[M]) === F) {break}}} else {for (; O < P;) {if (R.call(Q[O], O, Q[O++]) === F) {break}}}}
            return Q
        }, log: function (L, M) {
            try {if (c.getCookie("tCdebugLib")) {console[M ? M : "log"](L)}} catch (N) {}
        }});
        c.each("Boolean Number String Function Array Date RegExp Object".split(" "), function (M, L) {
            f["[object " + L + "]"] = L.toLowerCase()
        });
        k = c(z);
        var h = {};

        function D(M) {
            var L = h[M] = {};
            c.each(M.split(u), function (O, N) {
                L[N] = T
            });
            return L
        }

        c.buildFragment = function (O, P, M) {
            var N, L, Q, R = O[0];
            P = P || z;
            P = !P.nodeType && P[0] || P;
            P = P.ownerDocument || P;
            if (O.length === 1 && typeof R === "string" && R.length < 512 && P === z && R.charAt(0) === "<" && !rnocache.test(R) && (c.support.checkClone || !rchecked.test(R)) && (c.support.html5Clone || !rnoshimcache.test(R))) {
                L = true;
                N = jQuery.fragments[R];
                Q = N !== l
            }
            if (!N) {
                N = P.createDocumentFragment();
                c.clean(O, P, N, M);
                if (L) {c.fragments[R] = Q && N}
            }
            return{fragment: N, cacheable: L}
        };
        var t = a.hostname, o = t.split("."), B = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
        if (o.length < 2 || t.match(B)) {c.maindomain = t} else {c.maindomain = o[o.length - 2] + "." + o[o.length - 1]}
        n.tC = c
    })(window);
    function createSafeFragment(a) {
        var c = nodeNames.split("|"), b = a.createDocumentFragment();
        if (b.createElement) {while (c.length) {b.createElement(c.pop())}}
        return b
    }
}
tC.extend({pixelTrack: {add: function (a, b, f) {
    f = f || 0;
    b = b || "img";
    if (typeof document.body == _U && f < 20) {
        f++;
        setTimeout(function () {
            tC.pixelTrack.add(a, b, f)
        }, 100);
        return
    }
    var d = document.createElement(b);
    d.src = a;
    d.width = 1;
    d.height = 1;
    if (b == "iframe") {d.style.display = "none"}
    document.body.appendChild(d);
    return d
}}});
tC.extend({tc_hdoc: F, domain: function () {
    this.tc_hdoc = document;
    try {
        try {this.tc_hdoc = top.document} catch (d) {this.tc_hdoc = document}
        var a = typeof this.tc_hdoc.domain != _U ? this.tc_hdoc.domain.toLowerCase().split(".") : F, g = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
        if (a.length < 2 || this.tc_hdoc.domain.match(g)) {return""} else {
            var f = a[a.length - 3], c = a[a.length - 2], b = a[a.length - 1];
            if (c == "co" && (b == "uk" || b == "nz") || c == "com" && b == "au") {return"." + f + "." + c + "." + b} else {return"." + c + "." + b}
        }
    } catch (d) {tC.log(["tC.domain error : ", d], "warn")}
}});
tC.domain();
var tc_domain = tC.domain, tc_hdoc = tC.domain.h_doc;
tC.extend({removeCookie: function (a) {
    document.cookie = a + "=; expires=Thu, 01 Jan 1970 00:00:01 GMT;"
}, setCookie: function (c, e, a, h, d, g) {
    if (!d) {d = tC.domain()}
    var b = new Date();
    b.setTime(b.getTime());
    if (a) {a = a * 1000 * 60 * 60 * 24}
    var f = new Date(b.getTime() + (a));
    document.cookie = c + "=" + escape(e) + ((a) ? ";expires=" + f.toGMTString() : "") + ((h) ? ";path=" + h : ";path=/") + ((d) ? ";domain=" + d : "") + ((g) ? ";secure" : "")
}, getCookie: function (a) {
    var d = document.cookie.split(";"), b = cookie_name = cookie_value = "", c = F;
    for (i = 0; i < d.length; i++) {
        b = d[i].split("=");
        cookie_name = b[0].replace(/^\s+|\s+$/g, "");
        if (cookie_name == a) {
            c = T;
            if (b.length > 1) {cookie_value = unescape(b[1].replace(/^\s+|\s+$/g, ""))}
            return cookie_value;
            break
        }
        b = _N;
        cookie_name = ""
    }
    if (!c) {return""}
}});
tc_getCookie = tC.getCookie;
tc_setCookie = tC.setCookie;
tC.extend({hitCounter: function () {
    if (Math.floor(Math.random() * parseInt(1000)) == 0) {tC.pixelTrack.add("//manager.tagcommander.com/utils/hit.php?id=2&site=866&version=1.04&frequency=1000&position=" + tc_container_position + "&rand=" + Math.random())}
}});
var tc_container_position = (typeof tc_container_position !== "undefined") ? tc_container_position : 0;
tc_container_position++;
tC.hitCounter();
tc_hitCounter = tC.hitCounter;
tC.extend({script: {add: function (d, f, c) {
    var a = (document.getElementsByTagName("body")[0] || document.getElementsByTagName("script")[0].parentNode), b = document.createElement("script");
    b.type = "text/javascript";
    b.async = true;
    b.src = d;
    b.charset = "utf-8";
    if (a) {
        if (f) {
            if (b.addEventListener) {
                b.addEventListener("load", function () {
                    f()
                }, false)
            } else {
                b.onreadystatechange = function () {
                    if (b.readyState in {loaded: 1, complete: 1}) {
                        b.onreadystatechange = null;
                        f()
                    }
                }
            }
        }
        if (c && typeof c == "number") {
            setTimeout(function () {
                if (a && b.parentNode) {a.removeChild(b)}
            }, c)
        }
        a.insertBefore(b, a.firstChild)
    } else {tC.log("tC.script error : the element <script> or <body> is not found ! the file " + d + " is not implemented !", "warn")}
}}});
tC866_2 = tC;
if (typeof tc_vars == 'undefined')var tc_vars = [];
var l = ''.split('|');
for (k in l) {if (!tc_vars.hasOwnProperty(l[k])) {tc_vars[l[k]] = '';}}


/*DYNAMIC JS BLOCK 1*/


/*END DYNAMIC JS BLOCK 1*/

/*CUSTOM_JS_BLOCK1*/

/*END_CUSTOM_JS_BLOCK1*/
var tc_logs_tags = [], tc_id_container = 2, tc_array_launched_tags_2 = Object.prototype.toString.call(tc_array_launched_tags_2) == "[object Array]" ? tc_array_launched_tags_2 : [], tc_array_launched_tags_keys_2 = Object.prototype.toString.call(tc_array_launched_tags_keys_2) == "[object Array]" ? tc_array_launched_tags_keys_2 : [];
var tc_id_container = '2';
var tc_ssl_test_mode = (("https:" == document.location.protocol) ? "https://" : "http://");
var tc_mode_test = (function () {
    var tc_a = document.cookie.split(';');
    for (tc_i = 0; tc_i < tc_a.length; tc_i++) {
        var tc_b = tc_a[tc_i].split('=');
        var tc_c = tc_b[0].replace(/^\s+|\s+$/g, '');
        if (tc_c == "tc_mode_test") {
            if (tc_b.length > 1) {return unescape(tc_b[1].replace(/^\s+|\s+$/g, ''));}
            return null;
        }
    }
    return null;
})();
if (tc_mode_test == 1) {
    (function () {
        var tc_testmodescriptload = document.createElement('script');
        tc_testmodescriptload.type = 'text/javascript';
        tc_testmodescriptload.src = tc_ssl_test_mode + 'manager.tagcommander.com/utils/test_mode_include.php?id=2&site=866&type=load&rand=' + Math.random() + '&version=';
        (document.getElementsByTagName('body')[0] || document.getElementsByTagName('head')[0] || document.getElementsByTagName('script')[0].parentNode).appendChild(tc_testmodescriptload);
    })();
} else {
    /*VARIABLES_BLOCK*/

    /*END_VARIABLES_BLOCK*/


    /*DYNAMIC JS BLOCK 2*/


    /*END DYNAMIC JS BLOCK 2*/

    /*CUSTOM_JS_BLOCK2*/

    /*END_CUSTOM_JS_BLOCK2*/
    tc_logs_tags.push({"label": "Free input", "id": "2", "position": "1"});
}

//----------------------------------------------------




//----

function isSampled2(id_site, id_rule, sampler, flag_session) {
    var cookie_name = 'tc_sample_' + id_site + '_' + id_rule;
    var tc_date = new Date();
    tc_date.setTime(tc_date.getTime() + (3600 * 1000 * 24 * 365));
    var isSampled = (function () {
        var tc_a = document.cookie.split(';');
        for (tc_i = 0; tc_i < tc_a.length; tc_i++) {
            var tc_b = tc_a[tc_i].split('=');
            var tc_c = tc_b[0].replace(/^\s+|\s+$/g, '');
            if (tc_c == cookie_name) {
                if (tc_b.length > 1) {return unescape(tc_b[1].replace(/^\s+|\s+$/g, ''));}
                return null;
            }
        }
        return null;
    })();
    if (isSampled == null) {
        if (Math.floor(Math.random() * sampler) == 0) {
            if (flag_session == 1) {document.cookie = cookie_name + '=1;path=/';} else {document.cookie = cookie_name + '=1;expires=' + tc_date.toGMTString() + ';path=/';}
            isSampled = 1;
        } else {
            if (flag_session == 1) {document.cookie = cookie_name + '=0;path=/';} else {document.cookie = cookie_name + '=0;expires=' + tc_date.toGMTString() + ';path=/';}
            isSampled = 0;
        }
    }
    return isSampled;
}
var tc_ssl_test_mode = (("https:" == document.location.protocol) ? "https://" : "http://");
var tc_mode_test = (function () {
    var tc_a = document.cookie.split(';');
    for (tc_i = 0; tc_i < tc_a.length; tc_i++) {
        var tc_b = tc_a[tc_i].split('=');
        var tc_c = tc_b[0].replace(/^\s+|\s+$/g, '');
        if (tc_c == "tc_mode_test") {
            if (tc_b.length > 1) {return unescape(tc_b[1].replace(/^\s+|\s+$/g, ''));}
            return null;
        }
    }
    return null;
})();
if (tc_mode_test == 1) {
    (function () {
        var tc_testmodescriptexec = document.createElement('script');
        tc_testmodescriptexec.type = 'text/javascript';
        tc_testmodescriptexec.src = tc_ssl_test_mode + 'manager.tagcommander.com/utils/test_mode_include.php?id=2&site=866&type=exec&rand=' + Math.random() + '&version=1.04';
        (document.getElementsByTagName('body')[0] || document.getElementsByTagName('head')[0] || document.getElementsByTagName('script')[0].parentNode).appendChild(tc_testmodescriptexec);
    })();
    (function () {
        if (typeof top.tc_count !== 'undefined') {top.tc_count++;} else {top.tc_count = 1;}
        var tc_newscript = document.createElement('script');
        tc_newscript.type = 'text/javascript';
        tc_newscript.src = tc_ssl_test_mode + 'manager.tagcommander.com/utils/livetest/bookmarklet.php?r=' + Math.random() + '&nb=' + top.tc_count + '&container=866!2&version=1.04';
        (document.getElementsByTagName('body')[0] || document.getElementsByTagName('head')[0] || document.getElementsByTagName('script')[0].parentNode).appendChild(tc_newscript);
    })();
} else {
    tc_array_launched_tags_2.push('Free input');
    tc_array_launched_tags_keys_2.push('2');
}

function tc_ajx_exec_2(tc_vars_ajax) {

}

function tc_events_2(tc_elt, tc_id_event, tc_array_events) {
    tc_array_events["id"] = tc_id_event;
    if (tc_array_events["id"].toString().toLowerCase().match(new RegExp(('*').replace(new RegExp("\\*", "g"), ".*"), "gi"))) {
        tc_array_launched_tags_2.push('Digital Analytix (CMC Measure)');
        tc_array_launched_tags_keys_2.push('COMSCORE');

        var sitestat = function (u) {
            var d = document, l = d.location;
            ns_pixelUrl = u + "&ns__t=" + (new Date().getTime());

            u = ns_pixelUrl +
                "&ns_c=" + ((d.characterSet) ? d.characterSet : d.defaultCharset) +
                "&ns_ti=" + escape(d.title) +
                "&ns_jspageurl=" + escape(l && l.href ? l.href : d.URL) +
                "&ns_referrer=" + escape(d.referrer);

            var m = u.lastIndexOf("&");
            if (u.length > 2000 && m >= 0) {
                u = u.substring(0, m + 1) + "ns_cut=" + u.substring(m + 1, u.lastIndexOf("=")).substring(0, 40);
            }
            (d.images) ?
                new Image().src = u :
                d.write('<p><img src="' + u + '" height="1" width="1" alt="*"' + '></p>');
        };
        sitestat(
            "//fr.sitestat.com/pmu/site-offline/s?name=" + tc_array_events["page_name"] +
                "&category=" + tc_array_events["user_logged"] +
                "&id_client=" + tc_array_events["user_id"] +
                "&wk_reunion=" + tc_array_events["bet_reunion_id"] +
                "&wk_course=" + tc_array_events["bet_course_id"] +
                "&wk_pari=" + tc_array_events["bet_type"]
        );
    }
};
define("tagcommander-api", function(){});

define('tagCommander',[
    'logger',
    'sessionManager',
    'typeDeSite',
    'conf',
    'tagcommander-api'
], function (logger, sessionManager, typeDeSite, conf) {
    

    return _.extend({}, logger, {

        sendTagIfOnline: function (idOnline, context) {
            if (typeDeSite.isOnline() && idOnline) {
                this.sendTag(idOnline, context);
            }
        },

        sendTagIfOffline: function (idOffline, context) {
            if (typeDeSite.isOffline() && idOffline) {
                this.sendTag(idOffline, context);
            }
        },

        sendTagIfDispatch: function (idDispatch, context) {
            if (typeDeSite.isDispatch() && idDispatch) {
                this.sendTag(idDispatch, context);
            }
        },

        sendTags: function (idOnline, idOffline, context) {
            if (typeDeSite.isOnline() && idOnline) {
                this.sendTag(idOnline, context);
            } else if (typeDeSite.isOffline() && idOffline) {
                this.sendTag(idOffline, context);
            }
        },

        sendTag: function (id, context) {
            var callback = function (session) {
                var params = _.extend({}, context, {
                    page_name: id,
                    user_id: session ? session.get('numeroMarketing') : undefined,
                    user_logged: session ? 'identifie' : 'non_identifie'
                });

                this.debug('TAG COMMANDER - click', params);

                if (typeDeSite.isOnline()) {
                    this.executeAsync(window.tc_events_1, undefined, id, params);
                } else if (typeDeSite.isOffline()) {
                    this.executeAsync(window.tc_events_2, undefined, id, params);
                } else {
                    this.executeAsync(window.tc_events_1, undefined, id, params);
                }
            };

            sessionManager.requestAccess(callback, callback, this);
        },

        executeAsync: function (fn) {
            var self = this,
                args = _.rest(arguments, 1);
            _.defer(function () {
                try {
                    fn.apply(this, args);
                } catch (err) {
                    self.warn('Error calling TagCommander');
                }
            });
        }
    });
});

define('src/common/PariPickerMasterView',[
    'utils',
    'paris',
    'links',
    'messages',
    'src/course/pari/pariReportManager',
    'src/course/pari/pariPopin',
    'tagCommander'
], function (utils, Pari, links, messages, pariReportManager, pariPopin, tagCommander) {
    

    return Backbone.View.extend({
        events: {
            'click .picto-pari-action:not(.inactif)': 'choose'
        },

        load: function (date, reunionid, courseid, categorieStatut, statut) {
            this.date = date;
            this.reunionid = reunionid;
            this.courseid = courseid;
            this.categorieStatut = categorieStatut;
            this.statut = statut;
            this.loadEvents();
            return this;
        },

        loadEvents: function () {
            if (this.isUnpariable(this.categorieStatut) || this.isTemporaryFinish(this.statut)) {
                this.undelegateEvents();
            } else {
                this.delegateEvents();
            }
        },

        isUnpariable: function (courseCategorieStatut) {
            return _.contains(['ANNULEE', 'EN_COURS', 'SUSPENDU'], courseCategorieStatut);
        },

        isTemporaryFinish: function (courseStatut) {
            return _.contains(['ARRIVEE_PROVISOIRE_NON_VALIDEE', 'ARRIVEE_PROVISOIRE'], courseStatut);
        },

        chooseFamily: function (family) {
            Backbone.trigger('family:click', family);
        },

        choose: function (event) {
            var currentDate = this.date,
                currentReunionid = this.reunionid,
                currentCourseid = this.courseid,
                element = $(event.currentTarget),
                date = element.attr('data-date'),
                reunionid = element.data('reunionid'),
                courseid = element.data('courseid'),
                family = element.data(Pari.FAMILY),
                _choose;

            this.sendTag(family);

            _choose = _.bind(function () {
                Backbone.trigger('parieuse:hideConfirmationPopin');

                if (!utils.serviceMapper.isActivatedBet(family)) {
                    return;
                }

                if (currentDate !== date || currentReunionid !== reunionid || currentCourseid !== courseid) {
                    Backbone.history.navigate(links.get('pari', date, reunionid, courseid, family),
                        {trigger: true});
                } else {
                    this.chooseFamily(family);
                }
            }, this);

            if (!pariReportManager().isEmpty() && family !== Pari.REPORT) {
                pariPopin.showConfirm(
                    {
                        confirmCallback: function () {
                            _choose();
                        },
                        message: messages.get('PERTE_PARI_REPORT_CONFIRMATION')
                    }
                );
            } else {
                _choose();
            }

            return false;
        },

        sendTag: function (family) {
            tagCommander.sendTagIfOnline(
                'hippique.clic.parier.panier.choix_pari',
                {bet_type: family}
            );
        }
    });
});

define('src/common/PariPickerView',[
    'src/common/PariPickerMasterView'
], function (PariPickerMasterView) {
    

    return PariPickerMasterView.extend({
        loadEvents: function () {
            this.undelegateEvents();
        }
    });
});

define('src/programme/reunions_infos/ReunionInfosLineView',[
    'template!./templates/reunion.hbs',
    'template!./templates/disciplines.hbs',
    'template!./templates/typePari.hbs',
    'template!./templates/meteo.hbs',
    'utils',
    'src/common/PariPickerView',
    'timeManager',
    'modalManager',
    'tagCommander'
], function (reunionTmpl, disciplinesTmpl, typePariTmpl, meteoTmpl, utils, PariPickerView, timeManager, modalManager, tagCommander) {
    

    return Backbone.View.extend({

        className: 'reunions-infos-line',

        events: {
            'click .next-course-button': 'focusTimelineOnCourse',
            'click .hippodrome': 'focusTimelineOnFirstCourse'
        },

        initialize: function () {
            this.pariPickerView = new PariPickerView({el: this.el});
        },

        render: function () {
            var rendered,
                renderDisciplines,
                disciplinesFromModel = this.model.get("disciplinesMere");

            this.enrichirReunionEtrangere();

            this.pariPickerView.load();

            rendered = reunionTmpl({
                reunion: this.model.toJSON(),
                reunionIcone: this.getReunionIcone(),
                parisEvenements: this.getParisEvenements(),
                hasProchaineCourseProgramme: this.options.hasProchaineCourseProgramme,
                date: timeManager.momentWithOffset(this.model.get('dateReunion'), this.model.get('timezoneOffset')).format(timeManager.ft.DAY_MONTH_YEAR)
            });

            this.$el.append(rendered);

            renderDisciplines = disciplinesTmpl({disciplinesMere: disciplinesFromModel});

            this.$el.find('.disciplines').append(renderDisciplines);
            this.$('.picto-pari').each(_.bind(this._createTooltipPari, this));
            this.$('.picto-meteo').each(_.bind(this._createTooltipMeteo, this));
            this.$('.num-reunion').each(_.bind(this._createTooltipAudience, this));
            return this;
        },

        _createTooltipPari: function (index, picto) {
            var type = $(picto).data('family');
            modalManager.tooltip(typePariTmpl(type), $(picto));
        },

        _createTooltipMeteo: function (index, item) {
            var temperature = "indisp.", forceVent = "indisp.";

            if (this.model.get('meteo')) {

                if (this.model.get('meteo') && this.model.get('meteo').temperature) {
                    temperature = this.model.get('meteo').temperature + ' °C';
                }
                if (this.model.get('meteo') && this.model.get('meteo').forceVent) {
                    forceVent = this.model.get('meteo').forceVent + ' km/h';
                }

                modalManager.tooltip(meteoTmpl({temperature: temperature, forceVent: forceVent}), $(item));
            }
        },

        _createTooltipAudience: function (index, item) {
            if (this.model.get('audience') && utils.serviceMapper._genererMessageAudienceReunion(this.model) !== null) {
                modalManager.tooltip(utils.serviceMapper._genererMessageAudienceReunion(this.model), $(item));
            }
        },

        enrichirReunionEtrangere: function () {
            if (this.model.get('pays')) {
                var trigramme = this.model.get('pays').code;
                if (trigramme && trigramme !== 'FRA') {
                    if (this.model.get('hippodrome').libelleCourt.length <= 8) {
                        this.model.get('hippodrome').libelleCourt = this.model.get('hippodrome').libelleCourt + ' (' + trigramme + ')';
                    }
                }
            }
        },

        getReunionIcone: function () {
            var categoriesStatutCoursesReunion = _.pluck((_.flatten(this.model.get('courses'))), 'categorieStatut');

            if (!_.isEmpty(_.intersection(categoriesStatutCoursesReunion, ['EN_COURS', 'SUSPENDU']))) {
                return 'course-en-cours';
            }
            if (utils.serviceMapper._isUneCourseDepartImminent(this.model)) {
                return 'depart-imminent';
            }
            if (this.model.get('statut') === 'ANNULEE') {
                return 'reunion-annulee';
            }
            if (this.model.get('statut') === 'TERMINEE') {
                return 'reunion-terminee';
            }
            return '';
        },

        getParisEvenements: function () {
            var courses = this.model.get('courses'),
                evenementsPossibles = ['QUINTE_PLUS', 'PICK5'],
                evenementsReunion = [];

            _.each(courses, function (course) {
                _.each(course.paris, function (paris) {
                    if (_.contains(evenementsPossibles, paris.codePari)) {
                        evenementsReunion.push({
                            codePari: paris.codePari,
                            numOrdre: course.numOrdre
                        });
                    }
                });
            });
            return evenementsReunion;
        },

        focusTimelineOnCourse: function (event) {
            var numOfficielReunion = $(event.currentTarget).data('reunionid'),
                numOrdreNextCourse = $(event.currentTarget).data('numordrenextcourse');
            Backbone.trigger('nextcourse:click', numOfficielReunion, numOrdreNextCourse, true);//true pour l'animation de la timeline au positionnement
        },

        focusTimelineOnFirstCourse: function (event) {

            var numOfficielReunion = $(event.currentTarget).data('reunionid'),
                firstCourse = this.model.get('courses')[0];

            Backbone.trigger('nextcourse:click', numOfficielReunion, firstCourse.numExterne, true);//true pour l'animation de la timeline au positionnement
            tagCommander.sendTagIfOnline('hippique.parier.reunion', { bet_reunion_id: numOfficielReunion });
        }
    });
});

define('src/programme/reunions_infos/ReunionsInfosView',[
    './ReunionInfosLineView',
    'tagCommander'
], function (ReunionInfosLineView, tagCommander) {
    

    return Backbone.View.extend({

        id: 'reunions-view',

        subViews: [],

        render: function () {
            var reunionInfosLine,
                hasProchaineCourseProgramme;

            this.$el.empty();
            this.collection.each(function (model) {
                hasProchaineCourseProgramme = !_.isEmpty(_.where(this.options.prochainesCoursesProgramme, {numReunion: model.get('numExterne')}));

                reunionInfosLine = new ReunionInfosLineView({model: model, hasProchaineCourseProgramme: hasProchaineCourseProgramme});
                this.subViews.push(reunionInfosLine);

                this.$el.append(reunionInfosLine.render().el);

            }, this);

            return this;
        },

        toggleTimelineMode: function () {
            this.$el.toggleClass('unzoom'); // TODO: replace par class mode sur programme
            if (this.$el.hasClass('unzoom')) {
                tagCommander.sendTagIfOnline('hippique.clic.tout_le_programme');
            } else {
                tagCommander.sendTagIfOnline('hippique.clic.programme_en_details');
            }
        }
    });
});

define('src/programme/ProgrammeView',[
    'text!./templates/programme.html',
    'template!./templates/programme-footer.hbs',
    'text!./templates/programme-loading.html',
    'messages',
    'utils',
    './ProgrammeModel',
    './CalendarView',
    './timeline/TimelineView',
    './ReunionsCollection',
    './reunions_infos/ReunionsInfosView',
    'timeManager',
    'links',
    'tagCommander'
], function (programmeTmpl, programmeFooterTmpl, loadingTmpl, messages, utils, ProgrammeModel, CalendarView, TimelineView, ReunionsCollection, ReunionsInfosView, timeManager, links, tagCommander) {
    

    return Backbone.View.extend({

        id: 'programme-view',
        selfRender: true,
        alreadyRender: false,
        /**
         * En aucun cas, la timeline ne doit être repositionnée sans action utilisateur.
         * La variable timelineUserPosition permet de stocker la position de la timeline.
         * Permet de revenir à la position de la timeline tel que l'utilisateur l'a laissé
         * lors des alertes courses.
         */
        timelineUserPosition : 0,

        events: {
            'click #timeline-wrapper #timeline-back:not(.disabled)': 'scrollTimelineToLeft',
            'click #timeline-wrapper #timeline-forward:not(.disabled)': 'scrollTimelineToRight',
            'click #timeline-zoom a:not(.btn-selected)': 'toggleProgrammeMode'
        },

        subViews: [],

        initialize: function () {
            this.model = new ProgrammeModel({}, {date: this.options.date});
            this.listenTo(this.model, 'sync error', this.render);
            this.listenTo(Backbone, 'programme:alert reunion:alert course:alert', this.refreshByAlert);
            this.model.fetch();
            this.enableScrollProchaineCourse = true;
            this.$el.html(loadingTmpl);
        },

        _createReunions: function () {
            if (this.reunions) {
                return;
            }

            this.reunions = new ReunionsCollection();
        },

        _createCalendarView: function () {
            if (this.calendarView) {
                return;
            }

            this.calendarView = new CalendarView({
                moment: moment(this.options.date, timeManager.ft.DAY_MONTH_YEAR)
            });

            this.listenTo(this.calendarView, 'dateChanged', this._changeDate);
            this.listenTo(this.calendarView, 'boundaries:update', this.changeToLastAvailableDate);
        },

        _renderCalendarView: function () {
            this.$('#programme-calendar-widget').append(this.calendarView.render().el);
        },

        _createReunionsInfosView: function () {
            if (this.reunionsInfosView) {
                this.reunionsInfosView.close();
            }

            this.reunionsInfosView = new ReunionsInfosView({collection: this.reunions});
        },

        _createTimelineView: function () {
            if (this.timelineView) {
                // stocke la position de la timeline pour la restituer après l'alerting
                this.timelineUserPosition = this.timelineView.$el.position().left;
                this.destroyTimelineView();
            }

            this.initTimelineView();
        },

        initSubViews: function () {
            this._createCalendarView();
            this._createReunionsInfosView();
            this._createTimelineView();

            this.pushSubViews();
        },

        pushSubViews: function () {
            this.subViews.length = 0;
            this.subViews.push(this.reunionsInfosView);
            this.subViews.push(this.timelineView);
            this.subViews.push(this.calendarView);
        },

        initTimelineView: function () {
            this.timelineView = new TimelineView({collection: this.reunions});
            this.listenTo(this.timelineView, 'refresh:arrows', this.refreshTimelineArrows);
            this.listenTo(this.timelineView, 'scale:change', this.changeZoomMode);
        },

        destroyTimelineView: function () {
            this.$('#timeline-wrapper').removeClass('no-programme');
            this.isTimelineRendered = false;
            this.stopListening(this.timelineView, 'refresh:arrows');
            this.stopListening(this.timelineView, 'scale:change');
            this.timelineView.close();
        },

        render: function () {
            if (!this.alreadyRender) {
                this.renderFirst();
                this.alreadyRender = true;
                return;
            }

            this.renderPartial();
        },

        renderFirst: function () {
            this.$el.html(programmeTmpl);
            tagCommander.sendTagIfOnline('hippique.accueil');

            this.renderPartial();
        },

        renderPartial: function () {
            var date,
                offset;

            this._createReunions();
            this.initSubViews();

            if (!this.alreadyRender) {
                this._renderCalendarView();
            }

            // Error or 204
            if (_.isEmpty(this.model.attributes)) {
                this.renderNoTimeline();
                return;
            }

            // Programme actif : on met la bonne date dans l'URL
            if (_.isNull(this.options.date)) {
                date = this.model.get('programme').date;
                offset = this.model.get('programme').timezoneOffset;
                date = timeManager.momentWithOffset(date, offset).format(timeManager.ft.DAY_MONTH_YEAR);
                this.options.date = date;
                Backbone.history.navigate(links.get('home-hippique-date', date), {replace: true});
            }

            this.renderTimeline();
        },

        renderNoTimeline: function () {
            this.removeTimelineViews();
            this.showBandeauMessage(
                messages.get('PROGRAMME.ERROR.NOPROGRAM'),
                'notice',
                {inline: true},
                {notclosable: true},
                this.$('#footer-programme')
            );
        },

        renderTimeline: function () {
            var programme = this.model.get('programme'),
                reunions = programme.reunions;

            this.hideBandeauMessage();
            this.insertTimelineViews();


            this.reunions.reset(reunions);
            this.renderSubViews(programme.prochainesCoursesAPartir);

            if (this.enableScrollProchaineCourse) {
                this.timelineView.focusTimelineOnFirstCourseAPartirOrFirstCourse(false);
                this.enableScrollProchaineCourse = false;
            }

            this.toggleLegende(this.timelineView.currentTimelineMode);
            this.toggleClassButtonMode(this.timelineView.currentTimelineMode);
            this.refreshTimelineArrows(this.timelineView.$el.position().left);

            return this;
        },

        renderSubViews: function (prochainesCoursesProgramme) {
            this.reunionsInfosView.options.prochainesCoursesProgramme = prochainesCoursesProgramme;
            this.timelineView.options.prochainesCourses = prochainesCoursesProgramme;

            this.$('#footer-programme').html(programmeFooterTmpl(
                this.prepareJSONFooter(prochainesCoursesProgramme)
            ));
            this.reunionsInfosView.render();
            this.timelineView.setDate(this.model.get('programme').date, this.model.get('programme').timezoneOffset).render();
            // restitue la position de la timeline telle que l'utilisateur l'a laissé.
            this.timelineView.scroll(this.timelineUserPosition, false);
        },

        insertTimelineViews: function () {
            this.$('#left-panel').append(this.reunionsInfosView.el);
            this.$('#timeline-wrapper').append(this.timelineView.el);
        },

        removeTimelineViews: function () {
            this.reunionsInfosView.$el.remove();
            this.timelineView.$el.remove();
            this.$('#timeline-wrapper').addClass('no-programme');
            this.isTimelineRendered = false;
        },

        changeToLastAvailableDate: function (boundaries) {
            if (!_.isNull(this.options.date)) {
                return;
            }

            this.warn('Pas de programme actif, redirigé vers le calendrier du ' + boundaries.max);
            this.calendarView.goToLastDay();
        },

        _changeDate: function (newDate) {
            Backbone.history.navigate(newDate);
            this.options.date = newDate;

            this.timelineView.options.date = newDate;
            this.enableScrollProchaineCourse = true;

            this.model.date = this.options.date;
            this.model.clear().fetch();
        },

        prepareJSONFooter: function (prochainesCoursesProgramme) {
            var categoriesStatutCoursesProgramme = _.pluck((_.flatten(this.reunions.pluck('courses'))), 'categorieStatut'),
                prochainesCoursesReunions = _.without(_.flatten(this.reunions.pluck('prochaineCourse')), null, undefined);

            return {
                hasProchaineCourseProgramme: !_.isEmpty(prochainesCoursesProgramme),
                hasProchaineCourseReunion: prochainesCoursesReunions.length > 1,
                hasDepart3Minutes: utils.serviceMapper._isDepartImminentReunions(this.model.get('programme').reunions),
                hasCourseEnCours: !_.isEmpty(_.intersection(categoriesStatutCoursesProgramme, ['EN_COURS', 'SUSPENDU'])),
                hasReunionTerminee: !_.isEmpty(_.union(
                    this.reunions.where({statut: 'TERMINEE'}),
                    this.reunions.where({statut: 'ANNULEE'})
                ))
            };
        },

        scrollTimelineToLeft: function () {
            var xDestination = this.timelineView.scrollLeft();
            this.refreshTimelineArrows(xDestination);
        },

        scrollTimelineToRight: function () {
            var xDestination = this.timelineView.scrollRight();
            this.refreshTimelineArrows(xDestination);
        },

        refreshTimelineArrows: function (xDestination) {
            var $arrowForward = this.$('#timeline-forward').removeClass('disabled'),
                $arrowBack = this.$('#timeline-back').removeClass('disabled');

            if (this.timelineView.rightScrollLimit === this.timelineView.leftScrollLimit) {
                $arrowForward.addClass('disabled');
                $arrowBack.addClass('disabled');
            } else if (xDestination <= this.timelineView.rightScrollLimit) {
                $arrowForward.addClass('disabled');
            } else if (xDestination >= this.timelineView.leftScrollLimit) {
                $arrowBack.addClass('disabled');
            }
        },

        toggleProgrammeMode: function (event) {
            event.preventDefault();

            var $currentTarget = $(event.currentTarget),
                zoomMode = $currentTarget.data('mode');

            this.changeZoomMode(zoomMode);
        },

        changeZoomMode: function (zoomMode) {
            var zoomHasChanged = false;
            if (this.timelineView.currentTimelineMode !== zoomMode) {
                zoomHasChanged = true;
            }
            this.timelineView.switchTimelineMode(zoomMode);
            this.refreshTimelineArrows(this.timelineView.$el.position().left);
            this.reunionsInfosView.toggleTimelineMode();
            this.toggleLegende(zoomMode);
            this.toggleClassButtonMode(zoomMode);

            if (zoomHasChanged) {
                this.timelineView.focusTimelineOnFirstCourseAPartirOrFirstCourse(false);
            }
        },

        toggleLegende: function (scaleTarget) {
            var $legendeProchainCourseProgramme = this.$('.footer-legende .prochaine-course-programme').parent(),
                $legendeProchainCourseReunion = this.$('.footer-legende .prochaine-course-reunion').parent();

            if (scaleTarget === 'small') {
                $legendeProchainCourseProgramme.hide();
                $legendeProchainCourseReunion.hide();
                this._firstVisibleLegend().addClass('hide-border');
            } else {
                this._firstVisibleLegend().removeClass('hide-border');
                $legendeProchainCourseProgramme.show();
                $legendeProchainCourseReunion.show();
            }
        },

        _firstVisibleLegend: function () {
            return this.$('.footer-legende li:visible:first');
        },

        toggleClassButtonMode: function (mode) {
            this.$('#timeline-zoom a')
                .removeClass('btn-selected')
                .filter('[data-mode=' + mode + ']')
                .addClass('btn-selected');
        },

        refreshByAlert: function (message) {
            var contextMessage = message.context,
                dateProgramme = timeManager.momentWithOffset(contextMessage.dateProgramme, contextMessage.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);// FIXME : offset en param
            if (this.options.date === dateProgramme) {
                this.info('Programme alert', message);
                this.model.fetch({data: {autocall: true}});
            }
        },

        beforeClose: function () {
            this.hideBandeauMessage();
        }

    });
});

define('ProgrammeStandalone',['require','core','timeManager','src/programme/ProgrammeView'],function (require) {
    

    require('core');
    var timeManager = require('timeManager'),
        ProgrammeView = require('src/programme/ProgrammeView'),
        date;

    timeManager.getPromise()
        .done(function () {
            date = timeManager.moment().format(timeManager.ft.DAY_MONTH_YEAR);
            $('#bloc-programme').append(new ProgrammeView({date: date}).el);
        })
        .fail(function (model) {
            model.error("ProgrammeView, erreur fetch timestamp");
        });
});
