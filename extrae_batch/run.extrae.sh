#!/bin/sh

#INFO: se puede llamar este archivo cada 5min desde cron para que se ocupe de toda la sincronizacion, rtUnaInstancia garantiza que si ya hay una instancia de un script no se lanza otra del mismo

MY_DIR="$( cd "$( dirname "$0" )" && pwd )"
RT_DIR="$( cd "$MY_DIR/../rt_java_run" && pwd )"

cd $MY_DIR

#Trae novedades de certa
$RT_DIR/rtUnaInstancia SyncExtraeCerta $MY_DIR syncExtraeCerta.js 
#Impacta novedades en el nuevo modelo
#$RT_DIR/rtUnaInstancia SyncCargaPmMapa $MY_DIR syncCargaMapa.js 
#Busca notas nuevas en el navegador
#$RT_DIR/rtUnaInstancia SyncExtraeNotaMapa $MY_DIR syncExtraeNotaDeMapa.js
#Impacta novedades en el nuevo modelo
#$RT_DIR/rtUnaInstancia SyncCargaNotaCerta $MY_DIR syncCargaNotaEnCerta.js

#XXX:avisarle a viz_mapa?
