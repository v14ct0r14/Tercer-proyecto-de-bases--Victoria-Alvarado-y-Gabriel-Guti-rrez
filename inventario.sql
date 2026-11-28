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