
define('text!src/session/templates/profil-menu.hbs',[],function () { return '{{#each menus}}\n    <li><a href="{{ this }}">{{ @key }}</a></li>\n{{/each}}\n<li><a id="logout-button">Me déconnecter</a></li>\n';});

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

define('src/session/ProfilMenu',['template!./templates/profil-menu.hbs', 'messages', 'sessionManager'], function (profilMenuTmpl, messages, sessionManager) {
    

    return Backbone.View.extend({
        tagName: 'ul',
        className: 'profil-menu',

        events: {
            'click #logout-button': 'logout'
        },

        initialize: function () {
            this.template = profilMenuTmpl;
            this.menus = { menus: this.options.menus};
            this.hide();
        },

        render: function () {
            this.$el.html(this.template(this.menus));
            return this;
        },

        firstMenuUrl: function () {
            return _.values(this.menus.menus)[0];
        },

        show: function () {
            this.$el.show();
            $('#box-profil').addClass('open');
            this.visible = true;

            this.closeOnDocumentClick();
        },

        closeOnDocumentClick: function () {
            $(document).one('click', _.bind(this.hide, this));
        },

        hide: function () {
            this.$el.hide();
            $('#box-profil').removeClass('open');
            this.visible = false;
            $(document).off('click', _.bind(this.hide, this));
        },

        isVisible: function () {
            return this.visible;
        },

        logout: function () {
            this.model.destroy({
                error: _.bind(this.onLogoutError, this)
            });
        },

        onLogoutError: function (model, response) {
            var message;

            if (response.status === 420) {
                message = messages.getErrorService(JSON.parse(response.responseText));
            } else {
                message = messages.get('LOGOUT.ERROR.TECHNIQUE');
            }

            Backbone.trigger('menu:error', message);
        }
    });
});

define('text!src/session/templates/profil.hbs',[],function () { return '<div class="mon-profil">\n    <div id="box-profil">\n        <a {{#if boxHref }}href="{{ boxHref }}"{{/if}} class="account-name">\n            {{#if user.isTruncate }}\n                <span class="two-lines">\n                    <span>{{ user.checkedFirstName }}</span>\n                    <span>{{ user.checkedLastName }}</span>\n                </span>\n            {{else}}\n                <span class="one-line">{{ user.prenom }} {{ user.nom }}</span>\n            {{/if}}\n        </a>\n        <div class="nav-button"></div>\n    </div>\n    <div id="menu-profil"></div>\n    <span class="help"> </span>\n</div>\n<div class="mon-solde">\n    {{#if displaySolde }}\n    <span class="solde-comptable">{{ formatMoney user.soldeDisponiblePari }}</span>\n    <span class="texte">{{ message }} :</span>\n    {{/if}}\n</div>\n';});

