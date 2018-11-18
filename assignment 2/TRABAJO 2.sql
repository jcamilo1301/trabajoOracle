  --1. Crear una vista llamada �MEDIOS_PAGO_CLIENTES� que contenga las siguientes columnas:
--CLIENTE_ID, NOMBRE_CLIENTE (Si tiene el nombre y el apellido separados en columnas, deber�n
--estar unidas en una sola), MEDIO_PAGO_ID, TIPO (TDC, Android, Paypal, Efectivo),
--DETALLES_MEDIO_PAGO, EMPRESARIAL (FALSO o VERDADERO), NOMBRE_EMPRESA (Si la
--columna Empresarial es falso, este campo aparecer� Nulo)
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

--2. Cree una vista que permita listar los viajes de cada cliente ordenados cronol�gicamente. El nombre
--de la vista ser� �VIAJES_CLIENTES�, los campos que tendr� son: FECHA_VIAJE,
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

--3. Cree y evidencie el plan de ejecuci�n de la vista VIAJES_CLIENTES. Cree al menos un �ndice donde
--mejore el rendimiento del query y muestre el nuevo plan de ejecuci�n



EXPLAIN PLAN 
SET STATEMENT_ID='PLAN'
FOR
SELECT * FROM VIAJES_CLIENTES
WHERE placa_vehiculo = 'DZG700';

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE','PLAN','TYPICAL'));

CREATE UNIQUE INDEX PLACA_VEHICULOS_INDEX ON VEHICULOS(PLACA);

EXPLAIN PLAN 
SET STATEMENT_ID='PLAN2'
FOR
SELECT * FROM VIAJES_CLIENTES
WHERE placa_vehiculo = 'DZG700';
SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY('PLAN_TABLE','PLAN2','TYPICAL'));

-- NOTA: SE EJECUTA EL EXPLAIN SIN INDEXAR CAMPOS Y POSTERIORMENTE SE INDEXA EL CAMPO PLACA DE VEHICULO, EN EL CUAL SE PUDO 
-- EVIDENCIAR UNA REBAJA COSIDERABLE EN EL COSTO ASOCIADO A LA CONSULTA, POR LO QUE CONCLUIMOS QUE EN ESTE CASO SERIA VIABLE
-- INDEXAR LA COLUMNA. EN EL REPOSITORIO ESTAN LAS EVIDENCIAS EN LOS IMAGENES LLAMADAS EXPLAIN1.PNG Y EXPLAIN2.PNG



--4. Las directivas han decidido implementar el valor de la tarifa por cada kil�metro recorrido y el valor de
--la tarifa por minuto transcurrido de acuerdo a cada ciudad. Tambi�n han decidido almacenar el valor
--de la tarifa base para cada ciudad. Para esto usted deber� crear tres de columnas de tipo num�rico y
--en la tabla que sea conveniente (Se sugiere que sea en la tabla de Ciudades en caso de tenerla-
--disponible) Ejemplo:

ALTER TABLE CIUDADES
  ADD VALOR_MINUTO NUMBER;
  
  ALTER TABLE CIUDADES
  ADD VALOR_KILOMETRO NUMBER;
  
  ALTER TABLE CIUDADES
  ADD VALOR_BASE NUMBER;

--a. Medell�n: el valor por cada kil�metro es: 764.525994 pesos colombianos y el valor por minuto
--es de: 178.571429 pesos colombianos. El valor de la tarifa base es de 2500
  UPDATE CIUDADES SET VALOR_MINUTO=178.571429
  WHERE NOMBRE='Medellin';
    UPDATE CIUDADES SET VALOR_KILOMETRO=764.525994
  WHERE NOMBRE='Medellin';
    UPDATE CIUDADES SET VALOR_BASE=2500
  WHERE NOMBRE='Medellin';

--b. Bogot�: el valor por cada kil�metro es: 522.43456 pesos colombianos y el valor por minuto es
--de: 173.1273 pesos colombianos. El valor de la tarifa base es de 2400
  
  UPDATE CIUDADES SET VALOR_MINUTO= 173.1273
  WHERE NOMBRE='Bogota';
    UPDATE CIUDADES SET VALOR_KILOMETRO=522.43456
  WHERE NOMBRE='Bogota';
    UPDATE CIUDADES SET VALOR_BASE=2400
  WHERE NOMBRE='Bogota';

