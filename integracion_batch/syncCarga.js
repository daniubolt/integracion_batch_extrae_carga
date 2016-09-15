//INFO: carga las novedades recibidas en archivos a la replica que usamos para sincronizar los mapas, ejecutar ej. con CRON en un servidor cercano a la replica
load("libsync.js");

//*****************************************************************************
//S: CFG defaults
CfgFile= ARGV[1] || "../conf/carga.mapa..js" //U: path al archivo de configuracion, puede redefinir TODO!
CfgCx= { url: "CONFIGURAR DB URL", user: "CONFIGURAR DB USER", pass: "CONFIGURAR DB PASS"};
CfgDeltaDir= "../var/data/certa_deltas"; //U: carpeta donde se guardan los archivos con datos extraidos
CfgDeltaPfx= "x_"; //U: se pega ANTES del nombre de cada archivo de datos extraidos
CfgCargaLogIdFile= "../var/run/cargaMapa_logid.cnt"; //U: archivo donde guardamos el ultimo logid extraido

CfgManifestCntMax= 1; //U: maximo de manifests para cargar por corrida
CfgCommitAunqueHayaErrores= false; //U: guardar los datos aunque algunos fallen

CfgNoDb= false; //U: Para PRUEBAS, no conectarse a la base de datos
CfgAppendSql= ""; //U: Para PRUEBAS, agregar al WHERE ej "ROWNUM<10"
CfgPlanStepFrom= 0; //U: Para PRUEBAS, saltear los primeros pasos del plan
CfgPlanStepTo= -1; //U: Para PRUEBAS, parar antes del final del plan
CfgFilaNumMax= -1; //U: Para PRUEBAS, solo cargar algunas filas

CfgReprDbPfx= "../repr_db_mapa_txt/"; //U: pegar ANTES del nombre de archivo con el query

var cfgCallExtFile = false; //U: Boolean para hacer una llamada a un Jar externo en lugar de resolver localmente la impactación en el nuevo modelo
var cfgExternalJarPath; //U: Type: String - Ruta al Jar que se quiere llamar (ej: '/home/gismobile/jars/java.jar')
var cfgExternalJarPkg ; //Type: String - Package del Jar en donde se encuentra la clase con el método a invocar (ej: 'com.enerminds.bussiness.impl')
var cfgExternalJarClass; //Type: String - Class del Jar en donde se encuentro el método a invocar (ej: 'Anomaly' )
var cfgExternalJarMethod; //Type: String - Método del Jar que se quiere invocar
var logIdSyncMin; //Type: long - logId procesado la última vez
var logIdSyncMax; //Type: long - logId que se procesa en la corrida actual.
var CfgIsFirstImport = false; //U: Si es verdadero no se procesa ninguna lista de elementos para ELIMINAR, porque es la primera carga
var CfgCalculatePolygon = true;
//A: defaults de configuracion definidos
//=============================================================================

//*****************************************************************************
//S: recorrer CSV
foldkv_file_csv= function (path,cb,acc,digestCalc,isGzip) {
	var names= null; var row= 0;
	return fold_file_csv(path,function (cols) {
		if (!names) { names= cols.map(function (k) { return k.toLowerCase() }); }
		else { 
			var val = zipkv(names,cols); 
			logm("DBG",9,"CSV ROW VAL",{row: row, val: val});
			acc= cb(val);
			row++;
		}
		return acc;
	},acc,digestCalc,isGzip);
}