//TODO: externaliser les chaines affichées dans les dialog lors des US de traitement des erreurs
define('src/session/ProfilView',[
    './ProfilMenu',
    'template!./templates/profil.hbs',
    'messages'
], function (ProfilMenu, profilMenuTmpl, messages) {
    

    return Backbone.View.extend({

        id: 'profil-view',

        compiledProfilMenuTmpl: profilMenuTmpl,

        events: {
            'mouseover .account-name': 'showMenu',
            'mouseleave .account-name': 'hideMenu',
            'mouseover ul': 'showMenu',
            'mouseleave ul': 'hideMenu',
            'click .nav-button': 'toggleMenu'
        },

        initialize: function () {
            this.menuView = new ProfilMenu({model: this.model, menus: this.options.menus});
        },

        checkNameSize: function () {

            var prenomFromModel = this.model.get('prenom'),
                nomFromModel = this.model.get('nom'),
                checkedFirstName,
                checkedLastName,
                isTruncate = false,
                firstNames,
                lastNames,
                lastNamesLength;

            if (prenomFromModel.length > 23) {
                isTruncate = true;
                prenomFromModel = _.str.truncate(prenomFromModel, 20);
                if (_.str.include(prenomFromModel, ' ')) {
                    firstNames = _.str.words(prenomFromModel);

                    if (_.first(firstNames).length > 23) {
                        prenomFromModel = _.str.truncate(_.first(firstNames), 20);
                        nomFromModel = _.str.join(' ', _.str.strRight(prenomFromModel, ' '), nomFromModel);
                    } else {
                        checkedFirstName = _.str.truncate(prenomFromModel, 20);
                    }
                }
                checkedLastName = _.str.truncate(nomFromModel, 20);
            } else {
                checkedFirstName = prenomFromModel;
            }

            if (checkedFirstName.length + nomFromModel.length > 23) {
                isTruncate = true;
                if (_.str.include(nomFromModel, ' ')) {
                    lastNames = _.str.words(nomFromModel);
                    lastNamesLength = lastNames.toString().length;

                    while (lastNamesLength > 22) {
                        lastNames.pop();
                        lastNamesLength = lastNames.toString().length;
                        if (lastNames.length === 1) {
                            nomFromModel = _.str.truncate(lastNames[0], 22 - checkedFirstName.length);
                            break;
                        }
                        nomFromModel = lastNames.join(' ');
                    }
                    checkedLastName = nomFromModel;
                } else {
                    checkedLastName = _.str.truncate(nomFromModel, 20);
                }
            } else {
                checkedLastName = nomFromModel;
            }
            this.prepareJSON(checkedFirstName, checkedLastName, isTruncate);
        },

        prepareJSON: function (checkedFirstName, checkedLastName, isTruncate) {
            this.userJSON = this.model.toJSON();
            this.userJSON.checkedLastName = checkedLastName;
            this.userJSON.checkedFirstName = checkedFirstName;
            this.userJSON.isTruncate = isTruncate;
        },

        render: function () {
            this.checkNameSize();
            var user = this.userJSON,
                rendered;

            user.checkedFirstName = _.str.titleize(user.checkedFirstName.toLowerCase());
            user.prenom = _.str.titleize(user.prenom.toLowerCase());

            rendered = this.compiledProfilMenuTmpl({
                user: this.userJSON,
                message: messages.get('SOLDE'),
                displaySolde: this.options.displaySolde,
                boxHref: this.menuView.firstMenuUrl()
            });
            this.$el.html(rendered);
            this.$("#menu-profil").html(this.menuView.render().el);
            return this;
        },

        showMenu: function () {
            this.menuView.show();
        },

        hideMenu: function () {
            this.menuView.hide();
        },

        toggleMenu: function (event) {
            event.stopPropagation();

            if (this.menuView.isVisible()) {
                this.menuView.hide();
            } else {
                this.menuView.show();
            }
        }
    });
});

define('src/session/PinpadFormModel',['messages', 'timeManager'], function (messages, timeManager) {
    

    return Backbone.Model.extend({

        initialize: function () {
            this.on('change:day change:month change:year', this.changeDateNaissance, this);
        },

        validation: {
            day: {
                required: true,
                pattern: /^([1-9]|0[1-9]|[12][0-9]|3[01])$/,
                length: 2
            },
            month: {
                required: true,
                length: 2,
                pattern: /^([1-9]|0[1-9]|1[012])$/
            },
            year: {
                required: true,
                length: 4,
                pattern: /^(19|20)[0-9]{2}$/
            },
            dateNaissance: [
                {
                    required: true,
                    msg: function () {
                        return messages.get('PINPAD.ERROR.DATE');
                    }
                },
                {
                    pattern: /^([1-9]|0[1-9]|[12][0-9]|3[01])([1-9]|0[1-9]|1[012])(19|20)[0-9]{2}$/,
                    msg: function () {
                        return messages.get('PINPAD.ERROR.DATE');
                    }
                },
                {
                    fn: 'validateAge'
                }
            ],
            code: {
                required: true,
                length: 4,
                msg: function () {
                    return messages.get('PINPAD.ERROR.CODE');
                }
            }
        },

        changeDateNaissance: function () {
            var day = this.get('day'),
                month = this.get('month'),
                year = this.get('year');
            if (!_.isUndefined(day) || !_.isUndefined(month) || !_.isUndefined(year)) {
                if (!_.isEmpty(day) && !_.isEmpty(month) && !_.isEmpty(year)) {
                    this.set('dateNaissance', day + month + year);
                } else if (day === '' || month === '' || year === '') {
                    this.set('dateNaissance', '');
                }
            }
        },

        validateAge: function (dateNaissance) {
            if (dateNaissance && dateNaissance.length === 8 &&
                    moment(dateNaissance, timeManager.ft.DAY_MONTH_YEAR).valueOf() > moment().subtract('years', 18).valueOf()) {
                return messages.get('PINPAD.ERROR.AGE');
            }
        }

    });

});
define('src/session/PinpadModel',['defaults'], function (Defaults) {
    

    return Backbone.Model.extend({
        url: function () {
            return  Defaults.PINPAD_URL.replace('{timestamp}', new Date().getTime());
        }
    });

});
define('text!src/session/templates/pinpad.html',[],function () { return '<div class="pinpad-header">\n    <p>Identification</p>\n    <div id="button-close" class="close-button">\n        Fermer X\n    </div>\n</div>\n<div id="pinpad-nav-error" class="inline"></div>\n<div class="pinpad-body">\n    <form id="pinpad-form" method="post" action="#" autocomplete="off">\n        <div id="birthdate-block" class="block">\n            <h5>1. Saisir votre date de naissance :</h5>\n            <div id="birthdate-body">\n                <input id="day" class="day error-place-holder" name="day" type="text" maxlength="2" placeHolder="JJ" />\n                <input id="month" class="month error-place-holder" name="month" type="text" maxlength="2" placeHolder="MM" />\n                <input id="year" class="year error-place-holder" name="year" type="text" maxlength="4" placeHolder="AAAA" />\n                <div id="birthdate-help" class="birthdate-help" title="Vous devez avoir au moins 18 ans pour parier"></div>\n                <div class="error-message dateNaissance"></div>\n            </div>\n        </div>\n        <div id="code-block" class="block">\n            <h5>2. Saisir votre Code Confidentiel :</h5>\n            <p id="grille-text">\n                Pour des raisons de sécurité, vous devez cliquer sur les chiffres de la grille pour saisir votre\n                Code Confidentiel :\n            </p>\n            <div class="cx">\n                <div id="pinpad-grid" class="grid">\n                    <div class="num" value="0">0</div>\n                    <div class="num" value="1">1</div>\n                    <div class="num" value="2">2</div>\n                    <div class="num" value="3">3</div>\n                    <div class="num" value="4">4</div>\n                    <div class="num" value="5">5</div>\n                    <div class="num" value="6">6</div>\n                    <div class="num" value="7">7</div>\n                    <div class="num" value="8">8</div>\n                    <div class="num" value="9">9</div>\n                </div>\n                <div class="button-right">\n                    <input id="button-correct" class="button button-correct" value="Corriger" type="button" />\n                    <input id="button-cancel" class="button button-cancel" value="Annuler" type="button" />\n                </div>\n            </div>\n            <div class="cx">\n                <input id="code-pinpad" class="error-place-holder code" name="code" type="password" maxlength="4" disabled="disabled" />\n                <strong>(4 chiffres)</strong>\n                <div class="error-message code"></div>\n                <input id="button-confirm" class="button" value="Confirmer" type="submit" disabled="disabled"/>\n            </div>\n        </div>\n    </form>\n</div>\n';});