--c. Llenar diversos valores para las dem�s ciudad.

  UPDATE CIUDADES SET VALOR_MINUTO= 1
  WHERE NOMBRE='Miami';
    UPDATE CIUDADES SET VALOR_KILOMETRO=2
  WHERE NOMBRE='Miami';
    UPDATE CIUDADES SET VALOR_BASE=3
  WHERE NOMBRE='Miami';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 0.8
  WHERE NOMBRE='New Yorck';
    UPDATE CIUDADES SET VALOR_KILOMETRO=1.4
  WHERE NOMBRE='New Yorck';
    UPDATE CIUDADES SET VALOR_BASE=1.7
  WHERE NOMBRE='New Yorck';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 0.7
  WHERE NOMBRE='Los Angeles';
    UPDATE CIUDADES SET VALOR_KILOMETRO=1.5
  WHERE NOMBRE='Los Angeles';
    UPDATE CIUDADES SET VALOR_BASE=2
  WHERE NOMBRE='Los Angeles';
  
    UPDATE CIUDADES SET VALOR_MINUTO=0.8
  WHERE NOMBRE='Lima';
    UPDATE CIUDADES SET VALOR_KILOMETRO=1.1
  WHERE NOMBRE='Lima';
    UPDATE CIUDADES SET VALOR_BASE=0.9
  WHERE NOMBRE='Lima';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 1
  WHERE NOMBRE='Cusco';
    UPDATE CIUDADES SET VALOR_KILOMETRO=1.2
  WHERE NOMBRE='Cusco';
    UPDATE CIUDADES SET VALOR_BASE=1
  WHERE NOMBRE='Cusco';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 123.1273
  WHERE NOMBRE='Cali';
    UPDATE CIUDADES SET VALOR_KILOMETRO=529.43456
  WHERE NOMBRE='Cali';
    UPDATE CIUDADES SET VALOR_BASE=2100
  WHERE NOMBRE='Cali';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 177.1273
  WHERE NOMBRE='Barranquilla';
    UPDATE CIUDADES SET VALOR_KILOMETRO=622.43456
  WHERE NOMBRE='Barranquilla';
    UPDATE CIUDADES SET VALOR_BASE=2300
  WHERE NOMBRE='Barranquilla';
  
    UPDATE CIUDADES SET VALOR_MINUTO= 0.5
  WHERE NOMBRE='Tampa';
    UPDATE CIUDADES SET VALOR_KILOMETRO=1
  WHERE NOMBRE='Tampa';
    UPDATE CIUDADES SET VALOR_BASE=1.2
  WHERE NOMBRE='Tampa';
  
 
  
--5. Crear una funci�n llamada VALOR_DISTANCIA que reciba la distancia en kil�metros y el nombre de
--la ciudad donde se hizo el servicio. Con esta informaci�n deber� buscar el valor por cada kil�metro
--dependiendo de la ciudad donde est� ubicado el viaje. Deber� retornar el resultado de multiplicar la
--distancia recorrida y el valor de cada kil�metro dependiendo de la ciudad. Si la distancia es menor a 0
--kil�metros o la ciudad no es v�lida deber� levantar una excepci�n propia. Ejemplo: Viaje_ID: 342 que
--fue hecho en Medell�n y la distancia fue 20.68km. En este caso deber� retornar 20.68 * 764.525994 =
--15810.3976.

create  or replace function VALOR_DISTANCIA(distancia  in number, nombre_ciudad in varchar2) 
return number is
--declaracion variables
resultado number;
KILOMETRO EXCEPTION;
begin
--cuerpo pl
    IF distancia<0 then 
    RAISE KILOMETRO;
    END IF;
    select  COALESCE(valor_kilometro,0)* distancia into resultado from ciudades where nombre=nombre_ciudad;
    return ROUND(resultado,4);
    EXCEPTION  
    WHEN KILOMETRO THEN 
    dbms_output.put_line('LA DISTANCIA DEBE SER MAYOR O IGUAL A CERO');
    RETURN -1;
     WHEN NO_DATA_FOUND THEN
     dbms_output.put_line('LA CIUDAD INGRESADA NO EXISTE O NO TIENE UN VALOR ASOCIADO');
     RETURN -1;
end;

declare
a  number := 0;
begin
a:=VALOR_DISTANCIA(10,'Medellin');
dbms_output.put_line('resultado: ' || a);
end;

--6. Crear una funci�n llamada VALOR_TIEMPO que reciba la cantidad de minutos del servicio y el
--nombre de la ciudad donde se hizo el servicio. Con esta informaci�n deber� buscar el valor por cada
--minuto dependiendo de la ciudad donde est� ubicado el viaje. Deber� retornar el resultado de
--multiplicar la distancia recorrida y el valor de cada minuto dependiendo de la ciudad. Si la cantidad de
--minutos es menor a 0 o la ciudad no es v�lida deber� levantar una excepci�n propia. Ejemplo:
--Viaje_ID: 342 que fue hecho en Medell�n y el tiempo fue 28 minutos. En este caso deber� retornar 28
--* 178.571429 = 5000.00001 (0.25)

