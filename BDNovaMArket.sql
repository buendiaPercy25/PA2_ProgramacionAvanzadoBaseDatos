CREATE DATABASE NovaMarket;
GO

USE NovaMarket;
GO

CREATE TABLE Cliente (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Documento VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Activo BIT DEFAULT 1
);

CREATE TABLE Categoria (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Producto (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    CategoriaID INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    PrecioLista DECIMAL(10,2) NOT NULL,
    PrecioOferta DECIMAL(10,2) NULL,
    Stock INT NOT NULL,
    Activo BIT DEFAULT 1,
    FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID)
);

CREATE TABLE Pedido (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT NOT NULL,
    FechaPedido DATE NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('CONFIRMADO','PENDIENTE','ANULADO','BORRADOR')),
    Canal VARCHAR(50),
    FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
);

CREATE TABLE DetallePedido (
    DetalleID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID)
);

INSERT INTO Categoria (Nombre) VALUES
('Redes'), ('Seguridad'), ('Accesorios');

select  * from Categoria;

select  * from Cliente;

INSERT INTO Cliente (Documento, Nombre, Ciudad, Activo) VALUES
('DOC001','Carlos Pérez','Lima',1),
('DOC002','Ana Torres','Arequipa',1),
('DOC003','Luis Gómez','Cusco',1),
('DOC004','María Díaz','Trujillo',1),
('DOC005','Pedro Sánchez','Lima',1),
('DOC006','Lucía Ramos','Piura',1),
('DOC007','Jorge Castillo','Chiclayo',1),
('DOC008','Sofía Herrera','Tacna',1),
('DOC009','Diego Vargas','Lima',1),
('DOC010','Valeria Rojas','Ica',1),
('DOC011','Andrés Silva','Huancayo',1),
('DOC012','Gabriela Flores','Lima',1),
('DOC013','Ricardo Medina','Arequipa',1),
('DOC014','Paola Cruz','Cusco',1),
('DOC015','Fernando López','Lima',1),
('DOC016','Miguel Salazar','Lima',1),
('DOC017','Patricia Rojas','Cusco',1),
('DOC018','Hugo Fernández','Arequipa',1),
('DOC019','Carolina Vargas','Piura',1),
('DOC020','José Ramírez','Trujillo',1),
('DOC021','Daniela Torres','Chiclayo',1),
('DOC022','Martín Castillo','Tacna',1),
('DOC023','Rosa Medina','Ica',1),
('DOC024','Alberto Cruz','Huancayo',1),
('DOC025','Claudia Herrera','Lima',1),
('DOC026','Felipe Gómez','Arequipa',1),
('DOC027','Verónica Díaz','Cusco',1),
('DOC028','Esteban Silva','Piura',1),
('DOC029','Natalia Flores','Trujillo',1),
('DOC030','Gustavo López','Chiclayo',1),
('DOC031','Marisol Sánchez','Tacna',1),
('DOC032','Raúl Paredes','Ica',1),
('DOC033','Elena Ramírez','Huancayo',1),
('DOC034','Javier Torres','Lima',1),
('DOC035','Liliana Rojas','Arequipa',1),
('DOC036','César Vargas','Cusco',1),
('DOC037','Andrea Fernández','Piura',1),
('DOC038','Pablo Castillo','Trujillo',1),
('DOC039','Gabriela Cruz','Chiclayo',1),
('DOC040','Ricardo Herrera','Tacna',1);


select * from Producto;

INSERT INTO Producto (CategoriaID, Nombre, PrecioLista, Stock, Activo) VALUES
(1,'Router TP-Link',150.00,20,1),
(1,'Switch Cisco',300.00,15,1),
(1,'Cable Ethernet',20.00,100,1),
(2,'Firewall Fortinet',1200.00,5,1),
(2,'Antivirus Kaspersky',80.00,50,1),
(2,'Cámara IP Hikvision',250.00,30,1),
(3,'Mouse Logitech',40.00,40,1),
(3,'Teclado Microsoft',60.00,35,1),
(3,'Audífonos Sony',100.00,25,1),
(3,'Cargador Universal',25.00,60,1),
(3,'Memoria USB 32GB',15.00,80,1),
(3,'Parlante Bluetooth JBL',120.00,20,1);

