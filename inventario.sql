CREATE TABLE proveedor (
    idProveedor SERIAL PRIMARY KEY,
    nombreProveedor VARCHAR(70) NOT NULL,
    contactoProveedor VARCHAR(70) NOT NULL,
    telefonoProveedor VARCHAR(20) NOT NULL,
    paisProveedor VARCHAR(25) NOT NULL
);

CREATE TABLE categoria (
	idCategoria SERIAL PRIMARY KEY,
	nombreCategoria VARCHAR(30) NOT NULL
);
ALTER TABLE categoria
ADD CONSTRAINT uq_categoria
UNIQUE (nombreCategoria);

CREATE TABLE subcategoria (
	idSubcategoria SERIAL PRIMARY KEY,
	idCategoria INT NOT NULL,

	FOREIGN KEY (idCategoria)
	REFERENCES categoria (idCategoria),

	nombreSubcategoria VARCHAR(30) NOT NULL
);
ALTER TABLE subcategoria
ADD CONSTRAINT uq_subcategoria
UNIQUE (idCategoria, nombreSubcategoria);

CREATE TABLE producto (
	idProducto SERIAL PRIMARY KEY,
	sku VARCHAR(7) UNIQUE NOT NULL,
	nombreProducto VARCHAR(65) NOT NULL,
	idSubcategoria INT NOT NULL,
	
	FOREIGN KEY (idSubcategoria)
	REFERENCES subcategoria (idSubcategoria),
	
	costoUnitario NUMERIC(12,2) NOT NULL,
	precioVenta  NUMERIC(12,2) NOT NULL,
	idProveedor INT NOT NULL,

	FOREIGN KEY (idProveedor)
	REFERENCES proveedor(idProveedor)
);
ALTER TABLE producto
ADD CONSTRAINT chk_costo
CHECK (costoUnitario >= 0);

ALTER TABLE producto
ADD CONSTRAINT chk_precio
CHECK (precioVenta >= 0);

CREATE TABLE almacen (
	idAlmacen SERIAL PRIMARY KEY,
	nombreAlmacen VARCHAR(70) NOT NULL,
	ubicacionAlmacen VARCHAR(40) NOT NULL
);
ALTER TABLE almacen
ADD CONSTRAINT uq_nombre_almacen
UNIQUE (nombreAlmacen);

CREATE TABLE ubicacion (
	idUbicacion SERIAL PRIMARY KEY,
	idAlmacen INT NOT NULL,
	
	FOREIGN KEY (idAlmacen)
	REFERENCES almacen (idAlmacen),
	
	pasillo VARCHAR(10) NOT NULL,
	estante VARCHAR(10) NOT NULL
);
ALTER TABLE ubicacion
ADD CONSTRAINT uq_ubicacion
UNIQUE (idAlmacen, pasillo, estante);

CREATE TABLE inventario (
	idInventario SERIAL PRIMARY KEY NOT NULL UNIQUE,
	idProducto INT NOT NULL,
	idAlmacen INT NOT NULL,
	
	FOREIGN KEY (idProducto)
	REFERENCES producto (idProducto),

	FOREIGN KEY (idAlmacen)
	REFERENCES almacen (idAlmacen),

	cantidadStock int NOT NULL,
	stockMinimo INT NOT NULL,
	stockOptimo INT NOT NULL,
	estadoStock VARCHAR(20)
	GENERATED ALWAYS AS (
	    CASE
	        WHEN cantidadStock = 0 THEN 'Agotado'
	        WHEN cantidadStock <= stockMinimo THEN 'Reordenar'
	        ELSE 'En stock'
	    END
	) STORED,
	UNIQUE (idProducto, idAlmacen),
	CHECK (cantidadStock >= 0),
    CHECK (stockMinimo >= 0),
    CHECK (stockOptimo >= stockMinimo)
);

INSERT INTO categoria (nombreCategoria)
VALUES
    ('Electrónica'),
    ('Muebles'),
    ('Accesorios');

INSERT INTO subcategoria (
    idCategoria,
    nombreSubcategoria
)
VALUES
    (1, 'Monitores'),
    (1, 'Periféricos'),
    (2, 'Oficina'),
    (3, 'Periféricos'),
    (3, 'Cables');	

INSERT INTO proveedor (
	nombreProveedor, contactoProveedor, telefonoProveedor, paisProveedor)
VALUES
	('Tech Supplies Co.', 'Carlos Ruiz', '+506 8888-1111', 'Costa Rica'),
	('Muebles & Confort', 'Ana Gómez', '+506 8888-2222', 'Costa Rica'),
	('Importadora Global', 'Luis Mora', '+506 8888-3333', 'Costa Rica');

