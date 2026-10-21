with dist as (
    select try_to_decimal(replace(distancia_km, ',', '.'), 6, 1) as distancia_num
    from {{ source('raw', 'pedidos') }}
)
select
    min(distancia_num) as minimo,
    max(distancia_num) as maximo,
    approx_percentile(distancia_num, 0.99) as p99
from dist