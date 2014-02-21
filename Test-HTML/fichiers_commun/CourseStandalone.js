
define('comparator',[],function () {
    

    var TestSwitch = function (o) {
        return _.extend(this, o);
    },
        CompareSwitch = function (o) {
            return _.extend(this, o);
        },
        _protoSwitch = {
            isUndefined: function (a) {
                return a === null || a === undefined;
            },
            isValUndefined: function (a) {
                return this.isUndefined(this.val(a));
            },
            getComparator: function () {
                return _.bind(this.exec, this);
            }
        };

    TestSwitch.prototype = _.extend({}, _protoSwitch, {
        bothTrue: null,
        bothFalse: null,
        different: null,
        test: null,
        exec: function (a, b) {
            if (this.test(a) && this.test(b)) {
                return this.bothTrue(a, b);
            }
            if (this.test(a) || this.test(b)) {
                return this.different(a, b);
            }
            return this.bothFalse(a, b);
        }
    });

    CompareSwitch.prototype = _.extend({}, _protoSwitch, {
        val: null,
        equal: function (a, b) {
            return 0;
        },
        different: function (a, b, test) {
            return test ? -1 : 1;
        },
        test: function (a, b) {
            return this.val(a) < this.val(b);
        },
        exec: function (a, b) {
            if (this.val(a) === this.val(b)) {
                return this.equal(a, b);
            }
            return this.different(a, b, this.test(a, b));
        }
    });

    return {

        TestSwitch: TestSwitch,
        CompareSwitch: CompareSwitch,

        /**
         * Return a Comparator that will compare nulls to be either lower or higher than other objects.
         * @param nonNullComparator
         * @param nullsAreHigh
         * @return {function} comparator
         */
        nullComparator: function (nonNullComparator, nullsAreHigh) {
            return function (a, b) {
                if (a === b) {
                    return 0;
                }
                if (a === null || a === undefined) {
                    return (nullsAreHigh ? -1 : 1);
                }
                if (b === null || b === undefined) {
                    return (nullsAreHigh ? 1 : -1);
                }
                return nonNullComparator(a, b);
            };
        },

        /**
         * Compararateur comparant 2 valeurs avec le < et le > de javascript.
         * @return {function} comparator
         */
        baseComparator: function () {
            return function (valeurA, valeurB) {
                if (valeurA === valeurB) {
                    return 0;
                }
                return valeurA < valeurB ? -1 : 1;
            };
        },

        /**
         * Return a comparator which compares two backbone model by the specified bean property.
         * @param comparator Le comparateur à appliquer à la propriété.
         * @param propertyName Nom de la propriété à comparer.
         * @return {function} comparator
         */
        modelPropertyComparator: function (comparator, propertyName) {
            var self = this;

            return function (modelA, modelB) {
                var propertyModelA = self.retrievePropertyValue(modelA, propertyName),
                    propertyModelB = self.retrievePropertyValue(modelB, propertyName);

                return comparator(propertyModelA, propertyModelB);
            };
        },

        /**
         * Retourne la valeur de la proprité passée en paramètre
         * @param model
         * @param property
         * @returns {value}
         */
        retrievePropertyValue: function (model, property) {
            var propertiesNames = property.split('_'),
                propertyValue = model.get(propertiesNames[0]);

            _.each(_.rest(propertiesNames), function (propertyName) {
                propertyValue = propertyValue[propertyName];
            });
            return propertyValue;
        },

        /**
         * Return a comparator which reverses the order of another comparator.
         * @return {function} comparator Le comparateur à inverser.
         */
        reverseComparator: function (comparator) {
            return function (valeurA, valeurB) {
                return -(comparator(valeurA, valeurB));
            };
        }

    };
});

define('src/course/participants/ParticipantModel',[],function () {
    

    return Backbone.Model.extend({

        idAttribute: 'numPmu',

        defaults: {
            coteRef: null,
            cote: null
        },

        isNonPartant: function () {
            return this.get('statut') === 'NON_PARTANT';
        },

        parseRapports: function () {
            var rapportRef = this.get('dernierRapportReference'),
                rapportDirect = this.get('dernierRapportDirect');

            if (rapportRef && rapportRef.rapport !== undefined && rapportRef.rapport !== 0) {
                this.set('coteRef', rapportRef.rapport);
            }
            if (rapportDirect && rapportDirect.rapport !== undefined && rapportDirect.rapport !== 0) {
                this.set('cote', rapportDirect.rapport);
            }
        }

    });
});

define('src/common/SortableCollection',['comparator'], function (comparator) {
    

    return Backbone.Collection.extend({

        initialize: function () {

        },

        sortByPropertyAsc: function (propertyName) {
            this.setComparator(propertyName, true);
            this.sort();
        },

        sortByPropertyDesc: function (propertyName) {
            this.setComparator(propertyName, false);
            this.sort();
        },

        sortByProperty: function (propertyName) {
            this.setComparator(propertyName);
            this.sort();
        },

        setComparator: function (propertyName, isAsc) {
            this.comparator = comparator.baseComparator();

            if (isAsc === undefined) {
                if (this.sortPropertyName === propertyName) {
                    this.sortAsc = !this.sortAsc;
                } else {
                    this.sortAsc = true;
                }
            } else {
                this.sortAsc = isAsc;
            }
            this.sortPropertyName = propertyName;

            if (!this.isSortAsc()) {
                // On inverse l'ordre de comparaison
                this.comparator = comparator.reverseComparator(this.comparator);
            }

            // Les nulls apparaissent en fin de liste dans tous les cas
            this.comparator = comparator.nullComparator(this.comparator, false);

            this.comparator = comparator.modelPropertyComparator(
                this.comparator,
                propertyName
            );
        },

        getSortPropertyName: function () {
            return this.sortPropertyName;
        },

        isSortAsc: function () {
            return this.sortAsc === true;
        }

    });
});
define('src/course/participants/ParticipantCollection',[
    'comparator',
    './ParticipantModel',
    'src/common/SortableCollection'
], function (comparator, ParticipantModel, SortableCollection) {
    

    // Renvoie -1 ou 1 si argument est false ou true
    function state(b) {
        return b ? 1 : -1;
    }

    return SortableCollection.extend({

        model: ParticipantModel,

        initialize: function () {
            this.setComparator('numPmu'); // Propriété par laquelle la collection est triée initialement.
        },

        setComparator: function (propertyName, isAsc) {
            var compareNumPmu,
                compareNom,
                compareIncident,
                compareordreArrivee,
                compareNonPartants,
                compareOrdreArriveeNonPartants,
                compareBoolOrdreArrivee,
                compareAttr,
                invert = state(isAsc);

            SortableCollection.prototype.setComparator.apply(this, [propertyName, isAsc]);

            compareAttr = function (attr) {
                return new comparator.CompareSwitch({
                    val: function (a) {
                        return a.get(attr);
                    }
                });
            };
            compareNumPmu = compareAttr('numPmu');
            compareNom = compareAttr('nom');

            compareIncident = new comparator.CompareSwitch({
                val: function (a) {
                    return a.get('incident');
                },
                equal: function (a, b) {
                    return compareNumPmu.exec(a, b);
                },
                different: function (a, b, test) {
                    return state(test) * invert;
                }
            });

            compareNonPartants = new comparator.TestSwitch({
                bothTrue: function (a, b) {
                    return compareNumPmu.exec(a, b);
                },
                bothFalse: this.comparator,
                different: function (a, b) {
                    return state(this.test(a));
                },
                test: function (a) {
                    return a.isNonPartant();
                }
            });

            compareOrdreArriveeNonPartants = new comparator.TestSwitch(compareNonPartants);
            compareOrdreArriveeNonPartants.bothFalse = function (a, b) {
                return compareIncident.exec(a, b);
            };

            compareordreArrivee = new comparator.CompareSwitch({
                val: function (a) {
                    return a.get('ordreArrivee');
                },
                equal: function (a, b) {
                    return compareNom.exec(a, b);
                },
                different: function (a, b, test) {
                    return state(test);
                }
            });

            compareBoolOrdreArrivee = new comparator.TestSwitch({
                bothFalse: this.comparator,
                bothTrue: function (a, b) {
                    return compareOrdreArriveeNonPartants.exec(a, b);
                },
                different: function (a, b) {
                    return state(this.test(a));
                },
                test: function (a) {
                    return this.isUndefined(a.get('ordreArrivee'));
                }
            });

            if (propertyName === 'ordreArrivee') {
                this.comparator = compareBoolOrdreArrivee.getComparator();
                return;
            }

            if (propertyName !== 'numPmu' && propertyName !== 'nom') {
                this.comparator = compareNonPartants.getComparator();
            }
        },

        getNonPartants: function () {
            return this.filter(function (participant) {
                return participant.isNonPartant();
            });
        },

        getPartants: function () {
            return this.filter(function (participant) {
                return !participant.isNonPartant();
            });
        }

    });
});