-- inserciones :p
INSERT INTO producto (sku, nombreProducto, idSubcategoria, costoUnitario, precioVenta, idProveedor)
VALUES
	('ELE-101', 'Monitor Gamer 27" 144Hz', 1, 180.00, 280.00, 1),
	('ELE-102', 'Teclado Mecánico RGB', 2, 35.00, 65.00, 1),
	('OFF-201', 'Silla Ergonómica Ejecutiva', 3, 110.00, 195.00, 2),
	('OFF-202', 'Escritorio Ajustable de Pie', 3, 210.00, 350.00, 2),
	('ACC-301', 'Mousepad XL Antideslizante', 4, 6.50, 15.00, 3),
	('ACC-302', 'Cable HDMI 2.1 2m', 5, 3.00, 8.00, 3);

INSERT INTO almacen (nombreAlmacen, ubicacionAlmacen)
VALUES
	('Almacén Central', 'Cartago, Costa Rica'),
	('Bodega Norte', 'San José, Costa Rica');

INSERT INTO ubicacion (idAlmacen, pasillo, estante)
VALUES
	(1, 'A', '01'),
	(1, 'A', '02'),
	(1, 'B', '05'),
	(1, 'B', '06'),
	(2, 'C', '01'),
	(2, 'C', '03');


INSERT INTO inventario (idProducto, idAlmacen, cantidadStock, stockMinimo, stockOptimo)
VALUES
    (1, 1, 15, 5, 10),
    (2, 1, 4, 10, 20),
    (3, 1, 8, 3, 6),
    (4, 1, 0, 2, 4),
    (5, 2, 45, 15, 30),
    (6, 2, 8, 12, 24);
--

CREATE TABLE movimiento (
    idMovimiento SERIAL PRIMARY KEY,
    sku VARCHAR(7) NOT NULL,
    idAlmacen INT NOT NULL,
    tipoMovimiento VARCHAR(15) NOT NULL,
    cantidad INT NOT NULL,
    fechaMovimiento TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,
    idProveedor INT,

    FOREIGN KEY (sku)
    REFERENCES producto(sku),

    FOREIGN KEY (idAlmacen)
    REFERENCES almacen(idAlmacen),

    FOREIGN KEY (idProveedor)
    REFERENCES proveedor(idProveedor),

    CHECK (tipoMovimiento IN ('Entrada', 'Salida')),
    CHECK (cantidad > 0)
);

INSERT INTO movimiento (sku, idAlmacen, tipoMovimiento, cantidad, fechaMovimiento, idProveedor)
VALUES
    ('ELE-101', 1, 'Entrada', 10, '2026-10-15', 1),
    ('ELE-102', 1, 'Entrada', 20, '2026-09-20', 1),
    ('OFF-201', 1, 'Entrada', 5, '2026-10-01', 2),
    ('OFF-202', 1, 'Entrada', 2, '2026-08-10', 2),
    ('ACC-301', 2, 'Entrada', 50, '2026-10-18', 3),
    ('ACC-302', 2, 'Entrada', 30, '2026-09-05', 3);
	
-- control de acceso

CREATE ROLE db_admin NOLOGIN;
CREATE ROLE inventory_manager NOLOGIN;
CREATE ROLE auditor NOLOGIN;

GRANT USAGE ON SCHEMA public
TO inventory_manager;

GRANT SELECT, INSERT, UPDATE
ON producto, inventario
TO inventory_manager;

GRANT SELECT
ON categoria, subcategoria,
   proveedor, almacen, ubicacion
TO inventory_manager;

GRANT SELECT
ON movimiento
TO inventory_manager;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO inventory_manager;


GRANT USAGE ON SCHEMA public
TO auditor;

GRANT SELECT
ON producto, categoria, subcategoria,
   almacen, ubicacion, movimiento
TO auditor;

GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA public
TO db_admin;

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA public
TO db_admin;

GRANT USAGE, CREATE
ON SCHEMA public
TO db_admin;

-- seguridad a nivel de filas
-- Gestores de cada almacén
CREATE ROLE gestorCentral NOLOGIN;
CREATE ROLE gestorNorte NOLOGIN;

GRANT inventory_manager TO gestorCentral;
GRANT inventory_manager TO gestorNorte;

CREATE TABLE usuarioAlmacen (
    idAsignacion SERIAL PRIMARY KEY,
    nombreUsuario VARCHAR(65) NOT NULL,
    idAlmacen INT NOT NULL,

    FOREIGN KEY (idAlmacen)
    REFERENCES almacen(idAlmacen),

    UNIQUE (nombreUsuario, idAlmacen)
);

