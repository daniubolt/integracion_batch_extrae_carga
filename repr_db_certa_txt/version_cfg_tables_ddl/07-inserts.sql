--------------------------------------------------------
--  FIRST INSERT AMAREAS_H
--------------------------------------------------------

INSERT INTO amAreas_h (areaId, areaTypeId, areaName, areaShortName, superArea, fsAreaCode, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT areaId, areaTypeId, areaName, areaShortName, superArea, fsAreaCode, 
1, 0, SYSDATE, null 
FROM amAreas;

--------------------------------------------------------
--  FIRST INSERT AMAREATYPES_H
--------------------------------------------------------

INSERT INTO amAreaTypes_h (areaTypeId, areaTypeName, superAreaType, fsAreaTypeCode, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT areaTypeId, areaTypeName, superAreaType, fsAreaTypeCode, 1, 0 , SYSDATE, null
FROM amAreaTypes;

--------------------------------------------------------
--  FIRST INSERT AMPOLYGONGEO_H
--------------------------------------------------------

INSERT INTO amPolygonGeo_h (polygonId, polygonVerOrder, x, y, logIdFrom, logIdTo)
SELECT polygonId, polygonVerOrder, x, y, 1, 0 
FROM amPolygonGeo;

--------------------------------------------------------
--  FIRST INSERT AMPOLYGONS_H
--------------------------------------------------------

INSERT INTO amPolygons_h (areaId, polygonId, polygonAddSub, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT areaId, polygonId, polygonAddSub, 1, 0, SYSDATE, null 
FROM amPolygons;

--------------------------------------------------------
--  FIRST INSERT CATEGORIES_H
--------------------------------------------------------

INSERT INTO categories_h (categId, netTypeId, categCaption, entityType, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT categId, netTypeId, categCaption, entityType, 1, 0, SYSDATE, null 
FROM categories;

--------------------------------------------------------
--  FIRST INSERT LINKS_H
--------------------------------------------------------

INSERT INTO links_h (linkId, linkCaption, linkType, linkValidation, linkMin, linkMax, 
logIdFrom, logIdTo, dateFrom, dateTo)
SELECT linkId, linkCaption, linkType, linkValidation, linkMin, linkMax, 1, 0, SYSDATE, null 
FROM links;

--------------------------------------------------------
--  FIRST INSERT NETTYPES_H
--------------------------------------------------------

INSERT INTO netTypes_h (netTypeId, netTypeCaption, netTypePrefix, netTypeParent, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT netTypeId, netTypeCaption, netTypePrefix, netTypeParent, 1, 0, SYSDATE, null 
FROM netTypes;

--------------------------------------------------------
--  FIRST INSERT SMBLOCKFACADES_H
--------------------------------------------------------

INSERT INTO smBlockFacades_h (blockFacadeId, streetId, blockId, blockVerIni, blockVerEnd, blockFacadeNumIni, 
blockFacadeNumEnd, blockInvertNum, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT blockFacadeId, streetId, blockId, blockVerIni, blockVerEnd, blockFacadeNumIni, 
blockFacadeNumEnd, blockInvertNum, 1, 0, SYSDATE, null 
FROM smBlockFacades;

--------------------------------------------------------
--  FIRST INSERT SMSTREETS_H
--------------------------------------------------------

INSERT INTO smStreets_h (streetId, streetAntiq, streetTypeId, streetName, regionId, streetShortName, 
fsStreetCode, streetDeleted, userid, logIdFrom, dateFrom, logIdTo, dateto )
SELECT streetId, streetAntiq, streetTypeId, streetName, regionId, streetShortName, fsStreetCode, streetDeleted, 
userid, 1 logIdFrom, dateFrom, CASE WHEN streetAntiq <> 0 OR streetDeleted=1 THEN 1 ELSE 0 END logIdTo, dateTo
FROM smStreets
WHERE streetAntiq = 0;

--------------------------------------------------------
--  FIRST INSERT SMSTREETTYPES_H
--------------------------------------------------------

INSERT INTO smStreetTypes_h (streetTypeId, streetTypeName, numberTypeId, magConvid, 
logIdFrom, logIdTo, dateFrom, dateTo)
SELECT streetTypeId, streetTypeName, numberTypeId, magConvid, 1, 0, SYSDATE, null 
FROM smStreetTypes;

--------------------------------------------------------
--  FIRST INSERT SPRENTITIES_H
--------------------------------------------------------

INSERT INTO sprEntities_h (sprId, netTypeId, categId, caption, alias, entityType, 
flags, propertyId, layer, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT sprId, netTypeId, categId, caption, alias, entityType, flags, propertyId, layer, 1, 0, SYSDATE, null 
FROM sprEntities;

--------------------------------------------------------
--  FIRST INSERT USERS_H
--------------------------------------------------------

INSERT INTO users_h (userId, userName, userPassword, userFullName, 
logIdFrom, logIdTo, dateFrom, dateTo)
SELECT userId, userName, userPassword, userFullName, 1, 0, SYSDATE, null 
FROM users;

--------------------------------------------------------
--  FIRST INSERT USERUSERGROUPS_H
--------------------------------------------------------

INSERT INTO userUserGroups_h (userGroupId, userId, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT userGroupId, userId, 1, 0, SYSDATE, null 
FROM userUserGroups;

--------------------------------------------------------
--  FIRST INSERT AREAUSERGROUPS_H
--------------------------------------------------------

INSERT INTO areaUserGroups_h (areaId, userGroupId, permissionId, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT areaId, userGroupId, permissionId, 1, 0, SYSDATE, null 
FROM areaUserGroups;

--------------------------------------------------------
--  FIRST INSERT USERGROUPS_H
--------------------------------------------------------

INSERT INTO userGroups_h (userGroupId, userGroupName, userGroupFullName, fsUserGroupName, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT userGroupId, userGroupName, userGroupFullName, fsUserGroupName, 1, 0, SYSDATE, null 
FROM userGroups;

--------------------------------------------------------
--  FIRST INSERT GIS_DET_AREA_H
--------------------------------------------------------

INSERT INTO gis_det_area_h (
areaname, constr, alimen, pelos, bidirec, nodos, fecha_hab, doc, dispo1, dispo2, manzanas, viviendas, clientes, 
ancho_banda, nse_nodo, partido, label_mgt, viv_relev, ord_porc, zona_comercial, zona_ust, sched_area, descripcion, 
cablemodem, rxo, tecnico_id, fecha_alta_cablemodem, grilla_reducida, fecha_hab_digitalizada, plan_dalvi, empresa, red, 
fecha_hab_unificacion, agrup_subnodo, marca_in, canal_barrial, phone, fecha_hab_phone, estado, agrup_directa, fecha_normal_red, 
tipo_bidirec, fecha_cambio_bidirec, vod, fecha_cambio_ab, fecha_hab_vod, fecha_cambio_bidirec_old, tipo_bidirec_old, 
fecha_hab_phone_old, phone_old, fecha_hab_digitalizada_old, grilla_reducida_old, fecha_cambio_ab_old, pelos_old, 
ancho_banda_old, vod_old, fecha_hab_vod_old, viable_2w, tx_nodo, puerto_apex, node_group, om_nodo, antiguedad_red, 
apex, om, max_vel_acc, fecha_cambio_vel, max_vel_acc_old, logIdFrom, logIdTo, dateFrom, dateTo ) 
SELECT areaname, constr, alimen, pelos, bidirec, nodos, fecha_hab, doc, dispo1, 
dispo2, manzanas, viviendas, clientes, ancho_banda, nse_nodo, partido, label_mgt,
viv_relev, ord_porc, zona_comercial, zona_ust, sched_area, descripcion, cablemodem,
rxo, tecnico_id, fecha_alta_cablemodem, grilla_reducida, fecha_hab_digitalizada, plan_dalvi, 
empresa, red, fecha_hab_unificacion, agrup_subnodo, marca_in, canal_barrial, phone,
fecha_hab_phone, estado, agrup_directa, fecha_normal_red, tipo_bidirec, fecha_cambio_bidirec, 
vod, fecha_cambio_ab, fecha_hab_vod, fecha_cambio_bidirec_old, tipo_bidirec_old, fecha_hab_phone_old, 
phone_old, fecha_hab_digitalizada_old, grilla_reducida_old, fecha_cambio_ab_old, pelos_old, 
ancho_banda_old, vod_old, fecha_hab_vod_old, viable_2w, tx_nodo, puerto_apex, 
node_group, om_nodo, antiguedad_red, apex, om, max_vel_acc, fecha_cambio_vel, 
max_vel_acc_old, 1, 0, SYSDATE, null 
FROM gis_det_area ;






INSERT INTO nodepoints_h (SPRID,
NODEINDEX,
X,
Y,
Z, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT SPRID,
NODEINDEX,
X,
Y,
Z, 
1, 0, SYSDATE, null 
FROM nodepoints ;




INSERT INTO sprstringchunks_h (STRINGID, CHUNKORDER, STRINGCHUNK, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT STRINGID, CHUNKORDER, STRINGCHUNK, 1, 0, SYSDATE, null 
FROM sprstringchunks;

INSERT INTO sprsymbgs_h (GSID,
CAPTION,
CATEGORYID,
SCALE,
TYPE,
IMAGEPATH, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT GSID,
CAPTION,
CATEGORYID,
SCALE,
TYPE,
IMAGEPATH, 1, 0, SYSDATE, null 
FROM sprsymbgs ;


INSERT INTO sprsymbgscat_h (CATEGORYID,
CAPTION,
PARENTCATEGORYID, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT CATEGORYID,
CAPTION,
PARENTCATEGORYID, 1, 0, SYSDATE, null 
FROM sprsymbgscat;


INSERT INTO sprsymbgspart_h (GSPARTID,
GSID,
ITEM,
TYPE,
FLAGS,
COLOR,
LINETYPE,
LINETYPEINFO,
DBL1,
DBL2,
DBL3,
DBL4,
DBL5,
DBL6, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT GSPARTID,
GSID,
ITEM,
TYPE,
FLAGS,
COLOR,
LINETYPE,
LINETYPEINFO,
DBL1,
DBL2,
DBL3,
DBL4,
DBL5,
DBL6, 1, 0, SYSDATE, null 
FROM sprsymbgspart ;



INSERT INTO sprsymbgspartvertex_h (GSPARTVERTEXID,
GSPARTID,
ITEM,
X,
Y,
BULGE,
STARTWIDTH,
ENDWIDTH, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT GSPARTVERTEXID,
GSPARTID,
ITEM,
X,
Y,
BULGE,
STARTWIDTH,
ENDWIDTH, 1, 0, SYSDATE, null 
FROM sprsymbgspartvertex ;



INSERT INTO sprsymbrules_h (RULEID,
PROFILEID,
SCALERANGEID,
SPRID,
PROVIDERNAME,
CONFIGSTRINGID,
DRAWORDER, logIdFrom, logIdTo, dateFrom, dateTo)
SELECT RULEID,
PROFILEID,
SCALERANGEID,
SPRID,
PROVIDERNAME,
CONFIGSTRINGID,
DRAWORDER, 1, 0, SYSDATE, null 
FROM sprsymbrules;

commit;