define('text!src/course/templates/course-popin-full.hbs',[],function () { return '<div>\n    <p>\n        <span class="prix">PRIX {{libelleCourt}}</span>\n        <br/>\n        <span class="starting-date">{{formatMomentWithOffsetDate heureDepart timezoneOffset \'HH\\hmm\'}}</span>\n        -\n        <!-- TODO: faire le traitement de chaine dans la view -->\n        <span>\n            {{#if disciplineStr}}\n                {{substr disciplineStr 0 7}}\n            {{else}}\n                ERR\n            {{/if}}\n            {{#if categorieParticularite}}\n                - {{categorieStr}}\n            {{/if}}\n        </span>\n        <br/>\n        <span class="price">{{montantTotalOffert}} €</span>\n        -\n        <span>{{distance}}m</span>\n        -\n        <span>{{nombreDeclaresPartants}} partants</span>\n    </p>\n    {{#unless isNoBetYet}}\n        <ul class="inline-list">\n            {{#each parisFamiliesUIData}}\n            <li>\n                <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"\n                   href="{{findUrl \'course\' ../momentWithOffsetUrl ../numReunion ../numOrdre}}"></a>\n            </li>\n            {{/each}}\n            <li>\n                <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'course\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n            </li>\n        </ul>\n    {{else}}\n        <ul class="inline-list">\n            {{#each parisFamiliesUIData}}\n            <li>\n                <a class="picto-pari picto-pari-action small {{cssPictoFamily}}{{#if pariUnique}} {{pariUnique.codePari}}{{/if}}"\n                   href="{{findUrl \'pari\' ../momentWithOffsetUrl ../numReunion ../numOrdre family}}"></a>\n            </li>\n            {{/each}}\n            <li>\n                <a class="picto-pari picto-pari-spot size44x18 SPOT{{#unless isAtLeastOneSpot}} invisible{{/unless}}" href="{{findUrl \'pari-spot\' momentWithOffsetUrl numReunion numOrdre}}"></a>\n            </li>\n        </ul>\n    {{/unless}}\n</div>\n';});

define('text!src/programme/reunions_infos/templates/disciplines.hbs',[],function () { return '{{#each disciplinesMere}}\n    <li class="picto-discipline {{lowercase this}}">\n        <span title="{{capitalizeFirst this}}"> </span>\n    </li>\n{{/each}}\n';});

define('text!src/course/liste_courses/templates/liste-courses.hbs',[],function () { return '<div id="reunion-course-selector" class="clearfix">\n    <div class="reunion-selector">\n        <div class="reunion-discipline">\n            <span class="button-nav previous{{#if reunion.numOfficielReunionPrecedente}} actif{{/if}}"> </span>\n            <div class="liste-courses-cell-reunion {{reunion.statut}}"><span class="separator">R{{reunion.numExterne}}&nbsp;</span>&nbsp;{{truncate reunion.hippodrome.libelleCourt 13 \'...\'}}</div>\n            <span class="button-nav next{{#if reunion.numOfficielReunionSuivante}} actif{{/if}}">&nbsp;</span>\n        </div>\n        <div class="bottom">\n            <ul class="inline-list disciplines"></ul>\n            <div class="picto-meteo WEATHER-CLOUD"></div>\n        </div>\n    </div>\n    <div class="liste-courses-cell-line clearfix">\n        <ul class="liste-courses-cell-courses inline-list">\n            {{#each reunion.courses}}\n            <li data-reunionid="{{../reunion.numOfficiel}}"\n                data-courseid="{{numExterne}}"\n                data-date="{{formatMomentWithOffsetDate ../reunion.dateReunion ../reunion.timezoneOffset \'DDMMYYYY\'}}"\n                class="course {{categorieStatut}}{{#if evenement}} evenement {{evenement}}{{/if}}{{#is numExterne ../course.numExterne}} current{{/is}}">\n                C{{numExterne}}\n                <span class="picto-pari mini {{evenement}}"></span>\n            </li>\n            {{/each}}\n        </ul>\n        <a class="btn" href="{{findUrl \'home-hippique-date\' date}}">Retour au programme</a>\n    </div>\n</div>\n<h2 class="course-title">\n    <span class="date">{{formatMomentWithOffsetDate course.heureDepart course.timezoneOffset \'LL\'}}</span>\n    <b>&bull;</b> R{{reunion.numExterne}}C{{course.numExterne}} - {{formatMomentWithOffsetDate course.heureDepart course.timezoneOffset \'HH\\hmm\'}}\n    <b>&bull; {{reunion.hippodrome.libelleCourt}} - {{course.libelle}}</b>\n</h2>\n<div id="course-info" {{#is course.categorieStatut \'ANNULEE\'}}class="course-info-annulee"{{/is}}>\n    <div class="course-info-left">\n        <div id="info-detail">\n            <div id="conditions" class="clearfix">\n                <p>\n                    <strong>\n                        {{course.disciplineStr}} -\n                        {{course.montantTotalOffert}} € -\n                    </strong>\n                    {{course.distance}}m -\n                    {{course.nombreDeclaresPartants}} partants\n                    {{#if reunion.penetrometre}}\n                        {{#if reunion.penetrometre.intitule}}\n                            &nbsp;-&nbsp;Terrain&nbsp;{{getMessage reunion.penetrometre.intitule}}\n                        {{/if}}\n                    {{/if}}\n                    {{#if course.categorieParticularite}}\n                        &nbsp;-&nbsp;{{course.categorieStr}}\n                    {{/if}}\n                    {{#if course.corde}}\n                        {{getMessage course.corde}}\n                    {{/if}}\n                </p>\n                {{#isnt course.categorieStatut \'ANNULEE\'}}\n                    <a class="btn conditions-show">Détail des conditions</a>\n                {{/isnt}}\n            </div>\n        </div>\n        <div id="bets"></div>\n    </div>\n    {{#isnt course.categorieStatut \'ANNULEE\'}}\n        <div id="course-info-plus"></div>\n    {{/isnt}}\n    <p class="invisible">{{course.conditions}}</p>\n</div>\n';});

define('text!src/course/liste_courses/pronostic/templates/pronostic.hbs',[],function () { return '<div class="pronostic-content clearfix">\n    <span class="unit">Pronostic: {{selection}}</span>\n    {{#if signature}}\n    <span class="unitRight">({{signature}} - {{source}})</span>\n    {{else}}\n    <span class="unitRight">({{source}})</span>\n    {{/if}}\n</div>';});

define('src/course/liste_courses/pronostic/PronosticModel',['defaults'], function (Defaults) {
    

    return Backbone.Model.extend({

        url: function () {
            return Defaults.PRONOSTIC_URL + '/' + this.date + '/R' + this.reunionid + '/C' + this.courseid;
        },

        setParams: function (date, reunionid, courseid) {
            this.date = date;
            this.reunionid = reunionid;
            this.courseid = courseid;
            return this;
        }

    });
});
define('src/course/liste_courses/pronostic/PronosticView',[
    'template!./templates/pronostic.hbs',
    './PronosticModel'
], function (template, PronosticModel) {
    

    return Backbone.View.extend({

        id: 'pronostic',

        initialize: function () {
            this.model = new PronosticModel();

            this.listenTo(this.model, 'change', this.render);
            this.listenTo(this.model, 'error', this.empty);
        },

        setParams: function (date, reunionid, courseid) {
            this.model.setParams(date, reunionid, courseid);
        },

        clear: function () {
            this.model.clear({silent: true});
            this.empty();
        },

        reFetch: function () {
            this.model.fetch();
        },

        render: function () {
            this.$el.html(template(this.prepareJson()));
            this.delegateEvents();
        },

        prepareJson: function () {
            var selectionObjectArray = this.model.get('selection'),
                selection;

            selectionObjectArray = _.sortBy(selectionObjectArray, function () {
                return Number('rang');
            });
            selection = _.pluck(selectionObjectArray, 'num_partant').join(' - ');

            return {
                selection: selection,
                signature: this.model.get('signature'),
                source: this.model.get('source')
            };
        },

        empty: function () {
            this.$el.empty();
        }
    });
});

define('text!src/course/liste_courses/masses_enjeu/templates/masses-enjeu.hbs',[],function () { return '<h3 class="infos-title">\n    <div class="infos-dots"></div>\n    Total des enjeux\n</h3>\n\n<div id="masses-enjeu">\n    {{#each data}}\n    <div>\n        {{#if totalEnjeu}}\n            <span class="hour">A {{formatMomentWithOffsetDate momentWithOffset timezoneOffset \'HH\\hmm\'}}</span>\n            <div class="picto-pari small {{famille}} {{typePari}}"></div>\n            {{libelleVariant}} : <strong>{{formatMoney totalEnjeu}}</strong>\n        {{/if}}\n        </div>\n    {{else}}\n      Informations indisponibles\n    {{/each}}\n</div>\n';});

define('src/course/liste_courses/masses_enjeu/MassesEnjeuModel',[],function () {
    

    return Backbone.Model.extend({

        idAttribute: 'typePari'

    });
});
define('src/course/liste_courses/masses_enjeu/MassesEnjeuCollection',['defaults', './MassesEnjeuModel'], function (defaults, MassesEnjeuModel) {
    

    return Backbone.Collection.extend({

        model: MassesEnjeuModel,

        url: function () {
            return defaults.MASSES_ENJEU_URL + '/' + this.date + '/R' + this.reunionid + '/C' + this.courseid;
        },

        args: function (date, reunionid, courseid) {
            this.date = date;
            this.reunionid = reunionid;
            this.courseid = courseid;
        }
    });
});
define('src/alerting/alertingParser',['underscore'], function (_) {
    

    function AlertingError(message) {
        this.name = "AlertingError";
        this.message = message || "Erreur de parsing de l'alerte";
    }

    AlertingError.prototype = new Error();
    AlertingError.prototype.constructor = AlertingError;

    return {

        /**
         * {
            totalEnjeu: 12345678,
            typePari: "SIMPLE_GAGNANT",
            dateProgramme: 1349215200000,
            timezoneOffset: 3600000,
            reunion: 1,
            course: 1
        }
         * @return Object contenant les données de masse d'enjeu nécessaires par un composant métier
         * @throw AlertingError si message mal formé
         * */
        parseMasseEnjeu: function (message) {
            var parsed = {}, msgData, msgPari;

            if (this.isValidMessage(message)) {
                msgData = message.context;
                msgPari = msgData.pari;

                if (_.isObject(msgPari) && _.isString(msgPari.typePari) && _.isNumber(msgPari.reunion) &&
                    _.isNumber(msgPari.course) && _.isNumber(msgPari.dateProgramme) && _.isNumber(msgPari.timezoneOffset) &&
                    _.isNumber(msgData.totalEnjeu)) {

                    parsed.totalEnjeu = msgData.totalEnjeu;
                    parsed.typePari = msgPari.typePari;
                    parsed.dateProgramme = msgPari.dateProgramme;
                    parsed.timezoneOffset = msgPari.timezoneOffset;
                    parsed.reunion = msgPari.reunion;
                    parsed.course = msgPari.course;
                } else {
                    throw new AlertingError("Erreur de parsing de l'alerte: contenu invalide message.context");
                }
            } else {
                throw new AlertingError("Erreur de parsing de l'alerte: structure du message invalide");
            }
            return parsed;
        },

        isValidMessage: function (message) {
            return _.isObject(message) && _.isObject(message.context) && !_.isEmpty(message.context);
        }
    };
});
define('src/course/liste_courses/masses_enjeu/MassesEnjeuView',[
    'template!./templates/masses-enjeu.hbs',
    './MassesEnjeuModel',
    './MassesEnjeuCollection',
    'paris',
    'timeManager',
    'conf',
    'utils',
    'messages',
    'src/alerting/alertingParser'
], function (masseEnjeuTmpl, MassesEnjeuModel, MassesEnjeuCollection, Pari, timeManager, conf, utils, messages, alertingParser) {
    

    return Backbone.View.extend({

        id: 'masses-enjeu-view',

        initialize: function () {
            this.collection = new MassesEnjeuCollection();

            this.listenTo(this.collection, 'sync error change add', this.render);
            this.listenTo(Backbone, 'masse_enjeu:alert', this.updateFromAlert);
        },

        setParams: function (date, reunionid, courseid) {
            this.date = date;
            this.reunionid = reunionid;
            this.courseid = courseid;
            this.collection.args(date, reunionid, courseid);
        },

        reFetch: function () {
            this.collection.fetch();
        },

        render: function () {
            var rendered = masseEnjeuTmpl({data: this.prepareJSON()});
            this.$el.html(rendered);
            return this;
        },

        prepareJSON: function () {
            var data = {};

            if (this.collection.get('SIMPLE_GAGNANT') != null) {
                data.masseEnjeuSG = this.collection.get('SIMPLE_GAGNANT').toJSON();
                this.prepareMasseEnjeu(data.masseEnjeuSG);
            }
            if (this.collection.get('SIMPLE_PLACE') != null) {
                data.masseEnjeuSP = this.collection.get('SIMPLE_PLACE').toJSON();
                this.prepareMasseEnjeu(data.masseEnjeuSP);
            }

            return data;
        },

        prepareMasseEnjeu: function (masseEnjeu) {
            masseEnjeu.momentWithOffset = masseEnjeu.majTotalEnjeu;
            masseEnjeu.famille = utils.serviceMapper.getFamilyFromCodePari(masseEnjeu.typePari);
            masseEnjeu.libelleVariant = messages.get(utils.serviceMapper.getVariantFromCodePari(masseEnjeu.typePari));
        },

        updateFromAlert: function (message) {
            var parsedMsg, dateCourseNotif;

            try {
                parsedMsg = alertingParser.parseMasseEnjeu(message);
                dateCourseNotif = timeManager.momentWithOffset(parsedMsg.dateProgramme, parsedMsg.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);

                // see commonViewMethods.js
                if (this._isAlertOnCurrentCourse(this.date, this.reunionid, this.courseid,
                    dateCourseNotif, parsedMsg.reunion, parsedMsg.course)) {

                    // cela met aussi a jour pour les alertes de type couplé
                    // backbone peut ne faire aucun changement si les données sont identiques dans la collection
                    this.collection.update({typePari: parsedMsg.typePari, totalEnjeu: parsedMsg.totalEnjeu}, {remove: false});
                    return true;
                }
            } catch (e) {
                this.error("Impossible de parser l'alerte", message);
            }
            return false;
        }
    });
});

define('text!src/course/liste_courses/liste-paris/templates/liste-paris.hbs',[],function () { return '<h3 class="infos-title">\n    <span class="infos-dots"></span>\n    Les paris sur la course\n</h3>\n<ul class="inline-list">\n    {{#each parisFamiliesUIData}}\n    <li class="picto-pari picto-pari-action size44x18 {{ cssPictoFamily }}\n     {{#if pariUnique }}\n        {{ pariUnique.codePari }}\n     {{/if}}\n\n     {{#if ../isSpotActive}}\n         {{#if spotAutorise}}\n            pictospot\n         {{else}}\n            inactif\n         {{/if}}\n     {{/if}}"\n        data-family="{{ family }}"\n        data-date="{{ ../date }}"\n        data-courseid="{{ ../course.numOrdre }}"\n        data-reunionid="{{ ../course.numReunion }}">\n    </li>\n    {{/each}}\n\n    {{#if spotVisible}}\n        <li class="picto-pari picto-pari-spot size44x18 SPOT"></li>\n    {{/if}}\n</ul>';});

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

define('src/course/liste_courses/liste-paris/ListeParisMasterView',[
    'template!./templates/liste-paris.hbs',
    'src/common/PariPickerView',
    'utils',
    'timeManager',
    'src/course/pari/pariManager',
    'paris'
], function (template, PariPickerView, utils, timeManager, pariManager, pari) {
    

    return Backbone.View.extend({

        events: {
            'click .SPOT': 'triggerSpot'
        },

        initialize: function () {
            this.model = pariManager().getPari();

            this._initListeners();
            this.pariPickerView = new PariPickerView({el: this.el});
        },

        _initListeners: function () {
            this.listenTo(this.model, 'change:isSpot', this.toggleSpot);
        },

        render: function () {
            this.$el.html(template(this.prepareJson()));
            this.pariPickerView.load(
                this.options.date,
                this.options.course.numReunion,
                this.options.course.numOrdre,
                this.options.course.categorieStatut,
                this.options.course.statut
            );
            this.bindEvents();
            return this;
        },

        bindEvents: function () {
            if (this.pariPickerView.isUnpariable(this.options.course.categorieStatut) || this.pariPickerView.isTemporaryFinish(this.options.course.statut)) {
                this.undelegateEvents();
            } else {
                this.delegateEvents();
            }
        },

        setOptions: function (date, course, categorieStatut) {
            this.options.date = date;
            this.options.course = course;
            this.options.categorieStatut = categorieStatut;
            this.isSpotActive = false;
        },

        toggleSpot: function (model, isSpot) {
            this.isSpotActive = isSpot;
            this.render();
        },

        prepareJson: function () {
            var json = {};

            json.parisFamiliesUIData = utils.serviceMapper.createUIFamiliesData(this.options.course.paris);
            json.course = this.options.course;
            json.date = timeManager.momentWithOffset(this.options.course.heureDepart, this.options.course.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);
            json.isSpotActive = this.isSpotActive;
            json.spotVisible = utils.somePariSpot(this.options.course.paris);

            return json;
        },

        triggerSpot: function () {
            if (utils.somePariEnVente(this.options.course.paris)) {
                if (!((utils.somePariSpot(this.options.course.paris) && !this.model.get('family')) ||
                    (!this.model.get('isReport') && utils.somePariSpotInFamily(this.options.course.paris, this.model.get('family'))))) {
                    pariManager().set(pari.FAMILY, null);
                }
                Backbone.trigger('spot:isActive', !this.isSpotActive);
            }
        },

        beforeClose: function () {
            this.pariPickerView.close();
        }

    });
});

define('src/course/liste_courses/liste-paris/ListeParisView',[
    'src/course/liste_courses/liste-paris/ListeParisMasterView'
], function (ListeParisMasterView) {
    

    return ListeParisMasterView.extend({
        bindEvents: function () {
            this.$el.addClass('bets-selection-disabled');
            this.undelegateEvents();
        }
    });
});


define('text!src/course/liste_courses/rapports-definitifs/templates/liste-rapports-definitifs.hbs',[],function () { return '<h3 class="infos-title">\n    <span class="infos-dots rapports-dots"></span>\n    Rapports définitifs\n</h3>\n<ul class="inline-list">\n{{#each parisFamiliesUIData}}\n    {{#isnt family "TIC_TROIS"}}\n    {{#isnt family "REPORT"}}\n    <li class="picto-pari picto-pari-action size44x18 {{ cssPictoFamily }}"\n        data-family="{{ family }}"\n        data-date="{{ ../../../date }}"\n        data-courseid="{{ ../../../course.numOrdre }}"\n        data-reunionid="{{ ../../../course.numReunion }}">\n    </li>\n    {{/isnt}}\n    {{/isnt}}\n{{/each}}\n</ul>';});

define('text!src/course/liste_courses/rapports-definitifs/templates/rapports-definitifs-layer.hbs',[],function () { return '<ul>\n{{#each .}}\n    {{#isnt family "TIC_TROIS"}}\n    {{#isnt family "REPORT"}}\n    <li data-type-pari="{{ family }}"><a><div class="picto-pari size44x18 {{ cssPictoFamily }}"></div></a></li>\n    {{/isnt}}\n    {{/isnt}}\n{{/each}}\n</ul>\n\n<div id="rapports-definitifs-table" class="clearfix"></div>\n\n<div id="container-bottom">\n    <div id="rapports-definitifs-tirelire"></div>\n    <div id="rapports-definitifs-legende"></div>\n</div>\n';});

define('text!src/course/liste_courses/rapports-definitifs/templates/rapports-definitifs-table.hbs',[],function () { return '<table>\n  <thead>\n  <tr>\n      <td>Arrivée</td>\n\n      {{#if hasColumnType}}\n      <td>Type</td>\n      {{/if}}\n\n      <td class="right">Rapport</td>\n\n      {{#if hasColumnMisesGagnantes}}\n      <td class="right">Mises gagnantes</td>\n      {{/if}}\n  </tr>\n  </thead>\n  <tbody>\n\n    {{#stripes rapports "odd" "even"}}\n    <tr class="{{ stripeClass }}">\n        <td>{{ join combinaison \' - \' }}</td>\n\n        {{#if ../hasColumnType}}\n        <td>{{ libelle }}</td>\n        {{/if}}\n\n        <td class="right">{{ formatMoney dividende }}</td>\n\n        {{#if ../hasColumnMisesGagnantes}}\n        <td class="right">{{ nombreGagnants }}</td>\n        {{/if}}\n    </tr>\n    {{/stripes}}\n\n  </tbody>\n</table>';});

define('text!src/course/liste_courses/rapports-definitifs/templates/rapports-definitifs-legende.hbs',[],function () { return '<p>\n{{#if pourUnEuro}}\nPour 1€\n{{else}}\nPour {{ legendeFormat }}\n{{/if}}\n</p>';});

define('text!src/course/liste_courses/rapports-definitifs/templates/rapports-definitifs-no-table.html',[],function () { return '<div class="alternative">\n    Calcul en cours\n</div>';});

define('text!src/course/liste_courses/rapports-definitifs/templates/tirelire.hbs',[],function () { return '{{#if numeroPlus}}\n<div class="numero-plus">\n    <span class="libelle">N° PLUS</span>\n    <span class="valeur">{{ numeroPlus }}</span>\n</div>\n{{/if}}\n\n<div class="tirelire">\n    Tirelire du {{ date }} :\n    <span class="valeur">{{ formatMoneyEuros montant }}</span>\n</div>\n\n{{#if numeroPlus}}\n  {{#if text}}\n  <div class="text-infos" style="clear: both;">\n      {{ text }}\n  </div>\n  {{/if}}\n{{/if}}';});

define('src/course/liste_courses/rapports-definitifs/TirelireModel',['defaults'], function (Defaults) {
    

    return Backbone.Model.extend({
        initialize: function (options) {
            this.date = options.date;
        },

        url: function () {
            return Defaults.TIRELIRE_DATE_URL
                .replace('{date}', this.date);
        }
    });
});
define('src/course/liste_courses/rapports-definitifs/TirelireView',[
    'template!./templates/tirelire.hbs',
    './TirelireModel',
    'timeManager',
    'messages'
], function (template, TirelireModel, timeManager, messages) {
    

    return Backbone.View.extend({

        initialize: function () {
            this.tirelire = new TirelireModel({date: this.options.date});
            this.tirelire.fetch({
                success: _.bind(this.render, this)
            });
        },

        prepareJSON: function () {
            var json = this.tirelire.toJSON();

            json.date = timeManager.momentWithOffset(json.date, json.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR_SLASHED);
            json.text = messages.get('RAPPORTS_DEFINITIS.MULTIPLICATION_GAIN_NUMERO_PLUS');

            return json;
        },

        render: function () {
            this.$el.html(template(this.prepareJSON()));
            return this;
        }
    });
});

define('src/course/liste_courses/rapports-definitifs/RapportsDefinitifsCollection',[
    'defaults',
    'utils'
], function (defaults, utils) {
    

    return Backbone.Collection.extend({

        mappingTypePariLibelle : {
            'SIMPLE_GAGNANT': 'Gagnant',
            'SIMPLE_PLACE': 'Placé',
            'COUPLE_GAGNANT': 'Gagnant',
            'COUPLE_PLACE': 'Placé',
            'COUPLE_ORDRE': 'Ordre',
            'TRIO': '',
            'TRIO_ORDRE': 'Ordre'
        },

        url: function () {
            return defaults.RAPPORTS_DEFINITIFS
                .replace('{date}', this.date)
                .replace('{numReunion}', this.numReunion)
                .replace('{numCourse}', this.numCourse);
        },

        setOptions: function (date, numReunion, numCourse) {
            this.date = date;
            this.numReunion = numReunion;
            this.numCourse = numCourse;
            return this;
        },

        parse: function (json) {
            this.mergeFamille(json, 'SIMPLE');
            this.mergeFamille(json, 'COUPLE');
            this.mergeFamille(json, 'TRIO');
            return _.compact(json);
        },

        mergeFamille: function (json, famillePari) {
            var newRapports = [],
                newPari = {typePari: famillePari, miseBase: 150};

            _.each(json, function (pari, i) {

                if (pari) {
                    var familyPari = utils.serviceMapper.getFamilyFromCodePari(pari.typePari);

                    if (familyPari === famillePari) {

                        _.each(pari.rapports, function (rapport, i) {
                            rapport.libelle = this.mappingTypePariLibelle[pari.typePari];
                        }, this);

                        newRapports = _.union(newRapports, pari.rapports);
                        delete json[i];
                    }
                }
            }, this);

            newPari.rapports = newRapports;
            if (json) {
                json.push(newPari);
            }
        }
    });
});

define('src/course/liste_courses/rapports-definitifs/LayerRapportsDefinitifsView',[
    'template!./templates/rapports-definitifs-layer.hbs',
    'template!./templates/rapports-definitifs-table.hbs',
    'template!./templates/rapports-definitifs-legende.hbs',
    'text!./templates/rapports-definitifs-no-table.html',
    './TirelireView',
    './RapportsDefinitifsCollection',
    'utils',
    'tagCommander'
], function (layerTmpl, tableTmpl, legendeTmpl, noTableTmpl, TirelireView, RapportsDefinitifsCollection, utils, tagCommander) {
    

    return Backbone.View.extend({

        id: 'rapports-definitifs',

        events: {
            'click li': 'switchTab'
        },

        initialize: function () {
            this.deferred = $.Deferred();

            this.collection = new RapportsDefinitifsCollection().setOptions(this.options.date, this.options.course.numReunion, this.options.course.numExterne);
            this.collection.fetch({
                success: _.bind(this.render, this)
            });
        },

        switchTab: function (e) {
            var $currentTarget = $(e.currentTarget),
                typePari = $currentTarget.data('type-pari'),
                containerTirelire = this.$('#rapports-definitifs-tirelire');

            this.$('li').removeClass('active');
            $currentTarget.addClass('active');
            this.renderTable(typePari);

            if (typePari === 'QUINTE_PLUS') {
                this.tirelireRapportsDefinitifsView = new TirelireView({date: this.options.date});
                containerTirelire.html(this.tirelireRapportsDefinitifsView.el);
                this.renderLegende('QUINTE_PLUS');
            } else {
                containerTirelire.empty();
                this.renderLegende(typePari);
            }
        },

        render: function () {
            this.deferred.resolve();

            this.$el.html(layerTmpl(this.prepareParisJSON()));
            this.renderTable(this.options.familyPari);

            this.$('li').removeClass('active');
            $('li[data-type-pari="' + this.options.familyPari + '"]').addClass('active');

            if (this.options.familyPari === 'QUINTE_PLUS') {
                this.tirelireRapportsDefinitifsView = new TirelireView({date: this.options.date});
                this.$('#rapports-definitifs-tirelire').html(this.tirelireRapportsDefinitifsView.el);
                this.renderLegende('QUINTE_PLUS');
            } else {
                this.$('#rapports-definitifs-tirelire').empty();
                this.renderLegende(this.options.familyPari);
            }

            return this;
        },

        sendTag: function (typePari) {
            tagCommander.sendTagIfOnline(
                'hippique.parier.reunion.course.rapports_definitifs',
                {
                    bet_reunion_id: this.options.course.numReunion,
                    bet_course_id: this.options.course.numOrdre,
                    bet_type: typePari
                }
            );
        },

        renderTable: function (typePari) {
            var pariWithRapports = this.preparePariJSON(typePari);
            if (pariWithRapports) {
                this.$('#rapports-definitifs-table').html(tableTmpl(pariWithRapports));
            } else {
                this.$('#rapports-definitifs-table').html(noTableTmpl);
            }
            this.sendTag(typePari);
            return this;
        },

        renderLegende: function (typePari) {
            var legende = this.prepareLegendeJSON(typePari);
            if (legende) {
                this.$('#rapports-definitifs-legende').html(legendeTmpl(legende));
            } else {
                this.$('#rapports-definitifs-legende').empty();
            }
            return this;
        },

        prepareParisJSON: function () {
            return utils.serviceMapper.createUIFamiliesData(this.options.course.paris);
        },

        prepareLegendeJSON: function (typePari) {
            var pari = this.collection.where({typePari: typePari})[0],
                json = {},
                legendeFormat;

            if (pari && !_.isEmpty(pari.get('rapports'))) {
                json = pari.toJSON();

                if (typePari === 'SIMPLE' || typePari === 'COUPLE' || typePari === 'TRIO') {
                    json.pourUnEuro = true;
                } else {
                    json.pourUnEuro = false;
                }

                legendeFormat = pari.get('miseBase') / 100;
                if (Math.round(legendeFormat) === legendeFormat) {
                    json.legendeFormat = accounting.formatMoney(legendeFormat, "€", 0);
                } else {
                    json.legendeFormat = accounting.formatMoney(legendeFormat, "€", 2);
                }

                return json;
            }
            return null;
        },

        preparePariJSON: function (typePari) {
            var pari = this.collection.where({typePari: typePari})[0],
                json = {};

            if (pari && !_.isEmpty(pari.get('rapports'))) {
                json = pari.toJSON();

                if (typePari === 'DEUX_SUR_QUATRE') {
                    json.hasColumnType = false;
                    json.hasColumnMisesGagnantes = false;
                } else if (typePari === 'PICK5') {
                    json.hasColumnType = false;
                    json.hasColumnMisesGagnantes = true;
                } else if (typePari === 'SIMPLE' || typePari === 'COUPLE' || typePari === 'TRIO') {
                    json.hasColumnMisesGagnantes = false;
                    json.hasColumnType = true;
                } else {
                    json.hasColumnType = true;
                    json.hasColumnMisesGagnantes = true;
                }

                return json;
            }
            return null;
        },

        promise: function () {
            return this.deferred.promise();
        }
    });

});

define('src/course/liste_courses/rapports-definitifs/ListeRapportsDefinitifsView',[
    'template!./templates/liste-rapports-definitifs.hbs',
    './LayerRapportsDefinitifsView',
    'utils',
    'timeManager',
    'modalManager'
], function (template, LayerRapportsDefinitifsView, utils, timeManager, modalManager) {
    

    return Backbone.View.extend({

        events: {
            'click .picto-pari-action': 'showDetailRapportDefinitifs'
        },

        showDetailRapportDefinitifs: function (e) {
            var $currentTarget = $(e.currentTarget),
                familyPari = $currentTarget.data('family');

            modalManager.pane(
                new LayerRapportsDefinitifsView({date: this.date, course: this.course, familyPari: familyPari}),
                $currentTarget.parent(),
                'Rapports définitifs',
                {
                    cssClass: 'popin detail-popin rapports-definitifs',
                    offset: {x: -30, y: 0},
                    position: 'none',
                    $target: $currentTarget.parent(),
                    minWidth: 345,
                    category: 'layer'
                }
            );
        },

        render: function () {
            this.$el.html(template(this.prepareJson()));
            this.delegateEvents();
            return this;
        },

        prepareJson: function () {
            var json = {};

            json.parisFamiliesUIData = utils.serviceMapper.createUIFamiliesData(this.course.paris);
            json.course = this.course;
            json.date = timeManager.momentWithOffset(this.course.heureDepart, this.course.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);
            return json;
        },

        setCourse: function (date, course) {
            this.date = date;
            this.course = course;
            return this;
        }
    });
});

define('text!src/course/liste_courses/layers/templates/layers-buttons.html',[],function () { return '<li class="pronostics first-child"><span>Pronostics</span></li>\n<li class="rapports"><span>Rapports probables</span></li>\n<li class="plus-joues"><span>Les + joués</span></li>\n<li class="perf last-child"><span>Perf.</span></li>\n';});

define('text!src/course/liste_courses/layers/rapports-probables/templates/rapports-probables-nav.hbs',[],function () { return '<li>\n    <a href="#" class="btn">Couplé Gagnant</a>\n    <ul>\n        <li><a href="#" class="btn btn-green btn-collapse btn-collapse-first" data-type-pari="COUPLE_GAGNANT" data-type-rapport="rapportReference">Référence</a></li><!--\n        --><li><a href="#" class="btn btn-green btn-collapse btn-collapse-last" data-type-pari="COUPLE_GAGNANT" data-type-rapport="rapportDirect">Direct</a></li>\n    </ul>\n</li><!--\n--><li>\n    <a href="#" class="btn">Couplé Ordre</a>\n    <ul>\n        <li><a href="#" class="btn btn-green btn-collapse btn-collapse-first" data-type-pari="COUPLE_ORDRE" data-type-rapport="rapportReference">Référence</a></li><!--\n        --><li><a href="#" class="btn btn-green btn-collapse btn-collapse-last" data-type-pari="COUPLE_ORDRE" data-type-rapport="rapportDirect">Direct</a></li>\n    </ul>\n</li><!--\n--><li><a href="#" class="btn" data-type-pari="SIMPLE_PLACE">Simple Placé</a></li>\n';});

define('src/course/liste_courses/layers/rapports-probables/NavRapportsProbablesView',[
    'template!./templates/rapports-probables-nav.hbs'
], function (template) {
    

    return Backbone.View.extend({
        selfRender: true,

        className: 'rapports-probables-nav',

        tagName: 'ul',

        events: {
            'click li a': 'switchTabs'
        },

        switchTabs: function (e) {
            e.preventDefault();
            var $target = $(e.currentTarget);

            $target
                .closest('ul')
                    .find('.btn-active')
                        .removeClass('btn-active')
                    .end()
                    .find('ul')
                        .hide()
                    .end()
                .end()
                .addClass('btn-active')
                .next('ul')
                    .show()
                    .find('.btn:first')
                        .addClass('btn-active')
                        .trigger('click');

            if (!$target.data('type-pari')) {
                return;
            }

            this.trigger('switchRapport', {
                typePari: $target.data('type-pari'),
                typeRapport: $target.data('type-rapport')
            });
        },

        render: function () {
            this.$el.html(template());
            this.$el.find('>li:first>a')
                        .addClass('btn-active')
                        .next()
                            .show()
                                .find('>li:first>a')
                                    .addClass('btn-active');

            return this;
        }
    });
});

define('text!src/course/liste_courses/layers/rapports-probables/templates/rapports-probables-simple.hbs',[],function () { return '    <caption>Simple Placé</caption>\n    <thead>\n        <tr>\n            <th class="numero">N°</th>\n            <th>Cheval</th>\n            <th>Jockey/Driver</th>\n            <th>Casaque</th>\n            <th>Simple Placé<br />Min - Max</th>\n        </tr>\n    </thead>\n    <tfoot></tfoot>\n    <tbody>\n        {{#stripes rapportsFormated "odd" "even"}}\n        <tr class="{{stripeClass}}">\n            <td class="txtC"><strong>{{numerosParticipant}}</strong></td>\n            <td>\n                <span class="unit" title="{{nom}}{{#if engagement}}suppl.{{/if}}">\n                    <strong>{{formatForCell nom 20}}</strong>\n                </span>\n                {{#if engagement}}\n                <span class="unitRight paddingRight5">\n                    <b class="icoSuppl">&nbsp;</b>\n                </span>\n                {{/if}}\n            </td>\n            <td><span title="{{driver}}">{{#if driver}}{{formatForCell driver 13}}{{/if}}</span></td>\n            <td class="txtC">\n                <img class="ico" src="css/images/transparent.png" alt="casaque" width="19" height="19" style="{{pictoCasaqueStyle ../urlCasaque numPmu}}"></div>\n            </td>\n            <td class="txtC">{{minRapportProbable}} - {{maxRapportProbable}}</td>\n        </tr>\n        {{/stripes}}\n    </tbody>\n';});

define('text!src/course/liste_courses/layers/rapports-probables/templates/rapports-probables-couple.hbs',[],function () { return '    <caption>couplé {{typeCouple}} - <em>{{#if isReference}}Référence{{else}}Direct{{/if}} à {{formatMomentWithOffsetDate dateMajDirect timezoneOffset \'HH\\hmm\'}}</em></caption>\n    <thead></thead>\n    <tfoot></tfoot>\n    <tbody>\n        {{#stripes rapportsFormated "odd" "even"}}\n        <tr class="{{stripeClass}}">\n            {{#each this}}\n            {{#if isTitle}}\n                <th>{{{label}}}</th>\n                {{else}}\n                    {{#if isEmpty}}\n                    <td>{{{label}}}</td>\n                    {{else}}\n                        {{#if isEqual}}\n                        <td class="empty">{{{label}}}</td>\n                        {{else}}\n                        <td class="hasValue">{{label}}</td>\n                        {{/if}}\n                    {{/if}}\n                {{/if}}\n            {{/each}}\n        </tr>\n        {{/stripes}}\n    </tbody>\n';});

define('src/course/liste_courses/layers/rapports-probables/TableRapportsProbablesView',[
    'template!./templates/rapports-probables-simple.hbs',
    'template!./templates/rapports-probables-couple.hbs',
    'tagCommander',
    'typeDeSite'
], function (simpleTmpl, coupleTmpl, tagCommander, typeDeSite) {
    

    return Backbone.View.extend({

        selfRender: true,

        tagName: 'table',

        className: 'rapports-probables-table table-layer',

        defaults: function () {
            return {
                typePari : 'COUPLE_GAGNANT',
                typeRapport : 'rapportReference'
            };
        },

        initialize: function () {
            this.templates = {
                simple: simpleTmpl,
                couple: coupleTmpl
            };

            this.options = _.extend(this.defaults(), this.options);
        },

        render: function (options) {
            this.sendTag();

            if (options) {
                _.extend(this.options, options);
            }

            switch (this.options.typePari) {
            case 'COUPLE_GAGNANT':
            case 'COUPLE_ORDRE':
                this.$el.html(this.templates.couple(this.model.getRapportsCoupleFormated(this.options.typeRapport)));
                break;
            case 'SIMPLE_PLACE':
                this.$el.html(this.templates.simple(this.model.getRapportsSimpleFormated()));
                break;
            default:
                break;
            }

            return this;
        },

        sendTag: function () {
            tagCommander.sendTags(
                'hippique.parier.reunion.course.rapports_probables',
                'programme_resultats.course.rapports',
                {
                    bet_type: this.model.get('typePari'),
                    bet_reunion_id: this.model.get('numReunion'),
                    bet_course_id: this.model.get('numCourse')
                }
            );
        }
    });
});

define('src/course/liste_courses/layers/rapports-probables/LayerRapportsProbablesModel',[
    'defaults'
], function (Defaults) {
    

    return Backbone.Model.extend({
        initialize: function (options) {
            this.defaults = {
                numReunion: null,
                numCourse: null,
                typePari: null,
                date: null
            };

            this.options = {};

            _.extend(this.options, this.defaults, options);
        },

        setOptions: function (options) {
            _.extend(this.options, options);
        },

        url: function () {
            return Defaults
                .RAPPORTS_PROBABLES_URL
                .replace('{date}', this.options.date)
                .replace('{numReunion}', this.options.numReunion)
                .replace('{numCourse}', this.options.numCourse)
                .replace('{typePari}', this.options.typePari);
        },

        parse: function (json) {
            if (!json) {
                return {};
            }

            return json;
        },

        _getMatchedParticipants: function (datas, rowIndex, colIndex) {
            var key = rowIndex + '-' + colIndex;
            return _.filter(datas, function (item) {
                return item.numerosParticipant.join('-') === key;
            });
        },

        _getSingleRapport: function (rowIndex, colIndex, typeRapport) {
            var rapport;

            if (!rowIndex || !colIndex) {
                return {
                    isTitle: true,
                    label: !rowIndex && !colIndex ? '&nbsp;' : (!rowIndex) ? colIndex : rowIndex
                };
            }

            if (rowIndex == colIndex) {
                return {
                    isEqual: true,
                    label: '&nbsp;'
                };
            }

            if (rowIndex > colIndex && this.options.typePari == 'COUPLE_GAGNANT') {
                return {
                    isEmpty: true,
                    label: '&nbsp;'
                };
            }

            rapport = this._getMatchedParticipants(this.get('rapportsParticipant'), rowIndex, colIndex);

            if (!_.isArray(rapport) || !rapport.length || !rapport[0][typeRapport]) {
                return {
                    isEmpty: true,
                    label: ' - '
                };
            }

            return {
                label: Math.round(rapport[0][typeRapport])
            };
        },

        getRapportsCoupleFormated: function (typeRapport) {
            var dimension = this.get('nbParticipants'),
                i = 0,
                j = 0,
                rows = [];

            for (i = 0; i <= dimension; i++) {
                rows[i] = []; // Parce que push c'est le mal
                for (j = 0; j <= dimension; j++) {
                    rows[i][j] = this._getSingleRapport(i, j, typeRapport);
                }
            }

            return {
                isReference: typeRapport == "rapportReference" ? true : false,
                typeCouple: this.options.typePari.replace('COUPLE_', ''),
                dateMajDirect: this.get('dateMajDirect'),
                rapportsFormated: rows
            };
        },

        getRapportsSimpleFormated: function () {
            return {
                rapportsFormated: _.sortBy(this.get('rapportsParticipant'), function (item) {
                    return item.numPmu;
                }),
                urlCasaque: _.findWhere(this.get('spriteCasaques'), {heightSize: 19}).url
            };
        }
    });
});

define('text!src/course/liste_courses/layers/templates/layer-title.hbs',[],function () { return 'R{{numReunion}} C{{numCourse}} - {{libelle}}';});

define('text!src/course/liste_courses/layers/templates/layer-empty.hbs',[],function () { return '<p class="infos-indispo">Les informations ne sont pas disponibles.</p>\n';});

define('text!src/course/liste_courses/layers/templates/layer-error.hbs',[],function () { return '<p class="infos-indispo">Une erreur est survenue, impossible d\'afficher les informations.</p>\n';});

define('text!src/course/liste_courses/layers/templates/layer-load.hbs',[],function () { return '<p>Chargement en cours...</p>\n';});

define('src/course/liste_courses/layers/LayerView',[
    'template!./templates/layer-title.hbs',
    'template!./templates/layer-empty.hbs',
    'template!./templates/layer-error.hbs',
    'template!./templates/layer-load.hbs'
], function (titleTmpl, emptyTmpl, errorTmpl, loadTmpl) {
    

    return Backbone.View.extend({

        templates: {
            title: titleTmpl,
            empty: emptyTmpl,
            error: errorTmpl,
            load: loadTmpl
        },

        initialize: function () {
            this.deferred = $.Deferred();
            this.update();
        },

        update: function () {
            this.model.fetch();
        },

        getLayerTemplate: function (key, oDatas) {
            return this.templates[key](oDatas);
        },

        render: function (model, response, options) {
            if (options.xhr.status === 204) {
                this.renderEmpty();
            } else {
                this.deferred.resolve();
                this.renderViews();
            }
            return this;
        },

        renderViews: function () {
            this.$el.empty().append(this.subViews[0].render().el);
        },

        renderError: function () {
            this.deferred.reject();
            this.errorEl()
                .empty()
                .append(this.getLayerTemplate('error', this.options));
            return this;
        },

        renderEmpty: function () {
            this.deferred.reject();
            this.errorEl()
                .empty()
                .append(this.getLayerTemplate('empty', this.options));
            return this;
        },

        errorEl: function () {
            return this.$el;
        },

        promise: function () {
            return this.deferred.promise();
        },

        beforeClose: function () {
            this.trigger('close');
        }
    });
});

define('src/course/liste_courses/layers/rapports-probables/LayerRapportsProbablesView',[
    './NavRapportsProbablesView',
    './TableRapportsProbablesView',
    './LayerRapportsProbablesModel',
    '../LayerView'
], function (NavRapportsProbablesView, TableRapportsProbablesView, LayerRapportsProbablesModel, LayerView) {
    

    return LayerView.extend({

        className: 'layer-content',

        libelle: 'Rapports probables',

        initialize: function () {
            _.extend(this.options, {libelle: this.libelle});

            this.model = new LayerRapportsProbablesModel({
                numReunion: this.options.numReunion,
                numCourse: this.options.numCourse,
                typePari: 'COUPLE_GAGNANT',
                typeRapport: 'rapportReference',
                date: this.options.date
            });

            this.tableRapportsProbablesView = new TableRapportsProbablesView({model: this.model});
            this.navRapportsProbablesView = new NavRapportsProbablesView();

            this.subViews = [
                this.tableRapportsProbablesView,
                this.navRapportsProbablesView
            ];
            this.$errorEl = $('<div class="message" />').hide();          //for errorEl()
            this.$el.prepend(this.$errorEl).hide();

            this.alreadyRendered = false;

            this.listenTo(this.model, 'sync', this.render);
            this.listenTo(this.model, 'error', this.renderError);
            this.listenTo(this.navRapportsProbablesView, 'switchRapport', this.switchRapport);

            LayerView.prototype.initialize.call(this);

            return this;
        },

        update: function () {
            this.model.fetch();
        },

        //CONTENT-CONTENT-CONTENT
        switchRapport: function (options) {
            this.$el.hide();
            _.extend(this.options, options);
            this.model.setOptions(this.options);
            this.model.fetch();
        },

        _appendView: function (oView) {
            this.$el.append(oView.render().el);
        },

        renderTable: function () {
            this.tableRapportsProbablesView.render(this.options);
            this.tableRapportsProbablesView.$el.show();
        },

        renderViews: function () {
            this.$errorEl.hide();
            if (this.alreadyRendered) {
                this.renderTable();
                this.$el.show();
                return this;
            }
            _.each(this.subViews, _.bind(this._appendView, this));
            this.alreadyRendered = true;
            this.$el.show();
            return this;
        },

        renderEmpty: function () {
            if (!this.alreadyRendered) {
                this.renderViews();
            }
            LayerView.prototype.renderEmpty.call(this);
            this.tableRapportsProbablesView.$el.hide();
            this.$el.show();
            return this;
        },

        renderError: function () {
            if (!this.alreadyRendered) {
                this.renderViews();
            }
            LayerView.prototype.renderError.call(this);
            this.tableRapportsProbablesView.$el.hide();
            this.$el.show();
            return this;
        },

        errorEl: function () {
            this.$errorEl.show();
            return this.$errorEl;
        }

    });
});

define('text!src/course/liste_courses/layers/pronostics/templates/pronostics-prono.hbs',[],function () { return '<div class="pronostic-equidia pronostic-section">\n    {{#unless .}}\n        <h3>Le pronostic</h3>\n        <p>Le pronostic n\'est pas disponible.</p>\n    {{else}}\n\n    <div class="encart">\n        <h3>Le pronostic {{source}}</h3>\n        <p>{{texte}}</p>\n    </div>\n\n    {{/unless}}\n</div>\n';});

define('text!src/course/liste_courses/layers/pronostics/templates/pronostics-synthese.hbs',[],function () { return '<div class="pronostic-synthese-presse pronostic-section">\n    <h3>La synthèse de la presse</h3>\n\n    {{#unless .}}\n        <p>La synthèse de la presse n\'est pas disponible.</p>\n    {{else}}\n\n    <div {{#unless @isQuinte}}class="wrapper clearfix"{{/unless}}>\n        {{#each .}}\n        <table class="table-layer">\n            <caption>{{getMessage \'PRONOSTIC.\' intitule}}</caption>\n            {{#stripes classement \'odd\' \'even\'}}\n            <tr class="{{ stripeClass }}">\n                <td class="txtC txtS first">{{numPmu}}</td>\n                <td class="txtL txtS">{{capitaliseFirstLetters nom}}</td>\n                {{#if @isQuinte}}\n                <td class="txtR last">{{pluralize nbPoints \'pt\'}}</td>\n                {{else}}\n                <td class="txtR last">{{nbFoisCite}} fois</td>\n                {{/if}}\n            </tr>\n            {{/stripes}}\n        </table>\n        {{/each}}\n    </div>\n\n    <p>\n        Pour établir cette synthèse on attribue: <br/>\n        8 points à chaque cheval placé en tête d\'un pronostic, puis 7 points pour le deuxième, 6 points pour\n        le troisième, 5 points pour le quatrième, 4 points pour le cinquième, 3 points pour le sixième, 2 points pour\n        le septième, et 1 point pour le huitième cheval.\n    </p>\n\n    {{/unless}}\n</div>\n';});

define('text!src/course/liste_courses/layers/pronostics/templates/pronostics-commentaire.hbs',[],function () { return '<div class="pronostic-commentaires-avant-course">\n    <h3>Commentaires avant course</h3>\n\n    {{#unless .}}\n        <p>Les commentaires sur les participants ne sont pas disponibles.</p>\n    {{else}}\n\n    <table class="table-layer">\n        {{#stripes . \'odd\' \'even\'}}\n        <tr class="{{ stripeClass }}">\n            <td class="first txtC txtS">{{numPmu}}</td>\n            <td class="txtL txtS">{{capitaliseFirstLetters nom}}</td>\n            <td class="txtL last">{{commentaire}}</td>\n        </tr>\n        {{/stripes}}\n    </table>\n\n    {{/unless}}\n</div>\n';});

define('text!src/course/liste_courses/layers/pronostics/templates/pronostics-avis.hbs',[],function () { return '<h3>Les avis de la presse</h3>\n\n\n{{#unless .}}\n    <p>Les avis de la Presse ne sont pas disponibles.</p>\n{{else}}\n\n<div class="carousel-button prev"></div>\n<div class="wrapper clearfix">\n    {{#wrapOnModulo . @modulo \'div\' \'pack-avis\'}}\n        <table class="table-layer">\n            <caption>{{societe}}</caption>\n            <tr>\n                <td colspan="2" class="syntheses"><div class="synthese txtL">{{journaliste}}<span>{{cumulPoints}}</span></div></td>\n            </tr>\n            {{#stripes pronostics \'even\' \'odd\'}}\n            <tr class="{{ stripeClass }}">\n                <td class="first txtC txtS">{{numPmu}}</td>\n                <td class="last txtL txtS nom-cheval">{{capitaliseFirstLetters nom}}</td>\n            </tr>\n            {{/stripes}}\n\n            {{#if @isQuinte}}\n            <tr class="even">\n                <td colspan="2" class="performances">\n                {{#each historiques}}\n                    <div>{{getMessage pariType}}\n                        <span>{{cumulPoints}} ({{ecart}})</span>\n                    </div>\n                {{/each}}\n                </td>\n            </tr>\n            {{/if}}\n        </table>\n    {{/wrapOnModulo}}\n</div>\n\n<div class="carousel-button next"></div>\n\n<ul class="carousel-pager"> </ul>\n\n{{#if @isQuinte}}\n<p class="clearfix">\n    Le nombre de points situé à droite sous le nom du quotidien représente le nombre de points cumulés sur 12 mois grâce aux différents Quinté+, Quarté+ et Tiercé trouvés sur cette période (5pts pour un Quinté+, 3Pts pour un Quarté+ et 2pts pour un Tiercé).\n</p>\n{{/if}}\n\n{{/unless}}\n';});

/*!
 * jQuery Cycle Plugin (with Transition Definitions)
 * Examples and documentation at: http://jquery.malsup.com/cycle/
 * Copyright (c) 2007-2012 M. Alsup
 * Version: 2.9999.81 (15-JAN-2013)
 * Dual licensed under the MIT and GPL licenses.
 * http://jquery.malsup.com/license.html
 * Requires: jQuery v1.7.1 or later
 */
;(function($, undefined) {
    

    var ver = '2.9999.81';

    function debug(s) {
        if ($.fn.cycle.debug)
            log(s);
    }
    function log() {
        if (window.console && console.log)
            console.log('[cycle] ' + Array.prototype.join.call(arguments,' '));
    }
    $.expr[':'].paused = function(el) {
        return el.cyclePause;
    };


// the options arg can be...
//   a number  - indicates an immediate transition should occur to the given slide index
//   a string  - 'pause', 'resume', 'toggle', 'next', 'prev', 'stop', 'destroy' or the name of a transition effect (ie, 'fade', 'zoom', etc)
//   an object - properties to control the slideshow
//
// the arg2 arg can be...
//   the name of an fx (only used in conjunction with a numeric value for 'options')
//   the value true (only used in first arg == 'resume') and indicates
//	 that the resume should occur immediately (not wait for next timeout)

    $.fn.cycle = function(options, arg2) {
        var o = { s: this.selector, c: this.context };

        // in 1.3+ we can fix mistakes with the ready state
        if (this.length === 0 && options != 'stop') {
            if (!$.isReady && o.s) {
                log('DOM not ready, queuing slideshow');
                $(function() {
                    $(o.s,o.c).cycle(options,arg2);
                });
                return this;
            }
            // is your DOM ready?  http://docs.jquery.com/Tutorials:Introducing_$(document).ready()
            log('terminating; zero elements found by selector' + ($.isReady ? '' : ' (DOM not ready)'));
            return this;
        }

        // iterate the matched nodeset
        return this.each(function() {
            var opts = handleArguments(this, options, arg2);
            if (opts === false)
                return;

            opts.updateActivePagerLink = opts.updateActivePagerLink || $.fn.cycle.updateActivePagerLink;

            // stop existing slideshow for this container (if there is one)
            if (this.cycleTimeout)
                clearTimeout(this.cycleTimeout);
            this.cycleTimeout = this.cyclePause = 0;
            this.cycleStop = 0; // issue #108

            var $cont = $(this);
            var $slides = opts.slideExpr ? $(opts.slideExpr, this) : $cont.children();
            var els = $slides.get();

            if (els.length < 2) {
                log('terminating; too few slides: ' + els.length);
                return;
            }

            var opts2 = buildOptions($cont, $slides, els, opts, o);
            if (opts2 === false)
                return;

            var startTime = opts2.continuous ? 10 : getTimeout(els[opts2.currSlide], els[opts2.nextSlide], opts2, !opts2.backwards);

            // if it's an auto slideshow, kick it off
            if (startTime) {
                startTime += (opts2.delay || 0);
                if (startTime < 10)
                    startTime = 10;
                debug('first timeout: ' + startTime);
                this.cycleTimeout = setTimeout(function(){go(els,opts2,0,!opts.backwards);}, startTime);
            }
        });
    };

    function triggerPause(cont, byHover, onPager) {
        var opts = $(cont).data('cycle.opts');
        if (!opts)
            return;
        var paused = !!cont.cyclePause;
        if (paused && opts.paused)
            opts.paused(cont, opts, byHover, onPager);
        else if (!paused && opts.resumed)
            opts.resumed(cont, opts, byHover, onPager);
    }

// process the args that were passed to the plugin fn
    function handleArguments(cont, options, arg2) {
        if (cont.cycleStop === undefined)
            cont.cycleStop = 0;
        if (options === undefined || options === null)
            options = {};
        if (options.constructor == String) {
            switch(options) {
            case 'destroy':
            case 'stop':
                var opts = $(cont).data('cycle.opts');
                if (!opts)
                    return false;
                cont.cycleStop++; // callbacks look for change
                if (cont.cycleTimeout)
                    clearTimeout(cont.cycleTimeout);
                cont.cycleTimeout = 0;
                if (opts.elements)
                    $(opts.elements).stop();
                $(cont).removeData('cycle.opts');
                if (options == 'destroy')
                    destroy(cont, opts);
                return false;
            case 'toggle':
                cont.cyclePause = (cont.cyclePause === 1) ? 0 : 1;
                checkInstantResume(cont.cyclePause, arg2, cont);
                triggerPause(cont);
                return false;
            case 'pause':
                cont.cyclePause = 1;
                triggerPause(cont);
                return false;
            case 'resume':
                cont.cyclePause = 0;
                checkInstantResume(false, arg2, cont);
                triggerPause(cont);
                return false;
            case 'prev':
            case 'next':
                opts = $(cont).data('cycle.opts');
                if (!opts) {
                    log('options not found, "prev/next" ignored');
                    return false;
                }
                $.fn.cycle[options](opts);
                return false;
            default:
                options = { fx: options };
            }
            return options;
        }
        else if (options.constructor == Number) {
            // go to the requested slide
            var num = options;
            options = $(cont).data('cycle.opts');
            if (!options) {
                log('options not found, can not advance slide');
                return false;
            }
            if (num < 0 || num >= options.elements.length) {
                log('invalid slide index: ' + num);
                return false;
            }
            options.nextSlide = num;
            if (cont.cycleTimeout) {
                clearTimeout(cont.cycleTimeout);
                cont.cycleTimeout = 0;
            }
            if (typeof arg2 == 'string')
                options.oneTimeFx = arg2;
            go(options.elements, options, 1, num >= options.currSlide);
            return false;
        }
        return options;

        function checkInstantResume(isPaused, arg2, cont) {
            if (!isPaused && arg2 === true) { // resume now!
                var options = $(cont).data('cycle.opts');
                if (!options) {
                    log('options not found, can not resume');
                    return false;
                }
                if (cont.cycleTimeout) {
                    clearTimeout(cont.cycleTimeout);
                    cont.cycleTimeout = 0;
                }
                go(options.elements, options, 1, !options.backwards);
            }
        }
    }

    function removeFilter(el, opts) {
        if (!$.support.opacity && opts.cleartype && el.style.filter) {
            try { el.style.removeAttribute('filter'); }
            catch(smother) {} // handle old opera versions
        }
    }

// unbind event handlers
    function destroy(cont, opts) {
        if (opts.next)
            $(opts.next).unbind(opts.prevNextEvent);
        if (opts.prev)
            $(opts.prev).unbind(opts.prevNextEvent);

        if (opts.pager || opts.pagerAnchorBuilder)
            $.each(opts.pagerAnchors || [], function() {
                this.unbind().remove();
            });
        opts.pagerAnchors = null;
        $(cont).unbind('mouseenter.cycle mouseleave.cycle');
        if (opts.destroy) // callback
            opts.destroy(opts);
    }

// one-time initialization
    function buildOptions($cont, $slides, els, options, o) {
        var startingSlideSpecified;
        // support metadata plugin (v1.0 and v2.0)
        var opts = $.extend({}, $.fn.cycle.defaults, options || {}, $.metadata ? $cont.metadata() : $.meta ? $cont.data() : {});
        var meta = $.isFunction($cont.data) ? $cont.data(opts.metaAttr) : null;
        if (meta)
            opts = $.extend(opts, meta);
        if (opts.autostop)
            opts.countdown = opts.autostopCount || els.length;

        var cont = $cont[0];
        $cont.data('cycle.opts', opts);
        opts.$cont = $cont;
        opts.stopCount = cont.cycleStop;
        opts.elements = els;
        opts.before = opts.before ? [opts.before] : [];
        opts.after = opts.after ? [opts.after] : [];

        // push some after callbacks
        if (!$.support.opacity && opts.cleartype)
            opts.after.push(function() { removeFilter(this, opts); });
        if (opts.continuous)
            opts.after.push(function() { go(els,opts,0,!opts.backwards); });

        saveOriginalOpts(opts);

        // clearType corrections
        if (!$.support.opacity && opts.cleartype && !opts.cleartypeNoBg)
            clearTypeFix($slides);

        // container requires non-static position so that slides can be position within
        if ($cont.css('position') == 'static')
            $cont.css('position', 'relative');
        if (opts.width)
            $cont.width(opts.width);
        if (opts.height && opts.height != 'auto')
            $cont.height(opts.height);

        if (opts.startingSlide !== undefined) {
            opts.startingSlide = parseInt(opts.startingSlide,10);
            if (opts.startingSlide >= els.length || opts.startSlide < 0)
                opts.startingSlide = 0; // catch bogus input
            else
                startingSlideSpecified = true;
        }
        else if (opts.backwards)
            opts.startingSlide = els.length - 1;
        else
            opts.startingSlide = 0;

        // if random, mix up the slide array
        if (opts.random) {
            opts.randomMap = [];
            for (var i = 0; i < els.length; i++)
                opts.randomMap.push(i);
            opts.randomMap.sort(function(a,b) {return Math.random() - 0.5;});
            if (startingSlideSpecified) {
                // try to find the specified starting slide and if found set start slide index in the map accordingly
                for ( var cnt = 0; cnt < els.length; cnt++ ) {
                    if ( opts.startingSlide == opts.randomMap[cnt] ) {
                        opts.randomIndex = cnt;
                    }
                }
            }
            else {
                opts.randomIndex = 1;
                opts.startingSlide = opts.randomMap[1];
            }
        }
        else if (opts.startingSlide >= els.length)
            opts.startingSlide = 0; // catch bogus input
        opts.currSlide = opts.startingSlide || 0;
        var first = opts.startingSlide;

        // set position and zIndex on all the slides
        $slides.css({position: 'absolute', top:0, left:0}).hide().each(function(i) {
            var z;
            if (opts.backwards)
                z = first ? i <= first ? els.length + (i-first) : first-i : els.length-i;
            else
                z = first ? i >= first ? els.length - (i-first) : first-i : els.length-i;
            $(this).css('z-index', z);
        });

        // make sure first slide is visible
        $(els[first]).css('opacity',1).show(); // opacity bit needed to handle restart use case
        removeFilter(els[first], opts);

        // stretch slides
        if (opts.fit) {
            if (!opts.aspect) {
                if (opts.width)
                    $slides.width(opts.width);
                if (opts.height && opts.height != 'auto')
                    $slides.height(opts.height);
            } else {
                $slides.each(function(){
                    var $slide = $(this);
                    var ratio = (opts.aspect === true) ? $slide.width()/$slide.height() : opts.aspect;
                    if( opts.width && $slide.width() != opts.width ) {
                        $slide.width( opts.width );
                        $slide.height( opts.width / ratio );
                    }

                    if( opts.height && $slide.height() < opts.height ) {
                        $slide.height( opts.height );
                        $slide.width( opts.height * ratio );
                    }
                });
            }
        }

        if (opts.center && ((!opts.fit) || opts.aspect)) {
            $slides.each(function(){
                var $slide = $(this);
                $slide.css({
                    "margin-left": opts.width ?
                        ((opts.width - $slide.width()) / 2) + "px" :
                        0,
                    "margin-top": opts.height ?
                        ((opts.height - $slide.height()) / 2) + "px" :
                        0
                });
            });
        }

        if (opts.center && !opts.fit && !opts.slideResize) {
            $slides.each(function(){
                var $slide = $(this);
                $slide.css({
                    "margin-left": opts.width ? ((opts.width - $slide.width()) / 2) + "px" : 0,
                    "margin-top": opts.height ? ((opts.height - $slide.height()) / 2) + "px" : 0
                });
            });
        }

        // stretch container
        var reshape = (opts.containerResize || opts.containerResizeHeight) && !$cont.innerHeight();
        if (reshape) { // do this only if container has no size http://tinyurl.com/da2oa9
            var maxw = 0, maxh = 0;
            for(var j=0; j < els.length; j++) {
                var $e = $(els[j]), e = $e[0], w = $e.outerWidth(), h = $e.outerHeight();
                if (!w) w = e.offsetWidth || e.width || $e.attr('width');
                if (!h) h = e.offsetHeight || e.height || $e.attr('height');
                maxw = w > maxw ? w : maxw;
                maxh = h > maxh ? h : maxh;
            }
            if (opts.containerResize && maxw > 0 && maxh > 0)
                $cont.css({width:maxw+'px',height:maxh+'px'});
            if (opts.containerResizeHeight && maxh > 0)
                $cont.css({height:maxh+'px'});
        }

        var pauseFlag = false;  // https://github.com/malsup/cycle/issues/44
        if (opts.pause)
            $cont.bind('mouseenter.cycle', function(){
                pauseFlag = true;
                this.cyclePause++;
                triggerPause(cont, true);
            }).bind('mouseleave.cycle', function(){
                    if (pauseFlag)
                        this.cyclePause--;
                    triggerPause(cont, true);
                });

        if (supportMultiTransitions(opts) === false)
            return false;

        // apparently a lot of people use image slideshows without height/width attributes on the images.
        // Cycle 2.50+ requires the sizing info for every slide; this block tries to deal with that.
        var requeue = false;
        options.requeueAttempts = options.requeueAttempts || 0;
        $slides.each(function() {
            // try to get height/width of each slide
            var $el = $(this);
            this.cycleH = (opts.fit && opts.height) ? opts.height : ($el.height() || this.offsetHeight || this.height || $el.attr('height') || 0);
            this.cycleW = (opts.fit && opts.width) ? opts.width : ($el.width() || this.offsetWidth || this.width || $el.attr('width') || 0);

            if ( $el.is('img') ) {
                var loading = (this.cycleH === 0 && this.cycleW === 0 && !this.complete);
                // don't requeue for images that are still loading but have a valid size
                if (loading) {
                    if (o.s && opts.requeueOnImageNotLoaded && ++options.requeueAttempts < 100) { // track retry count so we don't loop forever
                        log(options.requeueAttempts,' - img slide not loaded, requeuing slideshow: ', this.src, this.cycleW, this.cycleH);
                        setTimeout(function() {$(o.s,o.c).cycle(options);}, opts.requeueTimeout);
                        requeue = true;
                        return false; // break each loop
                    }
                    else {
                        log('could not determine size of image: '+this.src, this.cycleW, this.cycleH);
                    }
                }
            }
            return true;
        });

        if (requeue)
            return false;

        opts.cssBefore = opts.cssBefore || {};
        opts.cssAfter = opts.cssAfter || {};
        opts.cssFirst = opts.cssFirst || {};
        opts.animIn = opts.animIn || {};
        opts.animOut = opts.animOut || {};

        $slides.not(':eq('+first+')').css(opts.cssBefore);
        $($slides[first]).css(opts.cssFirst);

        if (opts.timeout) {
            opts.timeout = parseInt(opts.timeout,10);
            // ensure that timeout and speed settings are sane
            if (opts.speed.constructor == String)
                opts.speed = $.fx.speeds[opts.speed] || parseInt(opts.speed,10);
            if (!opts.sync)
                opts.speed = opts.speed / 2;

            var buffer = opts.fx == 'none' ? 0 : opts.fx == 'shuffle' ? 500 : 250;
            while((opts.timeout - opts.speed) < buffer) // sanitize timeout
                opts.timeout += opts.speed;
        }
        if (opts.easing)
            opts.easeIn = opts.easeOut = opts.easing;
        if (!opts.speedIn)
            opts.speedIn = opts.speed;
        if (!opts.speedOut)
            opts.speedOut = opts.speed;

        opts.slideCount = els.length;
        opts.currSlide = opts.lastSlide = first;
        if (opts.random) {
            if (++opts.randomIndex == els.length)
                opts.randomIndex = 0;
            opts.nextSlide = opts.randomMap[opts.randomIndex];
        }
        else if (opts.backwards)
            opts.nextSlide = opts.startingSlide === 0 ? (els.length-1) : opts.startingSlide-1;
        else
            opts.nextSlide = opts.startingSlide >= (els.length-1) ? 0 : opts.startingSlide+1;

        // run transition init fn
        if (!opts.multiFx) {
            var init = $.fn.cycle.transitions[opts.fx];
            if ($.isFunction(init))
                init($cont, $slides, opts);
            else if (opts.fx != 'custom' && !opts.multiFx) {
                log('unknown transition: ' + opts.fx,'; slideshow terminating');
                return false;
            }
        }

        // fire artificial events
        var e0 = $slides[first];
        if (!opts.skipInitializationCallbacks) {
            if (opts.before.length)
                opts.before[0].apply(e0, [e0, e0, opts, true]);
            if (opts.after.length)
                opts.after[0].apply(e0, [e0, e0, opts, true]);
        }
        if (opts.next)
            $(opts.next).bind(opts.prevNextEvent,function(){return advance(opts,1);});
        if (opts.prev)
            $(opts.prev).bind(opts.prevNextEvent,function(){return advance(opts,0);});
        if (opts.pager || opts.pagerAnchorBuilder)
            buildPager(els,opts);

        exposeAddSlide(opts, els);

        return opts;
    }

// save off original opts so we can restore after clearing state
    function saveOriginalOpts(opts) {
        opts.original = { before: [], after: [] };
        opts.original.cssBefore = $.extend({}, opts.cssBefore);
        opts.original.cssAfter  = $.extend({}, opts.cssAfter);
        opts.original.animIn	= $.extend({}, opts.animIn);
        opts.original.animOut   = $.extend({}, opts.animOut);
        $.each(opts.before, function() { opts.original.before.push(this); });
        $.each(opts.after,  function() { opts.original.after.push(this); });
    }

    function supportMultiTransitions(opts) {
        var i, tx, txs = $.fn.cycle.transitions;
        // look for multiple effects
        if (opts.fx.indexOf(',') > 0) {
            opts.multiFx = true;
            opts.fxs = opts.fx.replace(/\s*/g,'').split(',');
            // discard any bogus effect names
            for (i=0; i < opts.fxs.length; i++) {
                var fx = opts.fxs[i];
                tx = txs[fx];
                if (!tx || !txs.hasOwnProperty(fx) || !$.isFunction(tx)) {
                    log('discarding unknown transition: ',fx);
                    opts.fxs.splice(i,1);
                    i--;
                }
            }
            // if we have an empty list then we threw everything away!
            if (!opts.fxs.length) {
                log('No valid transitions named; slideshow terminating.');
                return false;
            }
        }
        else if (opts.fx == 'all') {  // auto-gen the list of transitions
            opts.multiFx = true;
            opts.fxs = [];
            for (var p in txs) {
                if (txs.hasOwnProperty(p)) {
                    tx = txs[p];
                    if (txs.hasOwnProperty(p) && $.isFunction(tx))
                        opts.fxs.push(p);
                }
            }
        }
        if (opts.multiFx && opts.randomizeEffects) {
            // munge the fxs array to make effect selection random
            var r1 = Math.floor(Math.random() * 20) + 30;
            for (i = 0; i < r1; i++) {
                var r2 = Math.floor(Math.random() * opts.fxs.length);
                opts.fxs.push(opts.fxs.splice(r2,1)[0]);
            }
            debug('randomized fx sequence: ',opts.fxs);
        }
        return true;
    }

// provide a mechanism for adding slides after the slideshow has started
    function exposeAddSlide(opts, els) {
        opts.addSlide = function(newSlide, prepend) {
            var $s = $(newSlide), s = $s[0];
            if (!opts.autostopCount)
                opts.countdown++;
            els[prepend?'unshift':'push'](s);
            if (opts.els)
                opts.els[prepend?'unshift':'push'](s); // shuffle needs this
            opts.slideCount = els.length;

            // add the slide to the random map and resort
            if (opts.random) {
                opts.randomMap.push(opts.slideCount-1);
                opts.randomMap.sort(function(a,b) {return Math.random() - 0.5;});
            }

            $s.css('position','absolute');
            $s[prepend?'prependTo':'appendTo'](opts.$cont);

            if (prepend) {
                opts.currSlide++;
                opts.nextSlide++;
            }

            if (!$.support.opacity && opts.cleartype && !opts.cleartypeNoBg)
                clearTypeFix($s);

            if (opts.fit && opts.width)
                $s.width(opts.width);
            if (opts.fit && opts.height && opts.height != 'auto')
                $s.height(opts.height);
            s.cycleH = (opts.fit && opts.height) ? opts.height : $s.height();
            s.cycleW = (opts.fit && opts.width) ? opts.width : $s.width();

            $s.css(opts.cssBefore);

            if (opts.pager || opts.pagerAnchorBuilder)
                $.fn.cycle.createPagerAnchor(els.length-1, s, $(opts.pager), els, opts);

            if ($.isFunction(opts.onAddSlide))
                opts.onAddSlide($s);
            else
                $s.hide(); // default behavior
        };
    }

// reset internal state; we do this on every pass in order to support multiple effects
    $.fn.cycle.resetState = function(opts, fx) {
        fx = fx || opts.fx;
        opts.before = []; opts.after = [];
        opts.cssBefore = $.extend({}, opts.original.cssBefore);
        opts.cssAfter  = $.extend({}, opts.original.cssAfter);
        opts.animIn	= $.extend({}, opts.original.animIn);
        opts.animOut   = $.extend({}, opts.original.animOut);
        opts.fxFn = null;
        $.each(opts.original.before, function() { opts.before.push(this); });
        $.each(opts.original.after,  function() { opts.after.push(this); });

        // re-init
        var init = $.fn.cycle.transitions[fx];
        if ($.isFunction(init))
            init(opts.$cont, $(opts.elements), opts);
    };

// this is the main engine fn, it handles the timeouts, callbacks and slide index mgmt
    function go(els, opts, manual, fwd) {
        var p = opts.$cont[0], curr = els[opts.currSlide], next = els[opts.nextSlide];

        // opts.busy is true if we're in the middle of an animation
        if (manual && opts.busy && opts.manualTrump) {
            // let manual transitions requests trump active ones
            debug('manualTrump in go(), stopping active transition');
            $(els).stop(true,true);
            opts.busy = 0;
            clearTimeout(p.cycleTimeout);
        }

        // don't begin another timeout-based transition if there is one active
        if (opts.busy) {
            debug('transition active, ignoring new tx request');
            return;
        }


        // stop cycling if we have an outstanding stop request
        if (p.cycleStop != opts.stopCount || p.cycleTimeout === 0 && !manual)
            return;

        // check to see if we should stop cycling based on autostop options
        if (!manual && !p.cyclePause && !opts.bounce &&
            ((opts.autostop && (--opts.countdown <= 0)) ||
                (opts.nowrap && !opts.random && opts.nextSlide < opts.currSlide))) {
            if (opts.end)
                opts.end(opts);
            return;
        }

        // if slideshow is paused, only transition on a manual trigger
        var changed = false;
        if ((manual || !p.cyclePause) && (opts.nextSlide != opts.currSlide)) {
            changed = true;
            var fx = opts.fx;
            // keep trying to get the slide size if we don't have it yet
            curr.cycleH = curr.cycleH || $(curr).height();
            curr.cycleW = curr.cycleW || $(curr).width();
            next.cycleH = next.cycleH || $(next).height();
            next.cycleW = next.cycleW || $(next).width();

            // support multiple transition types
            if (opts.multiFx) {
                if (fwd && (opts.lastFx === undefined || ++opts.lastFx >= opts.fxs.length))
                    opts.lastFx = 0;
                else if (!fwd && (opts.lastFx === undefined || --opts.lastFx < 0))
                    opts.lastFx = opts.fxs.length - 1;
                fx = opts.fxs[opts.lastFx];
            }

            // one-time fx overrides apply to:  $('div').cycle(3,'zoom');
            if (opts.oneTimeFx) {
                fx = opts.oneTimeFx;
                opts.oneTimeFx = null;
            }

            $.fn.cycle.resetState(opts, fx);

            // run the before callbacks
            if (opts.before.length)
                $.each(opts.before, function(i,o) {
                    if (p.cycleStop != opts.stopCount) return;
                    o.apply(next, [curr, next, opts, fwd]);
                });

            // stage the after callacks
            var after = function() {
                opts.busy = 0;
                $.each(opts.after, function(i,o) {
                    if (p.cycleStop != opts.stopCount) return;
                    o.apply(next, [curr, next, opts, fwd]);
                });
                if (!p.cycleStop) {
                    // queue next transition
                    queueNext();
                }
            };

            debug('tx firing('+fx+'); currSlide: ' + opts.currSlide + '; nextSlide: ' + opts.nextSlide);

            // get ready to perform the transition
            opts.busy = 1;
            if (opts.fxFn) // fx function provided?
                opts.fxFn(curr, next, opts, after, fwd, manual && opts.fastOnEvent);
            else if ($.isFunction($.fn.cycle[opts.fx])) // fx plugin ?
                $.fn.cycle[opts.fx](curr, next, opts, after, fwd, manual && opts.fastOnEvent);
            else
                $.fn.cycle.custom(curr, next, opts, after, fwd, manual && opts.fastOnEvent);
        }
        else {
            queueNext();
        }

        if (changed || opts.nextSlide == opts.currSlide) {
            // calculate the next slide
            var roll;
            opts.lastSlide = opts.currSlide;
            if (opts.random) {
                opts.currSlide = opts.nextSlide;
                if (++opts.randomIndex == els.length) {
                    opts.randomIndex = 0;
                    opts.randomMap.sort(function(a,b) {return Math.random() - 0.5;});
                }
                opts.nextSlide = opts.randomMap[opts.randomIndex];
                if (opts.nextSlide == opts.currSlide)
                    opts.nextSlide = (opts.currSlide == opts.slideCount - 1) ? 0 : opts.currSlide + 1;
            }
            else if (opts.backwards) {
                roll = (opts.nextSlide - 1) < 0;
                if (roll && opts.bounce) {
                    opts.backwards = !opts.backwards;
                    opts.nextSlide = 1;
                    opts.currSlide = 0;
                }
                else {
                    opts.nextSlide = roll ? (els.length-1) : opts.nextSlide-1;
                    opts.currSlide = roll ? 0 : opts.nextSlide+1;
                }
            }
            else { // sequence
                roll = (opts.nextSlide + 1) == els.length;
                if (roll && opts.bounce) {
                    opts.backwards = !opts.backwards;
                    opts.nextSlide = els.length-2;
                    opts.currSlide = els.length-1;
                }
                else {
                    opts.nextSlide = roll ? 0 : opts.nextSlide+1;
                    opts.currSlide = roll ? els.length-1 : opts.nextSlide-1;
                }
            }
        }
        if (changed && opts.pager)
            opts.updateActivePagerLink(opts.pager, opts.currSlide, opts.activePagerClass);

        function queueNext() {
            // stage the next transition
            var ms = 0, timeout = opts.timeout;
            if (opts.timeout && !opts.continuous) {
                ms = getTimeout(els[opts.currSlide], els[opts.nextSlide], opts, fwd);
                if (opts.fx == 'shuffle')
                    ms -= opts.speedOut;
            }
            else if (opts.continuous && p.cyclePause) // continuous shows work off an after callback, not this timer logic
                ms = 10;
            if (ms > 0)
                p.cycleTimeout = setTimeout(function(){ go(els, opts, 0, !opts.backwards); }, ms);
        }
    }

// invoked after transition
    $.fn.cycle.updateActivePagerLink = function(pager, currSlide, clsName) {
        $(pager).each(function() {
            $(this).children().removeClass(clsName).eq(currSlide).addClass(clsName);
        });
    };

// calculate timeout value for current transition
    function getTimeout(curr, next, opts, fwd) {
        if (opts.timeoutFn) {
            // call user provided calc fn
            var t = opts.timeoutFn.call(curr,curr,next,opts,fwd);
            while (opts.fx != 'none' && (t - opts.speed) < 250) // sanitize timeout
                t += opts.speed;
            debug('calculated timeout: ' + t + '; speed: ' + opts.speed);
            if (t !== false)
                return t;
        }
        return opts.timeout;
    }

// expose next/prev function, caller must pass in state
    $.fn.cycle.next = function(opts) { advance(opts,1); };
    $.fn.cycle.prev = function(opts) { advance(opts,0);};

// advance slide forward or back
    function advance(opts, moveForward) {
        var val = moveForward ? 1 : -1;
        var els = opts.elements;
        var p = opts.$cont[0], timeout = p.cycleTimeout;
        if (timeout) {
            clearTimeout(timeout);
            p.cycleTimeout = 0;
        }
        if (opts.random && val < 0) {
            // move back to the previously display slide
            opts.randomIndex--;
            if (--opts.randomIndex == -2)
                opts.randomIndex = els.length-2;
            else if (opts.randomIndex == -1)
                opts.randomIndex = els.length-1;
            opts.nextSlide = opts.randomMap[opts.randomIndex];
        }
        else if (opts.random) {
            opts.nextSlide = opts.randomMap[opts.randomIndex];
        }
        else {
            opts.nextSlide = opts.currSlide + val;
            if (opts.nextSlide < 0) {
                if (opts.nowrap) return false;
                opts.nextSlide = els.length - 1;
            }
            else if (opts.nextSlide >= els.length) {
                if (opts.nowrap) return false;
                opts.nextSlide = 0;
            }
        }

        var cb = opts.onPrevNextEvent || opts.prevNextClick; // prevNextClick is deprecated
        if ($.isFunction(cb))
            cb(val > 0, opts.nextSlide, els[opts.nextSlide]);
        go(els, opts, 1, moveForward);
        return false;
    }

    function buildPager(els, opts) {
        var $p = $(opts.pager);
        $.each(els, function(i,o) {
            $.fn.cycle.createPagerAnchor(i,o,$p,els,opts);
        });
        opts.updateActivePagerLink(opts.pager, opts.startingSlide, opts.activePagerClass);
    }

    $.fn.cycle.createPagerAnchor = function(i, el, $p, els, opts) {
        var a;
        if ($.isFunction(opts.pagerAnchorBuilder)) {
            a = opts.pagerAnchorBuilder(i,el);
            debug('pagerAnchorBuilder('+i+', el) returned: ' + a);
        }
        else
            a = '<a href="#">'+(i+1)+'</a>';

        if (!a)
            return;
        var $a = $(a);
        // don't reparent if anchor is in the dom
        if ($a.parents('body').length === 0) {
            var arr = [];
            if ($p.length > 1) {
                $p.each(function() {
                    var $clone = $a.clone(true);
                    $(this).append($clone);
                    arr.push($clone[0]);
                });
                $a = $(arr);
            }
            else {
                $a.appendTo($p);
            }
        }

        opts.pagerAnchors =  opts.pagerAnchors || [];
        opts.pagerAnchors.push($a);

        var pagerFn = function(e) {
            e.preventDefault();
            opts.nextSlide = i;
            var p = opts.$cont[0], timeout = p.cycleTimeout;
            if (timeout) {
                clearTimeout(timeout);
                p.cycleTimeout = 0;
            }
            var cb = opts.onPagerEvent || opts.pagerClick; // pagerClick is deprecated
            if ($.isFunction(cb))
                cb(opts.nextSlide, els[opts.nextSlide]);
            go(els,opts,1,opts.currSlide < i); // trigger the trans
//		return false; // <== allow bubble
        };

        if ( /mouseenter|mouseover/i.test(opts.pagerEvent) ) {
            $a.hover(pagerFn, function(){/* no-op */} );
        }
        else {
            $a.bind(opts.pagerEvent, pagerFn);
        }

        if ( ! /^click/.test(opts.pagerEvent) && !opts.allowPagerClickBubble)
            $a.bind('click.cycle', function(){return false;}); // suppress click

        var cont = opts.$cont[0];
        var pauseFlag = false; // https://github.com/malsup/cycle/issues/44
        if (opts.pauseOnPagerHover) {
            $a.hover(
                function() {
                    pauseFlag = true;
                    cont.cyclePause++;
                    triggerPause(cont,true,true);
                }, function() {
                    if (pauseFlag)
                        cont.cyclePause--;
                    triggerPause(cont,true,true);
                }
            );
        }
    };

// helper fn to calculate the number of slides between the current and the next
    $.fn.cycle.hopsFromLast = function(opts, fwd) {
        var hops, l = opts.lastSlide, c = opts.currSlide;
        if (fwd)
            hops = c > l ? c - l : opts.slideCount - l;
        else
            hops = c < l ? l - c : l + opts.slideCount - c;
        return hops;
    };

// fix clearType problems in ie6 by setting an explicit bg color
// (otherwise text slides look horrible during a fade transition)
    function clearTypeFix($slides) {
        debug('applying clearType background-color hack');
        function hex(s) {
            s = parseInt(s,10).toString(16);
            return s.length < 2 ? '0'+s : s;
        }
        function getBg(e) {
            for ( ; e && e.nodeName.toLowerCase() != 'html'; e = e.parentNode) {
                var v = $.css(e,'background-color');
                if (v && v.indexOf('rgb') >= 0 ) {
                    var rgb = v.match(/\d+/g);
                    return '#'+ hex(rgb[0]) + hex(rgb[1]) + hex(rgb[2]);
                }
                if (v && v != 'transparent')
                    return v;
            }
            return '#ffffff';
        }
        $slides.each(function() { $(this).css('background-color', getBg(this)); });
    }

// reset common props before the next transition
    $.fn.cycle.commonReset = function(curr,next,opts,w,h,rev) {
        $(opts.elements).not(curr).hide();
        if (typeof opts.cssBefore.opacity == 'undefined')
            opts.cssBefore.opacity = 1;
        opts.cssBefore.display = 'block';
        if (opts.slideResize && w !== false && next.cycleW > 0)
            opts.cssBefore.width = next.cycleW;
        if (opts.slideResize && h !== false && next.cycleH > 0)
            opts.cssBefore.height = next.cycleH;
        opts.cssAfter = opts.cssAfter || {};
        opts.cssAfter.display = 'none';
        $(curr).css('zIndex',opts.slideCount + (rev === true ? 1 : 0));
        $(next).css('zIndex',opts.slideCount + (rev === true ? 0 : 1));
    };

// the actual fn for effecting a transition
    $.fn.cycle.custom = function(curr, next, opts, cb, fwd, speedOverride) {
        var $l = $(curr), $n = $(next);
        var speedIn = opts.speedIn, speedOut = opts.speedOut, easeIn = opts.easeIn, easeOut = opts.easeOut;
        $n.css(opts.cssBefore);
        if (speedOverride) {
            if (typeof speedOverride == 'number')
                speedIn = speedOut = speedOverride;
            else
                speedIn = speedOut = 1;
            easeIn = easeOut = null;
        }
        var fn = function() {
            $n.animate(opts.animIn, speedIn, easeIn, function() {
                cb();
            });
        };
        $l.animate(opts.animOut, speedOut, easeOut, function() {
            $l.css(opts.cssAfter);
            if (!opts.sync)
                fn();
        });
        if (opts.sync) fn();
    };

// transition definitions - only fade is defined here, transition pack defines the rest
    $.fn.cycle.transitions = {
        fade: function($cont, $slides, opts) {
            $slides.not(':eq('+opts.currSlide+')').css('opacity',0);
            opts.before.push(function(curr,next,opts) {
                $.fn.cycle.commonReset(curr,next,opts);
                opts.cssBefore.opacity = 0;
            });
            opts.animIn	   = { opacity: 1 };
            opts.animOut   = { opacity: 0 };
            opts.cssBefore = { top: 0, left: 0 };
        }
    };

    $.fn.cycle.ver = function() { return ver; };

// override these globally if you like (they are all optional)
    $.fn.cycle.defaults = {
        activePagerClass: 'activeSlide', // class name used for the active pager link
        after:            null,     // transition callback (scope set to element that was shown):  function(currSlideElement, nextSlideElement, options, forwardFlag)
        allowPagerClickBubble: false, // allows or prevents click event on pager anchors from bubbling
        animIn:           null,     // properties that define how the slide animates in
        animOut:          null,     // properties that define how the slide animates out
        aspect:           false,    // preserve aspect ratio during fit resizing, cropping if necessary (must be used with fit option)
        autostop:         0,        // true to end slideshow after X transitions (where X == slide count)
        autostopCount:    0,        // number of transitions (optionally used with autostop to define X)
        backwards:        false,    // true to start slideshow at last slide and move backwards through the stack
        before:           null,     // transition callback (scope set to element to be shown):     function(currSlideElement, nextSlideElement, options, forwardFlag)
        center:           null,     // set to true to have cycle add top/left margin to each slide (use with width and height options)
        cleartype:        !$.support.opacity,  // true if clearType corrections should be applied (for IE)
        cleartypeNoBg:    false,    // set to true to disable extra cleartype fixing (leave false to force background color setting on slides)
        containerResize:  1,        // resize container to fit largest slide
        containerResizeHeight:  0,  // resize containers height to fit the largest slide but leave the width dynamic
        continuous:       0,        // true to start next transition immediately after current one completes
        cssAfter:         null,     // properties that defined the state of the slide after transitioning out
        cssBefore:        null,     // properties that define the initial state of the slide before transitioning in
        delay:            0,        // additional delay (in ms) for first transition (hint: can be negative)
        easeIn:           null,     // easing for "in" transition
        easeOut:          null,     // easing for "out" transition
        easing:           null,     // easing method for both in and out transitions
        end:              null,     // callback invoked when the slideshow terminates (use with autostop or nowrap options): function(options)
        fastOnEvent:      0,        // force fast transitions when triggered manually (via pager or prev/next); value == time in ms
        fit:              0,        // force slides to fit container
        fx:               'fade',   // name of transition effect (or comma separated names, ex: 'fade,scrollUp,shuffle')
        fxFn:             null,     // function used to control the transition: function(currSlideElement, nextSlideElement, options, afterCalback, forwardFlag)
        height:           'auto',   // container height (if the 'fit' option is true, the slides will be set to this height as well)
        manualTrump:      true,     // causes manual transition to stop an active transition instead of being ignored
        metaAttr:         'cycle',  // data- attribute that holds the option data for the slideshow
        next:             null,     // element, jQuery object, or jQuery selector string for the element to use as event trigger for next slide
        nowrap:           0,        // true to prevent slideshow from wrapping
        onPagerEvent:     null,     // callback fn for pager events: function(zeroBasedSlideIndex, slideElement)
        onPrevNextEvent:  null,     // callback fn for prev/next events: function(isNext, zeroBasedSlideIndex, slideElement)
        pager:            null,     // element, jQuery object, or jQuery selector string for the element to use as pager container
        pagerAnchorBuilder: null,   // callback fn for building anchor links:  function(index, DOMelement)
        pagerEvent:       'click.cycle', // name of event which drives the pager navigation
        pause:            0,        // true to enable "pause on hover"
        pauseOnPagerHover: 0,       // true to pause when hovering over pager link
        prev:             null,     // element, jQuery object, or jQuery selector string for the element to use as event trigger for previous slide
        prevNextEvent:    'click.cycle',// event which drives the manual transition to the previous or next slide
        random:           0,        // true for random, false for sequence (not applicable to shuffle fx)
        randomizeEffects: 1,        // valid when multiple effects are used; true to make the effect sequence random
        requeueOnImageNotLoaded: true, // requeue the slideshow if any image slides are not yet loaded
        requeueTimeout:   250,      // ms delay for requeue
        rev:              0,        // causes animations to transition in reverse (for effects that support it such as scrollHorz/scrollVert/shuffle)
        shuffle:          null,     // coords for shuffle animation, ex: { top:15, left: 200 }
        skipInitializationCallbacks: false, // set to true to disable the first before/after callback that occurs prior to any transition
        slideExpr:        null,     // expression for selecting slides (if something other than all children is required)
        slideResize:      1,        // force slide width/height to fixed size before every transition
        speed:            1000,     // speed of the transition (any valid fx speed value)
        speedIn:          null,     // speed of the 'in' transition
        speedOut:         null,     // speed of the 'out' transition
        startingSlide:    undefined,// zero-based index of the first slide to be displayed
        sync:             1,        // true if in/out transitions should occur simultaneously
        timeout:          4000,     // milliseconds between slide transitions (0 to disable auto advance)
        timeoutFn:        null,     // callback for determining per-slide timeout value:  function(currSlideElement, nextSlideElement, options, forwardFlag)
        updateActivePagerLink: null,// callback fn invoked to update the active pager link (adds/removes activePagerClass style)
        width:            null      // container width (if the 'fit' option is true, the slides will be set to this width as well)
    };

})(jQuery);


/*!
 * jQuery Cycle Plugin Transition Definitions
 * This script is a plugin for the jQuery Cycle Plugin
 * Examples and documentation at: http://malsup.com/jquery/cycle/
 * Copyright (c) 2007-2010 M. Alsup
 * Version:	 2.73
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 */
(function($) {
    

//
// These functions define slide initialization and properties for the named
// transitions. To save file size feel free to remove any of these that you
// don't need.
//
    $.fn.cycle.transitions.none = function($cont, $slides, opts) {
        opts.fxFn = function(curr,next,opts,after){
            $(next).show();
            $(curr).hide();
            after();
        };
    };

// not a cross-fade, fadeout only fades out the top slide
    $.fn.cycle.transitions.fadeout = function($cont, $slides, opts) {
        $slides.not(':eq('+opts.currSlide+')').css({ display: 'block', 'opacity': 1 });
        opts.before.push(function(curr,next,opts,w,h,rev) {
            $(curr).css('zIndex',opts.slideCount + (rev !== true ? 1 : 0));
            $(next).css('zIndex',opts.slideCount + (rev !== true ? 0 : 1));
        });
        opts.animIn.opacity = 1;
        opts.animOut.opacity = 0;
        opts.cssBefore.opacity = 1;
        opts.cssBefore.display = 'block';
        opts.cssAfter.zIndex = 0;
    };

// scrollUp/Down/Left/Right
    $.fn.cycle.transitions.scrollUp = function($cont, $slides, opts) {
        $cont.css('overflow','hidden');
        opts.before.push($.fn.cycle.commonReset);
        var h = $cont.height();
        opts.cssBefore.top = h;
        opts.cssBefore.left = 0;
        opts.cssFirst.top = 0;
        opts.animIn.top = 0;
        opts.animOut.top = -h;
    };
    $.fn.cycle.transitions.scrollDown = function($cont, $slides, opts) {
        $cont.css('overflow','hidden');
        opts.before.push($.fn.cycle.commonReset);
        var h = $cont.height();
        opts.cssFirst.top = 0;
        opts.cssBefore.top = -h;
        opts.cssBefore.left = 0;
        opts.animIn.top = 0;
        opts.animOut.top = h;
    };
    $.fn.cycle.transitions.scrollLeft = function($cont, $slides, opts) {
        $cont.css('overflow','hidden');
        opts.before.push($.fn.cycle.commonReset);
        var w = $cont.width();
        opts.cssFirst.left = 0;
        opts.cssBefore.left = w;
        opts.cssBefore.top = 0;
        opts.animIn.left = 0;
        opts.animOut.left = 0-w;
    };
    $.fn.cycle.transitions.scrollRight = function($cont, $slides, opts) {
        $cont.css('overflow','hidden');
        opts.before.push($.fn.cycle.commonReset);
        var w = $cont.width();
        opts.cssFirst.left = 0;
        opts.cssBefore.left = -w;
        opts.cssBefore.top = 0;
        opts.animIn.left = 0;
        opts.animOut.left = w;
    };
    $.fn.cycle.transitions.scrollHorz = function($cont, $slides, opts) {
        $cont.css('overflow','hidden').width();
        opts.before.push(function(curr, next, opts, fwd) {
            if (opts.rev)
                fwd = !fwd;
            $.fn.cycle.commonReset(curr,next,opts);
            opts.cssBefore.left = fwd ? (next.cycleW-1) : (1-next.cycleW);
            opts.animOut.left = fwd ? -curr.cycleW : curr.cycleW;
        });
        opts.cssFirst.left = 0;
        opts.cssBefore.top = 0;
        opts.animIn.left = 0;
        opts.animOut.top = 0;
    };
    $.fn.cycle.transitions.scrollVert = function($cont, $slides, opts) {
        $cont.css('overflow','hidden');
        opts.before.push(function(curr, next, opts, fwd) {
            if (opts.rev)
                fwd = !fwd;
            $.fn.cycle.commonReset(curr,next,opts);
            opts.cssBefore.top = fwd ? (1-next.cycleH) : (next.cycleH-1);
            opts.animOut.top = fwd ? curr.cycleH : -curr.cycleH;
        });
        opts.cssFirst.top = 0;
        opts.cssBefore.left = 0;
        opts.animIn.top = 0;
        opts.animOut.left = 0;
    };

// slideX/slideY
    $.fn.cycle.transitions.slideX = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $(opts.elements).not(curr).hide();
            $.fn.cycle.commonReset(curr,next,opts,false,true);
            opts.animIn.width = next.cycleW;
        });
        opts.cssBefore.left = 0;
        opts.cssBefore.top = 0;
        opts.cssBefore.width = 0;
        opts.animIn.width = 'show';
        opts.animOut.width = 0;
    };
    $.fn.cycle.transitions.slideY = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $(opts.elements).not(curr).hide();
            $.fn.cycle.commonReset(curr,next,opts,true,false);
            opts.animIn.height = next.cycleH;
        });
        opts.cssBefore.left = 0;
        opts.cssBefore.top = 0;
        opts.cssBefore.height = 0;
        opts.animIn.height = 'show';
        opts.animOut.height = 0;
    };

