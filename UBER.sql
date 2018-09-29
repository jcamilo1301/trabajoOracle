CREATE TABLE PAISES (
id          int PRIMARY KEY,
descripcion nvarchar2(255),
indicativo  int,
moneda varchar2(20)
);


CREATE TABLE VEHICULOS(
id              int PRIMARY KEY,
modelo          nvarchar2(255),
año             int,
marca           nvarchar2(255),
placa           nvarchar2(255),
tipo_vehiculo   nvarchar2(255),
CONSTRAINT check_tipo_vehiculo
CHECK (tipo_vehiculo IN('Uber X','Uber Black'))
);


CREATE TABLE CUIDADES (
id              int PRIMARY KEY,
nombre           nvarchar2(255),
pais_id         int,
CONSTRAINT fk_paises
    FOREIGN KEY (pais_id)
    REFERENCES PAISES (id)
);

CREATE TABLE EMPRESAS(
id              int PRIMARY KEY,
descripcion     nvarchar2(255),
nit             nvarchar2(255),
direccion       nvarchar2(255)
);


CREATE TABLE USUARIOS(
id              int PRIMARY KEY,
nombre          nvarchar2(255),
apellido        nvarchar2(255),
imagen_url      nvarchar2(255),
telefono        nvarchar2(255),
tipo_usuario    nvarchar2(255),
usuario         int,
idioma          nvarchar2(20),
ciudad_id       int,
CONSTRAINT check_tipo_usuario
    CHECK (tipo_usuario IN('Empresarial','Conductor','Cliente')),
CONSTRAINT fk_ciudades
    FOREIGN KEY (ciudad_id)
    REFERENCES CUIDADES (id)
);

CREATE TABLE EMAILS(
id              int PRIMARY KEY,
usuario_id      int,
email           varchar2(64),
CONSTRAINT fk_usuarios
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id)
);

CREATE TABLE ASIGNACIONES_VEHICULOS(
id              int PRIMARY KEY,
usuario_id      int,
vehiculo_id     int,
CONSTRAINT fk_usuarios
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id),
CONSTRAINT fk_vehiculos
    FOREIGN KEY (vehiculo_id)
    REFERENCES VEHICULOS (id)
);

--Faltan
CREATE TABLE CODIGOS_PROMOCIONALES(
id              int PRIMARY KEY,
codigo          nvarchar2(255),
valor           numeric(18,4),
estado          nvarchar2(255)
);



CREATE TABLE USUARIOS_CODIGOS_PROMOCIONALES(
id int PRIMARY KEY,
usuario_id int,
codigo_promocional_id int,
CONSTRAINT fk_codigos_promocionales
    FOREIGN KEY (codigo_promocional_id)
    REFERENCES CODIGOS_PROMOCIONALES (id),
    
    CONSTRAINT fk_usuario_codigo_promocional
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id)
);


CREATE TABLE MEDIOS_PAGO_USUARIO(
id int PRIMARY KEY,
usuario_id INT,
medio_pago_detalle nvarchar2(255),
estado varchar2(8),
tipo varchar2(64),
CONSTRAINT check_estado
    CHECK (estado IN('Activo','Inactivo')),
CONSTRAINT check_tipo
    CHECK (tipo IN('Tarjeta de crédito','Tarjeta débito','Cuenta de ahorros','PayPay','Android')),
  CONSTRAINT fk_usuario_medios_pago
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id)
);

CREATE TABLE CONFIGURACION_ENVIO_RECIBOS (
id int PRIMARY KEY,
email_id int,
medio_pago_usuario_id int,
    CONSTRAINT fk_emails
    FOREIGN KEY (email_id)
    REFERENCES EMAILS (id),
    
    CONSTRAINT fk_medio_pago_usuario
    FOREIGN KEY (medio_pago_usuario_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id)

);


CREATE TABLE USUARIOS_EMPRESAS(
id INT PRIMARY KEY,
usuario_id INT,
empresa_id INT,
estados char(1),
fecha_inicio TIMESTAMP,
fecha_fin TIMESTAMP,

 CONSTRAINT check_estados
    CHECK (estados IN('Y','N')),

 CONSTRAINT fk_usuario_empresas_usuario
    FOREIGN KEY (usuario_id)
    REFERENCES USUARIOS (id),
     CONSTRAINT fk_usuario_empresas_empresas
    FOREIGN KEY (empresa_id)
    REFERENCES EMPRESAS (id)
);

CREATE TABLE SERVICIOS(
id int PRIMARY KEY,
cliente_id int,
cliente_compartido_id int,
asignacion_vehiculo_id int,
distancia_recorrida int,
tiempo_requerido int,
fecha_inicio TIMESTAMP,
fecha_fin TIMESTAMP,
servicio_compartido char(1),
estado nvarchar2(20),
tarifa_dinamica char(1),
direccion_origen nvarchar2(255),
direccion_destino nvarchar2(255),
 CONSTRAINT fk_cliente_factura
    FOREIGN KEY (cliente_id)
    REFERENCES USUARIOS (id),
    
     CONSTRAINT fk_cliente_compartido_factura
    FOREIGN KEY (cliente_compartido_id)
    REFERENCES USUARIOS (id),
    
    CONSTRAINT fk_servicio_asignaciones_vehiculos
    FOREIGN KEY (asignacion_vehiculo_id)
    REFERENCES ASIGNACIONES_VEHICULOS (id),   
    
    
    CONSTRAINT fk_servicio_medio_pagos
    FOREIGN KEY (medio_pago_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id),
    
    CONSTRAINT check_tarifa_dinamica
    CHECK (tarifa_dinamica IN('Y','N')),
    
    CONSTRAINT check_servicio_compartido
    CHECK (servicio_compartido IN('Y','N'))
    
  
);

CREATE TABLE FACTURAS(
id              int PRIMARY KEY,
servicio_id     int,
medio_pago_id int,
valor number,
estado varchar2(16),

CONSTRAINT check_estado
    CHECK (estado IN('Liquidada','Pendiente')),

comision number generated always as (valor * 0.34) virtual,
 CONSTRAINT fk_detalle_facturas_servicios
    FOREIGN KEY (servicio_id)
    REFERENCES SERVICIOS (id)
);

CREATE TABLE DETALLE_FACTURAS(
id int PRIMARY KEY,
factura_id int,
concepto nvarchar2(255),
valor number,
   CONSTRAINT fk_detalle_facturas_facturas
    FOREIGN KEY (factura_id)
    REFERENCES FACTURAS (id)
);

CREATE TABLE GEOLOCALIZACIONES(
id int PRIMARY KEY,
servicio_id int,
longitud nvarchar2(255),
latitud nvarchar2(255),
 CONSTRAINT fk_geolocalizaciones_ubicacion
    FOREIGN KEY (servicio_id)
    REFERENCES SERVICIOS (id)
);

CREATE TABLE PAGOS_CONDUCTORES(
id int PRIMARY KEY,
conductor_id int,
medio_pago_id int,
valor number,
fecha_corte_incial TIMESTAMP,
fecha_corte_final TIMESTAMP,
observaciones varchar2(2048),
 CONSTRAINT fk_pagos_medio_pago
    FOREIGN KEY (medio_pago_id)
    REFERENCES MEDIOS_PAGO_USUARIO (id),
     CONSTRAINT fk_pagos_conductor
    FOREIGN KEY (conductor_id)
    REFERENCES USUARIOS (id)
);
