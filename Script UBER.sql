--SELECT 'DROP TABLE "' || TABLE_NAME || '" CASCADE CONSTRAINTS;' FROM user_tables;
--GRANT CREATE TABLE TO UserUBER;
--GRANT GRANT ANY OBJECT PRIVILEGE TO UserUBER; 
--GRANT CREATE SEQUENCE TO UserUBER;
--CONNECT UserUBER;


CREATE TABLE PAISES (
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
descripcion nvarchar2(255) NOT NULL,
indicativo  int NOT NULL,
moneda varchar2(20) NOT NULL
);


CREATE TABLE VEHICULOS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
modelo          nvarchar2(255) NOT NULL,
a�o             int NOT NULL,
marca           nvarchar2(255) NOT NULL,
placa           nvarchar2(255) NOT NULL,
tipo_vehiculo   nvarchar2(255) NOT NULL,
CONSTRAINT check_tipo_vehiculo
CHECK (tipo_vehiculo IN('Uber X','Uber Black'))
);


CREATE TABLE CUIDADES (
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
nombre           nvarchar2(255) NOT NULL,
pais_id         int NOT NULL,
CONSTRAINT fk_paises
    FOREIGN KEY (pais_id)
    REFERENCES PAISES (id)
);

CREATE TABLE EMPRESAS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
descripcion     nvarchar2(255) NOT NULL,
nit             nvarchar2(255) NOT NULL,
direccion       nvarchar2(255) NOT NULL
);


CREATE TABLE USUARIOS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
nombre          nvarchar2(255) NOT NULL,
apellido        nvarchar2(255) NOT NULL,
imagen_url      nvarchar2(255),
telefono        nvarchar2(255) NOT NULL,
tipo_usuario    nvarchar2(255) NOT NULL,
usuario         varchar2 (64) NOT NULL,
idioma          nvarchar2(20),
ciudad_id       int,
CONSTRAINT check_tipo_usuario
    CHECK (tipo_usuario IN('Empresarial','Conductor','Cliente')),
CONSTRAINT fk_ciudades
    FOREIGN KEY (ciudad_id)
    REFERENCES CUIDADES (id)
);

CREATE TABLE EMAILS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
usuario_id      int NOT NULL,
email           varchar2(64) NOT NULL,
CONSTRAINT fk_usuarios
    FOREIGN KEY (usuario_id) 
    REFERENCES USUARIOS (id)
);

CREATE TABLE ASIGNACIONES_VEHICULOS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
usuario_id      int NOT NULL,
vehiculo_id     int NOT NULL,
CONSTRAINT fk_usuarios_asignaciones_vehiculos
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id),
CONSTRAINT fk_vehiculos_asignaciones_vehiculos
    FOREIGN KEY (vehiculo_id)
    REFERENCES VEHICULOS (id)
);


CREATE TABLE CODIGOS_PROMOCIONALES(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
codigo          nvarchar2(255)NOT NULL,
valor           numeric(18,4)NOT NULL,
estado          nvarchar2(255) NOT NULL,

CONSTRAINT check_estado_codigos_promicionales
    CHECK (estado IN('Activo','Inactivo','Ejecutado'))
);



CREATE TABLE USUARIOS_CODIGOS_PROMOCIONALES(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
usuario_id int NOT NULL,
codigo_promocional_id int NOT NULL,
CONSTRAINT fk_codigos_promocionales
    FOREIGN KEY (codigo_promocional_id)
    REFERENCES CODIGOS_PROMOCIONALES (id),
    
    CONSTRAINT fk_usuario_codigo_promocional
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id)
);


CREATE TABLE MEDIOS_PAGO_USUARIO(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
usuario_id INT,
medio_pago_detalle nvarchar2(255)NOT NULL,
estado varchar2(8) NOT NULL,
tipo varchar2(64) NOT NULL,
CONSTRAINT check_estado_medios_pago_usuario
    CHECK (estado IN('Activo','Inactivo')),
CONSTRAINT check_tipo_medios_pago_usuario
    CHECK (tipo IN('Tarjeta de cr�dito','Tarjeta d�bito','Cuenta de ahorros','PayPay','Android')),
  CONSTRAINT fk_usuario_medios_pago
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id)
);