dbExecEach_csv= function (path,sql,digestCalc,theCx,datosParaLog,pointsAcc) {
	datosParaLog= datosParaLog || {};
	datosParaLog.msj= datosParaLog.msj || "DB dbExecEach_csv FILA";
	datosParaLog.path= datosParaLog.path || path;
    
	var filaNum= 0;
	var logLvlOld= set_logLvlMax(5);
	//fold_file_csv=function (file,cb,acc,digestCalc,isGzip) 
	try { 
		foldkv_file_csv(path,function (paramsKv) {
			if (CfgFilaNumMax<0 || filaNum<CfgFilaNumMax) {
				if(pointsAcc && paramsKv["x"]!=null){ pointsAcc.push(paramsKv); }
				var cnt= dbExec(theCx,sql,paramsKv); 
				datosParaLog.paramsKv= paramsKv;
				datosParaLog.filaNum= filaNum;
				logm("DBG",(filaNum % 1000)==0 ? 3 : 9,datosParaLog.msj,datosParaLog);
			} 
			else { throw("FILA_NUM"); } //A: cada N CfgFilaNumMax salimos del ciclo y empezamos un nuevo con este throw
			filaNum++;
			//XXX: atajar excepcion de key violation?
		},"",digestCalc,true); 
	} catch (ex) {
		set_logLvlMax(logLvlOld);
		if (ex!="FILA_NUM") { throw(ex); }
	}
	set_logLvlMax(logLvlOld);
}

//*****************************************************************************
//S: calcular tiles afectados
var pointsAcc= CfgIsFirstImport ? null : {
	push: function(kv){ this.count++; data[kv.x+"_"+kv.y]=1; },
	data: {}, 
	count: 0,
};

//*****************************************************************************
//S: empieza el proceso

function cargarParaManifest(plan,manifestFile,logId) {
	logm("NFO",3,"SYNC PARA MANIFEST",{manifestFile: manifestFile, logId: logId});
	var manifest= JSON.parse(get_file(CfgDeltaDir+"/"+manifestFile));	
	logm("NFO",7,"SYNC PARA MANIFEST DATA",{manifestFile: manifestFile, logId: logId,manifest: manifest});

	var theCx= cx();
	dbTxAutoCommit(theCx,false);
	for (var i=0; i<plan.length; i++) {
		var pasoNombre= plan[i];
		var nfo= manifest.files[pasoNombre];
		logm("NFO",1,"SYNC previo al IF, DATOS:", {pasoNombre: pasoNombre, nfo: nfo});
		if ((!nfo) || nfo.cnt==0) {
			logm("NFO",1,"SYNC PASO LISTO, no hay datos nuevos", {pasoNombre: pasoNombre, index: i, manifest_info: nfo});
		}
		else {
			var path= nfo ? CfgDeltaDir+"/"+nfo.fname : "ERROR:MISSING";
			logm("NFO",1,"SYNC PASO START", {pasoNombre: pasoNombre, index: i, path: path, manifest_info: nfo});
			try {
				var pasoNombreAnt =pasoNombre;
				/**OJO CON ESTA NEGRADA!!**///
				var pasoNombreOk= pasoNombre.replace(/GeoStreetPartVtx/,"GeoStreetVtx").replace(/CfgEntities/,"CfgEntityType").replace(/CfgAttrTypes/,"CfgAttrType").replace(/CfgAreaTypes/,"CfgAreaType"); //XXX:solucionarlo en Extrae
				var sqlNombre= pasoNombreOk.replace(/\.deleted/,".delete").replace(/\.created/,".insert");
				if (sqlNombre == pasoNombreOk) { sqlNombre= sqlNombre+".insert"; } //A: si la tabla se sincroniza entera y no por deltas, el sql para cargar filas se llama xyz.insert
				////**///
				
				if (CfgIsFirstImport && sqlNombre.indexOf(".delete") != -1 ) { continue; } //A: si es la primera vez que cargamos, no necesitamos ejecutar los comandos que borran, porque no hay nada para borrar

				if (cfgCallExtFile) { //A: LLAMA A UN JAR EXTERNO con los datos
					//XXX: ver, por que no usar lo que ya habia de js?
					var gzFilePath = CfgDeltaDir + "/" + nfo.fname;
					LibRt.executeMethodClass(cfgExternalJarPath, cfgExternalJarPkg, 
							cfgExternalJarClass, cfgExternalJarMethod, 
							gzFilePath, logIdSyncMin, logIdSyncMax);
				} else { //A: cargar via sql
					
					var sql= reprDbSqlFor(sqlNombre, CfgReprDbPfx);
					logm("DBG",1,"DB REPDB SQL",{sql: sql, pasoNombre: pasoNombre});
					//A: tengo el sql que inserta los datos nuevos o borra los que ya no van
					var digestCalc= LibRt.digestCalc("MD5");
					var datosParaLog= {pasoNombre: pasoNombre, pasoNum: i}

					dbExecEach_csv(path,sql,digestCalc,theCx,datosParaLog);
					//A: recorri todas las filas del archivo

					var digest= LibRt.digestHexStr(digestCalc)+"";
					if (digest!=nfo.digest) {
						logmAndThrow("ERR",1,"SYNC CANCELADO, el digest del archivo no coincide", {pasoNombre: pasoNombre, path: path, index: i, digest: digest, manifest_info: nfo});
					}

					logm("NFO",1,"SYNC PASO END", {pasoNombre: pasoNombre, path: path, index: i, digest: digest, manifest_info: nfo});
				}
			} catch (ex) {
				//XXX: que hacemos si falla?
				logmex("ERR",1,"SYNC",{step: i, query: plan[i], plan: plan},ex);
				if (!CfgCommitAunqueHayaErrores) {
					dbTxRollback(theCx);
					throw(ex);
				}
			}
		}
	}
	//A: procese un delta completo sin errores, los digest coinciden con lo esperado, etc.
	dbTxCommit(theCx);
	contador_file(CfgCargaLogIdFile,logId,true);
	//A: guarde el logId en el contador para no procesarlo de nuevo
	//XXX:borrar lo que ya procese? o en otro proceso?
	return logId;
}

