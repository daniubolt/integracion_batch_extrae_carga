//INFO: extrae datos para sincronizar la replica que usamos para dibujar los mapas, ejecutar ej. con cron en un servidor con acceso a CERTA
load("libsync.js");

//*****************************************************************************
//S: CFG defaults
CfgFile= ARGV[1] || "../conf/extrae.certa.js" //U: path al archivo de configuracion, puede redefinir TODO!
CfgCx= { url: "CONFIGURAR DB URL", user: "CONFIGURAR DB USER", pass: "CONFIGURAR DB PASS" };
//CfgDeltaPfx= new Date().getTime(); //U: se pega ANTES del nombre de cada archivo de datos extraidos
CfgDeltaPfx= "x_";
CfgOnlyVersioned= false; //U: si es true solo se extraeran las tablas que tienen filtro por logid, pero OJO que eso no incluiria cambios en las de iconos, entidades, etc.
CfgOnlyLastVersion= false; //Solo tomar la ultima revision, sin bajas. NFO: El filtro de vigentes esta actualmente en los queries

CfgTestRowCntMax= -1; //U: si es 0 o mas solo extrae esa cant de filas por tabla (para probar rapido)
CfgTestNoDb= false; //U: Para PRUEBAS, no conectarse a la base de datos
CfgAppendSql= ""; //U: Para PRUEBAS, agregar al WHERE ej "ROWNUM<10"
CfgPlanStepFrom= 0; //U: Para PRUEBAS, saltear los primeros pasos del plan
CfgPlanStepTo= -1; //U: Para PRUEBAS, parar antes del final del plan

CfgQueryForLogIds= "logIdMinMax.query"; //Query que se utilizará para obtener el maximo y el minimo logid de la base de datos

//A: defaults de configuracion definidos
//=============================================================================
syncExtraerCfgLoad= function () {
	CxCfgFile= get_env("CXCFG");
	if (CxCfgFile) { 
		logm("NFO", 1, "SYNC EXTRAE CX CONFIG LOAD", CxCfgFile);
		load(CxCfgFile);
	}

	load(CfgFile);
}