CREATE TABLE CONFIGURACION_ENVIO_RECIBOS (
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
email_id int NOT NULL,
medio_pago_usuario_id int NOT NULL,
    CONSTRAINT fk_emails
    FOREIGN KEY (email_id)
    REFERENCES EMAILS (id),
    
    CONSTRAINT fk_medio_pago_usuario_configuracion_envio
    FOREIGN KEY (medio_pago_usuario_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id)

);


CREATE TABLE USUARIOS_EMPRESAS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
usuario_id INT NOT NULL,
empresa_id INT NOT NULL,
estados NVARCHAR2(32) NOT NULL,
fecha_inicio TIMESTAMP NOT NULL,
fecha_fin TIMESTAMP NOT NULL,

 CONSTRAINT check_estados_usuarios_empresas
    CHECK (estados IN('Activo','Inactivo')),

 CONSTRAINT fk_usuario_empresas_usuario
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id),
     CONSTRAINT fk_usuario_empresas_empresas
    FOREIGN KEY (empresa_id)
    REFERENCES EMPRESAS (id)
);

CREATE TABLE SERVICIOS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
cliente_id int NOT NULL,
cliente_compartido_id int ,
asignacion_vehiculo_id int NOT NULL,
distancia_recorrida int NOT NULL,
tiempo_requerido int NOT NULL,
fecha_inicio TIMESTAMP NOT NULL,
fecha_fin TIMESTAMP NOT NULL,
servicio_compartido char(1),
estado nvarchar2(20) NOT NULL,
tarifa_dinamica char(1) NOT NULL,
direccion_origen nvarchar2(255) NOT NULL,
direccion_destino nvarchar2(255) NOT NULL,
 CONSTRAINT fk_cliente_factura
    FOREIGN KEY (cliente_id)
    REFERENCES USUARIOS (id),
    
     CONSTRAINT fk_cliente_compartido_factura
    FOREIGN KEY (cliente_compartido_id)
    REFERENCES USUARIOS (id),
    
    CONSTRAINT fk_servicio_asignaciones_vehiculos
    FOREIGN KEY (asignacion_vehiculo_id)
    REFERENCES ASIGNACIONES_VEHICULOS (id),   
        
    
    CONSTRAINT check_tarifa_dinamica
    CHECK (tarifa_dinamica IN('Y','N')),
    
    CONSTRAINT check_servicio_compartido
    CHECK (servicio_compartido IN('Y','N'))
    
  
);

CREATE TABLE FACTURAS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
servicio_id     int NOT NULL,
medio_pago_id int NOT NULL,
valor number NOT NULL,
estado varchar2(16) NOT NULL,


CONSTRAINT fk_servicio_medio_pagos_facturas
    FOREIGN KEY (medio_pago_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id),

CONSTRAINT check_estado_facturas
    CHECK (estado IN('Liquidada','Pendiente')),

comision number generated always as (valor * 0.34) virtual,
 CONSTRAINT fk_detalle_facturas_servicios_facturas
    FOREIGN KEY (servicio_id)
    REFERENCES SERVICIOS (id)
);

CREATE TABLE DETALLE_FACTURAS(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
factura_id int NOT NULL,
concepto nvarchar2(255) NOT NULL,
valor number NOT NULL,
   CONSTRAINT fk_detalle_facturas_facturas_detalle
    FOREIGN KEY (factura_id)
    REFERENCES FACTURAS (id)
);

CREATE TABLE GEOLOCALIZACIONES(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
servicio_id int NOT NULL,
longitud nvarchar2(255) NOT NULL,
latitud nvarchar2(255) NOT NULL,
 CONSTRAINT fk_geolocalizaciones_ubicacion
    FOREIGN KEY (servicio_id)
    REFERENCES SERVICIOS (id)
);

CREATE TABLE PAGOS_CONDUCTORES(
id    INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
conductor_id int NOT NULL,
medio_pago_id int NOT NULL,
valor number NOT NULL,
fecha_corte_incial TIMESTAMP NOT NULL,
fecha_corte_final TIMESTAMP NOT NULL,
observaciones varchar2(2048),
 CONSTRAINT fk_pagos_medio_pago_pagos_conductores
    FOREIGN KEY (medio_pago_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id),
     CONSTRAINT fk_pagos_conductor
    FOREIGN KEY (conductor_id)
    REFERENCES USUARIOS (id)
);