create  or replace function VALOR_TIEMPO(minutos  in number, nombre_ciudad in varchar2) 
return number IS
resultado number;
MINUTOS_ERROR EXCEPTION;
begin
--cuerpo pl
    IF minutos<0 then 
    RAISE MINUTOS_ERROR;
    END IF;
    select  COALESCE(valor_minuto,0)* minutos into resultado from ciudades where nombre=nombre_ciudad;
    return ROUND(resultado,5);
    EXCEPTION  
    WHEN MINUTOS_ERROR THEN 
    dbms_output.put_line('LA CANTIDAD DE MINUTOS DEBE SER MAYOR O IGUAL A CERO');
    RETURN -1;
     WHEN NO_DATA_FOUND THEN
     dbms_output.put_line('LA CIUDAD INGRESADA NO EXISTE O NO TIENE UN VALOR ASOCIADO');
     RETURN -1;
end;

declare
a  number := 0;
begin
a:=VALOR_TIEMPO(125,'MedelliIKn');
dbms_output.put_line('resultado: ' || a);

end;



-- 7. Crear un procedimiento almacenado que se llame CALCULAR_TARIFA, deberá recibir el ID del viaje.
--Para calcular la tarifa se requiere lo siguiente (0.5):
--a. Si el estado del viaje es diferente a REALIZADO, deberá insert ar 0 en el valor de la tarifa.
--b. Buscar el valor de la tarifa base dependiendo de la ciudad donde se haya hecho el servicio.
--c. Invocar la función VALOR_DISTANCIA
--d. Invocar la función VALOR_TIEMPO
--e. Deberá buscar todos los detalles de cada viaje y sumarlos.
--f. Sumar la tarifa base más el resultado de la función VALOR_DISTANCIA más el resultado de
--la función VALOR_TIEMPO y el resultado de la sumatoria de los detalles del viaje.
--g. Actualizar el registro del viaje con el resultado obtenido.
--h. Si alguna de las funciones levanta una excepción, esta deberá ser controlada y actualizar el
--valor del viaje con 0.

CREATE OR REPLACE PROCEDURE CALCULAR_TARIFA(VIAJE_ID IN INT) AS
BEGIN
declare 
  ESTADOFACTURA VARCHAR2(256);
  VALOR_BASE  INT;
  VALOR_DISTANCIA_CALCULADA NUMBER;
  VALOR_TIEMPO_CALCULADA NUMBER;
  CIUDAD VARCHAR2(256);
  VALOR_DETALLES NUMBER;
BEGIN

SELECT ESTADO INTO ESTADOFACTURA FROM SERVICIOS WHERE ID=2;
IF(ESTADOFACTURA )<>'REALIZADO' THEN
 UPDATE FACTURAS SET VALOR=0 WHERE SERVICIO_ID=VIAJE_ID;

SELECT CIU.VALOR_BASE,ciu.nombre INTO VALOR_BASE,CIUDAD FROM SERVICIOS SER
 INNER JOIN ASIGNACIONES_VEHICULOS ASV ON SER.ASIGNACION_VEHICULO_ID=ASV.ID
 INNER JOIN USUARIOS USU ON USU.ID= ASV.USUARIO_ID
 INNER JOIN CIUDADES CIU ON USU.CIUDAD_ID=CIU.ID
 WHERE SER.ID=VIAJE_ID;
 
 SELECT VALOR_TIEMPO(TIEMPO_REQUERIDO,CIUDAD),  VALOR_DISTANCIA(DISTANCIA_RECORRIDA,CIUDAD) INTO VALOR_TIEMPO_CALCULADA,VALOR_DISTANCIA_CALCULADA
    FROM SERVICIOS
    WHERE ID=VIAJE_ID;
    
    IF (VALOR_TIEMPO_CALCULADA = -1 OR VALOR_DISTANCIA_CALCULADA = -1) THEN
        UPDATE FACTURAS SET VALOR= 0
        WHERE SERVICIO_ID=VIAJE_ID;
        RETURN;
    END IF;
    
    SELECT SUM(DFAC.VALOR) INTO VALOR_DETALLES FROM DETALLE_FACTURAS DFAC
        INNER JOIN FACTURAS FAC ON FAC.ID=dfac.factura_id
        WHERE SERVICIO_ID=VIAJE_ID;
    
    UPDATE FACTURAS SET VALOR= (VALOR_BASE +  VALOR_DISTANCIA_CALCULADA +  VALOR_TIEMPO_CALCULADA +  VALOR_DETALLES)
    WHERE SERVICIO_ID=VIAJE_ID;
    
END IF;
end;

END CALCULAR_TARIFA;