define('text!src/common/templates/full-screen-overlay.html',[],function () { return '<div id="full-screen-overlay" class="layer-popin"></div>';});

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

define('src/session/PinpadView',[
    'src/common/bandeau_message/BandeauMessageView',
    './PinpadFormModel',
    './PinpadModel',
    'text!./templates/pinpad.html',
    'text!src/common/templates/full-screen-overlay.html',
    'tagCommander',
    'messages'
], function (BandeauMessageView, PinpadFormModel, PinpadModel, pinpadTmpl, fullScreenLayerTmpl, tagCommander, messages) {
    

    var PINPAD_WIDTH = 360,
        PINPAD_HEIGHT = 515,
        INPUT_ERROR_CLASS = 'error-pinpad';

    return Backbone.View.extend({

        id: 'popin-pinpad',

        events: {
            'blur input, select': 'updateModel',
            'click #pinpad-grid div': 'fillCodePinpad',
            'click #button-close': 'close',
            'click #button-cancel': 'close',
            'keyup': 'closeIfEscape',
            'click #button-correct': 'corriger',
            'click #button-retry': 'retry',
            'keyup #day': 'focusMonth',
            'keyup #month': 'focusYear',
            'submit #pinpad-form': 'submit'
        },

        initialize: function () {
            this.model = new PinpadFormModel();

            this.scheme = new PinpadModel();
            this.listenTo(this.scheme, 'sync', this.schemeSuccess);
            this.listenTo(this.scheme, 'error', this.schemeError);
            this.scheme.fetch();
        },

        render: function () {
            this.$el.html(pinpadTmpl);
            this.positionViewRandomly();
            this.positionNumbersRandomly();
            this.insertOverlay();
            this.$codePinPad = this.$('#code-pinpad');

            Backbone.Validation.bind(this, {
                valid: _.bind(this.hideError, this),
                invalid: _.bind(this.showError, this),
                forceUpdate: true
            });

            this._renderPlaceholder();

            tagCommander.sendTagIfOnline('hippique.connexion.accueil');

            return this;
        },

        _renderPlaceholder: function () {
            _.placeholder(this.$('#day'), this.$('#month'), this.$('#year'));
        },

        focusMonth: function (e) {
            var code = e.keyCode || e.which;
            if (code !== 9 && code !== 16 && this.$("#day").val().length === 2) {
                this.$('#month').focus();
            }
        },

        focusYear: function (e) {
            var code = e.keyCode || e.which;
            if (code !== 9 && code !== 16 && this.$("#month").val().length === 2) {
                this.$('#year').focus();
            }
        },

        updateModel: function (el) {
            var $el = $(el.target);
            this.model.set($el.attr('name'), $el.val());
        },

        schemeSuccess: function (model) {
            this.pinpadKey = model.get('keyPinpad');
            this.codes = _.reduce(model.get('pinPadCodes'), function (memo, array) {
                memo[array[0]] = array[1];
                return memo;
            }, {});
            $('#button-confirm').prop('disabled', false);

            this.$('#pinpad-nav-error .bandeau').remove();
        },

        schemeError: function () {
            this.renderError(messages.get('validation.front.139'));
        },

        retry: function () {
            this.scheme.fetch();
        },

        insertOverlay: function () {
            $('body').prepend(fullScreenLayerTmpl);
        },

        removeOverlay: function () {
            $('#full-screen-overlay').remove();
        },

        positionViewRandomly: function () {
            var maxLeft = Math.abs(document.documentElement.clientWidth - PINPAD_WIDTH),
                maxTop = Math.abs(document.documentElement.clientHeight - PINPAD_HEIGHT);

            this.$el.css('top', this.rand(maxTop) + "px");
            this.$el.css('left', this.rand(maxLeft) + "px");
        },

        renderError: function (message) {
            new BandeauMessageView({
                model: new Backbone.Model({content: message, notclosable: true}),
                $target: this.$('#pinpad-nav-error'),
                inline: true
            }).error();
        },

        positionNumbersRandomly: function () {
            var self = this,
                gridSize = 5,
                cellSize = 42,
                numPositions = _.range(Math.pow(gridSize, 2));

            this.$("#pinpad-grid div").each(function (index, numberElt) {
                var $number = $(numberElt),
                    randValue = self.rand(numPositions.length);
                $number.css('top', Math.floor(numPositions[randValue] / gridSize) * cellSize + 'px');
                $number.css('left', numPositions[randValue] % gridSize * cellSize + 'px');
                numPositions.splice(randValue, 1);
            });
        },

        showError: function (view, attr, message) {
            this.$("." + attr + ".error-message").html(message);
            this.$("." + attr + ".error-place-holder").addClass(INPUT_ERROR_CLASS);
        },

        hideError: function (view, attr) {
            this.$("." + attr + ".error-message").html('');
            this.$("." + attr + ".error-place-holder").removeClass(INPUT_ERROR_CLASS);
        },

        submit: function (event) {
            event.preventDefault();

            this.model.set(this.serializeForm(), {validate: true});

            this.model.validate();
            if (this.model.isValid()) {
                this.options.success(this.toJSON());
                this.close();
            } else {
                this.renderError('Certaines informations sont incorrectes.');
            }
            tagCommander.sendTagIfOnline('hippique.clic.connexion.valider');
        },

        toJSON: function () {
            var json = this.model.toJSON();
            json.pinpadKey = this.pinpadKey;

            json.code = _.reduce(this.$codePinPad.val(), function (sum, key) {
                return sum + this.codes[key];
            }, '', this);

            return json;
        },

        serializeForm: function () {
            var form = this.$('form').serializeObject();
            // Le champ suivant n'est pas sérialisé car il est disabled.
            form.code = this.$codePinPad.val();
            return form;
        },

        fillCodePinpad: function (event) {
            if (this.$codePinPad.val().length < 4) {
                this.$codePinPad.val(this.$codePinPad.val() + $(event.target).text());
            }
            return false;
        },

        corriger: function () {
            this.$codePinPad.val('');
        },

        rand: function (n) {
            return Math.floor(Math.random() * n);
        },

        closeIfEscape: function (event) {
            if (event.keyCode === 27) {
                this.close();
            }
        },

        beforeClose: function () {
            this.removeOverlay();
        }

    });
});

