RTLIB.push("../integracion_batch"); //A: encuentra syncCarga.js
load("syncCarga.js");

load("../conf/db.mapa.js"); //A: configuramos la cx a la db
load("conf/syncCertaExtrae.js"); //A: cargamos el plan

syncCargaReplicaMapa(CfgSyncPlan); //A: ejecutamos cargar con el plan definido

