<!--
/*AdPerf - performance.js version 2.1*/
/*AdPerf is a trademark property of Weborama*/
/*http://www.weborama.com*/
/*Last edit  10/03/2008*/

/*Performance Class*/

/*Location*/
var WPERF_SERVER = ".weborama.fr", WPERF_PRGM = "/fcgi-bin/performance.fcgi", JS_TAG_VERSION=1;

function performancePassage(_FID_SITE, _ID_TRANSFO, _ID_PASSAGE) {
    /*Attributs*/
    this.FID_SITE = _FID_SITE;
    this.ID_TRANSFO = _ID_TRANSFO;
    this.ID_PASSAGE=_ID_PASSAGE;
    this.ACTION = 3;
    this.PARAMS = new Array();
    this.HOST = '';

    /*Fonctions*/
    this.getURL = getURL;
    this.setHost = setHost;
    this.setClient = setClient;
    this.addParam = addParam;	    
    this.execute = execute;
}

function performanceScenario(_FID_SITE, _ID_TRANSFO, _ID_SCENARIO) {
    /*Attributs*/
    this.FID_SITE = _FID_SITE;
    this.ID_TRANSFO = _ID_TRANSFO;
    this.ID_SCENARIO = _ID_SCENARIO;
    this.ACTION = 4;
    this.HOST = '';

    /*Fonctions*/
    this.getURL = getURL;
    this.setHost = setHost;
    this.execute = execute;
}

function performanceParam(_K, _V) {this.key = _K; this.value = _V;}

function performanceTransfo(_FID_SITE, _ID_TRANSFO) {
    /*Attributs*/
    this.FID_SITE = _FID_SITE;
    this.ID_TRANSFO = _ID_TRANSFO;
    this.ID_ACHAT = 0;
    this.ID_CLIENT = 0;
    this.MONTANT_ACHAT = 0; /*ascii value*/
    this.ARTICLE = 0;
    this.A_VALIDER = 0;
    this.ACTION = 2;	
    this.PARAMS = new Array();
    this.HOST = '';	

    /*Fonctions*/
    this.setAmount = setAmount;
    this.setId = setId;
    this.setClient = setClient;
    this.setQuantity = setQuantity;
    this.setPostValidation = setPostValidation;
    this.setHost = setHost;
    this.getURL = getURL;
    this.addParam = addParam;
    this.execute = execute;
}

function setAmount(_PRICE){this.MONTANT_ACHAT = _PRICE;}
function setId(_ID){this.ID_ACHAT = _ID;}
function setClient(_ID){this.ID_CLIENT = _ID;}
function setQuantity(_NB){this.ARTICLE = _NB;}
function setPostValidation(_V){this.A_VALIDER = _V;}
function setHost(_H){this.HOST = _H;}
function addParam(_K,_V){this.PARAMS.push(new performanceParam(_K, _V));}

function getURL() {
    var wbs_da = new Date(), WEBO_CONNEXION = '', wbs_arg = '';
    wbs_da = parseInt(wbs_da.getTime()/1000 - 60*wbs_da.getTimezoneOffset());

    /*Connection type auto detection : HTTP ou HTTPS*/
    if (this.HOST != '')
        WEBO_CONNEXION = ((location.protocol == 'https:')?"https://":"http://")+this.HOST;
    else {
        WEBO_CONNEXION = ((location.protocol == 'https:')?"https://ssl":"http://perf")+WPERF_SERVER;
    }

    wbs_arg = WEBO_CONNEXION + WPERF_PRGM + "?ID=" + this.FID_SITE + "&A=" + this.ACTION;
    wbs_arg += "&TR=" + this.ID_TRANSFO;

    if (this.ID_CLIENT != null && this.ID_CLIENT != 0){wbs_arg += "&CL=" + escape(this.ID_CLIENT);}
    if (this.ID_ACHAT != null && this.ID_ACHAT != 0){wbs_arg += "&AC=" + escape(this.ID_ACHAT);}
    if (this.MONTANT_ACHAT != null && this.MONTANT_ACHAT != 0){wbs_arg += "&MA=" + escape(this.MONTANT_ACHAT);}
    if (this.ARTICLE != null && this.ARTICLE != 0){wbs_arg += "&AR=" + this.ARTICLE;}
    if (this.ID_PASSAGE != null){wbs_arg += "&PT=" + this.ID_PASSAGE;}
    if (this.ID_SCENARIO != null){wbs_arg += "&SC=" + this.ID_SCENARIO;}
    if (this.A_VALIDER != null){wbs_arg += "&AV=" + this.A_VALIDER;}
    wbs_arg += '&H=I';
    wbs_arg += '&J=' + JS_TAG_VERSION;
    wbs_arg += "&da=" + wbs_da; 
    if (this.PARAMS && this.PARAMS.length) {
        wbs_arg += "&OPT=";
        for(i = 0; i < this.PARAMS.length; i++) {
            wbs_arg += escape(this.PARAMS[i].key)+':'+escape(this.PARAMS[i].value)+';';
        }
    }
    return wbs_arg;
}

function execute() {
    try {
        var wbo_ifrm = document.createElement('IFRAME'), bodyRef = document.getElementsByTagName('body').item(0) || document.documentElement.childNodes[0];
        wbo_ifrm.style.width=wbo_ifrm.style.height='1px';
        wbo_ifrm.style.border='0px';
        wbo_ifrm.style.position='absolute';
        wbo_ifrm.style.display='none';
        wbo_ifrm.style.top=wbo_ifrm.style.left='0px';
        wbo_ifrm.style.zIndex=0;
        wbo_ifrm.src=this.getURL();
        if (bodyRef.firstChild != null) {
            bodyRef.insertBefore(wbo_ifrm, bodyRef.firstChild);
        } else {
            bodyRef.appendChild(wbo_ifrm);
        }
    } catch (e) {
        document.write("<iframe src='"+this.getURL()+"' width=1 height=1 frameborder=0 style='border:0px'><\/iframe>");
    }
}

/*Weboscope performance ON/OFF*/

webo_performance = 1;

//-->
