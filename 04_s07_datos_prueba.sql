USE NovaMarket;
GO

/* =====================================================
   ACTIVIDAD 4 - A. Generación y control de datos de prueba
   Objetivo: llegar a mínimo 200 pedidos y 400 detalles
===================================================== */

PRINT '=== CONTEO ANTES ===';
SELECT 
    (SELECT COUNT(*) FROM Cliente) AS Clientes,
    (SELECT COUNT(*) FROM Producto) AS Productos,
    (SELECT COUNT(*) FROM Pedido) AS Pedidos,
    (SELECT COUNT(*) FROM DetallePedido) AS Detalles;
GO

/* =====================================================
   Insertar más pedidos
===================================================== */

-- 40 pedidos CONFIRMADO 2025
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal)
SELECT TOP 40
    ((ROW_NUMBER() OVER (ORDER BY ClienteID) - 1) % 40) + 1,
    DATEADD(DAY, - (ABS(CHECKSUM(NEWID())) % 180), '2025-12-20'),
    'CONFIRMADO',
    CASE WHEN ClienteID % 2 = 0 THEN 'Online' ELSE 'Tienda' END
FROM Cliente;

-- 80 pedidos CONFIRMADO 2026
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal)
SELECT TOP 80
    ((ROW_NUMBER() OVER (ORDER BY ClienteID) - 1) % 40) + 1,
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 330), '2026-01-05'),
    'CONFIRMADO',
    CASE WHEN ClienteID % 2 = 0 THEN 'Online' ELSE 'Tienda' END
FROM Cliente;

-- 30 pedidos PENDIENTE 2026
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal)
SELECT TOP 30
    ((ROW_NUMBER() OVER (ORDER BY ClienteID) - 1) % 40) + 1,
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 300), '2026-02-01'),
    'PENDIENTE',
    CASE WHEN ClienteID % 2 = 0 THEN 'Online' ELSE 'Tienda' END
FROM Cliente;

-- 25 pedidos ANULADO 2026
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal)
SELECT TOP 25
    ((ROW_NUMBER() OVER (ORDER BY ClienteID) - 1) % 40) + 1,
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 300), '2026-03-01'),
    'ANULADO',
    CASE WHEN ClienteID % 2 = 0 THEN 'Online' ELSE 'Tienda' END
FROM Cliente;

-- 25 pedidos BORRADOR 2026
INSERT INTO Pedido (ClienteID, FechaPedido, Estado, Canal)
SELECT TOP 25
    ((ROW_NUMBER() OVER (ORDER BY ClienteID) - 1) % 40) + 1,
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 250), '2026-04-01'),
    'BORRADOR',
    CASE WHEN ClienteID % 2 = 0 THEN 'Online' ELSE 'Tienda' END
FROM Cliente;
GO

/* =====================================================
   Insertar detalles
===================================================== */

-- Primera línea de detalle
INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, PrecioUnitario)
SELECT 
    p.PedidoID,
    ((ABS(CHECKSUM(NEWID())) % 12) + 1),
    ((ABS(CHECKSUM(NEWID())) % 4) + 1),
    pr.PrecioLista
FROM Pedido p
INNER JOIN Producto pr ON pr.ProductoID = ((ABS(CHECKSUM(NEWID())) % 12) + 1)
WHERE p.PedidoID > 40
  AND p.Estado IN ('CONFIRMADO', 'PENDIENTE', 'ANULADO')
  AND NOT EXISTS (SELECT 1 FROM DetallePedido d WHERE d.PedidoID = p.PedidoID);
GO

-- Segunda línea de detalle (para superar 400)
INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, PrecioUnitario)
SELECT 
    p.PedidoID,
    ((ABS(CHECKSUM(NEWID())) % 12) + 1),
    ((ABS(CHECKSUM(NEWID())) % 3) + 1),
    pr.PrecioLista
FROM Pedido p
INNER JOIN Producto pr ON pr.ProductoID = ((ABS(CHECKSUM(NEWID())) % 12) + 1)
WHERE p.PedidoID > 40
  AND p.Estado IN ('CONFIRMADO', 'PENDIENTE')
  AND (SELECT COUNT(*) FROM DetallePedido d WHERE d.PedidoID = p.PedidoID) = 1;
GO

/* =====================================================
   Verificación final
===================================================== */

PRINT '=== CONTEO DESPUÉS ===';
SELECT 
    (SELECT COUNT(*) FROM Cliente) AS Clientes,
    (SELECT COUNT(*) FROM Producto) AS Productos,
    (SELECT COUNT(*) FROM Pedido) AS Pedidos,
    (SELECT COUNT(*) FROM DetallePedido) AS Detalles;
GO

PRINT '=== DISTRIBUCIÓN POR ESTADO ===';
SELECT Estado, COUNT(*) AS Cantidad
FROM Pedido
GROUP BY Estado
ORDER BY Estado;
GO

PRINT '=== DISTRIBUCIÓN POR AÑO ===';
SELECT YEAR(FechaPedido) AS Anio, COUNT(*) AS Cantidad
FROM Pedido
GROUP BY YEAR(FechaPedido)
ORDER BY Anio;
GO