// shuffle
    $.fn.cycle.transitions.shuffle = function($cont, $slides, opts) {
        var i, w = $cont.css('overflow', 'visible').width();
        $slides.css({left: 0, top: 0});
        opts.before.push(function(curr,next,opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,true,true);
        });
        // only adjust speed once!
        if (!opts.speedAdjusted) {
            opts.speed = opts.speed / 2; // shuffle has 2 transitions
            opts.speedAdjusted = true;
        }
        opts.random = 0;
        opts.shuffle = opts.shuffle || {left:-w, top:15};
        opts.els = [];
        for (i=0; i < $slides.length; i++)
            opts.els.push($slides[i]);

        for (i=0; i < opts.currSlide; i++)
            opts.els.push(opts.els.shift());

        // custom transition fn (hat tip to Benjamin Sterling for this bit of sweetness!)
        opts.fxFn = function(curr, next, opts, cb, fwd) {
            if (opts.rev)
                fwd = !fwd;
            var $el = fwd ? $(curr) : $(next);
            $(next).css(opts.cssBefore);
            var count = opts.slideCount;
            $el.animate(opts.shuffle, opts.speedIn, opts.easeIn, function() {
                var hops = $.fn.cycle.hopsFromLast(opts, fwd);
                for (var k=0; k < hops; k++) {
                    if (fwd)
                        opts.els.push(opts.els.shift());
                    else
                        opts.els.unshift(opts.els.pop());
                }
                if (fwd) {
                    for (var i=0, len=opts.els.length; i < len; i++)
                        $(opts.els[i]).css('z-index', len-i+count);
                }
                else {
                    var z = $(curr).css('z-index');
                    $el.css('z-index', parseInt(z,10)+1+count);
                }
                $el.animate({left:0, top:0}, opts.speedOut, opts.easeOut, function() {
                    $(fwd ? this : curr).hide();
                    if (cb) cb();
                });
            });
        };
        $.extend(opts.cssBefore, { display: 'block', opacity: 1, top: 0, left: 0 });
    };