//A: configuracion actualizada desde archivo
//=============================================================================
syncExtraer= function (plan) {
 
	logm("NFO", 1, "SYNC EXTRAE CONFIG LOAD", CfgFile);

	var groupByObj ;
	
	logm("NFO", 1, "SYNC EXTRAE CONFIG READY", { plan: plan });
	ensure_dir(CfgDeltaDir); //A: el dir para escribir los deltas existe
/////////////
	var lastFile ={
	}
	var hayParaExtraer
	var logId_sync_anterior;
	var logId_sync_actual;
	
	if(exists_file(cfgLastFile)){

		var lines = get_file(cfgLastFile).split('\n');
		var lastLogId = lines[0].split(':');
		//ya corrio el gestor 

		logId_sync_actual=lastLogId[1].trim();
		logId_sync_anterior = contador_file(CfgLogIdPath, 0);
		
		if(logId_sync_anterior!=logId_sync_actual){
			hayParaExtraer=true;
		}
	}

	logm("NFO", 1, "SYNC EXTRAE LAST LOG ID", { last: logId_sync_actual });

///////////	
	/*var logId_sync_anterior= Math.max(contador_file(CfgLogIdPath, 0), CfgLogSyncMin);
	//A: logId_sync_anterior tiene el ultimo que extrajimos o el configurado como minimo
	
	var logIdSts= dbQueryFirstKv(cx(), reprDbSqlFor(CfgQueryForLogIds, CfgReprDbPfx));
	//A: logIdSts tiene los ultimos de la base

	var logId_sync_actual;
	if (logId_sync_anterior == 0) {
		logId_sync_actual= (CfgLogSyncDeltaMax > 0) ? Math.min(CfgLogSyncDeltaMax, logIdSts.maximo) : logIdSts.maximo ;
	} else if (CfgLogSyncDeltaMax > 0) {
		logId_sync_actual= Math.min(logId_sync_anterior + CfgLogSyncDeltaMax, parseInt(logIdSts.maximo)); 
	} else {
		logId_sync_actual= logIdSts.maximo;
	}*/
	//A: logId_sync_actual tiene el nro hasta el que tenemos que sincronizar

	var manifest= {
		files: {},
		logIdMax: logId_sync_actual,
		logIdMin: logId_sync_anterior
	};
	//A: tenemos un "manifest" por default, para poner la lista de archivos extraidos que el que carga debe  sincronizar todos juntos o ninguno, en que version necesita estar antes y en cual va a quedar despues

	var manifestCfg= syncStdManifestCfg("InProgress", CfgDeltaDir, CfgDeltaPfx);
	if (exists_file(manifestCfg.outPath)) {
		logm("NFO", 3, "SYNC EXTRAE MANIFEST InProgress ENCONTRADO", manifestCfg);
		manifest= JSON.parse(get_file(manifestCfg.outPath));
		logm("NFO", 7, "SYNC EXTRAE MANIFEST InProgress DATA", { manifestCfg: manifestCfg, manifest: manifest});
		if (logId_sync_actual!= manifest.logIdMax) {
			logm("ERR", 1, "SYNC EXTRAE MANIFEST InProgress maximo logId NO COINCIDE con el guardado en archivo", { esperado: logId_sync_actual, enElManifest: manifest.logIdMax, manifestCfg: manifestCfg, manifest: manifest});
		}
	}
	//A: si ya estaba en el medio de una extraccion que se interrumpio, cargue el manifest para seguir desde donde habia dejado

	//var hayParaExtraer= logId_sync_anterior < logId_sync_actual;

	cfgParams= {
		hayParaExtraer: hayParaExtraer,
		logId_sync_anterior: logId_sync_anterior,
		logId_sync_actual: logId_sync_actual,
		logIdDbMin: logId_sync_anterior + "",
		logIdDbMax: logId_sync_actual + "",
		CfgSyncPlan: CfgSyncPlan
	};
	logm("NFO", 1, "SYNC EXTRAE PARAMS READY", cfgParams);

	//A: todos los parametros para esta ejecucion estan cargados
	//=============================================================================
	if (hayParaExtraer) {
			pasosPendientes= []; //U: si no logramos extraer algun paso lo ponemos aca

			if (!CfgTestNoDb) {
					dbTxAutoCommit(cx(), false);
					cx().setTransactionIsolation(cx().TRANSACTION_READ_COMMITTED);
			}
			//A: en una transaccion, para leer versiones inconsistentes de la base

			var planStepTo= CfgPlanStepTo >= 0 ? CfgPlanStepTo + 1 : plan.length;
			logm("DBG",5,"SYNC EXTRAE PASOS", {pasoDesde: CfgPlanStepFrom, pasoHasta: planStepTo, plan: plan});

			var noManifest= true;
			for (var i= CfgPlanStepFrom; i < planStepTo; i++) {
				var stepFile= plan[i];
				var groupByForStep=null;

				if(hasGroupBy){	
					groupByForStep={}				
					var stepArr = stepFile.split('.');					
					var key = stepArr[0];

					if(cfgGroupBy[key]){
						groupByForStep = cfgGroupBy[key];		
						logm("DBG",4,"GROUP FOR STEP:",groupByForStep);	
					}else{
						groupByForStep=null;
					}
				}
				
				//XXX: cambiar por un filtro en plan.
				if ((plan[i].search("deleted") == -1 && CfgOnlyLastVersion) || !CfgOnlyLastVersion) {
					if (manifest.files[stepFile] && exists_file(CfgDeltaDir + "/" + manifest.files[stepFile].fname)) {
						logm("DBG", 3, "SYNC EXTRAE PASO YA ESTABA COMPLETO", { idx: i, paso: stepFile, datosManifest: manifest.files[stepFile] });
					} else { //A: no esta el archivo correspondiente a este paso
						logm("DBG", 3, "SYNC EXTRAE PASO COMIENZA", { idx: i, paso: stepFile, path: CfgReprDbPfx + plan[i], });
						try {
							var r= syncStd(
									logId_sync_actual, //U: logId MAXIMO se pondra en el nombre de archivo
									CfgReprDbPfx + plan[i],//U: path
									CfgDeltaDir,
									CfgDeltaPfx, 
									{ logidsyncmin: logId_sync_anterior, logidsyncmax: logId_sync_actual },
									CfgAppendSql,
									CfgTestNoDb,
									CfgOnlyVersioned && (logId_sync_anterior > 0),
									CfgTestRowCntMax || -1,
									groupByForStep
							);
							//A: extrajimos los datos en el archivo, incluimos el logId maximo en el nombre

							manifest.files[stepFile]= r;
							syncStdManifest("InProgress", manifest, CfgDeltaDir, CfgDeltaPfx);
							logm("NFO", 3, "SYNC EXTRAE PASO COMPLETADO", r);
							noManifest= false;
						} catch (ex) {
							pasosPendientes.push({ paso: stepFile, idx: i });
							logmex("ERR", 1, "SYNC EXTRAE PASO", { step: i, query: stepFile, plan: plan }, ex);
						}
					}
					hasGroupBy=false;
				} 
				else { logm("NFO", 3, "SYNC EXTRAE PASO OMITIDO", plan[i]); }
				//A: termine de procesar UN paso
			}
			//A: recorrimos todos los pasos y o estaba el archivo o lo tratams de extraer
			cfgParams.PasosPendientes= pasosPendientes;
			if (pasosPendientes.length > 0) {
				logm("NFO", 1, "SYNC EXTRAE END, FALTAN PASOS", cfgParams); //XXX: CONFIG!
			} else {
				if (!noManifest) {
					manifestCfgOk= syncStdManifestCfg(logId_sync_actual, CfgDeltaDir, CfgDeltaPfx);
					move_file(manifestCfg.outPath, manifestCfgOk.outPath, true); //A: sobreescribir
					contador_file(CfgLogIdPath, logId_sync_actual, true);
					//A: actualizamos el contador para el proximo sync
				} else {
					logm("NFO", 1, "SYNC EXTRAE END, OK NADA PARA EXTRAER", cfgParams);
					contador_file(CfgCentinelPath, 1, true);
				}
			}
	} else {
		logm("NFO", 1, "SYNC EXTRAE END, OK NADA PARA EXTRAER 1", cfgParams);
		contador_file(CfgCentinelPath, 1, true);
	}
}
