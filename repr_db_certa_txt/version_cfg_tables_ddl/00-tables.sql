--------------------------------------------------------
--  DDL for Table SPRSYMBRULES_H
--------------------------------------------------------

  CREATE TABLE "SPRSYMBRULES_H" 
   (	"RULEID" NUMBER(10,0), 
	"PROFILEID" NUMBER(5,0), 
	"SCALERANGEID" NUMBER(10,0), 
	"SPRID" NUMBER(5,0), 
	"PROVIDERNAME" VARCHAR2(255 BYTE), 
	"CONFIGSTRINGID" NUMBER(10,0), 
	"DRAWORDER" NUMBER(10,0), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRSTRINGCHUNKS_H
--------------------------------------------------------

  CREATE TABLE "SPRSTRINGCHUNKS_H" 
   (	"STRINGID" NUMBER(10,0), 
	"CHUNKORDER" NUMBER(5,0), 
	"STRINGCHUNK" VARCHAR2(255 BYTE), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRSYMBGSPARTVERTEX_H
--------------------------------------------------------

  CREATE TABLE "SPRSYMBGSPARTVERTEX_H" 
   (	"GSPARTVERTEXID" NUMBER(10,0), 
	"GSPARTID" NUMBER(10,0), 
	"ITEM" NUMBER(3,0), 
	"X" FLOAT(126), 
	"Y" FLOAT(126), 
	"BULGE" FLOAT(126), 
	"STARTWIDTH" FLOAT(126), 
	"ENDWIDTH" FLOAT(126), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRSYMBGSPART_H
--------------------------------------------------------

  CREATE TABLE "SPRSYMBGSPART_H" 
   (	"GSPARTID" NUMBER(10,0), 
	"GSID" NUMBER(10,0), 
	"ITEM" NUMBER(3,0), 
	"TYPE" NUMBER(3,0), 
	"FLAGS" NUMBER(10,0), 
	"COLOR" NUMBER(5,0), 
	"LINETYPE" VARCHAR2(32 BYTE), 
	"LINETYPEINFO" VARCHAR2(24 BYTE), 
	"DBL1" FLOAT(126), 
	"DBL2" FLOAT(126), 
	"DBL3" FLOAT(126), 
	"DBL4" FLOAT(126), 
	"DBL5" FLOAT(126), 
	"DBL6" FLOAT(126), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table NODEPOINTS_H
--------------------------------------------------------

  CREATE TABLE "NODEPOINTS_H" 
   (	"SPRID" NUMBER(5,0), 
	"NODEINDEX" NUMBER(5,0), 
	"X" FLOAT(126), 
	"Y" FLOAT(126), 
	"Z" FLOAT(126), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRSYMBGS_H
--------------------------------------------------------

  CREATE TABLE "SPRSYMBGS_H" 
   (	"GSID" NUMBER(10,0), 
	"CAPTION" VARCHAR2(255 BYTE), 
	"CATEGORYID" NUMBER(10,0), 
	"SCALE" FLOAT(126), 
	"TYPE" NUMBER(5,0), 
	"IMAGEPATH" VARCHAR2(255 BYTE), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRSYMBGSCAT_H
--------------------------------------------------------

  CREATE TABLE "SPRSYMBGSCAT_H" 
   (	"CATEGORYID" NUMBER(10,0), 
	"CAPTION" VARCHAR2(50 BYTE), 
	"PARENTCATEGORYID" NUMBER(10,0), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table CONTROLC
--------------------------------------------------------

  CREATE TABLE "CONTROLC" 
   (	"LOGID" NUMBER, 
	"FECHA" DATE, 
	"ENTIDAD" VARCHAR2(50 BYTE), 
	"ESTADO" NUMBER(1,0), 
	"FECHA_FIN" DATE, 
	"ID_ENTIDAD" NUMBER
   );
--------------------------------------------------------
--  DDL for Table AREAUSERGROUPS_H
--------------------------------------------------------

  CREATE TABLE "AREAUSERGROUPS_H" 
   (  "AREAID" NUMBER(10,0), 
  "USERGROUPID" NUMBER(5,0), 
  "PERMISSIONID" NUMBER(5,0), 
  "LOGIDFROM" NUMBER, 
  "LOGIDTO" NUMBER, 
  "DATEFROM" DATE, 
  "DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table USERS_H
--------------------------------------------------------

  CREATE TABLE "USERS_H" 
   (	"USERID" NUMBER(5,0), 
	"USERNAME" VARCHAR2(30 BYTE), 
	"USERPASSWORD" VARCHAR2(30 BYTE), 
	"USERFULLNAME" VARCHAR2(255 BYTE), 
	"LOGIDFROM" NUMBER(10,0), 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER(10,0), 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SMSTREETS_H
--------------------------------------------------------

  CREATE TABLE "SMSTREETS_H" 
   (	"STREETID" NUMBER(10,0), 
	"STREETANTIQ" NUMBER(5,0), 
	"STREETDELETED" NUMBER(5,0), 
	"STREETTYPEID" NUMBER(10,0), 
	"STREETNAME" VARCHAR2(50 BYTE), 
	"REGIONID" NUMBER(10,0), 
	"USERID" NUMBER(10,0), 
	"STREETSHORTNAME" VARCHAR2(12 BYTE), 
	"FSSTREETCODE" VARCHAR2(20 BYTE), 
	"LOGIDFROM" NUMBER, 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SMSTREETTYPES_H
--------------------------------------------------------

  CREATE TABLE "SMSTREETTYPES_H" 
   (	"STREETTYPEID" NUMBER(10,0), 
	"STREETTYPENAME" VARCHAR2(40 BYTE), 
	"NUMBERTYPEID" NUMBER(5,0), 
	"MAGCONVID" NUMBER(10,0), 
	"LOGIDFROM" NUMBER, 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table SPRENTITIES_H
--------------------------------------------------------

  CREATE TABLE "SPRENTITIES_H" 
   (	"SPRID" NUMBER(5,0), 
	"NETTYPEID" NUMBER(5,0), 
	"CATEGID" NUMBER(5,0), 
	"CAPTION" VARCHAR2(30 BYTE), 
	"ALIAS" VARCHAR2(5 BYTE), 
	"ENTITYTYPE" CHAR(1 BYTE), 
	"LAYER" VARCHAR2(31 BYTE),
	"PROPERTYID" NUMBER(5,0),
	"FLAGS" NUMBER(10,0),
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE, 
	"LOGIDFROM" NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table SMBLOCKFACADES_H
--------------------------------------------------------

  CREATE TABLE "SMBLOCKFACADES_H" 
   (	"BLOCKFACADEID" NUMBER(10,0), 
	"STREETID" NUMBER(10,0), 
	"BLOCKID" NUMBER(10,0), 
	"BLOCKVERINI" NUMBER(5,0), 
	"BLOCKVEREND" NUMBER(5,0), 
	"BLOCKFACADENUMINI" NUMBER(10,0), 
	"BLOCKFACADENUMEND" NUMBER(10,0), 
	"BLOCKINVERTNUM" NUMBER(5,0), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table NETTYPES_H
--------------------------------------------------------

  CREATE TABLE "NETTYPES_H" 
   (	"NETTYPEID" NUMBER(5,0), 
	"NETTYPECAPTION" VARCHAR2(30 BYTE), 
	"NETTYPEPREFIX" VARCHAR2(10 BYTE), 
	"NETTYPEPARENT" NUMBER(5,0), 
	"LOGIDFROM" NUMBER, 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table LINKS_H
--------------------------------------------------------

  CREATE TABLE "LINKS_H" 
   (	"LINKID" NUMBER(5,0), 
	"LINKCAPTION" VARCHAR2(30 BYTE), 
	"LINKTYPE" CHAR(1 BYTE), 
	"LINKVALIDATION" NUMBER(5,0), 
	"LINKMIN" VARCHAR2(20 BYTE), 
	"LINKMAX" VARCHAR2(20 BYTE), 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE, 
	"LOGIDFROM" NUMBER(10,0)
   );
--------------------------------------------------------
--  DDL for Table CATEGORIES_H
--------------------------------------------------------

  CREATE TABLE "CATEGORIES_H" 
   (	"CATEGID" NUMBER(5,0), 
	"NETTYPEID" NUMBER(5,0), 
	"CATEGCAPTION" VARCHAR2(30 BYTE), 
	"ENTITYTYPE" VARCHAR2(1 BYTE), 
	"LOGIDFROM" NUMBER, 
	"DATEFROM" DATE, 
	"LOGIDTO" NUMBER, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table AMPOLYGONS_H
--------------------------------------------------------

  CREATE TABLE "AMPOLYGONS_H" 
   (	"AREAID" NUMBER(10,0), 
	"POLYGONID" NUMBER(10,0), 
	"POLYGONADDSUB" NUMBER(5,0), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table AMPOLYGONGEO_H
--------------------------------------------------------

  CREATE TABLE "AMPOLYGONGEO_H" 
   (	"POLYGONID" NUMBER(10,0), 
	"POLYGONVERORDER" NUMBER(5,0), 
	"X" FLOAT(126), 
	"Y" FLOAT(126), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER
   );
--------------------------------------------------------
--  DDL for Table AMAREATYPES_H
--------------------------------------------------------

  CREATE TABLE "AMAREATYPES_H" 
   (	"AREATYPEID" NUMBER(10,0), 
	"AREATYPENAME" VARCHAR2(20 BYTE), 
	"SUPERAREATYPE" NUMBER(10,0), 
	"FSAREATYPECODE" VARCHAR2(20 BYTE), 
	"LOGIDFROM" NUMBER(10,0), 
	"LOGIDTO" NUMBER(10,0), 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table AMAREAS_H
--------------------------------------------------------

  CREATE TABLE "AMAREAS_H" 
   (	"AREAID" NUMBER(10,0), 
	"AREATYPEID" NUMBER(10,0), 
	"AREANAME" VARCHAR2(30 BYTE), 
	"AREASHORTNAME" VARCHAR2(12 BYTE), 
	"SUPERAREA" NUMBER(10,0), 
	"FSAREACODE" VARCHAR2(20 BYTE), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );

--------------------------------------------------------
--  DDL for Table USERGROUPS_H
--------------------------------------------------------

  CREATE TABLE "USERGROUPS_H" 
   (	"USERGROUPID" NUMBER(5,0), 
	"USERGROUPNAME" VARCHAR2(30 BYTE), 
	"USERGROUPFULLNAME" VARCHAR2(50 BYTE), 
	"FSUSERGROUPNAME" VARCHAR2(254 BYTE), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  DDL for Table USERUSERGROUPS_H
--------------------------------------------------------

  CREATE TABLE "USERUSERGROUPS_H" 
   (	"USERGROUPID" NUMBER(5,0), 
	"USERID" NUMBER(5,0), 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );

--------------------------------------------------------
--  DDL for Table GIS_DET_AREA_H
--------------------------------------------------------

  CREATE TABLE "GIS_DET_AREA_H" 
   (	"AREANAME" VARCHAR2(12 BYTE), 
	"CONSTR" VARCHAR2(12 BYTE), 
	"ALIMEN" VARCHAR2(12 BYTE), 
	"PELOS" NUMBER(5,0), 
	"BIDIREC" VARCHAR2(2 BYTE), 
	"NODOS" NUMBER(10,0), 
	"FECHA_HAB" DATE, 
	"DOC" VARCHAR2(12 BYTE), 
	"DISPO1" VARCHAR2(50 BYTE), 
	"DISPO2" VARCHAR2(50 BYTE), 
	"MANZANAS" NUMBER, 
	"VIVIENDAS" NUMBER, 
	"CLIENTES" NUMBER, 
	"ANCHO_BANDA" NUMBER(10,0), 
	"NSE_NODO" NUMBER, 
	"PARTIDO" NUMBER(10,0), 
	"LABEL_MGT" VARCHAR2(500 BYTE), 
	"VIV_RELEV" NUMBER(10,0), 
	"ORD_PORC" NUMBER(5,0), 
	"ZONA_COMERCIAL" VARCHAR2(4 BYTE), 
	"ZONA_UST" VARCHAR2(10 BYTE), 
	"SCHED_AREA" VARCHAR2(100 BYTE), 
	"DESCRIPCION" VARCHAR2(45 BYTE), 
	"CABLEMODEM" VARCHAR2(2 BYTE), 
	"RXO" VARCHAR2(12 BYTE), 
	"TECNICO_ID" NUMBER(10,0), 
	"FECHA_ALTA_CABLEMODEM" DATE, 
	"GRILLA_REDUCIDA" VARCHAR2(10 BYTE), 
	"FECHA_HAB_DIGITALIZADA" DATE, 
	"PLAN_DALVI" VARCHAR2(10 BYTE), 
	"EMPRESA" VARCHAR2(2 BYTE), 
	"RED" VARCHAR2(10 BYTE), 
	"FECHA_HAB_UNIFICACION" DATE, 
	"AGRUP_SUBNODO" VARCHAR2(4 BYTE), 
	"MARCA_IN" VARCHAR2(10 BYTE), 
	"CANAL_BARRIAL" VARCHAR2(10 BYTE), 
	"PHONE" VARCHAR2(2 BYTE), 
	"FECHA_HAB_PHONE" DATE, 
	"ESTADO" VARCHAR2(10 BYTE), 
	"AGRUP_DIRECTA" VARCHAR2(4 BYTE), 
	"FECHA_NORMAL_RED" DATE, 
	"TIPO_BIDIREC" VARCHAR2(2 BYTE), 
	"FECHA_CAMBIO_BIDIREC" DATE, 
	"VOD" VARCHAR2(3 BYTE), 
	"FECHA_CAMBIO_AB" DATE, 
	"FECHA_HAB_VOD" DATE, 
	"FECHA_CAMBIO_BIDIREC_OLD" DATE, 
	"TIPO_BIDIREC_OLD" VARCHAR2(2 BYTE), 
	"FECHA_HAB_PHONE_OLD" DATE, 
	"PHONE_OLD" VARCHAR2(2 BYTE), 
	"FECHA_HAB_DIGITALIZADA_OLD" DATE, 
	"GRILLA_REDUCIDA_OLD" VARCHAR2(2 BYTE), 
	"FECHA_CAMBIO_AB_OLD" DATE, 
	"PELOS_OLD" VARCHAR2(2 BYTE), 
	"ANCHO_BANDA_OLD" VARCHAR2(2 BYTE), 
	"VOD_OLD" VARCHAR2(3 BYTE), 
	"FECHA_HAB_VOD_OLD" DATE, 
	"VIABLE_2W" VARCHAR2(10 BYTE), 
	"TX_NODO" VARCHAR2(20 BYTE), 
	"PUERTO_APEX" VARCHAR2(20 BYTE), 
	"NODE_GROUP" NUMBER, 
	"OM_NODO" VARCHAR2(20 BYTE), 
	"ANTIGUEDAD_RED" DATE, 
	"APEX" VARCHAR2(20 BYTE), 
	"OM" VARCHAR2(50 BYTE), 
	"MAX_VEL_ACC" NUMBER, 
	"FECHA_CAMBIO_VEL" DATE, 
	"MAX_VEL_ACC_OLD" NUMBER, 
	"LOGIDFROM" NUMBER, 
	"LOGIDTO" NUMBER, 
	"DATEFROM" DATE, 
	"DATETO" DATE
   );
--------------------------------------------------------
--  Constraints for Table GIS_DET_AREA_H
--------------------------------------------------------

  ALTER TABLE "GIS_DET_AREA_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "GIS_DET_AREA_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "GIS_DET_AREA_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
--------------------------------------------------------
--  DDL for Index AMPOLYGONS_H_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AMPOLYGONS_H_PK" ON "AMPOLYGONS_H" ("POLYGONID", "LOGIDTO");
--------------------------------------------------------
--  DDL for Index AMPOLYGONGEO_H_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AMPOLYGONGEO_H_PK" ON "AMPOLYGONGEO_H" ("POLYGONID", "LOGIDTO", "POLYGONVERORDER");
--------------------------------------------------------
--  DDL for Index AMAREATYPES_H_PK
--------------------------------------------------------

  CREATE INDEX "AMAREATYPES_H_PK" ON "AMAREATYPES_H" ("AREATYPEID", "LOGIDTO");
--------------------------------------------------------
--  DDL for Index AMAREAS_H_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AMAREAS_H_PK" ON "AMAREAS_H" ("AREAID", "LOGIDTO");
--------------------------------------------------------
--  Constraints for Table USERS_H
--------------------------------------------------------

  ALTER TABLE "USERS_H" MODIFY ("USERID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SMSTREETS_H
--------------------------------------------------------

  ALTER TABLE "SMSTREETS_H" MODIFY ("STREETNAME" NOT NULL ENABLE);
  ALTER TABLE "SMSTREETS_H" MODIFY ("STREETANTIQ" NOT NULL ENABLE);
  ALTER TABLE "SMSTREETS_H" MODIFY ("STREETID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SMSTREETTYPES_H
--------------------------------------------------------

  ALTER TABLE "SMSTREETTYPES_H" MODIFY ("STREETTYPEID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRENTITIES_H
--------------------------------------------------------

  ALTER TABLE "SPRENTITIES_H" MODIFY ("SPRID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SMBLOCKFACADES_H
--------------------------------------------------------

  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKFACADENUMEND" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKFACADENUMINI" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKVEREND" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKVERINI" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKID" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("STREETID" NOT NULL ENABLE);
  ALTER TABLE "SMBLOCKFACADES_H" MODIFY ("BLOCKFACADEID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table NETTYPES_H
--------------------------------------------------------

  ALTER TABLE "NETTYPES_H" MODIFY ("NETTYPEID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table LINKS_H
--------------------------------------------------------

  ALTER TABLE "LINKS_H" MODIFY ("LINKID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table CATEGORIES_H
--------------------------------------------------------

  ALTER TABLE "CATEGORIES_H" MODIFY ("CATEGID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table AMPOLYGONS_H
--------------------------------------------------------

  ALTER TABLE "AMPOLYGONS_H" ADD CONSTRAINT "AMPOLYGONS_H_PK" PRIMARY KEY ("POLYGONID", "LOGIDTO");
  ALTER TABLE "AMPOLYGONS_H" MODIFY ("POLYGONADDSUB" NOT NULL ENABLE);
  ALTER TABLE "AMPOLYGONS_H" MODIFY ("POLYGONID" NOT NULL ENABLE);
  ALTER TABLE "AMPOLYGONS_H" MODIFY ("AREAID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table AMPOLYGONGEO_H
--------------------------------------------------------

  ALTER TABLE "AMPOLYGONGEO_H" ADD CONSTRAINT "AMPOLYGONGEO_H_PK" PRIMARY KEY ("POLYGONID", "LOGIDTO", "POLYGONVERORDER");
  ALTER TABLE "AMPOLYGONGEO_H" MODIFY ("Y" NOT NULL ENABLE);
  ALTER TABLE "AMPOLYGONGEO_H" MODIFY ("X" NOT NULL ENABLE);
  ALTER TABLE "AMPOLYGONGEO_H" MODIFY ("POLYGONVERORDER" NOT NULL ENABLE);
  ALTER TABLE "AMPOLYGONGEO_H" MODIFY ("POLYGONID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table AMAREATYPES_H
--------------------------------------------------------

  ALTER TABLE "AMAREATYPES_H" MODIFY ("SUPERAREATYPE" NOT NULL ENABLE);
  ALTER TABLE "AMAREATYPES_H" MODIFY ("AREATYPENAME" NOT NULL ENABLE);
  ALTER TABLE "AMAREATYPES_H" MODIFY ("AREATYPEID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table AMAREAS_H
--------------------------------------------------------

  ALTER TABLE "AMAREAS_H" ADD CONSTRAINT "AMAREAS_H_PK" PRIMARY KEY ("AREAID", "LOGIDTO");
  ALTER TABLE "AMAREAS_H" MODIFY ("SUPERAREA" NOT NULL ENABLE);
  ALTER TABLE "AMAREAS_H" MODIFY ("AREANAME" NOT NULL ENABLE);
  ALTER TABLE "AMAREAS_H" MODIFY ("AREATYPEID" NOT NULL ENABLE);
  ALTER TABLE "AMAREAS_H" MODIFY ("AREAID" NOT NULL ENABLE);

--------------------------------------------------------
--  Constraints for Table USERUSERGROUPS_H
--------------------------------------------------------

  ALTER TABLE "USERUSERGROUPS_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "USERUSERGROUPS_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "USERUSERGROUPS_H" MODIFY ("USERID" NOT NULL ENABLE);
  ALTER TABLE "USERUSERGROUPS_H" MODIFY ("USERGROUPID" NOT NULL ENABLE);

--------------------------------------------------------
--  Constraints for Table USERGROUPS_H
--------------------------------------------------------

  ALTER TABLE "USERGROUPS_H" MODIFY ("USERGROUPID" NOT NULL ENABLE);

--------------------------------------------------------
--  Constraints for Table AREAUSERGROUPS_H
--------------------------------------------------------

  ALTER TABLE "AREAUSERGROUPS_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "AREAUSERGROUPS_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "AREAUSERGROUPS_H" MODIFY ("PERMISSIONID" NOT NULL ENABLE);
  ALTER TABLE "AREAUSERGROUPS_H" MODIFY ("USERGROUPID" NOT NULL ENABLE);
  ALTER TABLE "AREAUSERGROUPS_H" MODIFY ("AREAID" NOT NULL ENABLE);

--------------------------------------------------------
--  DDL for Index CONTROLC_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "CONTROLC_PK" ON "CONTROLC" ("LOGID") ;
--------------------------------------------------------
--  Constraints for Table CONTROLC
--------------------------------------------------------

  ALTER TABLE "CONTROLC" ADD CONSTRAINT "CONTROLC_PK" PRIMARY KEY ("LOGID");
  ALTER TABLE "CONTROLC" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "CONTROLC" MODIFY ("ENTIDAD" NOT NULL ENABLE);
  ALTER TABLE "CONTROLC" MODIFY ("FECHA" NOT NULL ENABLE);
  ALTER TABLE "CONTROLC" MODIFY ("LOGID" NOT NULL ENABLE);
  --------------------------------------------------------
--  Constraints for Table SPRSYMBGSCAT_H
--------------------------------------------------------

  ALTER TABLE "SPRSYMBGSCAT_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSCAT_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSCAT_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSCAT_H" MODIFY ("CAPTION" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSCAT_H" MODIFY ("CATEGORYID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRSYMBGS_H
--------------------------------------------------------

  ALTER TABLE "SPRSYMBGS_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("TYPE" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("CATEGORYID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("CAPTION" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGS_H" MODIFY ("GSID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table NODEPOINTS_H
--------------------------------------------------------

  ALTER TABLE "NODEPOINTS_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "NODEPOINTS_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "NODEPOINTS_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "NODEPOINTS_H" MODIFY ("NODEINDEX" NOT NULL ENABLE);
  ALTER TABLE "NODEPOINTS_H" MODIFY ("SPRID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRSYMBGSPART_H
--------------------------------------------------------

  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("ITEM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("GSID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPART_H" MODIFY ("GSPARTID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRSYMBGSPARTVERTEX_H
--------------------------------------------------------

  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("ITEM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("GSPARTID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBGSPARTVERTEX_H" MODIFY ("GSPARTVERTEXID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRSTRINGCHUNKS_H
--------------------------------------------------------

  ALTER TABLE "SPRSTRINGCHUNKS_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSTRINGCHUNKS_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSTRINGCHUNKS_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSTRINGCHUNKS_H" MODIFY ("CHUNKORDER" NOT NULL ENABLE);
  ALTER TABLE "SPRSTRINGCHUNKS_H" MODIFY ("STRINGID" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SPRSYMBRULES_H
--------------------------------------------------------

  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("DATEFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("LOGIDTO" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("LOGIDFROM" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("DRAWORDER" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("CONFIGSTRINGID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("PROVIDERNAME" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("SPRID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("SCALERANGEID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("PROFILEID" NOT NULL ENABLE);
  ALTER TABLE "SPRSYMBRULES_H" MODIFY ("RULEID" NOT NULL ENABLE);
