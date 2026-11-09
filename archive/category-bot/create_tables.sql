--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: chat_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE CATEGORY_chat_log (
    id integer NOT NULL,
    channel character varying(64) NOT NULL,
    sender character varying(64) NOT NULL,
    message character varying(512) NOT NULL,
    date bigint NOT NULL
);

--
-- Name: chat_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE CATEGORY_chat_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: chat_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE CATEGORY_chat_log_id_seq OWNED BY CATEGORY_chat_log.id;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY CATEGORY_chat_log ALTER COLUMN id SET DEFAULT nextval('CATEGORY_chat_log_id_seq'::regclass);

--
-- Name: chat_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY CATEGRORY_chat_log
    ADD CONSTRAINT CATEGORY_chat_log_pkey PRIMARY KEY (id);

--
-- Name: stream_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX CATEGORY_chat_log_date_idx ON CATEGORY_chat_log (date);
CREATE INDEX CATEGORY_chat_log_channel_idx ON CATEGORY_chat_log (channel);

--
-- PostgreSQL database dump complete
--