INSERT INTO usuarioAlmacen (nombreUsuario, idAlmacen)
VALUES
    ('gestorcentral', 1),
    ('gestornorte', 2);

GRANT SELECT
ON usuarioAlmacen
TO inventory_manager;

ALTER TABLE inventario
ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_inventario_select
ON inventario
FOR SELECT
TO inventory_manager
USING (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = inventario.idAlmacen
    )
);

CREATE POLICY rls_inventario_update
ON inventario
FOR UPDATE
TO inventory_manager
USING (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = inventario.idAlmacen
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = inventario.idAlmacen
    )
);

CREATE POLICY rls_inventario_insert
ON inventario
FOR INSERT
TO inventory_manager
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = inventario.idAlmacen
    )
);

--
ALTER TABLE movimiento
ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_movimiento_select
ON movimiento
FOR SELECT
TO inventory_manager
USING (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = movimiento.idAlmacen
    )
);
--
CREATE POLICY rls_movimiento_auditor
ON movimiento
FOR SELECT
TO auditor
USING (true);

--Primer reporte
CREATE OR REPLACE FUNCTION
sp_reporte_valoracion_reabastecimiento(
    p_almacenid INT,
    p_margenalerta NUMERIC(5,2) DEFAULT 0
)
RETURNS TABLE (
    almacen TEXT,
    sku TEXT,
    producto TEXT,
    categoria TEXT,
    stock_actual INT,
    stock_minimo INT,
    stock_optimo INT,
    unidades_pedir INT,
    costo_unitario NUMERIC,
    valor_inventario NUMERIC,
    costo_reposicion NUMERIC,
    valor_total_almacen NUMERIC,
    presupuesto_total_almacen NUMERIC,
    estado TEXT
)
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN

    IF p_margenalerta IS NULL
       OR p_margenalerta < 0
       OR p_margenalerta > 100 THEN

        RAISE EXCEPTION
        'El margen de alerta debe estar entre 0 y 100';
    END IF;

    IF p_almacenid IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM public.almacen a
           WHERE a.idalmacen = p_almacenid
       ) THEN

        RAISE EXCEPTION
        'El almacén % no existe', p_almacenid;
    END IF;

    CREATE TEMP TABLE IF NOT EXISTS tmp_valoracion (
        almacen TEXT,
        sku TEXT,
        producto TEXT,
        categoria TEXT,
        stock_actual INT,
        stock_minimo INT,
        stock_optimo INT,
        unidades_pedir INT,
        costo_unitario NUMERIC,
        valor_inventario NUMERIC,
        costo_reposicion NUMERIC,
        estado TEXT,
        prioridad INT
    ) ON COMMIT DROP;

    TRUNCATE TABLE pg_temp.tmp_valoracion;

    INSERT INTO pg_temp.tmp_valoracion
    SELECT
        a.nombrealmacen::TEXT,
        p.sku::TEXT,
        p.nombreproducto::TEXT,
        c.nombrecategoria::TEXT,

        i.cantidadstock,
        i.stockminimo,
        i.stockoptimo,

        GREATEST(
            i.stockoptimo - i.cantidadstock, 0
        ),

        p.costounitario,

        i.cantidadstock * p.costounitario,

        GREATEST(
            i.stockoptimo - i.cantidadstock, 0
        ) * p.costounitario,

        CASE
            WHEN i.cantidadstock = 0
                THEN 'Agotado'

            WHEN i.cantidadstock <= i.stockminimo
                THEN 'Crítico'

            WHEN i.cantidadstock <=
                 i.stockminimo * (1 + p_margenalerta / 100)
                THEN 'En alerta'

            WHEN i.cantidadstock < i.stockoptimo
                THEN 'Reabastecer'

            ELSE 'Óptimo'
        END,

        CASE
            WHEN i.cantidadstock = 0 THEN 1
            WHEN i.cantidadstock <= i.stockminimo THEN 2
            WHEN i.cantidadstock <=
                 i.stockminimo * (1 + p_margenalerta / 100)
                THEN 3
            WHEN i.cantidadstock < i.stockoptimo THEN 4
            ELSE 5
        END

    FROM public.inventario i

    JOIN public.producto p
        ON i.idproducto = p.idproducto

    JOIN public.subcategoria s
        ON p.idsubcategoria = s.idsubcategoria

    JOIN public.categoria c
        ON s.idcategoria = c.idcategoria

    JOIN public.almacen a
        ON i.idalmacen = a.idalmacen

    WHERE p_almacenid IS NULL
       OR i.idalmacen = p_almacenid;

    RETURN QUERY

    SELECT
        t.almacen,
        t.sku,
        t.producto,
        t.categoria,
        t.stock_actual,
        t.stock_minimo,
        t.stock_optimo,
        t.unidades_pedir,
        t.costo_unitario,
        t.valor_inventario,
        t.costo_reposicion,

        SUM(t.valor_inventario) OVER (
            PARTITION BY t.almacen
        ),

        SUM(t.costo_reposicion) OVER (
            PARTITION BY t.almacen
        ),

        t.estado

    FROM pg_temp.tmp_valoracion t

    ORDER BY
        t.prioridad,
        t.almacen,
        t.sku;