// turnUp/Down/Left/Right
    $.fn.cycle.transitions.turnUp = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,false);
            opts.cssBefore.top = next.cycleH;
            opts.animIn.height = next.cycleH;
            opts.animOut.width = next.cycleW;
        });
        opts.cssFirst.top = 0;
        opts.cssBefore.left = 0;
        opts.cssBefore.height = 0;
        opts.animIn.top = 0;
        opts.animOut.height = 0;
    };
    $.fn.cycle.transitions.turnDown = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,false);
            opts.animIn.height = next.cycleH;
            opts.animOut.top   = curr.cycleH;
        });
        opts.cssFirst.top = 0;
        opts.cssBefore.left = 0;
        opts.cssBefore.top = 0;
        opts.cssBefore.height = 0;
        opts.animOut.height = 0;
    };
    $.fn.cycle.transitions.turnLeft = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,true);
            opts.cssBefore.left = next.cycleW;
            opts.animIn.width = next.cycleW;
        });
        opts.cssBefore.top = 0;
        opts.cssBefore.width = 0;
        opts.animIn.left = 0;
        opts.animOut.width = 0;
    };
    $.fn.cycle.transitions.turnRight = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,true);
            opts.animIn.width = next.cycleW;
            opts.animOut.left = curr.cycleW;
        });
        $.extend(opts.cssBefore, { top: 0, left: 0, width: 0 });
        opts.animIn.left = 0;
        opts.animOut.width = 0;
    };

// zoom
    $.fn.cycle.transitions.zoom = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,false,true);
            opts.cssBefore.top = next.cycleH/2;
            opts.cssBefore.left = next.cycleW/2;
            $.extend(opts.animIn, { top: 0, left: 0, width: next.cycleW, height: next.cycleH });
            $.extend(opts.animOut, { width: 0, height: 0, top: curr.cycleH/2, left: curr.cycleW/2 });
        });
        opts.cssFirst.top = 0;
        opts.cssFirst.left = 0;
        opts.cssBefore.width = 0;
        opts.cssBefore.height = 0;
    };

// fadeZoom
    $.fn.cycle.transitions.fadeZoom = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,false);
            opts.cssBefore.left = next.cycleW/2;
            opts.cssBefore.top = next.cycleH/2;
            $.extend(opts.animIn, { top: 0, left: 0, width: next.cycleW, height: next.cycleH });
        });
        opts.cssBefore.width = 0;
        opts.cssBefore.height = 0;
        opts.animOut.opacity = 0;
    };

// blindX
    $.fn.cycle.transitions.blindX = function($cont, $slides, opts) {
        var w = $cont.css('overflow','hidden').width();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts);
            opts.animIn.width = next.cycleW;
            opts.animOut.left   = curr.cycleW;
        });
        opts.cssBefore.left = w;
        opts.cssBefore.top = 0;
        opts.animIn.left = 0;
        opts.animOut.left = w;
    };
// blindY
    $.fn.cycle.transitions.blindY = function($cont, $slides, opts) {
        var h = $cont.css('overflow','hidden').height();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts);
            opts.animIn.height = next.cycleH;
            opts.animOut.top   = curr.cycleH;
        });
        opts.cssBefore.top = h;
        opts.cssBefore.left = 0;
        opts.animIn.top = 0;
        opts.animOut.top = h;
    };
// blindZ
    $.fn.cycle.transitions.blindZ = function($cont, $slides, opts) {
        var h = $cont.css('overflow','hidden').height();
        var w = $cont.width();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts);
            opts.animIn.height = next.cycleH;
            opts.animOut.top   = curr.cycleH;
        });
        opts.cssBefore.top = h;
        opts.cssBefore.left = w;
        opts.animIn.top = 0;
        opts.animIn.left = 0;
        opts.animOut.top = h;
        opts.animOut.left = w;
    };

// growX - grow horizontally from centered 0 width
    $.fn.cycle.transitions.growX = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,true);
            opts.cssBefore.left = this.cycleW/2;
            opts.animIn.left = 0;
            opts.animIn.width = this.cycleW;
            opts.animOut.left = 0;
        });
        opts.cssBefore.top = 0;
        opts.cssBefore.width = 0;
    };
// growY - grow vertically from centered 0 height
    $.fn.cycle.transitions.growY = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,false);
            opts.cssBefore.top = this.cycleH/2;
            opts.animIn.top = 0;
            opts.animIn.height = this.cycleH;
            opts.animOut.top = 0;
        });
        opts.cssBefore.height = 0;
        opts.cssBefore.left = 0;
    };

// curtainX - squeeze in both edges horizontally
    $.fn.cycle.transitions.curtainX = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,false,true,true);
            opts.cssBefore.left = next.cycleW/2;
            opts.animIn.left = 0;
            opts.animIn.width = this.cycleW;
            opts.animOut.left = curr.cycleW/2;
            opts.animOut.width = 0;
        });
        opts.cssBefore.top = 0;
        opts.cssBefore.width = 0;
    };
// curtainY - squeeze in both edges vertically
    $.fn.cycle.transitions.curtainY = function($cont, $slides, opts) {
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,false,true);
            opts.cssBefore.top = next.cycleH/2;
            opts.animIn.top = 0;
            opts.animIn.height = next.cycleH;
            opts.animOut.top = curr.cycleH/2;
            opts.animOut.height = 0;
        });
        opts.cssBefore.height = 0;
        opts.cssBefore.left = 0;
    };

// cover - curr slide covered by next slide
    $.fn.cycle.transitions.cover = function($cont, $slides, opts) {
        var d = opts.direction || 'left';
        var w = $cont.css('overflow','hidden').width();
        var h = $cont.height();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts);
            opts.cssAfter.display = '';
            if (d == 'right')
                opts.cssBefore.left = -w;
            else if (d == 'up')
                opts.cssBefore.top = h;
            else if (d == 'down')
                opts.cssBefore.top = -h;
            else
                opts.cssBefore.left = w;
        });
        opts.animIn.left = 0;
        opts.animIn.top = 0;
        opts.cssBefore.top = 0;
        opts.cssBefore.left = 0;
    };

// uncover - curr slide moves off next slide
    $.fn.cycle.transitions.uncover = function($cont, $slides, opts) {
        var d = opts.direction || 'left';
        var w = $cont.css('overflow','hidden').width();
        var h = $cont.height();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,true,true);
            if (d == 'right')
                opts.animOut.left = w;
            else if (d == 'up')
                opts.animOut.top = -h;
            else if (d == 'down')
                opts.animOut.top = h;
            else
                opts.animOut.left = -w;
        });
        opts.animIn.left = 0;
        opts.animIn.top = 0;
        opts.cssBefore.top = 0;
        opts.cssBefore.left = 0;
    };

// toss - move top slide and fade away
    $.fn.cycle.transitions.toss = function($cont, $slides, opts) {
        var w = $cont.css('overflow','visible').width();
        var h = $cont.height();
        opts.before.push(function(curr, next, opts) {
            $.fn.cycle.commonReset(curr,next,opts,true,true,true);
            // provide default toss settings if animOut not provided
            if (!opts.animOut.left && !opts.animOut.top)
                $.extend(opts.animOut, { left: w*2, top: -h/2, opacity: 0 });
            else
                opts.animOut.opacity = 0;
        });
        opts.cssBefore.left = 0;
        opts.cssBefore.top = 0;
        opts.animIn.left = 0;
    };

// wipe - clip animation
    $.fn.cycle.transitions.wipe = function($cont, $slides, opts) {
        var w = $cont.css('overflow','hidden').width();
        var h = $cont.height();
        opts.cssBefore = opts.cssBefore || {};
        var clip;
        if (opts.clip) {
            if (/l2r/.test(opts.clip))
                clip = 'rect(0px 0px '+h+'px 0px)';
            else if (/r2l/.test(opts.clip))
                clip = 'rect(0px '+w+'px '+h+'px '+w+'px)';
            else if (/t2b/.test(opts.clip))
                clip = 'rect(0px '+w+'px 0px 0px)';
            else if (/b2t/.test(opts.clip))
                clip = 'rect('+h+'px '+w+'px '+h+'px 0px)';
            else if (/zoom/.test(opts.clip)) {
                var top = parseInt(h/2,10);
                var left = parseInt(w/2,10);
                clip = 'rect('+top+'px '+left+'px '+top+'px '+left+'px)';
            }
        }

        opts.cssBefore.clip = opts.cssBefore.clip || clip || 'rect(0px 0px 0px 0px)';

        var d = opts.cssBefore.clip.match(/(\d+)/g);
        var t = parseInt(d[0],10), r = parseInt(d[1],10), b = parseInt(d[2],10), l = parseInt(d[3],10);

        opts.before.push(function(curr, next, opts) {
            if (curr == next) return;
            var $curr = $(curr), $next = $(next);
            $.fn.cycle.commonReset(curr,next,opts,true,true,false);
            opts.cssAfter.display = 'block';

            var step = 1, count = parseInt((opts.speedIn / 13),10) - 1;
            (function f() {
                var tt = t ? t - parseInt(step * (t/count),10) : 0;
                var ll = l ? l - parseInt(step * (l/count),10) : 0;
                var bb = b < h ? b + parseInt(step * ((h-b)/count || 1),10) : h;
                var rr = r < w ? r + parseInt(step * ((w-r)/count || 1),10) : w;
                $next.css({ clip: 'rect('+tt+'px '+rr+'px '+bb+'px '+ll+'px)' });
                (step++ <= count) ? setTimeout(f, 13) : $curr.css('display', 'none');
            })();
        });
        $.extend(opts.cssBefore, { display: 'block', opacity: 1, top: 0, left: 0 });
        opts.animIn	   = { left: 0 };
        opts.animOut   = { left: 0 };
    };

})(jQuery);
define("jcycle", function(){});

define('src/course/liste_courses/layers/pronostics/CarrouselAvisPresseView',[
    'template!./templates/pronostics-avis.hbs',
    'jcycle'
], function (avisPresseTableTmpl) {
    

    return Backbone.View.extend({
        className: 'carousel-avis pronostic-section',

        render: function (json, isQuinte) {
            var length = _.isUndefined(json) ? 0 : json.length,
                nbAvisPerSlide = isQuinte ? 3 : 9,
                btnNext,
                btnPrev,
                hideBtn = function ($btn) {
                    $btn.css('visibility', 'hidden');
                },
                showBtn = function ($btn) {
                    $btn.css('visibility', 'visible');
                };

            this.$el.empty().append(avisPresseTableTmpl(json, {data: {isQuinte: isQuinte, modulo: nbAvisPerSlide}}));

            btnNext =  this.$('.carousel-button.next');
            btnPrev =  this.$('.carousel-button.prev');

            this.$('.wrapper').cycle({
                activePagerClass: 'active',
                fx: 'fade',
                speed: 500,
                timeout: 0,
                pager: this.$('.carousel-pager'),
                prev: btnPrev,
                next: btnNext,
                cleartypeNoBg: true,
                pagerAnchorBuilder: function () {
                    return '<li></li>';
                },
                after:  function (curr, next, opts) {

                    if (opts.currSlide === opts.elements.length - 1) {
                        hideBtn(btnNext);
                    } else {
                        showBtn(btnNext);
                    }

                    if (opts.currSlide === 0) {
                        hideBtn(btnPrev);
                    } else {
                        showBtn(btnPrev);
                    }
                }
            });

            this.$('.carousel-pager').css('width', this._centerPage(length, nbAvisPerSlide));

            if (length < nbAvisPerSlide) {
                hideBtn(this.$('.carousel-button'));
            } else {
                showBtn(this.$('.carousel-button'));
            }

            hideBtn(btnPrev);

            return this;
        },

        _centerPage: function (jsonLength, tablePerSlide) {
            var nbPages = Math.ceil(jsonLength / tablePerSlide);
            return nbPages * 20;
        }
    });
});
define('src/course/liste_courses/layers/pronostics/LayerPronosticsContentView',[
    'template!./templates/pronostics-prono.hbs',
    'template!./templates/pronostics-synthese.hbs',
    'template!./templates/pronostics-commentaire.hbs',
    './CarrouselAvisPresseView',
    'tagCommander',
    'typeDeSite'
], function (pronoTmpl, syntheseTmpl, commentaireTmpl, CarrouselAvisPresseView, tagCommander, typeDeSite) {
    

    return Backbone.View.extend({
        className: 'layer-content',

        initialize: function () {
            this.carrouselAvisPresseView = new CarrouselAvisPresseView();
            this.templates = {
                prono: pronoTmpl,
                synthese: syntheseTmpl,
                commentaire: commentaireTmpl
            };
        },

        render: function () {
            this.sendTag();

            var json = this.model.toJSON();
            this.$el
                .empty()
                .append(this.templates.prono(json.commentaire))
                .append(this.templates.synthese(json.syntheses, {data: {isQuinte: json.quinte}}))
                .append(this.carrouselAvisPresseView.render(json.avis, json.quinte).el)
                .append(this.templates.commentaire(json.cribles));

            return this;
        },

        sendTag: function () {
            tagCommander.sendTags(
                'hippique.parier.reunion.course.pronostics',
                'programme_resultats.course.pronos',
                {
                    bet_reunion_id: this.model.numReunion,
                    bet_course_id: this.model.numCourse
                }
            );
        }
    });
});

define('src/course/liste_courses/layers/pronostics/LayerPronosticsModel',[
    'defaults'
], function (defaults) {
    

    return Backbone.Model.extend({
        url: function () {
            return defaults.PRONOSTIC_DETAILS_URL.replace('{date}', this.date).replace('{numReunion}', this.numReunion).replace('{numCourse}', this.numCourse);
        },

        initialize: function (attributes, options) {
            this.numReunion = options.numReunion;
            this.numCourse = options.numCourse;
            this.date = options.date;
        }
    });
});

define('src/course/liste_courses/layers/pronostics/LayerPronosticsView',[
    '../LayerView',
    './LayerPronosticsContentView',
    './LayerPronosticsModel'
], function (LayerView, LayerPronosticsContentView, LayerPronosticsModel) {
    

    return LayerView.extend({

        libelle: 'Pronostics',

        initialize: function () {
            _.extend(this.options, {libelle: this.libelle});

            this.model = new LayerPronosticsModel({}, {
                numReunion: this.options.numReunion,
                numCourse: this.options.numCourse,
                date: this.options.date
            });

            this.subViews = [
                new LayerPronosticsContentView({model: this.model})
            ];

            this.listenTo(this.model, 'sync', this.render);
            this.listenTo(this.model, 'error', this.renderError);

            LayerView.prototype.initialize.call(this);
        }
    });
});

define('text!src/course/liste_courses/layers/les-plus-joues/templates/les-plus-joues-tableau.hbs',[],function () { return '<div class="les-plus-joues {{famillePari}}">\n    <h3 class="les-plus-joues-title">Les chevaux les plus joués en {{titre}}</h3>\n    <div class="image-pari">\n        <div class="picto-pari size44x18 {{uppercase famillePari}}"></div>\n    </div>\n    <table class="plus-joues-recap"> </table>\n</div>\n';});

define('text!src/course/liste_courses/layers/les-plus-joues/templates/les-plus-joues-ligne.hbs',[],function () { return '<td class="label">{{libelle}}</td>\n<td>\n    <table>\n        <tr>\n            {{#if combinaisons}}\n                {{#each combinaisons.listeCombinaisons}}\n                    <td class="plus-joues-combinaison"> {{this}} </td>\n                {{/each}}\n            {{else}}\n                <td> -</td>\n            {{/if}}\n        </tr>\n    </table>\n</td>\n<td class="date">\n    {{#if combinaisons.updateTimeFormated}}\n        à {{combinaisons.updateTimeFormated}}\n    {{else}}\n        -\n    {{/if}}\n</td>\n';});

define('src/course/liste_courses/layers/les-plus-joues/LesPlusJouesContentLigneView',[
    'utils',
    'template!./templates/les-plus-joues-ligne.hbs'
],

    function (utils, tmpl) {
        

        var MAX_COMBI = 8;

        return Backbone.View.extend({
            tagName: "tr",

            render: function () {
                this.$el.empty().append(tmpl(this.json));
                return this;
            },

            prepareJson: function () {
                var combinaisons = this.model.getCombinaison(this.options.pari, MAX_COMBI);

                this.json = {
                    libelle: this.options.libelle,
                    combinaisons: combinaisons,
                    nbCombinaisons: combinaisons ? combinaisons.listeCombinaisons.length : 0
                };
            }
        });
    });

define('src/course/liste_courses/layers/les-plus-joues/LesPlusJouesContentView',[
    'template!./templates/les-plus-joues-tableau.hbs',
    './LesPlusJouesContentLigneView',
    'tagCommander',
    'typeDeSite'
],

    function (tmpl, LesPlusJouesContentLigneView, tagCommander, typeDeSite) {
        

        return Backbone.View.extend({

            className: 'layer-content',

            initialize: function () {

                this.subViews = [
                    new LesPlusJouesContentLigneView({model: this.model, pari: 'SIMPLE_GAGNANT', libelle: 'Gagnant'}),
                    new LesPlusJouesContentLigneView({model: this.model, pari: 'SIMPLE_PLACE', libelle: 'Placé'}),
                    new LesPlusJouesContentLigneView({model: this.model, pari: 'COUPLE_GAGNANT', libelle: 'Gagnant'}),
                    new LesPlusJouesContentLigneView({model: this.model, pari: 'COUPLE_ORDRE', libelle: 'Ordre'})
                ];
            },

            render: function () {
                this.sendTag();
                this.$el.empty().append(tmpl({famillePari: 'simple',  titre: 'simple'}));

                _.invoke(this.subViews, 'prepareJson');

                this.$('.les-plus-joues.simple table')
                    .append(this.subViews[0].render().el)
                    .append('<tr class="empty"></tr>') // resolves chrome dotted border problem
                    .append(this.subViews[1].render().el);

                this.$el.append(tmpl({famillePari: 'couple', titre: 'couplé'}));

                this.$('.les-plus-joues.couple table')
                    .append(this.subViews[2].render().el)
                    .append('<tr class="empty"></tr>') // resolves chrome dotted border problem
                    .append(this.subViews[3].render().el);

                return this;
            },

            sendTag: function () {
                tagCommander.sendTags(
                    'hippique.parier.reunion.course.les_plus_joues',
                    'programme_resultats.course.les_plus_joues',
                    {
                        bet_reunion_id: this.model.numReunion,
                        bet_course_id: this.model.numCourse
                    }
                );
            }
        });
    });

define('src/course/liste_courses/layers/les-plus-joues/LesPlusJouesModel',[
    'defaults',
    'timeManager'
], function (defaults, timeManager) {
    

    return Backbone.Model.extend({

        initialize: function (attributes, options) {
            this.date = options.date;
            this.numReunion = options.numReunion;
            this.numCourse = options.numCourse;
        },

        url: function () {
            return defaults.COMBINAISONS_URL.replace('{date}', this.date)
                .replace('{numReunion}', this.numReunion)
                .replace('{numCourse}', this.numCourse);
        },

        _sliceCombinaison: function (table, length) {
            if (length > 0) {
                return table.slice(0, length);
            }
            return table;
        },

        _findCombinaison: function (listeCombi, typePari) {
            var pariCombinaison = null;
            _.each(listeCombi, function (combinaison) {
                if (typePari === combinaison.pariType) {

                    pariCombinaison = combinaison;
                    return false;
                }
            }, this);
            return pariCombinaison;
        },

        _formatCombinaison: function (liste_combinaison, replace_string) {
            _.each(liste_combinaison, function (combiValue, index) {
                if (_.size(combiValue) > 1) {
                    liste_combinaison[index] = combiValue.join(replace_string);
                } else {
                    liste_combinaison[index] = combiValue.toString();
                }
            });
            return liste_combinaison;
        },

        _createUpdateTime: function (updateTime, offset) {
            var time = timeManager.momentWithOffset(updateTime, offset);
            return time.format('HH') + 'h' + time.format('mm');
        },

        getCombinaison: function (typePari, maxCombi) {
            var content = this.toJSON(),
                listeCombi = content.combinaisons,
                pariCombinaison = this._findCombinaison(listeCombi, typePari);

            if (pariCombinaison) {
                pariCombinaison.listeCombinaisons = this._formatCombinaison(pariCombinaison.listeCombinaisons, ' - ');
                pariCombinaison.updateTimeFormated = this._createUpdateTime(pariCombinaison.updateTime, pariCombinaison.timezoneOffset);
                pariCombinaison.listeCombinaisons = this._sliceCombinaison(pariCombinaison.listeCombinaisons, maxCombi);
            }
            return pariCombinaison;
        }
    });
});
define('src/course/liste_courses/layers/les-plus-joues/LesPlusJouesView',[
    '../LayerView',
    './LesPlusJouesContentView',
    './LesPlusJouesModel'
], function (LayerView, LesPlusJouesContentView, LesPlusJouesModel) {
    

    return LayerView.extend({

        libelle: 'Les plus joués',

        initialize: function () {
            _.extend(this.options, {libelle: this.libelle});

            this.model = new LesPlusJouesModel({}, {
                date: this.options.date,
                numReunion: this.options.numReunion,
                numCourse: this.options.numCourse

            });

            this.subViews = [
                new LesPlusJouesContentView({model: this.model})
            ];

            this.listenTo(this.model, 'sync', this.render);
            this.listenTo(this.model, 'error', this.renderError);

            LayerView.prototype.initialize.call(this);
        }
    });
});

define('src/course/liste_courses/layers/performances/PerfParticipantsCollection',[],function () {
    
    return Backbone.Collection.extend({
        model: Backbone.Model.extend({idAttribute: 'numPmu'})
    });
});
define('src/course/liste_courses/layers/performances/PerfCoursesCollection',[],function () {
    
    return Backbone.Collection.extend({

        getCoursesJSON: function (numPmu) {
            return this.reduce(function (coursesCourues, course) {

                var match = _.some(course.get('participants'), function (participant) {
                    return participant.numPmu === numPmu;
                });
                if (match) {
                    _.each(course.get('participants'), function (participant) {
                        participant.itsHim = participant.numPmu === numPmu;
                    });
                    coursesCourues.push(course.toJSON());
                }
                return coursesCourues;
            }, []);
        }

    });
});
define('src/course/liste_courses/layers/performances/PerfModel',[
    'defaults',
    './PerfParticipantsCollection',
    './PerfCoursesCollection'
], function (defaults, PerfParticipantsCollection, PerfCoursesCollection) {
    

    return Backbone.Model.extend({

        isDetaille: true, //false = comparee

        initialize: function (attributes, options) {
            this.numReunion = options.numReunion;
            this.numCourse = options.numCourse;
            this.date = options.date;

            this.participants = new PerfParticipantsCollection();
            this.courses = new PerfCoursesCollection();
        },

        url: function () {
            var urlBase = this.isDetaille ? defaults.PERFORMANCES_DETAILLEES : defaults.PERFORMANCES_COMPAREES;
            return urlBase.replace('{date}', this.date).replace('{numReunion}', this.numReunion).replace('{numCourse}', this.numCourse);
        },

        switchModelType: function () {
            this.isDetaille = !this.isDetaille;
            this.participants.reset();
            if (!this.isDetaille) {
                this.courses.reset();
            }
        },

        isPerfDetaillees: function () {
            return this.isDetaille;
        },

        parse: function (response) {
            if (_.isUndefined(response) || _.isNull(response)) {
                return;
            }

            var participants = response.participants;
            delete response.participants;
            if (!_.isEmpty(participants)) {
                participants[0].isFirst = true;
            }
            this.participants.add(participants, {silent: true});

            if (!this.isDetaille) {
                this.courses.add(response.coursesCourues, {silent: true});
            }

            return response;
        },

        getNomCheval: function (participant) {
            return this.participants.get(participant).toJSON().nomCheval;
        },

        getFirstParticipant: function () {
            return this.participants.first();
        },

        getPerfs: function (participant) {
            return this.isDetaille ? this._getPerfDetailleesJSON(participant) : this._getPerfCompareesJSON(participant);
        },

        _getPerfCompareesJSON: function (participant) {
            return this.courses.getCoursesJSON(participant.get('numPmu'));
        },

        _getPerfDetailleesJSON: function (participant) {
            return participant.get('coursesCourues');
        },

        hasNotPerf: function (participant) {
            return _.isEmpty(this.getPerfs(participant));
        },

        isGalop: function () {
            return this.get("allure") === "GALOP";
        }

    });
});

define('text!src/course/liste_courses/layers/performances/templates/perf-liste-partants.hbs',[],function () { return '<table class="table-layer">\n    <caption>PARTANTS</caption>\n    <tbody>\n        {{#stripes . \'odd\' \'even\'}}\n        <tr class="{{ stripeClass }} {{#if isFirst}}selected{{/if}}" data-numpmu="{{numPmu}}">\n            <td>{{numPmu}}</td>\n            <td>{{nomCheval}}</td>\n        </tr>\n        {{/stripes}}\n    </tbody>\n</table>';});

define('src/course/liste_courses/layers/performances/PerfListePartantsView',[
    'template!./templates/perf-liste-partants.hbs'
], function (listePartantTmpl) {
    

    return Backbone.View.extend({
        className: 'partants',

        events: {
            'click tr': 'selectCheval'
        },

        initialize: function () {
            this.debug('init PerfDetListParticipantView');
        },

        render: function () {
            var json = this.model.participants.toJSON();
            this.$el.empty().append(listePartantTmpl(json));
            return this;
        },

        selectCheval: function (e) {
            e.preventDefault();

            var $currentTarget = $(e.currentTarget),
                numPmu = $currentTarget.data('numpmu'),
                participant = this.model.participants.get(numPmu);

            participant.trigger('selected', participant);
            this._changeSelectedChevalStyle($currentTarget);
        },

        _changeSelectedChevalStyle: function (currentTarget) {
            this.$('tr').removeClass('selected');
            currentTarget.addClass('selected');
        }
    });
});

define('text!src/course/liste_courses/layers/performances/templates/perf-det-table-header-galop.hbs',[],function () { return '<!-- Galop: Place | Cheval | Jockey | Poids (kg) | Corde | Oeil.| Dist. Préc.-->\n<caption>Performances {{#if @isPerfDetaillees}}détaillées{{else}}comparées{{/if}} - {{.}}</caption>\n<thead>\n<tr>\n    <th class="place">Place</th>\n    <th class="nomCheval">Cheval</th>\n    <th class="nomJockey">Jockey</th>\n    <th class="smalth">Poids<span> (kg)</span></th>\n    <th class="xsmalth">Corde</th>\n    {{#if @isPerfDetaillees}}\n    <th class="xsmalth">Oeil.</th>\n    {{/if}}\n    <th class="smalth">Dist. Préc.</th>\n</tr>\n</thead>';});

