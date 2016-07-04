//INFO: funciones comodas para escribir planes de sincronizacion

//***************************************************************************
//S: cfg
CfgOutPfx="x_";
//set_logLvlMax(10);
//***************************************************************************
//S: db utils
cx_=null; //U: se crea una sola vez, PERO hay que poderla cerrar
cx= function () {
	cx_= cx_ || dbCx(CfgCx);
	return cx_;
}

//***************************************************************************
//S: sync plan
var CfgSyncPlan= [];
syncPlanAgregar= function(e) { CfgSyncPlan.push(e); }
syncPlanAgregarLista= function (l) { l.map(syncPlanAgregar); }

//***************************************************************************
//S: reprDb
reprDbSqlPathFor= function (name,reprDb) {
  return reprDb+"/"+name+".sql";
  //XXX:SEC devolver VACIO si no entendemos el caso!
}

ReprDbSqlCache= {};
reprDbSqlFor= function (name, reprDb) {
	var sqlPath= reprDbSqlPathFor(name, reprDb);
	var sql= ReprDbSqlCache[sqlPath];
	if (!sql) { sql= ReprDbSqlCache[sqlPath] || get_file(sqlPath); }

	if (CfgCx.url.match(/:h2:/)) { //XXX:esto es siempre? de que depende?
		sql= sql.replace(/TO_DATE/i,"PARSEDATETIME");
		sql= sql.replace("'YYYY-MM-DD HH24:MI:SS'","'yyyy-MM-dd HH:mm:ss'");	
	} 
	logm("DBG",1,"DB REPR SQL FOR",{name:name, reprDb: reprDb, sql: sql});
	return sql;
}
	
//***************************************************************************
//S: sync func
syncStdManifestCfg= function (logId,outDir,outPfx) {
	var fname= outPfx+"o_logId"+logId+"_manifest.json"; //XXX: otros casos de query a path 
	var cfg={
		fname: fname,
	  outPath: outDir+"/"+fname,
	};
	return cfg;
}

syncStdCfg= function (logId,queryName,outDir,outPfx,paramsKv,extraWhere) {
	var fname= outPfx+"o_logId"+logId+"_"+seguro_fname(queryName)+".csv.gz"; //XXX: otros casos de query a path 
	var cfg={
		sqlPath: queryName+".query.sql", //XXX:CFG //XXX:unificar con reprDbSqlFor
		fname: fname,
	  outPath: outDir+"/"+fname,
	};
	return cfg;
}

syncStdCfgSql= function (logId,queryName,outDir,outPfx,paramsKv,extraWhere) {
	var cfg= syncStdCfg(logId,queryName,outDir,outPfx,paramsKv,extraWhere);
	cfg.sql= cfg.sqlSrc= get_file(cfg.sqlPath);
	if (extraWhere) {
		cfg.sql= cfg.sqlSrc.match(/\s+WHERE\s+/i) ? 
			cfg.sqlSrc.replace(/\s+WHERE\s/i," WHERE "+extraWhere+" AND ") : 
			cfg.sqlSrc.match(/\s+(?:ORDER\s+BY)|(?:GROUP\s+BY)\s+/i) ?
				cfg.sqlSrc.replace(/\s+(?:ORDER\s+BY)|(?:GROUP\s+BY)\s+/i, function (m) { return(" WHERE "+extraWhere + m); }) :
				cfg.sqlSrc + " WHERE "+ extraWhere;
	}
	cfg.isVersioned= /SPRLOG/i.exec(cfg.sql)!=null; //XXX: generalize!!!
	return cfg;
}


syncStd= function (logId,queryName,outDir,outPfx,paramsKv,extraWhere,wantsNoDb,wantsOnlyVersioned,rowCntMax,group) {
	rowCntMax= rowCntMax || -1;

	var cfg= syncStdCfgSql(logId,queryName,outDir,outPfx,paramsKv,extraWhere); 
	logm("DBG",7,"DB REPDB SQL",cfg);
	var writer;
	var cnt= 0;
	if (wantsNoDb || (wantsOnlyVersioned && !cfg.isVersioned)) {//A: emulacion
		var digestCalc= LibRt.digestCalc("MD5");
		writer= LibRt.fileWriter(cfg.outPath,true,digestCalc); writer.write("");
	}
	else {
		var rs= dbQuery(cx(),cfg.sql,paramsKv); 
		var digestCalc= LibRt.digestCalc("MD5");
		if(group==null){
			
			writer= LibRt.fileWriter(cfg.outPath,true,digestCalc); writer.write("");
			logm("DBG",8,"SYNC TO CSV STEP got rs",{cfg: cfg, rsIsNull: rs==null, writerIsNull: writer==null});
			cnt= LibRt.serRsCsvToWriter(rs,null,writer,rowCntMax,"\t");
			rs.close();
			logm("DBG",7,"SYNC TO CSV STEP wrote", {cnt: cnt,queryName: queryName});
		}else{
			logm("DBG",7,"WITH GROUP BY",group);
			
			var writer= LibRt.fileWriterAppend(cfg.outPath,true,digestCalc);
			var por= group.campoPor;
			var agrupados = group.camposAgrupar;
			var nombreCampo = group.campoResultado
			
			cnt=LibRt.serDiccGroupByToWriter(rs,writer,rowCntMax,por,agrupados,nombreCampo);
			rs.close();
		}			
	}	
	writer.close();
	logm("DBG",1,"SYNC TO CSV DONE",cfg);
	return {cnt: cnt, fname: cfg.fname, outPath: cfg.outPath, digest: LibRt.digestHexStr(digestCalc)+"", query: queryName};
}

