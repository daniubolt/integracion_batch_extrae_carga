MY_DIR="$( cd "$( dirname "$0" )" && pwd )"
RT_DIR="$( cd "$MY_DIR/../rt_java_run" && pwd )"

cd $MY_DIR

#Trae novedades de certa
$RT_DIR/rtUnaInstancia_carga SyncCarga $MY_DIR syncCargaMapa.js 