define('text!src/course/liste_courses/layers/performances/templates/perf-det-table-header-trot.hbs',[],function () { return '<caption>Performances {{#if @isPerfDetaillees}}détaillées{{else}}comparées{{/if}} - {{.}}</caption>\n<thead>\n<tr>\n    <th class="place">Place</th>\n    <th class="nomCheval">Cheval</th>\n    <th class="nomJockey">Driver / Jockey</th>\n    <th class="smalth">Distance (m)</th>\n    <th class="smalth">Red. km.</th>\n</tr>\n</thead>';});

define('text!src/course/liste_courses/layers/performances/templates/perf-det-table-content-galop.hbs',[],function () { return '<tbody>\n{{#each .}}\n    <tr>\n        <td colspan="{{#if @isPerfDetaillees}}7{{else}}6{{/if}}" class="line-title">{{ formatMomentWithOffsetDate date timezoneOffset \'DD/MM/YYYY\' }} - {{hippodrome}} - {{nomPrix}} - {{ capitaliseFirstLetters discipline}} - {{distance}}m\n            {{#if etatTerrain}} - {{capitaliseFirstLetters etatTerrain}}{{/if}}\n            - {{nbParticipants}} partants\n            - {{formatDuree tempsDuPremier}}\n        </td>\n    </tr>\n    {{#stripes participants \'odd\' \'even\'}}\n        <tr class="{{ stripeClass }}{{#if itsHim}} him{{/if}}">\n            <td >{{#if place.rawValue}}{{ place.rawValue}}{{else}} {{libPlace place.statusArrivee place.place}}{{/if}}</td>\n            <td class="nomCheval">{{nomCheval}}</td>\n            <td class="nomJockey">{{nomJockey}}</td>\n            <td>{{formatReal poidsJockey}}</td>\n            <td>{{corde}}</td>\n            {{#if @isPerfDetaillees}}\n                <td class="oeil"><b class="{{oeillere}}"> </b></td>\n            {{/if}}\n            <td>{{getMessage \'DISTANCE.COURT.\' distanceAvecPrecedent.knownValue defaultKey=distanceAvecPrecedent.rawValue}}</td>\n        </tr>\n    {{/stripes}}\n{{/each}}\n</tbody>';});

define('text!src/course/liste_courses/layers/performances/templates/perf-det-table-content-trot.hbs',[],function () { return '<tbody>\n{{#each .}}\n    <tr>\n       <td colspan="5" class="line-title">{{ formatMomentDate date \'DD/MM/YYYY\' }}\n           - {{hippodrome}}\n           - {{nomPrix}}\n           - {{ capitaliseFirstLetters discipline}}\n           - {{distance}}m {{#if etatTerrain}}\n           - {{capitaliseFirstLetters etatTerrain}}{{/if}}\n           - {{nbParticipants}} partants\n           - {{formatDuree tempsDuPremier}}\n       </td>\n    </tr>\n    {{#stripes participants \'odd\' \'even\'}}\n        <tr class="{{ stripeClass }}{{#if itsHim}} him{{/if}}">\n           <td >{{#if place.rawValue}}{{ place.rawValue}}{{else}} {{libPlace place.statusArrivee place.place}}{{/if}}</td>\n            <td>{{nomCheval}}</td>\n            <td>{{nomJockey}}</td>\n            <td>{{distanceParcourue}}</td>\n            <td>{{formatDuree reductionKilometrique}}</td>\n        </tr>\n    {{/stripes}}\n{{/each}}\n</tbody>\n';});

define('src/course/liste_courses/layers/performances/PerfPartantsView',[
    'template!./templates/perf-det-table-header-galop.hbs',
    'template!./templates/perf-det-table-header-trot.hbs',
    'template!./templates/perf-det-table-content-galop.hbs',
    'template!./templates/perf-det-table-content-trot.hbs',
    'text!./../templates/layer-empty.hbs'
], function (headerGalopTmpl, headerTrotTmpl, contentGalopTmpl, contentTrotTmpl, emptyTmpl) {
    
    return Backbone.View.extend({

        tagName: 'table',
        className: 'table-layer table-layer-content',

        initialize: function () {
            this._initListeners();
        },
        _initListeners: function () {
            this.listenTo(this.model.participants, 'selected', this.render);
        },
        render: function (participant) {
            var headerTmpl, contentTmpl;

            if (participant && this.model.hasNotPerf(participant)) {
                this._renderError();
                participant.trigger('rendererror', participant);
                return;
            }

            headerTmpl = this.model.isGalop() ? headerGalopTmpl : headerTrotTmpl;
            contentTmpl = this.model.isGalop() ? contentGalopTmpl : contentTrotTmpl;

            participant = _.isUndefined(participant) ? this.model.getFirstParticipant() : participant;

            this.$el
                .empty()
                .removeClass('error')
                .append(headerTmpl(this.model.getNomCheval(participant), {data: {isPerfDetaillees: this.model.isPerfDetaillees() }}))
                .append(contentTmpl(this.model.getPerfs(participant), {data: {isPerfDetaillees: this.model.isPerfDetaillees() }}));

            participant.trigger('rendered', participant);
            return this;
        },
        _renderError: function () {
            this.$el
                .empty()
                .addClass('error')
                .append(emptyTmpl);
        }
    });
});
define('text!src/course/liste_courses/layers/performances/templates/perf-buttons.html',[],function () { return '<ul class="perf-nav">\n    <li>\n        <a href="#" class="btn btn-active">Performances détaillées</a>\n    </li>\n    <li>\n        <a href="#" class="btn ">Performances comparées</a>\n    </li>\n</ul>';});

/* 
== malihu jquery custom scrollbars plugin == 
version: 2.3.2 
author: malihu (http://manos.malihu.gr) 
plugin home: http://manos.malihu.gr/jquery-custom-content-scroller 
*/
(function($){
	var methods={
		init:function(options){
			var defaults={ 
				set_width:false, /*optional element width: boolean, pixels, percentage*/
				set_height:false, /*optional element height: boolean, pixels, percentage*/
				horizontalScroll:false, /*scroll horizontally: boolean*/
				scrollInertia:550, /*scrolling inertia: integer (milliseconds)*/
				scrollEasing:"easeOutCirc", /*scrolling easing: string*/
				mouseWheel:"pixels", /*mousewheel support and velocity: boolean, "auto", integer, "pixels"*/
				mouseWheelPixels:60, /*mousewheel pixels amount: integer*/
				autoDraggerLength:true, /*auto-adjust scrollbar dragger length: boolean*/
				scrollButtons:{ /*scroll buttons*/
					enable:false, /*scroll buttons support: boolean*/
					scrollType:"continuous", /*scroll buttons scrolling type: "continuous", "pixels"*/
					scrollSpeed:20, /*scroll buttons continuous scrolling speed: integer*/
					scrollAmount:40 /*scroll buttons pixels scroll amount: integer (pixels)*/
				},
				advanced:{
					updateOnBrowserResize:true, /*update scrollbars on browser resize (for layouts based on percentages): boolean*/
					updateOnContentResize:false, /*auto-update scrollbars on content resize (for dynamic content): boolean*/
					autoExpandHorizontalScroll:false, /*auto-expand width for horizontal scrolling: boolean*/
					autoScrollOnFocus:true /*auto-scroll on focused elements: boolean*/
				},
				callbacks:{
					onScrollStart:function(){}, /*user custom callback function on scroll start event*/
					onScroll:function(){}, /*user custom callback function on scroll event*/
					onTotalScroll:function(){}, /*user custom callback function on scroll end reached event*/
					onTotalScrollBack:function(){}, /*user custom callback function on scroll begin reached event*/
					onTotalScrollOffset:0, /*scroll end reached offset: integer (pixels)*/
					whileScrolling:false, /*user custom callback function on scrolling event*/
					whileScrollingInterval:30 /*interval for calling whileScrolling callback: integer (milliseconds)*/
				}
			},
			options=$.extend(true,defaults,options);
			/*check for touch device*/
			$(document).data("mCS-is-touch-device",false);
			if(is_touch_device()){
				$(document).data("mCS-is-touch-device",true); 
			}
			function is_touch_device(){
				return !!("ontouchstart" in window) ? 1 : 0;
			}
			return this.each(function(){
				var $this=$(this);
				/*set element width/height, create markup for custom scrollbars, add classes*/
				if(options.set_width){
					$this.css("width",options.set_width);
				}
				if(options.set_height){
					$this.css("height",options.set_height);
				}
				if(!$(document).data("mCustomScrollbar-index")){
					$(document).data("mCustomScrollbar-index","1");
				}else{
					var mCustomScrollbarIndex=parseInt($(document).data("mCustomScrollbar-index"));
					$(document).data("mCustomScrollbar-index",mCustomScrollbarIndex+1);
				}
				$this.wrapInner("<div class='mCustomScrollBox' id='mCSB_"+$(document).data("mCustomScrollbar-index")+"' style='position:relative; height:100%; overflow:hidden; max-width:100%;' />").addClass("mCustomScrollbar _mCS_"+$(document).data("mCustomScrollbar-index"));
				var mCustomScrollBox=$this.children(".mCustomScrollBox");
				if(options.horizontalScroll){
					mCustomScrollBox.addClass("mCSB_horizontal").wrapInner("<div class='mCSB_h_wrapper' style='position:relative; left:0; width:999999px;' />");
					var mCSB_h_wrapper=mCustomScrollBox.children(".mCSB_h_wrapper");
					mCSB_h_wrapper.wrapInner("<div class='mCSB_container' style='position:absolute; left:0;' />").children(".mCSB_container").css({"width":mCSB_h_wrapper.children().outerWidth(),"position":"relative"}).unwrap();
				}else{
					mCustomScrollBox.wrapInner("<div class='mCSB_container' style='position:relative; top:0;' />");
				}
				var mCSB_container=mCustomScrollBox.children(".mCSB_container");
				if($(document).data("mCS-is-touch-device")){
					mCSB_container.addClass("mCS_touch");
				}
				mCSB_container.after("<div class='mCSB_scrollTools' style='position:absolute;'><div class='mCSB_draggerContainer' style='position:relative;'><div class='mCSB_dragger' style='position:absolute;'><div class='mCSB_dragger_bar' style='position:relative;'></div></div><div class='mCSB_draggerRail'></div></div></div>");
				var mCSB_scrollTools=mCustomScrollBox.children(".mCSB_scrollTools"),
					mCSB_draggerContainer=mCSB_scrollTools.children(".mCSB_draggerContainer"),
					mCSB_dragger=mCSB_draggerContainer.children(".mCSB_dragger");
				if(options.horizontalScroll){
					mCSB_dragger.data("minDraggerWidth",mCSB_dragger.width());
				}else{
					mCSB_dragger.data("minDraggerHeight",mCSB_dragger.height());
				}
				if(options.scrollButtons.enable){
					if(options.horizontalScroll){
						mCSB_scrollTools.prepend("<a class='mCSB_buttonLeft' style='display:block; position:relative;'></a>").append("<a class='mCSB_buttonRight' style='display:block; position:relative;'></a>");
					}else{
						mCSB_scrollTools.prepend("<a class='mCSB_buttonUp' style='display:block; position:relative;'></a>").append("<a class='mCSB_buttonDown' style='display:block; position:relative;'></a>");
					}
				}
				/*mCustomScrollBox scrollTop and scrollLeft is always 0 to prevent browser focus scrolling*/
				mCustomScrollBox.bind("scroll",function(){
					if(!$this.is(".mCS_disabled")){ /*native focus scrolling for disabled scrollbars*/
						mCustomScrollBox.scrollTop(0).scrollLeft(0);
					}
				});
				/*store options, global vars/states, intervals and update element*/
				$this.data({
					/*init state*/
					"mCS_Init":true,
					/*option parameters*/
					"horizontalScroll":options.horizontalScroll,
					"scrollInertia":options.scrollInertia,
					"scrollEasing":options.scrollEasing,
					"mouseWheel":options.mouseWheel,
					"mouseWheelPixels":options.mouseWheelPixels,
					"autoDraggerLength":options.autoDraggerLength,
					"scrollButtons_enable":options.scrollButtons.enable,
					"scrollButtons_scrollType":options.scrollButtons.scrollType,
					"scrollButtons_scrollSpeed":options.scrollButtons.scrollSpeed,
					"scrollButtons_scrollAmount":options.scrollButtons.scrollAmount,
					"autoExpandHorizontalScroll":options.advanced.autoExpandHorizontalScroll,
					"autoScrollOnFocus":options.advanced.autoScrollOnFocus,
					"onScrollStart_Callback":options.callbacks.onScrollStart,
					"onScroll_Callback":options.callbacks.onScroll,
					"onTotalScroll_Callback":options.callbacks.onTotalScroll,
					"onTotalScrollBack_Callback":options.callbacks.onTotalScrollBack,
					"onTotalScroll_Offset":options.callbacks.onTotalScrollOffset,
					"whileScrolling_Callback":options.callbacks.whileScrolling,
					"whileScrolling_Interval":options.callbacks.whileScrollingInterval,
					/*events binding state*/
					"bindEvent_scrollbar_click":false,
					"bindEvent_mousewheel":false,
					"bindEvent_focusin":false,
					"bindEvent_buttonsContinuous_y":false,
					"bindEvent_buttonsContinuous_x":false,
					"bindEvent_buttonsPixels_y":false,
					"bindEvent_buttonsPixels_x":false,
					"bindEvent_scrollbar_touch":false,
					"bindEvent_content_touch":false,
					/*buttons intervals*/
					"mCSB_buttonScrollRight":false,
					"mCSB_buttonScrollLeft":false,
					"mCSB_buttonScrollDown":false,
					"mCSB_buttonScrollUp":false,
					/*callback intervals*/
					"whileScrolling":false
				}).mCustomScrollbar("update");
				/*detect max-width*/
				if(options.horizontalScroll){
					if($this.css("max-width")!=="none"){
						if(!options.advanced.updateOnContentResize){ /*needs updateOnContentResize*/
							options.advanced.updateOnContentResize=true;
						}
						$this.data({"mCS_maxWidth":parseInt($this.css("max-width")),"mCS_maxWidth_Interval":setInterval(function(){
							if(mCSB_container.outerWidth()>$this.data("mCS_maxWidth")){
								clearInterval($this.data("mCS_maxWidth_Interval"));
								$this.mCustomScrollbar("update");
							}
						},150)});
					}
				}else{
					/*detect max-height*/
					if($this.css("max-height")!=="none"){
						$this.data({"mCS_maxHeight":parseInt($this.css("max-height")),"mCS_maxHeight_Interval":setInterval(function(){
							mCustomScrollBox.css("max-height",$this.data("mCS_maxHeight"));
							if(mCSB_container.outerHeight()>$this.data("mCS_maxHeight")){
								clearInterval($this.data("mCS_maxHeight_Interval"));
								$this.mCustomScrollbar("update");
							}
						},150)});
					}
				}
				/*window resize fn (for layouts based on percentages)*/
				if(options.advanced.updateOnBrowserResize){
					var mCSB_resizeTimeout;
					$(window).resize(function(){
						if(mCSB_resizeTimeout){
							clearTimeout(mCSB_resizeTimeout);
						}
						mCSB_resizeTimeout=setTimeout(function(){
							if(!$this.is(".mCS_disabled") && !$this.is(".mCS_destroyed")){
								$this.mCustomScrollbar("update");
							}
						},150);
					});
				}
				/*content resize fn (for dynamically generated content)*/
				if(options.advanced.updateOnContentResize){
					var mCSB_onContentResize;
					if(options.horizontalScroll){
						var mCSB_containerOldSize=mCSB_container.outerWidth();
					}else{
						var mCSB_containerOldSize=mCSB_container.outerHeight();
					}
					mCSB_onContentResize=setInterval(function(){
						if(options.horizontalScroll){
							if(options.advanced.autoExpandHorizontalScroll){
								mCSB_container.css({"position":"absolute","width":"auto"}).wrap("<div class='mCSB_h_wrapper' style='position:relative; left:0; width:999999px;' />").css({"width":mCSB_container.outerWidth(),"position":"relative"}).unwrap();
							}
							var mCSB_containerNewSize=mCSB_container.outerWidth();
						}else{
							var mCSB_containerNewSize=mCSB_container.outerHeight();
						}
						if(mCSB_containerNewSize!=mCSB_containerOldSize){
							$this.mCustomScrollbar("update");
							mCSB_containerOldSize=mCSB_containerNewSize;
						}
					},300);
				}
			});
		},
		update:function(){
			var $this=$(this),
				mCustomScrollBox=$this.children(".mCustomScrollBox"),
				mCSB_container=mCustomScrollBox.children(".mCSB_container");
			mCSB_container.removeClass("mCS_no_scrollbar");
			$this.removeClass("mCS_disabled mCS_destroyed");
			mCustomScrollBox.scrollTop(0).scrollLeft(0); /*reset scrollTop/scrollLeft to prevent browser focus scrolling*/
			var mCSB_scrollTools=mCustomScrollBox.children(".mCSB_scrollTools"),
				mCSB_draggerContainer=mCSB_scrollTools.children(".mCSB_draggerContainer"),
				mCSB_dragger=mCSB_draggerContainer.children(".mCSB_dragger");
			if($this.data("horizontalScroll")){
				var mCSB_buttonLeft=mCSB_scrollTools.children(".mCSB_buttonLeft"),
					mCSB_buttonRight=mCSB_scrollTools.children(".mCSB_buttonRight"),
					mCustomScrollBoxW=mCustomScrollBox.width();
				if($this.data("autoExpandHorizontalScroll")){
					mCSB_container.css({"position":"absolute","width":"auto"}).wrap("<div class='mCSB_h_wrapper' style='position:relative; left:0; width:999999px;' />").css({"width":mCSB_container.outerWidth(),"position":"relative"}).unwrap();
				}
				var mCSB_containerW=mCSB_container.outerWidth();
			}else{
				var mCSB_buttonUp=mCSB_scrollTools.children(".mCSB_buttonUp"),
					mCSB_buttonDown=mCSB_scrollTools.children(".mCSB_buttonDown"),
					mCustomScrollBoxH=mCustomScrollBox.height(),
					mCSB_containerH=mCSB_container.outerHeight();
			}
			if(mCSB_containerH>mCustomScrollBoxH && !$this.data("horizontalScroll")){ /*content needs vertical scrolling*/
				mCSB_scrollTools.css("display","block");
				var mCSB_draggerContainerH=mCSB_draggerContainer.height();
				/*auto adjust scrollbar dragger length analogous to content*/
				if($this.data("autoDraggerLength")){
					var draggerH=Math.round(mCustomScrollBoxH/mCSB_containerH*mCSB_draggerContainerH),
						minDraggerH=mCSB_dragger.data("minDraggerHeight");
					if(draggerH<=minDraggerH){ /*min dragger height*/
						mCSB_dragger.css({"height":minDraggerH});
					}else if(draggerH>=mCSB_draggerContainerH-10){ /*max dragger height*/
						var mCSB_draggerContainerMaxH=mCSB_draggerContainerH-10;
						mCSB_dragger.css({"height":mCSB_draggerContainerMaxH});
					}else{
						mCSB_dragger.css({"height":draggerH});
					}
					mCSB_dragger.children(".mCSB_dragger_bar").css({"line-height":mCSB_dragger.height()+"px"});
				}
				var mCSB_draggerH=mCSB_dragger.height(),
				/*calculate and store scroll amount, add scrolling*/
					scrollAmount=(mCSB_containerH-mCustomScrollBoxH)/(mCSB_draggerContainerH-mCSB_draggerH);
				$this.data("scrollAmount",scrollAmount).mCustomScrollbar("scrolling",mCustomScrollBox,mCSB_container,mCSB_draggerContainer,mCSB_dragger,mCSB_buttonUp,mCSB_buttonDown,mCSB_buttonLeft,mCSB_buttonRight);
				/*scroll*/
				var mCSB_containerP=Math.abs(Math.round(mCSB_container.position().top));
				$this.mCustomScrollbar("scrollTo",mCSB_containerP,{callback:false});
			}else if(mCSB_containerW>mCustomScrollBoxW && $this.data("horizontalScroll")){ /*content needs horizontal scrolling*/
				mCSB_scrollTools.css("display","block");
				var mCSB_draggerContainerW=mCSB_draggerContainer.width();
				/*auto adjust scrollbar dragger length analogous to content*/
				if($this.data("autoDraggerLength")){
					var draggerW=Math.round(mCustomScrollBoxW/mCSB_containerW*mCSB_draggerContainerW),
						minDraggerW=mCSB_dragger.data("minDraggerWidth");
					if(draggerW<=minDraggerW){ /*min dragger height*/
						mCSB_dragger.css({"width":minDraggerW});
					}else if(draggerW>=mCSB_draggerContainerW-10){ /*max dragger height*/
						var mCSB_draggerContainerMaxW=mCSB_draggerContainerW-10;
						mCSB_dragger.css({"width":mCSB_draggerContainerMaxW});
					}else{
						mCSB_dragger.css({"width":draggerW});
					}
				}
				var mCSB_draggerW=mCSB_dragger.width(),
				/*calculate and store scroll amount, add scrolling*/
					scrollAmount=(mCSB_containerW-mCustomScrollBoxW)/(mCSB_draggerContainerW-mCSB_draggerW);
				$this.data("scrollAmount",scrollAmount).mCustomScrollbar("scrolling",mCustomScrollBox,mCSB_container,mCSB_draggerContainer,mCSB_dragger,mCSB_buttonUp,mCSB_buttonDown,mCSB_buttonLeft,mCSB_buttonRight);
				/*scroll*/
				var mCSB_containerP=Math.abs(Math.round(mCSB_container.position().left));
				$this.mCustomScrollbar("scrollTo",mCSB_containerP,{callback:false});
			}else{ /*content does not need scrolling*/
				/*unbind events, reset content position, hide scrollbars, remove classes*/
				mCustomScrollBox.unbind("mousewheel focusin");
				if($this.data("horizontalScroll")){
					mCSB_dragger.add(mCSB_container).css("left",0);
				}else{
					mCSB_dragger.add(mCSB_container).css("top",0);
				}
				mCSB_scrollTools.css("display","none");
				mCSB_container.addClass("mCS_no_scrollbar");
				$this.data({"bindEvent_mousewheel":false,"bindEvent_focusin":false});
			}
		},
		scrolling:function(mCustomScrollBox,mCSB_container,mCSB_draggerContainer,mCSB_dragger,mCSB_buttonUp,mCSB_buttonDown,mCSB_buttonLeft,mCSB_buttonRight){
			var $this=$(this);
			/*while scrolling callback*/
			$this.mCustomScrollbar("callbacks","whileScrolling"); 
			/*drag scrolling*/
			if(!mCSB_dragger.hasClass("ui-draggable")){ /*apply drag function once*/
				if($this.data("horizontalScroll")){
					var draggableAxis="x";
				}else{
					var draggableAxis="y";
				}
				mCSB_dragger.draggable({ 
					axis:draggableAxis,
					containment:"parent",
					drag:function(event,ui){
						$this.mCustomScrollbar("scroll");
						mCSB_dragger.addClass("mCSB_dragger_onDrag");
					},
					stop:function(event,ui){
						mCSB_dragger.removeClass("mCSB_dragger_onDrag");	
					}
				});
			}
			if(!$this.data("bindEvent_scrollbar_click")){ /*bind once*/
				mCSB_draggerContainer.bind("click",function(e){
					if($this.data("horizontalScroll")){
						var mouseCoord=(e.pageX-mCSB_draggerContainer.offset().left);
						if(mouseCoord<mCSB_dragger.position().left || mouseCoord>(mCSB_dragger.position().left+mCSB_dragger.width())){
							var scrollToPos=mouseCoord;
							if(scrollToPos>=mCSB_draggerContainer.width()-mCSB_dragger.width()){ /*max dragger position is bottom*/
								scrollToPos=mCSB_draggerContainer.width()-mCSB_dragger.width();
							}
							mCSB_dragger.css("left",scrollToPos);
							$this.mCustomScrollbar("scroll");
						}
					}else{
						var mouseCoord=(e.pageY-mCSB_draggerContainer.offset().top);
						if(mouseCoord<mCSB_dragger.position().top || mouseCoord>(mCSB_dragger.position().top+mCSB_dragger.height())){
							var scrollToPos=mouseCoord;
							if(scrollToPos>=mCSB_draggerContainer.height()-mCSB_dragger.height()){ /*max dragger position is bottom*/
								scrollToPos=mCSB_draggerContainer.height()-mCSB_dragger.height();
							}
							mCSB_dragger.css("top",scrollToPos);
							$this.mCustomScrollbar("scroll");
						}
					}
				});
				$this.data({"bindEvent_scrollbar_click":true});
			}
			/*mousewheel scrolling*/
			if($this.data("mouseWheel")){
				var mousewheelVel=$this.data("mouseWheel");
				if($this.data("mouseWheel")==="auto"){
					mousewheelVel=8; /*default mousewheel velocity*/
					/*check for safari browser on mac osx to lower mousewheel velocity*/
					var os=navigator.userAgent;
					if(os.indexOf("Mac")!=-1 && os.indexOf("Safari")!=-1 && os.indexOf("AppleWebKit")!=-1 && os.indexOf("Chrome")==-1){ 
						mousewheelVel=1;
					}
				}
				if(!$this.data("bindEvent_mousewheel")){ /*bind once*/
					mCustomScrollBox.bind("mousewheel",function(event,delta){
						event.preventDefault();
						var vel=Math.abs(delta*mousewheelVel);
						if($this.data("horizontalScroll")){
							if($this.data("mouseWheel")==="pixels"){
								if(delta<0){
									delta=-1;
								}else{
									delta=1;
								}
								var scrollTo=Math.abs(Math.round(mCSB_container.position().left))-(delta*$this.data("mouseWheelPixels"));
								$this.mCustomScrollbar("scrollTo",scrollTo);
							}else{
								var posX=mCSB_dragger.position().left-(delta*vel);
								mCSB_dragger.css("left",posX);
								if(mCSB_dragger.position().left<0){
									mCSB_dragger.css("left",0);
								}
								var mCSB_draggerContainerW=mCSB_draggerContainer.width(),
									mCSB_draggerW=mCSB_dragger.width();
								if(mCSB_dragger.position().left>mCSB_draggerContainerW-mCSB_draggerW){
									mCSB_dragger.css("left",mCSB_draggerContainerW-mCSB_draggerW);
								}
								$this.mCustomScrollbar("scroll");
							}
						}else{
							if($this.data("mouseWheel")==="pixels"){
								if(delta<0){
									delta=-1;
								}else{
									delta=1;
								}
								var scrollTo=Math.abs(Math.round(mCSB_container.position().top))-(delta*$this.data("mouseWheelPixels"));
								$this.mCustomScrollbar("scrollTo",scrollTo);
							}else{
								var posY=mCSB_dragger.position().top-(delta*vel);
								mCSB_dragger.css("top",posY);
								if(mCSB_dragger.position().top<0){
									mCSB_dragger.css("top",0);
								}
								var mCSB_draggerContainerH=mCSB_draggerContainer.height(),
									mCSB_draggerH=mCSB_dragger.height();
								if(mCSB_dragger.position().top>mCSB_draggerContainerH-mCSB_draggerH){
									mCSB_dragger.css("top",mCSB_draggerContainerH-mCSB_draggerH);
								}
								$this.mCustomScrollbar("scroll");
							}
						}
					});
					$this.data({"bindEvent_mousewheel":true});
				}
			}
			/*buttons scrolling*/
			if($this.data("scrollButtons_enable")){
				if($this.data("scrollButtons_scrollType")==="pixels"){ /*scroll by pixels*/
					var pixelsScrollTo;
					if($.browser.msie && parseInt($.browser.version)<9){ /*stupid ie8*/
						$this.data("scrollInertia",0);
					}
					if($this.data("horizontalScroll")){
						mCSB_buttonRight.add(mCSB_buttonLeft).unbind("mousedown touchstart onmsgesturestart mouseup mouseout touchend onmsgestureend",mCSB_buttonRight_stop,mCSB_buttonLeft_stop);
						$this.data({"bindEvent_buttonsContinuous_x":false});
						if(!$this.data("bindEvent_buttonsPixels_x")){ /*bind once*/
							/*scroll right*/
							mCSB_buttonRight.bind("click",function(e){
								e.preventDefault();
								if(!mCSB_container.is(":animated")){
									pixelsScrollTo=Math.abs(mCSB_container.position().left)+$this.data("scrollButtons_scrollAmount");
									$this.mCustomScrollbar("scrollTo",pixelsScrollTo);
								}
							});
							/*scroll left*/
							mCSB_buttonLeft.bind("click",function(e){
								e.preventDefault();
								if(!mCSB_container.is(":animated")){
									pixelsScrollTo=Math.abs(mCSB_container.position().left)-$this.data("scrollButtons_scrollAmount");
									if(mCSB_container.position().left>=-$this.data("scrollButtons_scrollAmount")){
										pixelsScrollTo="left";
									}
									$this.mCustomScrollbar("scrollTo",pixelsScrollTo);
								}
							});
							$this.data({"bindEvent_buttonsPixels_x":true});
						}
					}else{
						mCSB_buttonDown.add(mCSB_buttonUp).unbind("mousedown touchstart onmsgesturestart mouseup mouseout touchend onmsgestureend",mCSB_buttonRight_stop,mCSB_buttonLeft_stop);
						$this.data({"bindEvent_buttonsContinuous_y":false});
						if(!$this.data("bindEvent_buttonsPixels_y")){ /*bind once*/
							/*scroll down*/
							mCSB_buttonDown.bind("click",function(e){
								e.preventDefault();
								if(!mCSB_container.is(":animated")){
									pixelsScrollTo=Math.abs(mCSB_container.position().top)+$this.data("scrollButtons_scrollAmount");
									$this.mCustomScrollbar("scrollTo",pixelsScrollTo);
								}
							});
							/*scroll up*/
							mCSB_buttonUp.bind("click",function(e){
								e.preventDefault();
								if(!mCSB_container.is(":animated")){
									pixelsScrollTo=Math.abs(mCSB_container.position().top)-$this.data("scrollButtons_scrollAmount");
									if(mCSB_container.position().top>=-$this.data("scrollButtons_scrollAmount")){
										pixelsScrollTo="top";
									}
									$this.mCustomScrollbar("scrollTo",pixelsScrollTo);
								}
							});
							$this.data({"bindEvent_buttonsPixels_y":true});
						}
					}
				}else{ /*continuous scrolling*/
					if($this.data("horizontalScroll")){
						mCSB_buttonRight.add(mCSB_buttonLeft).unbind("click");
						$this.data({"bindEvent_buttonsPixels_x":false});
						if(!$this.data("bindEvent_buttonsContinuous_x")){ /*bind once*/
							/*scroll right*/
							mCSB_buttonRight.bind("mousedown touchstart onmsgesturestart",function(e){
								e.preventDefault();
								e.stopPropagation();
								$this.data({"mCSB_buttonScrollRight":setInterval(function(){
									var scrollTo=Math.round((Math.abs(Math.round(mCSB_container.position().left))+$this.data("scrollButtons_scrollSpeed"))/$this.data("scrollAmount"));
									$this.mCustomScrollbar("scrollTo",scrollTo,{moveDragger:true});
								},30)});
							});
							var mCSB_buttonRight_stop=function(e){
								e.preventDefault();
								e.stopPropagation();
								clearInterval($this.data("mCSB_buttonScrollRight"));
							}
							mCSB_buttonRight.bind("mouseup touchend onmsgestureend mouseout",mCSB_buttonRight_stop);
							/*scroll left*/
							mCSB_buttonLeft.bind("mousedown touchstart onmsgesturestart",function(e){
								e.preventDefault();
								e.stopPropagation();
								$this.data({"mCSB_buttonScrollLeft":setInterval(function(){
									var scrollTo=Math.round((Math.abs(Math.round(mCSB_container.position().left))-$this.data("scrollButtons_scrollSpeed"))/$this.data("scrollAmount"));
									$this.mCustomScrollbar("scrollTo",scrollTo,{moveDragger:true});
								},30)});
							});	
							var mCSB_buttonLeft_stop=function(e){
								e.preventDefault();
								e.stopPropagation();
								clearInterval($this.data("mCSB_buttonScrollLeft"));
							}
							mCSB_buttonLeft.bind("mouseup touchend onmsgestureend mouseout",mCSB_buttonLeft_stop);
							$this.data({"bindEvent_buttonsContinuous_x":true});
						}
					}else{
						mCSB_buttonDown.add(mCSB_buttonUp).unbind("click");
						$this.data({"bindEvent_buttonsPixels_y":false});
						if(!$this.data("bindEvent_buttonsContinuous_y")){ /*bind once*/
							/*scroll down*/
							mCSB_buttonDown.bind("mousedown touchstart onmsgesturestart",function(e){
								e.preventDefault();
								e.stopPropagation();
								$this.data({"mCSB_buttonScrollDown":setInterval(function(){
									var scrollTo=Math.round((Math.abs(Math.round(mCSB_container.position().top))+$this.data("scrollButtons_scrollSpeed"))/$this.data("scrollAmount"));
									$this.mCustomScrollbar("scrollTo",scrollTo,{moveDragger:true});
								},30)});
							});
							var mCSB_buttonDown_stop=function(e){
								e.preventDefault();
								e.stopPropagation();
								clearInterval($this.data("mCSB_buttonScrollDown"));
							}
							mCSB_buttonDown.bind("mouseup touchend onmsgestureend mouseout",mCSB_buttonDown_stop);
							/*scroll up*/
							mCSB_buttonUp.bind("mousedown touchstart onmsgesturestart",function(e){
								e.preventDefault();
								e.stopPropagation();
								$this.data({"mCSB_buttonScrollUp":setInterval(function(){
									var scrollTo=Math.round((Math.abs(Math.round(mCSB_container.position().top))-$this.data("scrollButtons_scrollSpeed"))/$this.data("scrollAmount"));
									$this.mCustomScrollbar("scrollTo",scrollTo,{moveDragger:true});
								},30)});
							});	
							var mCSB_buttonUp_stop=function(e){
								e.preventDefault();
								e.stopPropagation();
								clearInterval($this.data("mCSB_buttonScrollUp"));
							}
							mCSB_buttonUp.bind("mouseup touchend onmsgestureend mouseout",mCSB_buttonUp_stop);
							$this.data({"bindEvent_buttonsContinuous_y":true});
						}
					}
				}
			}
			/*scrolling on element focus (e.g. via TAB key)*/
			if($this.data("autoScrollOnFocus")){
				if(!$this.data("bindEvent_focusin")){ /*bind once*/
					mCustomScrollBox.bind("focusin",function(){
						mCustomScrollBox.scrollTop(0).scrollLeft(0);
						var focusedElem=$(document.activeElement);
						if(focusedElem.is("input,textarea,select,button,a[tabindex],area,object")){
							if($this.data("horizontalScroll")){
								var mCSB_containerX=mCSB_container.position().left,
									focusedElemX=focusedElem.position().left,
									mCustomScrollBoxW=mCustomScrollBox.width(),
									focusedElemW=focusedElem.outerWidth();
								if(mCSB_containerX+focusedElemX>=0 && mCSB_containerX+focusedElemX<=mCustomScrollBoxW-focusedElemW){
									/*just focus...*/
								}else{ /*scroll, then focus*/
									var moveDragger=focusedElemX/$this.data("scrollAmount");
									if(moveDragger>=mCSB_draggerContainer.width()-mCSB_dragger.width()){ /*max dragger position is bottom*/
										moveDragger=mCSB_draggerContainer.width()-mCSB_dragger.width();
									}
									mCSB_dragger.css("left",moveDragger);
									$this.mCustomScrollbar("scroll");
								}
							}else{
								var mCSB_containerY=mCSB_container.position().top,
									focusedElemY=focusedElem.position().top,
									mCustomScrollBoxH=mCustomScrollBox.height(),
									focusedElemH=focusedElem.outerHeight();
								if(mCSB_containerY+focusedElemY>=0 && mCSB_containerY+focusedElemY<=mCustomScrollBoxH-focusedElemH){
									/*just focus...*/
								}else{ /*scroll, then focus*/
									var moveDragger=focusedElemY/$this.data("scrollAmount");
									if(moveDragger>=mCSB_draggerContainer.height()-mCSB_dragger.height()){ /*max dragger position is bottom*/
										moveDragger=mCSB_draggerContainer.height()-mCSB_dragger.height();
									}
									mCSB_dragger.css("top",moveDragger);
									$this.mCustomScrollbar("scroll");
								}
							}
						}
					});
					$this.data({"bindEvent_focusin":true});
				}
			}
			/*touch events*/
			if($(document).data("mCS-is-touch-device")){
				/*scrollbar touch-drag*/
				if(!$this.data("bindEvent_scrollbar_touch")){ /*bind once*/
					var mCSB_draggerTouchY,
						mCSB_draggerTouchX;
					mCSB_dragger.bind("touchstart onmsgesturestart",function(e){
						e.preventDefault();
						e.stopPropagation();
						var touch=e.originalEvent.touches[0] || e.originalEvent.changedTouches[0],
							elem=$(this),
							elemOffset=elem.offset(),
							x=touch.pageX-elemOffset.left,
							y=touch.pageY-elemOffset.top;
						if(x<elem.width() && x>0 && y<elem.height() && y>0){
							mCSB_draggerTouchY=y;
							mCSB_draggerTouchX=x;
						}
					});
					mCSB_dragger.bind("touchmove onmsgesturechange",function(e){
						e.preventDefault();
						e.stopPropagation();
						var touch=e.originalEvent.touches[0] || e.originalEvent.changedTouches[0],
							elem=$(this),
							elemOffset=elem.offset(),
							x=touch.pageX-elemOffset.left,
							y=touch.pageY-elemOffset.top;
						if($this.data("horizontalScroll")){
							$this.mCustomScrollbar("scrollTo",(mCSB_dragger.position().left-(mCSB_draggerTouchX))+x,{moveDragger:true});
						}else{
							$this.mCustomScrollbar("scrollTo",(mCSB_dragger.position().top-(mCSB_draggerTouchY))+y,{moveDragger:true});
						}
					});
					$this.data({"bindEvent_scrollbar_touch":true});
				}
				/*content touch-drag*/
				if(!$this.data("bindEvent_content_touch")){ /*bind once*/
					var touch,
						elem,
						elemOffset,
						x,
						y,
						mCSB_containerTouchY,
						mCSB_containerTouchX;
					mCSB_container.bind("touchstart onmsgesturestart",function(e){
						touch=e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
						elem=$(this);
						elemOffset=elem.offset();
						x=touch.pageX-elemOffset.left;
						y=touch.pageY-elemOffset.top;
						mCSB_containerTouchY=y;
						mCSB_containerTouchX=x;
					});
					mCSB_container.bind("touchmove onmsgesturechange",function(e){
						e.preventDefault();
						e.stopPropagation();
						touch=e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
						elem=$(this).parent();
						elemOffset=elem.offset();
						x=touch.pageX-elemOffset.left;
						y=touch.pageY-elemOffset.top;
						if($this.data("horizontalScroll")){
							$this.mCustomScrollbar("scrollTo",mCSB_containerTouchX-x);
						}else{
							$this.mCustomScrollbar("scrollTo",mCSB_containerTouchY-y);
						}
					});
					$this.data({"bindEvent_content_touch":true});
				}
			}
		},
		scroll:function(bypassCallbacks){
			var $this=$(this),
				mCSB_dragger=$this.find(".mCSB_dragger"),
				mCSB_container=$this.find(".mCSB_container"),
				mCustomScrollBox=$this.find(".mCustomScrollBox");
			if($this.data("horizontalScroll")){
				var draggerX=mCSB_dragger.position().left,
					targX=-draggerX*$this.data("scrollAmount"),
					thisX=mCSB_container.position().left,
					posX=Math.round(thisX-targX);
			}else{
				var draggerY=mCSB_dragger.position().top,
					targY=-draggerY*$this.data("scrollAmount"),
					thisY=mCSB_container.position().top,
					posY=Math.round(thisY-targY);
			}
			if($.browser.webkit){ /*fix webkit zoom and jquery animate*/
				var screenCssPixelRatio=(window.outerWidth-8)/window.innerWidth,
					isZoomed=(screenCssPixelRatio<.98 || screenCssPixelRatio>1.02);
			}
			if($this.data("scrollInertia")===0 || isZoomed){
				if(!bypassCallbacks){
					$this.mCustomScrollbar("callbacks","onScrollStart"); /*user custom callback functions*/
				}
				if($this.data("horizontalScroll")){
					mCSB_container.css("left",targX);
				}else{
					mCSB_container.css("top",targY);
				}
				if(!bypassCallbacks){
					/*user custom callback functions*/
					if($this.data("whileScrolling")){
						$this.data("whileScrolling_Callback").call();
					}
					$this.mCustomScrollbar("callbacks","onScroll");  
				}
				$this.data({"mCS_Init":false});
			}else{
				if(!bypassCallbacks){
					$this.mCustomScrollbar("callbacks","onScrollStart"); /*user custom callback functions*/
				}
				if($this.data("horizontalScroll")){
					mCSB_container.stop().animate({left:"-="+posX},$this.data("scrollInertia"),$this.data("scrollEasing"),function(){
						if(!bypassCallbacks){
							$this.mCustomScrollbar("callbacks","onScroll"); /*user custom callback functions*/
						}
						$this.data({"mCS_Init":false});
					});
				}else{
					mCSB_container.stop().animate({top:"-="+posY},$this.data("scrollInertia"),$this.data("scrollEasing"),function(){
						if(!bypassCallbacks){
							$this.mCustomScrollbar("callbacks","onScroll"); /*user custom callback functions*/
						}
						$this.data({"mCS_Init":false});
					});
				}
			}
		},
		scrollTo:function(scrollTo,options){
			var defaults={
				moveDragger:false,
				callback:true
			},
				options=$.extend(defaults,options),
				$this=$(this),
				scrollToPos,
				mCustomScrollBox=$this.find(".mCustomScrollBox"),
				mCSB_container=mCustomScrollBox.children(".mCSB_container"),
				mCSB_draggerContainer=$this.find(".mCSB_draggerContainer"),
				mCSB_dragger=mCSB_draggerContainer.children(".mCSB_dragger"),
				targetPos;
			if(scrollTo || scrollTo===0){
				if(typeof(scrollTo)==="number"){ /*if integer, scroll by number of pixels*/
					if(options.moveDragger){ /*scroll dragger*/
						scrollToPos=scrollTo;
					}else{ /*scroll content by default*/
						targetPos=scrollTo;
						scrollToPos=Math.round(targetPos/$this.data("scrollAmount"));
					}
				}else if(typeof(scrollTo)==="string"){ /*if string, scroll by element position*/
					var target;
					if(scrollTo==="top"){ /*scroll to top*/
						target=0;
					}else if(scrollTo==="bottom" && !$this.data("horizontalScroll")){ /*scroll to bottom*/
						target=mCSB_container.outerHeight()-mCustomScrollBox.height();
					}else if(scrollTo==="left"){ /*scroll to left*/
						target=0;
					}else if(scrollTo==="right" && $this.data("horizontalScroll")){ /*scroll to right*/
						target=mCSB_container.outerWidth()-mCustomScrollBox.width();
					}else if(scrollTo==="first"){ /*scroll to first element position*/
						target=$this.find(".mCSB_container").find(":first");
					}else if(scrollTo==="last"){ /*scroll to last element position*/
						target=$this.find(".mCSB_container").find(":last");
					}else{ /*scroll to element position*/
						target=$this.find(scrollTo);
					}
					if(target.length===1){ /*if such unique element exists, scroll to it*/
						if($this.data("horizontalScroll")){
							targetPos=target.position().left;
						}else{
							targetPos=target.position().top;
						}
						scrollToPos=Math.ceil(targetPos/$this.data("scrollAmount"));
					}else{
						scrollToPos=target;
					}
				}
				/*scroll to*/
				if(scrollToPos<0){
					scrollToPos=0;
				}
				if($this.data("horizontalScroll")){
					if(scrollToPos>=mCSB_draggerContainer.width()-mCSB_dragger.width()){ /*max dragger position is bottom*/
						scrollToPos=mCSB_draggerContainer.width()-mCSB_dragger.width();
					}
					mCSB_dragger.css("left",scrollToPos);
				}else{
					if(scrollToPos>=mCSB_draggerContainer.height()-mCSB_dragger.height()){ /*max dragger position is bottom*/
						scrollToPos=mCSB_draggerContainer.height()-mCSB_dragger.height();
					}
					mCSB_dragger.css("top",scrollToPos);
				}
				if(options.callback){
					$this.mCustomScrollbar("scroll",false);
				}else{
					$this.mCustomScrollbar("scroll",true);
				}
			}
		},
		callbacks:function(callback){
			var $this=$(this),
				mCustomScrollBox=$this.find(".mCustomScrollBox"),
				mCSB_container=$this.find(".mCSB_container");
			switch(callback){
				/*start scrolling callback*/
				case "onScrollStart":
					if(!mCSB_container.is(":animated")){
						$this.data("onScrollStart_Callback").call();
					}
					break;
				/*end scrolling callback*/
				case "onScroll":
					if($this.data("horizontalScroll")){
						var mCSB_containerX=Math.round(mCSB_container.position().left);
						if(mCSB_containerX<0 && mCSB_containerX<=mCustomScrollBox.width()-mCSB_container.outerWidth()+$this.data("onTotalScroll_Offset")){
							$this.data("onTotalScroll_Callback").call();
						}else if(mCSB_containerX>=-$this.data("onTotalScroll_Offset")){
							$this.data("onTotalScrollBack_Callback").call();
						}else{
							$this.data("onScroll_Callback").call();
						}
					}else{
						var mCSB_containerY=Math.round(mCSB_container.position().top);
						if(mCSB_containerY<0 && mCSB_containerY<=mCustomScrollBox.height()-mCSB_container.outerHeight()+$this.data("onTotalScroll_Offset")){
							$this.data("onTotalScroll_Callback").call();
						}else if(mCSB_containerY>=-$this.data("onTotalScroll_Offset")){
							$this.data("onTotalScrollBack_Callback").call();
						}else{
							$this.data("onScroll_Callback").call();
						}
					}
					break;
				/*while scrolling callback*/
				case "whileScrolling":
					if($this.data("whileScrolling_Callback") && !$this.data("whileScrolling")){
						$this.data({"whileScrolling":setInterval(function(){
							if(mCSB_container.is(":animated") && !$this.data("mCS_Init")){
								$this.data("whileScrolling_Callback").call();
							}
						},$this.data("whileScrolling_Interval"))});
					}
					break;
			}
		},
		disable:function(resetScroll){
			var $this=$(this),
				mCustomScrollBox=$this.children(".mCustomScrollBox"),
				mCSB_container=mCustomScrollBox.children(".mCSB_container"),
				mCSB_scrollTools=mCustomScrollBox.children(".mCSB_scrollTools"),
				mCSB_dragger=mCSB_scrollTools.find(".mCSB_dragger");
			mCustomScrollBox.unbind("mousewheel focusin");
			if(resetScroll){
				if($this.data("horizontalScroll")){
					mCSB_dragger.add(mCSB_container).css("left",0);
				}else{
					mCSB_dragger.add(mCSB_container).css("top",0);
				}
			}
			mCSB_scrollTools.css("display","none");
			mCSB_container.addClass("mCS_no_scrollbar");
			$this.data({"bindEvent_mousewheel":false,"bindEvent_focusin":false}).addClass("mCS_disabled");
		},
		destroy:function(){
			var $this=$(this),
				content=$this.find(".mCSB_container").html();
			$this.find(".mCustomScrollBox").remove();
			$this.html(content).removeClass("mCustomScrollbar _mCS_"+$(document).data("mCustomScrollbar-index")).addClass("mCS_destroyed");
		}
	}
	$.fn.mCustomScrollbar=function(method){
		if(methods[method]){
			return methods[method].apply(this,Array.prototype.slice.call(arguments,1));
		}else if(typeof method==="object" || !method){
			return methods.init.apply(this,arguments);
		}else{
			$.error("Method "+method+" does not exist");
		}
	};
})(jQuery); 
/*iOS 6 bug fix 
  iOS 6 suffers from a bug that kills timers that are created while a page is scrolling. 
  The following fixes that problem by recreating timers after scrolling finishes (with interval correction).*/