END;
$$;

REVOKE ALL
ON FUNCTION
sp_reporte_valoracion_reabastecimiento(INT, NUMERIC)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION
sp_reporte_valoracion_reabastecimiento(INT, NUMERIC)
TO db_admin, inventory_manager;

CREATE POLICY rls_inventario_admin
ON inventario
FOR ALL
TO db_admin
USING (true)
WITH CHECK (true);

--Segundo reporte
GRANT SELECT
ON inventario
TO auditor;

CREATE POLICY rls_inventario_auditor
ON inventario
FOR SELECT
TO auditor
USING (true);

--
CREATE OR REPLACE FUNCTION sp_reporte_rotacion_inventario(
    p_fechainicio DATE,
    p_fechafin DATE,
    p_categoriaid INT DEFAULT NULL
)
RETURNS TABLE (
    sku TEXT,
    producto TEXT,
    categoria TEXT,
    stock_promedio NUMERIC,
    total_salidas_unidades BIGINT,
    valor_total_salidas_usd NUMERIC,
    promedio_diario_salidas NUMERIC,
    dias_inventario_restante NUMERIC,
    indice_rotacion NUMERIC,
    clasificacion_abc TEXT
)
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    v_dias INT;
BEGIN

    IF p_fechainicio IS NULL OR p_fechafin IS NULL THEN
        RAISE EXCEPTION
        'Las fechas de inicio y fin son obligatorias';
    END IF;

    IF p_fechainicio > p_fechafin THEN
        RAISE EXCEPTION
        'La fecha de inicio (%) no puede ser después a la fecha fin (%). Operación cancelada.',
        p_fechainicio, p_fechafin;
    END IF;

    IF p_categoriaid IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM public.categoria c
           WHERE c.idcategoria = p_categoriaid
       ) THEN
        RAISE EXCEPTION
        'La categoría % no existe', p_categoriaid;
    END IF;

    v_dias := p_fechafin - p_fechainicio + 1;

    CREATE TEMP TABLE IF NOT EXISTS tmp_rotacion (
        codigo TEXT,
        nombre TEXT,
        nombre_categoria TEXT,
        stock_actual BIGINT,
        entradas NUMERIC,
        salidas NUMERIC,
        precio_venta NUMERIC
    ) ON COMMIT DROP;

    TRUNCATE TABLE pg_temp.tmp_rotacion;

    INSERT INTO pg_temp.tmp_rotacion
    SELECT
        p.sku::TEXT,
        p.nombreproducto::TEXT,
        c.nombrecategoria::TEXT,
        SUM(i.cantidadstock),
        SUM(m.entradas),
        SUM(m.salidas),
        p.precioventa
    FROM public.inventario i

    JOIN public.producto p
        ON i.idproducto = p.idproducto

    JOIN public.subcategoria s
        ON p.idsubcategoria = s.idsubcategoria

    JOIN public.categoria c
        ON s.idcategoria = c.idcategoria

    CROSS JOIN LATERAL (
        SELECT 1
    ) AS auxiliar

    LEFT JOIN LATERAL (
        SELECT
            COALESCE(SUM(
                CASE WHEN mov.tipomovimiento = 'Entrada'
                     THEN mov.cantidad ELSE 0 END
            ), 0) AS entradas,

            COALESCE(SUM(
                CASE WHEN mov.tipomovimiento = 'Salida'
                     THEN mov.cantidad ELSE 0 END
            ), 0) AS salidas

        FROM public.movimiento mov
        WHERE mov.sku = p.sku
          AND mov.idalmacen = i.idalmacen
          AND mov.fechamovimiento >= p_fechainicio
          AND mov.fechamovimiento < p_fechafin + INTERVAL '1 day'
    ) m ON TRUE

    WHERE p_categoriaid IS NULL
       OR c.idcategoria = p_categoriaid

    GROUP BY
        p.sku,
        p.nombreproducto,
        c.nombrecategoria,
        p.precioventa;

    RETURN QUERY

    WITH calculos AS (
        SELECT
            t.*,

            GREATEST(
                0::NUMERIC,
                (
                    t.stock_actual +
                    GREATEST(
                        0::NUMERIC,
                        t.stock_actual - t.entradas + t.salidas
                    )
                ) / 2
            ) AS promedio_estimado

        FROM pg_temp.tmp_rotacion t
    ),

    metricas AS (
        SELECT
            c.codigo,
            c.nombre,
            c.nombre_categoria,

            ROUND(c.promedio_estimado, 2) AS promedio,

            c.salidas::BIGINT AS total_salidas,

            ROUND(
                c.salidas * c.precio_venta, 2
            ) AS valor_salidas,

            ROUND(
                c.salidas / v_dias, 2
            ) AS salidas_diarias,

            CASE
                WHEN c.salidas = 0 THEN NULL
                ELSE ROUND(
                    c.stock_actual * v_dias / c.salidas,
                    2
                )
            END AS dias_restantes,

            CASE
                WHEN c.promedio_estimado = 0 THEN NULL
                ELSE ROUND(
                    c.salidas / c.promedio_estimado,
                    2
                )
            END AS rotacion

        FROM calculos c
    ),

    ordenados AS (
        SELECT
            m.*,

            SUM(m.valor_salidas) OVER ()
                AS valor_global,

            COALESCE(
                SUM(m.valor_salidas) OVER (
                    ORDER BY m.valor_salidas DESC, m.codigo
                    ROWS BETWEEN UNBOUNDED PRECEDING
                    AND 1 PRECEDING
                ), 0
            ) AS valor_acumulado_anterior

        FROM metricas m
    )

    SELECT
        o.codigo,
        o.nombre,
        o.nombre_categoria,
        o.promedio,
        o.total_salidas,
        o.valor_salidas,
        o.salidas_diarias,
        o.dias_restantes,
        o.rotacion,

        CASE
            WHEN o.valor_global = 0 THEN 'Sin salidas'

            WHEN o.valor_acumulado_anterior
                 / o.valor_global < 0.80
                 THEN 'Clase A (Alto valor)'

            WHEN o.valor_acumulado_anterior
                 / o.valor_global < 0.95
                 THEN 'Clase B (Valor medio)'

            ELSE 'Clase C (Bajo valor)'
        END

    FROM ordenados o

    ORDER BY
        o.valor_salidas DESC,
        o.codigo;