define('text!src/session/templates/auth-form.hbs',[],function () { return '<form id="auth-form" action="" method="">\n    <span class="title">\n            {{#isSiteDispatch}}\n                Se connecter\n            {{/isSiteDispatch}}\n            {{#isSiteOnline}}\n                Accès Compte pmu.fr\n            {{/isSiteOnline}}\n            {{#isSiteOffline}}\n                Accès Compte Carte PMU / Allo Pari\n            {{/isSiteOffline}}\n    </span>\n    <input type="text" id="numeroExterne" name="numeroExterne" placeholder="N° DE COMPTE" />\n    <input type="text" id="codeConf"  name="codeConf" value="" placeholder="CODE" />\n    <button>OK</button>\n</form>\n<span class="bottom">\n    <a id="code-confidentiel-reinit" href="{{ findUrl \'transverse-code-confidentiel-renitialiser\' }}">Code confidentiel oublié ?</a>\n    <a href="{{ urlOuvertureCompte }}">Ouvrir un compte</a>\n</span>\n';});

define('localstorage',[], function () {
    

    return {
        /**
         * Save a value in the localstorage
         * @param key key of the value to save
         * @param value value to save
         * @throws  QuotaExceededError if the quota of the localstorage has been exceeded
         *          SecurityError if you're not allow to save in the localstorage
         *          ReferenceError if the localstorage is not supported
         */
        save: function (key, value) {
            localStorage.setItem(key, value);
        },

        /**
         * Read a value from the localstorage from a key
         * @param key key of the value to read
         * @returns {*} value if found. null if no value is found
         * @throws ReferenceError if the localstorage is not supported
         */
        read : function (key) {
            return localStorage.getItem(key);
        },

        /**
         * Convenient method to save a collection to the localstorage.
         * The collection will be saved after being JSON.stringified
         * @param key
         * @param collection
         * @throws  QuotaExceededError if the quota of the localstorage has been exceeded
         *          SecurityError if you're not allow to save in the localstorage
         *          ReferenceError if the localstorage is not supported
         */
        saveArray: function (key, collection) {
            localStorage.setItem(key, JSON.stringify(collection));
        },

        /**
         * Read a collection from the localstorage.
         * @param key
         * @returns {*} the array if the collection exists. Otherwise null
         * @throws ReferenceError if the localstorage is not supported
         */
        readArray: function (key) {
            return JSON.parse(localStorage.getItem(key));
        },

        /**
         * Add an item to a collection saved in the localstorage.
         * If the collection is empty, it will create a new collection with the item.
         * If the item already exists in the saved collection, it will not be added a second time
         * @param key key of the collection where the item will be added
         * @param item the item to add
         * @throws  QuotaExceededError if the quota of the localstorage has been exceeded
         *          SecurityError if you're not allow to save in the localstorage
         *          ReferenceError if the localstorage is not supported
         */
        addToArray: function (key, item) {
            var array,
                storedValue = JSON.parse(localStorage.getItem(key));
            if (storedValue instanceof Array) {
                if (storedValue.indexOf(item) === -1) {
                    storedValue.push(item);
                    localStorage.setItem(key, JSON.stringify(storedValue));
                }
            } else if (storedValue === null) {
                array = [];
                array.push(item);
                localStorage.setItem(key, JSON.stringify(array));
            }
        },

        /**
         * Delete a value in the localstorage from a key
         * @param key key of the value to remove
         * @throws ReferenceError if the localstorage is not supported
         */
        remove: function (key) {
            localStorage.removeItem(key);
        }
    };
});

