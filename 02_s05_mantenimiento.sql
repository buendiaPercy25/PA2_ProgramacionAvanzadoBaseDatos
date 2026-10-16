USE NovaMarket;
GO

/* =========================================
   A. INSERT ... SELECT
   Historial de pedidos confirmados de 2025
   ========================================= */

IF OBJECT_ID('dbo.PedidoHistorico2025', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PedidoHistorico2025 (
        PedidoID INT PRIMARY KEY,
        ClienteID INT NOT NULL,
        FechaPedido DATE NOT NULL,
        Estado VARCHAR(20) NOT NULL,
        Canal VARCHAR(30) NULL
    );
END;
GO

INSERT INTO dbo.PedidoHistorico2025
    (PedidoID, ClienteID, FechaPedido, Estado, Canal)
SELECT
    p.PedidoID,
    p.ClienteID,
    p.FechaPedido,
    p.Estado,
    p.Canal
FROM dbo.Pedido AS p
WHERE p.Estado = 'CONFIRMADO'
  AND p.FechaPedido < '20260101'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.PedidoHistorico2025 AS h
      WHERE h.PedidoID = p.PedidoID
  );

SELECT @@ROWCOUNT AS PedidosHistoricosInsertados;
GO

-- Verificar los registros
SELECT COUNT(*) AS TotalPedidosConfirmados2025
FROM dbo.Pedido
WHERE Estado = 'CONFIRMADO'
  AND FechaPedido < '20260101';

SELECT COUNT(*) AS TotalPedidosHistoricos
FROM dbo.PedidoHistorico2025;

SELECT *
FROM dbo.PedidoHistorico2025
ORDER BY FechaPedido;
GO


/* =========================================
   B. UPDATE condicional
   Descuento del 10% en productos seleccionados
   ========================================= */

UPDATE p
SET PrecioOferta = ROUND(p.PrecioLista * 0.90, 2)
FROM dbo.Producto AS p
INNER JOIN dbo.Categoria AS c
    ON c.CategoriaID = p.CategoriaID
WHERE c.Nombre = 'Redes'
  AND p.Activo = 1
  AND p.Stock >= 10
  AND (
      p.PrecioOferta IS NULL
      OR p.PrecioOferta <> ROUND(p.PrecioLista * 0.90, 2)
  );

SELECT @@ROWCOUNT AS ProductosActualizados;
GO

-- Verificar los precios
SELECT
    p.ProductoID,
    p.Nombre,
    c.Nombre AS Categoria,
    p.Stock,
    p.Activo,
    p.PrecioLista,
    p.PrecioOferta
FROM dbo.Producto AS p
INNER JOIN dbo.Categoria AS c
    ON c.CategoriaID = p.CategoriaID
WHERE c.Nombre = 'Redes'
ORDER BY p.ProductoID;
GO


/* =========================================
   C. DELETE protegido
   Eliminar borradores sin detalles
   ========================================= */

DELETE FROM dbo.Pedido
WHERE Estado = 'BORRADOR'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DetallePedido AS d
      WHERE d.PedidoID = dbo.Pedido.PedidoID
  );

SELECT @@ROWCOUNT AS PedidosBorradorEliminados;
GO

-- Verificar pedidos restantes
SELECT
    p.PedidoID,
    p.Estado,
    COUNT(d.PedidoID) AS CantidadDetalles
FROM dbo.Pedido AS p
LEFT JOIN dbo.DetallePedido AS d
    ON d.PedidoID = p.PedidoID
GROUP BY p.PedidoID, p.Estado
ORDER BY p.PedidoID;
GO

-- Confirmar que no se eliminaron pedidos confirmados
SELECT *
FROM dbo.Pedido
WHERE Estado = 'CONFIRMADO';

-- Confirmar que los borradores con detalles permanecen
SELECT p.*
FROM dbo.Pedido AS p
WHERE p.Estado = 'BORRADOR'
  AND EXISTS (
      SELECT 1
      FROM dbo.DetallePedido AS d
      WHERE d.PedidoID = p.PedidoID
  );
GO