var iOSVersion=iOSVersion();
if(iOSVersion>=6){
	(function(h){var a={};var d={};var e=h.setTimeout;var f=h.setInterval;var i=h.clearTimeout;var c=h.clearInterval;if(!h.addEventListener){return false}function j(q,n,l){var p,k=l[0],m=(q===f);function o(){if(k){k.apply(h,arguments);if(!m){delete n[p];k=null}}}l[0]=o;p=q.apply(h,l);n[p]={args:l,created:Date.now(),cb:k,id:p};return p}function b(q,o,k,r,t){var l=k[r];if(!l){return}var m=(q===f);o(l.id);if(!m){var n=l.args[1];var p=Date.now()-l.created;if(p<0){p=0}n-=p;if(n<0){n=0}l.args[1]=n}function s(){if(l.cb){l.cb.apply(h,arguments);if(!m){delete k[r];l.cb=null}}}l.args[0]=s;l.created=Date.now();l.id=q.apply(h,l.args)}h.setTimeout=function(){return j(e,a,arguments)};h.setInterval=function(){return j(f,d,arguments)};h.clearTimeout=function(l){var k=a[l];if(k){delete a[l];i(k.id)}};h.clearInterval=function(l){var k=d[l];if(k){delete d[l];c(k.id)}};var g=h;while(g.location!=g.parent.location){g=g.parent}g.addEventListener("scroll",function(){var k;for(k in a){b(e,i,a,k)}for(k in d){b(f,c,d,k)}})}(window));
}
function iOSVersion(){
	var agent=window.navigator.userAgent,
		start=agent.indexOf('OS ');
	if((agent.indexOf('iPhone')>-1 || agent.indexOf('iPad')>-1) && start>-1){
		return window.Number(agent.substr(start+3,3).replace('_','.'));
	}
	return 0;
};
define("lib/vendor/jquery.mCustomScrollbar", function(){});

define('src/course/liste_courses/layers/performances/PerfView',[
    '../LayerView',
    './PerfModel',
    './PerfListePartantsView',
    './PerfPartantsView',
    'text!./templates/perf-buttons.html',
    'tagCommander',
    'typeDeSite',
    'lib/vendor/jquery.mCustomScrollbar'
], function (LayerView, PerfModel, PerfListePartantsView, PerfPartantsView, perfButtonsTmpl, tagCommander, typeDeSite) {
    

    return LayerView.extend({
        events: {
            'click .btn': '_toggleView'
        },
        libelle: 'Performances',

        initialize: function () {
            this.debug('init LayerPerfView');

            _.extend(this.options, {libelle: this.libelle});

            this._initModels();
            this._initListeners();
            this._createSubViews();

            this.sendTag();

            this.$el.append(this.partants.el);
            this.$el.append($('<div class="detail"/>').html(this.performancesPartant.el));
            this.$el.append('<div class="message"/>');
            this.$el.append(perfButtonsTmpl);
            this.$el.hide();

            LayerView.prototype.initialize.call(this);
        },

        sendTag: function () {
            tagCommander.sendTags(
                'hippique.parier.reunion.course.performance',
                'programme_resultats.course.performances',
                {
                    bet_reunion_id: this.model.numReunion,
                    bet_course_id: this.model.numCourse
                }
            );
        },

        _initModels: function () {
            this.model = new PerfModel({}, {
                numReunion: this.options.numReunion,
                numCourse: this.options.numCourse,
                date: this.options.date
            });
        },

        _initListeners: function () {
            this.listenTo(this.model, 'sync', this.render);
            this.listenTo(this.model, 'error', this.renderError);
            this.listenTo(this.model.participants, 'rendered', this._updateScrollbar);
            this.listenTo(this.model.participants, 'rendererror', this._updateScrollbarError);
        },

        _createSubViews: function () {
            this.partants = new PerfListePartantsView({model: this.model});
            this.performancesPartant = new PerfPartantsView({model: this.model});

            this.subViews = [
                this.partants,
                this.performancesPartant
            ];
        },
        renderViews: function () {
            this.$el.addClass('layer-content').show();
            this.partants.render().$el.show();
            this.performancesPartant.render().$el.show();
            this._handleScrollBar();

            this.$('.message').hide();
            this.$('.perf-nav').removeClass('center');
        },
        renderError: function () {
            LayerView.prototype.renderError.call(this);
            this.$el.removeClass().show();
        },
        renderEmpty: function () {
            LayerView.prototype.renderEmpty.call(this);
            this.$el.removeClass().show();
        },
        errorEl: function () {
            this.partants.$el.hide();
            this.performancesPartant.$el.hide();

            this.$('.message').show();
            this.$('.perf-nav').addClass('center');

            return this.$('.message');
        },
        _toggleView: function (e) {
            var activeClass = 'btn-active';

            e.preventDefault();
            if ($(e.currentTarget).hasClass(activeClass)) {
                return;
            }
            this.$el.hide();

            this.model.switchModelType();
            this._toogleButtons(activeClass);
            this.model.fetch();
        },

        _toogleButtons: function (activeClass) {
            this.$('.btn').removeClass(activeClass);

            if (this.model.isPerfDetaillees()) {
                this.$('.btn:first').addClass(activeClass);
            } else {
                this.$('.btn:last').addClass(activeClass);
            }
        },

        _handleScrollBar: function () {
            if (!this.scrollbarEnabled) {
                this.$('.detail').mCustomScrollbar();
            }
            this.scrollbarEnabled = true;
        },
        _updateScrollbarError: function () {
            this._updateScrollbar();
            this.$('.detail').removeClass('dotted');
        },
        _updateScrollbar: function () {
            if (this.scrollbarEnabled) {
                this.$('.detail').mCustomScrollbar("update");
            }
            this.$('.detail').addClass('dotted');
        }
    });
});

define('src/course/liste_courses/layers/LayersButtonsView',[
    'text!./templates/layers-buttons.html',
    './rapports-probables/LayerRapportsProbablesView',
    './pronostics/LayerPronosticsView',
    './les-plus-joues/LesPlusJouesView',
    './performances/PerfView',
    'modalManager'
],
    function (tmpl, LayerRapportsProbablesView, LayerPronosticsView, LesPlusJouesView, PerfView, modalManager) {
        

        return Backbone.View.extend({
            tagName: 'ul',

            id: 'stat-button',

            events: {
                'click li': 'toggleLayers'
            },

            initialize: function () {
                this.layers = [
                    LayerPronosticsView,
                    LayerRapportsProbablesView,
                    LesPlusJouesView,
                    PerfView
                ];
                this.currentIndex = -1;

                this.render();
            },

            render: function () {
                this.$el.append(tmpl);
                this.$tabs = this.$el.children();
            },

            toggleLayers: function (e) {
                var $target = $(e.currentTarget),
                    index = this.$tabs.index($target.get(0));

                if (this.currentIndex === index) {
                    this.hideLayer(index);
                    return;
                }

                this.showLayer(index, $target);
            },

            showLayer: function (index, $target) {
                if (this.currentIndex !== -1) {
                    this.hideCurrentLayer();
                }
                this.currentIndex = index;

                this.$tabs.eq(index).addClass('stat-button-active');

                this.currentView = new this.layers[index](this.options);

                this.listenTo(this.currentView, 'close', this.hideCurrentLayer);

                modalManager.pane(
                    this.currentView,
                    $target,
                    this.currentView.getLayerTemplate('title', this.options),
                    {
                        cssClass: 'popin detail-popin ' + $target.attr('class').split(' ')[0] + '-details',
                        offset: { x: $target.outerHeight(), y: -584 + $target.parent().offset().left - $target.offset().left },
                        position: 'none',
                        category: 'layer',
                        width: 834
                    }
                );
            },

            hideLayer: function (index) {
                this.$tabs.eq(index).removeClass('stat-button-active');
                modalManager.closeCategory('layer');
                this.currentIndex = -1;
            },

            hideCurrentLayer: function () {
                this.$tabs.eq(this.currentIndex).removeClass('stat-button-active');
                this.stopListening(this.currentView);
                this.currentIndex = -1;
            },

            beforeClose: function () {
                this.layers.length = 0;
                this.currentIndex = -1;
            }
        });
    });

define('src/course/liste_courses/ReunionView',[
    'template!../templates/course-popin-full.hbs',
    'template!../../programme/reunions_infos/templates/disciplines.hbs',
    'template!./templates/liste-courses.hbs',
    './pronostic/PronosticView',
    './masses_enjeu/MassesEnjeuView',
    './liste-paris/ListeParisView',
    './rapports-definitifs/ListeRapportsDefinitifsView',
    './layers/LayersButtonsView',
    'utils',
    'links',
    'timeManager',
    'src/course/pari/pariPopin',
    '../pari/pariReportManager',
    'messages',
    'modalManager',
    'tagCommander'
], function (coursePopinFullTmpl, disciplinesTmpl, listeCourseTmpl, PronosticView, MassesEnjeuView, ListeParisView, ListeRapportsDefinitifsView, LayersButtonsView, utils, links, timeManager, pariPopin, pariReportManager, messages, modalManager, tagCommander) {

    

    return Backbone.View.extend({
        id: 'liste-courses-view',

        events: {
            'click .course:not(.current)': 'onCourseClick',
            'click .button-nav.previous.actif': 'goToPreviousReunion',
            'click .button-nav.next.actif': 'goToNextReunion',
            'click .conditions-show': 'showConditionsPopin'
        },

        initialize: function () {
            this.$el.append('<div id="liste-courses-content" class="liste-courses-line"></div>');

            this.pronosticView = new PronosticView();
            this.listeParisView = new ListeParisView();
            this.listeRapportsDefinitifsView = new ListeRapportsDefinitifsView();
            this.masseEnjeuView = new MassesEnjeuView();

            this._initListeners();
        },

        _initListeners: function () {
            this.listenTo(Backbone, 'listecourses:show', this.show);
            this.listenTo(Backbone, 'listecourses:hide', this.hide);
        },

        showConditionsPopin: function (event) {
            var $currentTarget = $(event.currentTarget),
                courseId = $('.course.current').attr('data-courseid') - 1,
                currentCourse = this.model.get('courses')[courseId];

            if (this.modal) {
                this._cleanupModal();
                return;
            }

            tagCommander.sendTagIfOnline(
                'hippique.parier.reunion.course.detail_conditions',
                {
                    bet_reunion_id: this.options.reunionid,
                    bet_course_id: this.options.courseid
                }
            );

            this.modal = modalManager.modal(
                {
                    content: currentCourse.conditions,
                    title: 'Détail des conditions',
                    $target: $currentTarget,
                    cssClass: 'popin detail-popin',
                    position: 'right',
                    width: 430,
                    category: 'layer'
                }
            );
            this.listenTo(this.modal, 'close', this._cleanupModal);
        },

        _cleanupModal: function () {
            this.stopListening(this.modal);
            this.modal.close();
            this.modal = undefined;
        },

        onCourseClick: function (event) {
            var currentTarget = $(event.currentTarget),
                courseid = currentTarget.data('courseid'),
                reunionid = currentTarget.data('reunionid'),
                date = currentTarget.attr('data-date');

            if (!pariReportManager().isEmpty()) {
                pariPopin.showConfirm(
                    {
                        confirmCallback: function () {
                            pariReportManager().set('isReport', false);
                            Backbone.history.navigate(links.get('course-node', date, reunionid, courseid), {trigger: false});
                            Backbone.trigger('course:change', date, reunionid, courseid);
                        },
                        message: messages.get('PERTE_PARI_REPORT_CONFIRMATION')
                    }
                );
            } else {
                pariReportManager().set('isReport', false);
                Backbone.history.navigate(links.get('course-node', date, reunionid, courseid), {trigger: false});
                Backbone.trigger('course:change', date, reunionid, courseid);
            }
        },

        prepareTooltipJson: function (course) {
            return _.extend({}, course, {
                momentWithOffsetUrl: timeManager.momentWithOffset(this.model.get('dateReunion'), this.model.get('timezoneOffset')).format('DDMMYYYY'),
                isAtLeastOneSpot: utils.somePariSpot(course.paris),
                isNoBetYet: utils.somePariEnVente(course.paris),
                parisFamiliesUIData: utils.serviceMapper.createUIFamiliesData(course.paris)
            });
        },

        getCourse: function (courseid) {
            var courses = this.model.get('courses');
            return _.find(courses, function (course) {
                return courseid === course.numExterne;
            });
        },

        setOptions: function (options) {
            _.extend(this.options, options);
            return this;
        },

        setCourseCommons: function (renderDisciplines) {
            this.pointerSet();
            this.$('.disciplines').append(renderDisciplines);
        },

        appendMasseEnjeuAndPronostic: function () {
            this.masseEnjeuView.setParams(this.options.date, this.options.reunionid, this.options.courseid);
            this.pronosticView.setParams(this.options.date, this.options.reunionid, this.options.courseid);
            this.pronosticView.clear();

            if (!this.options.renderFromAlerting) {//changement de course non initié par l'alerting
                this.masseEnjeuView.reFetch();
                this.pronosticView.reFetch();
            }

            this.$("#course-info-plus").append(this.masseEnjeuView.el);
            this.$("#info-detail").append(this.pronosticView.el);
        },

        appendListeParis: function () {
            this.listeParisView.setOptions(this.options.date, this.getCourse(this.options.courseid), this.getCourse(this.options.courseid).categorieStatut);
            this.$('#bets').append(this.listeParisView.render().el);
            if (this.listeParisView.pariPickerView.isTemporaryFinish(this.getCourse(this.options.courseid).statut) || this.listeParisView.pariPickerView.isUnpariable(this.getCourse(this.options.courseid).categorieStatut) || !utils.somePariEnVente((this.getCourse(this.options.courseid).paris))) {
                this.$('#bets li').removeClass('picto-pari-action').addClass('picto-pari-action.inactif');
                this.$('#bets li').removeClass('picto-pari-spot').addClass('picto-pari-spot.inactif');
            }
        },

        appendRapportsDefinitifs: function () {
            this.listeRapportsDefinitifsView.setCourse(this.options.date, this.getCourse(this.options.courseid));
            this.$('#bets').append(this.listeRapportsDefinitifsView.render().el);
        },

        render: function () {
            // On doit pouvoir appeler `render` même quand le serveur n'a pas répondu
            // @see LayoutView#render
            if (_.isEmpty(this.model.attributes)) {
                return this;
            }

            var renderDisciplines,
                categorieStatut = this.getCourse(this.options.courseid).categorieStatut,
                statut = this.getCourse(this.options.courseid).statut;

            renderDisciplines = disciplinesTmpl({
                disciplinesMere: this.model.get("disciplinesMere")
            });

            this.$('#liste-courses-content').html(listeCourseTmpl(this.prepareJson()));

            switch (categorieStatut) {
            case 'ANNULEE':
                this.appendListeParis();
                break;

            case 'ARRIVEE':
                this.appendMasseEnjeuAndPronostic();
                if (statut === 'ARRIVEE_PROVISOIRE_NON_VALIDEE' || statut === 'ARRIVEE_PROVISOIRE') {
                    this.appendListeParis();
                } else {
                    this.appendRapportsDefinitifs();
                }

                break;

            default:
                this.appendMasseEnjeuAndPronostic();
                this.appendListeParis();
                break;
            }

            this.$('#course-info-plus').prepend(
                new LayersButtonsView({
                    numReunion: this.options.reunionid,
                    numCourse: this.options.courseid,
                    date: this.options.date
                }).el
            );

            this.setCourseCommons(renderDisciplines);

            this.$('.course:not(.current)').each(_.bind(this._createTooltip, this));

            return this;
        },

        _createTooltip: function (index, item) {
            var $course = $(item),
                courseid = $course.data('courseid'),
                course = this.getCourse(courseid);

            if (course.categorieStatut !== 'A_PARTIR') {
                return;
            }

            modalManager.tooltip(
                coursePopinFullTmpl(this.prepareTooltipJson(course)),
                $course,
                {
                    cssClass: 'popin infocourse',
                    maxWidth: 242
                }
            );
        },

        prepareJson: function () {
            var numCourseEvenement = this.model.get('courseEvenement').numCourse,
                courseEvenement,
                reunion = this.model.attributes,
                course = _.findWhere(reunion.courses, {numExterne: this.options.courseid}),
                paris = this.getCourse(this.options.courseid).paris;

            courseEvenement = _.findWhere(reunion.courses, {numExterne: numCourseEvenement}) || {};
            courseEvenement.evenement = utils.serviceMapper.getPariEvenement(courseEvenement.paris);

            this.debug('Statut reunion: ' + reunion.statut);
            return {
                reunion: reunion,
                parisFamiliesUIData: utils.serviceMapper.createUIFamiliesData(paris),
                date: this.options.date,
                course: course
            };
        },

        pointerSet: function () {
            //positionnement pointer
            var pointer = this.$('span.pointer'),
                course = this.$('li.current'),
                pos;

            pos = course.offset();
            pos.top += course.outerHeight(false) - 2;
            pos.left -= (pointer.width() / 2) - (course.outerWidth(true) / 2);
            pos.left -= course.css('marginLeft').replace('px', '');

            pointer.offset(pos);
        },

        goToNextReunion: function () {
            this.goToReunion(this.model.get('numOfficielReunionSuivante'));
        },

        goToPreviousReunion: function () {
            this.goToReunion(this.model.get('numOfficielReunionPrecedente'));
        },

        goToReunion: function (reunionid) {
            var self = this;

            if (!reunionid) {
                return;
            }

            function _goToReunion() {
                pariReportManager().set('isReport', false);
                var date = timeManager.momentWithOffset(self.model.get('dateReunion'), self.model.get('timezoneOffset')).format(timeManager.ft.DAY_MONTH_YEAR);

                Backbone.history.navigate(links.get('reunion', date, reunionid), {trigger: false});
                Backbone.trigger('course:change', date, reunionid);
            }

            if (pariReportManager().isEmpty()) {
                return _goToReunion();
            }

            return pariPopin.showConfirm({
                confirmCallback: _goToReunion,
                message: messages.get('PERTE_PARI_REPORT_CONFIRMATION')
            });
        },


        beforeClose: function () {
            this.masseEnjeuView.close();
            this.pronosticView.close();
            this.listeParisView.close();
            this.listeRapportsDefinitifsView.close();
        }
    });
});

