with num as (
    select
        pedido_id,
        tiempo_promesa_min as tiempo_texto,
        try_to_number(tiempo_promesa_min) as tiempo_num
    from {{ source('raw', 'pedidos') }}
)

select 
    tiempo_texto, tiempo_num, count(*) as n
from num
group by 1, 2
order by n desc


-- with dist as (
--     select
--         pedido_id,
--         distancia_km as distancia_texto,
--         try_to_decimal(replace(distancia_km, ',', '.'), 6, 1) as distancia_num
--     from {{ source('raw', 'pedidos') }}
-- )

-- select distancia_texto, distancia_num, count(*) as n
-- from dist
-- where distancia_num < 1
--    or distancia_num is null
-- group by 1, 2
-- order by n desc