END;
$$;

CREATE POLICY rls_movimiento_admin
ON movimiento
FOR SELECT
TO db_admin
USING (true);


REVOKE ALL
ON FUNCTION sp_reporte_rotacion_inventario(DATE, DATE, INT)
FROM PUBLIC;

GRANT EXECUTE
ON FUNCTION sp_reporte_rotacion_inventario(DATE, DATE, INT)
TO auditor, inventory_manager, db_admin;

--Inserción de datos para pruebas!!
INSERT INTO movimiento (sku, idAlmacen, tipoMovimiento, cantidad, fechaMovimiento, idProveedor)
VALUES
    ('ELE-101', 1, 'Salida', 3, '2026-11-10', NULL),
    ('ELE-102', 1, 'Salida', 2, '2026-11-12', NULL),
    ('OFF-201', 1, 'Salida', 1, '2026-11-15', NULL),
    ('ACC-301', 2, 'Salida', 5, '2026-11-18', NULL),
    ('ACC-302', 2, 'Salida', 2, '2026-11-20', NULL);
--

SELECT
    sku,
    stock_promedio,
    total_salidas_unidades,
    promedio_diario_salidas,
    dias_inventario_restante,
    indice_rotacion
FROM sp_reporte_rotacion_inventario(
    '2026-11-01'::DATE,
    '2026-11-27'::DATE,
    1
)
WHERE sku = 'ELE-101';