//TODO: filtre des parametres du formulaire ?
define('src/session/AuthView',[
    './PinpadView',
    'template!./templates/auth-form.hbs',
    'messages',
    'conf',
    'localstorage',
    'sessionManager',
    'logger'
], function (PinpadView, authFormTmpl, messages, conf, localstorage, sessionManager, logger) {
    

    return Backbone.View.extend({

        id: 'auth-view',

        events: {
            'focus #codeConf': 'popinLogin',
            'submit #auth-form': 'popinLogin'
        },

        initialize: function () {
            this.compiledAuthFormTmpl = authFormTmpl;
        },

        render: function () {
            this.$el.html(this.compiledAuthFormTmpl({urlOuvertureCompte: conf.OUVERTURE_COMPTE_URL}));
            this._renderPlaceholder();
            this._initAutocompleteFeature();
            return this;
        },

        _initAutocompleteFeature : function () {
            var numerosExterne;
            try {
                numerosExterne = localstorage.readArray("pmu-numero-externe");
                this.$("#numeroExterne").autocomplete({
                    source:  numerosExterne ? numerosExterne : []
                });
            } catch (e) {
                logger.error(e.message);
            }
        },

        _renderPlaceholder: function () {
            _.placeholder(this.$('#numeroExterne'), this.$('#codeConf'));
        },

        popinLogin: function (event) {
            var self = this;

            event.preventDefault();

            if (this.pinpad) {
                this.pinpad.close();
            }
            this.pinpad = new PinpadView({
                success: _.bind(this.login, this)//TODO: supprimer ce passage de callback en param. déporter la méthode login dans PinpadView
            });
            $('body').append(this.pinpad.render().el);
            _.defer(function () {
                self.pinpad.$('#day').focus();
            });
        },

        //TODO: déporter cette méthode dans PinpadView
        login: function (json) {
            this.$('#codeConf').val('****');
            this.$('#codeConf').addClass('input-loading');
            sessionManager.login({
                dateNaissance: json.day + json.month + json.year,
                codeConf: json.code,
                pinpadKey: json.pinpadKey,
                numeroExterne: _.str.trim(this.$('#numeroExterne').val())
            }, {
                success: _.bind(this.loginSuccess, this),
                error: _.bind(this.onLoginError, this)
            });
        },

        onLoginError: function (model, response) {
            var message;

            if (_.contains([420, 400], response.status)) {
                message = messages.getErrorService(JSON.parse(response.responseText));
            } else {
                message = messages.get('LOGIN.ERROR.TECHNIQUE');
            }

            this.triggerError(message);
            this.hideLoading();
        },

        loginSuccess: function () {
            try {
                localstorage.addToArray("pmu-numero-externe", this.$('#numeroExterne').val());
            } catch (e) {
                logger.error(e.message);
            }
            this.hideLoading();
        },

        hideLoading : function () {
            this.$('#codeConf').removeClass('input-loading');
        },

        triggerError: function (message) {
            Backbone.trigger('menu:error', message);
        },

        beforeClose: function () {
            if (this.pinpad) {
                this.pinpad.close();
            }
        }
    });
});

