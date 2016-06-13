loadDir("conf/syncCertaHistoricPlan.d");
CfgDeltaDir = "../var/data/certa_deltas_historic"; //U: carpeta donde se guardan los archivos con datos extraidos
CfgDeltaPfx = "h_";
CfgLogIdPath = "../var/run/extraeCertaHistoric_logid.cnt"; //U: archivo donde guardamos el ultimo logid extraido
CfgLogSyncMin = 0; //U: minima revision que sincronizamos, si no queremos empezar de la primera
//XXX: La degradacion de la performance al modificar este valor aumenta exponencialmente
//Oculta el caso de revisiones con mucha carga de informacion (ex. LOGID=1)
CfgLogSyncDeltaMax = 1; //U: maxima cantidad de versiones a extraer por ejecucion
CfgReprDbPfx = "../repr_db_certa_txt/repr_db_certa_txt_historic/"; //U: pegar ANTES del nombre de archivo con el query
//para especificar las tablas que necesitan hacer un group by
load("conf/syncGroupBy.js");