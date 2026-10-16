USE NovaMarket;
GO
/* =========================================
   A.
   ========================================= */
SELECT DISTINCT 
    Cliente.ClienteID, 
    Cliente.Nombre, 
    Cliente.Ciudad
FROM Cliente
WHERE EXISTS (
    SELECT 1 
    FROM Pedido
    INNER JOIN DetallePedido ON Pedido.PedidoID = DetallePedido.PedidoID
    INNER JOIN Producto ON DetallePedido.ProductoID = Producto.ProductoID
    INNER JOIN Categoria ON Producto.CategoriaID = Categoria.CategoriaID
    WHERE Pedido.ClienteID = Cliente.ClienteID
      AND Pedido.Estado = 'CONFIRMADO'
      AND Categoria.Nombre = 'Redes'
      AND YEAR(Pedido.FechaPedido) = 2026
)
AND NOT EXISTS (
    SELECT 1 
    FROM Pedido
    INNER JOIN DetallePedido ON Pedido.PedidoID = DetallePedido.PedidoID
    INNER JOIN Producto ON DetallePedido.ProductoID = Producto.ProductoID
    INNER JOIN Categoria ON Producto.CategoriaID = Categoria.CategoriaID
    WHERE Pedido.ClienteID = Cliente.ClienteID
      AND Pedido.Estado = 'CONFIRMADO'
      AND Categoria.Nombre = 'Seguridad'
      AND YEAR(Pedido.FechaPedido) = 2026
);
GO

/* =========================================
   B. 
   ========================================= */

SELECT 
    Producto.ProductoID, 
    Producto.Nombre AS NombreProducto, 
    Categoria.Nombre AS NombreCategoria, 
    Producto.PrecioLista,
    (
        SELECT AVG(SubProducto.PrecioLista) 
        FROM Producto AS SubProducto 
        WHERE SubProducto.CategoriaID = Producto.CategoriaID
    ) AS PromedioPrecioCategoria
FROM Producto
INNER JOIN Categoria ON Producto.CategoriaID = Categoria.CategoriaID
WHERE Producto.PrecioLista > (
    SELECT AVG(SubProducto.PrecioLista) 
    FROM Producto AS SubProducto 
    WHERE SubProducto.CategoriaID = Producto.CategoriaID
);
GO

/* =========================================
   C.
   ========================================= */

   /*EXISTS y NOT EXISTS son apropiados porque permiten comprobar 
   si un cliente tiene o no tiene determinados pedidos. 
   En este caso, EXISTS busca que tenga por lo menos un pedido de
   Redes y NOT EXISTS que no tenga pedidos de Seguridad durante el
   2026.

	Se debe tener cuidado con NOT IN cuando la subconsulta puede devolver
	NULL, porque esto puede hacer que la consulta no dé los resultados 
	esperados. Por eso, en este caso es mejor usar NOT EXISTS.

	Caso 1: Un cliente tiene un pedido CONFIRMADO de Redes en 2026 y no
	tiene pedidos de Seguridad → aparece en el resultado.

	Caso 2: Un cliente tiene un pedido CONFIRMADO de Redes y también uno
	de Seguridad en 2026 → no aparece en el resultado.
   */