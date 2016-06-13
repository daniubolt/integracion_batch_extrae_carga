//INFO: copia los archivos generados a la(s) replicas

load("libsync.js");

function syncCopiaAReplica() { //XXX: cfg como parametro?

	CfgCopiaLogIdFile="run_copiaAReplica1_logId.cnt";
	CfgDeltaDir="t_data_certaOut"; 
	CfgDeltaDir="t_data_deltas";
	CfgCopiaCmd="noexistecp {{CfgDeltaDir}}/{{fname}} {{CfgDstHostDir}}/{{fname}}"; //XXX:mover a caso de prueba que falla y entonces NO actualiza contador
	CfgCopiaCmd="cp {{CfgDeltaDir}}/{{fname}} {{CfgDstHostDir}}/{{fname}}"; //D: definir como vacio para usar scp interno
	CfgDstHostUrl="127.0.0.1";
	CfgDstHostUser="usr10";
	CfgDstHostPass= get_env("REPLICA_SSH_PASS") || "PoneTuClave";
	CfgDstHostDir="/tmp/replica1"; //XXX:OJO! debe existir!
	CfgPlanD="planCertaExtrae.d"; 
	load("conf/dev.certa.js"); 
	loadDir(CfgPlanD);
	//A: se definieron directorios de output, limites, etc.

	var ahora= new Date();
	var hora= ahora.getHours();
	var EMU_HORA= hora;
	logm("NFO",1,"SYNC COPIA START",{hora: hora});

	var plan= CfgSyncPlan;

	function copiarFile(nfo) {
		nfo.path= CfgDeltaDir+"/"+nfo.fname;
		logm("NFO",1,"SYNC FILE START", nfo);
		var cmdptpl= CfgCopiaCmd ? CfgCopiaCmd.split(/ +/) : null;	
		try {
			if (cmdptpl) { //A: usar comando del sistema
				var params= nfo;
				var cmdp= cmdptpl.map(function (p) { return p.replace(/{{([A-Za-z0-1]*)}}/g,function (m,k) { return params[k] || GLOBAL[k] || ""; }) });
				logm("DBG",1,"TPL",{tpl: cmdptpl, inst: cmdp});
				//XXX: mover a lib, emprolijar que se puede usar y que no, etc.
				//A: instanncie cmdp con variables de acuerdo a la plantilla
				var r= systemRun(cmdp);
				if (r!=0) {
					throw(new Exception("Comando fallo "+ser_json({tpl: cmdptpl, inst: cmdp})));
				}
			}
			else {
				LibRt.set_file_scp_pass(nfo.path,CfgDstHostUrl,CfgDstHostDir+"/"+nfo.fname,CfgDstHostUser,CfgDstHostPass);
			}
			//A: copie el archivo
			logm("NFO",1,"SYNC FILE END", nfo);
		}
		catch (ex) {
			//XXX: que hacemos si falla?
			logmex("ERR",1,"SYNC FILE",nfo,ex);
			throw(ex);
		}
	}

	function copiarFilesDelta(manifestPath,logId) {
		var manifest= JSON.parse(get_file(CfgDeltaDir+"/"+manifestPath));
		var files= manifest.files;
		for (var k in files) { var file= files[k];
			copiarFile(file);
		}
		//A: ya copie todos los archivos de datos pero NO manifest (que avisa que la copia esta completa)
		var fname= "x_"+"o_logId"+logId+"_manifest.json";
		copiarFile({fname: fname, name: "manifest"});
		//A: ya copie todos los archivos de datos Y manifest (que avisa que la copia esta completa)
		return logId;
	}

	logm("NFO",1,"SYNC de las 11am",{outPath: outPath, plan: plan});
	var lastSyncLogId= contador_file(CfgCopiaLogIdFile,0);
	//A: tengo el ultimo logId que sincronice

	manifestList= get_filelist_newer_int(CfgDeltaDir,lastSyncLogId,/logId(\d+)_manifest.json/)
	logm("NFO",1,"SYNC FILES FOUND",manifestList);
	for (var i= manifestList.newerIdx; i<manifestList.files.length; i++) {
		var m= manifestList.files[i];
		var fname= m[0];
		var logId= m[1];
		var r= copiarFilesDelta(fname,logId);
		//A: procese una delta completo 
		contador_file(CfgCopiaLogIdFile,logId,true);
		//A: guarde el logId en el contador para no procesarlo de nuevo
		//XXX:borrar lo que ya procese? o en otro proceso?
	}
	logm("NFO",1,"SYNC END",{hora: hora});
}

if (ARGV[0]=="syncCopiaAReplica.js") {
	syncCopiaAReplica();
}

