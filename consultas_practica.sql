-- Consultas de práctica para la base tienda_db.
-- Primero ejecuta guia_mysql_practica_completa.sql para crear y cargar los datos.
-- Este archivo solo consulta información; no modifica ni elimina datos.

USE tienda_db;

-- 1. Consultas básicas y filtros
SELECT nombre, apellido, ciudad FROM clientes;

SELECT nombre, precio FROM productos WHERE precio > 50;

SELECT nombre, precio
FROM productos
WHERE categoria = 'Audio' AND stock > 0;

SELECT nombre, precio FROM productos WHERE precio BETWEEN 20 AND 100;

SELECT nombre, apellido, ciudad
FROM clientes
WHERE ciudad IN ('Miami', 'Tampa');

SELECT nombre FROM clientes WHERE nombre LIKE 'A%';

SELECT nombre, email FROM clientes WHERE email LIKE '%@mail.com';

SELECT nombre, ciudad FROM clientes WHERE ciudad IS NULL;

-- 2. Orden, límite y paginación
SELECT nombre, precio FROM productos ORDER BY precio DESC;

SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 3;

SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 3 OFFSET 3;

-- 3. Alias, cálculos y valores distintos
SELECT nombre, precio, ROUND(precio * 1.07, 2) AS precio_con_impuesto
FROM productos;

SELECT DISTINCT ciudad FROM clientes;

-- 4. Agregación y agrupación
SELECT COUNT(*) AS total_productos,
       AVG(precio) AS precio_promedio,
       MIN(precio) AS precio_minimo,
       MAX(precio) AS precio_maximo,
       SUM(stock) AS stock_total
FROM productos;

SELECT categoria,
       COUNT(*) AS cantidad,
       ROUND(AVG(precio), 2) AS precio_promedio
FROM productos
GROUP BY categoria;

SELECT categoria, COUNT(*) AS cantidad
FROM productos
GROUP BY categoria
HAVING COUNT(*) >= 2;

-- 5. JOINs
SELECT p.pedido_id, c.nombre, c.apellido, p.fecha, p.estado
FROM pedidos p
INNER JOIN clientes c ON c.cliente_id = p.cliente_id;

SELECT p.pedido_id,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       pr.nombre AS producto,
       d.cantidad,
       pr.precio,
       d.cantidad * pr.precio AS subtotal
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
ORDER BY p.pedido_id;

SELECT c.cliente_id, c.nombre, c.apellido
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.pedido_id IS NULL;

SELECT pr.producto_id, pr.nombre, d.pedido_id, d.cantidad
FROM detalle_pedido d
RIGHT JOIN productos pr ON pr.producto_id = d.producto_id
ORDER BY pr.producto_id;

SELECT c.cliente_id, c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
UNION
SELECT c.cliente_id, c.nombre, p.pedido_id, p.estado
FROM clientes c
RIGHT JOIN pedidos p ON p.cliente_id = c.cliente_id;

SELECT c.ciudad, cat.categoria
FROM (SELECT DISTINCT ciudad FROM clientes) c
CROSS JOIN (SELECT DISTINCT categoria FROM productos) cat
ORDER BY c.ciudad, cat.categoria;

SELECT e.nombre AS empleado, j.nombre AS jefe
FROM empleados e
LEFT JOIN empleados j ON j.empleado_id = e.jefe_id;

SELECT c.cliente_id, c.nombre, COUNT(p.pedido_id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre
ORDER BY total_pedidos DESC;

SELECT c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p
  ON p.cliente_id = c.cliente_id AND p.estado = 'Pendiente';

SELECT c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.estado = 'Pendiente';

SELECT p.pedido_id, SUM(d.cantidad * pr.precio) AS total_pedido
FROM pedidos p
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
GROUP BY p.pedido_id;

SELECT c.nombre, c.apellido,
       SUM(d.cantidad * pr.precio) AS total_gastado
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
GROUP BY c.cliente_id, c.nombre, c.apellido
ORDER BY total_gastado DESC;

-- 6. Subconsultas y CTE (MySQL 8.0 o posterior)
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

SELECT nombre, apellido
FROM clientes
WHERE cliente_id IN (SELECT cliente_id FROM pedidos);

WITH totales AS (
  SELECT d.pedido_id, SUM(d.cantidad * pr.precio) AS total
  FROM detalle_pedido d
  JOIN productos pr ON pr.producto_id = d.producto_id
  GROUP BY d.pedido_id
)
SELECT p.pedido_id, p.cliente_id, t.total
FROM pedidos p
JOIN totales t ON t.pedido_id = p.pedido_id
WHERE t.total > 100;

-- 7. Funciones y expresiones
SELECT UPPER(nombre), LENGTH(nombre), LEFT(nombre, 3) FROM clientes;

SELECT NOW() AS ahora, YEAR(NOW()) AS anio, CURDATE() AS hoy;

SELECT DATEDIFF(CURDATE(), '2026-10-01') AS dias_transcurridos;

SELECT DATE_FORMAT(fecha, '%d/%m/%Y') FROM pedidos;

SELECT IFNULL(ciudad, 'Sin ciudad') AS ciudad
FROM clientes;

SELECT CAST(precio AS SIGNED) AS precio_entero
FROM productos;

SELECT nombre, stock,
       CASE
         WHEN stock = 0 THEN 'Agotado'
         WHEN stock < 20 THEN 'Bajo'
         ELSE 'Disponible'
       END AS estado_stock
FROM productos;

-- 8. Ejercicios resueltos
SELECT nombre, precio
FROM productos
WHERE categoria = 'Accesorios'
ORDER BY precio ASC;

SELECT ciudad, COUNT(*) AS total_clientes
FROM clientes
GROUP BY ciudad;

SELECT p.pedido_id,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       p.estado
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id;

SELECT pr.nombre,
       IFNULL(SUM(d.cantidad), 0) AS unidades_vendidas
FROM productos pr
LEFT JOIN detalle_pedido d ON d.producto_id = pr.producto_id
GROUP BY pr.producto_id, pr.nombre
ORDER BY unidades_vendidas DESC;

SELECT DISTINCT c.nombre, c.apellido
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
WHERE pr.categoria = 'Audio';

SELECT p.pedido_id,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       SUM(d.cantidad * pr.precio) AS total
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
GROUP BY p.pedido_id, c.nombre, c.apellido
HAVING SUM(d.cantidad * pr.precio) > 100
ORDER BY total DESC;

SELECT e.nombre AS empleado,
       j.nombre AS jefe,
       s.nombre AS jefe_superior
FROM empleados e
LEFT JOIN empleados j ON j.empleado_id = e.jefe_id
LEFT JOIN empleados s ON s.empleado_id = j.jefe_id;

SELECT pr.nombre, SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedido d
JOIN productos pr ON pr.producto_id = d.producto_id
GROUP BY pr.producto_id, pr.nombre
ORDER BY unidades_vendidas DESC
LIMIT 1;
