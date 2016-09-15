loadDir("conf/syncCertaHistoricPlan.d");
CfgLogSyncMin = 0; //U: minima revision que sincronizamos, si no queremos empezar de la primera
CfgLogSyncDeltaMax = 1; //U: maxima cantidad de versiones a extraer por ejecucion

CfgReprDbPfx = "../repr_db_certa_txt/repr_db_certa_txt_historic/"; //U: pegar ANTES del nombre de archivo con el query
CfgDeltaDir = "../var/data/certa_deltas_historic"; //U: carpeta donde se guardan los archivos con datos extraidos
CfgDeltaPfx = "h_";
CfgLogIdPath= "../var/run/extraeCerta_h_logid.cnt"; //U: archivo donde guardamos el ultimo logid extraido
CfgCentinelPath= "../var/run/extraeCerta_h_finalizado"; //U: archivo que indica que ya no hay novedades

load("conf/syncGroupBy.js"); //para especificar las tablas que necesitan hacer un group by
hasGroupBy = true;