define('text!src/course/infos_arrivee/templates/infos-arrivee.hbs',[],function () { return '<div class="infos-arrivee-content clearfix">\n    <div class="infos-arrivee-photo{{#if photosArrivee}} infos-arrivee-photo-disponible{{/if}}">\n        {{#if photosArrivee}}\n            {{#each photosArrivee}}\n                {{#is widthSize 450}}\n                    <img src="{{url}}" alt="" width="{{widthSize}}" height="{{heightSize}}"/>\n                {{/is}}\n            {{/each}}\n        {{else}}\n            <p>Photo de l\'arrivée en attente.</p>\n        {{/if}}\n    </div>\n    <dl class="infos-arrivee-details">\n        <dt class="infos-arrivee-list">\n            Arrivée\n            {{#if arriveeDefinitive}}\n            définitive\n            {{else}}\n            provisoire\n            {{/if}}\n        </dt>\n        {{#if ordreArrivee}}\n        <dd class="infos-arrivee-list">{{getCourseListeChevaux ordreArrivee }}</dd>\n        {{else}}\n        <dd class="infos-arrivee-list">En attente</dd>\n        {{/if}}\n        {{#if dureeCourse}}\n        <dt>Temps de la course :&nbsp;</dt>\n        <dd>{{ getCourseDuree dureeCourse }}</dd>\n        {{/if}}\n        {{#each incidents}}\n            <dt>{{#if type}}{{getMessage \'INCIDENT.\' type defaultKey=\'INCIDENT.INCONNU\' }}{{/if}} :&nbsp;</dt>\n            <dd>{{getCourseListeChevaux numeroParticipants }}</dd>\n        {{/each}}\n    </dl>\n    {{#if commentaireApresCourse}}\n    <p class="infos-arrivee-commentaire">\n        {{#if commentaireApresCourse.texte}}{{ commentaireApresCourse.texte }}{{/if}}\n    </p>\n    {{/if}}\n</div>\n';});

define('src/course/infos_arrivee/InfosArriveeView',[
    'template!./templates/infos-arrivee.hbs'
], function (template) {
    

    return Backbone.View.extend({

        id: 'infos-arrivee',

        selfRender : true,

        defaults: function () {
            return {
                statut                 : null,
                categorieStatut        : null,
                dureeCourse            : null,
                ordreArrivee           : [],
                incidents              : [],
                commentaireApresCourse : null,
                urlPhoto               : null,
                arriveeDefinitive      : false
            };
        },

        setOptions: function (options) {
            _.extend(this.options, options);
            this.course = this.model.getCourseById(this.options.courseid);
            return this;
        },

        render: function () {
            this.$el.empty();

            if (_.isEmpty(this.course) || this.course.categorieStatut !== 'ARRIVEE') {
                return this;
            }

            this.$el.html(template(
                _.extend({}, this.defaults(), this.course)
            ));

            return this;
        }
    });
});

define('src/course/participants/ParticipantsWrapperModel',['defaults'], function (defaults) {
    

    return Backbone.Model.extend({

        url: function () {
            return defaults.PARTICIPANTS_URL
                .replace('{date}', this.date)
                .replace('{numReunion}', this.reunionid)
                .replace('{numCourse}', this.courseid);
        },

        args: function (date, reunionid, courseid) {
            this.date = date;
            this.reunionid = reunionid;
            this.courseid = courseid;
        },

        parse: function (json) {
            var spriteCasaque = _.findWhere(json.spriteCasaques, {heightSize: 19});

            if (spriteCasaque) {
                _.each(json.participants, function (participant) {
                    participant.urlCasaque = spriteCasaque.url;
                });
            }

            // TODO modifier le service pour qu'il renvoie un tableau d'écuries vide
            if (!json.ecuries) {
                json.ecuries = [];
            }

            return json;
        }

    });
});

define('src/course/participants/EcurieModel',[],function () {
    

    return Backbone.Model.extend({

        idAttribute: 'nom',

        defaults: {
            coteRef: null,
            cote: null
        },

        parseRapports: function () {
            var rapportRef = this.get('dernierRapportReference'),
                rapportDirect = this.get('dernierRapportDirect');

            if (rapportRef && rapportRef.rapport !== undefined && rapportRef.rapport !== 0) {
                this.set('coteRef', rapportRef.rapport);
            }
            if (rapportDirect && rapportDirect.rapport !== undefined && rapportDirect.rapport !== 0) {
                this.set('cote', rapportDirect.rapport);
            }
        }

    });
});

define('src/course/participants/EcurieCollection',[
    './EcurieModel',
    'src/common/SortableCollection'
], function (EcurieModel, SortableCollection) {
    

    return SortableCollection.extend({

        model: EcurieModel,

        initialize: function () {
            this.setComparator('nom'); // Propriété par laquelle la collection est triée initialement.
        }

    });
});

define('text!src/course/participants/templates/partants/plat-list.hbs',[],function () { return '<h2>Tableau des <b>partants</b></h2>\n<span class="aide"></span>\n<table>\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2" title="Casaque">Cas.</th>\n        <th rowspan="2" title="Oeillère">Oeil</th>\n        <th rowspan="2"><span title="Sexe">S</span></th>\n        <th rowspan="2"><span title="Age">A</span></th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th rowspan="2" class="txtC">Corde</th>\n        <th colspan="2" class="poids">Poids (kg)</th>\n        <th rowspan="2" style="width: 70px;">Entraineur</th>\n        <th rowspan="2" style="width: 80px;" class="musique">Musique</th>\n        <th colspan="2" class="rapports">Rapports&nbsp;probables&nbsp;SG</th>\n        {{#isSiteOnline}}\n        <th rowspan="2" class="column-separator optional"></th>\n        <th class="advanced-mode-b optional" data-type="base" rowspan="2" style="width:27px">B.</th>\n        <th class="advanced-mode-a optional" data-type="associate" rowspan="2" style="width:27px">A.</th>\n        <th class="formule-simplifiee optional" data-type="simplifiee" rowspan="2" style="width:52px">Sélect.</th>\n        {{/isSiteOnline}}\n    </tr>\n    <tr>\n        <th class="info-poids" title="Poids handicapeur">Hand.</th>\n        <th class="info-poids" title="Poids de monte">Monte</th>\n        <th class="txtC rapport-probable optional" style="width: 75px;">Ref.</th>\n        <th class="txtC rapport-probable last" style="width: 75px;">Direct</th>\n    </tr>\n\n    <tr class="tri">\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="oeilleres triable">\n            <div></div>\n        </td>\n        <td class="sexe triable">\n            <div></div>\n        </td>\n        <td class="age triable">\n            <div></div>\n        </td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td class="placeCorde triable">\n            <div></div>\n        </td>\n        <td class="handicapPoids triable">\n            <div></div>\n        </td>\n        <td class="poidsConditionMonte triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="musique"></td>\n        <td class="coteRef triable optional">\n            <div></div>\n        </td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        {{#isSiteOnline}}\n        <td class="column-separator optional"></td>\n        <td class="mode-b optional"></td>\n        <td class="advanced-mode-a optional"></td>\n        {{/isSiteOnline}}\n    </tr>\n    </thead>\n    <tbody></tbody>\n\n    <tfoot></tfoot>\n</table>\n';});

define('text!src/course/participants/templates/partants/obstacle-list.hbs',[],function () { return '<h2>Tableau des <b>partants</b></h2>\n<span class="aide"> </span>\n<table>\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2" title="Casaque">Cas.</th>\n        <th rowspan="2" title="Oeillère">Oeil</th>\n        <th rowspan="2"><span title="Sexe">S</span></th>\n        <th rowspan="2"><span title="Age">A</span></th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th colspan="2" class="poids">Poids (kg)</th>\n        <th rowspan="2" style="width: 70px;">Entraîneur</th>\n        <th rowspan="2" style="width: 80px;" class="musique">Musique</th>\n        <th colspan="2" class="rapports">Rapports&nbsp;probables&nbsp;SG</th>\n        {{#isSiteOnline}}\n        <th rowspan="2" class="column-separator optional"> </th>\n        <th class="advanced-mode-b optional" data-type="base" rowspan="2" style="width:27px">B.</th>\n        <th class="advanced-mode-a optional" data-type="associate" rowspan="2" style="width:27px">A.</th>\n        <th class="formule-simplifiee optional" data-type="simplifiee" rowspan="2" style="width:52px">Sélect.</th>\n        {{/isSiteOnline}}\n    </tr>\n    <tr>\n        <th class="info-poids" title="Poids handicapeur">Hand.</th>\n        <th class="info-poids" title="Poids de monte">Monte</th>\n        <th class="txtC rapport-probable optional" style="width: 75px;">Ref.</th>\n        <th class="txtC rapport-probable last" style="width: 75px;">Direct</th>\n    </tr>\n\n    <tr class="tri">\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="oeilleres triable">\n            <div></div>\n        </td>\n        <td class="sexe triable">\n            <div></div>\n        </td>\n        <td class="age triable">\n            <div></div>\n        </td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td class="handicapPoids triable">\n            <div></div>\n        </td>\n        <td class="poidsConditionMonte triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="musique"> </td>\n        <td class="coteRef triable optional">\n            <div></div>\n        </td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        {{#isSiteOnline}}\n        <td class="column-separator optional"> </td>\n        <td class="mode-b optional"> </td>\n        <td class="advanced-mode-a optional"> </td>\n        {{/isSiteOnline}}\n    </tr>\n    </thead>\n    <tbody> </tbody>\n    <tfoot> </tfoot>\n</table>\n';});

define('text!src/course/participants/templates/partants/trot-attele-list.hbs',[],function () { return '<h2>Tableau des <b>partants</b></h2>\n<span class="aide"> </span>\n<table>\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2" title="Casaque">Cas.</th>\n        <th rowspan="2" title="Intention de déferrer">Fer</th>\n        <th rowspan="2"><span title="Sexe">S</span></th>\n        <th rowspan="2"><span title="Age">A</span></th>\n        <th rowspan="2" style="width: 70px;">Driver</th>\n        <th rowspan="2" style="width: 70px;">Entraîneur</th>\n        <th rowspan="2" style="width: 35px;">Dist (mètres)</th>\n        <th rowspan="2" style="width: 75px;" class="musique">Musique</th>\n        <th rowspan="2" style="width: 54px;">Gains</th>\n        <th colspan="2" class="rapports">Rapports&nbsp;probables&nbsp;SG</th>\n        {{#isSiteOnline}}\n        <th rowspan="2" class="column-separator optional"> </th>\n        <th class="advanced-mode-b optional" data-type="base" rowspan="2" style="width:27px">B.</th>\n        <th class="advanced-mode-a optional" data-type="associate" rowspan="2" style="width:27px">A.</th>\n        <th class="formule-simplifiee optional" data-type="simplifiee" rowspan="2" style="width:52px">Sélect.</th>\n        {{/isSiteOnline}}\n    </tr>\n    <tr>\n        <th class="txtC rapport-probable optional" style="width: 75px;">Ref.</th>\n        <th class="txtC rapport-probable last" style="width: 75px;">Direct</th>\n    </tr>\n\n    <tr class="tri">\n        <td class="numPmu triable">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="deferre triable">\n            <div></div>\n        </td>\n        <td class="sexe triable">\n            <div></div>\n        </td>\n        <td class="age triable">\n            <div></div>\n        </td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="handicapDistance triable">\n            <div></div>\n        </td>\n        <td class="musique"> </td>\n        <td class="gainsParticipant_gainsCarriere triable">\n            <div></div>\n        </td>\n        <td class="coteRef triable optional">\n            <div></div>\n        </td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        {{#isSiteOnline}}\n            <td class="column-separator optional"> </td>\n            <td class="mode-b optional"> </td>\n            <td class="advanced-mode-a optional"> </td>\n        {{/isSiteOnline}}\n    </tr>\n    </thead>\n    <tbody> </tbody>\n    <tfoot> </tfoot>\n</table>\n';});

define('text!src/course/participants/templates/partants/trot-monte-list.hbs',[],function () { return '<h2>Tableau des <b>partants</b></h2>\n<span class="aide"></span>\n<table>\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2" title="Casaque">Cas</th>\n        <th rowspan="2" title="Intention de déferrer">Fer</th>\n        <th rowspan="2"><span title="Sexe">S</span></th>\n        <th rowspan="2"><span title="Age">A</span></th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th rowspan="2" title="Poids handicapeur">Poids (kg)</th>\n        <th rowspan="2" style="width: 70px;">Entraîneur</th>\n        <th rowspan="2" style="width: 35px;">Dist (mètres)</th>\n        <th rowspan="2" style="width: 75px;" class="musique">Musique</th>\n        <th rowspan="2">Gains</th>\n        <th colspan="2" class="rapports">Rapports&nbsp;probables&nbsp;SG</th>\n        {{#isSiteOnline}}\n        <th rowspan="2" class="column-separator optional"></th>\n        <th class="advanced-mode-b optional" data-type="base" rowspan="2" style="width:27px">B.</th>\n        <th class="advanced-mode-a optional" data-type="associate" rowspan="2" style="width:27px">A.</th>\n        <th class="formule-simplifiee optional" data-type="simplifiee" rowspan="2" style="width:52px">Sélect.</th>\n        {{/isSiteOnline}}\n    </tr>\n    <tr>\n        <th class="txtC rapport-probable optional" style="width: 75px;">Ref.</th>\n        <th class="txtC rapport-probable last" style="width: 75px;">Direct</th>\n    </tr>\n\n    <tr class="tri">\n        <td class="numPmu triable ">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="deferre triable">\n            <div></div>\n        </td>\n        <td class="sexe triable">\n            <div></div>\n        </td>\n        <td class="age triable">\n            <div></div>\n        </td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td class="handicapPoids triable">\n            <div></div>\n        </td>\n        <td> </td>\n        <td class="handicapDistance triable">\n            <div></div>\n        </td>\n        <td class="musique"> </td>\n        <td class="gainsParticipant_gainsCarriere triable">\n            <div></div>\n        </td>\n        <td class="coteRef triable optional">\n            <div></div>\n        </td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        {{#isSiteOnline}}\n         <td class="column-separator optional"> </td>\n         <td class="mode-b optional"> </td>\n         <td class="advanced-mode-a optional"> </td>\n        {{/isSiteOnline}}\n    </tr>\n    </thead>\n    <tbody> </tbody>\n    <tfoot> </tfoot>\n</table>\n';});

define('text!src/course/participants/templates/arrivee/plat-list.html',[],function () { return '<h2>Détail de l\'<strong>arrivée</strong></h2>\n<table class="tableau-chevaux arrivee">\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">Place</th>\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2">Cas.</th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th rowspan="2" title="Ecart par rapport au cheval précédent">Ecart prèc.</th>\n        <th class="rapports">Rapports</th>\n        <th rowspan="2" class="commentaire">Commentaires d\'après-course</th>\n    </tr>\n    <tr>\n        <th class="rapport-probable" style="width: 75px;"></th>\n    </tr>\n\n    <tr class="tri">\n        <td class="ordreArrivee triable">\n            <div></div>\n        </td>\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        <td class="commentaire"></td>\n    </tr>\n    </thead>\n    <tbody>\n\n    </tbody>\n    <tfoot></tfoot>\n</table>\n';});

define('text!src/course/participants/templates/arrivee/obstacle-list.html',[],function () { return '<h2>Détail de l\'<strong>arrivée</strong></h2>\n<table class="tableau-chevaux arrivee">\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">Place</th>\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2">Cas.</th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th rowspan="2" title="Ecart par rapport au cheval précédent">Ecart prèc.</th>\n        <th class="rapports">Rapports</th>\n        <th rowspan="2" class="commentaire">Commentaires d\'après-course</th>\n    </tr>\n    <tr>\n        <th class="rapport-probable" style="width: 75px;"></th>\n    </tr>\n\n    <tr class="tri">\n        <td class="ordreArrivee triable">\n            <div></div>\n        </td>\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        <td class="commentaire"></td>\n    </tr>\n    </thead>\n    <tbody>\n\n    </tbody>\n    <tfoot></tfoot>\n</table>\n';});

define('text!src/course/participants/templates/arrivee/trot-attele-list.html',[],function () { return '<h2>Détail de l\'<strong>arrivée</strong></h2>\n<table class="tableau-chevaux arrivee">\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">Place</th>\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2">Cas.</th>\n        <th rowspan="2" style="width: 70px;">Driver</th>\n        <th rowspan="2" title="Réduction kilométrique">Red. Kim</th>\n        <th class="rapports">Rapports</th>\n        <th rowspan="2" class="commentaire">Commentaires d\'après-course</th>\n    </tr>\n    <tr>\n        <th class="rapport-probable" style="width: 75px;"></th>\n    </tr>\n\n    <tr class="tri">\n        <td class="ordreArrivee triable">\n            <div></div>\n        </td>\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        <td class="commentaire"></td>\n    </tr>\n    </thead>\n    <tbody>\n\n    </tbody>\n    <tfoot></tfoot>\n</table>\n';});

define('text!src/course/participants/templates/arrivee/trot-monte-list.html',[],function () { return '<h2>Détail de l\'<strong>arrivée</strong></h2>\n<table class="tableau-chevaux arrivee">\n    <thead class="partant">\n    <tr class="participant-header">\n        <th rowspan="2" class="numero">Place</th>\n        <th rowspan="2" class="numero">N°</th>\n        <th rowspan="2" style="width: 122px;">Nom</th>\n        <th rowspan="2">Cas.</th>\n        <th rowspan="2" style="width: 70px;">Jockey</th>\n        <th rowspan="2" title="Réduction kilométrique">Red. Kim</th>\n        <th class="rapports">Rapports</th>\n        <th rowspan="2" class="commentaire">Commentaires d\'après-course</th>\n    </tr>\n    <tr>\n        <th class="rapport-probable" style="width: 75px;"></th>\n    </tr>\n\n    <tr class="tri">\n        <td class="ordreArrivee triable">\n            <div></div>\n        </td>\n        <td class="numPmu triable desc">\n            <div></div>\n        </td>\n        <td class="nom triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="driver triable">\n            <div></div>\n        </td>\n        <td></td>\n        <td class="cote triable">\n            <div></div>\n        </td>\n        <td class="commentaire"></td>\n    </tr>\n    </thead>\n    <tbody>\n\n    </tbody>\n    <tfoot></tfoot>\n</table>\n';});

define('text!src/course/participants/templates/legende-partants.hbs',[],function () { return '<ul class="legende-partants">\n{{#each data}}\n    <li><b class="{{cssClass}}"> </b><span>{{label}}</span></li>\n{{/each}}\n</ul>';});

define('text!src/course/participants/templates/ecurie-item.hbs',[],function () { return '<tr class="ligne-participant">\n    <td></td>\n    <td><strong>Ecurie {{ ecurie.nom }}</strong></td>\n    {{#if isPlatOrTrot}}\n        <td colspan="10"> </td>\n    {{ else }}\n        <td colspan="9"> </td>\n    {{/if}}\n    <td class="txtC rapport-probable optional">{{ formatReal ecurie.coteRef }}</td>\n    <td class="txtC rapport-probable last">{{ formatReal ecurie.cote }}</td>\n    {{#isSiteOnline}}\n    <td class="column-separator optional"></td>\n    <td class="optional"></td>\n    <td class="advanced-mode-a optional"></td>\n    {{/isSiteOnline}}\n</tr>\n';});

define('text!src/course/participants/templates/musique-popin.html',[],function () { return '<div class="musique-popin">\n    <h4>Musique :</h4>\n\n    <p>\n        C’est le résumé des classements obtenus par un cheval lors de ses dernières compétitions, en commençant par la plus\n        récente. <br>\n        Pour davantage d’informations sur le sujet, ouvrez le <a href="{{aideMusique}}" target="_blank">lien suivant</a>\n    </p>\n</div>';});

define('text!src/course/participants/templates/partants/plat-item.hbs',[],function () { return '<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}">{{#if p.engagement}}[suppl]{{/if}} </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC">\n    <div title="{{p.proprietaire}}" class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC"><b class="{{p.oeilleres}}"> </b></td>\n<td class="txtC">{{charAt p.sexe 0}}</td>\n<td class="txtC">{{p.age}}</td>\n<td>\n    <span title="{{p.driver}}">{{#if p.driver}}{{formatForCell p.driver 13}}{{/if}}</span>\n</td>\n<td class="txtC">{{p.placeCorde}}</td>\n<td class="txtC">{{chevalPoids p.handicapPoids}}</td>\n<td class="txtC">{{chevalPoids p.poidsConditionMonte}}</td>\n<td><span title="{{p.entraineur}}">{{#if p.entraineur}}{{formatForCell p.entraineur 13}}{{/if}}</span></td>\n<td><span title="{{p.musique}}">{{#if p.musique}}{{truncate p.musique 12}}{{/if}}</span></td>\n<td class="txtC rapport-probable optional">{{formatReal p.coteRef}}</td>\n<td class="txtC rapport-probable last">{{formatReal p.cote}}</td>\n{{#isSiteOnline}}\n<td class="column-separator optional"></td>\n<td class="txtC mode-b optional">\n    <div id="participant-base-{{p.numPmu}}" class="participant-selector">\n        <b data-type="base" class="participant-check base{{#if p.baseSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n<td class="txtC advanced-mode-a optional">\n    <div id="participant-associate-{{p.numPmu}}" class="participant-selector">\n        <b data-type="associate" class="participant-check associate{{#if p.associateSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n{{/isSiteOnline}}\n';});

define('text!src/course/participants/templates/partants/obstacle-item.hbs',[],function () { return '<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}">{{#if p.engagement}}[suppl]{{/if}} </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC">\n    <div title="{{p.proprietaire}}" class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC"><b class="{{p.oeilleres}}"> </b></td>\n<td class="txtC">{{charAt p.sexe 0}}</td>\n<td class="txtC">{{p.age}}</td>\n<td>\n    <span title="{{p.driver}}">{{#if p.driver}}{{formatForCell p.driver 13}}{{/if}}</span>\n</td>\n<td class="txtC">{{chevalPoids p.handicapPoids}}</td>\n<td class="txtC">{{chevalPoids p.poidsConditionMonte}}</td>\n<td><span title="{{p.entraineur}}">{{#if p.entraineur}}{{formatForCell p.entraineur 13}}{{/if}}</span></td>\n<td><span title="{{p.musique}}">{{#if p.musique}}{{truncate p.musique 12}}{{/if}}</span></td>\n<td class="txtC rapport-probable optional">{{formatReal p.coteRef}}</td>\n<td class="txtC rapport-probable last">{{formatReal p.cote}}</td>\n{{#isSiteOnline}}\n<td class="column-separator optional"></td>\n<td class="txtC mode-b optional">\n    <div id="participant-base-{{p.numPmu}}" class="participant-selector">\n        <b data-type="base" class="participant-check base{{#if p.baseSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n<td class="txtC advanced-mode-a optional">\n    <div id="participant-associate-{{p.numPmu}}" class="participant-selector">\n        <b data-type="associate" class="participant-check associate{{#if p.associateSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n{{/isSiteOnline}}\n';});

define('text!src/course/participants/templates/partants/trot-attele-item.hbs',[],function () { return '<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC">\n    <div title="{{p.proprietaire}}" class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td><b class="{{p.deferre}}"> </b></td>\n<td class="txtC">{{charAt p.sexe 0}}</td>\n<td class="txtC">{{p.age}}</td>\n<td>\n    <span title="{{p.driver}}">{{#if p.driver}}{{formatForCell p.driver 13}}{{/if}}</span>\n</td>\n<td><span title="{{p.entraineur}}">{{#if p.entraineur}}{{formatForCell p.entraineur 13}}{{/if}}</span></td>\n<td class="txtC">{{#if p.handicapDistance}}{{p.handicapDistance}}{{/if}}</td>\n<td><span title="{{p.musique}}">{{#if p.musique}}{{truncate p.musique 10}}{{/if}}</span></td>\n<td class="gains">{{formatMoney p.gainsParticipant.gainsCarriere}}</td>\n<td class="txtC rapport-probable optional">{{formatReal p.coteRef}}</td>\n<td class="txtC rapport-probable last">{{formatReal p.cote}}</td>\n{{#isSiteOnline}}\n<td class="column-separator optional"></td>\n<td class="txtC mode-b optional">\n    <div id="participant-base-{{p.numPmu}}" class="participant-selector">\n        <b data-type="base" class="participant-check base{{#if p.baseSelected}} checked{{/if}}"> </b>\n    </div>\n    </div>\n</td>\n<td class="txtC advanced-mode-a optional">\n    <div id="participant-associate-{{p.numPmu}}" class="participant-selector">\n        <b data-type="associate" class="participant-check associate{{#if p.associateSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n{{/isSiteOnline}}\n';});

define('text!src/course/participants/templates/partants/trot-monte-item.hbs',[],function () { return '<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n<td class="txtC">\n    <div title="{{p.proprietaire}}" class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td><b class="{{p.deferre}}"> </b></td>\n<td class="txtC">{{charAt p.sexe 0}}</td>\n<td class="txtC">{{p.age}}</td>\n<td>\n    <span title="{{p.driver}}">{{#if p.driver}}{{formatForCell p.driver 13}}{{/if}}</span>\n</td>\n<td class="txtC">{{chevalPoids p.handicapPoids}}</td>\n<td><span title="{{p.entraineur}}">{{#if p.entraineur}}{{formatForCell p.entraineur 13}}{{/if}}</span></td>\n<td class="txtC">{{#if p.handicapDistance}}{{p.handicapDistance}}{{/if}}</td>\n<td><span title="{{p.musique}}">{{#if p.musique}}{{truncate p.musique 10}}{{/if}}</span></td>\n<td class="gains">{{formatMoney p.gainsParticipant.gainsCarriere}}</td>\n<td class="txtC rapport-probable optional">{{formatReal p.coteRef}}</td>\n<td class="txtC rapport-probable last">{{formatReal p.cote}}</td>\n{{#isSiteOnline}}\n<td class="column-separator optional"></td>\n<td class="txtC mode-b optional">\n    <div id="participant-base-{{p.numPmu}}" class="participant-selector">\n        <b data-type="base" class="participant-check base{{#if p.baseSelected}} checked{{/if}}"> </b>\n    </div>\n    </div>\n</td>\n<td class="txtC advanced-mode-a optional">\n    <div id="participant-associate-{{p.numPmu}}" class="participant-selector">\n        <b data-type="associate" class="participant-check associate{{#if p.associateSelected}} checked{{/if}}"> </b>\n    </div>\n</td>\n{{/isSiteOnline}}\n';});

define('text!src/course/participants/templates/partants/non-partant-item.hbs',[],function () { return '<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        <strong>{{formatForCell p.nom 20}}</strong>\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n    </span>\n</td>\n<td class="txtC" colspan="{{p.colspan}}"></td>\n<td class="txtC libelle-non-partant" colspan="2">NON PARTANT</td>\n{{#isSiteOnline}}\n<td class="column-separator optional"> </td>\n<td class="txtC optional">\n    <div id="participant-base-{{p.numPmu}}" class="participant-selector">\n        {{#if p.baseSelected}}\n        <b data-type="base" class="participant-check base checked"> </b>\n        {{/if}}\n    </div>\n</td>\n<td class="txtC advanced-mode-a optional">\n    <div id="participant-associate-{{p.numPmu}}" class="participant-selector">\n        {{#if p.associateSelected}}\n        <b data-type="associate" class="participant-check associate checked"> </b>\n        {{/if}}\n    </div>\n</td>\n{{/isSiteOnline}}\n';});

define('text!src/course/participants/templates/arrivee/plat-item.hbs',[],function () { return '<td class="txtC small-col">\n    {{#if p.arriveeDefinitiveComplete}}\n        {{#if p.incident}}\n            {{getMessage \'INCIDENT.COURT.\' p.incident}}\n        {{else}}\n            {{ordinal p.ordreArrivee false}}\n        {{/if}}\n    {{/if}}\n</td>\n<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC small-col">\n    <div class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC">\n    <span title="{{p.driver}}">{{formatForCell p.driver 13}}</span>\n</td>\n<td class="center">\n    {{#if p.distanceChevalPrecedent.identifiant}}\n        {{getMessage \'DISTANCE.LONG.\' p.distanceChevalPrecedent.identifiant defaultKey=p.distanceChevalPrecedent.identifiant}}\n    {{/if}}</td>\n<td class="txtC rapport-probable">{{formatReal p.cote}}</td>\n<td class="commentaire">{{formatCommentaireHippique p.commentaireApresCourse}}</td>\n';});

define('text!src/course/participants/templates/arrivee/obstacle-item.hbs',[],function () { return '<td class="txtC small-col">\n    {{#if p.arriveeDefinitiveComplete}}\n        {{#if p.incident}}\n            {{getMessage \'INCIDENT.COURT.\' p.incident}}\n        {{else}}\n            {{ordinal p.ordreArrivee false}}\n        {{/if}}\n    {{/if}}\n</td>\n<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC small-col">\n    <div class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC">\n    <span title="{{p.driver}}">{{formatForCell p.driver 13}}</span>\n</td>\n<td class="center">\n    {{#if p.distanceChevalPrecedent.identifiant}}\n        {{getMessage \'DISTANCE.LONG.\' p.distanceChevalPrecedent.identifiant defaultKey=p.distanceChevalPrecedent.identifiant}}\n    {{/if}}\n</td>\n<td class="txtC rapport-probable">{{formatReal p.cote}}</td>\n<td class="commentaire">{{formatCommentaireHippique p.commentaireApresCourse}}</td>\n';});

define('text!src/course/participants/templates/arrivee/trot-attele-item.hbs',[],function () { return '<td class="txtC small-col">\n    {{#if p.arriveeDefinitiveComplete}}\n        {{#if p.incident}}\n            {{getMessage \'INCIDENT.COURT.\' p.incident}}\n        {{else}}\n            {{ordinal p.ordreArrivee false}}\n        {{/if}}\n    {{/if}}\n</td>\n<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC small-col">\n    <div class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC">\n    <span title="{{p.driver}}">{{formatForCell p.driver 13}}</span>\n</td>\n<td class="center">{{getCourseDuree p.reductionKilometrique}}</td>\n<td class="txtC rapport-probable">{{formatReal p.cote}}</td>\n<td class="commentaire">{{formatCommentaireHippique p.commentaireApresCourse}}</td>\n';});

define('text!src/course/participants/templates/arrivee/trot-monte-item.hbs',[],function () { return '<td class="txtC small-col">\n    {{#if p.arriveeDefinitiveComplete}}\n        {{#if p.incident}}\n            {{getMessage \'INCIDENT.COURT.\' p.incident}}\n        {{else}}\n            {{ordinal p.ordreArrivee false}}\n        {{/if}}\n    {{/if}}\n</td>\n<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        {{formatForCell p.nom 20}}\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n        <b class="{{#if p.jumentPleine}}icoJumentPleine{{/if}}"> </b>\n        {{#if p.ecurie}}{{p.ecurie}}{{/if}}\n    </span>\n</td>\n<td class="txtC small-col">\n    <div class="picto-casaque" style="{{pictoCasaqueStyle p.urlCasaque p.numPmu}}"></div>\n</td>\n<td class="txtC">\n    <span title="{{p.driver}}">{{formatForCell p.driver 13}}</span>\n</td>\n<td class="center">{{getCourseDuree p.reductionKilometrique}}</td>\n<td class="txtC rapport-probable">{{formatReal p.cote}}</td>\n<td class="commentaire">{{formatCommentaireHippique p.commentaireApresCourse}}</td>\n';});

define('text!src/course/participants/templates/arrivee/non-partant-item.hbs',[],function () { return '<td class="txtC"></td>\n<td class="txtC"><strong>{{p.numPmu}}</strong></td>\n<td>\n    <span class="name unit" title="{{p.nom}}">\n        <strong>{{formatForCell p.nom 20}}</strong>\n    </span>\n    <span class="unitRight paddingRight5">\n        <b class="{{#if p.engagement}}icoSuppl{{/if}}"> </b>\n    </span>\n</td>\n<td class="txtC" colspan="{{p.colspan}}"></td>\n<td class="txtC libelle-non-partant" colspan="2">NON PARTANT</td>\n';});

