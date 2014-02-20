
define("json!src/tags-offline.json", function(){ return {
    "chargement": {
        "body[tag-id='front']": "home.accueil",
        "body[tag-id='programme']": "programme_resultats.accueil",
        "body[tag-id='programme-actualites-hippiques']": "programme_resultats.actualites",
        "body[tag-id='programme-calendrier-reunions']": "programme_resultats.calendrier",
        "body[tag-id='programme-guide-des-paris']": "mon_pmu.guide_paris",

        "body[tag-id='mon-pmu']": "mon_pmu.accueil",
        "body[tag-id='mon-pmu-trouver-pmu']": "mon_pmu.pmu_locator",
        "body[tag-id='mon-pmu-mes-paris-en-toute-simplicite']": "mon_pmu.mes_paris",
        "body[tag-id='mon-pmu-animation-point-de-vente']": "mon_pmu.animations_pdv",

        "body[tag-id='partenariats']": "partenariat_sponsoring.accueil",
        "body[tag-id='partenariats-hippique']": "partenariat_sponsoring.hippique",
        "body[tag-id='partenariats-sport']": "partenariat_sponsoring.sport",
        "body[tag-id='partenariats-poker']": "partenariat_sponsoring.poker",
        "body[tag-id='partenariats-partenariats']": "partenariat_sponsoring.autres",

        "body[tag-id='la-carte']": "la_carte.accueil",
        "body[tag-id='la-carte-avantages']": "la_carte.avantages",
        "body[tag-id='la-carte-offre-bienvenue']": "la_carte.avantages.offre_bienvenue",
        "body[tag-id='la-carte-operations-commerciales']": "la_carte.ma_carte.ope_commerciales",

        "body[tag-id='entreprise-actualites']": "entreprise.accueil",
        "body[tag-id='entreprise-chiffres-cles']": "entreprise.chiffres_cles",
        "body[tag-id='entreprise-fonctionnement']": "entreprise.chiffres_cles.fonctionnement",
        "body[tag-id='entreprise-gouvernance']": "entreprise.chiffres_cles.gouvernance",
        "body[tag-id='entreprise-histoire']": "entreprise.chiffres_cles.dates",
        "body[tag-id='entreprise-entreprise-responsable']": "entreprise.rh.entreprise_responsable",
        "body[tag-id='entreprise-jeu-responsable']": "entreprise.responsabilite.jeu_responsable",
        "body[tag-id='entreprise-mecenat']": "entreprise.responsabilite.mecenat",
        "body[tag-id='entreprise-partenariats-sportifs']": "entreprise.partenariat_sponsoring.sport",
        "body[tag-id='entreprise-partenariats']": "entreprise.partenariat_sponsoring.media",
        "body[tag-id='entreprise-international']": "entreprise.chiffres_cles.international",
        "body[tag-id='entreprise-communiques-presse']": "entreprise.presse",
        "body[tag-id='entreprise-rapport-activite']": "entreprise.presse.publications",
        "body[tag-id='entreprise-photos']": "entreprise.presse.phototheque",
        "body[tag-id='entreprise-videos']": "entreprise.presse.mediatheque",
        "body[tag-id='entreprise-offre-emplois']": "entreprise.rh.offres_emploi",
        "body.node-type-jobs": "entreprise.rh.offres_emploi.detail",
        "body[tag-id='entreprise-notre-ambition']": "entreprise.rh.notre_ambition",
        "body[tag-id='entreprise-mecenat']": "entreprise.responsabilite.mecenat",
        "body[tag-id='entreprise-nos-metiers']": "entreprise.nos_metiers",

        "body[tag-id='contact']": "contact.accueil",
        "body[tag-id='mon-pmu-infos-legales']": "infos_legales.accueil",
        "body[tag-id='plan-du-site']": "plan_site.accueil"
    },
    "clic": {
        ".marketing-neolane-off": "commun.clic.bloc_droit.",
        ".twitter": "commun.clic.footer.twitter",
        ".facebook": "commun.clic.footer.facebook"
    }
};});

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

define('TaggerStandalone',['json!src/tags-offline.json', 'tagCommander'], function (tags, tagCommander) {
    

    var tagger = {

        setClickTaggers: function () {
            _.each(_.keys(tags.clic), function (selector) {
                $(selector).click(function () {
                    var cms_title = $(selector).data('cmsTitle');
                    if (cms_title) {
                        cms_title = _.str.slugify(cms_title);
                        tagCommander.sendTagIfOffline(tags.clic[selector] + cms_title);
                    } else {
                        tagCommander.sendTagIfOffline(tags.clic[selector]);
                    }
                });
            });
        },

        tagAffichage: function () {
            _.each(_.keys(tags.chargement), function (selector) {
                if ($(selector).length) {
                    tagCommander.sendTagIfOffline(tags.chargement[selector]);
                }
            });
        }

    };

    $(document).ready(function () {
        tagger.setClickTaggers();
        tagger.tagAffichage();
    });

    return tagger;
});