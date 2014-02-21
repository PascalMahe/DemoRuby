define('conf', {

    LOG_LEVEL: 'warn',

    SOCKET_SCHEME: 'https',
    SOCKET_HOST: 'www.alerting.pmu.fr',
    SOCKET_PORT: '443',
    SOCKET_PREFIX: '/ws',

    GUIDE_DES_PARIS_IMAGES_PATH: "/sites/offline/modules/custom/pmu_ria/ressources/",

    GCMV_ROOT_URL : 'https://www.pmu.fr',
    GCMV_85_SUFFIXE : '?clientApi=7&typeCompte=85&redirectionUrl=https://info.pmu.fr',
//    OUVERTURE_COMPTE_URL: 'https://www.pmu.fr/ouverture?clientApi=7&typeCompte=85&redirectionUrl=https%3A%2F%2Finfo%2Epmu%2Efr',
    OUVERTURE_COMPTE_URL:'https://www.pmu.fr/ouverture/85?clientApi=7&redirectionUrl=https%3A%2F%2Finfo%2Epmu%2Efr',
    POKER_URL: 'http://poker.pmu.fr/',
    SPORTIF_URL: 'https://paris-sportifs.pmu.fr/',

    AIDE_PMU: {
        MUSIQUE_URL: 'http://www.aide.pmu.fr/musique'
    },

    URLS_CMS_FALLBACK: {//default drupal
        GUIDE_PARIS_URL: 'https://www.pmu.fr/#!/guide-des-paris',
        MOBILE_URL: 'http://www.pmumobile.fr/index.html',
        OLD_PMU_INFO_URL: 'http://www.pmu.fr/turf/',
        BLOG_POKER_URL: "http://poker.blog.pmu.fr/",
        BLOG_SPORT_URL: "http://sport.blog.pmu.fr/",
        INTERDICTION_VOL_JEUX: 'http://www.interieur.gouv.fr/sections/a_votre_service/vos_demarches/interdiction-jeux',
        TWITTER_PMU_SPORTIF_URL: 'https://twitter.com/PMU_Sportif',
        FACEBOOK_PMU_SPORTIF_URL: 'http://www.facebook.com/pages/PMU-Paris-Sportifs/125532387462663',
        ENTREPRISE_PMU_URL: 'http://entreprise.pmu.fr/',
        ENTREPRISE_PMU_MINEURS_URL: 'http://www.pmu.fr/entreprise/assurer-la-protection-des-mineurs.html',
        ENTREPRISE_PMU_JOUONS_RESPONSABLE_URL: 'http://www.pmu.fr/entreprise/jouons-responsable-pmu.html',
        ENTREPRISE_PMU_CARRIERES_URL: 'http://www.pmu.fr/entreprise/voir-toutes-les-offres.html',
        PARIMUTUEL_EUROPE_URL: 'http://www.parimutuel-europe.org/',
        PMU_AIDE_URL: 'http://www.aide.pmu.fr/aide-hippique/faq/parier-pmufr',
        PMU_NEWSLETTER_URL: 'http://formulaires.pmuanimation.fr/newsletter-pmu',
        PMU_CONTACT_URL: 'https://www.pmu.fr/#!/contact',
        VERISIGN_URL: 'http://www.verisign.fr',
        PMU_PARTENARIAT_URL: 'https://www.pmu.fr/entreprise/partenariats-operationnels.html',
        PMU_EN_URL: 'http://en.pmu.fr',
        PMU_PLAN_SITE_URL: 'https://www.pmu.fr/#!/plan-du-site',
        PMU_INFO_LEGALES_URL: 'https://www.pmu.fr/#!/informations-legales',
        PMU_ACTUALITES_URL: 'https://www.pmu.fr/#!/actualites-hippiques'
    },

    LIVE_AUDIO: 'http://stat3.cybermonitor.com/cgi-bin/ft/09110?svc_mode=I&svc_campaign=Commentaires+en+direct&svc_partner=Colonne+de+droite&estat_url=http%3A%2F%2Fplayers.tv-radio.com%2Fequidia%2Faudio%2FEquidiaFlexPlayer.php%3F',

    GUIDE_PARIS_SERVER_PATH: 'guide',
    GUIDE_PARIS_IMAGES_URL: 'guide-des-paris/images/#!/',

    TIMEOUT_DEFAULT: 5000,
    // Expressions régulières des urls des services, cf. backboneCustom.js#sync
    TIMEOUTS: {
        '/turfInfo/client/7/timestampPMU': 10000,
        '/ws/online/pmu_ws_content_region/(.*)\\?region=sidebar_right': 5000,
        '/account/client/7/profil': 5000,
        '/account/client/7/compte/activer': 5000,
        '/account/client/7/mouvements': 10000,
        '/account/client/7/solde-retrait': 10000,
        '/account/client/7/session': 15000
    },

    // les versions des navigateurs à partir desquelles on autorise la navigation.
    // les navigateurs hors de cette liste sont considérés comme des versions degradées. On autorise la navigation avec un message de warning.
    BROWSER_FIRST_COMPATIBLE_VERSION: {
        IE: 8,
        FIREFOX: 19,
        CHROME: 23,
        SAFARI: 5
    },

    CALENDAR_BORNE: {
        dateMinProgrammes: 1361228400000,   //Mon, 18 Feb 2013 23:00:00 GMT
        dateMaxProgrammes: 1815350400000    //Mon, 12 Jul 2027 00:00:00 GMT
    }
});