define('text!src/course/participants/templates/partants/fiche-cheval.hbs',[],function () { return '\n<h3>{{race}}, {{sexe}}, {{age}} ANS, {{robe.libelleLong}}</h3>\n <div class="cheval-courses-gain fiche-cheval-separator">\n     <div class="fiche-cheval-courses">\n        <h5>Courses :</h5>\n        <ul>\n           <li><span>Courues</span><b>{{nombreCourses}}</b></li>\n           <li><span>Victoires</span><b>{{nombreVictoires}}</b></li>\n           <li><span>Places</span><b>{{nombrePlaces}}</b></li>\n        </ul>\n     </div>\n     <div class="fiche-cheval-gains">\n        <h5>Gains :</h5>\n        <ul>\n            <li><span>En carrière</span><b> {{#if gainsParticipant.gainsCarriere}}{{formatMoney gainsParticipant.gainsCarriere}}{{else}}- €{{/if}}</b></li>\n            <li><span>Année Précédente</span><b> {{#if gainsParticipant.gainsAnneePrecedente}}{{formatMoney gainsParticipant.gainsAnneePrecedente}}{{else}}- €{{/if}}</b></li>\n            <li><span>En Victoires </span><b> {{#if gainsParticipant.gainsVictoires}}{{formatMoney gainsParticipant.gainsVictoires}}{{else}}- €{{/if}}</b></li>\n            <li><span>Année en cours </span><b> {{#if gainsParticipant.gainsAnneeEnCours}}{{formatMoney gainsParticipant.gainsAnneeEnCours}}{{else}}- €{{/if}}</b></li>\n        </ul>\n     </div>\n</div>\n<div class="cheval-entraineur-ascendance">\n     <div class="fiche-cheval-entraineur">\n        <h5>Entraîneur : </h5>\n        <b>{{#if entraineur}}{{entraineur}}{{else}}- {{/if}}</b>\n        <h5>Propriétaire : </h5>\n        <b>{{#if proprietaire}}{{proprietaire}}{{else}}- {{/if}}</b>\n        <h5>Eleveur : </h5>\n        <b>{{#if eleveur}}{{eleveur}}{{else}}- {{/if}}</b>\n     </div>\n     <div class="fiche-cheval-ascendance">\n        <h5>Ascendance :</h5>\n        <ul>\n            <li><span>Père</span><span title="{{nomPere}}"><b>{{#if nomPere}} {{formatForCell nomPere 20}}{{else}}- {{/if}}</b></span></li>\n            <li><span>Mère </span><span title="{{nomMere}}"> <b>{{#if nomMere}} {{formatForCell nomMere 20}}{{else}}- {{/if}}</b></span></li>\n            <li><span>Père de la mère</span><span title="{{nomPereMere}}"> <b>{{#if nomPereMere}}{{formatForCell nomPereMere 15}}{{else}}- {{/if}}</b></span></li>\n        </ul>\n     </div>\n</div>';});

define('src/course/participants/ParticipantItemView',[
    'template!./templates/partants/plat-item.hbs',
    'template!./templates/partants/obstacle-item.hbs',
    'template!./templates/partants/trot-attele-item.hbs',
    'template!./templates/partants/trot-monte-item.hbs',
    'template!./templates/partants/non-partant-item.hbs',

    'template!./templates/arrivee/plat-item.hbs',
    'template!./templates/arrivee/obstacle-item.hbs',
    'template!./templates/arrivee/trot-attele-item.hbs',
    'template!./templates/arrivee/trot-monte-item.hbs',
    'template!./templates/arrivee/non-partant-item.hbs',
    'template!./templates/partants/fiche-cheval.hbs',
    'utils',
    'paris',
    'modalManager',
    'tagCommander'
], function (partantPlatTmpl, partantObstacleTmpl, partantTrotAtteleTmpl, partantTrotMonteTmpl, partantNonPartantTmpl, arriveePlatTmpl, arriveeObstacleTmpl, arriveeTrotAtteleTmpl, arriveeTrotMonteTmpl, arriveeNonPartantTmpl, ficheChevalTmpl, utils, Pari, modalManager, tagCommander) {

    

    return Backbone.View.extend({

        tagName: 'tr',

        className: 'ligne-participant',

        events: {
            'click .participant-check': 'toggleParticipant',
            'click .name': 'showFichePopin'
        },

        templates: {
            ARRIVEE: {
                PLAT: {template: arriveePlatTmpl, colspan: 4},
                OBSTACLE: {template: arriveeObstacleTmpl, colspan: 4},
                TROT_ATTELE: {template: arriveeTrotAtteleTmpl, colspan: 4},
                TROT_MONTE: {template: arriveeTrotMonteTmpl, colspan: 4}
            },
            NON_ARRIVEE: {
                PLAT: {template: partantPlatTmpl, colspan: 10},
                OBSTACLE: {template: partantObstacleTmpl, colspan: 9},
                TROT_ATTELE: {template: partantTrotAtteleTmpl, colspan: 9},
                TROT_MONTE: {template: partantTrotMonteTmpl, colspan: 10}
            }
        },

        nonPartantItemTmpl: {
            ARRIVEE: arriveeNonPartantTmpl,
            NON_ARRIVEE: partantNonPartantTmpl
        },

        nonPartant: {},

        initialize: function () {
            this.model.parseRapports();
            this.listenTo(this.model, 'change:statut change:ordreArrivee change:baseSelected change:associateSelected', this.render);
        },

        render: function () {
            var specialite = this.options.specialite,
                statut = this.options.course.statut,
                arrivee = this.options.arrivee,
                index = this.options.index,
                isParisOnCourse = this.options.isParisOnCourse,
                template,
                json;

            if (specialite) {
                json = this.model.toJSON();
                if (this.model.isNonPartant()) {
                    template = this.nonPartantItemTmpl[arrivee];
                    this.$el.addClass('non-partant');
                    json.colspan = this.templates[arrivee][specialite].colspan;
                } else {
                    template = this.templates[arrivee][specialite].template;
                    this.$el.removeClass('non-partant');
                }

                if (this.model.isFavori) {
                    this.$el.addClass('favorite');
                }

                json.arriveeDefinitiveComplete = statut === 'FIN_COURSE' || statut === 'ARRIVEE_DEFINITIVE_COMPLETE';
                json.sexe = utils.serviceMapper.getSexeFromCondition(json.sexe) || json.sexe;

                this.$el
                    .addClass(index % 2 === 0 ? 'odd' : 'even')
                    .html(template({p: json}));
            }

            if (arrivee === 'ARRIVEE' || !isParisOnCourse) {
                this.$('.optional').hide();
            }

            return this;
        },

        toggleParticipant: function (event) {
            var type = $(event.currentTarget).data('type'),
                isBaseSelected = this.model.get('baseSelected'),
                isAssociateSelected = this.model.get('associateSelected'),
                value = {};

            Backbone.trigger('parieuse:hideConfirmationPopin');

            if (type === Pari.BASE) {
                if (isBaseSelected) {
                    this.toggleSelected({baseSelected: false});
                } else {
                    this.model.once('grant:baseSelected', this.toggleBase, this);
                    this.model.trigger('request:baseSelected', this.model);
                }
            } else if (type === Pari.ASSOCIATE) {
                if (isBaseSelected) {
                    value.baseSelected = false;
                }
                value.associateSelected = !isAssociateSelected;
                this.toggleSelected(value);
            }
        },

        toggleSelected: function (value) {
            this.model.set(value);
        },

        toggleBase: function () {
            var isAssociateSelected = this.model.get('associateSelected'),
                isComplementarySelected = this.model.get('complementarySelected'),
                value = {};

            if (isAssociateSelected) {
                value.associateSelected = false;
            }
            if (isComplementarySelected) {
                value.complementarySelected = false;
            }
            value.baseSelected = true;
            this.toggleSelected(value);
        },

        showFichePopin: function (event) {
            var json = this.model.toJSON();
            json.sexe = utils.serviceMapper.getSexeFromCondition(json.sexe) || json.sexe;

            this.sendTag();

            modalManager.pane(
                ficheChevalTmpl(json),
                $(event.currentTarget),
                'Fiche Cheval ' + json.nom,
                {
                    cssClass: 'popin detail-popin fiche-cheval',
                    position: 'right',
                    width: 402,
                    category: 'layer'
                }
            );
        },

        sendTag: function () {
            tagCommander.sendTagIfOffline(
                'programme_resultats.course.fiche_cheval',
                {
                    bet_reunion_id: this.options.course.numReunion,
                    bet_course_id: this.options.course.numOrdre
                }
            );
        }
    });
});

define('src/course/participants/ParticipantListView',[
    'template!./templates/partants/plat-list.hbs',
    'template!./templates/partants/obstacle-list.hbs',
    'template!./templates/partants/trot-attele-list.hbs',
    'template!./templates/partants/trot-monte-list.hbs',

    'text!./templates/arrivee/plat-list.html',
    'text!./templates/arrivee/obstacle-list.html',
    'text!./templates/arrivee/trot-attele-list.html',
    'text!./templates/arrivee/trot-monte-list.html',

    'template!./templates/legende-partants.hbs',

    'template!./templates/ecurie-item.hbs',
    'template!./templates/musique-popin.html',
    'utils',
    'comparator',
    './ParticipantItemView',
    'paris',
    'messages',
    'timeManager',
    'modalManager',
    'conf'
], function (partantPlatHeader, partantObstacleHeader, partantTrotAtteleHeader, partantTrotMonteHeader, arriveePlatHeader, arriveeObstacleHeader, arriveeTrotAtteleHeader, arriveeTrotMonteHeader, legendePartantsTmpl, ecurieItemTmpl, musiquePopinTmpl, utils, comparator, ParticipantItemView, Pari, messages, timeManager, modalManager, conf) {
    

    var IS_TRIABLE_CLASS = 'triable',
        SORT_ASC_CLASS = 'asc',
        SORT_DESC_CLASS = 'desc',
        FORMULE_SIMPLIFIE_CLASS = 'formule-simplifiee',
        FORMULE_AVANCEE_CLASS = 'formule-avancee';

    return Backbone.View.extend({

        events: {
            'click .triable': '_sort'
        },

        templates: {
            NON_ARRIVEE: {
                PLAT: partantPlatHeader,
                OBSTACLE: partantObstacleHeader,
                TROT_ATTELE: partantTrotAtteleHeader,
                TROT_MONTE: partantTrotMonteHeader
            },
            ARRIVEE: {
                PLAT: arriveePlatHeader,
                OBSTACLE: arriveeObstacleHeader,
                TROT_ATTELE: arriveeTrotAtteleHeader,
                TROT_MONTE: arriveeTrotMonteHeader
            }
        },

        initialize: function () {
            this.participants = this.options.participants;
            this.ecuries = this.options.ecuries;

            this._initListeners();
        },

        _initListeners: function () {
            this.listenTo(Backbone, 'pari:formule', this.onChangeFormule);
            this.listenTo(this.participants, 'reset update sort', this.render);
        },

        _sort: function (event) {
            var classes = $(event.currentTarget).closest('td').attr('class').split(/\s+/),
                cl = _.without(classes, IS_TRIABLE_CLASS, SORT_ASC_CLASS, SORT_DESC_CLASS),
                isAsc = _.indexOf(classes, SORT_ASC_CLASS) !== -1;
            this.participants.sortByProperty(cl[0], isAsc);
        },

        renderSort: function () {
            this.$('.' + IS_TRIABLE_CLASS)
                .removeClass(SORT_ASC_CLASS + ' ' + SORT_DESC_CLASS)
                .filter('.' + this.participants.getSortPropertyName())
                .addClass(this.participants.isSortAsc() ? SORT_ASC_CLASS : SORT_DESC_CLASS);
        },

        resetSort: function () {
            if (this.course && this.course.categorieStatut === 'ARRIVEE') {
                this.participants.setComparator('ordreArrivee', true);
            } else {
                this.participants.setComparator('numPmu', true); // Propriété par laquelle la collection est triée initialement.
            }
        },

        render: function () {
            var discipline = (this.course && this.course.discipline) || '',
                specialite = utils.serviceMapper.getSpecialiteFromDiscipline(discipline),
                advanced = this.$el.hasClass(FORMULE_AVANCEE_CLASS),
                $tbody,
                $participantsItems = $([]),
                statut,
                isParisOnCourse,
                jumentPleineArray = [],
                oeilleresArray = [],
                deferreArray = [];

            if (!specialite) { return this; }

            isParisOnCourse = utils.somePariEnVente(this.course.paris);

            if (this.course.categorieStatut === 'ARRIVEE') {
                if (!this.currentTable) { this.currentTable = 'ARRIVEE'; }
                statut = this.currentTable;
            } else {
                statut = 'NON_ARRIVEE';
            }

            if (statut === 'NON_ARRIVEE') {
                this.$el.html(this.templates[statut][specialite]());
            } else {
                this.$el.html(this.templates[statut][specialite]);
            }
            $tbody = this.$('tbody');

            this.participants.min(function (participant) {
                if (participant.get('statut') === 'PARTANT' && participant.get('dernierRapportDirect') && participant.get('dernierRapportDirect').rapport > 0) {
                    return participant.get('dernierRapportDirect').rapport;
                }
            }).isFavori = true;

            this.participants.each(function (participantModel, index) {
                $participantsItems = $participantsItems.add(new ParticipantItemView({
                    arrivee: statut,
                    course: this.course,
                    model: participantModel,
                    specialite: specialite,
                    index: index,
                    isParisOnCourse: isParisOnCourse
                }).render().el);

                jumentPleineArray.push(participantModel.get('jumentPleine'));

                if (specialite !== 'TROT_MONTE' && specialite !== 'TROT_ATTELE') {
                    deferreArray.push(participantModel.get('oeilleres'));
                } else {
                    deferreArray.push(participantModel.get('deferre'));
                }
            }, this);

            $tbody.append($participantsItems);

            this.renderSort();


            if (statut === 'NON_ARRIVEE') {
                this.renderEcurie(specialite);
            }

            if (_.contains(['EN_COURS', 'SUSPENDU', 'ARRIVEE'], this.course.categorieStatut) || !isParisOnCourse) {
                this.hidePariColumns();
            } else {
                if (advanced) {
                    this.setFormuleAvancee();
                } else {
                    this.setFormuleSimplifiee();
                }
            }
            this.renderHeuresRapportsProbables();

            this.delegateEvents();

            modalManager.tooltip(musiquePopinTmpl({aideMusique: conf.AIDE_PMU.MUSIQUE_URL}), this.$('.musique').first());

            this.$('tr.participant-header th[data-type]').each(_.bind(this._createTooltipCheval, this));

            this.renderLegend(jumentPleineArray, oeilleresArray, deferreArray);

            return this;
        },

        renderLegend: function (jumentPleineArray, oeilleresArray, deferreArray) {
            var modelData = {},
                legendData = [];

            modelData = _.compact(_.flatten([_.uniq(jumentPleineArray), _.uniq(oeilleresArray), _.uniq(deferreArray)]));

            _.each(modelData, function (data) {
                if (data === true) { //true n'est présent que dans le cas d'une jument pleine
                    legendData.push({
                        "cssClass": 'icoJumentPleine',
                        "label": 'Jument pleine'
                    });
                } else if (data !== 'INCONNU' && data !== 'SANS_OEILLERES') {
                    legendData.push({
                        "cssClass": data,
                        "label": messages.get(data)
                    });
                }
            });

            this.$el.append(legendePartantsTmpl({data: legendData}));
        },

        hidePariColumns: function () {
            this.$('.optional').remove();
            this.$('th.rapports').removeProp('colspan').css('width', '140px');
        },

        _createTooltipCheval: function (index, cheval) {
            var message = this.getTooltipText($(cheval).data('type'));
            modalManager.tooltip(message, $(cheval));
        },

        renderEcurie: function (specialite) {
            var $tfoot = this.$('tfoot'),
                isPlatOrTrot = (specialite === 'PLAT' || specialite === 'TROT_MONTE');

            if (!this.ecuries) { return; }

            this._sortEcurie();
            this.ecuries.each(_.bind(function (ecurie) {
                $tfoot.append(ecurieItemTmpl({ecurie: ecurie.toJSON(), isPlatOrTrot: isPlatOrTrot}));
            }, this));
        },

        _sortEcurie: function () {
            var sortProperty = this.participants.getSortPropertyName();

            if (!_.contains(['nom', 'coteRef', 'cote'], sortProperty)) {
                // Si tri sur une autre colonne, tri par défaut par nom ascendant
                sortProperty = 'nom';
                this.ecuries.sortByPropertyAsc(sortProperty);
            } else if (this.participants.isSortAsc()) {
                this.ecuries.sortByPropertyAsc(sortProperty);
            } else {
                this.ecuries.sortByPropertyDesc(sortProperty);
            }
        },

        // TODO : le service devrait renvoyer les dates des rapports probables hors des participants
        renderHeuresRapportsProbables: function () {
            var participantAvecDateRapportRef,
                participantAvecDateRapportEvol,
                dateRapportRef = 'Ref.',
                dateRapportEvol = 'Direct';

            participantAvecDateRapportRef = this.participants.find(function (participant) {
                return (participant.get('dernierRapportReference') && participant.get('dernierRapportReference').dateRapport);
            });
            if (participantAvecDateRapportRef) {
                dateRapportRef = participantAvecDateRapportRef.get('dernierRapportReference').dateRapport;
                dateRapportRef = timeManager.moment(dateRapportRef);
                dateRapportRef = dateRapportRef.format('HH\\hmm');
            }

            participantAvecDateRapportEvol = this.participants.find(function (participant) {
                return (participant.get('dernierRapportDirect') && participant.get('dernierRapportDirect').dateRapport);
            });
            if (participantAvecDateRapportEvol) {
                dateRapportEvol = participantAvecDateRapportEvol.get('dernierRapportDirect').dateRapport;
                dateRapportEvol = timeManager.moment(dateRapportEvol);
                dateRapportEvol = dateRapportEvol.format('HH\\hmm');
            }

            this.$('thead .rapport-probable:first-child').text(dateRapportRef);
            this.$('thead .rapport-probable:last-child').text(dateRapportEvol);
        },

        onChangeFormule: function (formule) {
            this.formule = formule;
            switch (formule) {
            case Pari.CHAMP_TOTAL:
            case Pari.UNITAIRE:
            case Pari.COMBINAISON:
                this.setFormuleSimplifiee();
                break;
            case Pari.CHAMP_REDUIT:
                this.setFormuleAvancee();
                break;
            }
        },

        setFormuleAvancee: function () {
            this.$el.removeClass(FORMULE_SIMPLIFIE_CLASS);
            this.$el.addClass(FORMULE_AVANCEE_CLASS);
        },

        setFormuleSimplifiee: function () {
            this.$el.removeClass(FORMULE_AVANCEE_CLASS);
            this.$el.addClass(FORMULE_SIMPLIFIE_CLASS);

            this.participants.each(function (model) {
                model.set('associateSelected', false);
            });
        },

        getTooltipText: function (column) {
            if (column === 'associate') {
                return messages.get('CHEVAUX_SELECTION_ASSOCIATES');
            }
            if (column === 'base' || this.formule === Pari.CHAMP_TOTAL) {
                return messages.get('CHEVAUX_SELECTION_BASES');
            }
            return messages.get('CHEVAUX_SELECTION');
        }
    });
});

define('text!src/course/participants/templates/course-view.html',[],function () { return '<div class="buttonGroup txtC">\n    <a class="btn btn-selected">Détails de l\'arrivée</a><!--\n    --><a class="btn">Tableau des partants</a>\n</div>\n';});

define('src/course/participants/ParticipantsCourseView',[
    './ParticipantsWrapperModel',
    './EcurieCollection',
    './ParticipantListView',
    'text!./templates/course-view.html',
    'timeManager',
    'src/course/pari/pariManager'
], function (ParticipantsWrapperModel, EcurieCollection, ParticipantListView, courseTemplate, timeManager, pariManager) {
    

    return Backbone.View.extend({

        id: 'participants-view',

        selfRender: true,

        className: 'participants-view',

        events: {
            'click .buttonGroup a:not(.btn-selected)': 'toggleTable'
        },

        initialize: function () {
            this.participants = this.options.participants;
            this.ecuries = new EcurieCollection();
            this.participantsWrapper = new ParticipantsWrapperModel();
            this.participantListView = new ParticipantListView({participants: this.participants, ecuries: this.ecuries});

            // Evenement de notification de changement sur la course
            this.listenTo(Backbone, 'course:alert rapports_sg_participants:alert', this.refreshByAlert);
        },

        render: function () {
            this.$el.html(this.participantListView.render().el);
            return this;
        },

        load: function (date, reunionid, courseid, course) {
            var self = this;

            if (course.categorieStatut === 'ANNULEE') {
                this.$el.empty();
                return;
            }

            this.participantListView.course = course;
            this.participantListView.currentTable = undefined;
            this.participantListView.resetSort();
            this.render();

            if (course.categorieStatut === 'ARRIVEE') {
                this.$el.append(courseTemplate);
            } else {
                this.$('.buttonGroup').remove();
            }

            this.participantsWrapper.args(date, reunionid, courseid);
            this.participantsWrapper.fetch({
                success: function (wrapper) {
                    self.ecuries.reset(wrapper.get('ecuries'));
                    self.ecuries.each(function (ecurie) {
                        ecurie.parseRapports();
                    });
                    self.participants.reset(wrapper.get('participants'));

                    if (_.contains(['A_PARTIR', 'INCONNU'], course.categorieStatut)) {
                        pariManager().getPari().selectParticipantsFromBase();
                        pariManager().getPari().selectParticipantsFromAssocie();
                    }
                }
            });
        },

        reload: function (autocall) {
            var self = this;
            this.participantsWrapper.fetch({
                success: function (model) {
                    self.ecuries.update(model.get('ecuries'));
                    self.ecuries.each(function (ecurie) {
                        ecurie.parseRapports();
                    });

                    // Ne pas mettre {merge:false} dans le update car les models doivent être mergé pour rester
                    // coché
                    self.participants.update(model.get('participants'));
                    self.participants.trigger('update');
                    self.participants.sort();
                },
                data: autocall ? {autocall: true} : {}
            });
        },

        refreshByAlert: function (message) {
            var contextMessage = message.context,
                dateCourseNotif = timeManager.momentWithOffset(contextMessage.dateProgramme, contextMessage.timezoneOffset).format(timeManager.ft.DAY_MONTH_YEAR);// FIXME : offset en param

            if (this.participantsWrapper.reunionid === contextMessage.reunion &&
                    this.participantsWrapper.courseid === contextMessage.course &&
                    this.participantsWrapper.date === dateCourseNotif) {

                this.info('Participants alert', message);
                this.reload(true);
            }
        },

        toggleTable: function (event) {
            event.preventDefault();
            this.participantListView.currentTable = this.participantListView.currentTable == 'ARRIVEE' ? 'NON_ARRIVEE' : 'ARRIVEE';
            this.participantListView.render();

            this.$('.buttonGroup .btn-selected').removeClass('btn-selected');
            $(event.currentTarget).addClass('btn-selected');
        }
    });
});

define('text!src/course/bandeau_status/templates/course-annulee.hbs',[],function () { return '<div class=\'img-course-annulee\'>\n    COURSE ANNUL&Eacute;E\n</div>\n';});

define('text!src/course/bandeau_status/templates/course-en-cours.hbs',[],function () { return '<div class="img-course-en-cours">\n    LES CHEVAUX SONT PARTIS !\n</div>\n';});

define('src/course/bandeau_status/BandeauCourseStatusView',[
    'template!src/course/bandeau_status/templates/course-annulee.hbs',
    'template!src/course/bandeau_status/templates/course-en-cours.hbs'
], function (courseAnnuleeTmpl, courseEnCoursTmpl) {
    

    return Backbone.View.extend({
        template : {},

        selfRender: true,

        className : 'course-bandeau-statut',

        initialize : function () {
            this.template.ANNULEE = courseAnnuleeTmpl;
            this.template.EN_COURS = courseEnCoursTmpl;
            this.template.SUSPENDU = courseEnCoursTmpl;
        },

        setOptions : function (options) {
            _.extend(this.options, options);

            return this;
        },

        render : function () {
            var hasTemplate = !!this.template[this.options.categorieStatut];

            if (hasTemplate) {
                this.$el.show().html(this.template[this.options.categorieStatut]());
                return this;
            }

            this.$el.hide().empty();
            return this;
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
define('src/course/CourseWrapperView',[
    './liste_courses/ReunionView',
    './infos_arrivee/InfosArriveeView',
    './participants/ParticipantsCourseView',
    'src/course/liste_courses/reunionManager',
    'src/course/pari/pariManager',
    'src/common/PariPickerView',
    'src/course/bandeau_status/BandeauCourseStatusView',
    'utils',
    'links',
    'messages',
    'dialog',
    'tagCommander'
], function (ReunionView, InfosArriveeView, ParticipantsCourseView, reunionManager, pariManager, PariPickerView, BandeauCourseStatusView, utils, links, messages, dialog, tagCommander) {
    

    return Backbone.View.extend({

        subViews: [],

        initialize: function (options) {
            this.setOptions();
            this.setModel();
            this.setSubViews();
            this.setListeners();
        },

        setOptions: function () {
            Backbone.View.prototype.setOptions.apply(this, arguments);
            reunionManager().setCurrentCourseId(this.courseid);
            reunionManager().setCurrentCourseDate(this.date);
        },

        setModel: function () {
            this.model = reunionManager().getReunion(true);
        },

        fetchModel: function (date, reunionid) {
            this.lastCategorieStatut = null;

            if (reunionid !== this.model.get('numOfficiel')) {
                this.model.clear();
            }

            this.model.setUrlParams(date, reunionid);
            this.model.fetch();
        },

        setListeners: function () {
            this.listenTo(this.model, 'sync', this.renderCourse);
            this.listenTo(this.model, 'error', this.renderErrorCourse);
            this.listenTo(Backbone, 'course:change', this.changeCourse);
            this.listenTo(Backbone, 'spot:isActive', this.toggleSpot);
            this.listenTo(Backbone, 'course:alert', this.refreshByAlert);
        },

        setSubViews: function () {
            this.reunionView = new ReunionView({model: this.model, date: this.date, reunionid: this.reunionid});
            this.infosArriveeView = new InfosArriveeView({model: this.model, courseid: this.courseid});
            this.participantsCourseView = new ParticipantsCourseView({model: this.model, participants: this.participants});
            this.bandeauCourseStatusView = new BandeauCourseStatusView();

            this.subViews = [
                this.reunionView,
                this.infosArriveeView,
                this.bandeauCourseStatusView,
                this.participantsCourseView
            ];

            this.$el
                .append(this.reunionView.el)
                .append(this.infosArriveeView.el)
                .append(this.bandeauCourseStatusView.el)
                .append(this.participantsCourseView.el);
        },

        render: function () {
            this.fetchModel(this.date, this.reunionid);
            return this;
        },

        refreshByAlert: function (message) {
            var timestampProgramme = moment(this.date, 'DDMMYYYY').toDate().getTime();// FIXME : offset en param

            if (message.context.dateProgramme !== timestampProgramme || message.context.reunion !== this.reunionid || message.context.course !== this.courseid) {
                return;
            }

            this.renderFromAlerting = true;
            this.model.fetch({data: {autocall: true}});
        },

        updateCourse: function (course) {
            this.reunionView.setOptions({date: this.date, reunionid: this.reunionid, courseid: this.courseid, renderFromAlerting: this.renderFromAlerting}).render();
            this.infosArriveeView.setOptions({courseid: this.courseid}).render();
            this.bandeauCourseStatusView.setOptions({categorieStatut: course.categorieStatut}).render();
            this.participantsCourseView.participantListView.course = course;
        },

        changeCourse: function (date, reunionid, courseid, pari) {
            this.renderFromAlerting = false;

            this.setOptions({
                date: date,
                reunionid: reunionid,
                courseid: courseid,
                pari: pari
            });

            this.fetchModel(date, reunionid, true);
        },

        renderCourse: function () {
            var course = this.setAppropriateCourse();

            if (_.isUndefined(course)) {
                this.renderNoCourse();
                return;
            }

            this.setRouteIfNecessary(course.numOrdre);
            this.setSidebarContext(course);
            this.updateCourse(course);

            if (course.categorieStatut !== this.lastCategorieStatut) {
                if (course.categorieStatut === 'EN_COURS' && this.lastCategorieStatut === 'A_PARTIR') {
                    this.alertCourseDepart();
                }
                if (!this.pariView.model.get('isReport')) {
                    this.pariView.model.set(this.pariView.model.defaults);
                }

                this.setParticipants(course);
                this.setPari(course);
                this.pariView.render();
                this.lastCategorieStatut = course.categorieStatut;

            } else {
                if (this.lastDepartImminent === null || (course.departImminent !== this.lastDepartImminent)) {
                    this.setPari(course);
                    this.pariView.renderDepartImminent();
                    this.lastDepartImminent = course.departImminent;
                }
            }

            pariManager().restaurer();
            PariPickerView.prototype.chooseFamily(this.family);

            this.sendTag();
        },

        renderErrorCourse: function (model, response) {
            if (_.contains([420, 500], response.status)) {
                this.setOptions();
                this.returnToHome();
            }
        },

        sendTag: function () {
            tagCommander.sendTags(
                'hippique.parier.reunion.course',
                'programme_resultats.course',
                {
                    bet_reunion_id: this.reunionid,
                    bet_course_id: this.courseid
                }
            );
        },

        renderNoCourse: function () {
            this.sidebarView.switchContext('course_autres');

            this.showBandeauMessage(
                messages.get('COURSE.ERROR.NOCOURSE'),
                'notice',
                {inline: true},
                {notclosable: true},
                this.$('#participants-view')
            );
        },

        setParticipants: function (course) {
            this.participantsCourseView.load(
                this.date,
                this.reunionid,
                this.courseid,
                course
            );
        },

        setPari: function (course) {
            this.pariView.setOptions(
                this.date,
                course.heureDepart,
                this.reunionid,
                this.model.get('numExterne'),
                this.courseid,
                course.paris,
                this.isSpot,
                course.departImminent
            );
        },

        toggleSpot: function () {
            if (this.isSpot === true) {
                this.isSpot = false;
            }
        },

        setAppropriateCourse: function () {
            var view = this;

            if (!this.courseid) {
                this.courseid = reunionManager().getProchaineCourse();
            }

            return _.find(this.model.get('courses'), function (course) {
                return course.numOrdre === view.courseid;
            });
        },

        setRouteIfNecessary: function (courseid) {
            if (Backbone.history.fragment.indexOf('/C') === -1) {
                Backbone.history.navigate(
                    links.get('course', this.date, this.reunionid, courseid),
                    {replace: true}
                );
            }
        },

        setSidebarContext: function (course) {
            if (_.contains(['A_PARTIR', 'INCONNU'], course.categorieStatut) && utils.somePariEnVente(course.paris)) {
                this.sidebarView.switchContext('course_a_partir');
                tagCommander.sendTagIfOnline('hippique.parier.panier');
            } else {
                this.sidebarView.switchContext('course_autres');
            }
        },

        alertCourseDepart: function () {
            if (dialog.isOpen() && dialog.getCurrentType() === 'session') {
                // L'alerte de déconnexion est prioriaire
                return;
            }

            dialog.infoWithClose(
                'course-depart',
                '<div class="txt">' + messages.get('validation.front.3100') + '</div>',
                'Attention',
                {
                    modal: true,
                    duration: 3000,
                    dialogClass: 'dialog-black',
                    minWidth: 375,
                    position: ['center', 'center']
                }
            );
        }
    });
});

define('src/course/CourseWrapperOffView',['src/course/CourseWrapperView', 'messages'], function (CourseWrapperView, messages) {
    

    return CourseWrapperView.extend({
        renderCourse: function () {
            var course = this.setAppropriateCourse();

            if (_.isUndefined(course)) {
                this.renderNoCourse();
                return;
            }

            this.setRouteIfNecessary(course.numOrdre);
            this.updateCourse(course);

            if (course.categorieStatut !== this.lastCategorieStatut) {
                if (course.categorieStatut === 'EN_COURS' && this.lastCategorieStatut === 'A_PARTIR') {
                    this.alertCourseDepart();
                }

                this.setParticipants(course);
                this.lastCategorieStatut = course.categorieStatut;
            }

            this.sendTag();
        },
        renderNoCourse: function () {
            this.showBandeauMessage(
                messages.get('COURSE.ERROR.NOCOURSE'),
                'notice',
                {inline: true},
                {notclosable: true},
                this.$('.inner')
            );
        }
    });
});

define('CourseStandalone',['require','core','timeManager','src/course/participants/ParticipantCollection','src/course/CourseWrapperOffView'],function (require) {
    

    require('core');

    var timeManager = require('timeManager'),
        ParticipantCollection = require('src/course/participants/ParticipantCollection'),
        CourseView = require('src/course/CourseWrapperOffView'),
        CourseRouter,
        router,
        course;

    CourseRouter = Backbone.Router.extend({
        hashBangPrefix: '!/',
        partialRoutes: {
            ':date': 'programme',
            ':date/R:reunionid': 'reunion',
            ':date/R:reunionid/C:courseid': 'course',
            '*path': 'home'
            //':date/R:reunionid/C:courseid/SPOT': 'course',
            //':date/R:reunionid/C:courseid/:family': 'course',
        },
        initialize: function () {
            this.buildRoutes(this.partialRoutes, this.hashBangPrefix);
        },
        home: function () {
            //console.log('redirect home');
        },
        programme: function () {
            //console.log('redirect programme');
        },
        reunion: function (date, reunionid) {
            course.setOptions({
                date: date,
                reunionid: parseInt(reunionid, 10),
                courseid: undefined
            });

            course.fetchModel(date, parseInt(reunionid, 10));
        },
        course: function (date, reunionid, courseid) {
            course.setOptions({
                date: date,
                reunionid: parseInt(reunionid, 10),
                courseid: parseInt(courseid, 10)
            });

            course.fetchModel(date, parseInt(reunionid, 10));
        },
        buildRoutes: function (partialRoutes, hashBangPrefix) {
            var excludedRoute = '*path',
                route,
                routes = _.keys(partialRoutes);

            while ((route = routes.pop()) != null) {//!= undefined || != null
                if (route !== excludedRoute) {
                    this.route(hashBangPrefix + route, partialRoutes[route]);
                    this.route(route, partialRoutes[route]);
                } else {
                    this.route(route, partialRoutes[route]);
                }
            }
        }
    });

    timeManager.fetch({
        success: function () {
            course = new CourseView({participants: new ParticipantCollection()});
            router = new CourseRouter();

            try {
                Backbone.history.start();
            } catch (err) {
                Backbone.history.loadUrl();
            }

            $('#bloc-course').append(course.el);
        },
        error: function () {

        }
    });
});