--Transacciones :p
CREATE TABLE venta (
    idVenta SERIAL PRIMARY KEY,
    idAlmacen INT NOT NULL,
    fechaVenta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuarioResponsable VARCHAR(65) NOT NULL,
    totalVenta NUMERIC(12,2) NOT NULL CHECK (totalVenta >= 0),

    FOREIGN KEY (idAlmacen)
    REFERENCES almacen(idAlmacen)
);
CREATE TABLE detalleVenta (
    idDetalleV SERIAL PRIMARY KEY,
    idVenta INT NOT NULL,
    idProducto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precioUnidad NUMERIC(12,2) NOT NULL CHECK (precioUnidad >= 0),
    subtotal NUMERIC(12,2)
        GENERATED ALWAYS AS (cantidad * precioUnidad) STORED,

    FOREIGN KEY (idVenta)
    REFERENCES venta(idVenta),
    FOREIGN KEY (idProducto)
    REFERENCES producto(idProducto),

    UNIQUE (idVenta, idProducto)
);
CREATE TABLE transferencia (
    idTransferencia SERIAL PRIMARY KEY,
    idAlmacenOriginal INT NOT NULL,
    idAlmacenDestino INT NOT NULL,
    fechaTransferencia TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuarioEncargado VARCHAR(65) NOT NULL,

    FOREIGN KEY (idAlmacenOriginal)
    REFERENCES almacen(idAlmacen),
    FOREIGN KEY (idAlmacenDestino)
    REFERENCES almacen(idAlmacen),

    CHECK (idAlmacenOriginal <> idAlmacenDestino)
);
CREATE TABLE detalleTransferencia (
    idDetalleT SERIAL PRIMARY KEY,
    idTransferencia INT NOT NULL,
    idProducto INT NOT NULL,
    cantidadT INT NOT NULL CHECK (cantidadT > 0),

    FOREIGN KEY (idTransferencia)
    REFERENCES transferencia(idTransferencia),
    FOREIGN KEY (idProducto)
    REFERENCES producto(idProducto),

    UNIQUE (idTransferencia, idProducto)
);

ALTER TABLE venta ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalleventa ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_venta_select
ON venta
FOR SELECT
TO inventory_manager
USING (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = venta.idAlmacen
    )
);

CREATE POLICY rls_venta_insert
ON venta
FOR INSERT
TO inventory_manager
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM usuarioAlmacen ua
        WHERE ua.nombreUsuario = CURRENT_USER
          AND ua.idAlmacen = venta.idAlmacen
    )
);

CREATE POLICY rls_detalleventa_select
ON detalleventa
FOR SELECT
TO inventory_manager
USING (
    EXISTS (
        SELECT 1
        FROM venta v
        JOIN usuarioAlmacen ua
          ON ua.idAlmacen = v.idAlmacen
        WHERE v.idVenta = detalleventa.idVenta
          AND ua.nombreUsuario = CURRENT_USER
    )
);
CREATE POLICY rls_detalleventa_insert
ON detalleventa
FOR INSERT
TO inventory_manager
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM venta v
        JOIN usuarioAlmacen ua
          ON ua.idAlmacen = v.idAlmacen
        WHERE v.idVenta = detalleventa.idVenta
          AND ua.nombreUsuario = CURRENT_USER
    )
);

REVOKE ALL ON venta, detalleventa
FROM PUBLIC, inventory_manager, auditor;

GRANT SELECT ON venta, detalleventa
TO inventory_manager;

GRANT SELECT ON venta, detalleventa
TO db_admin;


