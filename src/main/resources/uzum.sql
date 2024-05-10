--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: order_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA order_schema;


ALTER SCHEMA order_schema OWNER TO postgres;

--
-- Name: payment_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA payment_schema;


ALTER SCHEMA payment_schema OWNER TO postgres;

--
-- Name: product_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA product_schema;


ALTER SCHEMA product_schema OWNER TO postgres;

--
-- Name: user_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA user_schema;


ALTER SCHEMA user_schema OWNER TO postgres;

--
-- Name: delete_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
begin
    if tg_when = 'BEFORE' and tg_op = 'DELETE' then
        raise info '% deleted from %',row_to_json(old)::text,tg_table_name;
    end if;
    return old;
end;
$$;


ALTER FUNCTION public.delete_trigger() OWNER TO postgres;

--
-- Name: insert_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    declare
    begin
        if tg_when='AFTER' and tg_op='INSERT' then
            raise info '% inserted into %',row_to_json(new)::text,tg_table_name;
        end if;
        return new;
    end;
    $$;


ALTER FUNCTION public.insert_trigger() OWNER TO postgres;

--
-- Name: update_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
begin
    if tg_when='BEFORE' and tg_op='UPDATE' then
        raise info '% : % updated to %',tg_table_name,row_to_json(old)::text,row_to_json(new)::text;
    end if;
    return new;
end;
$$;


ALTER FUNCTION public.update_trigger() OWNER TO postgres;