syncStdGroupBy= function (logId,queryName,outDir,outPfx,paramsKv,extraWhere,wantsNoDb,wantsOnlyVersioned,rowCntMax) {
	rowCntMax= rowCntMax || -1;

	var cfg= syncStdCfgSql(logId,queryName,outDir,outPfx,paramsKv,extraWhere); 
	logm("DBG",7,"DB REPDB SQL",cfg);
	
	var cnt= 0;
	if (wantsNoDb || (wantsOnlyVersioned && !cfg.isVersioned)) {//A: emulacion
		var digestCalc= LibRt.digestCalc("MD5");
		var writer= LibRt.fileWriter(cfg.outPath,true,digestCalc); writer.write("");
	}
	else {
		var rs= dbQuery(cx(),cfg.sql,paramsKv); 
		
		var digestCalc= LibRt.digestCalc("MD5");
		var writer= LibRt.fileWriterAppend(cfg.outPath,true,digestCalc); 
		
		if(writer==null){
			logm("DBG",1,"ESTA VACIO EL WRITER",{});
		}
		
		logm("DBG",1,"SYNC TO CSV STEP got rs",{cfg: cfg, rsIsNull: rs==null, writerIsNull: writer==null});
		
		logm("DBG",1,"APPEND REG",{});
		var id_actual = null;
		var geo = []; //[{x: ,y:}]
		var reg = {};
		
		var keys = [];
		var haveKeys = false; 
		var cantCol=0;
		while (d = dbNextRowKv(rs)) {
			
			if(id_actual==null){
				reg=clonar(d);
				logm("DBG",1,"REGISTRO 1",d);
				
				id_actual = d.id;
				reg.x=d.x;
				reg.y=d.y;	
				if(!haveKeys){
						var cols = "";
						for(var key in d){
							cols+=key+"\t";
							keys.push(cols);
							cantCol++;
						}
						
						cols+='geo';						
						LibRt.serDiccCsvToWriter(cols,writer,rowCntMax,"\t");						
						haveKeys=true;
				}
				
			}else{
				if(id_actual!=d.id){				
					reg.geo = geo;
					logm("DBG",1,"REGISTRO ",d);
						
					var str ="";
                    					
					logm("DBG",9,"QUE TIENE REG",d);
						
					for(var key in reg){				
						(function(key){
							logm("DBG",4,"VALOR:" ,reg[key]);
							str+=reg[key] + "\t";
						})(key)
					}
					
					str=str.substring(0,str.length-1);
					logm("DBG",9,"LINEA DESDE JS",str);
					cnt= LibRt.serDiccCsvToWriter(str,writer,rowCntMax,"\t");
					
					geo=[];
					reg={};
					
					id_actual = d.id;					
					reg=clonar(d);
					reg.x=d.x;
					reg.y=d.y;	
				}
			}
			geo.push(d.x);
			geo.push(d.y);
			
			//geo.push({"x":d.x,"y":d.y}); 		
		}
		
			reg.geo = geo;
			logm("DBG",1,"REGISTRO ",d);
			
			
			var str ="";
                  					
			logm("DBG",9,"QUE TIENE REG",d);
				
			for(var key in reg){				
				(function(key){
					logm("DBG",4,"VALOR:" ,reg[key]);
					str+=reg[key] + "\t";
				})(key)
						
			}
			
			//str+=reg.geo+ "\t";
			
			str=str.substring(0,str.length-1);
			logm("DBG",9,"LINEA DESDE JS",str);
			cnt= LibRt.serDiccCsvToWriter(str,writer,rowCntMax,"\t");	
		
			LibRt.closeWriterAppend(writer);
			rs.close();
			logm("DBG",7,"SYNC TO CSV STEP wrote", {cnt: cnt,queryName: queryName});
	}
	writer.close();
	logm("DBG",1,"SYNC TO CSV DONE",cfg);
	return {cnt: cnt, fname: cfg.fname, outPath: cfg.outPath, digest: LibRt.digestHexStr(digestCalc)+"", query: queryName};
}

syncStdManifest= function (logId,manifest,outDir,outPfx) {
	var cfg= syncStdManifestCfg(logId,outDir,outPfx);
	set_file(cfg.outPath,ser_json(manifest,true));
}
	