CREATE OR REPLACE PROCEDURE sp_procesar_venta(
    p_idAlmacen INT,
    p_productos JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
    v_usuario TEXT;
    v_esAdmin BOOLEAN;
    v_idVenta INT;
    v_total NUMERIC(12,2) := 0;
    v_producto RECORD;
BEGIN
    v_usuario := current_setting('role');

    IF v_usuario = 'none' THEN
        v_usuario := SESSION_USER;
    END IF;

    v_esAdmin := pg_has_role(
        v_usuario, 'db_admin', 'member'
    );

    IF NOT (
        v_esAdmin OR
        pg_has_role(v_usuario, 'inventory_manager', 'member')
    ) THEN
        RAISE EXCEPTION
            'Usuario % no autorizado para realizar ventas',
            v_usuario;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM almacen
        WHERE idAlmacen = p_idAlmacen
    ) THEN
        RAISE EXCEPTION 'El almacén no existe';
    END IF;

    IF NOT v_esAdmin AND NOT EXISTS (
        SELECT 1
        FROM usuarioAlmacen
        WHERE nombreUsuario = v_usuario
          AND idAlmacen = p_idAlmacen
    ) THEN
        RAISE EXCEPTION
            'El usuario % no tiene acceso al almacén %',
            v_usuario, p_idAlmacen;
    END IF;

    IF p_productos IS NULL
       OR jsonb_typeof(p_productos) IS DISTINCT FROM 'array'
    THEN
        RAISE EXCEPTION
            'El pedido debe ser un arreglo JSON';
    END IF;

    IF jsonb_array_length(p_productos) = 0 THEN
        RAISE EXCEPTION 'El pedido está vacío';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        WHERE NULLIF(BTRIM(x.sku), '') IS NULL
           OR x.cantidad IS NULL
           OR x.cantidad <= 0
    ) THEN
        RAISE EXCEPTION
            'El pedido tiene productos o cantidades inválidas';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        GROUP BY x.sku
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION
            'El pedido tiene productos repetidos';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p ON p.sku = x.sku
        JOIN inventario i
          ON i.idProducto = p.idProducto
         AND i.idAlmacen = p_idAlmacen
    ) <> jsonb_array_length(p_productos) THEN
        RAISE EXCEPTION
            'Algún producto no existe en el inventario del almacén';
    END IF;

    FOR v_producto IN
        SELECT
            x.sku,
            x.cantidad,
            i.cantidadStock
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p ON p.sku = x.sku
        JOIN inventario i
          ON i.idProducto = p.idProducto
         AND i.idAlmacen = p_idAlmacen
        ORDER BY p.idProducto
        FOR UPDATE OF i
    LOOP
        IF v_producto.cantidadStock < v_producto.cantidad THEN
            RAISE EXCEPTION
                'Stock insuficiente para %. Disponible: %, solicitado: %',
                v_producto.sku,
                v_producto.cantidadStock,
                v_producto.cantidad;
        END IF;
    END LOOP;

    INSERT INTO venta (
        idAlmacen,
        usuarioResponsable,
        totalVenta
    )
    VALUES (
        p_idAlmacen,
        v_usuario,
        0
    )
    RETURNING idVenta INTO v_idVenta;

    FOR v_producto IN
        SELECT
            x.sku,
            x.cantidad,
            p.idProducto,
            p.precioVenta,
            i.idInventario
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p ON p.sku = x.sku
        JOIN inventario i
          ON i.idProducto = p.idProducto
         AND i.idAlmacen = p_idAlmacen
        ORDER BY p.idProducto
    LOOP

        INSERT INTO detalleVenta (
            idVenta,
            idProducto,
            cantidad,
            precioUnidad
        )
        VALUES (
            v_idVenta,
            v_producto.idProducto,
            v_producto.cantidad,
            v_producto.precioVenta
        );

        UPDATE inventario
        SET cantidadStock = cantidadStock - v_producto.cantidad
        WHERE idInventario = v_producto.idInventario;

        INSERT INTO movimiento (
            sku,
            idAlmacen,
            tipoMovimiento,
            cantidad
        )
        VALUES (
            v_producto.sku,
            p_idAlmacen,
            'Salida',
            v_producto.cantidad
        );

        v_total := v_total +
            (v_producto.cantidad * v_producto.precioVenta);

    END LOOP;

    UPDATE venta
    SET totalVenta = v_total
    WHERE idVenta = v_idVenta;

    RAISE NOTICE
        'Venta % procesada correctamente. Total: %',
        v_idVenta, v_total;

END;
$$;

REVOKE ALL ON PROCEDURE sp_procesar_venta(INT, JSONB)
FROM PUBLIC;

GRANT EXECUTE ON PROCEDURE sp_procesar_venta(INT, JSONB)
TO inventory_manager, db_admin;

ALTER TABLE transferencia
ENABLE ROW LEVEL SECURITY;

ALTER TABLE detalleTransferencia
ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON transferencia, detalleTransferencia
FROM PUBLIC, inventory_manager, auditor;

GRANT SELECT ON transferencia, detalleTransferencia
TO db_admin;
--

