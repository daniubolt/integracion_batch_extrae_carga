loadDir("conf/syncCerta.d");
CfgLogSyncDeltaMax = 1;
CfgLogSyncMin= 0 ;
CfgQueryForLogIds = "logIdMinMax.query";


CfgReprDbPfx = "../repr_db_certa_txt/"; //U: pegar ANTES del nombre de archivo con el query
CfgDeltaDir = "../var/data/certa_deltas/"; //U: carpeta donde se guardan los archivos con datos extraidos
CfgDeltaPfx = "h_";
CfgLogIdPath= "../var/run/extraeCerta_logid.cnt"; //U: archivo donde guardamos el ultimo logid extraido
CfgCentinelPath= "../var/run/extraeCerta_finalizado"; //U: archivo que indica que ya no hay novedades

hasGroupBy = false;