select * from Pedido;
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal) VALUES
(1,'2025-11-15','CONFIRMADO','Online'),
(2,'2025-12-20','CONFIRMADO','Tienda'),
(3,'2025-10-05','CONFIRMADO','Online'),
(4,'2025-09-12','CONFIRMADO','Tienda'),
(5,'2026-01-10','CONFIRMADO','Online'),
(6,'2026-02-15','CONFIRMADO','Tienda'),
(7,'2026-03-05','CONFIRMADO','Online'),
(8,'2026-04-20','CONFIRMADO','Tienda'),
(9,'2026-05-18','CONFIRMADO','Online'),
(10,'2026-06-25','CONFIRMADO','Tienda'),
(11,'2026-01-12','PENDIENTE','Online'),
(12,'2026-02-22','PENDIENTE','Tienda'),
(13,'2026-03-30','PENDIENTE','Online'),
(14,'2026-04-10','PENDIENTE','Tienda'),
(15,'2026-01-05','ANULADO','Online'),
(16,'2026-02-14','ANULADO','Tienda'),
(17,'2026-03-28','ANULADO','Online'),
(18,'2026-04-08','ANULADO','Tienda'),
(19,'2026-05-01','BORRADOR','Online'),
(20,'2026-05-15','BORRADOR','Tienda'),
(21,'2026-07-01','CONFIRMADO','Online'),
(22,'2026-07-12','CONFIRMADO','Tienda'),
(23,'2026-08-05','CONFIRMADO','Online'),
(24,'2026-08-20','CONFIRMADO','Tienda'),
(25,'2026-09-10','CONFIRMADO','Online'),
(26,'2026-09-25','CONFIRMADO','Tienda'),
(27,'2026-10-02','CONFIRMADO','Online'),
(28,'2026-10-18','CONFIRMADO','Tienda'),
(29,'2026-11-05','CONFIRMADO','Online'),
(30,'2026-11-22','CONFIRMADO','Tienda'),
(31,'2026-12-01','CONFIRMADO','Online'),
(32,'2026-12-15','CONFIRMADO','Tienda'),
(33,'2026-12-20','CONFIRMADO','Online'),
(34,'2026-12-28','CONFIRMADO','Tienda'),
(35,'2026-06-10','PENDIENTE','Online'),
(36,'2026-07-22','ANULADO','Tienda'),
(37,'2026-08-30','BORRADOR','Online'),
(38,'2026-09-12','BORRADOR','Tienda'),
(39,'2026-10-25','CONFIRMADO','Online'),
(40,'2026-11-30','CONFIRMADO','Tienda');

select * from DetallePedido;

INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, PrecioUnitario) VALUES
(1,1,2,150.00),(1,3,5,20.00),
(2,4,1,1200.00),(2,7,2,40.00),
(3,2,1,300.00),(3,9,1,100.00),
(4,6,1,250.00),(4,11,3,15.00),
(5,1,1,150.00),(5,8,1,60.00),
(6,2,2,300.00),(6,10,1,25.00),
(7,3,4,20.00),(7,12,1,120.00),
(8,5,1,80.00),(8,9,2,100.00),
(9,7,1,40.00),(9,11,2,15.00),
(10,1,1,150.00),(10,6,1,250.00),
(21,2,1,300.00),(21,3,2,20.00),
(22,4,1,1200.00),(22,7,1,40.00),
(23,8,1,60.00),(23,9,1,100.00),
(24,10,2,25.00),(24,12,1,120.00),
(25,1,1,150.00),(25,5,1,80.00),
(26,2,1,300.00),(26,6,1,250.00),
(27,3,3,20.00),(27,11,2,15.00),
(28,7,1,40.00),(28,9,1,100.00),
(29,8,1,60.00),(29,12,1,120.00),
(30,10,1,25.00),(30,1,1,150.00),
(31,2,1,300.00),(31,4,1,1200.00),
(32,5,1,80.00),(32,6,1,250.00),
(33,7,1,40.00),(33,9,1,100.00),
(34,8,1,60.00),(34,11,2,15.00),
(39,12,1,120.00),(39,3,2,20.00),
(40,1,1,150.00),(40,2,1,300.00),
(11,1,1,150.00),(12,2,1,300.00),
(13,3,1,20.00),(14,4,1,1200.00),
(15,5,1,80.00),(16,6,1,250.00),
(17,7,1,40.00),(18,8,1,60.00),
(20,9,1,100.00),(38,10,1,25.00),
(21,5,1,80.00),
(22,6,1,250.00),
(23,11,2,15.00),
(24,1,1,150.00);