CREATE OR REPLACE PROCEDURE sp_transferir_inventario(
    p_almacenOrigen INT,
    p_almacenDestino INT,
    p_productos JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
    v_usuario TEXT;
    v_esAdmin BOOLEAN;
    v_idTransferencia INT;
    v_producto RECORD;
BEGIN

    v_usuario := current_setting('role');

    IF v_usuario = 'none' THEN
        v_usuario := SESSION_USER;
    END IF;

    v_esAdmin := pg_has_role(
        v_usuario, 'db_admin', 'member'
    );

    IF NOT (
        v_esAdmin OR
        pg_has_role(v_usuario, 'inventory_manager', 'member')
    ) THEN
        RAISE EXCEPTION
            'Usuario % no autorizado para transferencias',
            v_usuario;
    END IF;

    IF p_almacenOrigen IS NULL
       OR p_almacenDestino IS NULL
       OR p_almacenOrigen = p_almacenDestino
    THEN
        RAISE EXCEPTION
            'El origen y destino deben ser diferentes y válidos';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM almacen
        WHERE idAlmacen IN (
            p_almacenOrigen,
            p_almacenDestino
        )
    ) <> 2 THEN
        RAISE EXCEPTION
            'Uno o ambos almacenes no existen';
    END IF;

    IF NOT v_esAdmin AND (
        SELECT COUNT(*)
        FROM usuarioAlmacen
        WHERE nombreUsuario = v_usuario
          AND idAlmacen IN (
              p_almacenOrigen,
              p_almacenDestino
          )
    ) <> 2 THEN
        RAISE EXCEPTION
            'El usuario % no tiene autorización en ambos almacenes',
            v_usuario;
    END IF;

    IF p_productos IS NULL
       OR jsonb_typeof(p_productos) IS DISTINCT FROM 'array'
    THEN
        RAISE EXCEPTION
            'Los productos deben enviarse como un arreglo JSON';
    END IF;

    IF jsonb_array_length(p_productos) = 0 THEN
        RAISE EXCEPTION
            'La transferencia no puede estar vacía';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        WHERE NULLIF(BTRIM(x.sku), '') IS NULL
           OR x.cantidad IS NULL
           OR x.cantidad <= 0
    ) THEN
        RAISE EXCEPTION
            'Existen productos o cantidades inválidas';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        GROUP BY x.sku
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION
            'No se permiten productos repetidos';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p
          ON p.sku = x.sku
        JOIN inventario i
          ON i.idProducto = p.idProducto
         AND i.idAlmacen = p_almacenOrigen
    ) <> jsonb_array_length(p_productos) THEN
        RAISE EXCEPTION
            'Algún producto no existe en el almacén origen';
    END IF;

    FOR v_producto IN
        SELECT
            x.sku,
            x.cantidad,
            i.cantidadStock
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p
          ON p.sku = x.sku
        JOIN inventario i
          ON i.idProducto = p.idProducto
         AND i.idAlmacen = p_almacenOrigen
        ORDER BY p.idProducto
        FOR UPDATE OF i
    LOOP
        IF v_producto.cantidadStock < v_producto.cantidad THEN
            RAISE EXCEPTION
                'Stock insuficiente para %. Disponible: %, solicitado: %',
                v_producto.sku,
                v_producto.cantidadStock,
                v_producto.cantidad;
        END IF;
    END LOOP;

    INSERT INTO transferencia (
        idAlmacenOriginal,
        idAlmacenDestino,
        usuarioEncargado
    )
    VALUES (
        p_almacenOrigen,
        p_almacenDestino,
        v_usuario
    )
    RETURNING idTransferencia
    INTO v_idTransferencia;

    FOR v_producto IN
        SELECT
            x.sku,
            x.cantidad,
            p.idProducto
        FROM jsonb_to_recordset(p_productos)
             AS x(sku TEXT, cantidad INT)
        JOIN producto p
          ON p.sku = x.sku
        ORDER BY p.idProducto
    LOOP

        INSERT INTO detalleTransferencia (
            idTransferencia,
            idProducto,
            cantidadT
        )
        VALUES (
            v_idTransferencia,
            v_producto.idProducto,
            v_producto.cantidad
        );

        UPDATE inventario
        SET cantidadStock = cantidadStock - v_producto.cantidad
        WHERE idProducto = v_producto.idProducto
          AND idAlmacen = p_almacenOrigen;

        INSERT INTO inventario (
            idProducto,
            idAlmacen,
            cantidadStock,
            stockMinimo,
            stockOptimo,
            fechaUltimaEntrada,
            cantidadUltimaEntrada
        )
        VALUES (
            v_producto.idProducto,
            p_almacenDestino,
            v_producto.cantidad,
            0,
            0,
            CURRENT_DATE,
            v_producto.cantidad
        )
        ON CONFLICT (idProducto, idAlmacen)
        DO UPDATE SET
            cantidadStock =
                inventario.cantidadStock + EXCLUDED.cantidadStock,
            fechaUltimaEntrada = CURRENT_DATE,
            cantidadUltimaEntrada = EXCLUDED.cantidadUltimaEntrada;

        INSERT INTO movimiento (
            sku,
            idAlmacen,
            tipoMovimiento,
            cantidad
        )
        VALUES (
            v_producto.sku,
            p_almacenOrigen,
            'Salida',
            v_producto.cantidad
        );

        INSERT INTO movimiento (
            sku,
            idAlmacen,
            tipoMovimiento,
            cantidad
        )
        VALUES (
            v_producto.sku,
            p_almacenDestino,
            'Entrada',
            v_producto.cantidad
        );

    END LOOP;

    RAISE NOTICE
        'Transferencia % procesada correctamente',
        v_idTransferencia;

END;
$$;

REVOKE ALL ON PROCEDURE sp_transferir_inventario(
    INT, INT, JSONB
) FROM PUBLIC;

GRANT EXECUTE ON PROCEDURE sp_transferir_inventario(
    INT, INT, JSONB
) TO inventory_manager, db_admin;