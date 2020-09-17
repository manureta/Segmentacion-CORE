drop table if exists public.corrida cascade;
CREATE TABLE public.corrida (
    comando text,
    prov integer,
    dpto integer,
    frac integer,
    radio integer,
    conexion text,
    pwd text,
    user_host text,
    cuando date
);


