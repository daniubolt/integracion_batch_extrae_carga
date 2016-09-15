RTLIB.push("../integracion_batch"); //A: encuentra syncExtrae.js
load("syncExtrae.js");

load("../conf/db.certa.js"); //A: configuramos la cx a la db
load("conf/syncCertaExtractHistoricPlan.js"); //A: cargamos el plan

syncExtraer(CfgSyncPlan); //A: ejecutamos extraer con el plan definido
