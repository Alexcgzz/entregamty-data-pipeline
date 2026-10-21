WITH fuente AS (

    select * from {{ source('raw', 'pedidos') }}

),

limpieza AS (

    SELECT 
        pedido_id,
        coalesce(
            try_to_timestamp(fecha_hora_pedido, 'YYYY-MM-DD HH24:MI:SS'),
            try_to_timestamp(fecha_hora_pedido, 'DD/MM/YYYY HH24:MI'),
            try_to_timestamp(fecha_hora_pedido, 'DD-MON-YYYY HH24:MI')
        ) as fecha_hora_pedido,
        coalesce(
            try_to_timestamp(fecha_hora_entrega, 'YYYY-MM-DD HH24:MI:SS'),
            try_to_timestamp(fecha_hora_entrega, 'DD/MM/YYYY HH24:MI'),
            try_to_timestamp(fecha_hora_entrega, 'DD-MON-YYYY HH24:MI')
        ) as fecha_hora_entrega,
        zona_id,
        repartidor_id,

        CASE 
            WHEN lower(trim(categoria)) in ('comida') then 'Comida'
            WHEN lower(trim(categoria)) in ('super','súper') then 'Super'
            WHEN lower(trim(categoria)) in ('paqueteria','paquetería') then 'Paqueteria'
            WHEN lower(trim(categoria)) in ('farmacia') then 'Farmacia'
            ELSE 'Desconocido'
        END as categoria,

        CASE 
            WHEN lower(trim(canal)) in ('tel.','telefono','teléfono') then 'Telefono'
            WHEN lower(trim(canal)) in ('web') then 'Web'
            WHEN lower(trim(canal)) in ('app') then 'App'
            ELSE 'Desconocido'
        END as canal,

        tipo_cliente,

        CASE 
            WHEN lower(trim(metodo_pago)) in ('tarjeta','tdc') then 'Tarjeta'
            WHEN lower(trim(metodo_pago)) in ('efectivo') then 'Efectivo'
            WHEN lower(trim(metodo_pago)) in ('transferencia', 'spei') then 'Transferencia'
            ELSE 'Desconocido'
        END as metodo_pago,

        try_to_decimal(
            nullif(regexp_replace(monto_pedido, '[^0-9.]', ''), ''), 12, 2
        ) as monto_pedido

        try_to_decimal(replace(distancia_km,',','.'),6,1) as distancia_km

        

        FROM fuente
),

reglas as (
    select 
        * exclude (monto_pedido, distancia_km),
        case 
            when monto_pedido >= 50000 then null 
            else monto_pedido 
        end as monto_pedido,

        case 
            when distancia_km <= 0 or distancia_km > 30 then null
            else distancia_km
        end as distancia_km
    from limpieza
)



select * from reglas