manifestsParaCargar= function () {
	var lastSyncLogId= contador_file(CfgCargaLogIdFile,0);
  logm("DBG", 1, "LAST_SYNC_ID FROM COUNTER FILE", lastSyncLogId);
	//A: tengo el ultimo logId que sincronice
	manifestList= get_filelist_newer_int(CfgDeltaDir,lastSyncLogId,/logId(\d+)_manifest.json/)
	logm("NFO",1,"SYNC FILES FOUND",manifestList);
	return manifestList;
}

/* syncCargaReplica
1. busca lo ultimo que sincronizo de un contador_file
2. recorre los manifest.json y si encuentra alguno NUEVO lo trate de cargar
3. si lo logra, actualiza el contador_file y se fija si encuentra otro mas para cargar, etc.
(por configuracion tambien podemos decidir si borra los archivos que ya uso)
*/
function syncCargaReplicaMapa(plan) {
	logm("NFO",1,"SYNC CargaReplica START");
	logm("NFO",1,"SYNC CARGA CONFIG READY",{plan: plan});
	manifestList= manifestsParaCargar();
	logm("NFO",2,"SYNC CargaReplica MANIFESTS para cargar", manifestList);
	var cnt= 0;
	for (var i= manifestList.newerIdx; (CfgManifestCntMax<0 || cnt<CfgManifestCntMax) && i<manifestList.files.length; i++) {
		var m= manifestList.files[i];
		var manifestFname=m[0];
		var manifestLogId=m[1];
		var r= cargarParaManifest(plan,manifestFname,manifestLogId);
		cnt++;
	}
	logm("NFO",1,"SYNC CargaReplica END");
}

if (ARGV[0]=="syncCarga.js") {
	CxCfgFile= get_env("CXCFG");
	if (CxCfgFile) { 
		logm("NFO", 1, "SYNC CARGA CX CONFIG LOAD", CxCfgFile);
		load(CxCfgFile);
	}
	logm("NFO",1,"SYNC CARGA CONFIG LOAD",CfgFile);
	load(CfgFile); 

	//A: configuracion actualizada desde archivo
	//=============================================================================

	syncCargaReplicaMapa(CfgSyncPlan);
}

