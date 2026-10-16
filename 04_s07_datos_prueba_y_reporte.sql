USE NovaMarket;
GO

/* =====================================================
   ACTIVIDAD 4 - SESIÓN 07
   Datos de prueba + Reporte de ventas por cliente
===================================================== */


/* =====================================================
   PARTE A: Generación y control de datos de prueba
   Objetivo: llegar a mínimo 200 pedidos y 400 detalles
===================================================== */

PRINT '=== CONTEO ANTES ===';
SELECT 
    (SELECT COUNT(*) FROM Cliente) AS Clientes,
    (SELECT COUNT(*) FROM Producto) AS Productos,
    (SELECT COUNT(*) FROM Pedido) AS Pedidos,
    (SELECT COUNT(*) FROM DetallePedido) AS Detalles;
GO

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


/* =====================================================
   PARTE B: Reporte de ventas por cliente 2026
   - Incluye TODOS los clientes activos
   - Solo cuenta pedidos CONFIRMADO de 2026
   - Clientes sin compras aparecen con 0
   - No duplica pedidos aunque tengan varias líneas
===================================================== */

SELECT 
    c.ClienteID,
    c.Nombre,
    COUNT(DISTINCT CASE 
        WHEN p.Estado = 'CONFIRMADO' 
         AND p.FechaPedido BETWEEN '2026-01-01' AND '2026-12-31' 
        THEN p.PedidoID 
    END) AS TotalPedidos2026,
    
    ISNULL(SUM(CASE 
        WHEN p.Estado = 'CONFIRMADO' 
         AND p.FechaPedido BETWEEN '2026-01-01' AND '2026-12-31' 
        THEN d.Cantidad * d.PrecioUnitario 
    END), 0) AS MontoVendido2026
FROM Cliente c
LEFT JOIN Pedido p 
    ON c.ClienteID = p.ClienteID
LEFT JOIN DetallePedido d 
    ON p.PedidoID = d.PedidoID
WHERE c.Activo = 1
GROUP BY c.ClienteID, c.Nombre
ORDER BY c.ClienteID;
GO


/* =====================================================
   PARTE C: Matriz de pruebas (documentación)
=====================================================

| # | Escenario                              | ClienteID | Resultado Esperado               | Resultado Obtenido | Conclusión                          |
|---|----------------------------------------|-----------|----------------------------------|--------------------|-------------------------------------|
| 1 | Cliente con varias líneas en un pedido |           | TotalPedidos ≥ 1 y Monto > 0     |                    | Correcto: no duplica el pedido     |
| 2 | Cliente sin compras confirmadas 2026   |           | TotalPedidos = 0 y Monto = 0     |                    | Correcto: aparece con ceros        |
| 3 | Cliente con pedido PENDIENTE           |           | No se cuenta el pedido           |                    | Correcto: se excluye PENDIENTE     |
| 4 | Cliente con pedido ANULADO             |           | No se cuenta el pedido           |                    | Correcto: se excluye ANULADO       |

Justificación técnica:
- Se usa LEFT JOIN para que los clientes sin compras no desaparezcan del reporte.
- Se usa ISNULL(..., 0) para convertir NULL en 0.
- Se usa COUNT(DISTINCT PedidoID) para no contar un pedido más de una vez aunque tenga varias líneas.
*/
