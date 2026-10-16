USE NovaMarket;
GO

/* =====================================================
   ACTIVIDAD 4 - B. Reporte de ventas por cliente 2026
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