define('dialog',[
    'jquery'
], function ($) {
    

    return {
        _display: function (content, title, type, options) {
            var $el = $('#dialog');
            options = options || {};
            $el.html(content);
            $el.dialog({
                show: options.show || 'fade',
                hide: options.hide || 'fade',
                dialogClass: options.dialogClass || type || 'info',
                position: options.position || ['right', 'top'],
                title: title || '',
                minHeight: 0,
                minWidth: options.minWidth || 0,
                modal: options.modal || false,
                draggable: options.draggable || true,
                resizable: options.resizable || false,
                buttons: options.buttons || []
            });

            if (options.duration !== 0) {
                setTimeout(_.bind(function () {
                    this.hide();
                }, this), options.duration || 3000);
            }
        },

        info: function (content, title, options) {
            this._display(content, title, 'info', options);
        },

        infoWithClose: function (type, content, title, options) {
            var $el = $('#dialog'),
                $closeButton = $('<div class="close-button">×</div>');

            this.currentType = type;
            this.info(content, title, options);
            $closeButton.on('click', this.hide);
            $el.prepend($closeButton);
        },

        success: function (content, title, options) {
            this._display(content, title, 'success', options);
        },

        error: function (content, title, options) {
            this._display(content, title, 'error', options);
        },

        hide: function () {
            this.currentType = null;
            var $el = $('#dialog');
            try {
                $el.dialog('close');
            } catch (err) {}
            $el.empty();
        },

        isOpen: function () {
            var $el = $('#dialog');
            try {
                return $el.dialog('isOpen');
            } catch (err) {
                return false;
            }
        },

        getCurrentType: function () {
            return this.currentType;
        }
    };
});
define('src/session/TtlModel',['defaults'], function (Defaults) {
    

    return Backbone.Model.extend({
        url: Defaults.SESSION_CHECK_URL
    });
});
define('src/session/ActivityView',[
    'dialog',
    'sessionManager',
    'src/session/TtlModel',
    'messages'
], function (dialog, sessionManager, TtlModel, messages) {
    

    var LISTEN_ACTIVITY_INTERVAL = 5 * 60 * 1000,
        DISCONNECTION_ALERT_LIMIT = 30 * 1000,
        CHECK_CONNECTION_INTERVAL_DEFAULT = 60 * 1000 + DISCONNECTION_ALERT_LIMIT;

    return Backbone.View.extend({
        initialize: function () {
            this.$body = $('body');

            this.ttlModel = new TtlModel();

            this.listenTo(sessionManager, 'login', this.loggedIn);
            this.listenTo(sessionManager, 'logout', this.loggedOut);
            sessionManager.requestAccess(_.bind(this.loggedIn, this), _.bind(this.loggedOut, this), this);
        },
        loggedIn: function () {
            this.checkConnection();
            this.listenActivity();
        },
        loggedOut: function () {
            this.$body.off('.activity');
            window.clearTimeout(this.checkConnectionHandler);
            window.clearTimeout(this.listenActivityHandler);
        },

        listenActivity: function () {
            window.clearTimeout(this.listenActivityHandler);

            this.$body
                .off('.activity')
                .on('keypress.activity mousedown.activity mousemove.activity mousewheel.activity', _.bind(this.keepAlive, this));
            this.listenActivityHandler = window.setTimeout(_.bind(this.listenActivity, this), LISTEN_ACTIVITY_INTERVAL);
        },
        keepAlive: function () {
            this.$body.off('.activity');
            sessionManager.keepAlive();
            this.stopAlertDisconnection();
        },

        checkConnection: function () {
            window.clearTimeout(this.checkConnectionHandler);

            this.ttlModel.fetch({
                success: _.bind(this.parseConnection, this),
                error: _.bind(this.parseConnection, this)
            });
        },
        parseConnection: function (model, response) {
            var ttl = CHECK_CONNECTION_INTERVAL_DEFAULT;

            if (response.status === 401) { // Déconnecté
                this.stopAlertDisconnection();
                // sessionManager.requestAccess() effectuée dans authenticationErrorsHandler
                return;
            }
            if (response.ttl) { // Réponse OK
                ttl = this.ttlModel.get('ttl') * 1000;
                if (!dialog.isOpen() && ttl <= DISCONNECTION_ALERT_LIMIT) {
                    window.clearTimeout(this.decompteTimeout);
                    this.alertDisconnection(Math.ceil(ttl / 1000));
                } else if (dialog.isOpen() && ttl > DISCONNECTION_ALERT_LIMIT) {
                    this.stopAlertDisconnection();
                }
            } else { // Autres réponses
                this.stopAlertDisconnection();
                this.warn('Echec de la récupération du TTL');
            }

            // On ne check la connection que 30 sec avant la date estimée de déconnexion automatique,
            // en attendant au minimum 1sec, au maximum 1min
            this.checkConnectionHandler = window.setTimeout(_.bind(this.checkConnection, this), this.clampValue(ttl - DISCONNECTION_ALERT_LIMIT, 1000, CHECK_CONNECTION_INTERVAL_DEFAULT - DISCONNECTION_ALERT_LIMIT));
        },

        alertDisconnection: function (timeRemainingSec) {
            if (timeRemainingSec < 0) {
                this.checkConnection();
                return;
            }

            if (!dialog.isOpen()) {
                dialog.infoWithClose('session', messages.get('validation.front.1300', '<span id="session-restant"></span>'), 'Attention', {
                    modal: true,
                    duration: 0,
                    dialogClass: 'dialog-black',
                    minWidth: 375,
                    position: ['center', 'center']
                });
                this.listenActivity();
            }
            $('#session-restant').text(timeRemainingSec + ' seconde' + (timeRemainingSec > 1 ? 's' : ''));

            this.decompteTimeout = window.setTimeout(_.bind(this.alertDisconnection, this), 1000, timeRemainingSec - 1);
        },
        stopAlertDisconnection: function () {
            window.clearTimeout(this.decompteTimeout);
            dialog.hide();
        },

        clampValue: function (x, min, max) {
            return (x < min ? min : (x > max ? max : x));
        }
    });
});

