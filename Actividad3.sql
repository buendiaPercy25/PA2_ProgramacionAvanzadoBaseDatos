-- Actividad 3: Vistas SQL y Reutilizacion de Consultas--

-- A. Vista vw_VentasCategoriaMes
/*Crear una vista con las columnas Anio, Mes, CategoriaID, NombreCategoria, 
TotalUnidades y MontoTotal. Considerar únicamente pedidos CONFIRMADO, 
agrupar por año, mes y categoría y utilizar Cantidad × PrecioUnitario*/

use NovaMarket;
GO

create or alter view vw_VentasCategoriaMes
as
select
    year(p.FechaPedido) as Anio,
    month(p.FechaPedido) as Mes,
    c.CategoriaID,
    c.Nombre as NombreCategoria,
    sum(dp.Cantidad) as TotalUnidades,
    sum(dp.Cantidad * dp.PrecioUnitario) as MontoTotal
from Pedido p
inner join DetallePedido dp on p.PedidoID = dp.PedidoID
inner join Producto pr on dp.ProductoID = pr.ProductoID
inner join Categoria c on pr.CategoriaID = c.CategoriaID
where p.Estado = 'CONFIRMADO'
group by
    year(p.FechaPedido),
    month(p.FechaPedido),
    c.CategoriaID,
    c.Nombre;
go


-- Consulta de la Vista para 2026 ordenado por Mes y MontoTotal
--Para esta consulta se nos muestra todas las columnas de las vistas
select * from vw_VentasCategoriaMes
where Anio = 2026
order by Mes asc, MontoTotal asc;
go

-- B. Vista vw_ClientesSinCompra2026
/*Crear vw_ClientesSinCompra2026 que muestre ClienteID,Nombre y Ciudad de 
los clientes sin pedidos CONFIRMADO durante 2026, aunque tengan pedidos de otro
estado. Evitar duplicados y comprobar el resultado mediante una consulta alternativa 
sobre las tablas originales.*/

create or alter view vw_ClientesSinCompra2026
as
select
    c.ClienteID,
    c.Nombre,
    c.Ciudad
from Cliente c
where not exists (
    select 1
    from Pedido p
    where p.ClienteID = c.ClienteID
      and p.Estado = 'CONFIRMADO'
      and year(p.FechaPedido) = 2026 );
go

--vista
select * from vw_ClientesSinCompra2026
order by Nombre;

--tabla alternativa sobre las tablas originales
select
    c.ClienteID,
    c.Nombre,
    c.Ciudad
from Cliente c
where c.ClienteID not in ( 
    select p.ClienteID
    from Pedido p
    where p.Estado = 'CONFIRMADO'
      and year(p.FechaPedido) = 2026 )
order by c.Nombre;



-- C. Consumo y verificación
/*Ejecutar SELECT sobre ambas vistas, contrastar al menos dos totales mensuales 
con sus registros de origen y explicar qué beneficio funcional aporta 
centralizar esta lógica en vistas*/

select *
from vw_VentasCategoriaMes
where Anio = 2026;

select *
from vw_ClientesSinCompra2026;

/*Las vistas ayudan a optimizar el tiempo de trabajo, reutiliznado queys sin tener que 
escribir todo el codigo de nuevo, tambien nos ayuda a mantener la misma logica de 
consulta para todos nuestros querys*/

select Mes, sum(MontoTotal) as MontoTotal
from vw_VentasCategoriaMes
where Anio = 2026 and Mes in (1, 2)
group by Mes;

select month(p.FechaPedido) as Mes,
       sum(d.Cantidad * d.PrecioUnitario) as MontoTotal
from Pedido p
inner join DetallePedido d on p.PedidoID = d.PedidoID
where p.Estado = 'CONFIRMADO'
  and year(p.FechaPedido) = 2026
  and month(p.FechaPedido) in (1, 2)
group by month(p.FechaPedido);








