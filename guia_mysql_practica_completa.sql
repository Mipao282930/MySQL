-- =========================================================
-- Guía práctica de MySQL: desde cero hasta respaldos, triggers y procedimientos
-- =========================================================
-- Ejecuta este script en MySQL Workbench o desde la línea de comandos.
-- Requiere MySQL 8.0+ para usar CHECK, CTE y funciones de ventana.

DROP DATABASE IF EXISTS tienda_db;
CREATE DATABASE tienda_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE tienda_db;

-- =========================================================
-- 5. Crear tablas
-- =========================================================
CREATE TABLE clientes (
  cliente_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  ciudad VARCHAR(50),
  fecha_alta DATE DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE productos (
  producto_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  categoria VARCHAR(40),
  precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
  stock INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE pedidos (
  pedido_id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  fecha DATE NOT NULL DEFAULT (CURRENT_DATE),
  estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
  detalle_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  CONSTRAINT fk_detalle_pedidos
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  CONSTRAINT fk_detalle_productos
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

-- =========================================================
-- 6. Insertar datos de ejemplo
-- =========================================================
INSERT INTO clientes (nombre, apellido, email, ciudad) VALUES
('Ana', 'Pérez', 'ana.perez@mail.com', 'Miami'),
('Luis', 'Gómez', 'luis.gomez@mail.com', 'Orlando'),
('María', 'López', 'maria.lopez@mail.com', 'Miami'),
('Carlos', 'Ruiz', 'carlos.ruiz@mail.com', 'Tampa'),
('Sofía', 'Torres', 'sofia.torres@mail.com', 'Orlando');

INSERT INTO productos (nombre, categoria, precio, stock) VALUES
('Laptop 14 pulgadas', 'Computación', 850.00, 15),
('Mouse inalámbrico', 'Accesorios', 18.50, 120),
('Teclado mecánico', 'Accesorios', 65.00, 60),
('Monitor 24 pulgadas', 'Computación', 150.00, 30),
('Audífonos', 'Audio', 45.90, 80),
('Bocina Bluetooth', 'Audio', 39.99, 0);

INSERT INTO pedidos (cliente_id, fecha, estado) VALUES
(1, '2026-10-01', 'Entregado'),
(1, '2026-10-15', 'Entregado'),
(2, '2026-10-20', 'Pendiente'),
(3, '2026-10-25', 'Enviado'),
(4, '2026-11-02', 'Pendiente');

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(2, 5, 1),
(3, 4, 2),
(4, 2, 3),
(4, 5, 2),
(5, 1, 1);

-- Verificación inicial
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM pedidos;
SELECT * FROM detalle_pedido;

-- =========================================================
-- 7. Consultas con SELECT
-- =========================================================
-- 7.1 Consulta básica y filtros
SELECT nombre, apellido, ciudad FROM clientes;
SELECT * FROM productos WHERE precio > 50;
SELECT * FROM productos WHERE categoria = 'Audio' AND stock > 0;
SELECT * FROM productos WHERE precio BETWEEN 20 AND 100;
SELECT * FROM clientes WHERE ciudad IN ('Miami', 'Tampa');
SELECT * FROM clientes WHERE nombre LIKE 'A%';
SELECT * FROM clientes WHERE email LIKE '%@mail.com';
SELECT * FROM clientes WHERE ciudad IS NULL;

-- 7.2 Ordenar y limitar
SELECT nombre, precio FROM productos ORDER BY precio DESC;
SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 3;
SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 3 OFFSET 3;

-- 7.3 Alias, columnas calculadas y DISTINCT
SELECT nombre, precio, ROUND(precio * 1.07, 2) AS precio_con_impuesto
FROM productos;
SELECT DISTINCT ciudad FROM clientes;

-- =========================================================
-- 8. Funciones de agregación y agrupación
-- =========================================================
SELECT COUNT(*) AS total_productos,
       AVG(precio) AS precio_promedio,
       MIN(precio) AS precio_minimo,
       MAX(precio) AS precio_maximo,
       SUM(stock) AS stock_total
FROM productos;

SELECT categoria, COUNT(*) AS cantidad, ROUND(AVG(precio), 2) AS precio_promedio
FROM productos
GROUP BY categoria;

SELECT categoria, COUNT(*) AS cantidad
FROM productos
GROUP BY categoria
HAVING COUNT(*) >= 2;

-- =========================================================
-- 9. JOINS: relacionar tablas
-- =========================================================
-- 9.1 INNER JOIN
SELECT c.nombre, c.apellido, p.pedido_id, p.estado
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.cliente_id;

-- 9.2 LEFT JOIN
SELECT c.nombre, c.apellido, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id;

-- 9.3 RIGHT JOIN
SELECT c.nombre, c.apellido, p.pedido_id, p.estado
FROM clientes c
RIGHT JOIN pedidos p ON p.cliente_id = c.cliente_id;

-- 9.4 Ejemplo con detalle pedido
SELECT p.pedido_id, pr.nombre, d.cantidad
FROM pedidos p
LEFT JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
LEFT JOIN productos pr ON pr.producto_id = d.producto_id
ORDER BY p.pedido_id, pr.producto_id;

-- 9.5 FULL JOIN simulado con UNION
SELECT c.cliente_id, c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
UNION
SELECT c.cliente_id, c.nombre, p.pedido_id, p.estado
FROM clientes c
RIGHT JOIN pedidos p ON p.cliente_id = c.cliente_id;

-- 9.6 CROSS JOIN
SELECT c.ciudad, cat.categoria
FROM (SELECT DISTINCT ciudad FROM clientes) c
CROSS JOIN (SELECT DISTINCT categoria FROM productos) cat
ORDER BY c.ciudad, cat.categoria;

-- 9.7 SELF JOIN
CREATE TABLE empleados (
  empleado_id INT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  jefe_id INT NULL,
  CONSTRAINT fk_empleados_jefe FOREIGN KEY (jefe_id) REFERENCES empleados(empleado_id)
) ENGINE=InnoDB;

INSERT INTO empleados (empleado_id, nombre, jefe_id) VALUES
(1, 'Roberto', NULL),
(2, 'Elena', 1),
(3, 'Miguel', 1),
(4, 'Laura', 2),
(5, 'Pedro', 2);

SELECT e.nombre AS empleado,
       j.nombre AS jefe
FROM empleados e
LEFT JOIN empleados j ON j.empleado_id = e.jefe_id;

-- 9.8 Contar incluyendo ceros
SELECT c.cliente_id,
       c.nombre,
       COUNT(p.pedido_id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre
ORDER BY total_pedidos DESC;

-- 9.9 ON vs WHERE en LEFT JOIN
SELECT c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p
  ON p.cliente_id = c.cliente_id AND p.estado = 'Pendiente';

SELECT c.nombre, p.pedido_id, p.estado
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.estado = 'Pendiente';

-- 9.10 Total por pedido y por cliente
SELECT p.pedido_id,
       SUM(d.cantidad * pr.precio) AS total_pedido
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

-- =========================================================
-- 10. Modificar y eliminar datos
-- =========================================================
UPDATE productos
SET stock = 50
WHERE nombre = 'Bocina Bluetooth';

UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Accesorios';

DELETE FROM clientes WHERE cliente_id = 5;

-- ALTER TABLE
ALTER TABLE clientes ADD COLUMN telefono VARCHAR(20);
ALTER TABLE clientes MODIFY COLUMN telefono VARCHAR(30);
ALTER TABLE clientes DROP COLUMN telefono;

-- Truncar y borrar tablas (ejemplos)
-- TRUNCATE TABLE tabla;
-- DROP TABLE tabla;
-- DROP TABLE IF EXISTS tabla;

-- =========================================================
-- 11. Subconsultas y CTE
-- =========================================================
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

-- =========================================================
-- 12. Funciones útiles de MySQL
-- =========================================================
SELECT UPPER(nombre), LENGTH(nombre), LEFT(nombre, 3) FROM clientes;
SELECT NOW() AS ahora, YEAR(NOW()) AS anio, CURDATE() AS hoy;
SELECT DATEDIFF(CURDATE(), '2026-10-01') AS dias_transcurridos;
SELECT DATE_FORMAT(fecha, '%d/%m/%Y') FROM pedidos;
SELECT IFNULL(ciudad, 'Sin ciudad') FROM clientes;
SELECT CAST(precio AS SIGNED) FROM productos;

SELECT nombre, stock,
       CASE
         WHEN stock = 0 THEN 'Agotado'
         WHEN stock < 20 THEN 'Bajo'
         ELSE 'Disponible'
       END AS estado_stock
FROM productos;

-- =========================================================
-- 13. Vistas
-- =========================================================
CREATE VIEW vw_detalle_pedidos AS
SELECT p.pedido_id,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       pr.nombre AS producto,
       d.cantidad,
       d.cantidad * pr.precio AS subtotal
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id;

SELECT * FROM vw_detalle_pedidos WHERE subtotal > 100;

-- =========================================================
-- 14. Procedimientos almacenados y funciones
-- =========================================================
DELIMITER //
CREATE PROCEDURE sp_pedidos_por_cliente(IN p_cliente_id INT)
BEGIN
  SELECT pedido_id, fecha, estado
  FROM pedidos
  WHERE cliente_id = p_cliente_id;
END //

CREATE PROCEDURE sp_agregar_producto(
  IN p_nombre VARCHAR(80),
  IN p_categoria VARCHAR(40),
  IN p_precio DECIMAL(10,2),
  IN p_stock INT
)
BEGIN
  INSERT INTO productos (nombre, categoria, precio, stock)
  VALUES (p_nombre, p_categoria, p_precio, p_stock);
END //

CREATE FUNCTION fn_precio_con_impuesto(p_precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN ROUND(p_precio * 1.07, 2);
END //
DELIMITER ;

CALL sp_pedidos_por_cliente(1);
CALL sp_agregar_producto('Webcam HD', 'Accesorios', 55.00, 25);
SELECT nombre, fn_precio_con_impuesto(precio) AS precio_final FROM productos;

-- =========================================================
-- 15. Transacciones
-- =========================================================
START TRANSACTION;
INSERT INTO pedidos (cliente_id, fecha, estado) VALUES (2, '2026-11-10', 'Pendiente');
SET @nuevo_pedido = LAST_INSERT_ID();
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad)
VALUES (@nuevo_pedido, 3, 1);
UPDATE productos SET stock = stock - 1 WHERE producto_id = 3;
COMMIT;

-- Deshacer todo (ejemplo):
-- START TRANSACTION;
-- INSERT INTO pedidos...;
-- ROLLBACK;

-- =========================================================
-- 16. Triggers (disparadores)
-- =========================================================
CREATE TABLE log_productos (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT,
  precio_anterior DECIMAL(10,2),
  precio_nuevo DECIMAL(10,2),
  fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_productos_audit
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
  INSERT INTO log_productos (producto_id, precio_anterior, precio_nuevo)
  VALUES (NEW.producto_id, OLD.precio, NEW.precio);
END //
DELIMITER ;

UPDATE productos
SET precio = precio * 1.05
WHERE categoria = 'Audio';

SELECT * FROM log_productos;

-- =========================================================
-- 17. Indexes y optimización
-- =========================================================
CREATE INDEX ix_clientes_ciudad ON clientes(ciudad);
CREATE INDEX ix_productos_categoria ON productos(categoria);
CREATE INDEX ix_pedidos_cliente ON pedidos(cliente_id);

EXPLAIN SELECT * FROM clientes WHERE ciudad = 'Miami';

-- =========================================================
-- 18. Ejercicios resueltos
-- =========================================================
-- Ejercicio 1. Accesorios ordenados por precio menor a mayor.
SELECT nombre, precio
FROM productos
WHERE categoria = 'Accesorios'
ORDER BY precio ASC;

-- Ejercicio 2. Clientes por ciudad.
SELECT ciudad, COUNT(*) AS total_clientes
FROM clientes
GROUP BY ciudad;

-- Ejercicio 3. Pedidos con nombre completo del cliente y su estado.
SELECT p.pedido_id, CONCAT(c.nombre, ' ', c.apellido) AS cliente, p.estado
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id;

-- Ejercicio 4. Cantidad total vendida por producto (0 si nunca se vendió).
SELECT pr.nombre, IFNULL(SUM(d.cantidad), 0) AS unidades_vendidas
FROM productos pr
LEFT JOIN detalle_pedido d ON d.producto_id = pr.producto_id
GROUP BY pr.producto_id, pr.nombre
ORDER BY unidades_vendidas DESC;

-- Ejercicio 5. Clientes que compraron productos de Audio, sin duplicados.
SELECT DISTINCT c.nombre, c.apellido
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
JOIN detalle_pedido d ON d.pedido_id = p.pedido_id
JOIN productos pr ON pr.producto_id = d.producto_id
WHERE pr.categoria = 'Audio';

-- Ejercicio 6. Pedidos cuyo total supera 100 con nombre del cliente.
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

-- Ejercicio 7. Cada empleado con jefe y jefe de su jefe.
SELECT e.nombre AS empleado,
       j.nombre AS jefe,
       s.nombre AS jefe_superior
FROM empleados e
LEFT JOIN empleados j ON j.empleado_id = e.jefe_id
LEFT JOIN empleados s ON s.empleado_id = j.jefe_id;

-- Ejercicio 8. Producto más vendido por unidades.
SELECT pr.nombre, SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedido d
JOIN productos pr ON pr.producto_id = d.producto_id
GROUP BY pr.producto_id, pr.nombre
ORDER BY unidades_vendidas DESC
LIMIT 1;

-- Ejercicio 9. Aumenta 5% el precio de los productos de Audio y verifica.
UPDATE productos
SET precio = ROUND(precio * 1.05, 2)
WHERE categoria = 'Audio';

SELECT nombre, precio FROM productos WHERE categoria = 'Audio';

-- =========================================================
-- 19. Errores comunes y cómo resolverlos
-- =========================================================
-- 1049 Unknown database -> crea la BD o revisa el nombre.
-- 1046 No database selected -> ejecuta USE tienda_db;
-- 1146 Table doesn't exist -> revisa SHOW TABLES; y mayúsculas/minúsculas.
-- 1062 Duplicate entry -> PK o UNIQUE repetido.
-- 1451 Cannot delete or update a parent row -> borra hijos o usa ON DELETE CASCADE.
-- 1452 Cannot add or update a child row -> inserta primero el registro padre.
-- 1364 Field doesn't have a default value -> falta NOT NULL o DEFAULT.
-- 1054 Unknown column -> nombre de columna mal escrito.
-- 1175 safe update mode -> agrega WHERE con columna indexada.
-- Acentos como ? -> usa utf8mb4 en la base y tablas.

-- =========================================================
-- 20. Diferencias frecuentes con SQL Server
-- =========================================================
-- MySQL: LIMIT 3  | SQL Server: TOP 3
-- MySQL: AUTO_INCREMENT | SQL Server: IDENTITY(1,1)
-- MySQL: CONCAT(a,b) | SQL Server: a + b
-- MySQL: NOW() / CURDATE() | SQL Server: GETDATE()
-- MySQL: IFNULL(x,y) | SQL Server: ISNULL(x,y)
-- MySQL: FULL JOIN se simula con UNION
-- MySQL: LAST_INSERT_ID() | SQL Server: SCOPE_IDENTITY()

-- =========================================================
-- 21. Buenas prácticas
-- =========================================================
-- - Usa nombres de columnas en lugar de SELECT * en producción.
-- - Usa WHERE en cada UPDATE y DELETE y prueba antes con SELECT.
-- - Usa transacciones cuando modifiques varias tablas.
-- - Nombra tablas y columnas consistentemente.
-- - Haz respaldos periódicos con mysqldump y prueba restaurarlos.
-- - Crea índices solo donde se necesiten y revisa con EXPLAIN.
-- - Valida datos con CHECK, FOREIGN KEY y UNIQUE.

-- =========================================================
-- 22. Comandos rápidos
-- =========================================================
-- CREATE DATABASE nombre;
-- USE nombre;
-- CREATE TABLE t (...);
-- ALTER TABLE t ADD COLUMN col tipo;
-- INSERT INTO t (cols) VALUES (...);
-- SELECT cols FROM t WHERE cond ORDER BY col LIMIT n;
-- SELECT ... FROM a JOIN b ON a.id = b.a_id;
-- SELECT col, COUNT(*) FROM t GROUP BY col HAVING COUNT(*) > 1;
-- UPDATE t SET col = val WHERE cond;
-- DELETE FROM t WHERE cond;
-- CREATE VIEW v AS SELECT ...;
-- CALL sp_nombre(param);
-- START TRANSACTION; ... COMMIT; -- o ROLLBACK;
-- CREATE INDEX ix ON t (col);

-- Backup desde terminal:
-- mysqldump -u root -p tienda_db > respaldo_tienda_db.sql

-- =========================================================
-- 23. Siguientes pasos
-- =========================================================
-- 1. Repite los ejercicios cambiando condiciones y datos.
-- 2. Diseña una base de datos propia (biblioteca, escuela, inventario).
-- 3. Aprende funciones de ventana: ROW_NUMBER(), RANK(), SUM() OVER.
-- 4. Consulta la documentación oficial de MySQL para profundizar.

-- FIN DEL SCRIPT
