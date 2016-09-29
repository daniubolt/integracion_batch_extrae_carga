
load("syncExtrae.js");
load("../conf/db.certa.js"); //A: configuramos la cx a la db
load("../conf/syncCertaExtractHistoricCFG.js"); //A: cargamos el plan
loadDir("../conf/plan.d"); //A: carga el directorio de plan de ejecucion
load("../conf/syncGroupBy.js"); //para especificar las tablas que necesitan hacer un group by


syncExtraer(CfgSyncPlan); //A: ejecutamos extraer con el plan definido
