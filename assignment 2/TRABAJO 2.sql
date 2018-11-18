  --1. Crear una vista llamada “MEDIOS_PAGO_CLIENTES” que contenga las siguientes columnas:
--CLIENTE_ID, NOMBRE_CLIENTE (Si tiene el nombre y el apellido separados en columnas, deberán
--estar unidas en una sola), MEDIO_PAGO_ID, TIPO (TDC, Android, Paypal, Efectivo),
--DETALLES_MEDIO_PAGO, EMPRESARIAL (FALSO o VERDADERO), NOMBRE_EMPRESA (Si la
--columna Empresarial es falso, este campo aparecerá Nulo)
 CREATE VIEW MEDIOS_PAGO_CLIENTES
AS SELECT U.ID AS CLIENTE_ID,NOMBRE||' '||APELLIDO AS NOMBRE_CLIENTE,MPU.ID AS MEDIO_PAGO_ID ,mpu.tipo 
,CASE 
    when u.tipo_usuario= 'Empresarial' then 'VERDADERO'
    ELSE 'FALSO' END AS EMPRESARIAL,
    emp.descripcion AS NOMBRE_EMPRESA
FROM USUARIOS U
INNER JOIN medios_pago_usuario MPU ON U.ID = mpu.usuario_id
LEFT JOIN usuarios_empresas USE ON u.id= use.empresa_id
LEFT JOIN EMPRESAS EMP ON use.empresa_id= emp.id;

--2. Cree una vista que permita listar los viajes de cada cliente ordenados cronológicamente. El nombre
--de la vista será “VIAJES_CLIENTES”, los campos que tendrá son: FECHA_VIAJE,
--NOMBRE_CONDUCTOR, PLACA_VEHICULO, NOMBRE_CLIENTE, VALOR_TOTAL,
--TARIFA_DINAMICA (FALSO O VERDADERO), TIPO_SERVICIO (UberX o UberBlack),
--CIUDAD_VIAJE.

CREATE VIEW VIAJES_CLIENTES
AS SELECT FECHA_INICIO AS FECHA_VIAJE, u.nombre||' '||u.apellido AS NOMBRE_CONDUCTOR, ve.placa AS PLACA_VEHICULO,
 UCLI.nombre||' '||UCLI.apellido AS NOMBRE_CLIENTE, fac.valor AS VALOR_TOTAL, CASE WHEN S.tarifa_dinamica= 'Y'
 THEN 'VERDADERO' ELSE 'FALSO' END AS TARIFA_DINAMICA, VE.TIPO_VEHICULO AS TIPO_SERVICIO, ciu.nombre AS CIUDADES_VIAJE
 FROM SERVICIOS S 
INNER JOIN asignaciones_vehiculos AV ON s.asignacion_vehiculo_id= av.id
INNER JOIN USUARIOS U ON av.usuario_id=u.id
INNER JOIN USUARIOS UCLI ON s.cliente_id=UCLI.id
INNER JOIN VEHICULOS VE ON VE.ID= AV.VEHICULO_ID
INNER JOIN FACTURAS FAC ON fac.servicio_id=s.id
INNER JOIN CIUDADES CIU ON u.ciudad_id=CIU.ID;