--
-- Name: delete_company(integer, integer); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.delete_company(p_id integer, p_users_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result record;
begin
    if p_id is null or p_users_id is null then
        raise exception 'Required fields are missing!';
    end if;

    if (not exists(select 1 from companies where id = p_id)
        or not exists(select 1 from users where id = p_users_id))
           and not exists(select 1 from companies where id = p_id) then
        raise exception 'User/Company not found!';
    end if;

    update companies
    set is_deleted= true,
        updated_by=p_users_id,
        updated_at=now(),
        username=md5(username)
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.delete_company(p_id integer, p_users_id integer) OWNER TO postgres;

--
-- Name: delete_user(integer, integer); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.delete_user(p_id integer, p_users_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result record;
begin
    if p_id is null or p_users_id is null then
        raise exception 'Required fields are missing!';
    end if;

    if not exists(select 1 from users where id = p_id)
        or not exists(select 1 from users where id = p_users_id) then
        raise exception 'User not found!';
    end if;

    update users
    set is_deleted= true,
        updated_by=p_users_id,
        updated_at=now(),
        username=md5(username)
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.delete_user(p_id integer, p_users_id integer) OWNER TO postgres;

--
-- Name: register_company(text, text, text); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.register_company(p_name text, p_username text, p_password text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_name is null or p_username is null or p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username);
    company_exist := exists(select 0 from companies where username = p_username);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    insert into companies(name, username, password) values
        (p_name, p_username, md5(p_password))
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.register_company(p_name text, p_username text, p_password text) OWNER TO postgres;

--
-- Name: register_company(text, text, text, integer); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.register_company(p_name text, p_username text, p_password text, p_users_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_name is null or p_username is null or p_password is null or p_users_id is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username);
    company_exist := exists(select 0 from companies where username = p_username);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    insert into companies(name, username, password, created_by, updated_by)
    values (p_name, p_username, md5(p_password),p_users_id, p_users_id)
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.register_company(p_name text, p_username text, p_password text, p_users_id integer) OWNER TO postgres;

--
-- Name: register_user(text, text, text, boolean, text); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.register_user(p_name text, p_username text, p_password text, p_gender boolean, p_birthdate text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_name is null or p_username is null or p_gender is null or p_birthdate is null or p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username);
    company_exist := exists(select 0 from companies where username = p_username);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    insert into users(name, username, password, gender, birthdate) values
                        (p_name, p_username, md5(p_password), p_gender, p_birthdate::date)
        returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.register_user(p_name text, p_username text, p_password text, p_gender boolean, p_birthdate text) OWNER TO postgres;

--
-- Name: update_company(integer, text, text, text); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.update_company(p_id integer, p_name text, p_username text, p_password text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_id is null or p_name is null or p_username is null or
       p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username and id <> p_id);
    company_exist := exists(select 0 from companies where username = p_username and id <> p_id);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    update users
    set name=p_name,
        username=p_username,
        password=md5(p_password)
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.update_company(p_id integer, p_name text, p_username text, p_password text) OWNER TO postgres;

--
-- Name: update_company(integer, text, text, text, integer); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.update_company(p_id integer, p_name text, p_username text, p_password text, p_users_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_id is null or p_name is null or p_username is null or p_users_id is null or
       p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username and id <> p_id);
    company_exist := exists(select 0 from companies where username = p_username and id <> p_id);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    update users
    set name=p_name,
        username=p_username,
        password=md5(p_password),
        updated_by=p_users_id,
        updated_at=now()
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.update_company(p_id integer, p_name text, p_username text, p_password text, p_users_id integer) OWNER TO postgres;

--
-- Name: update_user(integer, text, text, text, boolean, date); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.update_user(p_id integer, p_name text, p_username text, p_password text, p_gender boolean, p_birthdate date) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_id is null or p_name is null or p_username is null or p_gender is null or p_birthdate is null or
       p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username and id <> p_id);
    company_exist := exists(select 0 from companies where username = p_username and id <> p_id);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    update users
    set name=p_name,
        username=p_username,
        password=md5(p_password),
        gender=p_gender,
        birthdate=p_birthdate
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.update_user(p_id integer, p_name text, p_username text, p_password text, p_gender boolean, p_birthdate date) OWNER TO postgres;

--
-- Name: update_user(integer, text, text, text, boolean, date, integer); Type: FUNCTION; Schema: user_schema; Owner: postgres
--

CREATE FUNCTION user_schema.update_user(p_id integer, p_name text, p_username text, p_password text, p_gender boolean, p_birthdate date, p_users_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    result        record;
    user_exist    bool;
    company_exist bool;
begin

    if p_id is null or p_name is null or p_username is null or p_gender is null or p_birthdate is null or
       p_users_id is null or p_password is null then
        raise exception 'Required fields are missing!';
    end if;

    user_exist := exists(select 0 from users where username = p_username and id <> p_id);
    company_exist := exists(select 0 from companies where username = p_username and id <> p_id);

    if user_exist or company_exist then
        raise exception 'Username already taken!';
    end if;

    update users
    set name=p_name,
        username=p_username,
        password=md5(p_password),
        gender=p_gender,
        birthdate=p_birthdate,
        updated_by=p_users_id,
        updated_at=now()
    where id = p_id
    returning * into result;

    return row_to_json(result)::text;
end;
$$;


ALTER FUNCTION user_schema.update_user(p_id integer, p_name text, p_username text, p_password text, p_gender boolean, p_birthdate date, p_users_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: test_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_user (
    id integer NOT NULL,
    username text,
    password text
);


ALTER TABLE public.test_user OWNER TO postgres;

--
-- Name: test_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.test_user_id_seq OWNER TO postgres;

--
-- Name: test_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_user_id_seq OWNED BY public.test_user.id;


--
-- Name: companies; Type: TABLE; Schema: user_schema; Owner: postgres
--

CREATE TABLE user_schema.companies (
    id integer NOT NULL,
    name text NOT NULL,
    balance double precision DEFAULT 0.0 NOT NULL,
    username character varying(20) NOT NULL,
    password character varying(50) NOT NULL,
    created_at date DEFAULT now() NOT NULL,
    created_by integer,
    updated_by integer,
    updated_at date DEFAULT now() NOT NULL,
    is_deleted boolean,
    CONSTRAINT companies_name_check CHECK ((length(name) > 5))
);


ALTER TABLE user_schema.companies OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: user_schema; Owner: postgres
--

CREATE SEQUENCE user_schema.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE user_schema.companies_id_seq OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: user_schema; Owner: postgres
--

ALTER SEQUENCE user_schema.companies_id_seq OWNED BY user_schema.companies.id;


--
-- Name: users; Type: TABLE; Schema: user_schema; Owner: postgres
--

CREATE TABLE user_schema.users (
    id integer NOT NULL,
    name text NOT NULL,
    username character varying(20) NOT NULL,
    password character varying(50) NOT NULL,
    balance double precision DEFAULT 0.0,
    gender boolean NOT NULL,
    birthdate date,
    created_at date DEFAULT now() NOT NULL,
    created_by integer,
    updated_by integer,
    updated_at date DEFAULT now() NOT NULL,
    is_deleted boolean,
    CONSTRAINT users_name_check CHECK ((length(name) > 2))
);


ALTER TABLE user_schema.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: user_schema; Owner: postgres
--

CREATE SEQUENCE user_schema.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE user_schema.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: user_schema; Owner: postgres
--

ALTER SEQUENCE user_schema.users_id_seq OWNED BY user_schema.users.id;


--
-- Name: test_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_user ALTER COLUMN id SET DEFAULT nextval('public.test_user_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.companies ALTER COLUMN id SET DEFAULT nextval('user_schema.companies_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users ALTER COLUMN id SET DEFAULT nextval('user_schema.users_id_seq'::regclass);


--
-- Name: users created_by; Type: DEFAULT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users ALTER COLUMN created_by SET DEFAULT currval('user_schema.users_id_seq'::regclass);


--
-- Data for Name: test_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test_user (id, username, password) FROM stdin;
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: user_schema; Owner: postgres
--

COPY user_schema.companies (id, name, balance, username, password, created_at, created_by, updated_by, updated_at, is_deleted) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: user_schema; Owner: postgres
--

COPY user_schema.users (id, name, username, password, balance, gender, birthdate, created_at, created_by, updated_by, updated_at, is_deleted) FROM stdin;
\.


--
-- Name: test_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_user_id_seq', 1, false);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: user_schema; Owner: postgres
--

SELECT pg_catalog.setval('user_schema.companies_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: user_schema; Owner: postgres
--

SELECT pg_catalog.setval('user_schema.users_id_seq', 9, true);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_username_key; Type: CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.companies
    ADD CONSTRAINT companies_username_key UNIQUE (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: companies delete_company_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER delete_company_trigger BEFORE DELETE ON user_schema.companies FOR EACH ROW EXECUTE FUNCTION public.delete_trigger();


--
-- Name: users delete_user_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER delete_user_trigger BEFORE DELETE ON user_schema.users FOR EACH ROW EXECUTE FUNCTION public.delete_trigger();


--
-- Name: companies insert_company_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER insert_company_trigger AFTER INSERT ON user_schema.companies FOR EACH ROW EXECUTE FUNCTION public.insert_trigger();


--
-- Name: users insert_user_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER insert_user_trigger AFTER INSERT ON user_schema.users FOR EACH ROW EXECUTE FUNCTION public.insert_trigger();


--
-- Name: companies update_company_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER update_company_trigger BEFORE UPDATE ON user_schema.companies FOR EACH ROW EXECUTE FUNCTION public.update_trigger();


--
-- Name: users update_user_trigger; Type: TRIGGER; Schema: user_schema; Owner: postgres
--

CREATE TRIGGER update_user_trigger BEFORE UPDATE ON user_schema.users FOR EACH ROW EXECUTE FUNCTION public.update_trigger();


--
-- Name: companies companies_created_by_fkey; Type: FK CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.companies
    ADD CONSTRAINT companies_created_by_fkey FOREIGN KEY (created_by) REFERENCES user_schema.users(id);


--
-- Name: companies companies_updated_by_fkey; Type: FK CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.companies
    ADD CONSTRAINT companies_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES user_schema.users(id);


--
-- Name: users users_created_by_fkey; Type: FK CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users
    ADD CONSTRAINT users_created_by_fkey FOREIGN KEY (created_by) REFERENCES user_schema.users(id);


--
-- Name: users users_updated_by_fkey; Type: FK CONSTRAINT; Schema: user_schema; Owner: postgres
--

ALTER TABLE ONLY user_schema.users
    ADD CONSTRAINT users_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES user_schema.users(id);


--
-- PostgreSQL database dump complete
--