//FIXME: Mauvaise pratique => à remplacer par de la detection de fonctionnalités (voir Modernizr)
define('src/navigatorCompatibilityManager',['backbone', 'conf', 'messages'], function (Backbone, conf, messages) {
    

    var utils = {
        _isCompatibleChromeVersion: function (version) {
            return version >= conf.BROWSER_FIRST_COMPATIBLE_VERSION.CHROME;
        },

        _isCompatibleMozillaVersion: function (version) {
            return version >= conf.BROWSER_FIRST_COMPATIBLE_VERSION.FIREFOX;
        },

        _isCompatibleSafariVersion: function (version) {
            return version >= conf.BROWSER_FIRST_COMPATIBLE_VERSION.SAFARI;
        },

        _isCompatibleIEVersion: function (version) {
            return version >= conf.BROWSER_FIRST_COMPATIBLE_VERSION.IE;
        },

        _getMozillaVersion: function (version) {
            return window.parseInt(version.slice(0, 3));
        },

        _getIEVersion: function (version) {
            return window.parseInt(version.split(".")[0], 10);
        },

        _getSafariVersion: function (safariUserAgent) {
            // la version de safari dans le userAgent est un peu spéciale. c'était pas possible de la récupérer via jquery.
            // see http://www.redsunsoft.com/2011/07/check-browser-version-in-jquery/
            var versionString = safariUserAgent.substring(safariUserAgent.indexOf('Version/') + 8);
            return versionString.substring(0, versionString.indexOf('.'));
        },

        _isIE11OrMore: function (userAgent) {
            return userAgent.match(/Trident\/7\./) !== null;
        },

        _isKnownBrowser: function (browser) {
            var boolean = (browser.chrome || browser.mozilla || browser.msie || browser.safari);
            if (boolean === undefined) {
                return false;
            }
            return  boolean;
        }
    };


    return function () {
        return {
            isCompatibleVersion: function () {
                var browser = $.browser,
                    userAgent = navigator.userAgent,
                    version = browser.version;

                if (utils._isIE11OrMore(userAgent)) {
                    return true;
                }

                if (browser.chrome) {
                    return utils._isCompatibleChromeVersion(utils._getMozillaVersion(version));
                }

                if (browser.mozilla) {
                    return utils._isCompatibleMozillaVersion(utils._getMozillaVersion(version));
                }

                if (browser.msie) {
                    return utils._isCompatibleIEVersion(utils._getIEVersion(version));
                }

                if (browser.safari) {
                    return utils._isCompatibleSafariVersion(utils._getSafariVersion(userAgent));
                }


                return false;
            },

            isUnSupportedVersion: function () {
                return !this.isCompatibleVersion();
            },

            manageDegradedBrowserWarningMessage: function () {
                var browser = $.browser;
                if (this.isUnSupportedVersion()) {
                    Backbone.trigger('menu:warning', messages.get("validation.front.4000"));//trigger event to display warning
                }
            },
            // for UT
            Utils: {
                fcs: function () {
                    return utils;
                }
            }
        };
    };
});
define('src/session/SessionView',[
    './ProfilView',
    './AuthView',
    'messages',
    'sessionManager',
    './ActivityView',
    'links',
    'src/navigatorCompatibilityManager',
    'formatter',
    'cookie',
    'dialog'
], function (ProfilView, AuthView, messages, sessionManager, ActivityView, links, navigatorCompatibilityManager, formatter) {
    

    return Backbone.View.extend({

        id: 'session-view',

        initialize: function () {
            this.activity = new ActivityView();

            this.listenTo(sessionManager, 'login', this.onLoginSuccess);
            this.listenTo(sessionManager, 'logout', this.loggedOut);
            sessionManager.requestAccess(_.bind(this.onLoginSuccess, this), _.bind(this.renderAuthForm, this), this);
        },

        renderProfil: function (session) {
            this.profilView = new ProfilView({model: session, menus: this.menus(), displaySolde: this.displaySolde});
            this.$el.html(this.profilView.render().el);
            if (this.authView) {
                this.authView.close();
            }
        },

        renderAuthForm: function () {
            this.authView = new AuthView();
            this.$el.html(this.authView.render().el);
            if (this.profilView) {
                this.profilView.close();
            }

            navigatorCompatibilityManager().manageDegradedBrowserWarningMessage();
        },

        loggedOut: function () {
            this._closeBandeauMessage();
            this.renderAuthForm();
        },

        onLoginSuccess: function (session) {
            this._closeBandeauMessage();
            this.renderProfil(session);
            this.checkAccountOk(session);
        },

        _closeBandeauMessage: function () {
            Backbone.trigger('menu:closeBandeauMessage');
        },

        checkAccountOk: function (session) {
            var message = '', dayCount;


            if (session.isAwaitingDocumentsLater()) {
                message = 'validation.front.2505';
            } else if (session.isAwaitingDocuments()) {
                message = 'validation.front.2500';
            } else if (session.isAwaitingCode()) {
                message = 'validation.front.2504';
            } else if (session.isAwaitingCodeForAdresse()) {
                message = 'validation.front.2510';
            } else if (session.hasBirthInformationsMissing()) {
                message = messages.get('validation.front.2412', links.get('compteLieuNaissance'));
            } else if (session.isAutolilimitationsMissing()) {
                message = messages.get('AUTOLIM.ERROR.EMPTY.BANDEAU', links.get('compteAutolimitations'));
            }

            if (message) {
                dayCount = session.get('nombreJoursAvantBlocage');

                Backbone.trigger('menu:warning', messages.get(message, formatter.formatDayCount(dayCount), links.get('compteAccueil')));
            } else {
                navigatorCompatibilityManager().manageDegradedBrowserWarningMessage();
            }
        }
    });
});

define('src/session/SessionOffView',['src/session/SessionView', 'links'], function (SessionView, links) {
    

    return SessionView.extend({
        displaySolde: true,
        menus: function () {
            return {
                'Mon compte': links.get('compteAccueil'),
                'Approvisionner': links.get('compteApprovisionnement')
            };
        },
        loggedOut: function () {
            window.location.replace('/');
        },
        onLoginSuccess: function (session) {
            if (session.wasPost()) {
                window.location.reload();
            } else {
                SessionView.prototype.onLoginSuccess.apply(this, arguments);
            }
        }
    });
});

define('LoginStandalone',['require','core','src/session/SessionOffView'],function (require) {
    

    require('core');
    var SessionView = require('src/session/SessionOffView');
    $('#bloc-authent').append(new SessionView().el);
});