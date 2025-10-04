--
-- PostgreSQL database dump
--

\restrict IfdfqH08Iy5YgYGZk1x47OcjDpiPO7poAWuYSoDlELRkVgtlcD8nUTYidBA3kvN

-- Dumped from database version 16.10
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: lock_manager; Type: SCHEMA; Schema: -; Owner: lms_admin
--

CREATE SCHEMA lock_manager;


ALTER SCHEMA lock_manager OWNER TO lms_admin;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: fn_get_access_id(); Type: FUNCTION; Schema: public; Owner: lms_admin
--

CREATE FUNCTION public.fn_get_access_id() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    now_date TEXT; -- 현재 날짜/시간 값을 저장
    seq_value BIGINT;       -- 시퀀스 값 저장
    padded_seq TEXT;        -- 패딩 처리된 시퀀스 값
BEGIN
    -- 현재 날짜/시간을 'YYYYMMDDHHMISS' 형식으로 가져옴
    now_date := TO_CHAR(NOW(), 'YYYYMMDDHH24MISS');

    -- 다음 시퀀스 값 가져오기
    seq_value := NEXTVAL('seq_access_id');

    -- 시퀀스 값을 8자리로 맞추기 (숫자 앞에 0을 채움)
    padded_seq := LPAD(seq_value::TEXT, 8, '0');

    -- 값을 조합하여 반환
    RETURN 'ACCESS_' || now_date || '_' || padded_seq;
END;
$$;


ALTER FUNCTION public.fn_get_access_id() OWNER TO lms_admin;

--
-- Name: fn_get_desc1(character varying, character varying); Type: FUNCTION; Schema: public; Owner: lms_admin
--

CREATE FUNCTION public.fn_get_desc1(p_code_type character varying, p_code1 character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    result_desc1 VARCHAR;
BEGIN
    SELECT desc1
    INTO result_desc1
    FROM lock_manager.common_code_mgmt
    WHERE code_type = p_code_type
      AND code1 = p_code1;

    -- 조회 값이 없을 때 예외 처리
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN result_desc1;
END;
$$;


ALTER FUNCTION public.fn_get_desc1(p_code_type character varying, p_code1 character varying) OWNER TO lms_admin;

--
-- Name: nvl(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: lms_admin
--

CREATE FUNCTION public.nvl(expr1 anyelement, expr2 anyelement) RETURNS anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- expr1이 NULL인지 확인 후 expr2 반환
    RETURN COALESCE(expr1, expr2);
END;
$$;


ALTER FUNCTION public.nvl(expr1 anyelement, expr2 anyelement) OWNER TO lms_admin;

--
-- Name: nvl2(anyelement, anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: lms_admin
--

CREATE FUNCTION public.nvl2(expression anyelement, value_if_not_null anyelement, value_if_null anyelement) RETURNS anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN CASE
               WHEN expression IS NOT NULL THEN value_if_not_null
               ELSE value_if_null
        END;
END;
$$;


ALTER FUNCTION public.nvl2(expression anyelement, value_if_not_null anyelement, value_if_null anyelement) OWNER TO lms_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_log; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.access_log (
    log_id character varying(30) NOT NULL,
    user_id character varying(12) NOT NULL,
    uri_method character varying(6),
    uri character varying(100),
    description character varying(100),
    client_ip character varying(50),
    trace_id character varying(36),
    jsession_id character varying(255),
    agent_type character varying(2),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE lock_manager.access_log OWNER TO lms_admin;

--
-- Name: TABLE access_log; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.access_log IS '접속로그 관리';


--
-- Name: COLUMN access_log.log_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.log_id IS '접속로그 ID';


--
-- Name: COLUMN access_log.user_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.user_id IS '사용자 ID';


--
-- Name: COLUMN access_log.uri_method; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.uri_method IS 'URI 메서드';


--
-- Name: COLUMN access_log.uri; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.uri IS 'URI';


--
-- Name: COLUMN access_log.description; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.description IS '설명';


--
-- Name: COLUMN access_log.client_ip; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.client_ip IS '사용자 IP';


--
-- Name: COLUMN access_log.trace_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.trace_id IS '로그 추적 ID';


--
-- Name: COLUMN access_log.jsession_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.jsession_id IS 'JSESSION ID';


--
-- Name: COLUMN access_log.agent_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.agent_type IS 'AGENT 유형 (01: PC, 02: MOBILE or TABLET)';


--
-- Name: COLUMN access_log.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.access_log.created_at IS '등록일시';


--
-- Name: common_code_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.common_code_mgmt (
    code_type character varying(20) NOT NULL,
    code1 character varying(12) DEFAULT '***'::character varying NOT NULL,
    code2 character varying(10) DEFAULT '***'::character varying NOT NULL,
    code3 character varying(10) DEFAULT '***'::character varying NOT NULL,
    desc1 character varying(200),
    desc2 character varying(200),
    desc3 character varying(200),
    "order" integer,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.common_code_mgmt OWNER TO lms_admin;

--
-- Name: TABLE common_code_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.common_code_mgmt IS '공통 코드 관리';


--
-- Name: COLUMN common_code_mgmt.code_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.code_type IS '코드 구분';


--
-- Name: COLUMN common_code_mgmt.code1; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.code1 IS '코드1';


--
-- Name: COLUMN common_code_mgmt.code2; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.code2 IS '코드2';


--
-- Name: COLUMN common_code_mgmt.code3; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.code3 IS '코드3';


--
-- Name: COLUMN common_code_mgmt.desc1; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.desc1 IS '설명1';


--
-- Name: COLUMN common_code_mgmt.desc2; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.desc2 IS '설명2';


--
-- Name: COLUMN common_code_mgmt.desc3; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.desc3 IS '설명3';


--
-- Name: COLUMN common_code_mgmt."order"; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt."order" IS '순서';


--
-- Name: COLUMN common_code_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN common_code_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN common_code_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.created_by IS '등록자';


--
-- Name: COLUMN common_code_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN common_code_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.common_code_mgmt.updated_by IS '수정자';


--
-- Name: communication_logs; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.communication_logs (
    log_id bigint NOT NULL,
    df_serial_number character varying(14) NOT NULL,
    command_type character varying(50),
    command_detail text,
    request_time timestamp with time zone,
    response_code character varying(10),
    response_detail text,
    response_time timestamp with time zone,
    processing_time integer,
    connection_status character varying(20),
    signal_strength integer,
    battery_level integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE lock_manager.communication_logs OWNER TO lms_admin;

--
-- Name: TABLE communication_logs; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.communication_logs IS '통신 로그 테이블 (월별 파티셔닝)';


--
-- Name: COLUMN communication_logs.log_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.log_id IS '통신로그ID';


--
-- Name: COLUMN communication_logs.df_serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.df_serial_number IS '시리얼번호';


--
-- Name: COLUMN communication_logs.command_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.command_type IS '명령어 타입';


--
-- Name: COLUMN communication_logs.command_detail; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.command_detail IS '상세 명령어';


--
-- Name: COLUMN communication_logs.request_time; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.request_time IS '요청시간';


--
-- Name: COLUMN communication_logs.response_code; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.response_code IS '응답 코드';


--
-- Name: COLUMN communication_logs.response_detail; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.response_detail IS '응답 상세';


--
-- Name: COLUMN communication_logs.response_time; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.response_time IS '응답시간';


--
-- Name: COLUMN communication_logs.processing_time; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.processing_time IS '처리시간(ms)';


--
-- Name: COLUMN communication_logs.connection_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.connection_status IS '통신상태';


--
-- Name: COLUMN communication_logs.signal_strength; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.signal_strength IS '신호강도';


--
-- Name: COLUMN communication_logs.battery_level; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.battery_level IS '배터리레벨';


--
-- Name: COLUMN communication_logs.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.communication_logs.created_at IS '생성일';


--
-- Name: communication_logs_log_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.communication_logs_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.communication_logs_log_id_seq OWNER TO lms_admin;

--
-- Name: communication_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.communication_logs_log_id_seq OWNED BY lock_manager.communication_logs.log_id;


--
-- Name: customer_base; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.customer_base (
    customer_id character varying(20) NOT NULL,
    business_no character varying(10) NOT NULL,
    customer_nm character varying(100) NOT NULL,
    site_info character varying(100),
    manager_nm character varying(50),
    department character varying(50),
    email character varying(255),
    tel_no character varying(20),
    co_unique_id character varying(100) NOT NULL,
    admin_pw character varying(100) NOT NULL,
    master_key character varying(100) NOT NULL,
    memo text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.customer_base OWNER TO lms_admin;

--
-- Name: TABLE customer_base; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.customer_base IS '고객사 정보 관리';


--
-- Name: COLUMN customer_base.customer_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.customer_id IS '고객사 고유 ID';


--
-- Name: COLUMN customer_base.business_no; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.business_no IS '사업자번호';


--
-- Name: COLUMN customer_base.customer_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.customer_nm IS '고객사명';


--
-- Name: COLUMN customer_base.site_info; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.site_info IS '사이트 정보';


--
-- Name: COLUMN customer_base.manager_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.manager_nm IS '담당자명';


--
-- Name: COLUMN customer_base.department; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.department IS '부서';


--
-- Name: COLUMN customer_base.email; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.email IS '이메일';


--
-- Name: COLUMN customer_base.tel_no; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.tel_no IS '연락처';


--
-- Name: COLUMN customer_base.co_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.co_unique_id IS '고객사 구분코드';


--
-- Name: COLUMN customer_base.admin_pw; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.admin_pw IS '관리자 비밀번호';


--
-- Name: COLUMN customer_base.master_key; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.master_key IS '고객사 마스터키';


--
-- Name: COLUMN customer_base.memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.memo IS '메모';


--
-- Name: COLUMN customer_base.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.is_active IS '사용여부';


--
-- Name: COLUMN customer_base.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.created_at IS '등록일시';


--
-- Name: COLUMN customer_base.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.created_by IS '등록자';


--
-- Name: COLUMN customer_base.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.updated_at IS '수정일시';


--
-- Name: COLUMN customer_base.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_base.updated_by IS '수정자';


--
-- Name: customer_gen_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.customer_gen_history (
    history_id bigint NOT NULL,
    customer_id character varying(20) NOT NULL,
    co_unique_id character(100) NOT NULL,
    admin_pw character(100) NOT NULL,
    master_key character(100) NOT NULL,
    co_uid_plain character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL
);


ALTER TABLE lock_manager.customer_gen_history OWNER TO lms_admin;

--
-- Name: TABLE customer_gen_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.customer_gen_history IS '고객사 암호화 코드 생성 이력';


--
-- Name: COLUMN customer_gen_history.history_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.history_id IS '이력 고유 ID';


--
-- Name: COLUMN customer_gen_history.customer_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.customer_id IS '고객사 ID';


--
-- Name: COLUMN customer_gen_history.co_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.co_unique_id IS '고객사 구분코드';


--
-- Name: COLUMN customer_gen_history.admin_pw; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.admin_pw IS '관리자 비밀번호';


--
-- Name: COLUMN customer_gen_history.master_key; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.master_key IS '고객사 마스터키';


--
-- Name: COLUMN customer_gen_history.co_uid_plain; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.co_uid_plain IS '고객사 구분코드 평문';


--
-- Name: COLUMN customer_gen_history.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.created_at IS '등록일시';


--
-- Name: COLUMN customer_gen_history.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.customer_gen_history.created_by IS '등록자';


--
-- Name: customer_gen_history_history_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.customer_gen_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.customer_gen_history_history_id_seq OWNER TO lms_admin;

--
-- Name: customer_gen_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.customer_gen_history_history_id_seq OWNED BY lock_manager.customer_gen_history.history_id;


--
-- Name: jwt_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.jwt_mgmt (
    user_id character varying(12) NOT NULL,
    access_token character varying(255),
    refresh_token character varying(255),
    login_at timestamp with time zone
);


ALTER TABLE lock_manager.jwt_mgmt OWNER TO lms_admin;

--
-- Name: TABLE jwt_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.jwt_mgmt IS '접근 토큰 관리';


--
-- Name: COLUMN jwt_mgmt.user_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.jwt_mgmt.user_id IS '사용자 ID';


--
-- Name: COLUMN jwt_mgmt.access_token; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.jwt_mgmt.access_token IS '접근 토큰';


--
-- Name: COLUMN jwt_mgmt.refresh_token; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.jwt_mgmt.refresh_token IS '재발급 토큰';


--
-- Name: lock_customer_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.lock_customer_history (
    history_id bigint NOT NULL,
    df_serial_number character varying(14) NOT NULL,
    co_unique_id character varying(100) NOT NULL,
    admin_pw character varying(100) NOT NULL,
    master_key character varying(100) NOT NULL,
    previous_co_unique_id character varying(100),
    previous_admin_pw character varying(100),
    previous_master_key character varying(100),
    change_reason character varying(10) NOT NULL,
    process_type character varying(10) NOT NULL,
    process_id bigint,
    updated_at timestamp with time zone,
    updated_by character varying(12),
    note text
);


ALTER TABLE lock_manager.lock_customer_history OWNER TO lms_admin;

--
-- Name: TABLE lock_customer_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.lock_customer_history IS '고객정보 이력';


--
-- Name: COLUMN lock_customer_history.history_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.history_id IS '히스토리ID';


--
-- Name: COLUMN lock_customer_history.df_serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.df_serial_number IS '시리얼번호';


--
-- Name: COLUMN lock_customer_history.co_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.co_unique_id IS '변경된 고객사고유ID';


--
-- Name: COLUMN lock_customer_history.admin_pw; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.admin_pw IS '변경된 관리자비밀번호';


--
-- Name: COLUMN lock_customer_history.master_key; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.master_key IS '변경된 마스터키';


--
-- Name: COLUMN lock_customer_history.previous_co_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.previous_co_unique_id IS '이전 고객사고유ID';


--
-- Name: COLUMN lock_customer_history.previous_admin_pw; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.previous_admin_pw IS '이전 고객사관리자암호';


--
-- Name: COLUMN lock_customer_history.previous_master_key; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.previous_master_key IS '이전 고객사마스터키';


--
-- Name: COLUMN lock_customer_history.change_reason; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.change_reason IS '변경사유';


--
-- Name: COLUMN lock_customer_history.process_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.process_type IS '처리구분';


--
-- Name: COLUMN lock_customer_history.process_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.process_id IS '처리ID';


--
-- Name: COLUMN lock_customer_history.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.updated_at IS '수정일시';


--
-- Name: COLUMN lock_customer_history.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.updated_by IS '수정자';


--
-- Name: COLUMN lock_customer_history.note; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_customer_history.note IS '메모';


--
-- Name: lock_customer_history_history_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.lock_customer_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.lock_customer_history_history_id_seq OWNER TO lms_admin;

--
-- Name: lock_customer_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.lock_customer_history_history_id_seq OWNED BY lock_manager.lock_customer_history.history_id;


--
-- Name: lock_identity_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.lock_identity_history (
    history_id bigint NOT NULL,
    serial_number character varying(14) NOT NULL,
    unique_id character varying(100) NOT NULL,
    previous_serial_number character varying(14),
    previous_unique_id character varying(100),
    model_id bigint NOT NULL,
    change_reason character varying(50) NOT NULL,
    process_type character varying(10) NOT NULL,
    process_id bigint,
    updated_at timestamp with time zone,
    updated_by character varying(12),
    note text
);


ALTER TABLE lock_manager.lock_identity_history OWNER TO lms_admin;

--
-- Name: TABLE lock_identity_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.lock_identity_history IS '식별정보 이력';


--
-- Name: COLUMN lock_identity_history.history_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.history_id IS '히스토리ID';


--
-- Name: COLUMN lock_identity_history.serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.serial_number IS '현재 시리얼번호';


--
-- Name: COLUMN lock_identity_history.unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.unique_id IS '현재 unique_id';


--
-- Name: COLUMN lock_identity_history.previous_serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.previous_serial_number IS '이전 시리얼번호 (공장초기값)';


--
-- Name: COLUMN lock_identity_history.previous_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.previous_unique_id IS '이전 unique_id (공장초기값)';


--
-- Name: COLUMN lock_identity_history.model_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.model_id IS '스마트락 모델 고유 ID';


--
-- Name: COLUMN lock_identity_history.change_reason; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.change_reason IS '변경사유';


--
-- Name: COLUMN lock_identity_history.process_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.process_type IS '처리구분';


--
-- Name: COLUMN lock_identity_history.process_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.process_id IS '처리ID';


--
-- Name: COLUMN lock_identity_history.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.updated_at IS '수정일시';


--
-- Name: COLUMN lock_identity_history.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.updated_by IS '수정자';


--
-- Name: COLUMN lock_identity_history.note; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_identity_history.note IS '메모';


--
-- Name: lock_identity_history_history_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.lock_identity_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.lock_identity_history_history_id_seq OWNER TO lms_admin;

--
-- Name: lock_identity_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.lock_identity_history_history_id_seq OWNED BY lock_manager.lock_identity_history.history_id;


--
-- Name: lock_model_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.lock_model_mgmt (
    model_id bigint NOT NULL,
    model_cd character varying(50) NOT NULL,
    category character varying(10) NOT NULL,
    model_nm character varying(100) NOT NULL,
    color character varying(10) NOT NULL,
    memo text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12),
    deleted_at timestamp with time zone,
    deleted_by character varying(12)
);


ALTER TABLE lock_manager.lock_model_mgmt OWNER TO lms_admin;

--
-- Name: TABLE lock_model_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.lock_model_mgmt IS '스마트락 모델 정보 관리';


--
-- Name: COLUMN lock_model_mgmt.model_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.model_id IS '스마트락 모델 고유 ID';


--
-- Name: COLUMN lock_model_mgmt.model_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.model_cd IS '모델 코드';


--
-- Name: COLUMN lock_model_mgmt.category; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.category IS '구분';


--
-- Name: COLUMN lock_model_mgmt.model_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.model_nm IS '모델명';


--
-- Name: COLUMN lock_model_mgmt.color; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.color IS '색상';


--
-- Name: COLUMN lock_model_mgmt.memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.memo IS '메모';


--
-- Name: COLUMN lock_model_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN lock_model_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN lock_model_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.created_by IS '등록자';


--
-- Name: COLUMN lock_model_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN lock_model_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.updated_by IS '수정자';


--
-- Name: COLUMN lock_model_mgmt.deleted_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.deleted_at IS '삭제일시';


--
-- Name: COLUMN lock_model_mgmt.deleted_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_model_mgmt.deleted_by IS '삭제자';


--
-- Name: lock_model_mgmt_model_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.lock_model_mgmt_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.lock_model_mgmt_model_id_seq OWNER TO lms_admin;

--
-- Name: lock_model_mgmt_model_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.lock_model_mgmt_model_id_seq OWNED BY lock_manager.lock_model_mgmt.model_id;


--
-- Name: lock_settings_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.lock_settings_history (
    history_id bigint NOT NULL,
    df_serial_number character varying(14) NOT NULL,
    lock_method smallint,
    remote_lock smallint,
    guard_mode smallint,
    ecd_id character varying(16),
    firmware_version character varying(8),
    lif_id character varying(12),
    update_flag smallint,
    change_type character varying(10) NOT NULL,
    change_reason text NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12),
    note text
);


ALTER TABLE lock_manager.lock_settings_history OWNER TO lms_admin;

--
-- Name: TABLE lock_settings_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.lock_settings_history IS '환경설정 변경 이력';


--
-- Name: COLUMN lock_settings_history.history_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.history_id IS '히스토리ID';


--
-- Name: COLUMN lock_settings_history.df_serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.df_serial_number IS '시리얼번호';


--
-- Name: COLUMN lock_settings_history.lock_method; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.lock_method IS '잠금방식';


--
-- Name: COLUMN lock_settings_history.remote_lock; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.remote_lock IS '원격잠금설정';


--
-- Name: COLUMN lock_settings_history.guard_mode; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.guard_mode IS '가드모드설정';


--
-- Name: COLUMN lock_settings_history.ecd_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.ecd_id IS 'ECD_ID';


--
-- Name: COLUMN lock_settings_history.firmware_version; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.firmware_version IS '펌웨어버전';


--
-- Name: COLUMN lock_settings_history.lif_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.lif_id IS '잠금개소식별ID';


--
-- Name: COLUMN lock_settings_history.update_flag; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.update_flag IS '업데이트플래그';


--
-- Name: COLUMN lock_settings_history.change_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.change_type IS '변경유형';


--
-- Name: COLUMN lock_settings_history.change_reason; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.change_reason IS '변경사유';


--
-- Name: COLUMN lock_settings_history.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.updated_at IS '수정일시';


--
-- Name: COLUMN lock_settings_history.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.updated_by IS '수정자';


--
-- Name: COLUMN lock_settings_history.note; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.lock_settings_history.note IS '메모';


--
-- Name: lock_settings_history_history_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.lock_settings_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.lock_settings_history_history_id_seq OWNER TO lms_admin;

--
-- Name: lock_settings_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.lock_settings_history_history_id_seq OWNED BY lock_manager.lock_settings_history.history_id;


--
-- Name: menu_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.menu_mgmt (
    menu_id character varying(17) NOT NULL,
    par_menu_id character varying(17),
    menu_nm character varying(100) NOT NULL,
    url character varying(255) NOT NULL,
    "order" integer,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.menu_mgmt OWNER TO lms_admin;

--
-- Name: TABLE menu_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.menu_mgmt IS '메뉴 관리';


--
-- Name: COLUMN menu_mgmt.menu_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.menu_id IS '메뉴 고유 ID';


--
-- Name: COLUMN menu_mgmt.par_menu_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.par_menu_id IS '부모 메뉴 고유 ID';


--
-- Name: COLUMN menu_mgmt.menu_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.menu_nm IS '메뉴명';


--
-- Name: COLUMN menu_mgmt.url; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.url IS 'url';


--
-- Name: COLUMN menu_mgmt."order"; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt."order" IS '순서';


--
-- Name: COLUMN menu_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN menu_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN menu_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.created_by IS '등록자';


--
-- Name: COLUMN menu_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN menu_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.menu_mgmt.updated_by IS '수정자';


--
-- Name: notice_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.notice_mgmt (
    notice_id bigint NOT NULL,
    division character varying(10),
    category character varying(10),
    subject character varying(200),
    content text,
    importance character varying(10),
    post_from date,
    post_to date,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.notice_mgmt OWNER TO lms_admin;

--
-- Name: TABLE notice_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.notice_mgmt IS '공지사항';


--
-- Name: COLUMN notice_mgmt.notice_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.notice_id IS '고지사항 고유 ID';


--
-- Name: COLUMN notice_mgmt.division; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.division IS '공지사항 구분';


--
-- Name: COLUMN notice_mgmt.category; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.category IS '유형';


--
-- Name: COLUMN notice_mgmt.subject; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.subject IS '제목';


--
-- Name: COLUMN notice_mgmt.content; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.content IS '내용';


--
-- Name: COLUMN notice_mgmt.importance; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.importance IS '중요도';


--
-- Name: COLUMN notice_mgmt.post_from; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.post_from IS '게시 시작일';


--
-- Name: COLUMN notice_mgmt.post_to; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.post_to IS '게시 만료일';


--
-- Name: COLUMN notice_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN notice_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN notice_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.created_by IS '등록자';


--
-- Name: COLUMN notice_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN notice_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_mgmt.updated_by IS '수정자';


--
-- Name: notice_mgmt_notice_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.notice_mgmt_notice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.notice_mgmt_notice_id_seq OWNER TO lms_admin;

--
-- Name: notice_mgmt_notice_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.notice_mgmt_notice_id_seq OWNED BY lock_manager.notice_mgmt.notice_id;


--
-- Name: notice_read_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.notice_read_history (
    notice_id bigint NOT NULL,
    user_id character varying(12) NOT NULL,
    read_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE lock_manager.notice_read_history OWNER TO lms_admin;

--
-- Name: TABLE notice_read_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.notice_read_history IS '공지사항 열람 이력';


--
-- Name: COLUMN notice_read_history.notice_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_read_history.notice_id IS '코드 구분';


--
-- Name: COLUMN notice_read_history.user_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_read_history.user_id IS '코드1';


--
-- Name: COLUMN notice_read_history.read_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.notice_read_history.read_at IS '코드2';


--
-- Name: notice_read_history_notice_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.notice_read_history_notice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.notice_read_history_notice_id_seq OWNER TO lms_admin;

--
-- Name: notice_read_history_notice_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.notice_read_history_notice_id_seq OWNED BY lock_manager.notice_read_history.notice_id;


--
-- Name: organization_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.organization_mgmt (
    org_id character varying(20) NOT NULL,
    par_org_id character varying(20),
    org_nm character varying(50),
    org_type character varying(10),
    memo text,
    "order" integer,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.organization_mgmt OWNER TO lms_admin;

--
-- Name: TABLE organization_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.organization_mgmt IS '조직 정보 관리';


--
-- Name: COLUMN organization_mgmt.org_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.org_id IS '조직 고유 ID';


--
-- Name: COLUMN organization_mgmt.par_org_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.par_org_id IS '부모 조직 고유 ID';


--
-- Name: COLUMN organization_mgmt.org_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.org_nm IS '조직명';


--
-- Name: COLUMN organization_mgmt.org_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.org_type IS '조직 구분';


--
-- Name: COLUMN organization_mgmt.memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.memo IS '메모';


--
-- Name: COLUMN organization_mgmt."order"; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt."order" IS '순서';


--
-- Name: COLUMN organization_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN organization_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN organization_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.created_by IS '등록자';


--
-- Name: COLUMN organization_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN organization_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.organization_mgmt.updated_by IS '수정자';


--
-- Name: product_info; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.product_info (
    product_id bigint NOT NULL,
    serial_number character varying(14) NOT NULL,
    unique_id character varying(100) NOT NULL,
    co_unique_id character varying(100),
    admin_pw character varying(100),
    master_key character varying(100),
    lock_method character varying(10) NOT NULL,
    remote_lock character varying(10) NOT NULL,
    guard_mode character varying(10) NOT NULL,
    ecd_id character varying(16) NOT NULL,
    firmware_ver character varying(8) NOT NULL,
    lif_id character varying(12) NOT NULL,
    update_flag smallint,
    device_status character varying(10),
    operation_status character varying(10),
    battery_level integer,
    is_active boolean,
    last_connection timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.product_info OWNER TO lms_admin;

--
-- Name: TABLE product_info; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.product_info IS '상품정보';


--
-- Name: COLUMN product_info.product_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.product_id IS '고유 ID';


--
-- Name: COLUMN product_info.serial_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.serial_number IS '시리얼 번호';


--
-- Name: COLUMN product_info.unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.unique_id IS 'UID';


--
-- Name: COLUMN product_info.co_unique_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.co_unique_id IS '고객사 고유 ID';


--
-- Name: COLUMN product_info.admin_pw; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.admin_pw IS '고객사 관리자 암호';


--
-- Name: COLUMN product_info.master_key; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.master_key IS '마스터키';


--
-- Name: COLUMN product_info.lock_method; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.lock_method IS '잠금방식';


--
-- Name: COLUMN product_info.remote_lock; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.remote_lock IS '원격잠금설정 ';


--
-- Name: COLUMN product_info.guard_mode; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.guard_mode IS '가드모드설정 ';


--
-- Name: COLUMN product_info.ecd_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.ecd_id IS 'ECD ID';


--
-- Name: COLUMN product_info.firmware_ver; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.firmware_ver IS '펌웨어버전';


--
-- Name: COLUMN product_info.lif_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.lif_id IS '잠금개소식별ID';


--
-- Name: COLUMN product_info.update_flag; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.update_flag IS '업데이트플래그';


--
-- Name: COLUMN product_info.device_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.device_status IS '장비상태';


--
-- Name: COLUMN product_info.operation_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.operation_status IS '동작상태';


--
-- Name: COLUMN product_info.battery_level; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.battery_level IS '배터리 레벨';


--
-- Name: COLUMN product_info.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.is_active IS '활성화';


--
-- Name: COLUMN product_info.last_connection; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.last_connection IS '최종접속시간';


--
-- Name: COLUMN product_info.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.created_at IS '등록일';


--
-- Name: COLUMN product_info.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.created_by IS '등록자';


--
-- Name: COLUMN product_info.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.updated_at IS '수정일';


--
-- Name: COLUMN product_info.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_info.updated_by IS '수정자';


--
-- Name: product_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.product_mgmt (
    product_id bigint NOT NULL,
    model_id bigint NOT NULL,
    status character varying(10) NOT NULL,
    incoming_date date NOT NULL,
    warehouse_location character varying(50),
    rack_number character varying(20),
    incoming_memo text,
    incoming_by character varying(12),
    customer_id character varying(20),
    install_site_info character varying(100),
    install_department character varying(50),
    manager_nm character varying(50),
    manager_contact character varying(20),
    outgoing_shipping_company character varying(20),
    outgoing_tracking_number character varying(100),
    outgoing_shipping_status character varying(20),
    outgoing_shipping_post_cd character varying(10),
    outgoing_shipping_address text,
    outgoing_shipping_detail_address text,
    outgoing_shipping_note text,
    outgoing_shipping_info jsonb,
    outgoing_inspection_result text,
    outgoing_inspector character varying(12),
    outgoing_inspected_at date,
    outgoing_quality_status character varying(20),
    contract_number character varying(50),
    order_number character varying(50),
    outgoing_memo text,
    outgoing_expected_date date,
    outgoing_actual_date date,
    return_expected_date date,
    requester_name character varying(50),
    requester_contact character varying(20),
    request_date date,
    approval_date timestamp with time zone,
    approver character varying(12),
    refund_date date,
    requires_inspection boolean,
    refund_inspection_result text,
    refund_inspector character varying(12),
    refund_inspected_at date,
    pickup_post_cd character varying(10),
    pickup_address text,
    pickup_detail_address text,
    pickup_date date,
    refund_shipping_company character varying(20),
    refund_tracking_number character varying(100),
    refund_shipping_status character varying(20),
    refund_shipping_post_cd character varying(10),
    refund_shipping_address text,
    refund_shipping_detail_address text,
    refund_memo text,
    disposal_at timestamp with time zone,
    disposal_by character varying(12),
    disposal_memo text,
    outgoing_by character varying(12)
);


ALTER TABLE lock_manager.product_mgmt OWNER TO lms_admin;

--
-- Name: TABLE product_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.product_mgmt IS '상품 관리';


--
-- Name: COLUMN product_mgmt.product_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.product_id IS '고유 ID';


--
-- Name: COLUMN product_mgmt.model_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.model_id IS '스마트락 모델 고유 ID';


--
-- Name: COLUMN product_mgmt.status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.status IS '상태';


--
-- Name: COLUMN product_mgmt.incoming_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.incoming_date IS '입고일자';


--
-- Name: COLUMN product_mgmt.warehouse_location; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.warehouse_location IS '입고위치';


--
-- Name: COLUMN product_mgmt.rack_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.rack_number IS '렉번호';


--
-- Name: COLUMN product_mgmt.incoming_memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.incoming_memo IS '입고 메모';


--
-- Name: COLUMN product_mgmt.incoming_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.incoming_by IS '입고자';


--
-- Name: COLUMN product_mgmt.customer_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.customer_id IS '고객사 고유 ID';


--
-- Name: COLUMN product_mgmt.install_site_info; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.install_site_info IS '설치사이트 정보';


--
-- Name: COLUMN product_mgmt.install_department; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.install_department IS '설치부서';


--
-- Name: COLUMN product_mgmt.manager_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.manager_nm IS '담당자명';


--
-- Name: COLUMN product_mgmt.manager_contact; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.manager_contact IS '담당자연락처';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_company; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_company IS '출고 배송업체';


--
-- Name: COLUMN product_mgmt.outgoing_tracking_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_tracking_number IS '출고 운송장번호';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_status IS '출고 배송상태';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_post_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_post_cd IS '출고 배송주소 우편번호';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_address IS '출고 배송주소';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_detail_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_detail_address IS '출고 배송 상세주소';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_note; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_note IS '출고 배송메모';


--
-- Name: COLUMN product_mgmt.outgoing_shipping_info; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_shipping_info IS '출고 기타 배송정보';


--
-- Name: COLUMN product_mgmt.outgoing_inspection_result; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_inspection_result IS '출고 검수결과';


--
-- Name: COLUMN product_mgmt.outgoing_inspector; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_inspector IS '출고 검수자';


--
-- Name: COLUMN product_mgmt.outgoing_inspected_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_inspected_at IS '출고 검수일자';


--
-- Name: COLUMN product_mgmt.outgoing_quality_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_quality_status IS '출고 품질상태';


--
-- Name: COLUMN product_mgmt.contract_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.contract_number IS '계약번호';


--
-- Name: COLUMN product_mgmt.order_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.order_number IS '발주번호';


--
-- Name: COLUMN product_mgmt.outgoing_memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_memo IS '출고 메모';


--
-- Name: COLUMN product_mgmt.outgoing_expected_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_expected_date IS '출고예정일';


--
-- Name: COLUMN product_mgmt.outgoing_actual_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_actual_date IS '실제출고일';


--
-- Name: COLUMN product_mgmt.return_expected_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.return_expected_date IS '반납예정일 (데모/테스트의 경우)';


--
-- Name: COLUMN product_mgmt.requester_name; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.requester_name IS '반품요청자';


--
-- Name: COLUMN product_mgmt.requester_contact; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.requester_contact IS '요청자연락처';


--
-- Name: COLUMN product_mgmt.request_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.request_date IS '반품요청일';


--
-- Name: COLUMN product_mgmt.approval_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.approval_date IS '승인일시';


--
-- Name: COLUMN product_mgmt.approver; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.approver IS '승인자';


--
-- Name: COLUMN product_mgmt.refund_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_date IS '실제반품일';


--
-- Name: COLUMN product_mgmt.requires_inspection; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.requires_inspection IS '검수필요여부';


--
-- Name: COLUMN product_mgmt.refund_inspection_result; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_inspection_result IS '반품 검수결과';


--
-- Name: COLUMN product_mgmt.refund_inspector; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_inspector IS '반품 검수자';


--
-- Name: COLUMN product_mgmt.refund_inspected_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_inspected_at IS '반품 검수일자';


--
-- Name: COLUMN product_mgmt.pickup_post_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.pickup_post_cd IS '수거주소 우편번호';


--
-- Name: COLUMN product_mgmt.pickup_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.pickup_address IS '수거주소';


--
-- Name: COLUMN product_mgmt.pickup_detail_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.pickup_detail_address IS '수거 상세주소';


--
-- Name: COLUMN product_mgmt.pickup_date; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.pickup_date IS '수거예정일';


--
-- Name: COLUMN product_mgmt.refund_shipping_company; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_shipping_company IS '수거 업체';


--
-- Name: COLUMN product_mgmt.refund_tracking_number; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_tracking_number IS '수거 운송장번호';


--
-- Name: COLUMN product_mgmt.refund_shipping_status; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_shipping_status IS '수거 배송상태';


--
-- Name: COLUMN product_mgmt.refund_shipping_post_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_shipping_post_cd IS '수거 배송주소 우편번호';


--
-- Name: COLUMN product_mgmt.refund_shipping_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_shipping_address IS '수거 배송주소';


--
-- Name: COLUMN product_mgmt.refund_shipping_detail_address; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_shipping_detail_address IS '수거 배송 상세주소';


--
-- Name: COLUMN product_mgmt.refund_memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.refund_memo IS '반품 메모';


--
-- Name: COLUMN product_mgmt.disposal_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.disposal_at IS '폐기일시';


--
-- Name: COLUMN product_mgmt.disposal_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.disposal_by IS '폐기자';


--
-- Name: COLUMN product_mgmt.disposal_memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.disposal_memo IS '폐기 메모';


--
-- Name: COLUMN product_mgmt.outgoing_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.product_mgmt.outgoing_by IS '출고자';


--
-- Name: product_mgmt_product_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.product_mgmt_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.product_mgmt_product_id_seq OWNER TO lms_admin;

--
-- Name: product_mgmt_product_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.product_mgmt_product_id_seq OWNED BY lock_manager.product_mgmt.product_id;


--
-- Name: role_information; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.role_information (
    role_id character varying(17) NOT NULL,
    role_cd character varying(20) NOT NULL,
    role_nm character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.role_information OWNER TO lms_admin;

--
-- Name: TABLE role_information; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.role_information IS '역할 정보 관리';


--
-- Name: COLUMN role_information.role_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.role_id IS '역할 고유 ID';


--
-- Name: COLUMN role_information.role_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.role_cd IS '역할 코드';


--
-- Name: COLUMN role_information.role_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.role_nm IS '역할명';


--
-- Name: COLUMN role_information.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.created_at IS '등록일시';


--
-- Name: COLUMN role_information.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.created_by IS '등록자';


--
-- Name: COLUMN role_information.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.updated_at IS '수정일시';


--
-- Name: COLUMN role_information.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_information.updated_by IS '수정자';


--
-- Name: role_menu_map; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.role_menu_map (
    role_id character varying(17) NOT NULL,
    menu_id character varying(17) NOT NULL,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.role_menu_map OWNER TO lms_admin;

--
-- Name: TABLE role_menu_map; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.role_menu_map IS '메뉴 접근 권한 관리';


--
-- Name: COLUMN role_menu_map.role_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.role_id IS '역할 고유 ID';


--
-- Name: COLUMN role_menu_map.menu_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.menu_id IS '메뉴 고유 ID';


--
-- Name: COLUMN role_menu_map.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.is_active IS '사용여부';


--
-- Name: COLUMN role_menu_map.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.created_at IS '등록일시';


--
-- Name: COLUMN role_menu_map.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.created_by IS '등록자';


--
-- Name: COLUMN role_menu_map.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.updated_at IS '수정일시';


--
-- Name: COLUMN role_menu_map.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.role_menu_map.updated_by IS '수정자';


--
-- Name: sequence_history; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.sequence_history (
    history_id bigint NOT NULL,
    sequence_type character varying(10) NOT NULL,
    sequence_value character varying(100),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL
);


ALTER TABLE lock_manager.sequence_history OWNER TO lms_admin;

--
-- Name: TABLE sequence_history; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.sequence_history IS '자동 채번 이력';


--
-- Name: COLUMN sequence_history.history_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_history.history_id IS '이력 고유 ID';


--
-- Name: COLUMN sequence_history.sequence_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_history.sequence_type IS '시퀀스 구분';


--
-- Name: COLUMN sequence_history.sequence_value; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_history.sequence_value IS '자동채번 값';


--
-- Name: COLUMN sequence_history.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_history.created_at IS '등록일시';


--
-- Name: COLUMN sequence_history.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_history.created_by IS '등록자';


--
-- Name: sequence_history_history_id_seq; Type: SEQUENCE; Schema: lock_manager; Owner: lms_admin
--

CREATE SEQUENCE lock_manager.sequence_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE lock_manager.sequence_history_history_id_seq OWNER TO lms_admin;

--
-- Name: sequence_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: lock_manager; Owner: lms_admin
--

ALTER SEQUENCE lock_manager.sequence_history_history_id_seq OWNED BY lock_manager.sequence_history.history_id;


--
-- Name: sequence_mgmt; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.sequence_mgmt (
    sequence_type character varying(10) NOT NULL,
    sequence_nm character varying(200),
    prefix character varying(20),
    min_value integer,
    max_value integer,
    increment_by integer,
    format character varying(100),
    current_value integer,
    usage_limit integer,
    used_count integer,
    memo text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.sequence_mgmt OWNER TO lms_admin;

--
-- Name: TABLE sequence_mgmt; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.sequence_mgmt IS '자동 채번 관리';


--
-- Name: COLUMN sequence_mgmt.sequence_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.sequence_type IS '시퀀스 구분';


--
-- Name: COLUMN sequence_mgmt.sequence_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.sequence_nm IS '시퀀스명';


--
-- Name: COLUMN sequence_mgmt.prefix; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.prefix IS '접두어';


--
-- Name: COLUMN sequence_mgmt.min_value; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.min_value IS '최소값';


--
-- Name: COLUMN sequence_mgmt.max_value; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.max_value IS '최대값';


--
-- Name: COLUMN sequence_mgmt.increment_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.increment_by IS '증가값';


--
-- Name: COLUMN sequence_mgmt.format; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.format IS '형식';


--
-- Name: COLUMN sequence_mgmt.current_value; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.current_value IS '현재값';


--
-- Name: COLUMN sequence_mgmt.usage_limit; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.usage_limit IS '사용건수 제한';


--
-- Name: COLUMN sequence_mgmt.used_count; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.used_count IS '사용건수';


--
-- Name: COLUMN sequence_mgmt.memo; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.memo IS '메모';


--
-- Name: COLUMN sequence_mgmt.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.is_active IS '사용여부';


--
-- Name: COLUMN sequence_mgmt.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.created_at IS '등록일시';


--
-- Name: COLUMN sequence_mgmt.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.created_by IS '등록자';


--
-- Name: COLUMN sequence_mgmt.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.updated_at IS '수정일시';


--
-- Name: COLUMN sequence_mgmt.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.sequence_mgmt.updated_by IS '수정자';


--
-- Name: user_information; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.user_information (
    user_id character varying(12) NOT NULL,
    org_id character varying(20) NOT NULL,
    emp_no character varying(100),
    mobile_no character varying(50) NOT NULL,
    tel_no character varying(50),
    email character varying(255),
    "position" character varying(10),
    resp_office character varying(10),
    org_type character varying(10) NOT NULL,
    etc_cd character varying(10),
    division character varying(20),
    start_at date,
    retire_at date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(12) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.user_information OWNER TO lms_admin;

--
-- Name: TABLE user_information; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.user_information IS '사용자 상세 정보';


--
-- Name: COLUMN user_information.user_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.user_id IS '사용자 ID';


--
-- Name: COLUMN user_information.org_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.org_id IS '조직 ID';


--
-- Name: COLUMN user_information.emp_no; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.emp_no IS '사번';


--
-- Name: COLUMN user_information.mobile_no; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.mobile_no IS '핸드폰번호';


--
-- Name: COLUMN user_information.tel_no; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.tel_no IS '사무실 전화번호';


--
-- Name: COLUMN user_information.email; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.email IS '이메일';


--
-- Name: COLUMN user_information."position"; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information."position" IS '직위';


--
-- Name: COLUMN user_information.resp_office; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.resp_office IS '직책';


--
-- Name: COLUMN user_information.org_type; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.org_type IS '조직구분';


--
-- Name: COLUMN user_information.etc_cd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.etc_cd IS '기타코드';


--
-- Name: COLUMN user_information.division; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.division IS '관리조직';


--
-- Name: COLUMN user_information.start_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.start_at IS '입사일';


--
-- Name: COLUMN user_information.retire_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.retire_at IS '퇴사일';


--
-- Name: COLUMN user_information.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.created_at IS '등록일시';


--
-- Name: COLUMN user_information.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.created_by IS '등록자';


--
-- Name: COLUMN user_information.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.updated_at IS '수정일시';


--
-- Name: COLUMN user_information.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_information.updated_by IS '수정자';


--
-- Name: user_master; Type: TABLE; Schema: lock_manager; Owner: lms_admin
--

CREATE TABLE lock_manager.user_master (
    user_id character varying(12) NOT NULL,
    password character varying(255) NOT NULL,
    first_nm character varying(50) NOT NULL,
    last_nm character varying(40) NOT NULL,
    user_nm character varying(90) NOT NULL,
    language character varying(2) NOT NULL,
    role_id character varying(17) NOT NULL,
    is_active boolean,
    init_passwd boolean,
    modified_password_at timestamp with time zone,
    valid_from date NOT NULL,
    valid_to date NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(20) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(12)
);


ALTER TABLE lock_manager.user_master OWNER TO lms_admin;

--
-- Name: TABLE user_master; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON TABLE lock_manager.user_master IS '사용자 기본 정보';


--
-- Name: COLUMN user_master.user_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.user_id IS '사용자 ID';


--
-- Name: COLUMN user_master.password; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.password IS '비밀번호';


--
-- Name: COLUMN user_master.first_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.first_nm IS '사용자 FirstName';


--
-- Name: COLUMN user_master.last_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.last_nm IS '사용자 LastName';


--
-- Name: COLUMN user_master.user_nm; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.user_nm IS '사용자명';


--
-- Name: COLUMN user_master.language; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.language IS '사용언어';


--
-- Name: COLUMN user_master.role_id; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.role_id IS '역할 고유 ID';


--
-- Name: COLUMN user_master.is_active; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.is_active IS '사용자 잠김여부';


--
-- Name: COLUMN user_master.init_passwd; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.init_passwd IS '초기 Password 여부';


--
-- Name: COLUMN user_master.modified_password_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.modified_password_at IS '비밀번호 변경일시';


--
-- Name: COLUMN user_master.valid_from; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.valid_from IS '적용일';


--
-- Name: COLUMN user_master.valid_to; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.valid_to IS '만료일';


--
-- Name: COLUMN user_master.created_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.created_at IS '등록일시';


--
-- Name: COLUMN user_master.created_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.created_by IS '등록자';


--
-- Name: COLUMN user_master.updated_at; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.updated_at IS '수정일시';


--
-- Name: COLUMN user_master.updated_by; Type: COMMENT; Schema: lock_manager; Owner: lms_admin
--

COMMENT ON COLUMN lock_manager.user_master.updated_by IS '수정자';


--
-- Name: code_sequences; Type: TABLE; Schema: public; Owner: lms_admin
--

CREATE TABLE public.code_sequences (
    composite_key text NOT NULL,
    last_value integer NOT NULL
);


ALTER TABLE public.code_sequences OWNER TO lms_admin;

--
-- Name: seq_access_id; Type: SEQUENCE; Schema: public; Owner: lms_admin
--

CREATE SEQUENCE public.seq_access_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1
    CYCLE;


ALTER SEQUENCE public.seq_access_id OWNER TO lms_admin;

--
-- Name: communication_logs log_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.communication_logs ALTER COLUMN log_id SET DEFAULT nextval('lock_manager.communication_logs_log_id_seq'::regclass);


--
-- Name: customer_gen_history history_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_gen_history ALTER COLUMN history_id SET DEFAULT nextval('lock_manager.customer_gen_history_history_id_seq'::regclass);


--
-- Name: lock_customer_history history_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_customer_history ALTER COLUMN history_id SET DEFAULT nextval('lock_manager.lock_customer_history_history_id_seq'::regclass);


--
-- Name: lock_identity_history history_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_identity_history ALTER COLUMN history_id SET DEFAULT nextval('lock_manager.lock_identity_history_history_id_seq'::regclass);


--
-- Name: lock_model_mgmt model_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_model_mgmt ALTER COLUMN model_id SET DEFAULT nextval('lock_manager.lock_model_mgmt_model_id_seq'::regclass);


--
-- Name: lock_settings_history history_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_settings_history ALTER COLUMN history_id SET DEFAULT nextval('lock_manager.lock_settings_history_history_id_seq'::regclass);


--
-- Name: notice_mgmt notice_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.notice_mgmt ALTER COLUMN notice_id SET DEFAULT nextval('lock_manager.notice_mgmt_notice_id_seq'::regclass);


--
-- Name: notice_read_history notice_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.notice_read_history ALTER COLUMN notice_id SET DEFAULT nextval('lock_manager.notice_read_history_notice_id_seq'::regclass);


--
-- Name: product_mgmt product_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.product_mgmt ALTER COLUMN product_id SET DEFAULT nextval('lock_manager.product_mgmt_product_id_seq'::regclass);


--
-- Name: sequence_history history_id; Type: DEFAULT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.sequence_history ALTER COLUMN history_id SET DEFAULT nextval('lock_manager.sequence_history_history_id_seq'::regclass);


--
-- Data for Name: access_log; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.access_log (log_id, user_id, uri_method, uri, description, client_ip, trace_id, jsession_id, agent_type, created_at) FROM stdin;
ACCESS_20250910202753_00000001	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	3de6ccae-4812-4f3c-8615-1525c3b98b9d	57C879B3ED8C3A5CCEACC10B99F457EB	01	2025-09-10 07:27:53.888834-04
ACCESS_20250910202753_00000002	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	913425ae-0d87-44a7-8d35-57056a5e94cf	D3FE4D3216109113131FBB4D7285F135	01	2025-09-10 07:27:53.898559-04
ACCESS_20250910202756_00000003	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	b188c642-0c3d-4851-b1f6-1977fb08111a	7CF8A31C95072A35DFD6DCF11F23B9B8	01	2025-09-10 07:27:56.35361-04
ACCESS_20250910202756_00000004	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	15c68bc7-a57f-473d-a861-b7f8bf1191ce	DA1E88F28BD75A9BEA1C02B5418B0C85	01	2025-09-10 07:27:56.428834-04
ACCESS_20250910202757_00000005	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	5f3011c8-3b56-473b-bce9-1d251444f53b	D0EA08A3BB63D9B705A7BB97ABF008D9	01	2025-09-10 07:27:57.130826-04
ACCESS_20250910202759_00000006	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	95a1f5df-19b0-4bc4-9037-b4d7e268950b	F1DCBE132A1E24BAE45A339FFBDE755A	01	2025-09-10 07:27:59.242541-04
ACCESS_20250910202801_00000007	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	984804ed-86c5-4603-a31c-3da5c1a42b43	B8FA84BB4434E9B52A3B12728712ECAA	01	2025-09-10 07:28:01.282538-04
ACCESS_20250910202833_00000008	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	4543965e-6483-4817-a5a3-bfe95b33b184	92951D8B6DABC397DD0A6B4181E109A9	01	2025-09-10 07:28:33.393827-04
ACCESS_20250910202834_00000009	system	GET	/api/v1/ref/user/detail/system	사용자 관리 - 상세정보 조회	10.42.0.1	e9ef516c-861d-4e99-aff8-3e54e1e8b7d9	DD8B7795BB384175DBFF74D4BADA1675	01	2025-09-10 07:28:34.493407-04
ACCESS_20250910202838_00000010	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	1e42d79a-f0c7-41e9-ac7d-a008d6834ebc	CA257FE0A36FC0A49DBD9CC964269B53	01	2025-09-10 07:28:38.69328-04
ACCESS_20250910202839_00000011	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	af31ebae-f5f3-4e68-8cd9-7da27cbd68a9	062F12885B16369C07F78469EDFD9580	01	2025-09-10 07:28:39.469448-04
ACCESS_20250910202840_00000012	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	afd56d2e-a656-4450-97b3-06c47b89b34a	70D1621DC516660A0CE0BE03A975A111	01	2025-09-10 07:28:40.377822-04
ACCESS_20250910202841_00000013	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	09448b4a-dc96-4fdc-a61b-fa8fcdc0d2d4	EA9609913FC4DE64B72C4F769A5092C2	01	2025-09-10 07:28:41.254822-04
ACCESS_20250910202843_00000014	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	04db1edb-5e23-4376-bc40-cd242a31779a	061CCF0CEC80DFA9DF642742C832C7D3	01	2025-09-10 07:28:43.562063-04
ACCESS_20250910202848_00000015	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	b83c055f-9a5c-4bb6-8ab8-0ca8251c1400	25ED9E92C9AFD576212C0C4A95F5FBAE	01	2025-09-10 07:28:48.111551-04
ACCESS_20250910202848_00000016	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	0b669f90-5dc4-448e-9c2c-d75901169f1c	F6F8ED3AF0B106CC502F43FD2F857350	01	2025-09-10 07:28:48.952839-04
ACCESS_20250910202851_00000017	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	1635d88e-ede6-4a0b-85f5-6dee5a63562b	9463D2CBF9E587AA65317B9A36EF990B	01	2025-09-10 07:28:51.679927-04
ACCESS_20250910202852_00000018	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	50f6a5f6-0927-4f02-a109-6dc31d7ec446	CAD2276AAEE9B11CB343F149556C7BC1	01	2025-09-10 07:28:52.40325-04
ACCESS_20250910202853_00000019	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	18f6ffef-8b9d-4016-8c3a-922464a83c4e	F9988A743F89876BF9C02EC8400D4DA6	01	2025-09-10 07:28:53.203835-04
ACCESS_20250910202853_00000020	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	921be716-1890-470a-ac4a-b146a7f4a3cc	4BF14C488568C8DD29E597633B1EA944	01	2025-09-10 07:28:53.920352-04
ACCESS_20250910202932_00000021	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	eea81292-bbb8-4d78-b802-e1b16f01055b	2E66C674B8F85A43F24118FBB2A80775	01	2025-09-10 07:29:32.525455-04
ACCESS_20250910202932_00000022	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	fba0d218-f595-4b50-a6cd-398f967b3ebe	709CC4C9520AEA413C53073319ADB44B	01	2025-09-10 07:29:32.583707-04
ACCESS_20250910202947_00000023	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	76e7b245-fec0-48cf-b7a2-9717900a3a9a	8A1207FAE924F7A3CE999B7116CE815B	01	2025-09-10 07:29:47.277818-04
ACCESS_20250910202951_00000024	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	3381efe3-b816-44c2-9416-4509d60ded57	40127835996CC5A1486CC82BA0E7853C	01	2025-09-10 07:29:51.337096-04
ACCESS_20250910202951_00000025	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	54136c62-6128-4325-8ce3-d0dac04e0633	4F4D3B8454DF5F73125B6D55C5AF8BD9	01	2025-09-10 07:29:51.992133-04
ACCESS_20250910202953_00000026	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	fbca3fb7-7e89-4f16-88f8-f65e36126b4b	7495749C3D890D4E47DAFCA73D622544	01	2025-09-10 07:29:53.178204-04
ACCESS_20250910202954_00000027	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	08476ec7-40a4-42d9-8855-bfe710748f7f	6E613EECBC9E9B44C843A091439DF034	01	2025-09-10 07:29:54.138827-04
ACCESS_20250910202954_00000028	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	058257c6-17c2-48a4-bd13-d776c2f309db	81501102A0B9279AF5FB12FAD4E07B18	01	2025-09-10 07:29:54.427979-04
ACCESS_20250910202955_00000029	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	baa455e4-67d9-49c3-933c-e593b6ed9536	B41AC7D79A8EB62CF87AAB90E74E9F8C	01	2025-09-10 07:29:55.134253-04
ACCESS_20250910202955_00000030	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	fcb32aef-3f8d-4168-9daf-58226364a4e1	5248D6B29FAB9645FB8A077B4CDC32F7	01	2025-09-10 07:29:55.429487-04
ACCESS_20250910202956_00000031	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	3dc38544-5c53-44b3-8df5-7e5ee2f40897	FD5B268D405BC2F8A802820081CA0953	01	2025-09-10 07:29:56.13211-04
ACCESS_20250910202956_00000032	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	d65116f4-db7f-448f-a1cb-76c633fbcf43	F2932F780E654C79CA9D6007E63C69A2	01	2025-09-10 07:29:56.743277-04
ACCESS_20250910202957_00000033	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	ce278a37-7d39-4f83-a4dc-3a518563b0b8	44A654411794A6F6D65FB9F3834D5766	01	2025-09-10 07:29:57.196126-04
ACCESS_20250910205119_00000035	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	32241ae9-520f-4d8a-b483-39e2ca556ba8	4C4CEEFFFFB4158A89299B2F604784FB	02	2025-09-10 07:51:19.877552-04
ACCESS_20250910205119_00000034	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	77ac91e1-e1b9-46ad-9887-70e681f2e94f	7EF80CD6EB39BF4B3180CBEFAEC623B8	02	2025-09-10 07:51:19.877089-04
ACCESS_20250910205138_00000036	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	616131c7-b1ce-4dbc-abb4-4cd85b6b5d5f	7B778809372853C3F907DB942FAC62E5	02	2025-09-10 07:51:38.320239-04
ACCESS_20250910205138_00000037	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	f4c7e39c-8a3d-47f3-850c-6bddc3b45063	7B778809372853C3F907DB942FAC62E5	02	2025-09-10 07:51:38.327724-04
ACCESS_20250911085809_00000038	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	bdcdc2c8-0398-4103-863c-2c2e29caf258	2B91028D2F32FBC4ED91396FCFB86A7B	01	2025-09-10 19:58:09.405278-04
ACCESS_20250911085809_00000039	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	356d9743-973a-4655-b46a-53a147385a78	E6321F44A8E0809E2B448DDFFD2E58F1	01	2025-09-10 19:58:09.407013-04
ACCESS_20250911085813_00000040	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	ce9476f3-484e-47fc-bfb6-d4aef87fb5af	B0CA2EB590B06F783311F96707294CE2	01	2025-09-10 19:58:13.444801-04
ACCESS_20250911085813_00000041	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	753c2440-3d29-4287-a17c-b5ad31b935d0	91D8ECC7558E716B99167B5AC0D37164	01	2025-09-10 19:58:13.48112-04
ACCESS_20250911085814_00000042	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	a1a32239-8e4e-4b2e-9067-9a0bacc40e54	0BBD3B01F503279F6A510E9408492DDE	01	2025-09-10 19:58:14.439304-04
ACCESS_20250911085815_00000043	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	ac9cbb07-202d-467d-a97f-7a9fa3489346	FDF314D6F4F5B2B5DF5325E7D59D6C01	01	2025-09-10 19:58:15.685506-04
ACCESS_20250911085816_00000044	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	5e2cff83-0fb1-4a2f-8e17-3c2647696a6a	8A8C1813DCC9D93AA0A2FEB06A38C655	01	2025-09-10 19:58:16.62014-04
ACCESS_20250911085817_00000045	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	378d1551-a716-4a26-8c21-301c4adf8d33	E4F74335F51E60ECA1F7852B977B7A32	01	2025-09-10 19:58:17.303446-04
ACCESS_20250911085817_00000046	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	fcac5e0c-4efe-44df-bbb3-c3756cdeb159	3A06082BCE7AD143CBD9010EF398A665	01	2025-09-10 19:58:17.824437-04
ACCESS_20250911085824_00000047	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	5ef9b7bd-b318-4a10-aa5d-b9eab3e50580	E999A9EE03606B78D4FCE9AE4BFB9533	01	2025-09-10 19:58:24.317492-04
ACCESS_20250911085826_00000048	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	1b8eb9ac-93ea-48cd-b813-afe4601f2428	B3B5C4947D5E43BD550E17D5AF5ABFAE	01	2025-09-10 19:58:26.173823-04
ACCESS_20250911085827_00000049	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	9092a197-347f-484c-b1d1-42984945297d	43096A869DE6375DD57535CBE86CF5FD	01	2025-09-10 19:58:27.732999-04
ACCESS_20250911085828_00000050	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	b2f3a3bd-3c1c-44d2-9c89-bc3237dbe7e8	2F6A7D9FAAF6CB5215C73BF420BFB22F	01	2025-09-10 19:58:28.513164-04
ACCESS_20250911085839_00000051	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	bc904c92-5d38-46dd-b52c-e1ba2306e262	97956D90E4DECF7DEFC3E92253FC6F7E	01	2025-09-10 19:58:39.315515-04
ACCESS_20250911090000_00000052	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	c1cc37ee-08be-4292-80b6-467a1deb33f7	AA43F21AD61E616C1C544A5F74BA26EA	01	2025-09-10 20:00:00.722107-04
ACCESS_20250911090002_00000053	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5e2b965a-0fb3-495a-84f5-df8de25cdd2e	D3150B724D0F72B98DCE4F4F69BCCA75	01	2025-09-10 20:00:02.036049-04
ACCESS_20250911090018_00000054	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	ad35cda3-51b0-4c28-9e3e-d2f3a3612c93	FA565A0B2304BFADFD4C532823D79121	01	2025-09-10 20:00:18.511482-04
ACCESS_20250911090024_00000055	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	5e4c72ff-c2d2-497f-848a-afcca05e7354	E1A735A8C50783C9E4F67B28665343EF	01	2025-09-10 20:00:24.469194-04
ACCESS_20250911090240_00000056	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	18894c0e-eeb0-4102-bda0-6fedf3e21096	441138D76FA7C40197DB136FE1CC01D4	01	2025-09-10 20:02:40.313145-04
ACCESS_20250911090240_00000057	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	02be269d-c454-4cd3-801f-6b3147549dac	441138D76FA7C40197DB136FE1CC01D4	01	2025-09-10 20:02:40.313143-04
ACCESS_20250911092715_00000058	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	bfae6362-5432-44f0-aa05-b97e8344cef2	F753375146905382E06BF043DCB10D5C	01	2025-09-10 20:27:15.468721-04
ACCESS_20250911092715_00000059	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	6fd8c552-1294-4a16-ad30-3a88fd44af8d	8FAEE29D80F48F2D23B4CB37616A1521	01	2025-09-10 20:27:15.472258-04
ACCESS_20250911092724_00000060	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	dea67c53-5980-43ee-8570-b08594be3229	A0F4C10EE93520F6B1A93BFFCD032A76	01	2025-09-10 20:27:24.103188-04
ACCESS_20250911092724_00000061	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	d554b8fc-b9c5-40b8-a8e4-ba3a9a7898a2	ABDE9461FA9873438260FCC038BC916D	01	2025-09-10 20:27:24.203929-04
ACCESS_20250911092725_00000062	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ec656391-c14d-40f4-873d-02ca78a6a645	6BB4FD714B4B10BA08F0F8497F916BA1	01	2025-09-10 20:27:25.171258-04
ACCESS_20250911092725_00000063	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	e48eed9c-8e8d-4ac2-af87-7edb64597f55	ED8BEEBB5B05E226CA6D2988C5E7348B	01	2025-09-10 20:27:25.679231-04
ACCESS_20250911092726_00000064	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	67b7b6a9-7deb-4ae0-a694-3b3c1f9dbe6f	502A1DC16B802FC7895FC6A0ED1C94B4	01	2025-09-10 20:27:26.26098-04
ACCESS_20250911092727_00000065	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	2981f4fc-d6b8-4fe3-80f6-3ac391c35d3f	8E43E37F00B6E2FA4F66D27D9DABEE60	01	2025-09-10 20:27:27.015566-04
ACCESS_20250911092727_00000066	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	c252fa01-1753-4224-af62-0b5133a07fea	73E8D07EE6237382CE92A59A36F32ABC	01	2025-09-10 20:27:27.491779-04
ACCESS_20250911092728_00000067	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	43c2e60c-87a4-47ce-bbc4-bce7d00c56ce	6360B8C5161BE99A72950FDA1BDA7D86	01	2025-09-10 20:27:28.006108-04
ACCESS_20250911092728_00000068	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	5dc6b2a5-0d71-4473-9dcb-08db5e5e7a32	D1C231B960F5AE9BE034CE1AEB4646DC	01	2025-09-10 20:27:28.764776-04
ACCESS_20250911092729_00000069	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	059b993e-8958-4e73-836c-5761927d6029	DC6923E753329B540C184687DE24895B	01	2025-09-10 20:27:29.346475-04
ACCESS_20250911092729_00000070	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	f41e1c18-941a-407e-b446-7836a8374276	B9D895F826F8E6086867A06F7F85CE36	01	2025-09-10 20:27:29.857608-04
ACCESS_20250911092730_00000071	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	8ce008ce-beb6-4230-b068-ee823b7ca547	B44AE7551697ACFF585A55DC717A90E4	01	2025-09-10 20:27:30.417059-04
ACCESS_20250911092730_00000072	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	ee9fb262-c5ac-4755-8bb1-666ea265926f	E9A78556A0413457CAAB101AEFA7D289	01	2025-09-10 20:27:30.95607-04
ACCESS_20250912102717_00000073	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	5982e5e7-5c2f-499e-a0d4-31423033fcdf	774E5683714E18828A0F046FFF67B3EB	01	2025-09-11 21:27:17.340585-04
ACCESS_20250912102717_00000074	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	7c779f12-ef8f-4cdc-8e71-55c426ecb77b	E9BE8E9A98EFD2C4B4949478B064205A	01	2025-09-11 21:27:17.341195-04
ACCESS_20250912102721_00000075	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	c8210668-0cfe-4a6e-ba86-d798e5829c72	1137387564F3364843BCC8C2B7FB4CE6	01	2025-09-11 21:27:21.44363-04
ACCESS_20250912102721_00000076	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	7b3b0c29-17f8-4c9e-b7f2-c60cb398af43	D6260F5CA512D0CBB24EBB142CA0CADE	01	2025-09-11 21:27:21.47602-04
ACCESS_20250912102722_00000077	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	3393c4f0-8668-4461-8f48-5ee00cef7487	1E4586B93EC8843623CF121C35CF1422	01	2025-09-11 21:27:22.056961-04
ACCESS_20250912102724_00000078	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	281f7eec-a793-4a38-ac57-b5391ea642cb	D3E0BA034475AD919B84BAB85D4F2901	01	2025-09-11 21:27:24.631329-04
ACCESS_20250912102725_00000079	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	7b061819-1b91-4403-a29b-a7fd054ee4ad	02BFCD4A6B9BA4679943CAC4BC71035D	01	2025-09-11 21:27:25.400398-04
ACCESS_20250912102726_00000081	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	2efb5cff-4183-4e1b-92fc-93deff85b60b	F21D3DCA67665D30AEA4EFF4A1D7CC3B	01	2025-09-11 21:27:26.955064-04
ACCESS_20250912102733_00000083	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	52f43a94-96db-4264-9f77-b41b66fff246	92BACB3F455396E31F18EA2E3A62F03E	01	2025-09-11 21:27:33.199461-04
ACCESS_20250912102738_00000084	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	2c6d173a-9a21-41ce-9d2a-1c6188858d72	E905ED4169DD9CC3997790879866F483	01	2025-09-11 21:27:38.205726-04
ACCESS_20250912102738_00000085	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	2532cd13-ac65-449e-b75e-4751014e4558	EBAB33864DFE1C2BF5357157FD26A8C2	01	2025-09-11 21:27:38.747007-04
ACCESS_20250912102740_00000087	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	7801b150-5b5a-4cb3-86f5-2bda04de3610	76B7D0CBFBE49AE343663C75568CCC7A	01	2025-09-11 21:27:40.563065-04
ACCESS_20250912102742_00000089	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	a516d40e-33f6-4dde-9b16-e608faaf7b8f	ECD43EDBB39A7DC11517B30F42B0E65D	01	2025-09-11 21:27:42.029693-04
ACCESS_20250912102742_00000090	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	ce275031-8be9-43ad-ac6d-4cc5b69829ee	DD0009C3854D04AE3CC5ACC5140252D8	01	2025-09-11 21:27:42.534001-04
ACCESS_20250918164902_00001237	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	7556cf44-314e-40c1-81dc-bcd4a298a571	2C708FAB6360C7C0BD8716611C5F5A6C	01	2025-09-18 03:49:02.443368-04
ACCESS_20250918164904_00001238	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	2aff4d38-59d3-4d1d-8d11-555df7bbb79a	3ADE096C9152741949C00906711FB7CF	01	2025-09-18 03:49:04.471414-04
ACCESS_20250918175553_00001304	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	d9e514bf-a07e-4c11-a3e5-64d720cfcac9	61C78EC8C096F203A24302522C8E294A	01	2025-09-18 04:55:53.667018-04
ACCESS_20250918175553_00001305	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	a677f8c9-8c8d-4909-bc22-cc78eb76fdf8	28DF7BD1F8D1DA2B44744393C80015D3	01	2025-09-18 04:55:53.703131-04
ACCESS_20250919161405_00001366	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	e3dbe9b0-2c82-45d5-bd16-b0284acbe116	26EC85508AEFF80B3452EA0F519EAA9E	01	2025-09-19 03:14:05.184774-04
ACCESS_20250919161409_00001367	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1	e6b7dc77-ca59-4a16-b7d5-80e5016d9fa9	4A657D02C6D22AA753DAF2041A02D3D6	01	2025-09-19 03:14:09.249425-04
ACCESS_20250919161412_00001368	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	de448d3d-36ce-4516-b5c4-e9bec5f2a410	C3EAAFD866DC2D2EF30741660C5EE8B5	01	2025-09-19 03:14:12.089446-04
ACCESS_20250919161419_00001369	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	6e851dad-ffa9-4244-8ed2-ad99b1e35c21	3C521B2889F1D15CC6569CEBD44DDEE9	01	2025-09-19 03:14:19.184574-04
ACCESS_20250919161430_00001370	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	14ef1e56-1089-4925-ae39-4df0ff6bb2ad	F958F24C8791E8C0557C44370ED56187	01	2025-09-19 03:14:30.127228-04
ACCESS_20250919161436_00001371	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	ea9b7841-67a8-447d-85f2-0448cacb0109	2BD8B7DD58E08624E3C5EDB79FE50CA0	01	2025-09-19 03:14:36.254977-04
ACCESS_20250919161445_00001372	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	57f94910-2cf3-4404-96ad-37d5f43daaa0	CA62BE1687064D75BB4F63970EE3C14C	01	2025-09-19 03:14:45.07341-04
ACCESS_20250919161449_00001373	system	POST	/api/v1/outgoing/slock/config	출고 부가정보 불러오기	10.42.0.1	ac180642-9a42-4c16-a27e-08c534b369ef	3FE58EB200DC67F584879B56C410EAE7	01	2025-09-19 03:14:49.543911-04
ACCESS_20250919161454_00001374	system	POST	/api/v1/outgoing/slock/config	출고 부가정보 불러오기	10.42.0.1	ec59345e-aad6-4fe9-8d18-0f57d0a6844f	0F01C804E2C64AA2E76A3C634341018E	01	2025-09-19 03:14:54.830927-04
ACCESS_20250923172802_00001415	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	571fcad8-dbb6-4feb-8fa1-05f94c247f3d	B770C29E0553B7E16E0C94465C8866A5	01	2025-09-23 04:28:02.500507-04
ACCESS_20250923172828_00001416	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	8a30ae62-2997-4e27-bff3-bfbfc7f36dfb	33F584D79707BF084129AF0B56587043	01	2025-09-23 04:28:28.266334-04
ACCESS_20250923172837_00001417	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	36bb9831-0490-4ab6-91f9-2c21f13de28d	0B4BB8E49B468D95CA813ABB8507F0BD	01	2025-09-23 04:28:37.420253-04
ACCESS_20250925102002_00001455	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	63680fd3-134c-499a-81bc-4b63594dc55d	92E8B7EF75A8B0CD43C0994AE18DE008	01	2025-09-24 21:20:02.40363-04
ACCESS_20250926150524_00001477	system	GET	/api/v1/product/12	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	f63be282-ebcf-4774-9754-87dceb88af8a	1A30BD12381BCA7B5C5FBCC8D5A5C228	01	2025-09-26 02:05:24.48366-04
ACCESS_20250926150530_00001478	system	GET	/api/v1/product/12	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	63a3510b-43ce-407f-9cec-2182cadd2763	FBB2D8256A9DB214226818FCEC2E30AD	01	2025-09-26 02:05:30.134028-04
ACCESS_20250926150550_00001479	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1, 10.42.0.170	606267a7-d0b5-41a9-b8d0-c70333c3e104	4E17DAA3EFDC19E2840DCA0537AB4AD8	01	2025-09-26 02:05:50.820096-04
ACCESS_20250926164655_00001529	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	dafd6562-1aa2-415f-b4bf-2c115b82cbc2	A7864E34138AA20E402E9F8BC9AF82D7	01	2025-09-26 03:46:55.979188-04
ACCESS_20250926165405_00001571	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	9696c4b6-34ed-4412-839f-4c2b374f7a70	A2BD8162DCD0B23F4A8BE89C6674978B	01	2025-09-26 03:54:05.065878-04
ACCESS_20250926165413_00001572	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1, 10.42.0.170	8fbb798c-3555-4a53-a0e5-50cbf1f455d8	54215A59955FABE52C269924E4DD82C2	01	2025-09-26 03:54:13.073009-04
ACCESS_20250926165415_00001573	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	c76e228d-fcd1-40ea-baa5-91389bccc621	451682805B0947F35641B8CFADA9FEE7	01	2025-09-26 03:54:15.784708-04
ACCESS_20250912102726_00000080	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	10f0fa2b-c545-4422-a65e-b59d89e772a4	121993B081F593BAC2EC5534801E8278	01	2025-09-11 21:27:26.360796-04
ACCESS_20250912102727_00000082	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	79a78903-bd60-4039-b1eb-bf3b7f5f7b28	1708EF577DF728E810CBDCBCC0673D7B	01	2025-09-11 21:27:27.780812-04
ACCESS_20250912102739_00000086	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	c7e1e6fa-e27e-4566-b776-86bdad4416b8	5362EA7A8FB79041A8E49A8D72B4235A	01	2025-09-11 21:27:39.530343-04
ACCESS_20250912102741_00000088	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	5a88a653-d1a7-461b-985b-773bcec256cc	C444A6F1E0D2BFB08C0784943C6708AF	01	2025-09-11 21:27:41.237713-04
ACCESS_20250915141053_00000091	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	6ef70d7a-5ede-42e6-9005-2c3b1c29b438	FC874B8B089B9F5041CC4BC94CDA948A	01	2025-09-15 01:10:53.864627-04
ACCESS_20250915141053_00000092	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	61f0472b-0be5-4f55-a464-69d69ec06f45	59F3570911FBCEA09B7609BA753DC044	01	2025-09-15 01:10:53.864649-04
ACCESS_20250915162313_00000093	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	5107b9e5-f122-4fac-9606-9077b628a946	DBAE46FA1785E11D212B5A1DD7927A4C	02	2025-09-15 03:23:13.339758-04
ACCESS_20250915162313_00000094	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	4aaeba40-cb2e-43ff-9d3d-a27b94903fea	783F93986A46A9263C90B043B7ADDF43	02	2025-09-15 03:23:13.339802-04
ACCESS_20250915162317_00000095	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	49437a30-e55c-40ee-989a-f4ec5bdc0e72	0852FB6684DD28D85E1581E93F266603	02	2025-09-15 03:23:17.558934-04
ACCESS_20250915162317_00000096	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	2493c425-cf2d-4953-8b50-17aa318ec591	4413F3578229251E50F8E93848EE5B90	02	2025-09-15 03:23:17.623096-04
ACCESS_20250915162318_00000097	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	b912e716-6fdc-4cd7-9119-a931d9be6fe0	1DE3ECB066917B1BF923808803FE824F	02	2025-09-15 03:23:18.668449-04
ACCESS_20250915162319_00000098	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	91f9920e-df92-4b90-a7ce-c96288a85141	83934FB12EC3399D48612757E05026B0	02	2025-09-15 03:23:19.204062-04
ACCESS_20250915162319_00000099	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	72de25e8-6f6a-423f-8ee7-2187f82cce71	F225C66228A82F4D1024D4D4AC5A7268	02	2025-09-15 03:23:19.708925-04
ACCESS_20250915162320_00000100	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	fd55377d-d79d-4917-ac2a-d5a1b79fc251	950551B016D9D8A74B4D2E3A8421A563	02	2025-09-15 03:23:20.82436-04
ACCESS_20250915162325_00000101	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	87fd0a2e-a4b3-49e0-8429-6285c3d1e093	416B3FFC069D7D541D6FEAA9072DC3C6	01	2025-09-15 03:23:25.477752-04
ACCESS_20250915162325_00000102	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	8b719a96-624f-4715-8b4f-f3532953ba73	D82ACE7196880FF52EA50E6C9025EF0B	01	2025-09-15 03:23:25.477929-04
ACCESS_20250915162331_00000103	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	684ebf2c-46e3-4f96-a409-013a78814d5d	912DC7D1C28C8BD153E63491083A66E5	01	2025-09-15 03:23:31.46268-04
ACCESS_20250915162331_00000104	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	96b2bf50-6020-4784-8b20-b366b9eb32bc	8E9E102F37A0515036DC02124997C408	01	2025-09-15 03:23:31.503505-04
ACCESS_20250915162350_00000105	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	e314d31f-f7e7-4e9f-9fa1-f39e1f04506e	CF8BEAF729C3EF158CD8CE5C2F19952E	01	2025-09-15 03:23:50.497279-04
ACCESS_20250915163153_00000106	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	b7e1a3b9-a038-44ff-b026-5ebb883e2320	D914CFEF706B5F08AAB7A5E2982FD9F4	01	2025-09-15 03:31:53.501781-04
ACCESS_20250915163153_00000107	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	582451d7-a605-4dc7-a79e-584496f58f74	3B623FF0EDACF519A4560C2A3906A6CD	01	2025-09-15 03:31:53.501502-04
ACCESS_20250915163249_00000108	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	ccf79940-b502-47fb-9ad1-f7723bc54b5f	04E8FC9CC90BF886DE185C20B6439B3A	01	2025-09-15 03:32:49.080772-04
ACCESS_20250915163249_00000109	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	bbcba3ef-7f9e-409e-9230-84f90191f88d	6F12E6F2C70AA0F959B04A150A337CE9	01	2025-09-15 03:32:49.080774-04
ACCESS_20250915163251_00000110	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	77d50633-c08f-417d-9a95-d1f41c6a797a	C063B299C2750D2006A535AFD979E0A6	01	2025-09-15 03:32:51.570851-04
ACCESS_20250915163251_00000111	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	1629b1f8-f995-4da9-b467-952963d747a6	F3C176FAC577A1890296E393327561AD	01	2025-09-15 03:32:51.615776-04
ACCESS_20250915163303_00000112	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	cd223d99-eb25-494b-8dae-1fca25d2aed2	5F713B21466E41D5D9C962612647FE1E	01	2025-09-15 03:33:03.050433-04
ACCESS_20250915163307_00000113	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	6fd65265-20a8-427d-928f-cf2181713d55	F74F82EF43B86CCE439ED5F40E3B05C5	01	2025-09-15 03:33:07.538318-04
ACCESS_20250915163309_00000114	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	f8314744-bc4e-469a-abb0-36807de449ef	8CAD6E22D14732979045B466A9F97C6B	01	2025-09-15 03:33:09.632801-04
ACCESS_20250915163310_00000115	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	4f089397-325d-40a2-9d56-c2988cdf48fb	84988B1B1DE8697E10DF2E3CEAF44460	01	2025-09-15 03:33:10.836864-04
ACCESS_20250915163311_00000116	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	83527bd0-2185-4265-b0f0-ed39cf0b3eed	1346C08BFAC67C6B636EFB3385061F4E	01	2025-09-15 03:33:11.662385-04
ACCESS_20250915163313_00000117	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	1eae7f81-8515-4a4c-b7cd-a8b0166d6242	1332C4EFAC903D0600CACFDC34CD5288	01	2025-09-15 03:33:13.168549-04
ACCESS_20250915163317_00000118	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	fdce4517-a26b-4bb8-94c5-344bf6632065	20C512B07803FE497D89986F821547D6	01	2025-09-15 03:33:17.282827-04
ACCESS_20250915163320_00000119	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b7c5f329-0c1f-447d-9267-b987aee3f10c	8EA1B7C7CEA1BE3D4E388762C8EC8BB6	01	2025-09-15 03:33:20.101608-04
ACCESS_20250915163404_00000120	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	6382e73e-286d-4f47-bea6-e035277a267b	A9C86C9732B41B210E7F6062DCE98D54	01	2025-09-15 03:34:04.316017-04
ACCESS_20250915163404_00000121	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	b00b3418-a37d-4a94-b968-33fd991874f0	1C74DD49B06E6F380B34DE64A437BE35	01	2025-09-15 03:34:04.316992-04
ACCESS_20250915163412_00000122	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	a8ab4a0e-2f49-436b-9d4e-4516c07ddf25	387B22A86F0858FD673B598668369E05	01	2025-09-15 03:34:12.23073-04
ACCESS_20250915163422_00000123	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	de0e0ed3-b12b-4254-b9d1-c3c2d0f6df66	51A31FB4E1AA8FA7AFEA52ABC154DE55	01	2025-09-15 03:34:22.913949-04
ACCESS_20250915163425_00000124	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	1b4dcd93-9ab7-439a-b08d-9b9827cee108	C0043F5ED8CCDA9854683A3A2D37F47E	01	2025-09-15 03:34:25.10745-04
ACCESS_20250918165628_00001239	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	f69cbcac-884c-4e4c-a86f-d49c21a43f7e	7376B1E6DAAEEA79BAD9B76AB456D72F	01	2025-09-18 03:56:28.848975-04
ACCESS_20250918175603_00001306	system	GET	/api/v1/incoming/slock/6	입고관리 - 상세정보 조회	10.42.0.1	0737d8eb-9818-4838-acdb-98a262c9de0d	A0A8A2224970E4E490F6A372CAC8110C	01	2025-09-18 04:56:03.048553-04
ACCESS_20250918175616_00001309	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	47e1d84a-b32d-4017-abb0-a65e5bed4c9b	0DA8289ABD7D6ACA66BE0912C4865AF9	01	2025-09-18 04:56:16.108608-04
ACCESS_20250918175618_00001310	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	1163b3db-2043-402c-b2e7-38a5132eec09	7229098FA79834F0BE8C9D8B177886EF	01	2025-09-18 04:56:18.979206-04
ACCESS_20250918175702_00001311	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	03d158b9-b3d8-45fa-b417-22ed42e3eed4	BC2A622AD3A14EE9CFE9371B06386D5D	01	2025-09-18 04:57:02.970914-04
ACCESS_20250918175703_00001312	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	c37be612-86e7-4c77-abba-2ebff4c917d8	EB41E74527E64134F9AB67DD879D355E	01	2025-09-18 04:57:03.901455-04
ACCESS_20250919161503_00001375	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1	0b0c7e18-51b5-4231-9f1b-47fb18c175be	274485809BBDCEA6B7B0436B5AABD6C9	01	2025-09-19 03:15:03.350971-04
ACCESS_20250919161503_00001376	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	6e88309b-84eb-4f96-9858-cac1d0544029	6753CB6DD53CE80F75D266A3D760F527	01	2025-09-19 03:15:03.386649-04
ACCESS_20250919161509_00001377	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	75f285f2-72af-420b-9608-12866d7de09a	F11C53900D9F017F0BC93443CE2486A8	01	2025-09-19 03:15:09.830289-04
ACCESS_20250919161518_00001378	system	GET	/api/v1/product/8	입/출/반품 관리 - 상세정보 조회	10.42.0.1	0206e619-0318-41bf-a935-bc6d68812cda	599E6C1037AED420C722315697BD2653	01	2025-09-19 03:15:18.425015-04
ACCESS_20250919161528_00001379	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	db2fdaee-82e3-4df7-a7f1-5ccc26b1e52f	B85F042A2EC7E7E46DF3C7E909EDDD04	01	2025-09-19 03:15:28.21961-04
ACCESS_20250919161546_00001381	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	2c4d7632-d61a-415f-8a13-965247abbe1c	EC700BC5E23FAE30B857DDDFA827D563	01	2025-09-19 03:15:46.176486-04
ACCESS_20250919161546_00001382	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d35b0d65-8e59-43fe-a8c1-f74be6bcd31a	C6F173DCE32DCB3BF68E6D25CCE5CBFC	01	2025-09-19 03:15:46.205538-04
ACCESS_20250919161550_00001383	system	GET	/api/v1/product/8	입/출/반품 관리 - 상세정보 조회	10.42.0.1	22922bfc-7e26-49e7-abd8-b0824781f6da	C73EC2294C4F5299B0ACE01CEA8604EB	01	2025-09-19 03:15:50.946462-04
ACCESS_20250923172911_00001418	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	e9fb9649-4ace-4dcb-9638-1f7639a8bdb3	757893DE205917219C08585F5C7B1121	01	2025-09-23 04:29:11.53939-04
ACCESS_20250925102002_00001454	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	c296603a-52f0-46dd-bed3-6cadcd03e2dd	A78D578E52BCB19B045F04ABD27946CC	01	2025-09-24 21:20:02.403504-04
ACCESS_20250926150550_00001480	system	GET	/api/v1/product/12	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	4e0af753-8c4f-4682-814e-c963690c4201	75B873B6263BEDBA24082B0B23D61A4A	01	2025-09-26 02:05:50.82262-04
ACCESS_20250926164945_00001530	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	a5fbefa5-e826-480c-a1c3-bebf932d1901	582C89F57178C67D9EC56BEA3F819B3F	01	2025-09-26 03:49:45.177666-04
ACCESS_20250926164947_00001531	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	c53ed02c-b907-49d0-aa07-a030d27fc97d	1E99CB67E3C1817F81694176A71AEB53	01	2025-09-26 03:49:47.442458-04
ACCESS_20250926164954_00001532	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	c58f17d3-dca9-4a4c-b97c-608bbccf733d	5E05A7CBCF19252F43A4534900D797E8	01	2025-09-26 03:49:54.143753-04
ACCESS_20250926164957_00001533	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1, 10.42.0.170	33d94259-023b-4d7f-8e25-bea9c755596a	6C08C092B3583CBC64D0385798164302	01	2025-09-26 03:49:57.630397-04
ACCESS_20250926165006_00001534	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	b23d98e6-6960-4460-9df5-6094158c8d8a	1DCC8656372258A127B0CC8AC98D23DA	01	2025-09-26 03:50:06.314901-04
ACCESS_20250926165010_00001535	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	0815ed37-b793-4e4e-b0bd-d755f32ae7cd	A5A0ADE7AC0DE3A99E02B46AFDFF5859	01	2025-09-26 03:50:10.209623-04
ACCESS_20250926165418_00001574	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	bef2c255-1b38-44c9-9831-1c9c277bc0fe	13FA8C171A5A744901183AE56D7F25A7	01	2025-09-26 03:54:18.85433-04
ACCESS_20250926165423_00001575	system	GET	/api/v1/product/14	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	a856597f-fa97-44c5-acfc-58cd89f1aa7e	E5E6D31F0B2BB578419F83D0D397DAA1	01	2025-09-26 03:54:23.55245-04
ACCESS_20250926165431_00001576	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	e6f6ab14-8cc1-4627-95ae-0721b8b55c3b	7BFEB23D105A26E5FEF556B95239E113	01	2025-09-26 03:54:31.730103-04
ACCESS_20250926165432_00001577	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	9e2fd681-7f40-4740-9803-b99cde1e9596	7AFB0E9DC94D0B8A07D1092F9BFCDD70	01	2025-09-26 03:54:32.849326-04
ACCESS_20250930150033_00001594	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	b529061d-1584-4666-ad56-71de93685c42	22FC49D76C9366A1BA636BA74C0ED1A7	01	2025-09-30 02:00:33.535291-04
ACCESS_20250930150045_00001603	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1, 10.42.0.170	c76dbe40-7561-45a5-a841-8af907a52870	D82A44063B7C1162A8C3DD6F44300D91	01	2025-09-30 02:00:45.068991-04
ACCESS_20251002105435_00001614	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	4689c6b0-b159-4357-93cf-a6285e669103	12572843F438DF1AAA5298B3C57C0D06	01	2025-10-01 21:54:35.12621-04
ACCESS_20251002105435_00001613	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	f63e769f-7c70-487f-98f2-474d8d12cb6c	F2594DABA068080495C19DE67B205528	01	2025-10-01 21:54:35.126207-04
ACCESS_20251002105502_00001615	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	9ec870db-d487-4f58-bb1b-820aab7403e0	B54B779D9B6B57FECE23F3329DE8C778	01	2025-10-01 21:55:02.045041-04
ACCESS_20251002105502_00001616	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	dd664cd3-c87c-4034-845b-0ac31653d5ea	013AA5C950EDA781B06A1BF8D8103C07	01	2025-10-01 21:55:02.236821-04
ACCESS_20251002105503_00001617	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	19e2aa64-edfc-4e98-9195-ac7db3f0133f	214A2E5CBC176CAAD7FA6991F2F14EF3	02	2025-10-01 21:55:03.12984-04
ACCESS_20250915163425_00000125	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	760bb98a-2dcf-4e38-aec0-51cf18a63a80	984DBD51787B54B274C3A21327A8368E	01	2025-09-15 03:34:25.163728-04
ACCESS_20250915163545_00000126	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	573c7c63-23f9-4f82-b9c1-1767b07daa83	6BE1D712C063A7BAFCEE0F675B1F32C1	01	2025-09-15 03:35:45.270163-04
ACCESS_20250915163546_00000127	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	60461a2f-8ead-454b-964e-8dfec492975d	F13A48FA36EB9A4E96C9B4ED9193037C	01	2025-09-15 03:35:46.164441-04
ACCESS_20250915163547_00000128	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	99463ee7-40e7-46da-8d43-24be0d132a2f	2C963DD174471437F8015E0FE5E0B2ED	01	2025-09-15 03:35:47.521854-04
ACCESS_20250915163548_00000129	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7a607a37-3b50-4fbf-913b-3ffece55cf50	1CEF24BF1A1BD31EAA0C3A84718906B8	01	2025-09-15 03:35:48.853868-04
ACCESS_20250915163549_00000130	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	054a1913-3d60-44d7-ac47-c136fc1aa4cf	1AC7F570A3B740DF02A18935CEC05141	01	2025-09-15 03:35:49.658513-04
ACCESS_20250915163603_00000131	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	d31ea043-7b27-4bb3-93fc-01920f2185c6	95C912D1239BF09CDB553C3D1E027A7C	01	2025-09-15 03:36:03.527939-04
ACCESS_20250915163608_00000132	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	76e28ad7-718c-4c21-bbd6-f804219bcb6d	04868BEDC73D2C8D9739AD744B13900D	01	2025-09-15 03:36:08.780475-04
ACCESS_20250916101707_00000134	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	140a5885-be16-4c76-9c24-ed0b6f776cf2	8CF208DF62A8CBC71C1433DF878FF539	01	2025-09-15 21:17:07.182899-04
ACCESS_20250916101707_00000133	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	61cef6f8-cfe1-4632-b116-a7688f79a54c	E3CF568A013884786C5B061CE4733F8E	01	2025-09-15 21:17:07.182901-04
ACCESS_20250916101708_00000135	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	7e6218a3-ecc5-4a42-a57e-00075ca85ef1	010E27B41D587C8B91E9248C1CF64640	01	2025-09-15 21:17:08.779074-04
ACCESS_20250916101708_00000136	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	65a5f31c-2dc6-4b0e-93a8-0edc02112002	F300FE4301C79F636133D26FF0AF2894	01	2025-09-15 21:17:08.818819-04
ACCESS_20250916101710_00000137	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7228a184-cd74-4223-bdc7-604f1f32040f	E1CE1258AC25890A07C1E4769AABC235	01	2025-09-15 21:17:10.743856-04
ACCESS_20250916141208_00000138	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	626b33c5-7828-44dd-9f53-827224c3408b	916F0FFD6E1E37AE17E33B24610D35DC	01	2025-09-16 01:12:08.25134-04
ACCESS_20250916141208_00000139	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	6dfea9ff-42b6-45fb-b972-5c364fd349db	9110FB9BD31F2607DAFF02AFB27BF5FD	01	2025-09-16 01:12:08.252326-04
ACCESS_20250916141209_00000140	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	764897d5-97ea-4aee-a2de-5180e5d07b43	B003B92A07F42FF4676CEE1DE46B03B3	01	2025-09-16 01:12:09.578028-04
ACCESS_20250916142322_00000141	system	GET	/api/v1/ref/user/id/yskim	사용자 관리 - 아이디 검증	10.42.0.1	ef0aaf83-c9e7-4392-ad81-4a7d2fcf5c5a	E8D27E0C68DC23756FD23D9C2FB1568B	01	2025-09-16 01:23:22.266191-04
ACCESS_20250916142323_00000142	system	GET	/api/v1/ref/user/email/yskim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	3bce9627-eb07-4f66-9749-9de5928486ee	66BFFCBC4BEA608FBEA1FD820C58EA5D	01	2025-09-16 01:23:23.638776-04
ACCESS_20250916142330_00000143	system	GET	/api/v1/ref/user/mobile/01024687370	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	5e034b74-e401-49b6-bc06-869d3fc59c61	6CF62816D57A760006A41FB8C37856EF	01	2025-09-16 01:23:30.733892-04
ACCESS_20250916142354_00000144	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	770aeaf0-fa5f-4d00-91bd-4a2656a79f46	FB5A1A5F962BD63BC2BF89E2E94122C0	01	2025-09-16 01:23:54.497825-04
ACCESS_20250916142354_00000145	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b3c7563f-2269-4d1c-b3f9-e54cbb8195af	01FBFB51A81C810A66708CBF2B8AFE09	01	2025-09-16 01:23:54.674824-04
ACCESS_20250916142421_00000146	system	GET	/api/v1/ref/user/mobile/01059208536	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	501dd008-5237-47c9-af98-f0e95bd3fdd3	409DC211AD9C1973E60E3AECC88914D7	01	2025-09-16 01:24:21.902962-04
ACCESS_20250916142424_00000147	system	GET	/api/v1/ref/user/email/jhbang@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	f431c24c-7b2b-48af-8e75-fe6b7687c713	0B203342CFCE8842B0498D59EE8E818B	01	2025-09-16 01:24:24.559624-04
ACCESS_20250916142427_00000148	system	GET	/api/v1/ref/user/id/jhbang	사용자 관리 - 아이디 검증	10.42.0.1	3e28d35e-b692-4e92-8c8d-0fbf01df91f7	AD196FE0CBBFDA4E57D5D87B17297402	01	2025-09-16 01:24:27.262113-04
ACCESS_20250916142451_00000149	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	cc1c8918-3b9f-4321-865d-df71d968a0f8	4C3679A7167D3F17B3C2BE0843FA3DFB	01	2025-09-16 01:24:51.507404-04
ACCESS_20250916142451_00000150	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	fd2a7986-fcc4-41cd-82d4-eb318a0c487d	18C0211BFE5589C66EDA19FD822D10DF	01	2025-09-16 01:24:51.708779-04
ACCESS_20250916142458_00000151	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	b4d4cc5c-7169-42d9-92cf-e18ddd345712	9894E27FB0DDAF8FEED78866DE1AA2A4	01	2025-09-16 01:24:58.786117-04
ACCESS_20250916142459_00000152	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	12cfb0b0-fe93-4a14-835a-ec16f396a138	9D67F05E303A1DBCCF634DC1A455083E	01	2025-09-16 01:24:59.855628-04
ACCESS_20250916142500_00000153	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	97d7d183-afde-4c89-91b4-c25d0ecbf95f	94C736334CC2AE060E448E4EE941D736	01	2025-09-16 01:25:00.543209-04
ACCESS_20250916142501_00000154	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	2d1acf66-f0bb-4b9c-a0ed-c09eb9ad1c60	3778267D95CC8D321144A20097B862BF	01	2025-09-16 01:25:01.13794-04
ACCESS_20250916142501_00000155	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	e4df53cd-8f82-4364-b93e-096d82d5c582	1B0DD4A0236F6D544CC30653340F20A4	01	2025-09-16 01:25:01.72719-04
ACCESS_20250916142506_00000156	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	3fea4183-c6b1-4549-bd12-4211f8b3beb9	76477C3353BE2DB1308F25E723C4BB83	01	2025-09-16 01:25:06.832472-04
ACCESS_20250916142511_00000157	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	db994579-9754-499b-8337-b3caf7d63cc6	FC0F2D360467D37C2A29EDBF861D34D0	01	2025-09-16 01:25:11.172067-04
ACCESS_20250916142513_00000158	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	70804e59-569c-48f0-a07e-96589fa9e01c	157A48A490DF5E1326973BB9DEB004C5	01	2025-09-16 01:25:13.639788-04
ACCESS_20250916142514_00000159	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	4f7d99a4-7c94-46aa-a90e-c3dfa247d2c1	DE4CAE4E88C420D7F7091D40F407F50A	01	2025-09-16 01:25:14.961655-04
ACCESS_20250916142517_00000160	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	ec38caed-670f-4956-9335-8f37c14c0e44	1CF315578F6A63D6106CD876C2AD2716	01	2025-09-16 01:25:17.564624-04
ACCESS_20250916142521_00000161	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	babd168f-b1c2-49d7-bae2-fdc5986d4e72	48FD8E86BCE2661FD098A28F0D32CFD6	01	2025-09-16 01:25:21.630788-04
ACCESS_20250916142534_00000162	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	89f61b90-7e8b-4d88-84fa-9f78e31d05ed	F53BA9E72578652814F80F24EEFAAE1B	01	2025-09-16 01:25:34.759929-04
ACCESS_20250916142542_00000163	system	POST	/api/v1/ref/common-code/item	공통코드 - 코드항목 추가	10.42.0.1	64bbfdd9-e0af-4d7d-9574-b82e59a8eb62	86BBA918DC14F62D4BB3B1C67E7BDE6D	01	2025-09-16 01:25:42.812803-04
ACCESS_20250916142542_00000164	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	f75a7e40-cf97-4c2b-aa71-9d0586de2eb8	B9670C101F8720C051875EB6A2D410C8	01	2025-09-16 01:25:42.844171-04
ACCESS_20250916142542_00000165	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	dd69d33c-4009-44d7-af3a-eebfd8807fd2	ED1FDED7C4F8B9CF95140DE17431211E	01	2025-09-16 01:25:42.84633-04
ACCESS_20250916142548_00000166	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8a43ab7e-89c2-40ad-8949-28472c6db1f1	AC1AC9920FBE1993DA90A2E0FBFB0AFB	01	2025-09-16 01:25:48.394454-04
ACCESS_20250916142550_00000167	system	GET	/api/v1/ref/user/detail/yskim	사용자 관리 - 상세정보 조회	10.42.0.1	d845d754-ec9a-4c91-9f62-57903ccceb61	AA0E09BEAECE008E9C550B9144AA17DE	01	2025-09-16 01:25:50.936555-04
ACCESS_20250916142553_00000168	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	edc13e10-4980-45b2-9cb9-e05a6843daad	D1D88DC292C7AAF4CB3A4EDEB9B9B9F2	01	2025-09-16 01:25:53.780001-04
ACCESS_20250916142605_00000169	system	GET	/api/v1/ref/user/detail/yskim	사용자 관리 - 상세정보 조회	10.42.0.1	1c9910cd-2359-43d2-a2c1-637ca02e7c35	65CE770B773EA07F38083E86C7E57EE1	01	2025-09-16 01:26:05.178686-04
ACCESS_20250916142607_00000170	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	7f55db5b-27e7-455d-ba5c-3aa8b6be9f9a	D98EF8D88A76CD82A8BFAEBD5A4D0F38	01	2025-09-16 01:26:07.823553-04
ACCESS_20250916142610_00000171	system	PUT	/api/v1/ref/user/inits	사용자 관리 - 비밀번호 초기화	10.42.0.1	73f4f883-c4a9-4df2-ad0b-3db2f2e9f184	ED87F2E4488073B9B17BB828E1288E15	01	2025-09-16 01:26:10.776824-04
ACCESS_20250916142612_00000172	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	3c005f01-6f92-4013-9b1e-192173675027	A34CC3FCDA6C169E653A173AB094FDA9	01	2025-09-16 01:26:12.339847-04
ACCESS_20250916142615_00000173	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	f5e696d1-cde2-4c36-a51d-ac205bb61213	6FDB19ADE13088140EBE16EBD53EFC14	01	2025-09-16 01:26:15.439801-04
ACCESS_20250916142625_00000174	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	42cf8079-c843-41ab-a629-05c91e3a66c9	9E1CCD5073F8EB4A0D2AC3D1241284D6	01	2025-09-16 01:26:25.73377-04
ACCESS_20250916142625_00000175	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	a4aac256-7f65-4bbf-9688-165b990df698	6C33AB0FE02AD6A8BBF123A3A52FCA1B	01	2025-09-16 01:26:25.898829-04
ACCESS_20250916142625_00000176	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	960d7d4f-a887-4c2e-aeb3-80e65aa24642	6C33AB0FE02AD6A8BBF123A3A52FCA1B	01	2025-09-16 01:26:25.956812-04
ACCESS_20250916142637_00000177	system	GET	/api/v1/ref/user/id/jhbang	사용자 관리 - 아이디 검증	10.42.0.1	6dfdd803-15ba-4d40-bf7a-30be4efd758b	89EEFA71B06E6168F4ACA61B3A913B9D	01	2025-09-16 01:26:37.230237-04
ACCESS_20250916142644_00000178	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	87414d8e-d048-4c93-ae07-e490ae231fef	86E266406AEA31F83CDE9771F997362D	01	2025-09-16 01:26:44.34556-04
ACCESS_20250916142645_00000179	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	e82f991b-b283-418a-bf01-118fd296a1c5	C7B8B81A69ED1A8FAC5BC846D16A3661	01	2025-09-16 01:26:45.915361-04
ACCESS_20250916142651_00000180	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	341ceda7-15b2-4d54-8297-439baa96784a	B61F582FD830D4311548C65DFA6744BE	01	2025-09-16 01:26:51.894138-04
ACCESS_20250916142651_00000181	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	e3e6cfd4-1fa2-47ab-9b5d-7418dc15501a	4548080CFDF9FE4D1F29D01394F81BF1	01	2025-09-16 01:26:51.986789-04
ACCESS_20250916142651_00000182	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8dd142b4-6cee-43d5-aa9d-4dfc0c17acff	4548080CFDF9FE4D1F29D01394F81BF1	01	2025-09-16 01:26:51.98893-04
ACCESS_20250916142655_00000183	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	c9fac6ff-1a5f-4c32-9b3b-71bbfe7e3d4c	14543DC72FB0A61B6E0C789EBE73C6AA	01	2025-09-16 01:26:55.733431-04
ACCESS_20250916142701_00000184	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0a4f20d0-a577-4ff3-8a54-f2091cdc3869	B7F897A386EAA8D0D90674B7A1F79771	01	2025-09-16 01:27:01.353736-04
ACCESS_20250916142701_00000185	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	744bae3a-eca0-4317-8651-74089793effc	FE8ED22FED0E740DC6C853A54BDA6851	01	2025-09-16 01:27:01.458838-04
ACCESS_20250916142702_00000186	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	a5e66788-8106-4740-ac67-15eba3d2b01e	30CED241BCBA68C785517F04590B32CD	01	2025-09-16 01:27:02.195663-04
ACCESS_20250916142702_00000187	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	4a1b6554-0f81-486a-baff-d76f14820757	0A3EC7D847336A1045E8CD6A9DF23C13	01	2025-09-16 01:27:02.967644-04
ACCESS_20250916142704_00000188	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	2944ec01-a7e7-4eb5-aec1-fc5afc81e65f	62C822FAE127E7C8095D00E8EBA4BD66	01	2025-09-16 01:27:04.59563-04
ACCESS_20250916142705_00000189	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	c97285c2-33e0-43ac-a485-19650404856d	EB68F61DFF917E9F979A92B402CC2E93	01	2025-09-16 01:27:05.314785-04
ACCESS_20250916142712_00000190	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	7e43d160-5e94-4ed4-90dc-23ef1ec5f9d6	C59921DC64069A11462BC75016ECE2E2	01	2025-09-16 01:27:12.361119-04
ACCESS_20250916142724_00000191	system	GET	/api/v1/ref/user/id/smwoo	사용자 관리 - 아이디 검증	10.42.0.1	4b737f96-991a-4894-926c-e185f160693f	6CF7950A9CA8DECA1B33F9F72F12B4DD	01	2025-09-16 01:27:24.176009-04
ACCESS_20250916142738_00000192	system	GET	/api/v1/ref/user/email/smwoo@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	9cd04fbf-4bca-4363-ab85-033325a8bd11	585973646930E71CBCFC1EF30A5373D5	01	2025-09-16 01:27:38.186327-04
ACCESS_20250916142744_00000193	system	GET	/api/v1/ref/user/mobile/01024677370	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	c4714c95-c18d-484f-b364-ed907caa42b1	B2B3E19941EAB3F9C630551D3B33A8CD	01	2025-09-16 01:27:44.02166-04
ACCESS_20250916142755_00000194	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	993e88ee-9496-4731-98b8-77bc9590748b	5A12306773C672232AA1F1A4AEE6F6C5	01	2025-09-16 01:27:55.727374-04
ACCESS_20250916142755_00000195	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	4bc4ca11-4635-4a5d-a342-fcd25260cb30	248E3CAD82A27A043043DB7511949DCF	01	2025-09-16 01:27:55.877824-04
ACCESS_20250916142757_00000196	system	GET	/api/v1/ref/user/detail/smwoo	사용자 관리 - 상세정보 조회	10.42.0.1	afb5d03e-41c2-4cc5-8afc-d3eb5eb02c2e	52E76FB055D1C6905BE867A82A2EBDA9	01	2025-09-16 01:27:57.646609-04
ACCESS_20250916142804_00000197	system	GET	/api/v1/ref/user/detail/smwoo	사용자 관리 - 상세정보 조회	10.42.0.1	a5d358c7-8ad2-4d2c-843f-768524b71383	BEA4A83819A998460197CE098512143A	01	2025-09-16 01:28:04.431669-04
ACCESS_20250916142815_00000198	system	GET	/api/v1/ref/user/detail/smwoo	사용자 관리 - 상세정보 조회	10.42.0.1	e32ad3a2-4e9a-4fda-b94b-4e0cffa94049	B7CC522E831C980229083F69B1330656	01	2025-09-16 01:28:15.71882-04
ACCESS_20250916142838_00000199	system	GET	/api/v1/ref/user/email/gtkim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	9d4d3ffe-6bba-449e-ade9-6f5a97bfe1f8	D29B19CFB3CDE03567C9BDE3654F48EC	01	2025-09-16 01:28:38.125997-04
ACCESS_20250916142842_00000200	system	GET	/api/v1/ref/user/mobile/01043034243	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	ae160c3f-4daf-4cbb-b809-1d5c68562aa9	2969F32214630007EFF36A9CFA5ED42B	01	2025-09-16 01:28:42.693554-04
ACCESS_20250916142844_00000201	system	GET	/api/v1/ref/user/id/gtkim	사용자 관리 - 아이디 검증	10.42.0.1	8508a8b7-1552-471b-8c14-a645ff9fcf1c	BBCD84AB9881704F8E1B08DF7FBE3E73	01	2025-09-16 01:28:44.301666-04
ACCESS_20250916143035_00000202	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	c1a8987b-e3a2-43e3-8ced-fbb2118bab7f	CC6C52C7861E8CE2C36BAAD6691C2AF1	01	2025-09-16 01:30:35.159841-04
ACCESS_20250916143035_00000203	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	f30930af-1775-432d-8271-6df1f4681f38	39B6CA70C0A931DF8C54B9D17D1DFDE8	01	2025-09-16 01:30:35.298345-04
ACCESS_20250916143039_00000204	system	GET	/api/v1/ref/user/detail/smwoo	사용자 관리 - 상세정보 조회	10.42.0.1	3bf16f49-8efa-4307-a9cb-eaae5f97ec99	733B2A06D0B4A38D4D76BCFA9CA66D6D	01	2025-09-16 01:30:39.74407-04
ACCESS_20250916143053_00000205	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	e606c5be-28f5-47b0-ae16-45e9d4c03b89	A503C0BD95CAEA9FC31AEEA0FE9484D5	01	2025-09-16 01:30:53.144242-04
ACCESS_20250916143056_00000206	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	da34ebb8-0cf1-43c8-aa7f-a617027a2de9	5121013EC4D1E949877F37AD720FF081	01	2025-09-16 01:30:56.579671-04
ACCESS_20250916143104_00000207	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ad00af55-b792-42e9-a533-a88b44a80ca1	831A3665E39AA74ADC9445DD50865994	01	2025-09-16 01:31:04.35568-04
ACCESS_20250916143118_00000208	system	GET	/api/v1/ref/user/id/wksong	사용자 관리 - 아이디 검증	10.42.0.1	8c2588f8-cdb6-4224-b1d7-c2fadddd4767	E0804FA075D641217F02F5011FF4334F	01	2025-09-16 01:31:18.935779-04
ACCESS_20250916143129_00000209	system	GET	/api/v1/ref/user/email/wksong@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	48556c55-0457-4710-88ac-9913df38a87f	5FADFF64CA3A24C003B286828873FC2F	01	2025-09-16 01:31:29.304367-04
ACCESS_20250916143132_00000210	system	GET	/api/v1/ref/user/mobile/01023896690	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	611ee1ed-060c-45d5-99f4-d7c01fb91a41	420E9B60E9C2AA0A69C0963F417C0AA3	01	2025-09-16 01:31:32.661579-04
ACCESS_20250916143219_00000211	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	228394de-71d2-4c63-85ba-71a1a6852402	CA6BFCF2DC6CB72B780D64EE0E846058	01	2025-09-16 01:32:19.968617-04
ACCESS_20250916143220_00000212	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	2b6c2582-3229-439b-b3b5-93e97912f528	86EC0759821643F4BEB4CFED3AA23F4F	01	2025-09-16 01:32:20.043319-04
ACCESS_20250916143254_00000213	system	GET	/api/v1/ref/user/id/jychoi	사용자 관리 - 아이디 검증	10.42.0.1	32345d82-7b8f-4b4f-8bd2-8eaa5a761d95	5C007BE824DFD36CD8F58F1A1BED64C5	01	2025-09-16 01:32:54.211658-04
ACCESS_20250916143255_00000214	system	GET	/api/v1/ref/user/email/jychoi@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	45135731-8ae1-4968-a9c7-e09f589c2075	56350184E57440C898E0DD5C35B44301	01	2025-09-16 01:32:55.295651-04
ACCESS_20250916143256_00000215	system	GET	/api/v1/ref/user/mobile/01023053345	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	03baeac8-8935-425b-867b-5f4b6ff5ab44	4613D82B33F172DEC8BEC1FFA806171A	01	2025-09-16 01:32:56.535482-04
ACCESS_20250916143300_00000216	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	e5e11ec8-0114-489e-ba9e-8ce95cbbb2e8	7FE52D0F4DBB8AF65881F5F1DA629003	01	2025-09-16 01:33:00.417976-04
ACCESS_20250916143300_00000217	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	3d374dc4-8bd9-493b-aecc-2042abdbf47e	0CEA592D39812BB5934F16AA119714A8	01	2025-09-16 01:33:00.527015-04
ACCESS_20250916143303_00000218	system	GET	/api/v1/ref/user/detail/wksong	사용자 관리 - 상세정보 조회	10.42.0.1	a92ab077-db5d-4057-a297-7dac6986dd54	6BFF92E2B50A0B9C214AD40147AA2182	01	2025-09-16 01:33:03.01422-04
ACCESS_20250916143308_00000219	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	548e1c15-5329-4ccf-aa80-fceb7fcff3f9	F07290BEC423251B200D04BFECE83B9C	01	2025-09-16 01:33:08.84829-04
ACCESS_20250916143308_00000220	system	GET	/api/v1/ref/user/detail/wksong	사용자 관리 - 상세정보 조회	10.42.0.1	a546e5d0-eac4-4b54-87a3-fd0466463336	167C015412BB3BF5304FB36ADD088901	01	2025-09-16 01:33:08.94778-04
ACCESS_20250916143308_00000221	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	39da8316-d529-467d-8871-3a914cf35848	34DF80D9F3F3226FA683CE5CE4890E21	01	2025-09-16 01:33:08.967503-04
ACCESS_20250916143313_00000222	system	GET	/api/v1/ref/user/detail/gtkim	사용자 관리 - 상세정보 조회	10.42.0.1	9d9bbdd8-3300-40a7-a683-8f415c0995e3	CE9B3D99E203CFE76895DF9F095671D8	01	2025-09-16 01:33:13.611247-04
ACCESS_20250916143325_00000223	system	GET	/api/v1/ref/user/id/sckang	사용자 관리 - 아이디 검증	10.42.0.1	bbf8129d-27a3-455f-aaa4-2e9c5eab98eb	31F4EBD37668E5C337F95FB77474A023	01	2025-09-16 01:33:25.028682-04
ACCESS_20250916143333_00000224	system	GET	/api/v1/ref/user/email/sckang@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	879fdd9c-e23a-47f2-bf28-2c1d3a617451	7E1FDBAAAFDBB04D7EFAB07F3E81EC21	01	2025-09-16 01:33:33.537046-04
ACCESS_20250916143334_00000225	system	GET	/api/v1/ref/user/mobile/01050269666	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	e3a52246-a36b-4f59-9045-85bd38f8e17e	062ABF480A612426183247E703F93CB0	01	2025-09-16 01:33:34.728389-04
ACCESS_20250916143536_00000226	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	22347549-66f7-46ff-8cb9-50378bf6557e	6BA914A3FBE886CFDFC54B9B0024B2B3	01	2025-09-16 01:35:36.490826-04
ACCESS_20250916143536_00000227	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ddec7a9a-6b33-49fd-9fae-bef7996a793f	D38F4F138F3E5F07FDBB66E148047BCE	01	2025-09-16 01:35:36.651825-04
ACCESS_20250916143603_00000228	system	GET	/api/v1/ref/user/id/jskim	사용자 관리 - 아이디 검증	10.42.0.1	f02309fe-d58c-49cd-8bca-150a6d391415	1122434903A81B34A7AA456D68BDE7D4	01	2025-09-16 01:36:03.646585-04
ACCESS_20250916143605_00000229	system	GET	/api/v1/ref/user/email/jskim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	1e6714d1-7519-4dbc-8622-79c77b68a680	72F720938CDC82C90EFBB2A44080EEE9	01	2025-09-16 01:36:05.274615-04
ACCESS_20250916143606_00000230	system	GET	/api/v1/ref/user/mobile/01032494840	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	38bc6e13-20ae-4c75-b235-ce29b87876bf	F3C6965256FF801812BE03347B2D5A67	01	2025-09-16 01:36:06.539729-04
ACCESS_20250916143622_00000231	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	6e852f12-3f0f-4d15-9fb9-8c46421b4352	792F9BB185C9741BDF237E7568B1A487	01	2025-09-16 01:36:22.379989-04
ACCESS_20250916143622_00000232	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	d9a42466-1eb0-4df1-a229-f0a5b27db9a8	D63A6FA65378D5E04735442DF6A8C02C	01	2025-09-16 01:36:22.467605-04
ACCESS_20250916143638_00000233	system	GET	/api/v1/ref/user/mobile/01037069235	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	e732a791-9c01-431d-9d7e-64011787d74d	71796CDD35399141FF0B15F4A10FD1C6	01	2025-09-16 01:36:38.370487-04
ACCESS_20250916143639_00000234	system	GET	/api/v1/ref/user/email/khlee@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	92013c73-7da6-4fcd-a3af-b41e80122c34	6EAC97618156D07CF38CA7EEC52A09F6	01	2025-09-16 01:36:39.636851-04
ACCESS_20250916143640_00000235	system	GET	/api/v1/ref/user/id/khlee	사용자 관리 - 아이디 검증	10.42.0.1	c336b2d2-4c2a-447e-a986-7793fb2d3872	4818898F4D588E271EEC3957C28C5B11	01	2025-09-16 01:36:40.738662-04
ACCESS_20250916143713_00000236	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	5fac615d-87be-4e3e-ad94-45817d2f6c65	43A00FE4F3A4A2E126B0F746E47D0A21	01	2025-09-16 01:37:13.526978-04
ACCESS_20250916143713_00000237	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	4f383f27-d936-402f-b249-273426d4c52d	45812597BB9127DF18FD5DA5DC466F31	01	2025-09-16 01:37:13.647456-04
ACCESS_20250916143731_00000238	system	GET	/api/v1/ref/user/email/jwlee@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	305ef54d-fa58-4d3b-80fb-307dd992d14b	360B44864BBAC9398016083C0A88BD74	01	2025-09-16 01:37:31.035819-04
ACCESS_20250916143732_00000239	system	GET	/api/v1/ref/user/id/jwlee	사용자 관리 - 아이디 검증	10.42.0.1	96a095e7-a0a4-4855-91fe-3e2b7ff27fd5	B28978D20218AF31182FBFB3B26CA016	01	2025-09-16 01:37:32.462005-04
ACCESS_20250916143734_00000240	system	GET	/api/v1/ref/user/mobile/01064355050	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	4f911384-16eb-4f03-92ed-673bbaf09a0e	1A264FC59C18EF1066ACCBB7A8B5B725	01	2025-09-16 01:37:34.819192-04
ACCESS_20250916143748_00000241	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	2b6c005c-6f9a-4cf3-8daf-e78f298c2ffe	05964EF8A952823C27778301F3BEE73E	01	2025-09-16 01:37:48.915683-04
ACCESS_20250916143749_00000242	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	3d3068be-ba0e-41de-9f9c-2ac46d9a7bbb	8B9B1C05D2642847188CFE12692F9AF8	01	2025-09-16 01:37:49.016608-04
ACCESS_20250916143810_00000243	system	GET	/api/v1/ref/user/id/jplee	사용자 관리 - 아이디 검증	10.42.0.1	8c35c8c6-0b8d-4477-bbc5-dcd0778cc276	1B0B10969268B652F1529114FB13A5DF	01	2025-09-16 01:38:10.982823-04
ACCESS_20250916143812_00000244	system	GET	/api/v1/ref/user/email/jplee@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	434e3869-1a11-4c76-9bdc-0dad1cfc185a	5BFFCCD7F2857B4E9A68587E535A2221	01	2025-09-16 01:38:12.950892-04
ACCESS_20250916143814_00000245	system	GET	/api/v1/ref/user/mobile/01076005864	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	8f5ca25d-912b-4662-b24b-db76a8358e59	6329B4704AD6912E6830475A2DC9A025	01	2025-09-16 01:38:14.123265-04
ACCESS_20250916143846_00000246	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	186ac708-0275-42c4-a55c-e93b9d39f6b9	F51A1627EE5C1E5C6B606F0F3BAF3658	01	2025-09-16 01:38:46.17838-04
ACCESS_20250916143846_00000247	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	bfeafd27-f5ab-48d2-9035-1a1e4462703e	5283943F002FFA8A429E4C65831870F5	01	2025-09-16 01:38:46.284181-04
ACCESS_20250916143859_00000248	system	GET	/api/v1/ref/user/email/cmkim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	9fbed333-b823-490c-99cf-26bc8285bc69	7B760DA81E38FDC65AD9B2593C4A2F1B	01	2025-09-16 01:38:59.748271-04
ACCESS_20250916143901_00000249	system	GET	/api/v1/ref/user/id/cmkim	사용자 관리 - 아이디 검증	10.42.0.1	f1a7d9fa-1577-41e9-9ae7-92ad79b8e490	E24A068CD52687F29839FCB1F413E339	01	2025-09-16 01:39:01.166206-04
ACCESS_20250916143902_00000250	system	GET	/api/v1/ref/user/mobile/01062319341	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	0acd21bc-516c-4fde-a62a-67525fa68dcf	F01B9A30DC83007C9B51CA571EC69A7D	01	2025-09-16 01:39:02.725338-04
ACCESS_20250916143955_00000251	system	GET	/api/v1/ref/user/detail/jplee	사용자 관리 - 상세정보 조회	10.42.0.1	d5aa329f-4507-4e0b-b3d5-3584d3198560	A6D4E237F2F0F7A8518923CDB753A1E4	01	2025-09-16 01:39:55.085282-04
ACCESS_20250916144021_00000252	system	GET	/api/v1/ref/user/email/cmkim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	7d18a0cc-7046-480b-9e1c-00b4bc75bdbb	9CB15E091C56681124008D1E6A874E1E	01	2025-09-16 01:40:21.028213-04
ACCESS_20250916144022_00000253	system	GET	/api/v1/ref/user/id/cmkim	사용자 관리 - 아이디 검증	10.42.0.1	def2cd80-d1b5-4197-833d-2822157c0cbb	1DADAD5E97E3B865653BD51E7E57E00A	01	2025-09-16 01:40:22.110819-04
ACCESS_20250916144023_00000254	system	GET	/api/v1/ref/user/mobile/01062319341	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	10f040a6-bb47-4cfe-a378-95fbea128e1b	55922B02D21330F554B55BD990023CDB	01	2025-09-16 01:40:23.786434-04
ACCESS_20250916144032_00000255	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	7fecb189-0509-4c85-8506-a45f5aaa361f	DE0DBF8B4DFB133E559EA37CAC75AA07	01	2025-09-16 01:40:32.186021-04
ACCESS_20250916144032_00000256	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	558b3a60-29ce-4f4a-9122-22be2f023c03	1BEA856E4F20C5D15419DFED3A6D6CD4	01	2025-09-16 01:40:32.316394-04
ACCESS_20250916144046_00000257	system	GET	/api/v1/ref/user/mobile/01071338386	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	a55ad3f1-ad50-4bcf-b3c0-f7baa70e67a8	54305A77B9DD7D0A6933674BACAE211A	01	2025-09-16 01:40:46.465652-04
ACCESS_20250916144048_00000258	system	GET	/api/v1/ref/user/email/chyou@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	39c7aaea-abfd-4d9a-9d59-be67e5f49eee	6E224DCE137D8BC40BBC56562B1A3854	01	2025-09-16 01:40:48.386469-04
ACCESS_20250916144049_00000259	system	GET	/api/v1/ref/user/id/chyou	사용자 관리 - 아이디 검증	10.42.0.1	8cf0af47-6d58-43bf-8866-b1b036fa066d	2068965B97A6D9694A03009384D8DF21	01	2025-09-16 01:40:49.449826-04
ACCESS_20250916144058_00000260	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	d69b37df-ca6c-4a27-af33-21a1ed998c1f	1504D56E6B7B31AAFE5BF23E64BCCFA7	01	2025-09-16 01:40:58.782938-04
ACCESS_20250916144058_00000261	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	58fc46a6-a7b3-4cd5-8ba9-a312aa75b4d6	3CFBA5EBF619C5BCA067AB61BFB8AE84	01	2025-09-16 01:40:58.920318-04
ACCESS_20250916144105_00000262	system	GET	/api/v1/ref/user/id/shjung	사용자 관리 - 아이디 검증	10.42.0.1	71f4e290-5f04-4ce6-b6c8-893fbc5bae73	6A4256D87B101473CDFFB5C8B8610756	01	2025-09-16 01:41:05.131199-04
ACCESS_20250916144114_00000263	system	GET	/api/v1/ref/user/mobile/01036588212	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	7a42b0a5-8436-4d6b-acc4-81ec11a54b47	2DBA421C41171E836CD5264BA6344F31	01	2025-09-16 01:41:14.454788-04
ACCESS_20250916144115_00000264	system	GET	/api/v1/ref/user/email/shjung@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	321ee617-b36a-4e92-b578-149e050d3a43	7A46EAA6956482944CCC822AD8427823	01	2025-09-16 01:41:15.569798-04
ACCESS_20250916144126_00000265	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	58daa1b4-4b60-40d0-af24-b00d049bb9e2	4BA6084D1EB0E2BA0CF520D685C93996	01	2025-09-16 01:41:26.714221-04
ACCESS_20250916144126_00000266	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	266af847-35e0-4e06-a55a-0b1ede25c9a6	7D92EDF7147683BE215F072F7AA8CEE1	01	2025-09-16 01:41:26.82111-04
ACCESS_20250916144144_00000267	system	GET	/api/v1/ref/user/mobile/01077774684	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	0df21dc5-3397-4204-8bbb-26bfb6351cea	9690927E9F35E9DDB32AFF39165BC037	01	2025-09-16 01:41:44.898857-04
ACCESS_20250916144146_00000268	system	GET	/api/v1/ref/user/email/zschoi@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	5115bbe8-a03f-49b9-a60c-6fe61b716c03	70B3811586368AE2B96FD77B195D2B1D	01	2025-09-16 01:41:46.238022-04
ACCESS_20250916144147_00000269	system	GET	/api/v1/ref/user/id/zschoi	사용자 관리 - 아이디 검증	10.42.0.1	5847d476-6124-4b18-a321-cce64f0eb184	0A9FE772F6107C725E7B582E0C97D490	01	2025-09-16 01:41:47.885656-04
ACCESS_20250916144159_00000270	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	76161e20-fa2f-4798-9af4-31ed41dd7697	C7D410B538DBA821402F8390CFCD034F	01	2025-09-16 01:41:59.696563-04
ACCESS_20250916144159_00000271	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	2f7fa7b1-b658-414d-9e7a-64e3d860a67b	1B7F64160CCF1878DD2E408587B800FC	01	2025-09-16 01:41:59.811031-04
ACCESS_20250916144209_00000272	system	GET	/api/v1/ref/user/id/gtgu	사용자 관리 - 아이디 검증	10.42.0.1	a32950b0-9106-4eaf-afdb-8f74a4f673d8	3F4DB1EA3432E4FA33B737AFE449DB96	01	2025-09-16 01:42:09.79163-04
ACCESS_20250916144218_00000273	system	GET	/api/v1/ref/user/mobile/01028410230	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	9a9689b9-c59e-4fe5-bb3a-ed259d3dc86f	362D6A215A207E655860A2A7A899FC08	01	2025-09-16 01:42:18.566219-04
ACCESS_20250916144220_00000274	system	GET	/api/v1/ref/user/email/gtgu@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	b73c0e9d-6539-48fe-94a4-90a3269e068e	5CE9044E1BF25E1335722F153D4C73CB	01	2025-09-16 01:42:20.601537-04
ACCESS_20250916144234_00000275	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	bd0246de-1556-4227-ad3e-3ace44b586e3	476D054AC54E14A5A846E2642BAEC74D	01	2025-09-16 01:42:34.269753-04
ACCESS_20250916144234_00000276	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	178fd60c-ba05-4cf1-a4b8-e12e6fc19376	36BDDEE97058C5A3708B33DCB7D9D55F	01	2025-09-16 01:42:34.392337-04
ACCESS_20250916144250_00000277	system	GET	/api/v1/ref/user/mobile/01044658426	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	7057f71c-5a81-432d-8e0f-48416f62a51a	6105FCC551E41E9A7549FFE68C67066B	01	2025-09-16 01:42:50.693622-04
ACCESS_20250916144251_00000278	system	GET	/api/v1/ref/user/email/gwseo@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	347ecf79-4315-4d83-9e6b-d9eb74816dd3	A90BE8976C584151D81B1F9529581788	01	2025-09-16 01:42:51.937877-04
ACCESS_20250916144253_00000279	system	GET	/api/v1/ref/user/id/gwseo	사용자 관리 - 아이디 검증	10.42.0.1	31d8eafe-96f0-4562-b340-90bf3a9375d0	DE429A9F3BB9B16C0865AB3E6B4586A5	01	2025-09-16 01:42:53.122959-04
ACCESS_20250916144304_00000280	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	e5cce346-2802-43fe-b4de-e210544ac876	A034582A837474BCFB555B2FD717DAF8	01	2025-09-16 01:43:04.114132-04
ACCESS_20250916144304_00000281	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b13e01ce-1207-48b3-a9a2-354530ece346	760B1F4B450FDA78E9536F2DA39B93BF	01	2025-09-16 01:43:04.21795-04
ACCESS_20250916144331_00000282	system	GET	/api/v1/ref/user/email/jjoh@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	14e6634b-3305-41dc-80b0-efff40770856	C0B21C6BE778F112AA250BC0BEB72FAC	01	2025-09-16 01:43:31.496637-04
ACCESS_20250916144332_00000283	system	GET	/api/v1/ref/user/id/jjoh	사용자 관리 - 아이디 검증	10.42.0.1	f97e69d6-1931-4ea0-8226-3e8fef727388	148CFBCA6B74A12B12F8ACAA0A662C7D	01	2025-09-16 01:43:32.594303-04
ACCESS_20250916144334_00000284	system	GET	/api/v1/ref/user/mobile/01062861729	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	53e38e0e-d306-4a64-925f-56043ad8e601	B9FBC4E884C1F1B78606D3F96ABDA812	01	2025-09-16 01:43:34.775178-04
ACCESS_20250916144345_00000285	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	c12f7bb5-e156-46df-b943-22ea8a8beab3	E951A5987FEED01B6F6859D45ED406A3	01	2025-09-16 01:43:45.750142-04
ACCESS_20250916144345_00000286	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	52369b25-3b38-4ece-b560-9b25abb5dab0	4B74E79F27CD31052584A66078ED2F4D	01	2025-09-16 01:43:45.857512-04
ACCESS_20250916144400_00000287	system	GET	/api/v1/ref/user/id/jmlim	사용자 관리 - 아이디 검증	10.42.0.1	1db8dfc6-eba9-42ef-983b-506b9993a3fd	585E7051BF0B2233229D775A492C648E	01	2025-09-16 01:44:00.011904-04
ACCESS_20250916144401_00000288	system	GET	/api/v1/ref/user/email/jmlim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	822cdd7c-10ac-40f5-8a69-2db523eb39da	B9CB51F0A2C3B0CA605D6F6CB9299045	01	2025-09-16 01:44:01.797696-04
ACCESS_20250916144403_00000289	system	GET	/api/v1/ref/user/mobile/01045224533	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	aadd5c15-5ec2-488b-adcf-8d0995b600d4	763FB398366CE84AECDDC1FF5409AB64	01	2025-09-16 01:44:03.128364-04
ACCESS_20250916144429_00000290	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	9679859e-3e2d-4f33-a2a1-662ece0a8a90	4F5FE07FBAC0EB962A67CE77C9CFCEA8	01	2025-09-16 01:44:29.614026-04
ACCESS_20250918165628_00001240	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	d900a614-f8e7-4ff9-b8ce-e735003f6a59	E7D107BB9E474C55FDE0F00E99D6039B	01	2025-09-18 03:56:28.849814-04
ACCESS_20250916144436_00000292	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	93246c80-a8e5-4be1-86bb-b45d8c2de986	38389E9AEEDEAB06E293F1E1AF674803	01	2025-09-16 01:44:36.073838-04
ACCESS_20250916144439_00000293	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	0d864f55-38bf-41cb-8880-cedce02362ca	50B9E31B6C136072E043B5CB0C0244EB	01	2025-09-16 01:44:39.261395-04
ACCESS_20250916144441_00000294	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	15e0b8bb-5832-4771-87c0-8571e875baf6	7834AB186A1CD3EE748E8E5CBF8AEC8A	01	2025-09-16 01:44:41.384835-04
ACCESS_20250916144452_00000295	system	GET	/api/v1/ref/user/id/jmlim	사용자 관리 - 아이디 검증	10.42.0.1	e944f4ab-abc8-430e-845e-52df2222dd93	6ED732B02F57CDC93B359E816FCEBB29	01	2025-09-16 01:44:52.066182-04
ACCESS_20250916144454_00000296	system	GET	/api/v1/ref/user/id/jmlim	사용자 관리 - 아이디 검증	10.42.0.1	2844040e-8d02-4433-98af-02980d53199f	5ECA668EB49A15DC200270BE5950894B	01	2025-09-16 01:44:54.377333-04
ACCESS_20250916144509_00000297	system	GET	/api/v1/ref/user/id/jmlim	사용자 관리 - 아이디 검증	10.42.0.1	99051a90-9233-45ec-9906-1eff428c1e23	1E8CF0728C45DC4FD0C4FCCB88F207EF	01	2025-09-16 01:45:09.7843-04
ACCESS_20250916144630_00000298	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	cbf9c445-1f71-41d6-94b5-21b23612dc85	5F9B493DC6E4D3329BCD941687D902A2	01	2025-09-16 01:46:30.237755-04
ACCESS_20250916144632_00000299	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	08f9aa2a-4623-4688-9303-e3e8f526fbe3	A69C3F7A0DEB0FD75681463F2D26E291	01	2025-09-16 01:46:32.714317-04
ACCESS_20250916144637_00000300	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8c69e296-2e75-4c9e-b6c9-4cc9709666ba	1794441494F8F2EB22EDA23220DB2BE3	01	2025-09-16 01:46:37.099671-04
ACCESS_20250916144639_00000301	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	3d18b6a2-2278-46ab-9a40-5e64883ee60c	5BE07A3B6C69E5015E78FEC08438E2CB	01	2025-09-16 01:46:39.5267-04
ACCESS_20250916144650_00000302	system	GET	/api/v1/ref/user/id/jmlim	사용자 관리 - 아이디 검증	10.42.0.1	a322e746-365b-465f-b1e1-6a0894c77bba	DFD6E07514C679D317DEC0D56E0ADE05	01	2025-09-16 01:46:50.129936-04
ACCESS_20250916144858_00000303	system	GET	/api/v1/ref/user/detail/sckang	사용자 관리 - 상세정보 조회	10.42.0.1	374ee30c-97e1-4515-9e6d-76acdf4dd1c5	7FFEAC7E492D9296CBC00621FED571A9	01	2025-09-16 01:48:58.651434-04
ACCESS_20250916144931_00000304	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	3f1e8b03-e0e9-44f3-bccd-8ee3e050cb66	46570D3CF02F735CCFFF5A9FEB7E0868	01	2025-09-16 01:49:31.784338-04
ACCESS_20250916144931_00000305	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	5f46b0e9-97d9-4e42-a0af-aac27dd16221	852F900E294FFB7B99E76BBEA5A49FC4	01	2025-09-16 01:49:31.787635-04
ACCESS_20250916144932_00000306	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	7fd7cc75-23bb-405e-9cbd-74c3645f2c22	24CD83E603B28AF892978C36DF6F8868	01	2025-09-16 01:49:32.953258-04
ACCESS_20250916144936_00000307	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	f3802a43-7cbe-438d-af2b-bd0d5379f4ac	19913165EAE74C3EDB89FA9C420D572F	01	2025-09-16 01:49:36.817656-04
ACCESS_20250916144952_00000308	system	GET	/api/v1/ref/user/detail/jmlim	사용자 관리 - 상세정보 조회	10.42.0.1	a5c5762e-333c-4eed-947a-e59ce35cf2f7	395A536A1B0C5E8336FFB9B94B9215F9	01	2025-09-16 01:49:52.808789-04
ACCESS_20250916145003_00000309	system	GET	/api/v1/ref/user/detail/smwoo	사용자 관리 - 상세정보 조회	10.42.0.1	6e698d00-6bde-4cc2-9492-205025862d03	507EF2AE57D2D6E7C7B22AED0881C1B5	01	2025-09-16 01:50:03.445496-04
ACCESS_20250916145009_00000310	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	474ddd65-4425-4afd-80b3-14082f0e87d7	C144201C624C1A70E7379263F8DCFA12	01	2025-09-16 01:50:09.681951-04
ACCESS_20250916145029_00000311	system	GET	/api/v1/ref/user/email/srmkim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	7fe87a9f-ded7-49b5-bcfd-98d24c1a2acb	E537A3AE203C86B5C5F9E1D1E3C950F9	01	2025-09-16 01:50:29.94341-04
ACCESS_20250916145031_00000312	system	GET	/api/v1/ref/user/id/srmkim	사용자 관리 - 아이디 검증	10.42.0.1	044a535d-21ef-4426-a196-ad7fc981b746	810B4A73D858FDA63756D523ADFD9391	01	2025-09-16 01:50:31.05763-04
ACCESS_20250916145032_00000313	system	GET	/api/v1/ref/user/mobile/01090582278	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	40185ce9-9a04-4185-b5a6-f33871402713	BA549B5CB1C411C9A9CA1AF34267AC12	01	2025-09-16 01:50:32.610157-04
ACCESS_20250916145050_00000314	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	45ad6a8e-ab90-478c-8a96-83bf22f4d4fd	4B60AB868100992AAF2999B84C92819A	01	2025-09-16 01:50:50.374824-04
ACCESS_20250916145050_00000315	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	059b8fcf-6ed0-4c53-9362-148231fea16f	9EEE52B8F7DB17B53C6B2C69AC1A8589	01	2025-09-16 01:50:50.53134-04
ACCESS_20250916145053_00000316	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ee3ec6cf-464d-45aa-8ef4-eda00a3af16b	CF0D1232384C93A2969D2BCD01B11473	01	2025-09-16 01:50:53.473945-04
ACCESS_20250916145054_00000317	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	d9c45754-b245-4b09-8994-1b9a0ca8c357	DD0C933A386D0E1673EC89F6A4E75AA1	01	2025-09-16 01:50:54.535059-04
ACCESS_20250916145058_00000318	system	GET	/api/v1/ref/user/detail/khlee	사용자 관리 - 상세정보 조회	10.42.0.1	69d79b52-b93b-43c7-aa83-39bfac27409b	C9A0096A6B7D9E78488B7EF701689661	01	2025-09-16 01:50:58.48724-04
ACCESS_20250916145103_00000319	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	cc86ea0c-eac4-425d-b749-83f252b1e462	72F299817B281681A3C3C59BA15E407C	01	2025-09-16 01:51:03.85105-04
ACCESS_20250916145103_00000320	system	GET	/api/v1/ref/user/detail/khlee	사용자 관리 - 상세정보 조회	10.42.0.1	6a57414e-e11e-43bc-9137-4b5b38d8f2f8	261C625E38CA402621FEA753F1AEECDB	01	2025-09-16 01:51:03.97674-04
ACCESS_20250916145104_00000321	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	94fb0d32-4650-4e25-b367-4036a7f115d2	7E8E06594624EF28DCF9E642B8D15558	01	2025-09-16 01:51:04.007482-04
ACCESS_20250916145110_00000322	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	d93604c2-8528-44fe-91e7-5d59847347ec	85821C4934BB876C64B3B7EA68307183	01	2025-09-16 01:51:10.398735-04
ACCESS_20250916145111_00000323	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	2457dbc7-143d-407e-a6ed-ef2a1ac2be6f	A17928D235BED96BA695C85F4A8845E7	01	2025-09-16 01:51:11.405212-04
ACCESS_20250916145123_00000324	system	GET	/api/v1/ref/user/id/jhno	사용자 관리 - 아이디 검증	10.42.0.1	b8db328f-b0b8-44fc-a9ba-43b2262369a4	4B22AA091BA73BAF55EB6AB8E12EC31A	01	2025-09-16 01:51:23.098679-04
ACCESS_20250916145124_00000325	system	GET	/api/v1/ref/user/email/jhno@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	84835653-794e-4110-a63e-c5c6268c851b	F3BDE2BDA97EA026C18231888E576A68	01	2025-09-16 01:51:24.359752-04
ACCESS_20250916145125_00000326	system	GET	/api/v1/ref/user/mobile/01050314486	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	bd318bb4-bc06-4b5c-be4c-9e1f5c037351	D88A1A2E2C45A99475E984B62FA03A04	01	2025-09-16 01:51:25.50325-04
ACCESS_20250916145136_00000327	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	7e018006-f221-48db-b6fb-3b34edb1d10d	719C2A2C8C7C10C29BDFAC82530EB930	01	2025-09-16 01:51:36.860618-04
ACCESS_20250916145136_00000328	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8a04fdf1-73be-4f5b-a4ee-81f422ee74a8	099C7B8E977DAD46FC8735F5CFCDB313	01	2025-09-16 01:51:36.940307-04
ACCESS_20250916145149_00000329	system	GET	/api/v1/ref/user/id/yspark	사용자 관리 - 아이디 검증	10.42.0.1	b38bd744-dbff-4b19-b420-2091c5af6f74	332EC608661335FC2DAEB447BCAC4255	01	2025-09-16 01:51:49.01636-04
ACCESS_20250916145150_00000330	system	GET	/api/v1/ref/user/email/yspark@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	ad229c52-ee81-414a-acc5-115226a760c6	1730F0AB880895E77A1AF3EC8B0532AB	01	2025-09-16 01:51:50.480906-04
ACCESS_20250916145151_00000331	system	GET	/api/v1/ref/user/mobile/01080729204	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	57767b1e-b79a-44b7-9604-e103fcb631ba	F585E5D4D9C21924C2061145F7BB91B0	01	2025-09-16 01:51:51.897823-04
ACCESS_20250916145204_00000332	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	9176c25c-9224-4e22-8d92-f0259f40b2ee	B8B0965C08BAAC24DDDFA7A6A9A07210	01	2025-09-16 01:52:04.462496-04
ACCESS_20250916145204_00000333	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	dc9f12df-d40c-422b-8bd0-0bfe055ef45b	B41829D5CB309C95A95D2602C4DFC11E	01	2025-09-16 01:52:04.555803-04
ACCESS_20250916145211_00000334	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	64e74f7c-1257-493a-a59d-860a9788745d	C915BCF6995AEDA4876908AE310CB509	01	2025-09-16 01:52:11.375518-04
ACCESS_20250916145217_00000335	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	2358ab17-1200-4c78-a4d6-654a2e877017	23F277AE3DC952AB6FA98BC39BC905D8	01	2025-09-16 01:52:17.177223-04
ACCESS_20250916145217_00000336	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	14064935-7128-4f18-8d8b-7a481dd059c3	8C4E6643590048815050BEB61B1C02BB	01	2025-09-16 01:52:17.259908-04
ACCESS_20250916145217_00000337	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	240be9c3-3bc4-4dc1-bd66-5ecc904b058b	8B7A252EC75C502B338F54406AF619CC	01	2025-09-16 01:52:17.300672-04
ACCESS_20250916165034_00000339	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	a155d1f0-8119-453a-a28e-d7c94caf80ea	F6C5C9A1A4A3ABBD8D9F8368065962EE	01	2025-09-16 03:50:34.444074-04
ACCESS_20250916165034_00000338	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	87546639-2853-4afa-8e09-21d0e80a10ed	2F3ED361315D9F86E6842FA1F6DCB38B	01	2025-09-16 03:50:34.444295-04
ACCESS_20250916165056_00000340	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	344ab024-1747-49e0-a716-a27bd1bb229e	A179E60927703FBAE65A99A0AAA250E3	01	2025-09-16 03:50:56.066623-04
ACCESS_20250916165100_00000341	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	18e2a47e-eca6-4bbf-818c-e185f4202d5d	AEB2A8DA10957E563656A4DF71484C0A	01	2025-09-16 03:51:00.055125-04
ACCESS_20250916165101_00000342	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	227d7e0e-24bf-441e-b0b4-1025004b6c65	D85EE55DDEF2027A9F9146D3F0B42E9C	01	2025-09-16 03:51:01.413438-04
ACCESS_20250916165103_00000343	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	e8f90011-c6cc-408a-b89c-b989c712aa46	638026B4F8D808C223DD3A8EB3465FBC	01	2025-09-16 03:51:03.068017-04
ACCESS_20250916165105_00000344	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	5718d729-fb28-4aa2-829f-e68d397ae20e	6F4EAEFEFED7667CB9E2C6ED91EC555B	01	2025-09-16 03:51:05.894778-04
ACCESS_20250916165105_00000345	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	d528d1dc-110c-4358-8b3f-92cc8d4482fe	27A86DCC585B69928DBCC49F2DB6D916	01	2025-09-16 03:51:05.894781-04
ACCESS_20250916165107_00000346	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	2daa388a-0753-4d2c-9035-aedeed0f11b5	FB310D791B1C711812C8950AC38C46BB	01	2025-09-16 03:51:07.259436-04
ACCESS_20250916165109_00000347	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	0974cf3f-8868-4882-832d-7e56becf3569	92B512092356E13348C79B42C1A615A8	01	2025-09-16 03:51:09.384754-04
ACCESS_20250916165110_00000348	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	63cd8137-8a47-4e6e-83d4-737d2ced3f8c	E6556BE7A1707B3FACB71E9009D23E0F	01	2025-09-16 03:51:10.21202-04
ACCESS_20250916165112_00000349	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	63fba5ad-8f78-488b-af41-4ad1b843c9d6	10D1883A21BE9B22C26689AFA4F47393	01	2025-09-16 03:51:12.004359-04
ACCESS_20250916165118_00000350	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b0eaca35-bd07-452d-a401-8fd497881f32	CF899476D17B91E7DA7D0F8673C19E3B	01	2025-09-16 03:51:18.725338-04
ACCESS_20250916165133_00000351	system	GET	/api/v1/ref/user/email/jbson@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	0430948d-2e24-43bd-bdc7-c2a2f7f81fd4	4A77B945282BBD3D87DDE2681EF816EA	01	2025-09-16 03:51:33.925345-04
ACCESS_20250916165136_00000352	system	GET	/api/v1/ref/user/id/jbson	사용자 관리 - 아이디 검증	10.42.0.1	b45db5a0-6580-4d84-8374-122fec8e85b7	DA7911F926B41CE67C31D94B848483C9	01	2025-09-16 03:51:36.602333-04
ACCESS_20250916165138_00000353	system	GET	/api/v1/ref/user/mobile/01086830223	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	3d04318a-7113-4f61-9701-8b174c41ed5c	6DF2135AC6044F8B137EE682365340C2	01	2025-09-16 03:51:38.043816-04
ACCESS_20250916165151_00000354	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	53f33f8a-078e-4aab-9b4e-2f30b7f22ae2	C2051B4C497D1596D0AE80B17EB5D58F	01	2025-09-16 03:51:51.568418-04
ACCESS_20250916165151_00000355	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ec6065b1-9535-4650-90bf-a4ea8ca2259c	888FBC8920A11CB54D4A005793AC9939	01	2025-09-16 03:51:51.644978-04
ACCESS_20250916165206_00000356	system	GET	/api/v1/ref/user/email/yjwon@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	7862d995-e329-442f-b514-a8906f2242ed	1C0EC5C9892AB8F627E93E05E45A2419	01	2025-09-16 03:52:06.849779-04
ACCESS_20250916165212_00000357	system	GET	/api/v1/ref/user/mobile/01051161230	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	66062d89-693f-4101-aee7-cb8528f0eed0	826E184A75C333EE37B679A0E16124C3	01	2025-09-16 03:52:12.873877-04
ACCESS_20250916165214_00000358	system	GET	/api/v1/ref/user/id/yjwon	사용자 관리 - 아이디 검증	10.42.0.1	83dd4791-3cab-428e-b7c1-c389a5006d2e	379DB34E420D416DE46DA948F3A56342	01	2025-09-16 03:52:14.647814-04
ACCESS_20250916165226_00000359	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	47094dc6-2fd1-4e92-a452-1d286576288c	3DC668670B2166C01EC60A7ADE9B80E3	01	2025-09-16 03:52:26.614367-04
ACCESS_20250916165226_00000360	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	5b45a946-1b00-4f92-bc37-5e60e331bc01	7604C59DB8379ED07ADA097A0E0C77C8	01	2025-09-16 03:52:26.685988-04
ACCESS_20250916165242_00000361	system	GET	/api/v1/ref/user/id/hjlim	사용자 관리 - 아이디 검증	10.42.0.1	b0504ce2-7db0-497c-a788-8a72c819212b	61E907B28CD1C9993EB21F2D0C6D54AE	01	2025-09-16 03:52:42.748117-04
ACCESS_20250916165244_00000362	system	GET	/api/v1/ref/user/email/hjlim@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	39addcb8-6031-4695-afcb-438cd341426b	BE556D9510B2800BAEC1A7D06857F9B6	01	2025-09-16 03:52:44.577484-04
ACCESS_20250916165245_00000363	system	GET	/api/v1/ref/user/mobile/01031159137	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	2e0c53ae-92e2-4019-9e80-6fa5a31fee7b	8DAFAE7E7490E3D1DD208AEE64576053	01	2025-09-16 03:52:45.797996-04
ACCESS_20250916165256_00000364	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	0ba21546-d655-4417-a3ef-a789318ed48b	BEF508729EAF70CA6FE5E13DBA604964	01	2025-09-16 03:52:56.865717-04
ACCESS_20250916165256_00000365	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	bf48d402-5bde-4c41-9de4-b4402f01f8b8	71E3CD6C4DAFCE6A0EF4D8D65A74F894	01	2025-09-16 03:52:56.937193-04
ACCESS_20250916165316_00000366	system	GET	/api/v1/ref/user/id/jijeon	사용자 관리 - 아이디 검증	10.42.0.1	4645d9e6-f19a-40f0-b02d-855eeb78baf6	0D8E131C65F46D58F56509197185286B	01	2025-09-16 03:53:16.282236-04
ACCESS_20250916165317_00000367	system	GET	/api/v1/ref/user/email/jijeon@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	0b057493-e6da-447b-9440-ddbe73529245	9D3CBF888D5A8944829F679B755A82CF	01	2025-09-16 03:53:17.522396-04
ACCESS_20250916165319_00000368	system	GET	/api/v1/ref/user/mobile/01062507782	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	69058514-30c3-4081-a393-7b406ced3066	C7D0999F776E39CDE3AED371EDBC31D5	01	2025-09-16 03:53:19.119225-04
ACCESS_20250916165328_00000369	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	2fe3c74f-a2dd-464f-b29b-e11bbc0bbd07	20183BD6DEB4BFE46824C5AB8FF3FDD1	01	2025-09-16 03:53:28.19064-04
ACCESS_20250916165328_00000370	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ff0da3cc-0cfa-4d66-a386-7297f4d378ed	02D8EAD79C1261B496C80B532D53E63B	01	2025-09-16 03:53:28.287991-04
ACCESS_20250916165346_00000371	system	GET	/api/v1/ref/user/id/dhjo	사용자 관리 - 아이디 검증	10.42.0.1	e68e53ac-6d8f-4a42-b00d-b3a2ce467ec1	F1EC77D3ED010E29F892164BE3852B97	01	2025-09-16 03:53:46.27385-04
ACCESS_20250917005405_00000447	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	f491e64a-57f1-43d6-8acd-790f3080211f	A6C27ADEA4FAB440F843AB0309984A82	01	2025-09-16 11:54:05.999157-04
ACCESS_20250916165347_00000372	system	GET	/api/v1/ref/user/email/dhjo@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	a3c31ef3-3439-4e8d-9111-dfeeb5754964	F00A03079ADD38CD93347DE1C53A1B95	01	2025-09-16 03:53:47.42402-04
ACCESS_20250916165348_00000373	system	GET	/api/v1/ref/user/mobile/01044047088	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	7f5d5ff0-5cf6-4fb5-a07b-322f493a435e	563BB86B2DC06A4306BE032C4427165E	01	2025-09-16 03:53:48.705851-04
ACCESS_20250916165400_00000374	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	1778dd18-5095-45b7-b98c-ed912d270d1a	4365B63EDB3E888BB5080E78E328BB66	01	2025-09-16 03:54:00.252867-04
ACCESS_20250916165400_00000375	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	30b2b534-faac-4608-8b18-31022d9a12bc	EE7D659C3476C9880C1F87702EC8728A	01	2025-09-16 03:54:00.344438-04
ACCESS_20250916165413_00000376	system	GET	/api/v1/ref/user/email/ihchoi@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	e2a9421d-315d-4790-bffc-908a79a22b12	12C145B755426D4D05DD9DAB557D6C75	01	2025-09-16 03:54:13.848253-04
ACCESS_20250916165415_00000377	system	GET	/api/v1/ref/user/id/ihchoi	사용자 관리 - 아이디 검증	10.42.0.1	d84d4611-3977-42c9-b278-0eeef88dab68	BA80B0E579366F84EE124AF451EEF47F	01	2025-09-16 03:54:15.430656-04
ACCESS_20250916165416_00000378	system	GET	/api/v1/ref/user/mobile/01064221879	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	a2220dc6-d642-42c7-83ce-e0da4f5786e0	D86452091785F27AB06159C5DEFE08A2	01	2025-09-16 03:54:16.8598-04
ACCESS_20250916165427_00000379	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	88e01e95-3f17-4452-96ac-f18887c1c35d	55FB138952FFEF2E8921A6B0574B7C3B	01	2025-09-16 03:54:27.730955-04
ACCESS_20250916165427_00000380	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	dad418fb-d0a3-47ae-ad7f-8f744e8518e0	E3379864000718ADB80C8036595EC44E	01	2025-09-16 03:54:27.825806-04
ACCESS_20250916165442_00000381	system	GET	/api/v1/ref/user/email/cwsong@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	8d7416be-28bf-47a5-8f6c-658618c09e70	932A8BCA49433648465640D26E0FAD35	01	2025-09-16 03:54:42.853907-04
ACCESS_20250916165444_00000382	system	GET	/api/v1/ref/user/id/cwsong	사용자 관리 - 아이디 검증	10.42.0.1	de329745-3e26-48ef-823e-8662730fca7a	BDF67C356C2B05AC3E98FD69AB3BAEC1	01	2025-09-16 03:54:44.310045-04
ACCESS_20250916165445_00000383	system	GET	/api/v1/ref/user/mobile/01077517718	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	9b76f54c-5c48-4b93-825d-69052c456022	1AA6EC2A4E383D6D696E87344E3ACA2D	01	2025-09-16 03:54:45.850225-04
ACCESS_20250916165453_00000384	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	dd7b8657-f397-4667-a284-adae61f5c0a3	668DEF295AAC0AD9A8D720609B1EE152	01	2025-09-16 03:54:53.093529-04
ACCESS_20250916165453_00000385	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ff8bb707-f794-4bf9-b9f6-095a410200f9	AF86DB15D18D4112AF44388942201A4B	01	2025-09-16 03:54:53.184251-04
ACCESS_20250916165506_00000386	system	GET	/api/v1/ref/user/id/khlee2	사용자 관리 - 아이디 검증	10.42.0.1	2f429366-419a-4067-94ab-a7dcfbf92e72	692335D80DD5C377A0E35E7171BB4A8A	01	2025-09-16 03:55:06.796065-04
ACCESS_20250916165508_00000387	system	GET	/api/v1/ref/user/email/khlee2@jiwootech.kr	사용자 관리 - 이메일 중복 확인	10.42.0.1	65f1175a-94c4-49eb-ab23-a18e10a3b355	38EFB8FDD0615D5E5F7AD3FFE59D2B77	01	2025-09-16 03:55:08.041422-04
ACCESS_20250916165509_00000388	system	GET	/api/v1/ref/user/mobile/01071411489	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	e328c50e-2810-4b68-b5cd-308a1cb17292	C37E121F59777A7745C6E2228976284E	01	2025-09-16 03:55:09.302497-04
ACCESS_20250916165521_00000389	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	b78a41c5-2327-4852-a476-4a04aeb309de	40DAAC08AFB6829E9FBC3372BE1FED01	01	2025-09-16 03:55:21.176564-04
ACCESS_20250916165521_00000390	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ca2c93cb-d0be-4789-93dc-094b172079a4	9CB9697C1A9C91A93AA93E83E5656E87	01	2025-09-16 03:55:21.251253-04
ACCESS_20250916165523_00000391	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	784db9b6-b69c-42a2-b9e8-21ce88a6e6f0	AB05AB232BF85729E5931D87E4A0350E	01	2025-09-16 03:55:23.631453-04
ACCESS_20250916165543_00000392	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	9215ce0a-5d89-42c6-8be8-14d96e843427	B11CFF6AF1AF083BB941A422FB5D6493	01	2025-09-16 03:55:43.385893-04
ACCESS_20250916165543_00000393	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0bcac12c-2c92-4de4-acc1-fc49eb3fa5c5	E39E671073CDAE78FE85657B2CB8A58C	01	2025-09-16 03:55:43.433173-04
ACCESS_20250916165544_00000394	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	076e936d-b11f-419f-8667-4e4351aae99e	3062EF80ACE58791C0F86114D751F5CB	01	2025-09-16 03:55:44.588983-04
ACCESS_20250916165547_00000395	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	740ebbae-d099-47cf-8466-518c2e3963ed	F0ABF985C87E25DF6C2F398DE3E75EA2	01	2025-09-16 03:55:47.38523-04
ACCESS_20250916165548_00000396	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b9fe22c7-09c6-4ace-9819-8daf88290097	176F334952654AB23380E0C500C507F2	01	2025-09-16 03:55:48.765961-04
ACCESS_20250916165552_00000397	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8ceb4dbe-5462-4646-9049-334e8f631e8a	62952B5D91C15B954AB32B558493029A	01	2025-09-16 03:55:52.557757-04
ACCESS_20250916165554_00000398	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	d001dcb9-75d8-45aa-b0fe-fcc438af3525	95AB29D9A07CF1F436F82ACE252EBDD4	01	2025-09-16 03:55:54.292998-04
ACCESS_20250916165555_00000399	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	3ec89eb1-992d-4f29-a5a5-321c557b36da	1A0093F439B76CCC03FBF953D8C8876D	01	2025-09-16 03:55:55.289313-04
ACCESS_20250916165556_00000400	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b802fb58-dfa6-46e5-b56f-f6f06c98b9ca	F7CF8E5F2F5845B0C4716ADC62B12095	01	2025-09-16 03:55:56.036327-04
ACCESS_20250917005000_00000401	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	d0323505-f375-4505-8f55-64d4b5029aca	9855CE12BF891CF928CCAC3337F204B6	01	2025-09-16 11:50:00.344249-04
ACCESS_20250917005000_00000402	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	5c58945e-de95-4cb1-ae3a-d1ca821427f5	94C921ABE3E58F4C597F5C5BC6B6B740	01	2025-09-16 11:50:00.344241-04
ACCESS_20250917005006_00000403	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	d34ac9fd-a199-4da2-b9f9-e85ec4e00f32	2615446FAA12741FC33E8BF8320DD697	01	2025-09-16 11:50:06.738747-04
ACCESS_20250917005006_00000404	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	2cd9fc19-2a27-4984-b4b8-5b3c348f260c	B79E3309774E85DA194B9C96C4B94F6F	01	2025-09-16 11:50:06.781391-04
ACCESS_20250917005008_00000405	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	c3296af2-24bc-4678-bf23-fde0ab2a161a	5069084F46525EE43226A0DAEC51089D	01	2025-09-16 11:50:08.803667-04
ACCESS_20250917005016_00000406	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	17a8f201-cea8-4753-a8c6-c04da1a054f9	212F8364BDD8FE01576F57243C68B2F8	01	2025-09-16 11:50:16.550254-04
ACCESS_20250917005017_00000407	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	6a2dbc5e-bf11-4f07-834b-d979ff1324f1	D3AF70F92CFFE9759B35A2B2CF9D9F46	01	2025-09-16 11:50:17.758096-04
ACCESS_20250917005133_00000413	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	5b93e88d-6a80-4ff1-be2a-72df2f239487	E71D9CA87A542DBBEAFF292798E26FE1	01	2025-09-16 11:51:33.03749-04
ACCESS_20250918171917_00001241	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	3e5a6351-8ff1-422a-b1ac-db66860423fd	58C09532C558AC277B50883FB7132B9F	01	2025-09-18 04:19:17.455825-04
ACCESS_20250918175612_00001307	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	840cc514-576e-434c-ad67-80504df14e7a	66EDBB6050A6DA9366B8B1E9819FE1D0	01	2025-09-18 04:56:12.681082-04
ACCESS_20250918175705_00001313	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	af9f82dc-d14c-4e37-b2b0-361c4f4e93bc	0BBCC7A41BF41B0BE93D9247CC9A87AF	01	2025-09-18 04:57:05.715061-04
ACCESS_20250918175749_00001314	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	929c0055-aae8-4d7d-bc8e-c03eb5ed31e1	AF3D353F7456C95FD5D47828E44883CE	01	2025-09-18 04:57:49.375488-04
ACCESS_20250918175755_00001315	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	af3a2ea4-409f-4a81-ae43-a31694326492	5F264AA76FEF4EC0C15C60950E03F126	01	2025-09-18 04:57:55.185367-04
ACCESS_20250918175801_00001316	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	ff62112c-97ee-4292-980a-7196f08dbfdf	C76D5E18A2F30E4DF0743AF61CD023F7	01	2025-09-18 04:58:01.152756-04
ACCESS_20250918175801_00001317	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	ed4cbe94-19dd-41ca-a548-7746e764ba37	EE31B726474E0550BC45052DB717F718	01	2025-09-18 04:58:01.185699-04
ACCESS_20250918175805_00001318	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	acfc66f2-3ae7-4553-ab5d-9d834784590b	4A49E9DEB95A5EE2AEF995B08A026947	01	2025-09-18 04:58:05.407073-04
ACCESS_20250918175818_00001319	hckwak	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	2270a6d3-baf7-4004-a530-bb67e1b7e797	86030D023C04D8A1CE8D7864F1E86519	01	2025-09-18 04:58:18.937268-04
ACCESS_20250918175822_00001320	hckwak	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1	74299620-1bcf-454e-bc98-85c8fae194a3	D8EB9F9140633FEB25B75F846DC6CAAE	01	2025-09-18 04:58:22.931901-04
ACCESS_20250918175825_00001321	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	f1a76f6b-e557-47af-93d9-085ad5474464	AD230FFA3DDFDDB245F7BE7C64DEF9A5	01	2025-09-18 04:58:25.675694-04
ACCESS_20250918175831_00001322	hckwak	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1	e76f5996-974b-46a8-bae7-884a28616c8f	1EB7F0485D81AA7B99CD2F602383F4EE	01	2025-09-18 04:58:31.869302-04
ACCESS_20250918175831_00001323	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	c91f8ff8-b331-45cf-87c1-558d14daea66	8CC1DA477A1295CC70DFE721A24449C9	01	2025-09-18 04:58:31.932159-04
ACCESS_20250918175907_00001325	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	57820b2c-87e5-47b0-ac00-6cb868182493	EB866A6FA0624B65F22AF480EC2BC0D8	01	2025-09-18 04:59:07.181565-04
ACCESS_20250919161528_00001380	system	GET	/api/v1/product/7	입/출/반품 관리 - 상세정보 조회	10.42.0.1	1d911f6b-dd86-41a3-b544-bbe5c001cbb1	2E05D53CAD13174D4DA4B98678B879F1	01	2025-09-19 03:15:28.228204-04
ACCESS_20250919161559_00001384	system	GET	/api/v1/product/8	입/출/반품 관리 - 상세정보 조회	10.42.0.1	0ded0255-8c37-42fb-8c30-1a51630f40c1	930BEFBFA1430D4730CEE324C4E24AB3	01	2025-09-19 03:15:59.16438-04
ACCESS_20250923173515_00001419	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	570ec491-e9e0-4086-809e-343d19109625	ABF1E6E2D2C0842C13965707A6B242A8	01	2025-09-23 04:35:15.297385-04
ACCESS_20250925150556_00001456	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	7fb150dc-9d32-485f-86bd-e354f53c24d1	EE5D66C98C9A1263C885C0AC59150B10	01	2025-09-25 02:05:56.69049-04
ACCESS_20250926163306_00001482	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	c66ef741-c5ba-481f-a12c-ca299af25f4a	8FB35D997ED5F5AAFC9A7359701C02FD	01	2025-09-26 03:33:06.306029-04
ACCESS_20250926163306_00001481	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	2a7c82b5-b1aa-4ec3-a9af-eaae999e8d4c	9908261CBCDA209AD8801C8F8E55E9AD	01	2025-09-26 03:33:06.30603-04
ACCESS_20250926163325_00001483	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	6a7dec7a-5e68-4edb-89d5-cd18ed9f33a8	A6B26FCD1AC4BBD1796769EC6CF22AE3	01	2025-09-26 03:33:25.778575-04
ACCESS_20250926163326_00001484	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	7842eb77-6c43-45c2-803c-fd05fec91ca2	1D42897F853D45AD61302052247D88B8	01	2025-09-26 03:33:26.513579-04
ACCESS_20250926163328_00001485	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	1efbecc3-853f-4176-b5ed-faa2e7792496	D4B3B14691F0D46091C0ECD241455860	01	2025-09-26 03:33:28.514977-04
ACCESS_20250926163333_00001486	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	d832bbc2-afd6-46c8-aa68-2dfd4f78e79d	13483D28603F9EDAB27E6AFD8A1D1661	01	2025-09-26 03:33:33.874771-04
ACCESS_20250926163337_00001487	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	810cd1cc-abfe-4578-8779-9d973fa16fe3	5C5558CDB3E0A82C76CB71C463C4A5EA	01	2025-09-26 03:33:37.886116-04
ACCESS_20250926163341_00001488	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	840c7baf-164d-461d-aa63-60dae9f493cd	41F0372B3ECAB8FD32452B57042D4CE8	01	2025-09-26 03:33:41.723651-04
ACCESS_20250926163346_00001489	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	2fa935cf-b9d7-49f6-8075-dc9f77b3696f	7DF963E5616E1906B3478D72B42784A6	01	2025-09-26 03:33:46.937846-04
ACCESS_20250926163352_00001490	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	9fe30288-bce1-49cc-81d5-35a11b4d5bef	5486E89D3C33BF038D41F6DE09E46BDC	01	2025-09-26 03:33:52.715788-04
ACCESS_20250926163407_00001491	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	d3b4292a-8399-4239-bf28-4bff85634523	011E36C16ABBB2392B5DA7F6A1591338	01	2025-09-26 03:34:07.712439-04
ACCESS_20250926165013_00001536	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	17c05f85-f88a-4e99-b0e0-5e5ae5a5c0fd	B262691277DF7E9BE259F96B4DF3BC4B	01	2025-09-26 03:50:13.557057-04
ACCESS_20250926165017_00001537	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	465e70ff-970c-484b-b188-7beea3214b90	0F450DC7FD06E8D24836BC76EA5ED900	01	2025-09-26 03:50:17.261717-04
ACCESS_20250926165438_00001578	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	8d87637e-a440-459f-972a-35897b178368	30C0CEFC6771806EF9DDDAC1FFCFB479	01	2025-09-26 03:54:38.500922-04
ACCESS_20250930150033_00001595	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	1fc5b722-2781-471e-9f10-a14bfc452c4d	2E351519E6F8DC945CC1FB3063D8F732	01	2025-09-30 02:00:33.536976-04
ACCESS_20250917005019_00000408	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	6637d5cf-409d-4738-985e-21328267e5b6	56BDEE3026B12151486DDDA2B6A8362F	01	2025-09-16 11:50:19.441364-04
ACCESS_20250917005019_00000409	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	cee2812b-19d7-4501-8c2b-d8907520891d	BD72878E9E68F38AA8CDC34B21555A88	01	2025-09-16 11:50:19.942508-04
ACCESS_20250917005124_00000410	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	34526296-dddb-40b1-b1de-c0fa66064dd4	8EF22783ECE9B362F213307FBCE02C9A	01	2025-09-16 11:51:24.584597-04
ACCESS_20250917005124_00000411	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	b278fc74-b62d-4f2d-b5f5-84e512ac367f	518DBE68146BDB1BD9929FC786013804	01	2025-09-16 11:51:24.634685-04
ACCESS_20250917005124_00000412	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	c5ddb365-5f3d-4588-a20f-1ea2911c9613	EE573E1AD41C9E79673C06DCB0014E44	01	2025-09-16 11:51:24.679164-04
ACCESS_20250917005141_00000414	system	DELETE	/api/v1/ref/organizations/JW000012	조직 관리 - 삭제	10.42.0.1	5c591421-3c4e-4b81-b561-b405621a6e31	7C9B3C06482041C3787318F6EF1A1906	01	2025-09-16 11:51:41.936939-04
ACCESS_20250917005141_00000415	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	dd1edd3c-e9a6-4481-b748-4a433cc6cc0b	4B73090A64B9A55B88CF3E2B376ECAE7	01	2025-09-16 11:51:41.987978-04
ACCESS_20250917005153_00000416	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	ea517506-736d-47c8-8cdf-c070fb6803a2	AB894F998AD3EA9233246D3056DD26F1	01	2025-09-16 11:51:53.04912-04
ACCESS_20250917005220_00000417	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	c7296b14-a21b-4f89-b35b-3ff2e49c4261	3668B36F793434976042F20A5DD77332	01	2025-09-16 11:52:20.596554-04
ACCESS_20250917005222_00000418	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	3d54fe54-cf70-4375-a313-e17da8bb9211	D0017861B79714E8864F2464C83E641B	01	2025-09-16 11:52:22.084138-04
ACCESS_20250917005222_00000419	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b044d66a-c72b-47ce-93c5-f4ac1018a2cc	686E11984C908EAD276BEF616DC180A7	01	2025-09-16 11:52:22.763047-04
ACCESS_20250917005223_00000420	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7b1de542-8cb0-4c66-9563-8045d5ff1392	20BA43F93CA91EAA33BCA09F67A28F28	01	2025-09-16 11:52:23.902541-04
ACCESS_20250917005224_00000421	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	245fa496-5ee9-49cb-b2ae-02e755a5e0b3	4CCF21155574D4B3006E688667A2EA19	01	2025-09-16 11:52:24.888119-04
ACCESS_20250917005226_00000422	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	a095d095-1028-44d3-8ef5-bd3934bfe1fc	3BC50F251A95780749A7AC894560E7A4	01	2025-09-16 11:52:26.651454-04
ACCESS_20250917005227_00000423	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	91b619b1-23fc-4ed1-8204-60a5fff7339d	A7ABB76A752AF9C3A9FB1C8C9633E6DD	01	2025-09-16 11:52:27.826954-04
ACCESS_20250917005229_00000424	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	26a8d7e3-18a5-46c1-96ba-6f249f021eb9	27ECFC532D77A8370D6D01D54AE3A51D	01	2025-09-16 11:52:29.60229-04
ACCESS_20250917005252_00000425	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	05d6d31f-96e8-4b4c-b7b6-cb6e7e834f77	708C0D388FA10788F5654667F46DB283	01	2025-09-16 11:52:52.638941-04
ACCESS_20250917005254_00000426	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	f925de3a-0170-4767-b178-81b8b83fa654	B0FCB0B99A9A338C9F1D79E59F60E854	01	2025-09-16 11:52:54.328941-04
ACCESS_20250917005314_00000427	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	dbbbd266-7991-4083-af0e-4cf138adb040	DFB3AAED676454A6C461627B8FB70B99	01	2025-09-16 11:53:14.474995-04
ACCESS_20250917005314_00000428	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	c366a2fe-b58f-488b-8b07-5cd2c85f9b24	B2344386EFC3CE3017F0C744E2A3D605	01	2025-09-16 11:53:14.533611-04
ACCESS_20250917005314_00000429	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	091325d8-38b4-45fa-9fbd-002c24659dfe	B1C03FE29EE0CF086347A5F940D2559E	01	2025-09-16 11:53:14.566998-04
ACCESS_20250917005316_00000430	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	3c37ff9f-15d8-4c36-b2f8-7cb3e0d5e965	724AF4828623A3695D7F242CA9332EF8	01	2025-09-16 11:53:16.989619-04
ACCESS_20250917005331_00000431	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	3b13ceb8-4900-410b-a5e0-1e1a43220fa3	B2628746B8C779653669201C7A62409A	01	2025-09-16 11:53:31.254418-04
ACCESS_20250917005331_00000432	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	64606b54-18d2-4a6e-b7cc-2339457bde49	7BE6890C41B241F8A07DDD92F338003E	01	2025-09-16 11:53:31.307715-04
ACCESS_20250917005331_00000433	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	256df39c-64d3-43db-8337-f14b3031b2cc	7BE6890C41B241F8A07DDD92F338003E	01	2025-09-16 11:53:31.308447-04
ACCESS_20250917005337_00000434	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	30109d26-3546-4f99-94d7-4bc2a80a13e0	C8D084D109B782CD1ABF6FC151664653	01	2025-09-16 11:53:37.904256-04
ACCESS_20250917005337_00000435	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	3976145e-ba35-465d-8922-b110b8fad921	DFA577237481E952B483F04AFCD34197	01	2025-09-16 11:53:37.955204-04
ACCESS_20250917005337_00000436	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	13f59eaa-0566-44b9-a358-f2c57038375e	DFA577237481E952B483F04AFCD34197	01	2025-09-16 11:53:37.955414-04
ACCESS_20250917005346_00000437	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	a12b4137-fec5-4936-9ef0-3fdbfaf34721	93BBC5810A85FE3982F9342AC2D467F6	01	2025-09-16 11:53:46.307105-04
ACCESS_20250917005346_00000438	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	37f0911c-31ab-48b2-a0f1-292990f0c460	F1EAE71317AABA11CDB52597BFC5A886	01	2025-09-16 11:53:46.357502-04
ACCESS_20250917005346_00000439	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	78554307-09a5-4af7-9087-f8e03082e056	4ADFFAD7EE627A2F0F85D1BA73F4E382	01	2025-09-16 11:53:46.359214-04
ACCESS_20250917005352_00000440	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	29cb2d17-cadc-4c63-a636-5015b2d0d436	1DD7B1458F23A69A9207D36E9A7807BF	01	2025-09-16 11:53:52.887685-04
ACCESS_20250917005352_00000441	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	89d79d40-03f7-441f-aa05-1df7b2b4fd66	31F1F9D79AD3E046A57C2A539BA90E90	01	2025-09-16 11:53:52.936191-04
ACCESS_20250917005352_00000442	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	e64d926b-b47d-4ae5-8013-752591961669	31F1F9D79AD3E046A57C2A539BA90E90	01	2025-09-16 11:53:52.937045-04
ACCESS_20250917005359_00000443	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	638d39ce-4346-4b2f-b283-c3751e87cd32	58517E20C7E71C8030D03B778B76056C	01	2025-09-16 11:53:59.674214-04
ACCESS_20250917005359_00000444	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0cd6c8df-91f4-4cb6-81da-50d4026b2479	D59C714620414FB2FD8B8F11A03A5DE9	01	2025-09-16 11:53:59.705277-04
ACCESS_20250917005359_00000445	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8f93ac70-cfd7-44e2-ab9d-26a8dc1dc764	D59C714620414FB2FD8B8F11A03A5DE9	01	2025-09-16 11:53:59.705658-04
ACCESS_20250917005405_00000446	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	a62143ab-46f0-4150-a22b-91a427502dc5	884EF139E556C05140F1D9532D5DAA17	01	2025-09-16 11:54:05.967231-04
ACCESS_20250917005405_00000448	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	129dddd9-dc2a-4d18-be58-a5ed20f0e2b1	A6C27ADEA4FAB440F843AB0309984A82	01	2025-09-16 11:54:05.999466-04
ACCESS_20250917005427_00000449	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	bb5797d6-c9aa-47c7-b917-5321ba1b6459	D7EFAC6694FA98168E4FA7DF2429DB1B	01	2025-09-16 11:54:27.168165-04
ACCESS_20250917005427_00000450	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	ab60daaa-a327-4a20-a8d9-a3f197ead4f3	C9DCB6B23327FBC063BF2F3B174B9324	01	2025-09-16 11:54:27.201025-04
ACCESS_20250917005442_00000452	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	122b1f3a-7b4f-43b7-8584-911f8c797632	7773893CE8716DE2373392C03CD3BE37	01	2025-09-16 11:54:42.775979-04
ACCESS_20250917005442_00000453	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	98d0a386-b765-4960-a7d4-b4a9f48c6571	EF62C69D82FDF5E17EA817E87B03F8BE	01	2025-09-16 11:54:42.808014-04
ACCESS_20250917005453_00000455	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	c3882fe4-9440-4ae2-91be-6a7b2e8c5ef8	07659AB45E4A4ABE5E29C20B3B795CCA	01	2025-09-16 11:54:53.503331-04
ACCESS_20250917005519_00000459	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	6661c301-a17e-483c-a1d5-17e80ef1a2bf	DB03E49627D52EE719D284669450FBCB	01	2025-09-16 11:55:19.294591-04
ACCESS_20250917005519_00000460	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	18f5e174-17be-40f9-8007-08c5b4f20424	DA10EF8DF4A688D9BFCA6E3CE47A5AE3	01	2025-09-16 11:55:19.320749-04
ACCESS_20250917005534_00000462	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	c07e8842-f56d-469b-8741-edc98ffd76cb	221D7A4A95095A0671290C8DF8449129	01	2025-09-16 11:55:34.964108-04
ACCESS_20250917005534_00000463	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	27ab6015-07c5-4341-828f-6ab4d412d0d8	E93DC7F2419BBFEEC7BA5288ACBF9C33	01	2025-09-16 11:55:34.991703-04
ACCESS_20250917005543_00000466	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	11447b51-37e2-4d1e-abed-5e599fed833a	4063AD027127B31AC6AA860200911CFF	01	2025-09-16 11:55:43.900593-04
ACCESS_20250917005602_00000469	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	96bf7efd-faf9-4344-b0de-2574cd01bdba	025AE256CC67155082475FDA0CE2BD4D	01	2025-09-16 11:56:02.290165-04
ACCESS_20250918171917_00001242	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	bb3f30fb-5daa-4f33-b96f-d6b6e536014e	396A3F3A76EC931F8E972ED30571D451	01	2025-09-18 04:19:17.456479-04
ACCESS_20250918171941_00001245	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	fdbafd58-1897-4375-9f3a-8119a5868781	8A5216D8D5CDEA054299D44D07CC1A73	01	2025-09-18 04:19:41.906501-04
ACCESS_20250918175612_00001308	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	dee35f5d-4db4-42a6-9269-723bb5d72fe8	ACDFAAC340BD86D420169B9FCF4AF2E2	01	2025-09-18 04:56:12.681083-04
ACCESS_20250919161559_00001385	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	97c55d2a-1ea9-4c17-829b-c1875270ef76	930BEFBFA1430D4730CEE324C4E24AB3	01	2025-09-19 03:15:59.164623-04
ACCESS_20250919161616_00001386	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	4c66db89-8101-4a2f-ba25-43c6750f61d1	AE88A2F5EA97159C11FC7BD304AD54C1	01	2025-09-19 03:16:16.026198-04
ACCESS_20250919161616_00001387	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	7d2444c1-5fab-4c4d-b8a1-b59187825541	FAD58A7628E56357C4DE2B9A970030BA	01	2025-09-19 03:16:16.058835-04
ACCESS_20250919161622_00001388	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	0e2ae67f-d713-4a59-bd42-712cacb46909	547F7DF9C4B8FD97DB0BAFA8BE974F59	01	2025-09-19 03:16:22.546571-04
ACCESS_20250919161629_00001389	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	3fd21148-de2e-4f35-abb8-17512a4ffef5	6420CB6CEE463F690BFA1DCE1BFF927B	01	2025-09-19 03:16:29.361858-04
ACCESS_20250919161635_00001390	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	5816e0fc-5e93-4f5b-a97e-4ee70559292f	5D5253D4BA70F5A238329E4300728D7B	01	2025-09-19 03:16:35.577475-04
ACCESS_20250919161637_00001391	system	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1	3815cda0-18c3-4935-bd66-8ad0ce931c4e	38C4159C656B29798FAF8A6F12D347B6	01	2025-09-19 03:16:37.366516-04
ACCESS_20250923173538_00001420	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	9194f4f7-a52e-4091-8d5e-3967bcc74781	8601A594794189A3F618B70CF8CA53DE	01	2025-09-23 04:35:38.525852-04
ACCESS_20250923173548_00001421	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	a7b40edc-665b-4b1a-ab9a-6717317484ed	7237FE9B56D7E68A3A47E195CAB96C30	01	2025-09-23 04:35:48.745151-04
ACCESS_20250923173552_00001422	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	3dccd7e9-f815-47a0-81e5-7f939bc34974	08CE411261C242379200C8D64BAB42C7	01	2025-09-23 04:35:52.123761-04
ACCESS_20250923173605_00001423	hckwak	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	ae63f104-4bae-4df6-b4aa-ee1a569a055b	D1CB80612B09620E9C3E3ED6A9A9D320	01	2025-09-23 04:36:05.072441-04
ACCESS_20250923173605_00001424	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	84132f37-a577-4e52-bebe-ef3db169495d	B3D73406C6A468F97CA2A808DF0B4F19	01	2025-09-23 04:36:05.102224-04
ACCESS_20250923173623_00001425	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	85426b36-0449-45f4-9a02-80a695e80d34	B99CB1F000792CBB34729D62B8DEF160	01	2025-09-23 04:36:23.670572-04
ACCESS_20250923173627_00001426	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	f2946ed6-83d3-4af8-9169-1c2473678d90	CAB1561AADCC5F486E334A762B89F302	01	2025-09-23 04:36:27.850752-04
ACCESS_20250923173627_00001427	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	f74b4338-b04b-45cd-a2a7-aab11373988f	1935AF447E8EA620E7DDBADEC5E0DC53	01	2025-09-23 04:36:27.875141-04
ACCESS_20250923173634_00001428	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	73f27381-689c-4733-bfed-b1d1cfee6288	07C852A376FCD9CDABB5794CAA335567	01	2025-09-23 04:36:34.100385-04
ACCESS_20250923173646_00001429	hckwak	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	78ec65a2-190a-45f8-b555-59e2a770ba41	F472D269C61ADEC7E6BB6335EEDA8315	01	2025-09-23 04:36:46.967799-04
ACCESS_20250923173703_00001430	hckwak	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1	9cf05938-eaaf-456e-aa8b-b594e8ebe2ea	A9FC51676D8520C6994B29658E32C5CE	01	2025-09-23 04:37:03.562003-04
ACCESS_20250923173706_00001431	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	29b5fd9c-2d4f-4755-b21b-8f45f1116620	D82F37B3D8DBD879A684267DEFE1F517	01	2025-09-23 04:37:06.344852-04
ACCESS_20250917005427_00000451	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	9af85ba3-fe9d-4222-924f-99e3bc3c297e	C9DCB6B23327FBC063BF2F3B174B9324	01	2025-09-16 11:54:27.201243-04
ACCESS_20250917005442_00000454	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	aa602e26-adde-417a-84ff-2ee317834578	97D6D4C2E064637A52A970B866322F91	01	2025-09-16 11:54:42.835937-04
ACCESS_20250917005453_00000456	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	7ea3721d-e144-4c64-a921-45c1b4008016	15C3730EB28A2DBA25B9BE435BF97C6E	01	2025-09-16 11:54:53.535851-04
ACCESS_20250917005453_00000457	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	cb055d90-4d74-4d57-91ea-98839723d3ea	E21D67AD484B89107C057CA2C3ED8622	01	2025-09-16 11:54:53.564655-04
ACCESS_20250917005519_00000458	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	3918ca97-ae33-4a19-bf5f-041b64c9b7ae	68386F45E9C212FE2A510F0E32842B67	01	2025-09-16 11:55:19.262642-04
ACCESS_20250917005534_00000461	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	cea749ed-28c5-4162-9bb0-d4b85e96776e	7DDE24CD31E896F5BBDF4A1CF9059F9A	01	2025-09-16 11:55:34.933792-04
ACCESS_20250917005543_00000464	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	a7302fa8-4512-4467-82db-ce9f97f563d9	18B163FC9FA3B656CB85AFE693D25DDF	01	2025-09-16 11:55:43.838227-04
ACCESS_20250917005543_00000465	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	4e176b84-8288-439a-bf5b-4b4e7b9449e6	E3DF5B6E7867394E1EF51356582EBB91	01	2025-09-16 11:55:43.873195-04
ACCESS_20250917005602_00000467	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	181fe515-4e56-4547-8ec1-671ddab9d048	2799D4239839A4B1CE2DE4F3EBAAF8F4	01	2025-09-16 11:56:02.207279-04
ACCESS_20250917005602_00000468	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	37d97df5-c603-4901-8751-1d660bec66b7	9F65C51B2DC6D68048399841A774C559	01	2025-09-16 11:56:02.259052-04
ACCESS_20250917005620_00000470	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b1138eec-dff7-46d4-bad8-fa348c3d4687	3E7A72047FB2EBD26E0E9D120BD465D2	01	2025-09-16 11:56:20.213267-04
ACCESS_20250917005656_00000471	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	9b6f7973-7955-439e-bdc9-ee4498e6a808	85A84E208CF78E49A9A64D359DCBBB76	01	2025-09-16 11:56:56.484876-04
ACCESS_20250917005722_00000472	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	bdc390eb-da3d-4488-9778-062786a1de9d	19EF080D431CC37C557E938BC78A6346	01	2025-09-16 11:57:22.360667-04
ACCESS_20250917005726_00000473	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	1aee7c22-dafa-46ea-8601-bc572d8c03c9	8142C7AD64CF6394D6A2CE57278AF77A	01	2025-09-16 11:57:26.072379-04
ACCESS_20250917005726_00000474	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	90fadf3f-ad74-4c3e-81f4-33ce05294314	33A8124A249A0E542354BD412D869E45	01	2025-09-16 11:57:26.121814-04
ACCESS_20250917005726_00000475	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	f01e54e5-ccbe-43ac-8db1-89538e21520f	20EDE996E33853BA47F738C602773635	01	2025-09-16 11:57:26.1431-04
ACCESS_20250917005751_00000476	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	42437996-179d-425c-8253-5078ad8431ca	6770B724149FCE5373300FE553DBB10E	01	2025-09-16 11:57:51.174416-04
ACCESS_20250917005751_00000477	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	c96a7ad5-74bc-4947-9493-8fee675e914a	B530177C0E790692B69F211F12ECF682	01	2025-09-16 11:57:51.204653-04
ACCESS_20250917005751_00000478	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	ffa684fd-eea4-4fed-a332-fea52c4e4e71	B530177C0E790692B69F211F12ECF682	01	2025-09-16 11:57:51.204483-04
ACCESS_20250917005821_00000479	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	b8268497-d1e5-432a-bd29-b087311ff47a	6AC14D6B58CEBF3AD6A08E86C69B6A14	01	2025-09-16 11:58:21.846147-04
ACCESS_20250917005821_00000480	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	ff987850-e5e7-48da-8a01-9d6863d244b3	A4B93F11433781ACCC54836B4B2376DA	01	2025-09-16 11:58:21.894636-04
ACCESS_20250917005821_00000481	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	3f42597d-06ab-4ec1-b235-d978061638dc	A4B93F11433781ACCC54836B4B2376DA	01	2025-09-16 11:58:21.895183-04
ACCESS_20250917005832_00000482	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	678e1c78-974c-4c22-ac36-71ca7c839200	0B54A3D32739F308A2C4895B7BFDA5D3	01	2025-09-16 11:58:32.815033-04
ACCESS_20250917005832_00000483	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	2773e07a-aa34-4831-b540-779839c7601e	BDCDF4358E51297BEF3AAFCFC08C265D	01	2025-09-16 11:58:32.839516-04
ACCESS_20250917005832_00000484	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7701dbf2-a76d-4c02-ae4c-95939a6d9987	BDCDF4358E51297BEF3AAFCFC08C265D	01	2025-09-16 11:58:32.83973-04
ACCESS_20250917005840_00000485	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	1e98d00c-2305-4f97-b458-56913b96bb30	85C0C351EBF8D3B50EC1939D27C95DCB	01	2025-09-16 11:58:40.445175-04
ACCESS_20250917005840_00000486	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b862cebb-9564-4179-b5e4-1b6423a5858e	D339EF4928A1BD7B65D1B4D868082A97	01	2025-09-16 11:58:40.475138-04
ACCESS_20250917005840_00000487	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	fca82d2a-04b6-4d62-ae28-83b0844e7415	D339EF4928A1BD7B65D1B4D868082A97	01	2025-09-16 11:58:40.47523-04
ACCESS_20250917005849_00000488	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	c6e4d4f1-05ed-4503-8de1-372d600b2eb8	EE16E48D3E21ABABDFC97F148105744C	01	2025-09-16 11:58:49.421945-04
ACCESS_20250917005849_00000489	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	0581bc14-ce8f-4df3-97f2-f987d38dac5f	428099983B2AE60D90D44E3DD44BA58A	01	2025-09-16 11:58:49.470918-04
ACCESS_20250917005849_00000490	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0a9db303-a871-4616-bcd9-34a3aed09fca	428099983B2AE60D90D44E3DD44BA58A	01	2025-09-16 11:58:49.471079-04
ACCESS_20250917005858_00000491	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	d643a2ea-9c21-4acf-9320-58d524fa0316	20EF210C0D4A30E9AF9D97A75EDC657C	01	2025-09-16 11:58:58.863519-04
ACCESS_20250917005858_00000492	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	6c9c51d9-5325-4199-bf3a-f76736578712	A41F8D9A09D0A6DCFE9E9ED42D9B7B80	01	2025-09-16 11:58:58.891739-04
ACCESS_20250917005858_00000493	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	806c24a7-68a1-4ad1-86ad-f674f2c443b4	A41F8D9A09D0A6DCFE9E9ED42D9B7B80	01	2025-09-16 11:58:58.892044-04
ACCESS_20250917005919_00000494	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	9ddc860d-0f70-481e-8d96-ba51d8f3023c	3B37C95E5A8556AD62E8F88DB1BDDD19	01	2025-09-16 11:59:19.926166-04
ACCESS_20250917005919_00000495	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0ed14b17-8b78-4721-9293-10f628fa83e2	2F7E1121D195EBE4AD76D6028120A0AF	01	2025-09-16 11:59:19.954717-04
ACCESS_20250917005919_00000496	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	82d75047-ee44-406c-9b16-473fda997884	2F7E1121D195EBE4AD76D6028120A0AF	01	2025-09-16 11:59:19.954931-04
ACCESS_20250917005935_00000499	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	e1f43f27-b19b-4360-ac27-38d95aecfe5e	8870166EAA15533219205154BB9D5FF3	01	2025-09-16 11:59:35.239563-04
ACCESS_20250918171924_00001243	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	13d3ba5a-af98-4e15-9c77-6d72371844bf	C7704130CA03B7F65F96DF44F7309E56	01	2025-09-18 04:19:24.25279-04
ACCESS_20250918171934_00001244	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	dc4a32a0-8b11-41f7-a1c3-0dc31a157ac5	C6E4C921C5E9034FB2AC64BDDEFEB0FD	01	2025-09-18 04:19:34.685328-04
ACCESS_20250918175904_00001324	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	cc4324d7-e03c-44fb-8187-ec946561defc	11D7B1759021A4D1CF9A3F5E42C130FD	01	2025-09-18 04:59:04.368404-04
ACCESS_20250921003153_00001392	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	4c630641-ce6b-4a2b-a825-93f1bac5c35c	BB28013110A424F3779E82AACD48DF16	01	2025-09-20 11:31:53.831031-04
ACCESS_20250921003153_00001393	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	f34668ba-e1bd-4d8c-a55b-f3e811ac02d2	50BF15E60031C2AAF699FA7EDB261002	01	2025-09-20 11:31:53.830593-04
ACCESS_20250923173713_00001432	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	609fc880-c67b-49d4-9b36-1b69cb6237e9	D8A3E86F1D833F5DD7AC586372F7C53D	01	2025-09-23 04:37:13.529482-04
ACCESS_20250923173716_00001433	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	a52bef6b-ef8b-4e08-8601-8bff56ee6d42	1638167BE128446750C83C68D806AC17	01	2025-09-23 04:37:16.84377-04
ACCESS_20250923173724_00001434	hckwak	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1	4c0ea319-2f76-4376-99d2-f0302f55edc3	3844B8AED7C5D7AF2DF0C6412A5A2FF4	01	2025-09-23 04:37:24.163567-04
ACCESS_20250923173724_00001435	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	e251a0b2-e34a-4981-b6fd-05e2fd48b0bc	4B554B25C0A8BBB1557A8F2070FBBA50	01	2025-09-23 04:37:24.231766-04
ACCESS_20250923173727_00001436	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	5bf11c21-dce5-4a19-b0ea-5b31acd83445	6221DD3FB9AFF950D29DB3CCB5B4A342	01	2025-09-23 04:37:27.114541-04
ACCESS_20250923173731_00001437	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	4dfdae4b-0d92-44df-ac54-58edca6bbeb6	0D57AC0969B870BA861684BD7FED3A3E	01	2025-09-23 04:37:31.972003-04
ACCESS_20250923173735_00001438	hckwak	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	d088f956-f2fc-4811-9bb3-7249c33ddae1	332793250AEB3332F077FCB2F365A320	01	2025-09-23 04:37:35.689238-04
ACCESS_20250925150556_00001457	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	a5b92d4f-ee73-43b0-ac8e-ba7ffdeca1b6	D80BD3D8CFFF17F6A83143303E66969E	01	2025-09-25 02:05:56.707008-04
ACCESS_20250926163430_00001492	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	b6d00111-9d35-49e2-bf77-7a6a01a63610	9D974874DE76C0154A21E919F9F4BCEF	01	2025-09-26 03:34:30.973354-04
ACCESS_20250926165020_00001538	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	7abfcf2a-cd6a-407e-ab4e-6e3eeb315734	74D29B7C0E75C876764211D398A86303	01	2025-09-26 03:50:20.85909-04
ACCESS_20250926165022_00001539	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1, 10.42.0.170	48a943e4-b61e-43d7-86ff-0e33a7ffc645	EA6D5F4F5868B6A286848CDC2DEE5CF5	01	2025-09-26 03:50:22.927719-04
ACCESS_20250926165026_00001540	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1, 10.42.0.170	3e95f79d-20ff-4795-9f52-3bf4707e7304	83C3FDCCC2E3051E9A8BE08BF25BC023	01	2025-09-26 03:50:26.466505-04
ACCESS_20250926165034_00001541	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	9fb260e0-77d4-44cc-bf8f-c1fd96135e9d	0FF80D4EBD39792D93C7A5DDE065357A	01	2025-09-26 03:50:34.109503-04
ACCESS_20250926165038_00001542	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	553ff7fa-1bd6-44d2-82f1-0b23f8f58085	992D774F815151C71161C260761AA208	01	2025-09-26 03:50:38.679899-04
ACCESS_20250926165042_00001543	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	048cc00a-b8f8-4298-b299-46604e1618dc	DC62102E8E786917B65D43CD0C965A1D	01	2025-09-26 03:50:42.007769-04
ACCESS_20250926170657_00001579	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1, 10.42.0.170	20fda533-aba5-49ef-822f-44765d67acf1	4F74BE308EDA748B8383A7E3FCAE0F12	01	2025-09-26 04:06:57.033317-04
ACCESS_20250926170657_00001580	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	74f2e7b8-9a53-40d4-a793-67f72b2f9bb2	EDE3895181D0FB8C86571451CA39E230	01	2025-09-26 04:06:57.7276-04
ACCESS_20250926170659_00001581	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	4bf15fbe-a387-4902-ba0a-8705f65e4bd1	B8CFE1274404D22DB4F8E37B3965F039	01	2025-09-26 04:06:59.030543-04
ACCESS_20250926170704_00001582	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	076bc7b4-33e4-45ef-bd3c-d69f29fdf61d	D772C034D7D4F9396CB009CD60FFEF2F	01	2025-09-26 04:07:04.590242-04
ACCESS_20250926170704_00001583	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	e693eb9c-5569-4c13-a6ac-d7d58f9ce709	C33F1A94D89DC420145F1DDBA65FA2A0	01	2025-09-26 04:07:04.676479-04
ACCESS_20250930150035_00001596	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1, 10.42.0.170	26eb7910-2891-48f5-8a1b-d54de55a474b	4122A713323BE79BC44C9C8C299083F9	01	2025-09-30 02:00:35.673081-04
ACCESS_20250930150037_00001598	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1, 10.42.0.170	6c8c297c-f6b5-40ea-aa99-b68b2d3714b2	B79D7C35F7970F5403F3AC9D6755D349	01	2025-09-30 02:00:37.716991-04
ACCESS_20250930150039_00001599	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1, 10.42.0.170	23fc290a-cd9c-4e9d-b774-7f15285033a9	E82810FEEAD066AFD36B68D907012B4E	01	2025-09-30 02:00:39.970747-04
ACCESS_20250930150042_00001600	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	20c6548a-56a7-41a8-ab46-7effe5a68369	A2945151E1B79BA3EC5C575FC03AB048	01	2025-09-30 02:00:42.758588-04
ACCESS_20250930150043_00001601	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1, 10.42.0.170	9a5dfcb2-16ec-41f7-85ff-cc0054788f4e	94295C537370706B2A799A808F5907ED	01	2025-09-30 02:00:43.348637-04
ACCESS_20250930150044_00001602	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	2f560180-aaea-4a35-8394-0faccf1261b2	D15F5A7B8D0FD0A519C6F616A10A6E7E	01	2025-09-30 02:00:44.473941-04
ACCESS_20251002105503_00001618	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	a2d2d486-398a-44e9-a978-26f1cadfcbf4	6886D1CA7399BA303DF71ECD858AA86A	02	2025-10-01 21:55:03.133902-04
ACCESS_20251002110116_00001628	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	6e33596e-c40b-4497-a989-c29f7f5cad0b	3C25EF7C856C570088A594FEF0448F6F	01	2025-10-01 22:01:16.91586-04
ACCESS_20250917005935_00000497	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	d7bc1e60-bb3b-44e4-b2c6-d704c06f348f	AD2CC5E88D05502FA55EEC364336D50A	01	2025-09-16 11:59:35.189431-04
ACCESS_20250917005935_00000498	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	50393867-e6a7-480d-a7cc-f3a4ab45f6a7	8870166EAA15533219205154BB9D5FF3	01	2025-09-16 11:59:35.239357-04
ACCESS_20250917005959_00000500	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	21b8bb3a-332f-422d-a29e-f2473d733007	E05BAD7EDE8313C393B86ACB53856B41	01	2025-09-16 11:59:59.935155-04
ACCESS_20250917005959_00000501	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b878fad5-b620-4002-88c0-ca9edfceae40	9B4CA38A23FED43B3ACB4CB221954245	01	2025-09-16 11:59:59.970908-04
ACCESS_20250917005959_00000502	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	7e01634b-791d-455c-9821-61774490e789	9B4CA38A23FED43B3ACB4CB221954245	01	2025-09-16 11:59:59.971115-04
ACCESS_20250917010007_00000503	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	3b045c8a-2beb-4c30-96cf-bbbd9a3cc97d	1AD717C88C4C646221542B1BC73B82AD	01	2025-09-16 12:00:07.719107-04
ACCESS_20250917010007_00000504	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	4141cce9-de5a-45f5-8258-d33655b8eec3	4A3A9478D8881BE1D6724AEA42A20916	01	2025-09-16 12:00:07.743886-04
ACCESS_20250917010007_00000505	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	8b1e4ac2-6ca4-4700-9ca8-dcb84b01c59f	4A3A9478D8881BE1D6724AEA42A20916	01	2025-09-16 12:00:07.744082-04
ACCESS_20250917010021_00000506	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	fffd9679-ecdb-4b3e-9f1b-029f9c496283	E7860AD1972CA966A0058B23BDE6377C	01	2025-09-16 12:00:21.821466-04
ACCESS_20250917010021_00000507	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	9956c01a-f2ca-4938-b35d-c8f8c0bdc058	1A64223C66AD3966C32000AFEF0FEA9E	01	2025-09-16 12:00:21.881209-04
ACCESS_20250917010021_00000508	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	034a0155-d10c-4f4a-aa67-53d399a9aa06	1A64223C66AD3966C32000AFEF0FEA9E	01	2025-09-16 12:00:21.882149-04
ACCESS_20250917010033_00000509	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	65582b00-c1db-4d8e-b8a8-8198a31a827a	E2AA2DAA171A9D1365CAFCD03207E1F7	01	2025-09-16 12:00:33.253394-04
ACCESS_20250917010033_00000510	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	e9eb77a2-c905-48c0-89e8-161d16060cef	9056F859BAEDD4665AF862F516707253	01	2025-09-16 12:00:33.278995-04
ACCESS_20250917010033_00000511	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	96eed92f-7742-476c-8131-55cecb315d2b	9056F859BAEDD4665AF862F516707253	01	2025-09-16 12:00:33.278988-04
ACCESS_20250917010046_00000512	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	a5ec7119-0d92-4ce9-b370-d8e4db0c4bee	873B979596EDA9244825ECA14731034B	01	2025-09-16 12:00:46.463883-04
ACCESS_20250917010046_00000513	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	64e62a96-5603-4864-b656-3d516b6758d7	A99D8B2A119A46DF20CB79E89DB8EA86	01	2025-09-16 12:00:46.540074-04
ACCESS_20250917010046_00000514	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	f44d02d2-dc80-4266-abd1-ea4af4f7ad78	A99D8B2A119A46DF20CB79E89DB8EA86	01	2025-09-16 12:00:46.540289-04
ACCESS_20250917010057_00000515	system	PUT	/api/v1/ref/organizations/move	조직 관리 - 사용자 조직 이동	10.42.0.1	a4778342-f40f-444c-9483-8f53ab78d34d	3F1F9FDC4ED91BFCF5447F26010CA635	01	2025-09-16 12:00:57.006395-04
ACCESS_20250917010057_00000516	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0d14585e-49dc-448b-877d-a4f4213e7671	7D23EA08AE8EF1885DC5A8C845B03BB9	01	2025-09-16 12:00:57.037803-04
ACCESS_20250917010057_00000517	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	c5f1ef7a-cff7-41d9-9999-36bffa3edd98	7D23EA08AE8EF1885DC5A8C845B03BB9	01	2025-09-16 12:00:57.038009-04
ACCESS_20250917010118_00000518	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	2bc66e9d-e2c6-44f2-85a6-695cc628e5bf	905E93B413D628FCE5963F32BB238C60	01	2025-09-16 12:01:18.622779-04
ACCESS_20250917010119_00000519	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	3547d407-50fe-4d35-b6c6-d9abc22be125	B2F9F346DB6827A78F159CF4C9E2903A	01	2025-09-16 12:01:19.543904-04
ACCESS_20250917010236_00000520	system	GET	/api/v1/ref/customers/unique-info/cuid	고객사 관리 - 고유정보 생성	10.42.0.1	5a1f51ab-ffe2-4d7a-9181-42f179625b7e	E4C5809CA7C27F1B1E6DF50DB413EA5F	01	2025-09-16 12:02:36.318711-04
ACCESS_20250917010239_00000521	system	GET	/api/v1/ref/customers/unique-info/ap	고객사 관리 - 고유정보 생성	10.42.0.1	5b2ca32c-7c49-4290-aff4-3739b25af424	7DF0DD059E7C1DC36949381571819E06	01	2025-09-16 12:02:39.379641-04
ACCESS_20250917010241_00000522	system	GET	/api/v1/ref/customers/unique-info/mk	고객사 관리 - 고유정보 생성	10.42.0.1	59ba4b60-72b8-423b-9ea5-2d743b790b31	81BE56D81AEE31B738B7A6F4CC1169D3	01	2025-09-16 12:02:41.896653-04
ACCESS_20250917010248_00000523	system	GET	/api/v1/ref/customers/validate/POSCO	고객사 관리 - ID 중복체크	10.42.0.1	112677c6-38f8-4a02-b56b-58b0520525a7	19CCBC6AB04FC6BE13DA78DC5C016C80	01	2025-09-16 12:02:48.344492-04
ACCESS_20250917010250_00000524	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	d1d37b44-ff00-4378-a3b3-d49f2a0802be	F252BA7062F26861E55D2C4F90F07FA8	01	2025-09-16 12:02:50.175738-04
ACCESS_20250917010251_00000525	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	4a0f1ae4-41fe-432e-b5e7-5f9de2d04e94	7E3ADDFD643B1DBA4C4D6BD780160AEB	01	2025-09-16 12:02:51.320659-04
ACCESS_20250917010252_00000526	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	e1f99f0b-8a7f-4b23-981d-d30474e6af6e	9C37736E51741BCF411E2C5B8A56A9ED	01	2025-09-16 12:02:52.216307-04
ACCESS_20250917010255_00000527	system	POST	/api/v1/ref/customers	고객사 관리 - 등록	10.42.0.1	97855e43-6c7a-4c73-b416-2c5d05517175	9FEBA6D62578C5676CC25B73F410892E	01	2025-09-16 12:02:55.66401-04
ACCESS_20250917010255_00000528	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	24217f78-6293-45d9-8d88-9a2e8dfeaa65	77BBB51532D675E2FB895BC617F65763	01	2025-09-16 12:02:55.670527-04
ACCESS_20250917010255_00000529	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	c801272d-af9f-47ba-92a4-1aa42bb716be	A199194725F2D09FFCF5E1956E6E76DC	01	2025-09-16 12:02:55.697717-04
ACCESS_20250917010404_00000530	system	GET	/api/v1/ref/customers/validate/SNNC	고객사 관리 - ID 중복체크	10.42.0.1	01cfd13a-faeb-42cf-82ae-503c761a1dbe	094FB9CECB9BFE8334608BE45248C311	01	2025-09-16 12:04:04.71395-04
ACCESS_20250917010406_00000531	system	GET	/api/v1/ref/customers/unique-info/cuid	고객사 관리 - 고유정보 생성	10.42.0.1	eab52ad1-9418-482f-901d-4293a92b09be	CC202C8DFDB1380416AB7301989B7557	01	2025-09-16 12:04:06.916894-04
ACCESS_20250917010409_00000532	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	a6dc7fee-c739-4777-a86a-a8f67d4a007a	8693433A8F9F3831E204C8F22600BB9F	01	2025-09-16 12:04:09.347317-04
ACCESS_20250917010410_00000533	system	GET	/api/v1/ref/customers/unique-info/ap	고객사 관리 - 고유정보 생성	10.42.0.1	ef203772-879c-4fae-90dd-f9b0b5353c7b	09A160921C0399DEC5D680E85574081D	01	2025-09-16 12:04:10.526621-04
ACCESS_20250917010411_00000534	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	54ccbf6d-ce9d-431a-ab35-4dcf64dc6469	92251798FD22DF31F256CD6EAE5FC3FF	01	2025-09-16 12:04:11.785506-04
ACCESS_20250917010413_00000535	system	GET	/api/v1/ref/customers/unique-info/mk	고객사 관리 - 고유정보 생성	10.42.0.1	c540e5f3-9aad-4c1e-b4b7-d5d69301d683	30AF805B619415D772053205E9FF21E7	01	2025-09-16 12:04:13.125369-04
ACCESS_20250917010413_00000536	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	2548fabd-5eaa-4d3d-a443-c279c1d780f1	9E099C65269FCD75353D41160F70B32B	01	2025-09-16 12:04:13.744275-04
ACCESS_20250917010417_00000537	system	POST	/api/v1/ref/customers	고객사 관리 - 등록	10.42.0.1	3d5ef616-579e-430c-80e6-21b68751d373	099FC67DAFE226CE548A6E6B672F9986	01	2025-09-16 12:04:17.003303-04
ACCESS_20250917010417_00000538	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	44180ca5-d621-42ca-8f49-fd5a11a30f02	3AB405F0CFE02A9E676FC2E2CB4F1A56	01	2025-09-16 12:04:17.01215-04
ACCESS_20250917010417_00000539	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	0b39664a-5b9c-4603-be31-4eab26a50aaf	6FD600C83EE54140031B2E8B2DB3EA36	01	2025-09-16 12:04:17.034906-04
ACCESS_20250917010436_00000540	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	49fae855-3903-481e-b6dc-f3c3b3d6fd54	71E325D1E1FB2A7D91F1202843F57DBF	01	2025-09-16 12:04:36.993442-04
ACCESS_20250917010436_00000541	system	PUT	/api/v1/ref/customers/SNNC	고객사 관리 - 수정	10.42.0.1	402be895-6691-476c-84b7-396d09c470cb	71E325D1E1FB2A7D91F1202843F57DBF	01	2025-09-16 12:04:36.995392-04
ACCESS_20250917010437_00000542	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	03cd4064-c6ce-4697-9b6b-fc5176ffc5a0	2905779D299E8CDDE39042391D33330C	01	2025-09-16 12:04:37.025181-04
ACCESS_20250917010522_00000543	system	GET	/api/v1/ref/customers/validate/GlobalJW	고객사 관리 - ID 중복체크	10.42.0.1	ae38a340-4446-4c69-bbbc-4f8e14f622d4	FDDC8D5DCA8D361EE4D9E2BD52B9A93C	01	2025-09-16 12:05:22.154432-04
ACCESS_20250917010548_00000544	system	GET	/api/v1/ref/customers/unique-info/cuid	고객사 관리 - 고유정보 생성	10.42.0.1	70e7f8c7-17ab-4446-a253-2ef1884992b6	6A100E3FCE8CC0F42115227FDF400A05	01	2025-09-16 12:05:48.864343-04
ACCESS_20250917010550_00000545	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	04cf41e3-8960-4ca9-9ebd-41d345cd77eb	6D89CCC57B9B7E5534AC913F8F3CCCA0	01	2025-09-16 12:05:50.251515-04
ACCESS_20250917010551_00000546	system	GET	/api/v1/ref/customers/unique-info/ap	고객사 관리 - 고유정보 생성	10.42.0.1	c278e5ee-6926-4736-873e-2079d179e176	8F7C9DABB16A5F138C20DEFDBF2AFA7F	01	2025-09-16 12:05:51.483442-04
ACCESS_20250917010552_00000547	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	a975f85c-9c29-4760-868b-86ea0a535941	1F8364EAE4052B83732F9C15429A4F05	01	2025-09-16 12:05:52.209057-04
ACCESS_20250917010553_00000548	system	GET	/api/v1/ref/customers/unique-info/mk	고객사 관리 - 고유정보 생성	10.42.0.1	05535e64-26d7-4075-afcb-6a240e95af41	A49635E098BDB97F0E2D8B583A130E9F	01	2025-09-16 12:05:53.906858-04
ACCESS_20250917010554_00000549	system	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	5fae40ca-ac95-4868-b3a0-cebd76674039	AB2522C59E31C985A22874E15F76534A	01	2025-09-16 12:05:54.552453-04
ACCESS_20250917010556_00000550	system	POST	/api/v1/ref/customers	고객사 관리 - 등록	10.42.0.1	161bc1f9-4d87-415b-bc85-b4cdc697eee6	CD202871893A66D0AD5B98FBB53A18DA	01	2025-09-16 12:05:56.215969-04
ACCESS_20250917010556_00000551	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	2d2dc427-0c06-432b-b606-53b454dbeeee	340A3BB9FBF4CBBC83EAE391276A5DCB	01	2025-09-16 12:05:56.242704-04
ACCESS_20250917010556_00000552	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	500eeff8-2cf2-49fa-af18-4914b35d69df	853EF88E8F80BBF2167137A840D80BA3	01	2025-09-16 12:05:56.262467-04
ACCESS_20250917010609_00000553	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	f9829320-2b4a-43ce-aa1d-7e46a20d5124	B843C29B048A20E5D8C8470E5818D716	01	2025-09-16 12:06:09.792023-04
ACCESS_20250917010620_00000554	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	2b76af9d-223c-4fb9-8421-d919476732bf	1B30B21CCB21127C7CC66807E535894D	01	2025-09-16 12:06:20.440821-04
ACCESS_20250917010626_00000555	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	4e2c8c15-74fd-4cc1-b538-949a19ad0422	2A1928AEE712545493A55A0AC5CD02E9	01	2025-09-16 12:06:26.915962-04
ACCESS_20250917010628_00000556	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	03b373af-16e3-4e7f-90be-f0dd1eb2ad7f	8FB9DFFF8BD8EF1892F888BFE2EC1172	01	2025-09-16 12:06:28.629778-04
ACCESS_20250917010631_00000557	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	099703e1-4918-4404-92d2-499151ee247c	F4413BB6C844EE2F9B30272262C4A6FE	01	2025-09-16 12:06:31.450221-04
ACCESS_20250917010632_00000558	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	f4ef7d9c-078a-47f3-80e2-718a3a59543c	69AE00AAFCF6AA3E6DFA18153AD4716E	01	2025-09-16 12:06:32.36506-04
ACCESS_20250917010634_00000559	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	1a0bd180-0ccb-4cfe-835d-a5d33f8d95bb	A24E67EF2458BF4B676BDD960EE03714	01	2025-09-16 12:06:34.265797-04
ACCESS_20250917010638_00000560	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	629d56c7-248a-4247-882a-15788db18a7a	E722E3BF5A3856B7E5EE48A467710B42	01	2025-09-16 12:06:38.89547-04
ACCESS_20250917010640_00000561	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	dd6b882c-63e1-4c2a-9704-eb6e028687b1	B09FDCB27AE6554E446FAA3C21624058	01	2025-09-16 12:06:40.768756-04
ACCESS_20250917010642_00000562	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	18ef2237-565e-46b8-8d34-29e8e589cb70	A21E7FEF1B8E2934B0DA16B4F8CB5A93	01	2025-09-16 12:06:42.878532-04
ACCESS_20250917010701_00000563	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	378f2cf5-1e53-4b06-b702-5d2120c9b8a5	2A5014D3379D24DB9C56D5CF999CEC22	01	2025-09-16 12:07:01.303444-04
ACCESS_20250917010703_00000564	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	170ac54f-21bc-41ff-bc27-185bdd340ee0	25A2BA4487253BCE19F30ACD47D0FDAE	01	2025-09-16 12:07:03.255324-04
ACCESS_20250917010705_00000565	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	66223180-b65c-4e30-8cfd-ff70f18b4664	0412C3D9B208BCED6BFCCA9789D1B0DE	01	2025-09-16 12:07:05.594475-04
ACCESS_20250917010707_00000566	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	2c759223-b7c8-4015-90d2-418659470b2e	E1A1EED1498D80C3B5FA4A0A75270D21	01	2025-09-16 12:07:07.677798-04
ACCESS_20250917010715_00000567	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	3eef7c4b-2671-40bb-971e-3d914bbe132b	2C52818D80B3A5DE97FBDF04764F2658	01	2025-09-16 12:07:15.566764-04
ACCESS_20250917010718_00000568	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	6947bc0b-6dbf-46f5-b16c-6ab87a599811	1DF6EF4030EA6A84B4BE7C62ADBD7415	01	2025-09-16 12:07:18.99005-04
ACCESS_20250917010720_00000569	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	0da789dd-ef00-4240-97ee-1a0e6c4b8836	18667F7EA282E5EED0DAE60432F0ECFE	01	2025-09-16 12:07:20.334333-04
ACCESS_20250917010722_00000570	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	c592a393-aa7a-4011-9882-df5464a7085b	550657B8F038FC82566F653E6E5C4FBE	01	2025-09-16 12:07:22.163866-04
ACCESS_20250917010724_00000571	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	3e76ba22-4d84-4af3-9ca4-f9509fa94b2d	DA70A98D570D56E8523120171477632A	01	2025-09-16 12:07:24.984361-04
ACCESS_20250917010727_00000572	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	6b85f492-3d09-430b-ba64-16efee93aeef	40E295E5EFF36DFDF5800884442091F9	01	2025-09-16 12:07:27.85963-04
ACCESS_20250917010729_00000573	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	54df64b3-145f-442b-91dd-15bb924ca9d0	AFAF01ABC62E1704A7D74AAA1E7E1875	01	2025-09-16 12:07:29.93413-04
ACCESS_20250917010825_00000574	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	83920c1f-0a8f-4968-b1b0-850648ddd7cf	03D2708E6D7F1326141B0C38483329E8	01	2025-09-16 12:08:25.99525-04
ACCESS_20250917011009_00000575	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	15230eb3-c76f-4060-b1a5-4b286fb08e98	AB35F8020BB4CE470BC552BE486C9EDC	01	2025-09-16 12:10:09.433189-04
ACCESS_20250917011009_00000576	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	46c723a4-6b96-4a8e-a48e-10c6ce6c5ec9	E6206481CE1C710B6F078C1B5680C3B0	01	2025-09-16 12:10:09.485118-04
ACCESS_20250917011936_00000577	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	edff1341-666b-430e-bc01-a27c95c7188a	15F6F403959C15CFE0AF383D5A82F59B	01	2025-09-16 12:19:36.087175-04
ACCESS_20250917011936_00000578	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	ddc3f5d4-51bd-4937-bf53-59aee232886f	D4585E3DF2C0E3CDCD1C2405AD1484B2	01	2025-09-16 12:19:36.137988-04
ACCESS_20250917012038_00000579	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	a9854247-832e-4e73-aa36-4c65f691e1e1	402E76450C5C85281A9F571267E51629	01	2025-09-16 12:20:38.017415-04
ACCESS_20250917012038_00000580	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	7697e5fe-bdca-4051-8bea-bb4bc795f9f3	A0417AAA8FD77499A99A167CB520E24A	01	2025-09-16 12:20:38.069989-04
ACCESS_20250917012114_00000581	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	0aa3bd25-1162-4d3b-a0cc-aa0293f306f1	7E6C88A2A1B65DC6324A08BFEBC446DB	01	2025-09-16 12:21:14.674209-04
ACCESS_20250917012114_00000582	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	32dce113-5495-4b77-b416-dede2a1fb31d	9BAE8EA062C491447FF88E64C8401262	01	2025-09-16 12:21:14.726991-04
ACCESS_20250917012148_00000583	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	2887b6f3-1e18-40ef-8548-da8422987158	2C244A71864041CAA9139DAC2CFC36E8	01	2025-09-16 12:21:48.504727-04
ACCESS_20250917012148_00000584	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	26e4390c-077a-4b64-8000-6915e4bef3f9	0035DE3C16A6D8717277A181369B13EA	01	2025-09-16 12:21:48.58158-04
ACCESS_20250917012212_00000585	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	0d3c5409-f404-4354-8677-c4136ed07f30	325BAFDC4F3A7004BEF8B239706299DB	01	2025-09-16 12:22:12.353871-04
ACCESS_20250917012212_00000586	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	13b2b59e-2beb-4c26-bb9b-e4bea345dab9	DAB76DE8668BE755CC1CE735598D42AB	01	2025-09-16 12:22:12.404948-04
ACCESS_20250917012226_00000587	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	c7c49feb-8318-4010-9c3f-b3e77a895f60	D5DDB96AFB3243EE054535D93D20DB71	01	2025-09-16 12:22:26.720347-04
ACCESS_20250917012226_00000588	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	f22dbb72-ffce-4621-8765-9b2ec5ececfe	811B415A2DF6617DD209772C12F4FC99	01	2025-09-16 12:22:26.749221-04
ACCESS_20250917012402_00000589	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	98649ec8-ae3b-43ed-aafc-320330d45d28	143AFBC2014B8B9100DE3FC78CABD4E6	01	2025-09-16 12:24:02.739922-04
ACCESS_20250917012402_00000590	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	21b2d5c8-2317-482f-a2f5-4cda15df44e7	5DB5C90468AA88405E24A2D636DB5046	01	2025-09-16 12:24:02.794883-04
ACCESS_20250917012519_00000591	system	POST	/api/v1/ref/lockmodel	락모델 관리 - 락모델 추가	10.42.0.1	c0caa4c7-1161-4076-a23f-472d0b831d04	0863685757F966B66CF1BFD0CB966B97	01	2025-09-16 12:25:19.108028-04
ACCESS_20250917012519_00000592	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	437dda69-953f-4033-b302-bd51469b878f	CCFFDC4D2DD2EC89392F03C7517F3DC8	01	2025-09-16 12:25:19.161825-04
ACCESS_20250917012528_00000593	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	d241f769-2a37-4a9e-8d59-4f143c957178	DF0077BD5536BDFBF268D7EE32C984D2	01	2025-09-16 12:25:28.729094-04
ACCESS_20250917012534_00000594	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	0d9d0eac-60e7-403d-b9ce-0ddf7494d74c	311AD501C80FD3ADEFED375E35FB0946	01	2025-09-16 12:25:34.990264-04
ACCESS_20250917012537_00000595	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	2b7b38e4-ce36-4145-a174-8d5e2d9dd26d	3BC15C2DCDB042A07FE0D3C8AAA6BDFF	01	2025-09-16 12:25:37.425212-04
ACCESS_20250917012852_00000596	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	23b4531c-00f0-4b8d-81e0-121649aa07fa	61BB8C8628A7C9F28E74B1CD47ECD0A5	01	2025-09-16 12:28:52.593021-04
ACCESS_20250917012857_00000597	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	6db530e0-8f52-480d-b692-ded07f0ad6ed	8ED04BC271BBB1545990892C8F82FAA8	01	2025-09-16 12:28:57.847497-04
ACCESS_20250917012900_00000598	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	56e28b45-c2f0-41d0-a9da-fedc8f7be8c3	14CC5ABE9A16348830BCCEEF586B5273	01	2025-09-16 12:29:00.973091-04
ACCESS_20250917012932_00000599	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5a2f76a6-f672-40f9-9321-375dbfc27dff	99A9134870954DEC58C496730442A75B	01	2025-09-16 12:29:32.717952-04
ACCESS_20250917012941_00000600	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	92c9e3f7-f8ed-4811-9462-0f22eefba135	F28A5F0E75D7A259EE1936B016E74CDD	01	2025-09-16 12:29:41.754459-04
ACCESS_20250917013153_00000601	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	c2254eab-15c2-426e-97d2-04b0e9743e95	BD9067F8CBA637BC7D53C672E8909ED6	01	2025-09-16 12:31:53.208823-04
ACCESS_20250917013644_00000602	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	923a4364-270a-4677-8d29-8b169554661c	367D2B434077A3E81061B1DC51E08E5A	01	2025-09-16 12:36:44.220604-04
ACCESS_20250917013723_00000603	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	5524e383-f8ae-4209-8078-b3de7157201c	6B577C296C78320F155228A43CA3B403	01	2025-09-16 12:37:23.037713-04
ACCESS_20250917013744_00000604	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	5078aa37-5bfe-4661-8136-14220f07eff1	8D7DA51C4E70F2394931D75678B92514	01	2025-09-16 12:37:44.868649-04
ACCESS_20250917013851_00000605	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	5f3a6931-3342-4460-bfde-2d43c783c742	6A0DB0FDEDD5FD639D1C273E4DEA8B7E	01	2025-09-16 12:38:51.057854-04
ACCESS_20250917013855_00000606	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	d4f05750-a7b0-47d6-95df-2c53157e8275	810187907A025A48966BB78BACAD2AB9	01	2025-09-16 12:38:55.440427-04
ACCESS_20250917013910_00000607	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	1f5fc68e-7199-4c82-b07a-27c3f16be4e7	4DEF94B48D7BD63C5FB02676D8DCC183	01	2025-09-16 12:39:10.340846-04
ACCESS_20250917013918_00000608	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	04c2fa43-8904-494c-a8f0-f213dc4bd51b	961FFD585AF69F01FFCC0FE47BB9F16E	01	2025-09-16 12:39:18.847667-04
ACCESS_20250917013926_00000609	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	72f133ce-b011-4057-84cd-c01a61a074bc	CB9BF388D64B3F051C6D2DF268461711	01	2025-09-16 12:39:26.965079-04
ACCESS_20250917013933_00000610	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	9107e070-b6d9-48d1-b69a-896042d9bc47	C7B58A848499CAFC72D852097660A065	01	2025-09-16 12:39:33.625252-04
ACCESS_20250917013943_00000611	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	d6e6b753-1dba-41dc-94f4-0fde96adf98a	5E5294B807F7580C472328FB83BD9662	01	2025-09-16 12:39:43.782003-04
ACCESS_20250917013955_00000612	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	b1d6af82-62e9-4a7e-a0b0-0101e7a7e91c	11F150B92DF8C07F37C7804C4BC32F89	01	2025-09-16 12:39:55.852182-04
ACCESS_20250917014003_00000613	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	c47f5f8e-a22e-4b86-b4ad-14bc0f9e781a	22121961192061420667EA219F872A85	01	2025-09-16 12:40:03.71742-04
ACCESS_20250917014012_00000614	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	3c6ab662-7799-4aa5-a820-d6c5da94bfc7	73411DA1A6891514EF498D22037AF771	01	2025-09-16 12:40:12.623597-04
ACCESS_20250917014022_00000615	system	PUT	/api/v1/incoming/slock/config/1	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	9cbcff76-d056-4239-bf73-9644a0c2cfce	89B7295458F87C19FE07E9BB580B422B	01	2025-09-16 12:40:22.293557-04
ACCESS_20250917014030_00000616	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	7a09c4f8-504e-4ac2-8c28-7e51372437c8	74832169BD2F1E63BBFF9B0D94529A49	01	2025-09-16 12:40:30.164827-04
ACCESS_20250917014042_00000617	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	fc49c715-cefb-4499-b907-3e2a90552928	A53A2634BF34AA0B58F00126B1D6F378	01	2025-09-16 12:40:42.949346-04
ACCESS_20250917014051_00000618	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	deeb4fa1-5281-4af9-acfc-fc68cffbacbf	9CEE452B7C7F16D5DA31E067A1832CC7	01	2025-09-16 12:40:51.922309-04
ACCESS_20250917014059_00000619	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	264eaedb-147f-445b-b500-e8abd6bb4355	024ACBCD1B66327A6807B043F124BB1E	01	2025-09-16 12:40:59.866988-04
ACCESS_20250917014109_00000620	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	3bd1b14b-f1c7-401a-82d4-09db7989b125	25E9E1490FBDED5371A2CA08DFE13399	01	2025-09-16 12:41:09.649231-04
ACCESS_20250917014121_00000621	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	360cb1d9-270b-469d-aba8-fcc6a178c115	877D834E594791465F01FBE87828238E	01	2025-09-16 12:41:21.725362-04
ACCESS_20250917014312_00000622	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	62ca8e60-5612-486b-a300-f9f6d7043d05	E52C16D0230B94822F40D73EB9FD1114	01	2025-09-16 12:43:12.522444-04
ACCESS_20250917014321_00000623	system	PUT	/api/v1/incoming/slock/config/1	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	ad128717-1f73-4378-8329-65b5a14ed18c	6BEA82102E65D8AD119B8A4F1D076291	01	2025-09-16 12:43:21.443898-04
ACCESS_20250917014327_00000624	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	761e86b4-7846-4ba3-994e-cb241e6ea227	D0CC87F8C989836E93501A623FC7B8E2	01	2025-09-16 12:43:27.108181-04
ACCESS_20250917014341_00000625	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	0b5ae3e3-ed5f-4417-b112-a4dc8e2a106e	AC25F3534680E44D5956679F3E185E01	01	2025-09-16 12:43:41.758875-04
ACCESS_20250917014537_00000626	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	6ed4a7a5-ce4d-4e9c-a776-c2a5cfdad986	B2AB7B76D5272A2E3FCEF471F626D0F7	01	2025-09-16 12:45:37.913334-04
ACCESS_20250917014554_00000627	system	PUT	/api/v1/incoming/slock/config/1	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	6155b6c3-1d71-43e8-b899-a6a4048fa8fa	D6807A4CD97BAE2E71AB09E3A16A6C4F	01	2025-09-16 12:45:54.323828-04
ACCESS_20250917014604_00000628	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	3166a8ae-b1e0-497a-a8b0-f27e52b5ce15	DCF61CC239180BAD0A2DF12399504A5B	01	2025-09-16 12:46:04.148777-04
ACCESS_20250917014634_00000629	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	add77a0d-a072-440e-b916-367da2a13073	F2010DF97DAF530023703C0CE47538D8	01	2025-09-16 12:46:34.510425-04
ACCESS_20250917014640_00000630	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	664dfa4f-b4d1-4d9f-bd14-7a109e98c591	05D0084065B882B48C46642499BE3DD9	01	2025-09-16 12:46:40.779725-04
ACCESS_20250917014647_00000631	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	e3ea6c26-7c8e-4a16-b5d1-51473fe92499	D44051D8F2779B1DAE02764E89A5FC74	01	2025-09-16 12:46:47.716969-04
ACCESS_20250917014705_00000632	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	20e53db3-b832-48c0-af63-e8512de31810	62CE072B71F3B638E2B6F69A9419937D	01	2025-09-16 12:47:05.349036-04
ACCESS_20250917014723_00000633	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	b0599432-bc7b-485c-adb4-b1a09466ef44	DEE0791EB52CF3DF91B00221AD4EC3FF	01	2025-09-16 12:47:23.787056-04
ACCESS_20250917014723_00000634	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	3dbbc228-ea34-4a70-92ad-be034e699b86	E713A79B779DC547484D1866961A4595	01	2025-09-16 12:47:23.822736-04
ACCESS_20250918102357_00000635	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	e603e762-7277-494f-aa3d-b6069a26f0c6	87CDA26A33AA02729E1241E20F166E9F	01	2025-09-17 21:23:57.962165-04
ACCESS_20250918102357_00000636	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	8639be58-07d4-4c91-8e84-0d52918acd63	DC2414C31A687D6AA9767D344C00B597	01	2025-09-17 21:23:57.962968-04
ACCESS_20250918113029_00000674	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	a9dd0f94-cc91-45ba-aeda-d653561cf921	0DFFBCB1432AE111490A8E05A4D6CCD8	01	2025-09-17 22:30:29.149948-04
ACCESS_20250918102404_00000637	system	GET	/api/v1/home/dashboard/products/models/9	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	f5e0a598-6b15-4fdb-aac6-9e8e22a2ab03	AC3DACD6871472C8DA90C4C442FBC4E7	01	2025-09-17 21:24:04.342821-04
ACCESS_20250918102411_00000638	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	d5b03011-3a7e-407e-bd34-c8de610c524a	D445ECBAE100DF52E4D1D3A3F641C410	01	2025-09-17 21:24:11.550199-04
ACCESS_20250918102531_00000639	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	88869f3e-e241-4312-af02-57866095d231	62B07C8C8F114DA450202C9532A199A9	01	2025-09-17 21:25:31.793532-04
ACCESS_20250918102613_00000640	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	877443a4-be08-47c1-9a31-b7111aea79db	D3FE5AC202A1A60780A645992DCFCEA0	01	2025-09-17 21:26:13.724015-04
ACCESS_20250918103049_00000641	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	3e39a395-fc34-4a3b-b3f0-97b762ae0a90	A4567A8AF41D3417BB9A8AB7F237B8D5	01	2025-09-17 21:30:49.690748-04
ACCESS_20250918103049_00000642	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	3eb18e6d-de7f-459e-a507-330bac93580c	F834A794C174E9774A542CCA66FB5100	01	2025-09-17 21:30:49.746692-04
ACCESS_20250918103125_00000643	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	5cf020c2-1098-4f2a-8d26-7263aa929440	ECF1A6C1A35E7F9B67652DD94CFE9AC1	01	2025-09-17 21:31:25.710011-04
ACCESS_20250918103152_00000644	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	2452bc02-1338-4282-b0d4-19c5185bdec4	3F9E78BE5F251E30E58B55B7BD91AA7A	01	2025-09-17 21:31:52.491646-04
ACCESS_20250918103155_00000645	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	fd86467b-d855-497b-9d01-c9b2a05f5ab5	F1283131D23514E154B195F267429847	01	2025-09-17 21:31:55.908067-04
ACCESS_20250918103204_00000646	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	e719aedf-7b31-445f-ac03-c8948ceee346	8E721C545B36F1EB4D3CAFD73F3F18E4	01	2025-09-17 21:32:04.429241-04
ACCESS_20250918103230_00000647	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	827aefff-0238-40ad-9e76-aa2d8a51b85b	96C76D48EAF7F7691528B4CB24C088A3	01	2025-09-17 21:32:30.463199-04
ACCESS_20250918103406_00000648	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	8460bc00-dc17-4d42-9fcc-9bb40e4df6c6	20FC5A7D0FC791D421F8C2A2A7403A26	01	2025-09-17 21:34:06.132619-04
ACCESS_20250918103409_00000649	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	e93dd19f-c9b8-47cc-8b66-b0214ebef3c9	F5FE849A2F45E4CB08F9243C69D65847	01	2025-09-17 21:34:09.171929-04
ACCESS_20250918103416_00000650	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	62e00d8e-e2b9-496c-9249-fb9cb7ff059e	1FC18621C2EADD6878814232EFC7C64C	01	2025-09-17 21:34:16.124961-04
ACCESS_20250918103657_00000651	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	54de76ec-650e-4fbe-bd0e-d7ff7d9e8212	28EC4E3CDBABF77CD5C60D1B3BDD8293	01	2025-09-17 21:36:57.790606-04
ACCESS_20250918103700_00000652	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	64740ab1-4e92-457e-b51c-1d7c87ebc0af	1DB4EB3F8050BFC9B33768AF1AB5FD32	01	2025-09-17 21:37:00.757231-04
ACCESS_20250918103704_00000653	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	2f82610b-d2e4-40bb-a9a0-8c92324926a7	2CD599C2941AB745961CF293C8929C5E	01	2025-09-17 21:37:04.857798-04
ACCESS_20250918103814_00000654	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	fda71d9a-9fc8-4ffd-a6ac-f37a0c5bbbda	E03D843A92C17F5C09FF18831190F015	01	2025-09-17 21:38:14.832535-04
ACCESS_20250918103817_00000655	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	1d342fde-7be5-4089-97bc-2c203ad2c4e7	7A45A888CBA6E65320409A138643EF06	01	2025-09-17 21:38:17.882597-04
ACCESS_20250918104116_00000656	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	7e93f6e6-3f51-471b-a4fd-31f449bd030b	BA81D56FA9F0552FA00608D991256A43	01	2025-09-17 21:41:16.6329-04
ACCESS_20250918104125_00000657	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	029ef637-6826-4155-8ae0-c8bb8bb80574	FD462101FD8BA4453D4BD295B4167BE9	01	2025-09-17 21:41:25.211384-04
ACCESS_20250918104125_00000658	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	7beb0e3f-45e0-4909-80bd-ce92407615c5	3BBEAB2953E3B78C852D440F8C5276BA	01	2025-09-17 21:41:25.270279-04
ACCESS_20250918104140_00000659	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	e3b51c79-49af-4ddd-8dde-a3c3e58d26ad	E6CE1AADEA67CB0345F65ECE430394AC	01	2025-09-17 21:41:40.147049-04
ACCESS_20250918104202_00000660	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	981ba8fa-6ae1-4b4d-a16b-67f695556811	5B45019306D11BB066AFF60A4AFE7E51	01	2025-09-17 21:42:02.17801-04
ACCESS_20250918104202_00000661	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	f01710a3-b53b-4f69-9f48-10895b890df8	FAAE200278016DA6E87FB4A711487C94	01	2025-09-17 21:42:02.219849-04
ACCESS_20250918104209_00000662	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	3f17d9ba-dc6c-4522-ba20-3d19ab936711	FF02221298A0F496B9ED3BD91939C2E2	01	2025-09-17 21:42:09.309417-04
ACCESS_20250918104217_00000663	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	3b492b44-e16b-4392-b0c9-2c1e5bd10eeb	E534B67991B81C010836F2794F5A332E	01	2025-09-17 21:42:17.203444-04
ACCESS_20250918110720_00000664	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	7d86d8df-58d2-4df7-8267-f19d224d2e6c	11DC077F8987FF4853BB00B31DF50795	01	2025-09-17 22:07:20.375004-04
ACCESS_20250918110720_00000665	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	e2f10807-cd3b-4521-a8ef-8fe145d1071b	D89BE72CA14B5990C81F0ECBE16035BB	01	2025-09-17 22:07:20.376776-04
ACCESS_20250918110722_00000666	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	c280fceb-ad05-4315-9fb8-5454e08debbc	007088E1037295AD00573ED686A09229	01	2025-09-17 22:07:22.996741-04
ACCESS_20250918110730_00000667	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	f1cab10b-b9e7-4039-81e5-e4fe197e17f6	2AD99666152FE9254ADA0343EED7CCA6	01	2025-09-17 22:07:30.227312-04
ACCESS_20250918110730_00000668	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	296e1118-1945-4309-a3e4-3fb33e8fefad	850E5319016AC7877039469971F3F989	01	2025-09-17 22:07:30.30255-04
ACCESS_20250918110736_00000669	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	a85fc1be-60c8-4c11-ad2c-29ab460bfb90	B5B3A8BE8CED164BCE3C2D9B99248E9E	01	2025-09-17 22:07:36.580484-04
ACCESS_20250918110801_00000670	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	bb128557-b075-41b1-a751-f79847a6823c	0A7EE214065748F36AA2D71B37D87353	01	2025-09-17 22:08:01.741125-04
ACCESS_20250918171948_00001246	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	f9d05335-a3c9-4eba-adde-9477424f3329	1CFD6461D0CC7D93A2B07A0C241F0515	01	2025-09-18 04:19:48.354843-04
ACCESS_20250918113021_00000672	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	e7752c6f-286e-4d02-8a1a-ccf7a0bf5726	AD525D0724798ECBDE1DA808715DA711	01	2025-09-17 22:30:21.432131-04
ACCESS_20250918113021_00000673	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	c79b88ef-21d4-41ef-9a79-a243902fbfb3	56AF8CF318873111E2D0875E413135B2	01	2025-09-17 22:30:21.432131-04
ACCESS_20250918113426_00000675	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	b2d5c733-a3c8-48be-8f09-e96bb86dfae8	6594D662503FBD16996ABBE26A1FE7DB	01	2025-09-17 22:34:26.245297-04
ACCESS_20250918113439_00000676	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	39bc8970-5581-4545-92d2-56ccb59abdf0	34A40A6070DA870EAC3A8CD259A425C3	01	2025-09-17 22:34:39.52133-04
ACCESS_20250918113447_00000677	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	5e265d1b-1e9f-4e7f-9b81-f114f8979175	6C441BADE5BB6F8B4CEC08809CE9EF9E	01	2025-09-17 22:34:47.45186-04
ACCESS_20250918113451_00000678	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	d5009ca6-387f-43fe-af0f-b0a2e996e56e	BE4FD2521ED33822974EF6F3BD4A0275	01	2025-09-17 22:34:51.876932-04
ACCESS_20250918113452_00000679	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	bd737a17-37cc-44c9-8a38-4893145f990c	6FDAEC6D9EA9832C1B0C03ECB156E8D7	01	2025-09-17 22:34:52.654518-04
ACCESS_20250918113550_00000680	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	6f6ac176-d910-49ac-8676-07ed4895e72a	D7CF30BB19652BC60A02B5A62BDBB909	01	2025-09-17 22:35:50.26523-04
ACCESS_20250918113550_00000681	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	89ab8854-1844-446e-917c-d010b843eba9	5845B34949A9ACAE7AEEC3CCFC4EEF90	01	2025-09-17 22:35:50.326339-04
ACCESS_20250918113550_00000682	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	76ab0fca-7d49-40ae-aabc-741d00d3b682	2845B1FC130CB22490634ABF8650E949	01	2025-09-17 22:35:50.84023-04
ACCESS_20250918113551_00000683	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	17b31570-ab79-4c96-a71c-193a418b8f24	351BA087AF52FB5C309614C4B0FC32CB	01	2025-09-17 22:35:51.382014-04
ACCESS_20250918113552_00000684	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	1a76fd83-f5ec-4235-843e-160ed50e74e7	AF038F81FCBF4E09FBBED71E7D29103A	01	2025-09-17 22:35:52.144905-04
ACCESS_20250918113552_00000685	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	19265355-455b-43f4-8a18-d0523d32c9cc	CAB4A5B5FDBB3A88BCC72FCA493E623A	01	2025-09-17 22:35:52.559949-04
ACCESS_20250918113553_00000686	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	7769178d-2828-453b-935b-abe951052f28	6967E0FE115B31AB0AB4041086B2462B	01	2025-09-17 22:35:53.163982-04
ACCESS_20250918113554_00000687	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	9b3b8ed4-d1c5-4807-a2ed-f496ca4c3822	AD34374C034AE58AED4762D6DF417EA4	01	2025-09-17 22:35:54.270371-04
ACCESS_20250918115656_00000688	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	159d7b87-04ce-4893-8b99-8ff6b8b82f44	E41F50DFBE437B51B8D62F675CB7CBCE	01	2025-09-17 22:56:56.076234-04
ACCESS_20250918115656_00000689	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	f4482b5e-0da5-4d5d-b405-8fb99c979a60	12D62006B093A3DF186D09ACD49CF495	01	2025-09-17 22:56:56.076231-04
ACCESS_20250918115700_00000690	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	a81a744c-91da-4285-bc8a-085cc24761bb	6FC72A477B37BE6F27441B712C28E7AE	01	2025-09-17 22:57:00.538313-04
ACCESS_20250918115700_00000691	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	d63657c1-ed20-45a7-bb17-c5001d7051db	7736475436869DC3E6775B79B4EDCDF4	01	2025-09-17 22:57:00.570078-04
ACCESS_20250918115703_00000692	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	21904b17-a3ee-4f41-a3be-2fc12e77448b	9ACC25B5164576444A327B0CF026EC45	01	2025-09-17 22:57:03.736466-04
ACCESS_20250918115713_00000693	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	4778fe75-e173-41b8-9419-6e28087c9751	C08F17E4DF465645B00AC4028BBBB857	01	2025-09-17 22:57:13.112093-04
ACCESS_20250918115718_00000694	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	eb1939df-82a4-4c5f-8135-8e29c6c17f8f	E6BF3F6065E584D3477011C71668E5AB	01	2025-09-17 22:57:18.389083-04
ACCESS_20250918115752_00000695	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	f1b893e2-7ce7-414f-9638-1dd68211eff5	3959D367ADF17BF58A9C2E7E05443BD5	01	2025-09-17 22:57:52.15394-04
ACCESS_20250918115752_00000696	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	e3378d94-9a81-40c5-8d13-ba9db855a5f7	63CC4443C46B47AC40F9650F06F60091	01	2025-09-17 22:57:52.181185-04
ACCESS_20250918115752_00000697	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	4cc50cd2-7e3d-4777-825a-7aac43ba9ab9	E06FB48436096B0DFE6513B6250914B7	01	2025-09-17 22:57:52.207802-04
ACCESS_20250918115753_00000698	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	32cd9e6a-11d0-4060-8d0f-6ecb086823d2	A9CF2D495AFF4E625208BD7D7FDD54B6	01	2025-09-17 22:57:53.254104-04
ACCESS_20250918115804_00000699	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	ab45cc82-5ee1-4f7f-88d0-d6b07b0f2697	2E580EA17126EE8ED2FFF98F52BADF3C	01	2025-09-17 22:58:04.532358-04
ACCESS_20250918115804_00000700	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	39e351e1-a6b1-4774-adb1-fbcd50e0a29a	4F34046CADD6695377F0C3EFC933C17C	01	2025-09-17 22:58:04.563307-04
ACCESS_20250918115804_00000701	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	bd5d0a62-3f52-43fd-9926-7be13b3e69a5	FBF9332FC47492C0242FA8FF21D7CF90	01	2025-09-17 22:58:04.586717-04
ACCESS_20250918115805_00000702	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	b6878311-0aa8-4d67-9d03-09605c105305	FEA0D2EC9345097D81F2568775259830	01	2025-09-17 22:58:05.506965-04
ACCESS_20250918115818_00000703	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	dd1ad613-09ce-4c9e-aab8-92532cfe39c1	EC50F753E90A7B31653B8D2F58F10091	01	2025-09-17 22:58:18.155521-04
ACCESS_20250918115830_00000704	system	GET	/api/v1/ref/user/id/hckwak	사용자 관리 - 아이디 검증	10.42.0.1	5721e7e4-2ea3-4e92-8719-4bf7d3a122dd	6B3863A86A0FC2F3165F28AED1EFE0C7	01	2025-09-17 22:58:30.294867-04
ACCESS_20250918115847_00000705	system	GET	/api/v1/ref/user/email/koi.hckwak@gmail.com	사용자 관리 - 이메일 중복 확인	10.42.0.1	b6b04859-44fc-4928-a6cb-4ce910c48218	8B495DCF691559D65BA012C92008A548	01	2025-09-17 22:58:47.747437-04
ACCESS_20250918115855_00000706	system	GET	/api/v1/ref/user/mobile/01091253662	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	7f4d7e50-2c23-4752-aad9-8f68300f795f	06B0E8BFB304B50955686C6F42FE0BD6	01	2025-09-17 22:58:55.061865-04
ACCESS_20250918115923_00000707	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	9aceddaa-f025-4b8a-a295-1e3c230fb8ad	EC98D79A90A47BC7064E70F23E9D8E4A	01	2025-09-17 22:59:23.955282-04
ACCESS_20250918115924_00000708	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ba1c45a1-8e19-4be3-b0e3-1d5d5f6f42e8	198ECC587BAB81E77DB815B60291E38E	01	2025-09-17 22:59:24.029042-04
ACCESS_20250918120451_00000709	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	9ae5bdc3-0526-4648-94e2-34490c9706a3	F8F0EC2583D15A5F384D1BB3F6122016	01	2025-09-17 23:04:51.01938-04
ACCESS_20250918120454_00000711	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	acccc250-6092-4331-886b-184983b14d4c	809F02AF4A3B64F889466DC4A59DA077	01	2025-09-17 23:04:54.299383-04
ACCESS_20250918120451_00000710	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	b762aaef-8a39-47f8-9ad5-561e0becc5d3	65634F7FDB6F294001A658DB9B8BC57B	01	2025-09-17 23:04:51.019378-04
ACCESS_20250918171949_00001247	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	6c472e73-aea1-4d11-ac2c-5b125b322ff8	FE4BFC3E1B56BA043A0AA14CAEAD4494	01	2025-09-18 04:19:49.749287-04
ACCESS_20250918180120_00001326	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	4360e7fc-cad4-46b1-9182-30ebe3356f95	FB572EAC3308F6FC1900DA86D44387C3	01	2025-09-18 05:01:20.571226-04
ACCESS_20250918180127_00001327	hckwak	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	fede7303-7d09-46bd-ade6-2fde13d7b771	B4C33239C78AA1378B61CB18F0B05FB4	01	2025-09-18 05:01:27.145717-04
ACCESS_20250918180133_00001328	hckwak	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	04556e8a-12ce-4f48-a1eb-e1ea720244e8	D36B347101BC6E8511027BB76305A7DE	01	2025-09-18 05:01:33.436017-04
ACCESS_20250918180138_00001329	hckwak	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	81a37d58-de81-4cc8-ae6d-ec1543c33665	8444474B2A33971474CE17D853D59BE5	01	2025-09-18 05:01:38.526797-04
ACCESS_20250918180143_00001331	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	4499a32c-3edd-42ad-9a87-f25f0b23be18	30DF8856C9401B1444400D40204DF413	01	2025-09-18 05:01:43.904431-04
ACCESS_20250918180146_00001332	hckwak	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	7666e8c6-4521-4ef8-b65f-9689b9cce303	01BBCEE38201B7F8246503FD67E85E2D	01	2025-09-18 05:01:46.205107-04
ACCESS_20250922102836_00001394	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	04c9ad41-fd3e-47e9-af96-7900da6bff90	9D7722B2711F4CFD4EEF822A70472CE4	01	2025-09-21 21:28:36.162531-04
ACCESS_20250923173749_00001439	hckwak	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	28283d64-2bce-444d-bd37-f94eed84ff7e	3E7584ED167A71267933882596555CB1	01	2025-09-23 04:37:49.391446-04
ACCESS_20250923173749_00001440	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	6b8efec9-856a-40d2-81ad-36d96bd9a4a6	DC7C49111CA2AD6D9BAAEDF590B223D9	01	2025-09-23 04:37:49.422761-04
ACCESS_20250923173751_00001441	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	710422a2-b3a4-49c2-a62e-a7be16f36c42	27D62655064BE3E08A09B8058C9786E5	01	2025-09-23 04:37:51.43872-04
ACCESS_20250925152022_00001458	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	217a966b-a5a3-4e97-9bfe-969339249448	5B09F2715EE766764200C2F977AAEEE4	01	2025-09-25 02:20:22.817828-04
ACCESS_20250925152022_00001459	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	fda716d6-c06b-4e0b-b32b-f482c1b83d6f	98CF296076AD614E2AD537E8BAD18CD6	01	2025-09-25 02:20:22.853632-04
ACCESS_20250926163512_00001493	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1, 10.42.0.170	d53ef6d4-2f7f-4ef8-afab-39db734bf0ac	55EE33B0F5CA73E562D24F3F76945FDE	01	2025-09-26 03:35:12.068692-04
ACCESS_20250926163528_00001494	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	9f336d23-86a9-461b-9f31-b1da22d2689b	9DCEF2083D0947A81158CE6C36788621	01	2025-09-26 03:35:28.713571-04
ACCESS_20250926163534_00001495	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	95fcbc29-dcc9-4514-bdc3-439b918ab4d8	D4B6B0190ECDFAB9535C7B99B8C04C43	01	2025-09-26 03:35:34.384021-04
ACCESS_20250926163539_00001496	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	a9f3bbb4-19cb-47d9-baa9-8b85ff099d02	28F1ADEA1092B4F2316D6F108BB1036E	01	2025-09-26 03:35:39.217695-04
ACCESS_20250926163543_00001497	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	b09655f9-6ebe-4a10-9224-9c316fd0ac86	F97A029938D3803E9B8EF183B94DE991	01	2025-09-26 03:35:43.049771-04
ACCESS_20250926165045_00001544	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	a4442f60-8b60-4048-8d21-866027dc55d6	5E75715182C29F8C6420048B01B9C989	01	2025-09-26 03:50:45.422524-04
ACCESS_20250926165100_00001545	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1, 10.42.0.170	c0c472b4-029f-4ca0-9927-5540527a2602	83576D5067A5CC524951D9B00ABE06E3	01	2025-09-26 03:51:00.270094-04
ACCESS_20250926165100_00001546	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	5b1320bc-fe0c-4247-a190-b50d52d3313c	6E6374F5B97C0172055542501A888152	01	2025-09-26 03:51:00.303939-04
ACCESS_20250926165102_00001547	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	ab4468da-d0b9-4101-8d43-29ee515b1df1	2A676AADAE7B4FC5D2521E361FC97534	01	2025-09-26 03:51:02.83849-04
ACCESS_20250926165105_00001548	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	2c43bf47-9b48-40fd-a790-7ea7d21d474b	69B470998681D1F762A8261681F3212F	01	2025-09-26 03:51:05.362564-04
ACCESS_20250926170711_00001584	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	8da74650-35ca-4502-9041-52d10155d9ae	C95C51F29340F12F5E436906EAA401E8	01	2025-09-26 04:07:11.04441-04
ACCESS_20250926170716_00001585	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1, 10.42.0.170	57d5467d-13ee-4ebf-9864-48ce3c48e87e	22CDDE49AE1399A8F850A097BCD0C3D0	01	2025-09-26 04:07:16.715151-04
ACCESS_20250930150441_00001604	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	5a3d470c-e742-45a0-9d4f-eba86dbac25d	6B26FEF2B8065EC7A437A925D1218B4E	01	2025-09-30 02:04:41.975682-04
ACCESS_20250930150457_00001606	system	GET	/api/v1/home/dashboard/notices/2	대시보드 - 공지사항 상세정보 조회	10.42.0.1, 10.42.0.170	011b99ed-18c0-4307-ad44-414b2a0daa9f	85F735299D4AEBEC36400F5885F4286A	01	2025-09-30 02:04:57.137985-04
ACCESS_20250930150502_00001607	system	GET	/api/v1/home/dashboard/notices/2	대시보드 - 공지사항 상세정보 조회	10.42.0.1, 10.42.0.170	83ab4d56-f1f5-4a22-b926-1b4bc54de645	EC09E10BF77FE7DEC246472C83CF88BB	01	2025-09-30 02:05:02.858111-04
ACCESS_20251002105513_00001619	system	GET	/api/v1/home/dashboard/products/models/8	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1, 10.42.0.170	f8771267-b5d1-4e48-8dc4-3c65d963161c	B180CC7BBA5A53F75F03C8EDF58546F1	02	2025-10-01 21:55:13.064302-04
ACCESS_20251002105628_00001620	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	f365f7ae-5c4b-40ce-841c-92c6c2af28f5	5A6A4ABF712F0336E09ED766A22EBEA5	01	2025-10-01 21:56:28.310469-04
ACCESS_20251002105629_00001621	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1, 10.42.0.170	4a9328f3-a7a4-4d55-96d2-23c8773cfd9d	97B81FF2420C3088342A585E57616964	01	2025-10-01 21:56:29.029745-04
ACCESS_20251002105629_00001622	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1, 10.42.0.170	39c8d59b-2bc3-43e2-bdbd-4044f00c9872	30568CDB9280C11037791966A5927522	01	2025-10-01 21:56:29.382392-04
ACCESS_20251002105629_00001623	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1, 10.42.0.170	2474e6c2-1ac0-4424-be60-73bdce6d8d8a	13A25C4BCE05DA3C3B4B05973B36A33D	01	2025-10-01 21:56:29.476508-04
ACCESS_20250918120459_00000712	system	GET	/api/v1/ref/user/detail/sckang	사용자 관리 - 상세정보 조회	10.42.0.1	849942a2-2aab-4316-b3d7-75c59649a363	28E0DD0A2FB828C6AFDBFB20A5725817	01	2025-09-17 23:04:59.026583-04
ACCESS_20250918120928_00000713	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	8e63a4cf-117d-469d-b1b7-91c0a69d0bfd	1EA54A086DC87B481E084F081212025C	01	2025-09-17 23:09:28.048639-04
ACCESS_20250918120928_00000714	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	413f2e40-ec50-441d-85f6-1e2e4b22adde	C0F7E271B3F5E74637D2BEC9432D1814	01	2025-09-17 23:09:28.050322-04
ACCESS_20250918120932_00000715	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	40eb7fd3-2165-4193-a2e4-ae1c063d72a7	FE1182BFC0D76C13BD600103B4AB8CC0	01	2025-09-17 23:09:32.740628-04
ACCESS_20250918120934_00000716	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	6ddf2e53-616c-4920-824b-d357e0696230	74936E3193B3A5B57C773D048AE69754	01	2025-09-17 23:09:34.292168-04
ACCESS_20250918120934_00000717	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	d08ba951-c389-477b-887f-1419564b4c09	10241EB7EF2BCD3502BF4D1357C1A56C	01	2025-09-17 23:09:34.338423-04
ACCESS_20250918120936_00000718	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	c1e436ab-3868-47d4-930d-a67bd06e9ea7	C526C4A3FE24BB6A3C1AAD0F0AA67B1B	01	2025-09-17 23:09:36.834674-04
ACCESS_20250918120937_00000719	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8fd2ce76-d703-4259-9498-312779a6f4bf	ACF3F2D4CFB24D1B9EF26EFC6FFCD724	01	2025-09-17 23:09:37.404749-04
ACCESS_20250918120940_00000720	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	ec8a67c1-2943-4689-bb89-e3d28af41a8a	E1100CC16D2B90C28850AB8546748DDF	01	2025-09-17 23:09:40.118762-04
ACCESS_20250918120945_00000721	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8d6086c1-4c2a-4d88-b63a-c522074b23d2	9E01C746236F7B1CF0D188ED286AF154	01	2025-09-17 23:09:45.448633-04
ACCESS_20250918120945_00000722	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	f677435a-e8bd-42dc-8718-ea34624f233d	C54E4F2D62351B6A07E4C355DBFC80BE	01	2025-09-17 23:09:45.918884-04
ACCESS_20250918120948_00000723	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8c1745ff-441e-4359-a480-ca89a3384fb8	CB2CFEC87CF7AB9E55C28BFE98EFDC58	01	2025-09-17 23:09:48.854503-04
ACCESS_20250918120950_00000724	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	54f70704-5a79-48aa-a1b5-15204f880128	CC21DDFA5686D46A175D5A504BFE627B	01	2025-09-17 23:09:50.996464-04
ACCESS_20250918120952_00000725	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	4b8d39a0-c20e-4e1f-a0ef-be11f8f3b01b	B8CB08EED725EBAE1A3481F2E2D997FF	01	2025-09-17 23:09:52.121261-04
ACCESS_20250918120954_00000726	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	760db5a2-a473-4046-840f-2a96c7da70ea	36899FEE1DB394118624D7AAE83F1445	01	2025-09-17 23:09:54.032588-04
ACCESS_20250918120954_00000727	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	f2747304-b673-4ec1-9fd5-3e8b99216988	652A5B0E5B6BFFCB030E9A81961CE9F4	01	2025-09-17 23:09:54.936575-04
ACCESS_20250918120955_00000728	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	5b8ee3fd-34d9-4713-a393-4bd08f4e581b	5C542303AB80784222D883EE4F02AFAF	01	2025-09-17 23:09:55.990224-04
ACCESS_20250918120956_00000729	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	dd8f53aa-7f5c-4fb2-a521-bf2d6e806ae8	3202C2AACE9E2A14B0F68CE9A56E6BCC	01	2025-09-17 23:09:56.978928-04
ACCESS_20250918120957_00000730	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	cd5f2d2f-86be-42f3-b143-d757fc65c65c	64143AF0B7C7768C75DD27606304BCC1	01	2025-09-17 23:09:57.99067-04
ACCESS_20250918120959_00000731	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	a99eba88-c98a-4053-b0d2-0b587323475a	EB34CBF696E4B1BCC369C87B4C098515	01	2025-09-17 23:09:59.841555-04
ACCESS_20250918121004_00000732	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7d80dcb8-c06c-4838-abc7-a16b2a45c224	57B4AFDE6E71CF8980FB59DE25229A6D	01	2025-09-17 23:10:04.240464-04
ACCESS_20250918121005_00000733	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	7f44ec68-b47d-4b7a-9b77-6cca8c062ff7	7F3EFE1613DFB2A0ED76B19C5854B2AB	01	2025-09-17 23:10:05.111824-04
ACCESS_20250918121005_00000734	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	8309db71-9941-4eda-a5ce-0c2f5c1cf734	010B15E81EDCC50430486015D5B28E09	01	2025-09-17 23:10:05.593223-04
ACCESS_20250918121006_00000735	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	12466ebd-8f32-4274-95b3-84bdf0e59fd9	86D89E341E4A98217FD6590DC167F53F	01	2025-09-17 23:10:06.485281-04
ACCESS_20250918121007_00000736	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	4f6807d5-b77c-4ea5-9c92-eda3fa423a76	FF369C531DAE5A753390668A02F434D7	01	2025-09-17 23:10:07.208205-04
ACCESS_20250918121008_00000737	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	a3922de9-68bf-4ee3-ba32-1e8121094803	94B782D35C19008BD2F111E006093D15	01	2025-09-17 23:10:08.44856-04
ACCESS_20250918121009_00000738	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	4f1124ca-4fd8-4b78-9745-3646de9150f4	ED9E20E7F24B37F11DD35D7B4BFBEF87	01	2025-09-17 23:10:09.533691-04
ACCESS_20250918121011_00000739	system	GET	/api/v1/ref/user/detail/sckang	사용자 관리 - 상세정보 조회	10.42.0.1	89f12481-67b9-4dca-81a7-dec55ccd2082	2B5959F3695971D403A72BAFDD631246	01	2025-09-17 23:10:11.986176-04
ACCESS_20250918121023_00000740	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	9e20d5cc-a3b3-4880-aed6-3b008a417e8a	886007BC007D4EE5509B3E5A43E7A4D2	01	2025-09-17 23:10:23.999689-04
ACCESS_20250918121025_00000741	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	e20632d7-fdf7-4f08-8445-3d3310ca8d0f	B6163F1C249B048673F60C3974646651	01	2025-09-17 23:10:25.748402-04
ACCESS_20250918121028_00000742	system	GET	/api/v1/ref/user/detail/jhbang	사용자 관리 - 상세정보 조회	10.42.0.1	b611a49d-1358-440f-92f6-13c511a1c3c4	E862777D49F8DCEE0FEC42A3CE904981	01	2025-09-17 23:10:28.518933-04
ACCESS_20250918121138_00000743	system	GET	/api/v1/ref/user/detail/gtkim	사용자 관리 - 상세정보 조회	10.42.0.1	46d60bd0-1c0f-4528-8f97-916de3dab3bc	DFBD379E4B5DDF02B6164A025D48014A	01	2025-09-17 23:11:38.468163-04
ACCESS_20250918121221_00000744	system	GET	/api/v1/ref/user/detail/jhno	사용자 관리 - 상세정보 조회	10.42.0.1	85a5b7ad-1a93-48a8-949a-a0cb05384f7c	3F7D3E588A26AA64E0AF383BC82CD6A1	01	2025-09-17 23:12:21.876313-04
ACCESS_20250918122009_00000745	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	ce52b047-223e-424d-b0b8-445dce6da52e	4667A4228F22ED35F1CDDE0A517A2A52	01	2025-09-17 23:20:09.764003-04
ACCESS_20250918122009_00000746	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	aeb82938-a75f-4872-ac92-3153c222900d	86AE4A472DDB230450CFE33A4F3B5F68	01	2025-09-17 23:20:09.76455-04
ACCESS_20250918122045_00000747	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	4f5bfc4d-af79-48a3-84ac-5ec09000a34d	46D0FA912229590DAF964DFEB3453EF2	01	2025-09-17 23:20:45.207692-04
ACCESS_20250918122045_00000748	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	b4d2ab5c-0c77-40e8-a893-9b2922ea3138	43D3EDDBDAA6D0D9DF49B84A33E1672A	01	2025-09-17 23:20:45.207728-04
ACCESS_20250918122046_00000749	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	970fb3a4-787c-459f-aa02-855e96c1a97a	90298D7C16D7A33F48CB10DE706DDD29	01	2025-09-17 23:20:46.651502-04
ACCESS_20250918122104_00000751	system	PUT	/api/v1/ref/user/inits	사용자 관리 - 비밀번호 초기화	10.42.0.1	0e4b736f-2307-4df4-b081-3b67ff60ac62	503D714D4F16CC475049C481D04C57DC	01	2025-09-17 23:21:04.413178-04
ACCESS_20250918122120_00000752	system	GET	/api/v1/ref/user/detail/hckwak	사용자 관리 - 상세정보 조회	10.42.0.1	e92cb1b2-6aaf-4d65-ba29-2531a3520afc	0C47E17E8C20723CED70135632C89974	01	2025-09-17 23:21:20.619154-04
ACCESS_20250918122224_00000754	system	GET	/api/v1/ref/user/email/koi.daenahn@gmail.com	사용자 관리 - 이메일 중복 확인	10.42.0.1	b529d452-7499-44ac-8fea-383677eefc98	45EB9E626198D24D987BFEDFCE5A2D9B	01	2025-09-17 23:22:24.24189-04
ACCESS_20250918122231_00000755	system	GET	/api/v1/ref/user/mobile/01012341234	사용자 관리 - 모바일번호 중복 확인	10.42.0.1	29889fb9-99f2-4c10-860d-7ee94c0eeb30	11DBEC97DBA2DD86B751364665252C15	01	2025-09-17 23:22:31.640668-04
ACCESS_20250918171952_00001248	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	2c96a370-bfea-45af-b486-34ad1e622f3d	75FEF77769D48694BA3E5A0B008A2D3D	01	2025-09-18 04:19:52.287238-04
ACCESS_20250918172023_00001249	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	8bea6a3f-e156-404c-affc-0a5beabfd952	CA5FEF37A990078B23A7499E2D9C2047	01	2025-09-18 04:20:23.052674-04
ACCESS_20250918172023_00001250	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	3762798b-a2aa-477e-8e54-215ffafb6efb	48BD8E5847B052F9F32CF5F82B3EF8BA	01	2025-09-18 04:20:23.084933-04
ACCESS_20250918172032_00001251	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b0819dba-3a5f-4b8e-a338-d23ca0c32071	0565F0D7B8DC8B8458A1AB699A27D25C	01	2025-09-18 04:20:32.145076-04
ACCESS_20250918172058_00001252	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	43e9cc32-53b6-44ee-b6f4-02cf61139dd3	8E7B77912A8B4A359BABD463911C810D	01	2025-09-18 04:20:58.019166-04
ACCESS_20250918172100_00001253	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	7a5af3b3-9025-4b1c-88f4-971f26809a23	F3519615F836334286E3CB824820C405	01	2025-09-18 04:21:00.372958-04
ACCESS_20250918172114_00001254	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	3107cbc8-f218-49c7-8af4-6bacffa91894	F672AEE5EEC997CE27E63DC9120882CD	01	2025-09-18 04:21:14.498385-04
ACCESS_20250918172114_00001255	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	1afeba9a-728a-4c28-91d7-ecbd2e67e295	60080577A3C0F813F0A1CA91F881C165	01	2025-09-18 04:21:14.606582-04
ACCESS_20250918172120_00001256	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	518df9f2-c7a6-4f2c-a99d-5b92b8ccbd24	8AD598D2E3015E2AECFF20CD489B7A43	01	2025-09-18 04:21:20.66642-04
ACCESS_20250918172145_00001257	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	8709d9e7-36fe-4558-a367-72d5534bda8d	06BC0230BEB8E2E85ECC32B715D0E5DA	01	2025-09-18 04:21:45.089791-04
ACCESS_20250918172147_00001258	hckwak	GET	/api/v1/incoming/slock/3	입고관리 - 상세정보 조회	10.42.0.1	4f40944d-5879-4f43-9f36-75e35c72706e	912D5AEAA49700D355546C446FF526AC	01	2025-09-18 04:21:47.31091-04
ACCESS_20250918180138_00001330	hckwak	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	af02172c-987f-4c45-b055-fd539fb25ade	8444474B2A33971474CE17D853D59BE5	01	2025-09-18 05:01:38.526721-04
ACCESS_20250922102836_00001395	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	b3b17557-18ad-4da7-bfff-6ff5bf4e292a	706953C1292A0945B2F7CB833D32A7BA	01	2025-09-21 21:28:36.16311-04
ACCESS_20250923173754_00001442	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	cd4093ef-57db-4ede-9eed-b6490cc4d757	EADA9F8DEE06B7E27568A6ADCE428F35	01	2025-09-23 04:37:54.885987-04
ACCESS_20250923173801_00001443	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	8a818c1d-30bb-412b-9418-c5611bc99e48	627D8AE5A20DBB5B31B4CBB159178DE4	01	2025-09-23 04:38:01.501675-04
ACCESS_20250923173802_00001444	hckwak	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1	da3d627c-3aa1-481a-bc28-63b753d6f872	C66A5F4D56732F5DE231916AEEA9D48F	01	2025-09-23 04:38:02.903573-04
ACCESS_20250925152643_00001460	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	22b2087b-05ec-4abc-b101-cc2d1b67b8bc	F8C1D46141048556BF74A7238C90FB1E	01	2025-09-25 02:26:43.949686-04
ACCESS_20250925152643_00001461	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	138d8fc5-c4b0-42bc-897f-4cb32b48cf7d	243B4F6AD6F357E207377ECA7D0F15CD	01	2025-09-25 02:26:43.985199-04
ACCESS_20250926163738_00001498	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	cc6ec867-12c6-4376-8da1-d1553547af61	3CAA4C08C8BADE31735D9804D55B354F	01	2025-09-26 03:37:38.690127-04
ACCESS_20250926163747_00001499	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1, 10.42.0.170	ca0c7cbe-0097-47df-bf55-1a9a3c407c5e	BD7D99A01EE60199D30310D252E7AA2B	01	2025-09-26 03:37:47.927935-04
ACCESS_20250926163752_00001500	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1, 10.42.0.170	5fedccc1-70c0-4865-8df6-8bede05e70c0	3B64D8434581A564DFD74EE9699FC9B4	01	2025-09-26 03:37:52.906245-04
ACCESS_20250926163800_00001501	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	fc356538-9e41-4259-84fb-62390ffe8c36	8D3EB6BF5BBDA5E0D3F15EAFEC339570	01	2025-09-26 03:38:00.515454-04
ACCESS_20250926163804_00001502	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	e873797b-29f5-4589-a881-c709a6fef1a3	54B5BAB1C17F003F0C9F4790B98EE675	01	2025-09-26 03:38:04.586372-04
ACCESS_20250926165118_00001549	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	e83a7487-af75-42d9-b74f-e91625d8bd13	CDAEACCE7DC8DC26E3CDCABFF7337B62	01	2025-09-26 03:51:18.732356-04
ACCESS_20250926165118_00001550	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1, 10.42.0.170	3f291c48-f1dd-488f-8f77-5a858047e0cd	7A0D2C0D60FB6F478A1C5F1BAA937151	01	2025-09-26 03:51:18.767824-04
ACCESS_20250926165121_00001551	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	a64e16f4-3a12-450d-a756-87033c624494	7962DC12EDAA7FF38928480D99C00434	01	2025-09-26 03:51:21.560478-04
ACCESS_20250930145440_00001586	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	51c07c32-478f-4add-92a1-19a9e2cf09e6	3A037DBFDFCA1DE602B9CB09BECA71D6	01	2025-09-30 01:54:40.062742-04
ACCESS_20250930150441_00001605	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	213b8c56-e5c0-4a1c-8a74-ca36a551ffc3	2C6C8059DCEBAA349FF61548B9F4A12E	01	2025-09-30 02:04:41.977881-04
ACCESS_20250918122049_00000750	system	GET	/api/v1/ref/user/detail/hckwak	사용자 관리 - 상세정보 조회	10.42.0.1	455f4d4c-9b08-41e2-9915-b4a79a594883	C82742BE9C1BD60DD915D5BA4CA6AE8E	01	2025-09-17 23:20:49.599914-04
ACCESS_20250918122138_00000753	system	GET	/api/v1/ref/user/detail/hckwak	사용자 관리 - 상세정보 조회	10.42.0.1	d40acd35-ad68-4b0b-847a-a4dafdf05dca	DDFB82A40D52523CB922F9B056505104	01	2025-09-17 23:21:38.113319-04
ACCESS_20250918122314_00000756	system	GET	/api/v1/ref/user/id/daenahn	사용자 관리 - 아이디 검증	10.42.0.1	4b7bdc4b-b0d1-4d88-9e74-dc40f6e9c77d	8D2AABA2F1AA81AFB1725DAE5E5E482D	01	2025-09-17 23:23:14.527734-04
ACCESS_20250918122318_00000757	system	POST	/api/v1/ref/user	사용자 관리 - 사용자 추가	10.42.0.1	68b3df13-6e96-4aea-8351-65eb8940855a	935FA1DB4E00FF195F2FC524C582146E	01	2025-09-17 23:23:18.614704-04
ACCESS_20250918122318_00000758	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	47ab53f9-c6de-48b6-940f-e21759ac8081	1DC667E02EAD749CAAAD9D621188C3BC	01	2025-09-17 23:23:18.705997-04
ACCESS_20250918122352_00000759	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	7265d4be-d34f-4b21-9040-72521208a7a7	B4314AC7F651683B3218FF23ECCF2851	01	2025-09-17 23:23:52.636029-04
ACCESS_20250918122352_00000760	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	3f4536ff-1ba9-4012-ba5e-f57d77989e3d	6C69A1E3B6F9D07473BA0EC362222F83	01	2025-09-17 23:23:52.637135-04
ACCESS_20250918122356_00000761	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	a82dd2be-f7e2-456d-9dc8-6d4c9e49a1c8	282614AD3F1AA84715379FFA2FCBF36A	01	2025-09-17 23:23:56.351763-04
ACCESS_20250918122409_00000762	daenahn	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	8e360812-b36f-4f5b-ba42-b9d3749276d5	0953C9DC8913110A81FA649F31970B09	01	2025-09-17 23:24:09.027323-04
ACCESS_20250918122409_00000763	daenahn	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	d3a772f5-7223-41ce-afaa-34659c4c2447	0953C9DC8913110A81FA649F31970B09	01	2025-09-17 23:24:09.027321-04
ACCESS_20250918122417_00000764	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	f59584ba-4d09-412b-ad21-c6fbeccfe966	7747DEFF37C6E900EE054A97BAF2B6C6	01	2025-09-17 23:24:17.940537-04
ACCESS_20250918122417_00000765	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	64f05440-d56a-47ae-8b5b-1591e3f05c89	5F767AB9E36DE2540B59E379628F168B	01	2025-09-17 23:24:17.940538-04
ACCESS_20250918122433_00000766	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	9c6db12c-a055-4a5b-8ab9-a5782b020819	2ED1FE60AED6F9D3D7CC273245ABD655	01	2025-09-17 23:24:33.64255-04
ACCESS_20250918122433_00000767	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	b770bfbd-21a8-47a8-9a3a-4eeb9135cd8c	EA7B33AE4039A71A8C204DC563780ABD	01	2025-09-17 23:24:33.643153-04
ACCESS_20250918122442_00000768	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	3931c7c1-5330-40a7-af7e-a0e4f0089701	31920EDEDD9DC352694DCA51EE1862C4	01	2025-09-17 23:24:42.678588-04
ACCESS_20250918122449_00000769	hckwak	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	66f7159b-6a9f-470d-ad5e-bbd8f7d6a845	E7DEFF82594EF383183414B90EC26538	01	2025-09-17 23:24:49.336774-04
ACCESS_20250918122452_00000770	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	500b6fac-aa1b-42e2-be83-ec193c4d930d	928FFD090925D0EE2D6D901C7545C00F	01	2025-09-17 23:24:52.522415-04
ACCESS_20250918122454_00000771	hckwak	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	08f12048-16e5-4f98-a0a1-7bf45fe94281	B743C7761FF634BD7CA57066F88ECB35	01	2025-09-17 23:24:54.386067-04
ACCESS_20250918122457_00000772	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	56a1467d-eae3-4111-a073-7d19c175841d	6A665729F43C6ADC30B8C54EF70F63A3	01	2025-09-17 23:24:57.306845-04
ACCESS_20250918122538_00000773	hckwak	POST	/api/v1/ref/notice	공지사항 - 공지사항 추가	10.42.0.1	65ed93ac-ba7e-43b6-a623-9f8363db0435	AA1E0FB3E6FE8101F84F7B9C3F5E8CFE	01	2025-09-17 23:25:38.22474-04
ACCESS_20250918122538_00000774	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	f9171811-4675-4cf7-a679-8a33cfb48df3	D82222B83548FE63791D39D2E5F8E21F	01	2025-09-17 23:25:38.291433-04
ACCESS_20250918122649_00000775	hckwak	GET	/api/v1/ref/notice/1	공지사항 - 상세정보 조회	10.42.0.1	0a2f9899-9021-4c51-afcd-ab4567fedd06	F6C9EF20A7EBBD44220FE56CAB453353	01	2025-09-17 23:26:49.259037-04
ACCESS_20250918122653_00000776	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	b545a6bc-4828-4711-b9c5-8dc3c41717f5	AB3BCF1DCEF764FCBA8E29787A340252	01	2025-09-17 23:26:53.927861-04
ACCESS_20250918122653_00000777	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	c23e9504-dcec-4bd8-85ee-72f9f26f6c45	3CBB03F3C32C286A044F4751989DAECD	01	2025-09-17 23:26:53.947305-04
ACCESS_20250918122658_00000778	hckwak	GET	/api/v1/home/dashboard/notices/1	대시보드 - 공지사항 상세정보 조회	10.42.0.1	438bdbb8-245f-4d7d-be27-6f7752a0f565	28FD027F4203E13550DA9A50A5644E19	01	2025-09-17 23:26:58.969946-04
ACCESS_20250918122704_00000779	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	93a88b59-08e0-4de2-855d-723c30a5242d	FB930A431AD34500A0857438B7380247	01	2025-09-17 23:27:04.074141-04
ACCESS_20250918122705_00000780	hckwak	GET	/api/v1/ref/notice/1	공지사항 - 상세정보 조회	10.42.0.1	dfb8e6ae-f489-4a95-9b9b-a8d44eae89de	7EBA532A7A826A4569CF6929B03B9658	01	2025-09-17 23:27:05.340741-04
ACCESS_20250918122718_00000781	hckwak	PUT	/api/v1/ref/notice	공지사항 - 공지사항 수정	10.42.0.1	e0b8922c-88ba-4524-9eb2-3ec56b2f184c	6915895E5D6AE9CA7859FEB99BB31BC4	01	2025-09-17 23:27:18.883763-04
ACCESS_20250918122718_00000782	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	74301936-0c41-4114-9fb7-d2ceb79fba0e	4EE533DDDC7668B9285D4979083D22B7	01	2025-09-17 23:27:18.959444-04
ACCESS_20250918122802_00000783	hckwak	POST	/api/v1/ref/notice	공지사항 - 공지사항 추가	10.42.0.1	cd0cad5d-0b36-4ac6-8c65-6279259cef21	418B84AAB9BDC6AC77C99DF68C171969	01	2025-09-17 23:28:02.84896-04
ACCESS_20250918122802_00000784	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	821084f0-b0f0-4761-92e0-23ee3224baae	53DB327F97D4338BEBD2B2EE8737543C	01	2025-09-17 23:28:02.895301-04
ACCESS_20250918122809_00000785	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	4709065b-9e72-40a1-ab82-d8b228fc8b40	A85347EB1757BEA7C87B8CA7DF4BEE12	01	2025-09-17 23:28:09.71296-04
ACCESS_20250918122813_00000786	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	83ec019f-12f7-4ef6-9d69-8b4f91edcd11	FCB8778A53E360595D73FC0BB515E321	01	2025-09-17 23:28:13.502752-04
ACCESS_20250918122819_00000787	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	ce15b74f-75dd-40bd-a9aa-0b1d4f84416c	7D9F7E349A4FB8161015B9EAF39FAF0F	01	2025-09-17 23:28:19.144275-04
ACCESS_20250918122827_00000788	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	2fbdc8cd-5d25-4655-9be3-beb30ca0ec37	7E28A3DABBBF6D32E6FFD0CB9DA59DDC	01	2025-09-17 23:28:27.937746-04
ACCESS_20250918122832_00000789	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	c8a4c467-cbd7-4c28-8ce5-32d98f5ce32b	50E6B755712EB7196F89BA545E29AC33	01	2025-09-17 23:28:32.729489-04
ACCESS_20250918122837_00000790	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	343c18e5-bc29-45cb-a86a-653a606909ca	9351CFA992B8FEDCE03365314CF233FB	01	2025-09-17 23:28:37.6346-04
ACCESS_20250918122841_00000791	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	c65fc437-b9bf-4127-a42c-e947d2d040ad	F26EAC5EA92830FE8E65B217D1B2BD9A	01	2025-09-17 23:28:41.277431-04
ACCESS_20250918122845_00000792	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	bba83a79-963c-492c-bd27-bd865e233d35	21F2AD8974A5AB51CA9155E8347C2484	01	2025-09-17 23:28:45.092724-04
ACCESS_20250918122849_00000793	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	51713804-e03d-4b2c-ad94-7086e0c0709f	DFF1F5624364E3FD8682682EC810C13B	01	2025-09-17 23:28:49.429587-04
ACCESS_20250918122857_00000794	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	4de2239e-e053-4955-b7d6-b11db00aec13	B5E0C9B60E97AB39AF343AD618F5796D	01	2025-09-17 23:28:57.850084-04
ACCESS_20250918122902_00000795	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	63f7c070-ec53-443b-966d-807d707214c7	037DC4230822EF883D95D07D6ADBAF2F	01	2025-09-17 23:29:02.049297-04
ACCESS_20250918122907_00000796	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	61873e3e-e63d-4f79-aa79-a7b0ca53e4d1	19805EE9C2F19EBFBADF6390AF40FA16	01	2025-09-17 23:29:07.504954-04
ACCESS_20250918122912_00000797	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	df88e93e-3722-41ee-a240-6c39d49a80b9	A92297470FD8EBDFB96EEB5371BD6080	01	2025-09-17 23:29:12.804709-04
ACCESS_20250918122920_00000798	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	0a692f77-2615-4089-801e-0ba2e75a1764	C4CBE473B9EE745AA389887631959B51	01	2025-09-17 23:29:20.744598-04
ACCESS_20250918122935_00000799	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	7694f74e-b6ea-4436-8658-f96d9aa6b966	54DCE073C5177CF9A6E193CEA39070AD	01	2025-09-17 23:29:35.699978-04
ACCESS_20250918122941_00000800	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	84652a7d-2cf2-40d2-8d3c-3a277eabf134	F42CADA0A74DB743764A175624DC5B65	01	2025-09-17 23:29:41.99599-04
ACCESS_20250918123002_00000801	hckwak	POST	/api/v1/ref/common-code	공통코드 - 공통코드 추가	10.42.0.1	99a95451-a975-4e1d-bcba-22f70c7ac37c	F658EB3F9039707D22654E1BE048E207	01	2025-09-17 23:30:02.110468-04
ACCESS_20250918123002_00000802	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	b3f8678f-95ae-4b3a-ac8f-12fe18a64643	440EF7A0327B2FFA4B92ED20079193DF	01	2025-09-17 23:30:02.146976-04
ACCESS_20250918123006_00000803	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	dff2310c-86bb-437b-a37b-526dbc1dc705	5F66EA57955D66466DAB087A80AA8DF8	01	2025-09-17 23:30:06.480362-04
ACCESS_20250918123011_00000804	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	db4a78a9-beca-4347-a5ce-7cdccdd55b09	6D95709EFBF0EC6BCB8AC95415886252	01	2025-09-17 23:30:11.414415-04
ACCESS_20250918123013_00000805	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	168401fc-7fa5-46d5-9e60-1ea8534684af	8672A08ACA26F468CDF428BB979B6EAC	01	2025-09-17 23:30:13.442248-04
ACCESS_20250918123031_00000806	hckwak	POST	/api/v1/ref/common-code/item	공통코드 - 코드항목 추가	10.42.0.1	16f4dc26-0c1b-40bf-abbd-3a3824eef7da	E3DA905494C81E1F6726318C043E90E7	01	2025-09-17 23:30:31.066427-04
ACCESS_20250918123031_00000807	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	0ec03d37-8361-48c4-ac82-412ca36eb41f	5F2D85FDF0C661CD811EA0C0F5B7BA5E	01	2025-09-17 23:30:31.146625-04
ACCESS_20250918123031_00000808	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	99623214-b83c-42e9-b621-2b7939930cc4	5F2D85FDF0C661CD811EA0C0F5B7BA5E	01	2025-09-17 23:30:31.147238-04
ACCESS_20250918123044_00000809	hckwak	DELETE	/api/v1/ref/common-code/item/TEST_CODE/TEST_01	공통코드 - 코드항목 삭제	10.42.0.1	66932cd0-3cd1-4cec-a4ea-a0443eccaa1c	798DF45449F77F7AC06A310CDF57A5A3	01	2025-09-17 23:30:44.238165-04
ACCESS_20250918123044_00000810	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	3db6e5bf-0fe5-4dfc-8086-0d1ac073f5b0	BC40EB40178BB183D6243539A47CB90C	01	2025-09-17 23:30:44.282004-04
ACCESS_20250918123049_00000811	hckwak	DELETE	/api/v1/ref/common-code/TEST_CODE	공통코드 - 공통코드 삭제	10.42.0.1	cb29d1f6-93ed-49c6-9d07-60343df26351	C255CA19A166BFDEB2D8728B8D51D6F3	01	2025-09-17 23:30:49.465928-04
ACCESS_20250918123049_00000812	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	b85b4aa3-0f72-47b5-8ca1-a7ee7a7adf49	695C2C4E6A92B97184D493DA1B163BC7	01	2025-09-17 23:30:49.512976-04
ACCESS_20250918123100_00000813	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	c3738559-6e57-46f2-a88f-c3dd2a02337a	5A76369DEB6488F0AB1F8361BDA51B15	01	2025-09-17 23:31:00.216136-04
ACCESS_20250918123100_00000814	hckwak	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	a6c9c59d-2978-4c74-80ca-ce450a123481	D91052251238FE5FFBD5D298569BEF9A	01	2025-09-17 23:31:00.270079-04
ACCESS_20250918123103_00000815	hckwak	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	d25fe627-08c0-4bfe-b121-057655779887	814D7FE7D6B54CD2BB63A86D8F6EB3D4	01	2025-09-17 23:31:03.966361-04
ACCESS_20250918123120_00000816	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	e6982a8d-f6f9-429c-a1b6-4dc74bbf067b	872FBF91BDFFB03BEB6166767F7BD97F	01	2025-09-17 23:31:20.286413-04
ACCESS_20250918124841_00000817	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	d3a81cd8-c6b8-473e-a41d-729386485703	E2DF619EB4716260D3C87D3562CFA2F6	01	2025-09-17 23:48:41.585515-04
ACCESS_20250918124856_00000818	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	1a16417b-4b12-4a6d-9a23-ddbadc36d38f	40E571E886FA7A60AD3E6FE70A4CEF0B	01	2025-09-17 23:48:56.91322-04
ACCESS_20250918124900_00000819	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	e55a01de-ac9b-4575-845a-93c5933343e7	F63F917AE8FAEC45DA33ABA686201D18	01	2025-09-17 23:49:00.254754-04
ACCESS_20250918124925_00000820	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	30c3c1c8-8679-4003-91e2-1516f109ade2	71298FA95E85A44C0AE59D6C9F96154C	01	2025-09-17 23:49:25.175936-04
ACCESS_20250918124935_00000821	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	1c5cd24e-9ff9-43a8-be6c-34a71639d7b9	9FCE2166B32AE4EC4048B7570074E694	01	2025-09-17 23:49:35.722732-04
ACCESS_20250918124942_00000822	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	cd294a32-356d-44e3-8104-f2b98afcb0d2	6542EE76E098759DEF3D487B94D1B8C1	01	2025-09-17 23:49:42.761503-04
ACCESS_20250918124954_00000823	hckwak	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	5ce4bb68-f254-4b48-be0a-818d3b5bc4f6	783D03EB1B1C4F20B4DBC00912044299	01	2025-09-17 23:49:54.933354-04
ACCESS_20250918125004_00000824	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	27aaa819-a8da-465f-ba9a-5c7e908b9f5d	7F9EB36A85DF466947A4A739AC985F7A	01	2025-09-17 23:50:04.056221-04
ACCESS_20250918125005_00000825	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	6c6a3fa4-65e1-4522-ab0e-59b7e4cdc396	B8B265765DDDF12B5C322738E642BD5D	01	2025-09-17 23:50:05.787813-04
ACCESS_20250918125010_00000826	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	3c02cabd-c7ce-4a25-a9c0-73c38a075a12	3E535899C858E0A3AD256042652FDB8A	01	2025-09-17 23:50:10.075656-04
ACCESS_20250918125018_00000827	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	c88c0ff1-62b9-4987-86a3-fd500521102c	01B9D163CB76437FCEEDBF95A5471AC6	01	2025-09-17 23:50:18.757961-04
ACCESS_20250918125024_00000828	hckwak	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	b00c66c6-df68-4417-a3c9-c73f52809ac2	BA259AD8172AC53B7106A3EF5CA451D1	01	2025-09-17 23:50:24.139944-04
ACCESS_20250918125027_00000829	hckwak	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	eeb50cfd-3bf2-47ca-8968-3587a598e328	70B31939404749067155E01A62FCD421	01	2025-09-17 23:50:27.818191-04
ACCESS_20250918125039_00000830	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	cdf3d0e6-0291-4c62-a1d8-f506fda43822	C88FCE7A7322350E815B7263D694BBBE	01	2025-09-17 23:50:39.847221-04
ACCESS_20250918125046_00000831	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	cf925beb-2672-4e7e-9ba9-feea2734d3bb	6A83A1313F866DE838038768BDDD5E8F	01	2025-09-17 23:50:46.251355-04
ACCESS_20250918125106_00000832	hckwak	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	d0bdb4b9-a11a-46ed-8b1c-dfbd1201adc8	B5CEB42EF535A7C6EFC858BC8A1E13A9	01	2025-09-17 23:51:06.817047-04
ACCESS_20250918125106_00000833	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	d89f0ca0-dd34-4c1f-ba41-ce87edab8278	0173D2A524DB595D8142D5BB67404360	01	2025-09-17 23:51:06.859926-04
ACCESS_20250918125118_00000834	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	60a301cd-0182-4f23-98c9-f76b6ecbf0c0	D8D62F3E690A1EFAD16913CA679826E9	01	2025-09-17 23:51:18.650869-04
ACCESS_20250918125125_00000835	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	98fd61bc-034f-4214-838d-df3c63ecd365	81503E000DAA21B88702F90DEEF708C2	01	2025-09-17 23:51:25.569191-04
ACCESS_20250918125125_00000836	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	96d821d7-d76b-4cd3-b2fd-2e340d670883	801C2A7CF49A2289837A195B333E742B	01	2025-09-17 23:51:25.595507-04
ACCESS_20250918125139_00000837	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	2ccfa1b4-bf7d-4f7a-bb3b-ace970e80486	25D1EDEE52FC974410EF8216EEDB1CD4	01	2025-09-17 23:51:39.910441-04
ACCESS_20250918125151_00000838	hckwak	GET	/api/v1/ref/customers/validate/koiware	고객사 관리 - ID 중복체크	10.42.0.1	40681fe1-c4f9-456e-abc3-0bdd1de4e0a3	34001A56D8734A21900A5703D04391DF	01	2025-09-17 23:51:51.852464-04
ACCESS_20250918125231_00000839	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	0dc2e727-40f3-4833-9b2c-bcc339bbe385	84659FB943E589B70F360179DBA2235B	01	2025-09-17 23:52:31.071287-04
ACCESS_20250918125233_00000840	hckwak	GET	/api/v1/ref/user/detail/hckwak	사용자 관리 - 상세정보 조회	10.42.0.1	29b81dcf-8932-41a0-9488-bdc1a803a8f5	C661B396DE2312B5D4DFC84D68323D61	01	2025-09-17 23:52:33.717879-04
ACCESS_20250918125328_00000841	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	69a43dd0-7d59-4cdf-8134-1e35b6017137	1F9659E7329325999F97E5983B7341D6	01	2025-09-17 23:53:28.044875-04
ACCESS_20250918125427_00000842	hckwak	GET	/api/v1/ref/customers/unique-info/cuid	고객사 관리 - 고유정보 생성	10.42.0.1	43186a56-3680-4490-8bc8-2fab0115bc77	E8FA18AA2F551EC358CF52ABD1FA5045	01	2025-09-17 23:54:27.037446-04
ACCESS_20250918125427_00000843	hckwak	GET	/api/v1/ref/customers/unique-info/mk	고객사 관리 - 고유정보 생성	10.42.0.1	ff02543a-d839-443a-9491-2ff57f0af9b5	89B3B5618DF6DFBCCFF1FBFBE8938AD2	01	2025-09-17 23:54:27.746646-04
ACCESS_20250918125428_00000844	hckwak	GET	/api/v1/ref/customers/unique-info/ap	고객사 관리 - 고유정보 생성	10.42.0.1	d3511176-0f9d-4fcb-a602-6cfc4c56a132	71ABE2BB795531D68ADEA59649F186F8	01	2025-09-17 23:54:28.865551-04
ACCESS_20250918125435_00000845	hckwak	GET	/api/v1/ref/customers/validate/koiware	고객사 관리 - ID 중복체크	10.42.0.1	2ea7b230-d799-4f00-a4c6-f71f143b8ff5	EBA65744DE4BB9BEA766D7D10133A2BF	01	2025-09-17 23:54:35.279333-04
ACCESS_20250918125437_00000846	hckwak	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	fd48eb0f-04be-4f3a-9749-6843940b7fe3	77E337707EF01A6F01281E8647836226	01	2025-09-17 23:54:37.053355-04
ACCESS_20250918125438_00000847	hckwak	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	9dc41ac1-fd51-4d67-b67a-358118cb9b5b	7E32373C37B4AC5B0988ECBD82B7FAFE	01	2025-09-17 23:54:38.876102-04
ACCESS_20250918125440_00000848	hckwak	POST	/api/v1/ref/customers/unique-info/validate	고객사 관리 - 고유정보 중복체크	10.42.0.1	768e60e2-ef17-4ee0-bb54-10ce4dc93149	11E366A82C0969708BC9C902214C201F	01	2025-09-17 23:54:40.173359-04
ACCESS_20250918125441_00000849	hckwak	POST	/api/v1/ref/customers	고객사 관리 - 등록	10.42.0.1	f8c63fb5-fc5e-437c-b9ed-8ef19e1ee499	B65A798527034F5F3CAA5487E9CD9BAD	01	2025-09-17 23:54:41.781375-04
ACCESS_20250918125441_00000850	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	08d586ef-a5f3-4366-b992-d8cad9d38f3f	58228EF549DD3CBCC729E133F429B1C1	01	2025-09-17 23:54:41.786395-04
ACCESS_20250918125441_00000851	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	0ca76031-4c35-4f95-aedc-f3881c3d06ba	E11FA57C13D3DBF5F954C4559FE208C3	01	2025-09-17 23:54:41.807061-04
ACCESS_20250918125519_00000852	hckwak	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	07561ee7-d023-4da7-9d97-3d0684e7c532	BBEFA99B933B2C7F5FBFE3077AA3CA2D	01	2025-09-17 23:55:19.017328-04
ACCESS_20250918125521_00000853	hckwak	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	acd3055a-f427-4632-9ef9-4a68350f47a2	1D2A020E9F92DB85DDFA28B901C37DDE	01	2025-09-17 23:55:21.611352-04
ACCESS_20250918125523_00000854	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	4894022c-09f3-499d-8b1c-bbccb2fd73d9	3C34FE797E7BF080F883AA6284EC397B	01	2025-09-17 23:55:23.084745-04
ACCESS_20250918125526_00000855	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	7614346a-f882-4f38-b30c-dea756ba465e	A955CE7C4B372B0164C4C9708695A6EC	01	2025-09-17 23:55:26.759665-04
ACCESS_20250918125532_00000856	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	c3c19e4a-fab4-4b35-aeb0-30280109016d	53919AD55756A7EC5D98FEA8F36025BD	01	2025-09-17 23:55:32.73342-04
ACCESS_20250918125532_00000857	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	31b9df3e-33c3-4a36-83b8-dff652c78f52	E8616F2F10116CC87BEA5326A7790196	01	2025-09-17 23:55:32.765252-04
ACCESS_20250918125539_00000858	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	87aa0910-b537-4e04-a115-c37d7e487ced	042E33595DCFB9300494233B20E78355	01	2025-09-17 23:55:39.072627-04
ACCESS_20250918125631_00000859	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	c94fa5ef-4272-4e4d-a008-964d2f8ac358	67F3D34A8242BEB8C23AF9FF327153E9	01	2025-09-17 23:56:31.468534-04
ACCESS_20250918125631_00000860	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	8e6eb350-b9fb-4425-8d67-9231dfae034e	626C2B40CE1924A0F7C0FEC6558BCCC8	01	2025-09-17 23:56:31.524172-04
ACCESS_20250918125639_00000861	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	559bde7e-95a5-448a-aa81-38ffb4484704	DCA5D766D386F962C3815B504EAAB303	01	2025-09-17 23:56:39.174572-04
ACCESS_20250918125639_00000862	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	aa49f08e-a57e-4963-bb16-8ca206a6b86f	192B54BF321375AB35EB0ECF4B3D1D92	01	2025-09-17 23:56:39.182121-04
ACCESS_20250918125648_00000863	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	ba40c950-7a3a-44e8-be9c-4e10bdcb1389	ECB9C45B88DEC677015B8D66C6FA5E24	01	2025-09-17 23:56:48.535178-04
ACCESS_20250918125726_00000864	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	090e611c-9c74-42b8-add4-e2a367d7f4ac	1F5E00704BC800E6A38998903C0896E1	01	2025-09-17 23:57:26.200798-04
ACCESS_20250918125726_00000865	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	e7de6dba-59d5-4648-8091-38b868480932	017829C80019A05706DAA1DDF4865999	01	2025-09-17 23:57:26.839675-04
ACCESS_20250918125854_00000866	hckwak	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	d4a7e764-6d34-438c-9e73-9cfb2ab9291f	E22B09B9A09302B250B168551D33B730	01	2025-09-17 23:58:54.088989-04
ACCESS_20250918125900_00000867	hckwak	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1	91a34d90-a8ae-4b82-b5bf-20cb19bc5312	9E10F67FFCB15BC1D98022316D6D51AE	01	2025-09-17 23:59:00.469424-04
ACCESS_20250918125903_00000868	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	575178e9-6f56-417a-acef-b45f74b06964	D9D257F572AEFA0B20F4F2F2BC4E4563	01	2025-09-17 23:59:03.23719-04
ACCESS_20250918130012_00000869	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	e19d9552-20c7-4909-b4f1-435e880cfb53	8D72895112CBB3991C29AF4986EFE08E	01	2025-09-18 00:00:12.501478-04
ACCESS_20250918130019_00000870	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	fa2d50ff-5599-4ebc-aab7-f4244a787600	0356C6CEAF3EE69DBD87AB4CEBA35092	01	2025-09-18 00:00:19.463339-04
ACCESS_20250918130042_00000871	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	aa7183c4-9348-4e18-9b37-bad8e43236ff	5089659C893F3A2564400AF80C116D24	01	2025-09-18 00:00:42.823786-04
ACCESS_20250918130051_00000872	hckwak	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	0782897f-37ac-40eb-8499-f86680e948ff	015399303427158B7522801752C13918	01	2025-09-18 00:00:51.859734-04
ACCESS_20250918130059_00000873	hckwak	POST	/api/v1/outgoing/slock/config	출고 부가정보 불러오기	10.42.0.1	b0bff1f5-5982-4281-bb40-97822397332c	CCB47790C0EAB9EDB03CCE79C17244BF	01	2025-09-18 00:00:59.902194-04
ACCESS_20250918130111_00000874	hckwak	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1	983e4da7-828a-4168-89d6-f0202331773f	65B03795CB75F747E7016ACE025376FB	01	2025-09-18 00:01:11.100466-04
ACCESS_20250918130111_00000875	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	b155c65c-38f4-4246-bba0-f1d39102a828	339AC478E012FB683FAF6E3546F171C6	01	2025-09-18 00:01:11.173098-04
ACCESS_20250918130158_00000876	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	a7a59524-bcb7-4130-86df-2378b2a9c7e1	B6D5DC0A991450054DD0AF2D967E5CF8	01	2025-09-18 00:01:58.03698-04
ACCESS_20250918130210_00000877	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	244917d8-68c4-47b5-b2aa-c92c8f0cb447	5213849533B4689142328D9DC23C53C6	01	2025-09-18 00:02:10.151774-04
ACCESS_20250918130213_00000878	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	de8c63ef-1643-43f6-815b-2487808140a9	8282842E7C977E92EDDE0B6D497AB309	01	2025-09-18 00:02:13.099852-04
ACCESS_20250918130215_00000879	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	7b9d1acf-a3bc-4a04-8cd9-2b6fc7bf6517	A57A2F9740793E3BD5403AE39BED24CD	01	2025-09-18 00:02:15.460586-04
ACCESS_20250918130242_00000880	daenahn	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	ed5a58ae-6666-475b-963c-d79e2be65cd1	C7FD68E3B89EE7BB1ACB3FDAB3689B82	01	2025-09-18 00:02:42.905554-04
ACCESS_20250918130242_00000881	daenahn	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	cf69c7ce-24a3-4758-ba07-cbb57540cc81	46526DF7CB35F70E764571AEF81A407F	01	2025-09-18 00:02:42.906629-04
ACCESS_20250918130248_00000882	daenahn	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	360107fd-dbfd-4c88-9e00-5fee318decaf	0A528ECEDC15D27CE2F53122A432CA12	01	2025-09-18 00:02:48.1773-04
ACCESS_20250918130447_00000883	hckwak	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	11130949-3420-406d-98b6-12eb17b1b70d	190F6892385EEF56CCBA0DAD87E129BE	01	2025-09-18 00:04:47.599229-04
ACCESS_20250918130447_00000884	hckwak	GET	/api/v1/product/3	입/출/반품 관리 - 상세정보 조회	10.42.0.1	81a163e4-cfe4-45ee-9e20-379d748f1ea4	03C8D8D1125A8573DC4FA51D99EE0013	01	2025-09-18 00:04:47.606408-04
ACCESS_20250918130632_00000885	hckwak	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	e94f529f-e985-497a-add6-6779511431b2	2C28C4807C6DA80B0B20D8639700C982	01	2025-09-18 00:06:32.498396-04
ACCESS_20250918130632_00000886	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d9562b80-d2f1-45ad-8a4c-556c662c3eba	44ECC77458D3C0167A61BC37FC1D5BED	01	2025-09-18 00:06:32.52912-04
ACCESS_20250918130641_00000887	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	4db8de9d-dab9-4d0f-8857-7339fc6df5d4	DB8725DF06783AD85F7964EC2B6E60E2	01	2025-09-18 00:06:41.320433-04
ACCESS_20250918130644_00000888	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	9049d246-6c50-4f9a-b678-9340da332f0e	BCB3299686C673685BBA9DC431CF9397	01	2025-09-18 00:06:44.795838-04
ACCESS_20250918130651_00000889	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	e26831e1-351e-4ee2-a532-ef70315b7620	15BC315B764438EC3FA62ECA6A3659EF	01	2025-09-18 00:06:51.514691-04
ACCESS_20250918130653_00000890	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	a6513fc3-77bb-49e4-98d0-5ff687c334da	B139F10F958E23C3889F306A53ED181D	01	2025-09-18 00:06:53.695454-04
ACCESS_20250918130656_00000891	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	67333bd9-80a6-4593-a49e-1653c57da6f0	DBB1685535881B1D38653C5172BA8F6D	01	2025-09-18 00:06:56.458941-04
ACCESS_20250918130656_00000892	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	7f73006b-75b2-4248-b587-dae1aaff41f0	2696703D3141F87C5FFA9CC7388B7A0F	01	2025-09-18 00:06:56.466249-04
ACCESS_20250918130724_00000893	hckwak	GET	/api/v1/home/dashboard/products/models/3	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	45538d4d-e10f-4312-9fcb-ef57d14e9e83	C7919DB2AB4DCB5023912DF898D6DEA4	01	2025-09-18 00:07:24.260251-04
ACCESS_20250918130727_00000894	hckwak	GET	/api/v1/home/dashboard/products/models/3	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	689d76fa-f165-489e-a31b-66061c5addff	A8E66A11A220F906479742B3D9AB7FA4	01	2025-09-18 00:07:27.457043-04
ACCESS_20250918130740_00000895	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	6709812d-e56c-4731-8951-a8e6ea29bbca	FDCDB6005E701BD66B2E3E70CC07B352	01	2025-09-18 00:07:40.021705-04
ACCESS_20250918130746_00000896	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	917f6743-7c37-4db0-aa68-3d34c2216f12	5BA228543EB91DE2613B709F58B25EB3	01	2025-09-18 00:07:46.433145-04
ACCESS_20250918130751_00000897	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	6ea46cb8-14cd-41fe-8949-fd3da120a5c4	CC7A7D6BC78201DCB83540C6D1760470	01	2025-09-18 00:07:51.245068-04
ACCESS_20250918130758_00000898	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	0f2b2159-d8b3-47fa-8769-3b6ee1a1d9f5	212B785F7CC35710D68243314EF8DC98	01	2025-09-18 00:07:58.343439-04
ACCESS_20250918130808_00000899	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	95d40c27-40df-4abb-8aa4-be5286d0d5c1	2ECF995A1671400823AD906CF57CFC69	01	2025-09-18 00:08:08.012259-04
ACCESS_20250918132349_00000900	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	8cdd0eac-e199-473c-9e26-aa2b43f56182	265DBED504B9CA698F0E39C8EF25DAB2	01	2025-09-18 00:23:49.955947-04
ACCESS_20250918174607_00001259	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	33a9d6a7-bc79-4281-8fe4-6a49d3237c99	5A030DB441A9425813234A9FDC905298	01	2025-09-18 04:46:07.258642-04
ACCESS_20250918180244_00001333	hckwak	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	84da1cb7-d024-4fd8-8d94-ef7ad6fec463	07B31AC12E0E976795E95EA139F5C1D7	01	2025-09-18 05:02:44.876575-04
ACCESS_20250918180244_00001334	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	9c49e517-bb77-4a88-9f84-12e64ebb9ed6	8B0505E69E69BF5A1B3BEAA435731ABC	01	2025-09-18 05:02:44.922349-04
ACCESS_20250918180253_00001335	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	9d2ed950-bbcd-4db9-8d2c-6c4a2050948c	9FB19FE70E5F8E032A922AED693A4AC1	01	2025-09-18 05:02:53.170762-04
ACCESS_20250918180257_00001336	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	5a1f42d4-6100-4d2b-85db-787064953029	6ABCD17359593A364CFC9A3F0AAB9F29	01	2025-09-18 05:02:57.274492-04
ACCESS_20250918180300_00001337	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	83df4cfc-9ed4-41d5-a85c-2e0df6198234	703F128B530A9316562439E56427BB4E	01	2025-09-18 05:03:00.496285-04
ACCESS_20250918180304_00001338	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	77cb6450-66cc-4512-8626-2edced36bb1d	56834825B39BAADCD89BC4E8045FEF09	01	2025-09-18 05:03:04.995775-04
ACCESS_20250918180306_00001339	hckwak	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1	4e438369-8462-41a4-9bf2-b1b81d66f823	8965DA56A6F6EDA5D25E1449FAB846C4	01	2025-09-18 05:03:06.865252-04
ACCESS_20250923170454_00001396	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	20e92b4a-cfb8-4dcb-947e-7a1663365ba0	62D9CBE9BEA27D83B2D30FB395F22695	01	2025-09-23 04:04:54.897022-04
ACCESS_20250923170454_00001397	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	1080dee6-bc1a-4e6f-9c8e-1bf562a8a2b7	F91A255CD5FCF06EAF39051F952F95FD	01	2025-09-23 04:04:54.913269-04
ACCESS_20250923170504_00001398	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	16be1970-45e8-483d-8094-2fdfb4992ed0	9BD0302AF80CD1291AB60531C6C4AC80	01	2025-09-23 04:05:04.279883-04
ACCESS_20250924134517_00001445	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	7f988c7c-6b1e-4eea-b10b-0109f697168b	09A8196FA754A41B7AEEFDDE391C3763	01	2025-09-24 00:45:17.400873-04
ACCESS_20250924134521_00001447	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	1fdd2daa-c00c-4bc1-a362-fb6d2887f227	1446C2B34F9CBCD81DD9FB9A49177D35	01	2025-09-24 00:45:21.430298-04
ACCESS_20250924134527_00001448	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	9ab43870-c929-4230-b403-443fca253d23	3B3618F70EE4A5D96242BBEA0EF63C67	01	2025-09-24 00:45:27.391822-04
ACCESS_20250924134532_00001449	hckwak	GET	/api/v1/product/12	입/출/반품 관리 - 상세정보 조회	10.42.0.1	127b73cc-a5fd-4202-b74d-7fef8af97fba	E69AF5DF893277EA2FEEB3CAFDAB4872	01	2025-09-24 00:45:32.279555-04
ACCESS_20250925152856_00001462	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	3bd05808-353b-4ead-99e4-5325a4cf8f80	AD694C94BAC0B465F7A80D098CA1F4E3	01	2025-09-25 02:28:56.887075-04
ACCESS_20250925152857_00001463	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	4607df15-813b-40da-b9b9-c7170ab8f293	0176C930374E3778A5E278EA3A6BC64C	01	2025-09-25 02:28:57.337392-04
ACCESS_20250925152858_00001464	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1, 10.42.0.170	5feffe19-6eed-4810-ad0d-2ae2f76a4885	F8870161552564413CF4B6783231D193	01	2025-09-25 02:28:58.891826-04
ACCESS_20250925152900_00001465	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	bd6c90d4-845a-4d80-806b-2468ead3840a	E6D96FBCB7DA42BBC8A1AD439D851D0F	01	2025-09-25 02:29:00.464271-04
ACCESS_20250926163809_00001503	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	f7cac52d-042b-4ad4-8f29-9d18b901d084	876B680817BBF99A9FCCE388DF16678C	01	2025-09-26 03:38:09.579271-04
ACCESS_20250926163813_00001504	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	f0fc28c9-9e05-4510-ba3b-c6f493ca8fa3	3DC115C204D9165A2EAE31CE4BB60638	01	2025-09-26 03:38:13.203234-04
ACCESS_20250926163816_00001505	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1, 10.42.0.170	eaa9663f-e4a5-4afa-bf50-98ae3ea22f5e	6EAA7A3D3341F292076203009C8B15D9	01	2025-09-26 03:38:16.68316-04
ACCESS_20250926163906_00001506	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1, 10.42.0.170	1367d6f8-f4bb-4a0b-bc4b-93a88cb8da20	AE853D216E5F0F758511B127B2AA73D7	01	2025-09-26 03:39:06.463814-04
ACCESS_20250926163906_00001507	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	4f2d6336-9633-48e6-8fe0-2ac0bbc29b8d	B0A71D7152F0D9A3D216FBD7AAC48084	01	2025-09-26 03:39:06.508818-04
ACCESS_20250926163912_00001508	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	a88dc8b0-1ceb-4fef-bbe2-ec9c09aeb473	5E94A97DAFCE12DBAF86FB3E421933B4	01	2025-09-26 03:39:12.434662-04
ACCESS_20250926163925_00001509	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	2a99b3c0-e45f-4551-941b-f71fdbfc0d91	CFB47C8916911AFCC3CF1ACE0E995BA0	01	2025-09-26 03:39:25.276593-04
ACCESS_20250926163925_00001510	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1, 10.42.0.170	a39b7a18-ae22-4ddb-9fce-a9c16fe628b5	8B70DCFDB823839C8E120FC61F8C9BE2	01	2025-09-26 03:39:25.330575-04
ACCESS_20250926165137_00001552	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1, 10.42.0.170	06c039d6-10bd-4ff8-91d8-4e07d912e01f	5C533D6393C043913AFC5CD714CC2732	01	2025-09-26 03:51:37.952519-04
ACCESS_20250926165142_00001553	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1, 10.42.0.170	c493482d-0158-4860-a97a-4df80eb3199c	63FBB647C560B789D41E13231DE24E3B	01	2025-09-26 03:51:42.274433-04
ACCESS_20250926165144_00001554	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	cbda460d-d22d-4385-b6f2-1e56bf1f37f0	1B20088ABA6616F4C10520E4DF12DFE8	01	2025-09-26 03:51:44.091916-04
ACCESS_20250926165150_00001555	system	POST	/api/v1/outgoing/slock/eventLog	출고 이벤트로그 조회	10.42.0.1, 10.42.0.170	2b82adf4-491e-4fd5-8e23-f63597eb0ee4	ED348B6D2279C6F86355DD2327B79039	01	2025-09-26 03:51:50.0514-04
ACCESS_20250926165154_00001556	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	a81e15f5-45c2-41e1-8daf-9a4b58d1cf5c	8753758FABA30657B18D3593E10AE676	01	2025-09-26 03:51:54.718893-04
ACCESS_20250926165158_00001557	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	c644ea61-0159-419e-b21d-55d07accec99	04A5DA65DA364A633997EE723EB2F23C	01	2025-09-26 03:51:58.555506-04
ACCESS_20250926165202_00001558	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	6b8d21e3-daa2-4cc6-be07-72521f030f96	F95B77031F2DDACB5ECADB3927FAC76B	01	2025-09-26 03:52:02.184116-04
ACCESS_20250918132349_00000901	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	a109bbe2-9864-43e9-9e6b-8512784d5920	318C6CE27D2250CD9C7E7DBDFCE070CE	01	2025-09-18 00:23:49.955869-04
ACCESS_20250918132353_00000902	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	112b595a-f6fe-4c93-b4a0-4d671f05c135	4B842161F00F112872C01365B283CA03	01	2025-09-18 00:23:53.385061-04
ACCESS_20250918132359_00000903	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	729265a4-618a-4d83-9acd-905720422036	AC27680B5132C1458D20321F29CC2C63	01	2025-09-18 00:23:59.124671-04
ACCESS_20250918132402_00000904	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	63b7a14b-2d09-4580-9620-8c200f216413	4412C8DBF308923DE2F29F59B2C0911D	01	2025-09-18 00:24:02.075812-04
ACCESS_20250918132738_00000905	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	1ad71117-37f4-48aa-a84f-20dd44b14d4e	CE834C2355D8FB19F6CC81A98C40F5B9	01	2025-09-18 00:27:38.644093-04
ACCESS_20250918132739_00000906	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	531d31f1-aec0-4d34-a355-c274e6a8234e	D4A21108C51BC33E0BABEF392E5B4EF5	01	2025-09-18 00:27:39.89457-04
ACCESS_20250918132755_00000907	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	87cc78f6-ebed-4247-8cdf-7b26bd9fae02	949A68A5C7E344929145BD315CB3FFE5	01	2025-09-18 00:27:55.937973-04
ACCESS_20250918132816_00000908	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	ce060ad7-9f1b-43a1-b017-de7612340f62	9C564DCDFC8DC05E0217C61A7B791883	01	2025-09-18 00:28:16.446103-04
ACCESS_20250918132822_00000909	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	386156d4-47ed-4d12-baa8-a2553ad1a6c1	CF182E8D00328BB4253A4873FFF70CE5	01	2025-09-18 00:28:22.343841-04
ACCESS_20250918132832_00000910	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	48caba7e-8def-4dd1-bda1-b1efef6fac19	DF7E4C0BF158767970D98C8AE95DB67D	01	2025-09-18 00:28:32.911306-04
ACCESS_20250918133402_00000911	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	15a28b17-6846-4a25-aaea-0edaa2a2291b	0A7ADA07F31BA37368FE784AA1290394	01	2025-09-18 00:34:02.47523-04
ACCESS_20250918133403_00000912	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d972059d-59dd-4b9d-b7a9-c6a81f4c02b3	B03D21CB9A726EC264D92706F53F1D1D	01	2025-09-18 00:34:03.57971-04
ACCESS_20250918133412_00000913	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	a551d733-1abb-4455-83f8-d9fc21ed5330	4EE04A498DEDE1FA20F8B1C5D91D75D9	01	2025-09-18 00:34:12.489701-04
ACCESS_20250918134229_00000914	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	e4390388-2d7c-4578-8f6c-7ae00ed78848	825764A1B33916CF6B7FB70CC37F92A7	01	2025-09-18 00:42:29.179613-04
ACCESS_20250918134229_00000915	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	53c82b3f-5bd0-4e75-bb6d-a228f8c8ed11	2EF84A4035D53083BD010CB3335423D2	01	2025-09-18 00:42:29.179509-04
ACCESS_20250918134233_00000916	system	GET	/api/v1/home/dashboard/notices/2	대시보드 - 공지사항 상세정보 조회	10.42.0.1	a818c191-c35f-478f-bd11-5ab69688c27a	02A98E0CEA945A8ED70A461174DB9C5E	01	2025-09-18 00:42:33.674628-04
ACCESS_20250918134237_00000917	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	c2c2e5de-c4f4-410e-8664-c193ac1dd8a7	1A4D6D4D03063CD1AB944B34775462F2	01	2025-09-18 00:42:37.757499-04
ACCESS_20250918134239_00000918	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8fbb4484-3e1a-4aa9-bcf9-57f56045373c	E654C7CBCEB464C105FC82EE0DA1E1E7	01	2025-09-18 00:42:39.513022-04
ACCESS_20250918134243_00000919	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	14307a69-b160-4a33-a023-1248dd11d677	CCC3C8BE1F76B9F785245686C00F0139	01	2025-09-18 00:42:43.491893-04
ACCESS_20250918134243_00000920	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	3a4f81a6-621a-46ea-9fb1-82f9550cdeb1	1AC5216140DBC197B5C6F858C4987B72	01	2025-09-18 00:42:43.537889-04
ACCESS_20250918134244_00000921	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	e19c9140-6424-40db-837c-d32e2e2de416	654104D1EDD45E0FEE5E7A4118AC5128	01	2025-09-18 00:42:44.321522-04
ACCESS_20250918134252_00000922	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	60ed4112-8421-4810-9df6-1e555e88f81b	C7FD5F442AC27D170B08B68389F21DCC	01	2025-09-18 00:42:52.757913-04
ACCESS_20250918134255_00000923	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	517fdab4-8cbc-40d5-bd9a-1ac6e7ef0b07	9819B57E4165B816C7157A7F484DBA1C	01	2025-09-18 00:42:55.813896-04
ACCESS_20250918134256_00000924	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	bdaafe0a-7f98-4f8a-9c91-9ae887428a9d	C5539268B961212CC5E13AD00D481DEE	01	2025-09-18 00:42:56.971689-04
ACCESS_20250918134258_00000925	system	GET	/api/v1/ref/user/detail/daenahn	사용자 관리 - 상세정보 조회	10.42.0.1	b956f169-4553-49f7-90ff-095019ea1910	5497601F3EE179A27A8F4AB51766D842	01	2025-09-18 00:42:58.440778-04
ACCESS_20250918134737_00000926	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	21ad87ab-0544-4b98-b106-6683bf8805bc	AD92EADD2049B9697B63AE0602DA99A2	01	2025-09-18 00:47:37.838753-04
ACCESS_20250918134737_00000927	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	7913ba9b-3703-4d32-a42f-df6db184c17f	B73C7BC8EC4FF789E08D0D427DF4B00D	01	2025-09-18 00:47:37.853277-04
ACCESS_20250918134928_00000928	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	31862366-da32-4f84-9683-de588f81bd8d	6BE2697626BA8ACAF268A782C034F056	01	2025-09-18 00:49:28.387852-04
ACCESS_20250918134929_00000929	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	633eb15c-61c6-403d-a0fe-eef2e1e99f03	3CDF922E0F1069AAA64F1A8F6A99B3C4	01	2025-09-18 00:49:29.927427-04
ACCESS_20250918134936_00000930	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	b7e58baf-2328-452b-b0a5-f5d0cad76c21	D9E877463430776276AE334D110FD477	01	2025-09-18 00:49:36.767826-04
ACCESS_20250918134938_00000931	hckwak	GET	/api/v1/product/3	입/출/반품 관리 - 상세정보 조회	10.42.0.1	a11152ed-1412-4059-a75a-e6e1b8490702	347445431D45C170C44723F5DD592613	01	2025-09-18 00:49:38.443824-04
ACCESS_20250918134953_00000932	hckwak	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	777b6b6e-924c-4eab-b7f7-04b3cc65386e	C45AF85349CCF5A52AFF85D24CE08831	01	2025-09-18 00:49:53.389957-04
ACCESS_20250918134953_00000933	hckwak	GET	/api/v1/product/3	입/출/반품 관리 - 상세정보 조회	10.42.0.1	ce3d9045-1ac9-4c2f-9494-e61af9294289	E32E7457A1D1C78BAD573646438CAFC3	01	2025-09-18 00:49:53.394352-04
ACCESS_20250918135143_00000934	hckwak	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	bbb6b24c-82c9-476f-81c4-e45c0e13bdf0	DF19EFE83D0F31F1A0CA79B73202E490	01	2025-09-18 00:51:43.120146-04
ACCESS_20250918135143_00000935	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	85509857-0880-4759-82c0-18fd88bc6154	02D4D4BA680C82762516740A401C215D	01	2025-09-18 00:51:43.171739-04
ACCESS_20250918135147_00000936	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	3fe91e65-4315-4194-b030-27dbb2d93d7a	A0D529D6ADCB1882CA237E02F6B24399	01	2025-09-18 00:51:47.307452-04
ACCESS_20250918135152_00000937	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5c700df1-93b0-434f-b9e0-49fcd2df379c	C88EBB6458CED949106837A2C03C073E	01	2025-09-18 00:51:52.8632-04
ACCESS_20250918135156_00000938	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	6e75f2aa-bd5b-422f-af86-b0eaec19ff57	5CA3A5D931EB9DF8D35F5A433437571B	01	2025-09-18 00:51:56.18256-04
ACCESS_20250918135200_00000939	hckwak	POST	/api/v1/product/slock/connect	sLock 초기화 - 기기연결(자물쇠)	10.42.0.1	6fb4f1bc-ae44-4e77-83b2-ee3103e6febb	BC6CE5564F3486A099E5C503A6FE1FB8	01	2025-09-18 00:52:00.278436-04
ACCESS_20250918135226_00000940	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	c4c706e6-f95a-472e-9c22-a97cce7e1f02	F846DFB9A0D1AC806E4E6945DC2BDDCC	01	2025-09-18 00:52:26.045766-04
ACCESS_20250918135229_00000941	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	6af87a01-639f-419f-b07f-4f8b2a22bb10	E26CBEF350EA7C7B3E59E0D70858F4BE	01	2025-09-18 00:52:29.158961-04
ACCESS_20250918135233_00000942	hckwak	POST	/api/v1/product/slock/connect	sLock 초기화 - 기기연결(자물쇠)	10.42.0.1	a8fb9db1-db6d-45fe-aa40-d75a5a7188a0	377BD968C88998A85A9CC6696D90884C	01	2025-09-18 00:52:33.447153-04
ACCESS_20250918135244_00000943	hckwak	POST	/api/v1/product/slock/detail	sLock 초기화 - 설정값 조회(자물쇠)	10.42.0.1	5ce30bc7-078b-4cad-8878-bfd2a0072b74	7907529A33ED6BC938A18207C266FEC0	01	2025-09-18 00:52:44.136256-04
ACCESS_20250918135252_00000944	hckwak	PUT	/api/v1/product/slock	sLock 초기화 - 설정값 초기화(자물쇠)	10.42.0.1	65330fbc-ba6c-4d03-b36c-02ab18763639	627315EF0AB184E47948403D07EE95C4	01	2025-09-18 00:52:52.565557-04
ACCESS_20250918135256_00000945	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	7a999bba-6200-4808-a28c-ca5403cd1895	FE2F9E7F2E413083670A321675E03D48	01	2025-09-18 00:52:56.092802-04
ACCESS_20250918135306_00000946	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	50174a39-dab6-4d5b-ba67-dbc3192f5c1e	1B2E26A03461DB3B101D912A946F2806	01	2025-09-18 00:53:06.647981-04
ACCESS_20250918135321_00000947	hckwak	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	04b7dfd1-e44c-4a31-ae60-7c332204d650	4741B5B154B63CE891288A7A96B8D50B	01	2025-09-18 00:53:21.920373-04
ACCESS_20250918135326_00000948	hckwak	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	79fc9141-15f0-4dcd-8da3-68a8a98e822f	E8BA0B9EA0D6B251803417F617C87DAB	01	2025-09-18 00:53:26.070326-04
ACCESS_20250918135359_00000949	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	9e4ee3d9-38aa-4ce7-bf1d-42df0eae7df5	00E7CEDBCAF4BDFD405C860432B7542E	01	2025-09-18 00:53:59.878779-04
ACCESS_20250918135359_00000950	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	aa998769-d8fb-4c81-b902-1f6841f8e722	569491301359F4A66E7F9CA9D3492791	01	2025-09-18 00:53:59.939698-04
ACCESS_20250918135416_00000951	hckwak	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1	bc279c38-0799-45bc-b277-09ab6e4e08ef	DFF0DB8B1186DE9F692964CDC800D943	01	2025-09-18 00:54:16.622884-04
ACCESS_20250918135416_00000952	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	2c90c585-aa71-4627-903f-a936782f324b	DE6A3DC3663F877DF7EAC992ACBE17AB	01	2025-09-18 00:54:16.674973-04
ACCESS_20250918135416_00000953	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	32e597e2-ffed-4c74-a865-9500fc7bb4ab	C2011208134F8AC96D983B0390C85DC1	01	2025-09-18 00:54:16.706056-04
ACCESS_20250918135418_00000954	hckwak	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	1c90f5f5-9183-409f-9dd2-7f58d275d1e0	78EFDE7B96460A9F1A21D0018E96E7F2	01	2025-09-18 00:54:18.502566-04
ACCESS_20250918135423_00000955	hckwak	DELETE	/api/v1/ref/organizations/JW000022	조직 관리 - 삭제	10.42.0.1	5fd5f2d1-abd5-4d96-ba85-eb6bf8304340	3859EC8C403351E0B4B2D38DA8D418DC	01	2025-09-18 00:54:23.535215-04
ACCESS_20250918135423_00000956	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	ab6eadca-cdde-4260-9b69-a30d48de7ca8	1B2A581AFD087458B54203C8BC5DA098	01	2025-09-18 00:54:23.583507-04
ACCESS_20250918135426_00000957	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	bb1ef0cf-cd5f-4048-a36f-04e8f571877d	34305F853205D3EA498C34FAF2B60942	01	2025-09-18 00:54:26.331429-04
ACCESS_20250918135430_00000958	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	ec2b9a6d-57c7-4c13-b706-d25a7ec02462	E3AD8D72C412E345E7081E91990429D7	01	2025-09-18 00:54:30.6794-04
ACCESS_20250918135433_00000959	hckwak	GET	/api/v1/ref/user/detail/daenahn	사용자 관리 - 상세정보 조회	10.42.0.1	3dcb8177-47a4-4306-8eef-0a7eb0209f6c	2E893CCC9E1C389CAC54C59E2FBEC8F1	01	2025-09-18 00:54:33.098081-04
ACCESS_20250918135440_00000960	hckwak	GET	/api/v1/ref/user/detail/daenahn	사용자 관리 - 상세정보 조회	10.42.0.1	19ff848e-e28c-45e3-87f7-99f8b835caed	4AE9FEAA00AAAB7330FC33E7A720516F	01	2025-09-18 00:54:40.518565-04
ACCESS_20250918135446_00000961	hckwak	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	24603733-677d-4e44-8afe-2f5637686d40	ADD87DFC54F40887C47DEF7EFEE7F2DC	01	2025-09-18 00:54:46.138117-04
ACCESS_20250918135446_00000962	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	a25de79d-5fb0-47c0-8a8a-a5288458284c	61C517BDCC2665F3D22B54862301ACCA	01	2025-09-18 00:54:46.164833-04
ACCESS_20250918135446_00000963	hckwak	GET	/api/v1/ref/user/detail/daenahn	사용자 관리 - 상세정보 조회	10.42.0.1	106620f5-666d-4ffb-82cd-eb20f909d6b4	61C517BDCC2665F3D22B54862301ACCA	01	2025-09-18 00:54:46.165065-04
ACCESS_20250918135458_00000964	daenahn	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	027ed092-4e85-4002-a1f6-01639f296db4	22C9F39D5D27958E2C651B68842D2224	01	2025-09-18 00:54:58.423227-04
ACCESS_20250918135458_00000965	daenahn	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	6c1720e2-2e31-431e-8496-ea05d56aa0c4	62CAFFB196AE7E39BC12053E89756747	01	2025-09-18 00:54:58.424664-04
ACCESS_20250918135510_00000966	daenahn	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	8f0016e2-0a9d-4c6d-b81c-51cc2b752263	1787B5EB738CC53575773A882CDAE1B9	01	2025-09-18 00:55:10.580205-04
ACCESS_20250918135512_00000967	daenahn	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	bdcced8c-f0e4-4d9b-8b4c-9c0a9771ea2c	7B1746D89936DF10F3188E561AC0C69D	01	2025-09-18 00:55:12.782771-04
ACCESS_20250918135513_00000968	daenahn	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b00cd198-7286-4a65-9a9a-60fc5056c09b	6BF2220FBDA3E09CFE945FD31E21B1D3	01	2025-09-18 00:55:13.94768-04
ACCESS_20250918135518_00000969	daenahn	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	aadcc345-b3d4-4282-9d8f-3b1596eea54b	A85CAE2B148CA9FC7BA4DAD8036D1ADC	01	2025-09-18 00:55:18.127028-04
ACCESS_20250918135518_00000970	daenahn	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	80c7d438-1e7e-471a-906f-7ebae8602787	EFF841C5BEF5BDCE3F149DE4A27FB361	01	2025-09-18 00:55:18.135981-04
ACCESS_20250918135558_00000971	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	5d3c1d6f-a51e-4cdf-b0a0-dd743f3e1bcb	36C0108AA0020F63E5615C5222F97C8E	01	2025-09-18 00:55:58.530533-04
ACCESS_20250918135558_00000972	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	980275b7-e288-4336-bf81-6288c3faf205	594F1960E94E3AEAB068FF3681E70940	01	2025-09-18 00:55:58.532961-04
ACCESS_20250918135603_00000973	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	b931038f-bbbf-4203-9a66-f3e403962226	2E71424B526CE2CF8AB9BA34A2AD155A	01	2025-09-18 00:56:03.022347-04
ACCESS_20250918135604_00000974	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	81a5d250-4a34-4b8c-a1bf-d495206ad440	E573F34029A1C49BA737A716E56F954F	01	2025-09-18 00:56:04.822428-04
ACCESS_20250918174607_00001260	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	24f94af8-9cca-4724-ad0a-66c8c99a3836	38C1FDDDCBAE322AC7B781766FC660CD	01	2025-09-18 04:46:07.258672-04
ACCESS_20250918174609_00001261	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	a846b31c-3e5c-4f1d-8cb4-f6e9ada6a1ca	C7CC50B07E0F59649C1B1AE07F44BD20	01	2025-09-18 04:46:09.953755-04
ACCESS_20250919160928_00001340	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	cbfce95d-3d29-46de-bdd2-db8eca87b778	803B36ADF5B4261B850A37217E197249	01	2025-09-19 03:09:28.918832-04
ACCESS_20250919160959_00001345	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	8533a8b3-16b8-4bb1-963e-df5a413b8ef6	D142353B2A89AE548AC500481DF54914	01	2025-09-19 03:09:59.864762-04
ACCESS_20250919161015_00001346	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	1b7b91f3-2023-400e-a095-092930c044e1	ABB43282C6CFBC555CD2D6160D61EB2B	01	2025-09-19 03:10:15.256187-04
ACCESS_20250923172128_00001399	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	8a67bac8-e21f-48c4-9203-61a4fcee1f22	587DA21AAC81B7A1FE11C2DDD3651AAC	01	2025-09-23 04:21:28.931354-04
ACCESS_20250923172131_00001400	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	b1a524af-9d75-43a8-aef8-7a559bcc6a07	8EADA9E9E9B418881B426AE48F851BB9	01	2025-09-23 04:21:31.675935-04
ACCESS_20250923172134_00001401	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	1f000bfb-4dba-410a-9384-71f116e2695b	08D043C96933F8ADF44110B68F6AD69D	01	2025-09-23 04:21:34.681475-04
ACCESS_20250923172144_00001402	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	bf8f33f3-44e0-4f88-808d-04b9c143352c	0CCC8BF61E3CD17CD506B573DA64F234	01	2025-09-23 04:21:44.429315-04
ACCESS_20250924134517_00001446	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	275ed905-d8d7-422d-8497-dacfd2229dc5	0F0B12EBDDD6A8DDC43A36BAD815CA17	01	2025-09-24 00:45:17.403737-04
ACCESS_20250925152917_00001466	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	63b7538d-fdcd-418e-8a1d-4e5bc43feba4	3A78F09C8CF377C6ECE583EB288E49DE	01	2025-09-25 02:29:17.374204-04
ACCESS_20250925152917_00001467	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	542262cd-57ae-455f-8b10-659cfc7607e1	3203069C94181001D7D88272EB5A85FE	01	2025-09-25 02:29:17.732645-04
ACCESS_20250926163941_00001511	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	6cb79d8f-8cdc-45b5-ac33-7fe8980157b0	CB0B8D39593970B34F08E5F70B9B2359	01	2025-09-26 03:39:41.720599-04
ACCESS_20250926164014_00001512	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1, 10.42.0.170	0bfbfcdb-d24e-4076-81df-c112fd88c588	0FCB295E86929A7FFA750F3C8C824CC9	01	2025-09-26 03:40:14.496733-04
ACCESS_20250926164020_00001513	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1, 10.42.0.170	813386a2-195d-4ed6-8eb6-be3c35b883d2	4BC9DE555534AFAD9C43445070C14712	01	2025-09-26 03:40:20.924796-04
ACCESS_20250926165206_00001559	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	c99bb7b7-62cf-407e-a194-ea95f8ac9a67	6837F210044FC3041C4A8852A62B3D82	01	2025-09-26 03:52:06.618255-04
ACCESS_20250926165215_00001560	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1, 10.42.0.170	234355a7-3d32-4ca8-8e4d-19083f0225f1	D73655D137EDFB0DA039A6A55EBA5E42	01	2025-09-26 03:52:15.368508-04
ACCESS_20250926165215_00001561	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	c3991ebb-07b0-40aa-96c4-60e26ff1b8ca	03588B195F58BCB59C11BA6CDE3A1C43	01	2025-09-26 03:52:15.406674-04
ACCESS_20250926165223_00001562	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	fe4ca2a3-40ff-421a-9f1b-a57e3b12dddc	94D72D569691D6FAED72560F3F25AA53	01	2025-09-26 03:52:23.256519-04
ACCESS_20250926165225_00001563	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	7fd9d7ee-7589-47b0-9c01-8361fa95ee5e	E5A674AB5EAE2732EB01D70B10C33446	01	2025-09-26 03:52:25.989282-04
ACCESS_20250930145440_00001587	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	cdf5126f-4399-4cd0-a220-1ec107f0e7f4	B0B7604A2B656723298597E6061553CF	01	2025-09-30 01:54:40.068708-04
ACCESS_20250930145458_00001588	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	720ed8f5-1acb-486b-9906-38cb9f7aba9b	DEF788F65B85FD02ECF2CFE506D8CFEC	01	2025-09-30 01:54:58.830942-04
ACCESS_20250930150505_00001608	system	GET	/api/v1/home/dashboard/products/models/9	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1, 10.42.0.170	1d2bb394-1c0b-49db-b743-17cc386e97b4	8CB0D097005DF50E80CECF5747AE7BE4	01	2025-09-30 02:05:05.797182-04
ACCESS_20251002105629_00001624	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	5ce3aa7d-22ce-42c9-afdc-c1bfdc974e7d	E56CA2AD9ED0C265B7FEBD929BE727BA	01	2025-10-01 21:56:29.996637-04
ACCESS_20251002105630_00001626	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1, 10.42.0.170	b27ffae5-e6da-48f7-b357-a7ce19e9fd49	E1BC3C4CCE5875CBF342AE1AA10761B8	01	2025-10-01 21:56:30.737717-04
ACCESS_20251002110120_00001629	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1, 10.42.0.170	44350026-fe88-4d5b-99ad-9315b5d1e281	3DE44A1A17F344B355CEE1249E8EF2D3	01	2025-10-01 22:01:20.614843-04
ACCESS_20251002110121_00001630	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1, 10.42.0.170	5710a789-6bcc-49e3-92b5-b1e1db569500	1B8FFF6D6ECE13E1AFF3C4A893856620	01	2025-10-01 22:01:21.450217-04
ACCESS_20251002110122_00001631	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1, 10.42.0.170	abf38451-5932-48be-97b4-d103284405c7	6D40A5AEE16915451E17479D873FF1A8	01	2025-10-01 22:01:22.532609-04
ACCESS_20251002110123_00001632	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1, 10.42.0.170	5db9dff1-3746-458f-904e-76a47622ac07	13445FE4D8D46F0B61234199ACB00CEB	01	2025-10-01 22:01:23.103911-04
ACCESS_20251002110123_00001633	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1, 10.42.0.170	baf4a22f-9bb6-4a7f-9bbe-2e34926e470b	8E79BEFBC5DD655D0E034D8C00E09326	01	2025-10-01 22:01:23.698929-04
ACCESS_20251002155931_00001637	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	f090ed18-05f6-4704-9f26-dac836ed45b8	DACB5CAC01CD2639D2EFBB645DD7E4BD	01	2025-10-02 02:59:31.641475-04
ACCESS_20251002155941_00001638	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	aa17243a-6336-4c9e-8185-cc7f6fafb369	7E58E0881E308DF300C883DB941107CF	01	2025-10-02 02:59:41.012076-04
ACCESS_20251002155941_00001639	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	22ebba78-ff03-4b07-910c-1bc30284c35a	18E3B3AFBDF572DD37D8B55F7A52741D	01	2025-10-02 02:59:41.056718-04
ACCESS_20251002155942_00001640	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	dcf76268-1d32-4236-8ae2-7d25bcde38ac	504115E4EBA0C8D93BC3ACA9A579AA90	01	2025-10-02 02:59:42.71527-04
ACCESS_20250918135744_00000975	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	0964f1e0-af05-48c5-aeca-7e68721198f7	BCBFAFD58EC7539D00C3AB975B413728	01	2025-09-18 00:57:44.55622-04
ACCESS_20250918135744_00000976	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	67a1d431-e8be-4a53-ad31-c6f29e0754ea	F60DB2ECC3AFD60713D1CD388FBAAE61	01	2025-09-18 00:57:44.557786-04
ACCESS_20250918135749_00000977	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	7e47a75c-5446-4e61-a21a-6d55c83485ad	DFFD7E18C09DF832D2ADD782760B3F8D	01	2025-09-18 00:57:49.556855-04
ACCESS_20250918135801_00000978	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	c056e1ef-8b79-4124-8d5a-052dcd819009	7176EBC7BB7C50C31424D3E4A292DE65	01	2025-09-18 00:58:01.798449-04
ACCESS_20250918135801_00000979	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	36d0aa00-6831-4074-bd7c-0f6e99fb8a47	AC138C376B93991A30D8AA9788A4346F	01	2025-09-18 00:58:01.859584-04
ACCESS_20250918135809_00000980	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	5350ef1d-b9f7-43f9-a08b-f908116f0833	FC11DACEEF1FB28A01A99F6DAF2C9F8B	01	2025-09-18 00:58:09.61507-04
ACCESS_20250918135825_00000981	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	6ad3d605-7560-4962-b79d-35c0b37de0db	552D6F7B5E88DC9767C8496219D65130	01	2025-09-18 00:58:25.790034-04
ACCESS_20250918174619_00001262	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	5bf0b016-77dc-40d2-ad9e-6bb302768130	D6931DEA5328A0F8270887072D967680	01	2025-09-18 04:46:19.378137-04
ACCESS_20250918135911_00000983	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	1360c130-9ae8-4f0d-8355-78de601ec4db	AE7B1AEEF385658FF5A300B3434B0358	01	2025-09-18 00:59:11.574906-04
ACCESS_20250918135911_00000984	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	944c8790-e03c-4cc2-9cc0-3c34f14ff91b	BF15C7C3CB5F86FC54A21640F5D860E2	01	2025-09-18 00:59:11.617755-04
ACCESS_20250918135918_00000985	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	48e2edac-1015-47cd-90e0-4e1626ef4d58	7F73F00F29C5D82BE9CE32F64E92AED7	01	2025-09-18 00:59:18.110213-04
ACCESS_20250918135924_00000986	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b80f6db6-271d-40bf-bb82-3294d3064eca	8E3735072D6DFD1201016DDE8875019D	01	2025-09-18 00:59:24.230452-04
ACCESS_20250918135933_00000987	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	bf1a8f7c-9cdf-4455-b606-4f5ca17b9e68	C3A0DC5628837F6BB7D84E48A58C8C8D	01	2025-09-18 00:59:33.598613-04
ACCESS_20250918135937_00000988	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	69f0ab03-0065-4879-a56c-be82e2adf28e	8445740E82A2EEFB9AAC4911D2AB5C6C	01	2025-09-18 00:59:37.823062-04
ACCESS_20250918135939_00000989	hckwak	GET	/api/v1/ref/customers/GlobalJW	고객사 관리 - 상세정보 조회	10.42.0.1	9a9a9596-b5f8-4d8c-ab8c-4e9f7f242639	4E42E119D4E10A8D3C79237E01DE2C89	01	2025-09-18 00:59:39.735678-04
ACCESS_20250918135945_00000990	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	9faec33d-09ed-4d63-8c21-9ea577c78c31	CE5D40591619AF54C8ABA5111A7332AA	01	2025-09-18 00:59:45.31913-04
ACCESS_20250918135946_00000991	hckwak	GET	/api/v1/ref/customers/koiware	고객사 관리 - 상세정보 조회	10.42.0.1	728889bd-0ae9-4983-b7c2-72493f52e01d	742C5E780F23D65F6E02FC1237235A5A	01	2025-09-18 00:59:46.340512-04
ACCESS_20250918135948_00000992	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	c02212da-f0f6-440b-8aa3-5d0d5576d7d2	4F83850D7EB6AB6DC7E0AF8634F4B785	01	2025-09-18 00:59:48.821251-04
ACCESS_20250918135953_00000993	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	e6704a15-133a-4bbf-883f-c6c42efc50c2	637B6030C1D1D71321C4EC5C8F511D15	01	2025-09-18 00:59:53.892606-04
ACCESS_20250918135956_00000994	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	71d8a86d-19d6-45ca-a7e3-12e0b543f14e	C3F36564697657DBD9B501C149CADF61	01	2025-09-18 00:59:56.493309-04
ACCESS_20250918135956_00000995	hckwak	PUT	/api/v1/ref/customers/koiware	고객사 관리 - 수정	10.42.0.1	0bfc7965-e2b5-4b60-8776-504674e5a1c5	75BE49AFB2153DCDEAC93E69C7EC8CF8	01	2025-09-18 00:59:56.500354-04
ACCESS_20250918135956_00000996	hckwak	GET	/api/v1/ref/customers/koiware	고객사 관리 - 상세정보 조회	10.42.0.1	853238ac-6db6-4ded-836f-1ce52d25af97	9CE63F88EEF50C9D6A9BAFA64FF4720B	01	2025-09-18 00:59:56.558374-04
ACCESS_20250918135956_00000997	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	7f146bc7-02de-43f9-8702-d51976f3bb11	9CE63F88EEF50C9D6A9BAFA64FF4720B	01	2025-09-18 00:59:56.558477-04
ACCESS_20250918140002_00000998	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	523f8efe-964f-4580-9489-4e169d76c714	A04E151A7E6DB393EBA75214EECAA8E7	01	2025-09-18 01:00:02.992478-04
ACCESS_20250918140007_00000999	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	790379e5-3e37-4406-9d74-dd370b4daf27	2069853AD2F10C54C7EB55B22646FCB5	01	2025-09-18 01:00:07.309574-04
ACCESS_20250918140007_00001000	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	699eab54-bb14-41a2-84b2-12a76c6b543e	ED15D515A7D6CD91D9F98B9E1E3B3E00	01	2025-09-18 01:00:07.338001-04
ACCESS_20250918140010_00001001	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	8907ffc3-6114-4a27-949e-87b2322dc44b	8494B2932C7C7E243E908E847762FE28	01	2025-09-18 01:00:10.981272-04
ACCESS_20250918140013_00001002	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	6ecf8cc7-08ba-40f9-9d54-a70dcb796c4d	554938B8F2BA2B0F31ADD1B107119706	01	2025-09-18 01:00:13.370948-04
ACCESS_20250918140013_00001003	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	c1eedb40-bebe-4059-aa42-1485c545e3b0	9C6309E25058F1757ED5CD993DED0239	01	2025-09-18 01:00:13.800995-04
ACCESS_20250918140018_00001004	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	87bf26b6-e75a-4b11-b31e-bd3ccd8f028c	33B96E5E91878FDD99D23CAB64B876C6	01	2025-09-18 01:00:18.270475-04
ACCESS_20250918140019_00001005	hckwak	GET	/api/v1/ref/customers/koiware	고객사 관리 - 상세정보 조회	10.42.0.1	47a5d786-05ce-497c-b373-438355c7b10b	7D16B1B995CCDECC74E51B1BC98A7D2C	01	2025-09-18 01:00:19.279497-04
ACCESS_20250918140020_00001006	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b3623b1d-ae75-401f-9323-b559ea788958	AAAAFC308F7D347AC48539800C87886B	01	2025-09-18 01:00:20.567492-04
ACCESS_20250918140024_00001007	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	3ca8df77-11bc-47cc-b1b5-bf9c42eb0bbe	22046ECF617A00280220111E184BF330	01	2025-09-18 01:00:24.474463-04
ACCESS_20250918140024_00001008	hckwak	PUT	/api/v1/ref/customers/koiware	고객사 관리 - 수정	10.42.0.1	fbe84a13-d0b9-4182-82c1-92f45a9297a8	22046ECF617A00280220111E184BF330	01	2025-09-18 01:00:24.474622-04
ACCESS_20250918140024_00001009	hckwak	GET	/api/v1/ref/customers/koiware	고객사 관리 - 상세정보 조회	10.42.0.1	35e4a614-2b0e-4782-9d11-d35daeeff929	EB4A1A356DCDF4A72361F7D9B25B32B0	01	2025-09-18 01:00:24.502051-04
ACCESS_20250918140024_00001010	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	d3c22d5f-1690-499e-a5aa-4ba0aa5dc6f1	EB4A1A356DCDF4A72361F7D9B25B32B0	01	2025-09-18 01:00:24.502106-04
ACCESS_20250918140027_00001011	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	c1dbb590-fbef-4ddb-ba32-6e2a8a96a51e	834C652FB1BC20956E02457E85889ABD	01	2025-09-18 01:00:27.996262-04
ACCESS_20250918140037_00001013	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	1a654781-ac3f-491a-9b9f-91f3c77c5032	0E6C0913F8E4B4A8304DA27701A3FFC0	01	2025-09-18 01:00:37.633743-04
ACCESS_20250918140039_00001014	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	fdf97d11-69a3-402d-93fc-908f5466c396	A32A2D05ACBD5E0034E3A81BBB3C50A6	01	2025-09-18 01:00:39.293858-04
ACCESS_20250918140045_00001015	hckwak	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	512892cc-507d-4d9d-aa93-dc7d0fa09b07	6F1A7702DED11E6DE47867912C24032F	01	2025-09-18 01:00:45.291427-04
ACCESS_20250918174758_00001263	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	868b7ea4-b082-4984-a82e-e7befc8739b5	FDDB78868B670425C8DCB09C15DF144A	01	2025-09-18 04:47:58.668229-04
ACCESS_20250918174801_00001264	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	4c59a3c4-74d5-4259-b6b2-b436492650fd	71AEB16008B8460809DFAB24356BD57A	01	2025-09-18 04:48:01.371078-04
ACCESS_20250918174805_00001265	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	69c36959-135c-49e7-88eb-b6eff2311c4f	7B1CD168A832B0AD76B44AFAD60CD523	01	2025-09-18 04:48:05.601955-04
ACCESS_20250919160928_00001341	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	3ee63bc4-f6e1-40dc-b8ef-4e3ddb96c2ad	C680547576D0B7243CCEC2B57AB9990B	01	2025-09-19 03:09:28.919172-04
ACCESS_20250919160939_00001342	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	55b9cead-a7d5-402f-b55c-415044a52b25	ECA2585D99A8A890276A341F53C6772E	01	2025-09-19 03:09:39.602904-04
ACCESS_20250919160942_00001343	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	ad2ccd31-2025-48b9-bd94-a2d882ca835c	05A6CC52F084A232AE731575986DAB0E	01	2025-09-19 03:09:42.313205-04
ACCESS_20250919160946_00001344	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	8a55527b-e83b-4da1-9855-04bb456fc3ee	D1EAC0BFA64C644335D92A7FDF5080D5	01	2025-09-19 03:09:46.48953-04
ACCESS_20250923172439_00001403	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	c7470553-8d96-4a30-a28c-aa9b73d8b658	A0FB9014189EC1B3840E931484465FD5	01	2025-09-23 04:24:39.551785-04
ACCESS_20250924173203_00001450	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	09db90d7-e7e8-4922-ad5f-f80fd36b5b80	37C3614A63854DBB410FFB5469CDC61F	01	2025-09-24 04:32:03.942185-04
ACCESS_20250926150342_00001468	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	398f3295-495c-422d-b8d3-6e1afd9c0da4	12A22D278D271E40E4CC98B18DE7F4F6	01	2025-09-26 02:03:42.39598-04
ACCESS_20250926164022_00001514	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	89d5c34a-ccb7-4f5f-a1d6-42ea0421fdb3	910E1C8E5D639F023C34B126214D93D1	01	2025-09-26 03:40:22.69899-04
ACCESS_20250926164029_00001515	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	e75808ae-c8c9-4d90-b950-3b68c232e302	ACCCDEE532DD0EFEDB2DDF0CD6A521C0	01	2025-09-26 03:40:29.914415-04
ACCESS_20250926164034_00001516	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	62df82e5-31ac-42b5-b218-6bb346a4f108	2051F9EAB5F9693D7C6F84F359433003	01	2025-09-26 03:40:34.17209-04
ACCESS_20250926164038_00001517	system	POST	/api/v1/outgoing/slock/eventLog	출고 이벤트로그 조회	10.42.0.1, 10.42.0.170	6e1490d3-b107-4bba-b82c-40c267b2752b	B5B4D7DDFDB4D904F0C8F3DE40053FE0	01	2025-09-26 03:40:38.11824-04
ACCESS_20250926164045_00001518	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	2be19ed4-0b39-4562-a9b9-acbe5276374c	500921E133FE2DDC12BE2EF786BFACAC	01	2025-09-26 03:40:45.848947-04
ACCESS_20250926164049_00001519	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	218c01bc-d8ba-4f4b-9663-080f133f0b3c	F17A297C8FDF2E33144F55A4862D782B	01	2025-09-26 03:40:49.395493-04
ACCESS_20250926165251_00001564	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	a7276309-6621-455c-b914-2d31b13d4a0e	8C0193F6CBE9D2177A23EE72F311C740	01	2025-09-26 03:52:51.380026-04
ACCESS_20250926165255_00001565	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1, 10.42.0.170	b2aabd51-3bc0-4e4d-89b1-f951a9e3ed29	35F6C27183AFE3CA914D082AEBE408FC	01	2025-09-26 03:52:55.876262-04
ACCESS_20250930145458_00001589	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	0ee4ace8-882d-4c42-b4aa-c4e500394589	81EC23FE6E6BA857A1EE953516A42448	01	2025-09-30 01:54:58.831324-04
ACCESS_20250930151243_00001609	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	3c256b9c-3c46-4488-bcf2-ccb635f440eb	17485B62C7933DE9AC2980820C406CBE	01	2025-09-30 02:12:43.822479-04
ACCESS_20250930151244_00001610	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	f10e3e3a-5121-4de0-829a-d926fc8ce6be	23B1D8BE8D8C86F26EDC22417FD7C040	01	2025-09-30 02:12:44.130881-04
ACCESS_20250930151252_00001611	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	b2c46072-42b8-4e73-9561-d58337082fa3	CA47BF9E7AF44C3E2668AAB02723187A	01	2025-09-30 02:12:52.288179-04
ACCESS_20251002105630_00001625	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	75d36c45-9b9d-4334-9878-c59f6cf33d1c	1D800A8F960920CEBBAFE08E5168AB76	01	2025-10-01 21:56:30.088382-04
ACCESS_20251002110722_00001634	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	57d4321f-f6c9-4bd5-8351-e4c8125fe3c7	ED93EF2E4E54C11BA37B070A719063BA	01	2025-10-01 22:07:22.580672-04
ACCESS_20251002110722_00001635	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	5a114037-75f9-49ce-a0d1-31cbccb9fac4	64DE63E7672A53FF1EF655C98EA44A38	01	2025-10-01 22:07:22.60801-04
ACCESS_20251002155931_00001636	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	d3aab79f-e7a8-4a91-992d-f4a418c25ed0	427DDA9B152E2BFC7A0376F1DD93AA31	01	2025-10-02 02:59:31.64146-04
ACCESS_20251002155943_00001641	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	b374d763-fb70-4580-a095-7698e65988ec	A45B140309943846B2ADF1C14673CE57	01	2025-10-02 02:59:43.343478-04
ACCESS_20251002155943_00001642	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	18f70ae9-dfd2-449f-b619-f56090af3cf0	208B3EC71ACA599805E2C5D7AA40CDD8	01	2025-10-02 02:59:43.871026-04
ACCESS_20251002155945_00001643	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	f01617b2-8ef0-4d63-a167-cb86b940b0a8	4C6577940781210FD76DBA912C4E64B9	01	2025-10-02 02:59:45.275519-04
ACCESS_20251002155947_00001644	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	d0f0b22a-1fa6-4a77-844b-cb250d677a6b	1037634A1E773306D4B0CD5A4955B488	01	2025-10-02 02:59:47.366686-04
ACCESS_20250918140032_00001012	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	7d96136e-6a46-4753-ae35-086834ef2431	BE5E793AA09E767DECE6161A2FCCB831	01	2025-09-18 01:00:32.579565-04
ACCESS_20250918140050_00001016	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	3ec9e1d2-4874-407f-9fd6-e3a308829b9d	9F882C5A19F3E2541D9980A056357837	01	2025-09-18 01:00:50.116555-04
ACCESS_20250918140132_00001017	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	cbbc0943-7cbb-41ad-8701-fb92bada45d0	D666B50F2FFA3222E1BF45616719E8FD	01	2025-09-18 01:01:32.790454-04
ACCESS_20250918140132_00001018	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	6ad0d06f-9e86-473e-9a6c-1d0d720ac3dd	C2D49CC291C785F30E03B751D6A5E30F	01	2025-09-18 01:01:32.795514-04
ACCESS_20250918140137_00001019	hckwak	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	8dcabfb2-bd9f-4a72-9244-6aeae9de2312	2C615AA17E2F35273D01809A3CAA1786	01	2025-09-18 01:01:37.06912-04
ACCESS_20250918140138_00001020	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	fa110626-f2da-42fb-94bc-bff63aa8d5ce	4B955B6913E9C3ED17DCA4621C11D970	01	2025-09-18 01:01:38.739941-04
ACCESS_20250918140138_00001021	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	0454a12b-7429-4a6e-bb79-8dbf83f4dfe2	4B955B6913E9C3ED17DCA4621C11D970	01	2025-09-18 01:01:38.739944-04
ACCESS_20250918140142_00001022	hckwak	GET	/api/v1/home/dashboard/products/models/1	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	1a151581-bfcf-4db6-810c-bce583686c7f	B58CC08D154B347ECC63B05A119FB630	01	2025-09-18 01:01:42.938709-04
ACCESS_20250918140146_00001023	hckwak	GET	/api/v1/home/dashboard/products/models/1	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	6d63f362-2cf7-4c5f-995d-be28048f144e	2A4E390009232308AA108ADBB8F838F2	01	2025-09-18 01:01:46.43066-04
ACCESS_20250918140148_00001024	hckwak	GET	/api/v1/home/dashboard/products/models/1	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	9a19b926-1868-4f6f-b017-64b481b63471	01F54C7903CA1C08F4E0A45A3734C882	01	2025-09-18 01:01:48.294536-04
ACCESS_20250918140156_00001025	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	0b3b95ca-24e2-4ee9-991f-e1c2ef7b5418	D91A95C84773C63EC9BF15618898AF89	01	2025-09-18 01:01:56.224228-04
ACCESS_20250918140156_00001026	hckwak	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	b0d1b5a0-b7cf-454c-8d4b-65d5a02ce9ce	3480C277B4079D4922BB3240FC47B3CF	01	2025-09-18 01:01:56.272358-04
ACCESS_20250918140158_00001027	hckwak	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	ef98eb03-d33f-42a5-ad3a-a8b089f016f5	C5A1FE0C196F6BF1718B1DB3008C6C4D	01	2025-09-18 01:01:58.869749-04
ACCESS_20250918140204_00001028	hckwak	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	c0ebcbc6-e4ae-435f-adb5-a2bdc5bd3204	DF27F5D325213C086C614B0F93FD330E	01	2025-09-18 01:02:04.023722-04
ACCESS_20250918140208_00001029	hckwak	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	4e9551ef-348f-465d-9125-8bb64148f215	A48A17D1FEFE74F07E0DFC7FE993ED58	01	2025-09-18 01:02:08.199682-04
ACCESS_20250918140211_00001030	hckwak	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	33ac223f-6c00-4040-be5d-38ba6e0c7c21	9004B1EA9BCF82ED70FA3E0E5E43434D	01	2025-09-18 01:02:11.450534-04
ACCESS_20250918140237_00001031	hckwak	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	e4db0ae7-53ce-4f8e-a651-b3d5f79ac31b	FD6719ABBA8CF7FCB39D487CB709DC67	01	2025-09-18 01:02:37.324726-04
ACCESS_20250918140238_00001032	hckwak	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	85c114fa-1936-46eb-a6bb-ccce4d5b8b6d	BCFB90CC6BA1E67D6B507D2196D43ED7	01	2025-09-18 01:02:38.871087-04
ACCESS_20250918140240_00001033	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	420c3728-7b8f-4001-97dd-b8792537d07b	A437A3C6B1CBD4EF0849BD6A2466E494	01	2025-09-18 01:02:40.105827-04
ACCESS_20250918142045_00001034	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	13685a3d-e7fd-4d22-bebe-78c06b645f85	2B5E751F849C2C3A86CC8FF5C4E877DC	01	2025-09-18 01:20:45.069689-04
ACCESS_20250918142045_00001035	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	7f2f3a6a-78a0-4040-b5d7-532ce1ae87cc	5A513E7672B0C2196D0156F85AD0BE91	01	2025-09-18 01:20:45.089204-04
ACCESS_20250918142049_00001036	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	c361a71d-3d19-4135-a043-9e226fd617ea	03A6DBF304895758E2A2183F7A158058	01	2025-09-18 01:20:49.429435-04
ACCESS_20250918142057_00001037	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	bd660849-9765-44c5-8165-6391355da8ef	AA3C8F938F2F97BAF54AA1208AE42092	01	2025-09-18 01:20:57.127331-04
ACCESS_20250918142057_00001038	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	b1043784-3033-4047-b162-84ee3175505d	223E24914319EDBF7C016D29BDDF92EA	01	2025-09-18 01:20:57.172332-04
ACCESS_20250918142108_00001039	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	8e49cd60-0ad4-4c65-b499-a54cc86b504d	3A5662C937EC9E624564AE8A0296DCDB	01	2025-09-18 01:21:08.258591-04
ACCESS_20250918142113_00001040	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	2c60772d-f567-4e29-a9b5-f88c5e609e57	848AF01F446348E2B935EAFA222F843B	01	2025-09-18 01:21:13.09552-04
ACCESS_20250918142118_00001041	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	ef01e12e-c620-49ff-aac2-56895a7c4c5e	7F38E6E93994BB0D62E8AB91B5064EC9	01	2025-09-18 01:21:18.696521-04
ACCESS_20250918142130_00001042	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	3ec80cb2-7a9c-4081-a2de-fc0c43949520	56BE6638D7202CB35F487EE32F282A0D	01	2025-09-18 01:21:30.88793-04
ACCESS_20250918142133_00001043	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	55d120db-e84b-4c8e-8e74-3e490e19476f	F6B17BFE218FE9A02EDDAD0B428F6A94	01	2025-09-18 01:21:33.314916-04
ACCESS_20250918142138_00001044	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b41d989e-4448-428b-9116-bf05440327a2	0825DF992D536D9E5A4A7032B5CB994E	01	2025-09-18 01:21:38.631313-04
ACCESS_20250918142143_00001045	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b7144061-2f4f-410b-8297-efa465c14cd8	9DF716C72E8822BB483E766ADFAC2A76	01	2025-09-18 01:21:43.942637-04
ACCESS_20250918142152_00001046	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	e253f223-c268-4afc-8f6f-f3bd2aa0801e	B1B38988B8CECA11457780068EDDF03A	01	2025-09-18 01:21:52.939741-04
ACCESS_20250918142209_00001047	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	43bda6f2-3cf3-4fe3-8a95-dd97f1602dba	A2170A37222EA3499F17BC60255E1284	01	2025-09-18 01:22:09.072142-04
ACCESS_20250918142216_00001048	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	51f20e2e-dcbe-4772-8763-41ce56cbeb38	2C01138EE405FF21D6C9773DBDB9CA18	01	2025-09-18 01:22:16.369388-04
ACCESS_20250918142222_00001049	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	36e3b1ce-0a21-45e9-b34f-18569a0824fd	EEF571CF8B3728A0D564A05117CEA47B	01	2025-09-18 01:22:22.10656-04
ACCESS_20250918142228_00001050	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	26ce7f38-ac89-487e-94e0-04ad1520a3ca	D3FEC99D1BBBB315E2DD2F62BC64A955	01	2025-09-18 01:22:28.879687-04
ACCESS_20250918142919_00001051	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	55d2f418-d599-4575-9a68-8b59f7467322	975CEAA3493099B5DEF77971117966CD	01	2025-09-18 01:29:19.651738-04
ACCESS_20250918142919_00001052	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	a9f9bbac-d0d5-4f43-9fe0-dd4db8b18445	DE25B2E44A1F3BD1CF16A202A43AC018	01	2025-09-18 01:29:19.652762-04
ACCESS_20250918142922_00001053	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	8f13c4db-0e3d-43e7-9370-e13a61be7bb4	2018FBD47A12B4A7999EF72CF1DD8735	01	2025-09-18 01:29:22.12736-04
ACCESS_20250918142930_00001054	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	a810c972-39bf-40b1-909f-d203a8f45991	1E25ADB7C898F77AD7B3D9119A073BC5	01	2025-09-18 01:29:30.386361-04
ACCESS_20250918142930_00001055	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	d8be4885-15c7-4abe-acb8-298ac315f9c2	E3FE557E47EF78B5D18C959A9352543C	01	2025-09-18 01:29:30.422578-04
ACCESS_20250918142934_00001056	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	48e3e5ab-a63a-4ee9-af11-85ac622b1c5a	06CBCA431963C4181799ED66A24201B9	01	2025-09-18 01:29:34.866791-04
ACCESS_20250918143026_00001057	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	f97a0c0e-dee8-4f14-aec0-2fece63a7656	9EB85F26F8079A08D47E79924AD1EA03	01	2025-09-18 01:30:26.857319-04
ACCESS_20250918143027_00001058	hckwak	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	c5aab87e-020b-46f6-8424-4be6da80ffa1	3B63A363960560F0A14938E4FF1000E0	01	2025-09-18 01:30:27.444719-04
ACCESS_20250918143031_00001059	hckwak	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	565e309f-2a42-4114-854d-12166e8a978d	F57838475151D1576CACDB2E9CDA4C0B	01	2025-09-18 01:30:31.211114-04
ACCESS_20250918143031_00001060	hckwak	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	1917737b-89a3-41c2-8b70-863608f1df6b	06CE5FC97F24253EC4B20C079B28D330	01	2025-09-18 01:30:31.235997-04
ACCESS_20250918143036_00001061	hckwak	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	b3300dde-7ab9-43e3-a721-2ba8fec08c15	4DE33D5B40012054D9015ED5BD84A1B9	01	2025-09-18 01:30:36.589306-04
ACCESS_20250918143123_00001062	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	97ebe1b4-ea1a-4a90-9eaa-94bcc031101d	DF2E46BEA693FD1F016A954F84F3A0C9	01	2025-09-18 01:31:23.633301-04
ACCESS_20250918143125_00001063	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	2343f7a2-b355-413d-9fe4-5674b2b319bf	EDD2E78F0CAA89FE505999091748846C	01	2025-09-18 01:31:25.684503-04
ACCESS_20250918143128_00001064	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	1b1f2743-957c-4208-a8fe-38f4446cc6f5	531232A29EB8C32819D2942A9799BF7C	01	2025-09-18 01:31:28.494611-04
ACCESS_20250918143136_00001065	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5397e377-612b-4bae-b394-3a9e062352d1	DFA15D37285E8C075171D0A4EAF22E86	01	2025-09-18 01:31:36.15517-04
ACCESS_20250918143139_00001066	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	8f2bda3b-0785-4515-ba42-e480baa0dad4	4A3C4632343BC90967CD300151FDC17D	01	2025-09-18 01:31:39.048196-04
ACCESS_20250918143446_00001067	hckwak	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	f89c462a-400e-4f08-a23e-fafad3a9c3d4	7DA7A43507FFA9A85CD894647AB675AB	01	2025-09-18 01:34:46.989321-04
ACCESS_20250918143449_00001068	hckwak	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	562f0b30-c56e-480b-9fa8-89d708579360	B6C903DD48208A150F0E66771FC172DD	01	2025-09-18 01:34:49.002135-04
ACCESS_20250918143453_00001069	hckwak	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	8df07015-4045-4e1b-9a98-6bf80afeec42	E5B067101DE74A18607801804E7954FF	01	2025-09-18 01:34:53.169343-04
ACCESS_20250918143455_00001070	hckwak	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	857afd04-6618-4d67-82ca-8a204f44885f	E0F6F1D7AA5092D9B28189E35767616A	01	2025-09-18 01:34:55.562165-04
ACCESS_20250918143517_00001071	hckwak	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	c2e8d9a7-9f00-4b47-9904-aaa03eb9f96d	90B78C2587033F8ADFD5D8144450B152	01	2025-09-18 01:35:17.297837-04
ACCESS_20250918143706_00001072	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	158b04f1-b91c-44f5-b7e4-46d24067c1a0	66E0A5B6DF1870F9CAACB3DEFC4CDED5	01	2025-09-18 01:37:06.582879-04
ACCESS_20250918144119_00001073	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	f538cce0-e7eb-41a6-9cf6-ae982acdb98a	7E29040E4E698DCE99BAA44357FB87F9	01	2025-09-18 01:41:19.745535-04
ACCESS_20250918144121_00001074	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	a7f991ce-092c-4a3b-8e36-350287aede45	FDE464E72593C53322B432A08EEDA86A	01	2025-09-18 01:41:21.330941-04
ACCESS_20250918144122_00001075	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	aacea9ef-ef45-471d-aa7e-e7ff86b3dd72	A140573F28211317850FBF535802583D	01	2025-09-18 01:41:22.447833-04
ACCESS_20250918144127_00001076	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	e11f4c54-a930-4f19-9117-3bff4ef6c4ba	7127A41B47B53B8DCE77FCAAAC73DEBC	01	2025-09-18 01:41:27.465986-04
ACCESS_20250918144133_00001077	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	9abf4ea6-a748-4d5c-a0cf-fe8367a7599f	F5347DB1A6855F5FAC21650E40D17F98	01	2025-09-18 01:41:33.039858-04
ACCESS_20250918144603_00001078	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	c729cf73-30d9-4e24-a600-0b4edf13f24c	1C48D4A5E0EF160E990EF8257352A59A	01	2025-09-18 01:46:03.970239-04
ACCESS_20250918150337_00001079	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	6092e9ea-1972-45ec-b989-5f766265f0c6	3D3EDF0B98E8BC498F1CD25A9A0D921B	01	2025-09-18 02:03:37.476187-04
ACCESS_20250918150337_00001080	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	0db29688-71d2-4d32-997a-ed9856d6ec26	7C704385EC0DE7B3CF42601FF7C77D05	01	2025-09-18 02:03:37.476999-04
ACCESS_20250918150340_00001081	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	9171f521-50bd-4cee-9ea9-2e15c07bfccb	60A66CF62108F175FF9AC6A9855B164E	01	2025-09-18 02:03:40.409719-04
ACCESS_20250918150400_00001082	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	3fb1abd2-73a3-4184-9bb6-a0228b5676d9	553EE9E22394C12EFF300A36F79C322C	01	2025-09-18 02:04:00.716368-04
ACCESS_20250918150400_00001083	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	e3a9f7af-c3b0-4b41-9226-d2665267182e	2077D9AEA2B7DA32DF74055FA8EAB256	01	2025-09-18 02:04:00.776931-04
ACCESS_20250918150406_00001084	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	bf61fbef-7abc-4171-9f5d-82e3c14c8fe3	D663133A140EA797060212121D4958BF	01	2025-09-18 02:04:06.66707-04
ACCESS_20250918150523_00001085	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	ff73932d-c031-4408-885e-a825f5381ac8	EB5A2B9A2D613E39EAD843ECDB5BAA38	01	2025-09-18 02:05:23.559013-04
ACCESS_20250918150531_00001086	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	f93f862a-7a83-4ebb-8982-76452d8a80b4	5DC1EB1093A4CF9D42A90E726BA75CC3	01	2025-09-18 02:05:31.486559-04
ACCESS_20250918150552_00001087	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	d9991f67-b8eb-4486-a31e-654c225431b3	3FF59FFE005E76C84819158903A2C430	01	2025-09-18 02:05:52.958149-04
ACCESS_20250918150647_00001088	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	0d8992b9-16ef-4e4e-b332-3ca4b72b3bda	256B99C1F2D3A9050E5AD725DDD22A52	01	2025-09-18 02:06:47.021128-04
ACCESS_20250918153116_00001089	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	c3849d1a-9d50-4642-85c5-8e2fe83bba81	FD0BE2956D8491D6B9CDA81BE5FA97AA	01	2025-09-18 02:31:16.468099-04
ACCESS_20250918153116_00001090	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	3f718bfe-91dd-4b8e-85a3-c85f9c78e92a	1009B51E020CAF15CB2B319EB4AFB032	01	2025-09-18 02:31:16.487757-04
ACCESS_20250918153127_00001091	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	ed7715d6-9096-4e56-b14d-d3506b1e3fdd	F4DA73728B5D553606906B8624D8CA46	01	2025-09-18 02:31:27.880185-04
ACCESS_20250918153135_00001092	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	f7a4e4cd-acfc-4dd9-935b-20b5c4a5c9d4	68B31AE228DD0CA08AD066C0A5FC0DB6	01	2025-09-18 02:31:35.638136-04
ACCESS_20250918153135_00001093	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	cb4128ce-235e-4db7-b401-58e99ccab283	909BCD47742370B627CEA77F7F872B47	01	2025-09-18 02:31:35.682247-04
ACCESS_20250918153141_00001094	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	0af7bbdf-93ba-41e1-98df-2e51215c2df0	3B0E0813A02AABDFB203EAFD6AC2715E	01	2025-09-18 02:31:41.633191-04
ACCESS_20250918153146_00001095	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	11390d05-5971-4a99-bb04-1556ea07b537	964B6A72CAB611B8E2BA358302838C02	01	2025-09-18 02:31:46.33791-04
ACCESS_20250918154221_00001096	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	89a59f6c-e91e-4cdf-b992-dbe82a17a09e	8BFEA8C71FF8EACAF9D50DDA48A239E4	01	2025-09-18 02:42:21.730295-04
ACCESS_20250918154221_00001097	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	f221a066-adb5-4b62-81af-3e72d5b4afa1	1C794C92959BBBD3E721FF7D45D97E6F	01	2025-09-18 02:42:21.730296-04
ACCESS_20250918154827_00001098	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	63fb6e89-0736-4842-bf07-32bb47adb934	ADE380F0E929BDA43E0FB447E85345A3	01	2025-09-18 02:48:27.633799-04
ACCESS_20250918154833_00001099	system	GET	/api/v1/incoming/slock/1	입고관리 - 상세정보 조회	10.42.0.1	569283a0-faf3-4b0b-9018-f3a4208540b8	55230FDB56109397E87574990FB80DE9	01	2025-09-18 02:48:33.902777-04
ACCESS_20250918154936_00001100	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	c892e0a9-d9bc-4cbf-b235-73f05ef0197f	43BCCA869F20F7A45C8C48FF6D828781	01	2025-09-18 02:49:36.358177-04
ACCESS_20250918154941_00001101	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	09974bed-c96c-4909-9255-12366d4324c5	1400F44C241DB37747A4E2A8D85C407F	01	2025-09-18 02:49:41.584914-04
ACCESS_20250918154948_00001102	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	724a5be7-4e3b-41b1-be07-625a47f89df7	08BF516FC725E03C5BCC56D4F5C3CA4B	01	2025-09-18 02:49:48.80169-04
ACCESS_20250918155002_00001103	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	aa40909a-d842-441c-9ade-e553b2036267	3100DA520DE2E63F902087AD6556FE60	01	2025-09-18 02:50:02.151043-04
ACCESS_20250918155006_00001104	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	afba6e96-b751-4f7b-8361-03770eedc74d	AE4F2FF9ADEA700A0B895BA238F77A8F	01	2025-09-18 02:50:06.767867-04
ACCESS_20250918155147_00001105	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	49bad6c6-2bf1-4f0a-97a5-96d4635ea110	3626FADC3F56A351427C842F9C90FC71	01	2025-09-18 02:51:47.862163-04
ACCESS_20250918155310_00001106	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	584e35de-4f3e-45bb-82c7-c4a1bba2741a	A9E4A8E5F7C80DD41970190AC82F1873	01	2025-09-18 02:53:10.775433-04
ACCESS_20250918155316_00001107	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	f19526bd-a59d-4899-88e3-8b4455e661e8	02154ED73F76697B977718FC9B50D125	01	2025-09-18 02:53:16.079748-04
ACCESS_20250918155321_00001108	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	4536a4bf-c034-4d44-a430-f3279acc1df0	7DE695E8C65CBFCF7E542D08F484627A	01	2025-09-18 02:53:21.676197-04
ACCESS_20250918155335_00001109	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	288b38df-446b-4f25-8572-70870ff3a6eb	2131C9A5DB783BC979F3241A4F72CD3A	01	2025-09-18 02:53:35.028594-04
ACCESS_20250918155340_00001110	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	a9c53db5-62e9-4f25-9fd2-ba11e132935f	775954FE7FA4622EA392D1F9CA5C27F8	01	2025-09-18 02:53:40.852046-04
ACCESS_20250918155356_00001111	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	f64c9773-5a9e-4750-a627-4121a64d9cff	ABA420BA78986B05A9D3C3CD86894835	01	2025-09-18 02:53:56.443881-04
ACCESS_20250918155422_00001112	system	PUT	/api/v1/incoming/slock/config/4	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	3ea9a84f-9efa-49d4-8b2d-9cfb8cc92649	62A2A5FBDD3A3F15DC1D144410B9C320	01	2025-09-18 02:54:22.023875-04
ACCESS_20250918155504_00001113	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	14eb63a2-6ec8-4723-874f-5f39494b3f3d	A02D192ECF5105CBD9864B83401B04B5	01	2025-09-18 02:55:04.192867-04
ACCESS_20250918155508_00001114	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	b583f734-30b3-4774-8437-cc652aa0805b	C5955500642EC2AD3C96D23B85DB1AF0	01	2025-09-18 02:55:08.274635-04
ACCESS_20250918155515_00001115	system	PUT	/api/v1/incoming/slock/config/4	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	af71abce-3c7b-4655-b548-93f2425c7c9f	6A3A43C9F792FA055E50835CE0718BB6	01	2025-09-18 02:55:15.657537-04
ACCESS_20250918155536_00001116	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	759569f4-ba2d-4232-bd1b-04e41081ec8a	5EE10BC8AD875B2B1160676B95AB0867	01	2025-09-18 02:55:36.633403-04
ACCESS_20250918155536_00001117	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	303baa74-b969-4a24-88ef-7b4b77872942	DA35B863C19E01EF060C76AE6C736057	01	2025-09-18 02:55:36.686709-04
ACCESS_20250918155609_00001118	system	GET	/api/v1/incoming/slock/4	입고관리 - 상세정보 조회	10.42.0.1	f4b74b66-0620-437f-932b-7107ac2800cb	7F2EBEE5D95DDAEA19632066C17FABF5	01	2025-09-18 02:56:09.75104-04
ACCESS_20250918155614_00001119	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	f6e0ee38-390d-48a9-a279-96fe961a1093	07423ABB7BBC661539BC9135B8300600	01	2025-09-18 02:56:14.629829-04
ACCESS_20250918155622_00001120	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	3337d374-2d54-4a81-a22f-a504b44d325e	DF29F6A473F8AE10385F8BF8EBB615EF	01	2025-09-18 02:56:22.800319-04
ACCESS_20250918155622_00001121	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	3cd4e8aa-40d7-453b-8e49-7f204986e2bf	F756462AA3F8F19D43A5595714E21940	01	2025-09-18 02:56:22.850886-04
ACCESS_20250918155806_00001122	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	d57fe90f-03ef-47e8-a550-de2aa5eadb03	4C2E24B54FA6CAB684F64EAC278F6B49	01	2025-09-18 02:58:06.791132-04
ACCESS_20250918155824_00001123	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1	e862bbd6-b164-4c07-9cdf-cc025197d207	A58BBD440536D51D32017DECF73CF245	01	2025-09-18 02:58:24.850426-04
ACCESS_20250918155912_00001124	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1	a4f01e3a-cb84-4cb9-b8ec-4c1bc3e19683	5A748F4507FC27CAC81DEB98504A1C5A	01	2025-09-18 02:59:12.645863-04
ACCESS_20250918155915_00001125	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	cb3fb990-73c8-4d57-82ba-e4d794351f04	3A7FCA3A97CBCD167BA6DEB48B86C0A0	01	2025-09-18 02:59:15.52734-04
ACCESS_20250918155927_00001126	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	9cba21b9-6ebc-4de0-848e-523ada07ec19	4F0ECEB05B1BC7EF93A5CD1E65E6FA62	01	2025-09-18 02:59:27.164971-04
ACCESS_20250918155936_00001127	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	44c3ffc5-9efc-4535-86ed-bb0c51ae5ef3	EC14161F55BD0620F22D5B8ECAC8FDA2	01	2025-09-18 02:59:36.083449-04
ACCESS_20250918155944_00001128	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	1e9fca0f-71cd-466c-a770-adde9b77e798	7A7F8C4A4EEEEB80259BA6222E0ABCC2	01	2025-09-18 02:59:44.738479-04
ACCESS_20250918155955_00001129	system	POST	/api/v1/outgoing/slock/config	출고 부가정보 불러오기	10.42.0.1	5dd8ceee-c8ca-4b22-970c-fcfbdd89fbe2	0CD59DF7690DFB6BF082CC7AE74D4307	01	2025-09-18 02:59:55.964423-04
ACCESS_20250918160010_00001130	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1	b03fcebf-ada7-4457-b887-c70e9a72174a	22A39C7F1697B18A79D710D74978EC44	01	2025-09-18 03:00:10.755034-04
ACCESS_20250918160018_00001131	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1	71432a52-ce2f-451f-97eb-6e99eb5a5fed	35901F7A8B223B89169CF511C2CD6ED3	01	2025-09-18 03:00:18.921208-04
ACCESS_20250918160018_00001132	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	26dcd9eb-cacb-432b-b267-3fbee3a95c0d	4B7E9F1804C822097E388A071FF7FB9E	01	2025-09-18 03:00:18.953069-04
ACCESS_20250918160027_00001133	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	bf2d5c1a-3d37-41bf-b713-9e68edacbde6	AEC76A509C3AE5B67ABB808EE5D9F35F	01	2025-09-18 03:00:27.421711-04
ACCESS_20250918160040_00001134	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	1596749f-8e6d-45da-8d9f-409e6f62ac38	BA122818F9616C39C64E57CA332D56D0	01	2025-09-18 03:00:40.117045-04
ACCESS_20250918160101_00001135	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	e8fd664e-0478-469f-873d-1bd0cda1a93d	2D010EC3C8227590A117E4414421AF93	01	2025-09-18 03:01:01.389651-04
ACCESS_20250918160101_00001136	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	042e4893-a89d-4660-b05e-0505fcc531cb	59DC49B207C4B3F39630B6134D1FF7C8	01	2025-09-18 03:01:01.396804-04
ACCESS_20250918160134_00001137	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	0611d25e-cc42-4af7-8d25-7d12711c0170	D07816104C821EED4D50FB65075A410F	01	2025-09-18 03:01:34.846488-04
ACCESS_20250918160134_00001138	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	8e0b551d-bf80-4915-ab35-71babd515d97	1E95D23A7F3B7AD6630B654104E390C8	01	2025-09-18 03:01:34.895711-04
ACCESS_20250918160141_00001139	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	0c48d882-3641-4a42-97f9-7e2166f66d11	B24A569654CCF000A947AAF287E2B3CD	01	2025-09-18 03:01:41.66031-04
ACCESS_20250918160144_00001140	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	f1703eb6-4e21-4aa9-bdde-c8007a6b0706	8655E2C170FF4A8A983FF50026963C0E	01	2025-09-18 03:01:44.951797-04
ACCESS_20250918163344_00001141	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	52515797-6741-4d01-b885-2144d820e047	5974FAB653FC7E2CEE97DE52B8A7F9AC	01	2025-09-18 03:33:44.79244-04
ACCESS_20250918163344_00001142	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	19829dd7-4f73-4f6f-bf05-d8ca5a2abfd7	6DAEA7BB93AA168B3F5F9B1B9213D094	01	2025-09-18 03:33:44.792439-04
ACCESS_20250918163436_00001143	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	e668cb34-a80e-4544-a12b-5b0e403dd66b	60A9E5E6CD37AF72752A815BD756E010	01	2025-09-18 03:34:36.177966-04
ACCESS_20250918163436_00001144	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	24b63eec-ed2e-4bee-bba6-31ec1e7295d3	6AC58BF02BD23F286ED9257F3A1B9602	01	2025-09-18 03:34:36.17797-04
ACCESS_20250918163439_00001145	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d08c77e8-7a51-478b-b438-1db099afc37c	0C880C3E228F8891808F10D9257862DF	01	2025-09-18 03:34:39.248452-04
ACCESS_20250918163439_00001146	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	7c1b24b2-df77-4966-a7c1-2e0553d0fddc	FB7985D87B4F7EE6839450F0A7DC6130	01	2025-09-18 03:34:39.915837-04
ACCESS_20250918163440_00001147	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	f4ae4a65-4f1c-4150-9e56-e358b384a032	36EDC7D0B039CED33BDA48F2A20A8FC7	01	2025-09-18 03:34:40.726843-04
ACCESS_20250918163441_00001148	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	a23f53a0-d16f-4298-807f-9d19f22014f6	0BBC8CD99944236DF9B92F0078C78119	01	2025-09-18 03:34:41.858134-04
ACCESS_20250918163441_00001149	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	0f91edcf-e487-45e2-8d97-dae286588b80	8EB5BC6DFD7E4AB8D7378F609980BE17	01	2025-09-18 03:34:41.86307-04
ACCESS_20250918163442_00001150	system	GET	/api/v1/product/3	입/출/반품 관리 - 상세정보 조회	10.42.0.1	0b641cf7-ded4-49d9-8f55-2f9b6d65c131	3724BDE414E9E633CB185DBDD2D79A8F	01	2025-09-18 03:34:42.119728-04
ACCESS_20250918163444_00001151	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	f0f25260-873e-4348-b411-22bf8ea4a05a	A21F1D7D01F5600CFD496EBC27CAD690	01	2025-09-18 03:34:44.605853-04
ACCESS_20250918163446_00001152	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	8d8694ea-fe15-456c-98f0-f14b091e4e21	E302EA4AC93D10E8770341CF21EAA48D	01	2025-09-18 03:34:46.085004-04
ACCESS_20250918163453_00001153	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	1d6ae5a8-993e-40c9-9db7-ac23ba3a9e2d	3CD79CB514FB868419F8B916AC08F131	01	2025-09-18 03:34:53.169664-04
ACCESS_20250918163454_00001154	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	5d5a337f-a6ad-4cb6-81f9-c126da0c0516	CED9A6030DEB842F1910D301C6267A42	01	2025-09-18 03:34:54.485902-04
ACCESS_20250918163455_00001155	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	47c0bf9b-88c6-44a9-863c-810830dab035	25F91D53F5AF8867E387B26D3F9A263E	01	2025-09-18 03:34:55.640829-04
ACCESS_20250918163457_00001156	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	d8f7d1e5-6d1f-45e4-bf6e-37a713a1f0d1	90E6D2DA5B36C29FC317C3C968B49B68	01	2025-09-18 03:34:57.356553-04
ACCESS_20250918163459_00001157	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	5b453e57-169c-4e1a-8991-07b2ed972407	5756AEE6B9711D27208EBEC3F8799806	01	2025-09-18 03:34:59.58364-04
ACCESS_20250918163500_00001158	system	GET	/api/v1/incoming/slock/3	입고관리 - 상세정보 조회	10.42.0.1	346d5766-0cce-4889-aa72-93c8237c1a25	0129AC86430ECF2E9F66C0416274BFB0	01	2025-09-18 03:35:00.559162-04
ACCESS_20250918163501_00001159	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	ed13dd96-361b-4ab7-80c9-0e8541606e40	06F70BCC34D92D1E55F2383D0D990022	01	2025-09-18 03:35:01.33181-04
ACCESS_20250918163509_00001164	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1	296c7097-11d8-4ebe-bc1c-23f9845a2d79	C7883BA825BB27C39ED71C59F21F6B7F	01	2025-09-18 03:35:09.042152-04
ACCESS_20250918163516_00001168	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	5788e58a-7b38-4bbe-b60d-19aba04a2ac0	CD9653E17FBE26EFB945B45AD5FB696D	01	2025-09-18 03:35:16.457363-04
ACCESS_20250918163542_00001174	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	b83039ff-e91f-4fe7-9042-86950de06474	96C05FACB296020C7BE0DD85968B60A2	01	2025-09-18 03:35:42.853819-04
ACCESS_20250918163556_00001179	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	90edfa50-0f2b-47c8-befa-81e83a5a46b1	BDED9E12171A30F1AB75AF54D6941B71	01	2025-09-18 03:35:56.251665-04
ACCESS_20250918175046_00001267	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	ee2014d2-ffcc-4d9d-ae8e-de97674ade07	ABB3DADADD7E481EAF54A03B8E756A26	01	2025-09-18 04:50:46.218205-04
ACCESS_20250918175046_00001266	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	e74f8f89-700f-4b9a-8bac-eaa356f08689	251259937807778AE00A323BFD9DB757	01	2025-09-18 04:50:46.218201-04
ACCESS_20250918175052_00001269	system	GET	/api/v1/home/dashboard/products/models/8	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	183967ca-945b-4a33-b2d6-23930ffa0109	84C462BBEDF60A850ED2ABB673A6DA13	01	2025-09-18 04:50:52.745812-04
ACCESS_20250918175112_00001276	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	35791c98-1f3c-4702-9882-3da8cc2df181	1008E0FAE7CE8A6F5761479967A5480F	01	2025-09-18 04:51:12.215091-04
ACCESS_20250918175128_00001283	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	dbc16474-b646-496a-bba2-6e2c96588208	772B155EF67F9A9F6B73EE01B81A2F50	01	2025-09-18 04:51:28.239582-04
ACCESS_20250918175137_00001286	system	GET	/api/v1/ref/user/detail/jijeon	사용자 관리 - 상세정보 조회	10.42.0.1	18e5ecad-c227-4d12-8178-b06c681939b2	FF59D102FD5E9FB967EA19389F454A2B	01	2025-09-18 04:51:37.856445-04
ACCESS_20250918175137_00001287	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	d716aab0-fd5e-4fce-8523-84c8775ec94d	95A3319581099820197EE1F451C37EA3	01	2025-09-18 04:51:37.859306-04
ACCESS_20250919161024_00001347	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	0516326d-1a8b-4106-956e-20d6779270df	AC2FE8A600158428CB68D4C1EE88BABD	01	2025-09-19 03:10:24.09614-04
ACCESS_20250919161030_00001348	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	09cb3828-3bbe-433f-8988-ec86267df84a	C768B6E7688E5CC04682F56A069848F3	01	2025-09-19 03:10:30.962263-04
ACCESS_20250919161034_00001349	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	34fca13e-44a8-4797-9a16-4bb7070acfe9	C078BB1D886E77DE50B361244418ACEF	01	2025-09-19 03:10:34.668085-04
ACCESS_20250919161038_00001350	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	72c56af9-a5a3-45e4-8c52-8348057b1594	80A5B8F5D9FCF12A622D0ACC2BC061E5	01	2025-09-19 03:10:38.796364-04
ACCESS_20250919161050_00001351	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	66616252-3e70-42b3-aff5-0802c1182725	F8984B5309E278A3C7E584A3EE31AA60	01	2025-09-19 03:10:50.800969-04
ACCESS_20250919161101_00001352	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	c4f3a780-88b3-475a-bfa7-1e96fef2ee53	A7B8606E63AC680FD08BF8A7FDB79FE7	01	2025-09-19 03:11:01.448835-04
ACCESS_20250919161111_00001353	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	71609847-acc3-45c1-a1b8-8228dc64c100	409EC69BCDE2053AD98B0AC9C6B5CE47	01	2025-09-19 03:11:11.040985-04
ACCESS_20250919161114_00001354	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	c47c7ff2-17dc-4755-8379-eada87fae7d2	CB6EFA971E9E5A23C420C95D3C8392AE	01	2025-09-19 03:11:14.913975-04
ACCESS_20250923172449_00001405	hckwak	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	1d5b8f85-a0cf-468f-807c-e5b74e3c3f06	F330FF9D690E8937D9B1B921201418F4	01	2025-09-23 04:24:49.308517-04
ACCESS_20250923172449_00001404	hckwak	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	79803bb7-fdc7-4710-8f2a-f26cb3543c07	B90C6B31FA3F6AD198D872C13175637A	01	2025-09-23 04:24:49.30852-04
ACCESS_20250924173203_00001451	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	9cefcbe4-2ea8-4337-830b-9a63837a9626	16F9FC9D7D28261D8986AFE29E20A489	01	2025-09-24 04:32:03.943735-04
ACCESS_20250926150342_00001469	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	4c9bfcc1-55a2-4e5b-b188-c97601fdcb51	433A1A59E71B072F95ECF8ED7828C30A	01	2025-09-26 02:03:42.396564-04
ACCESS_20250926164101_00001520	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1, 10.42.0.170	0b9b01b2-b682-4142-9cac-3690334d97a2	20036670FB01082BCEB17FCBD13792A0	01	2025-09-26 03:41:01.721594-04
ACCESS_20250926164101_00001521	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	64bd6bc5-cb9c-41a2-b895-2b8e461a79de	7783105845562708F2FB29AD1818AC2D	01	2025-09-26 03:41:01.777392-04
ACCESS_20250926164107_00001522	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	00bcd313-286c-4f62-8e8b-b53d26fc1733	605161C71D5058F079F01834EF56F1FF	01	2025-09-26 03:41:07.633768-04
ACCESS_20250926164118_00001523	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1, 10.42.0.170	a76aa9c9-06b9-4c29-b0dc-426af3d8459f	FAA912894ABD87847CDBB51D13852254	01	2025-09-26 03:41:18.075099-04
ACCESS_20250926165255_00001566	system	GET	/api/v1/product/14	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	7d2d4677-efd5-42cc-adcc-b7fc1cd9864e	BF0320B02E162C5BA8D4F3F850075094	01	2025-09-26 03:52:55.879964-04
ACCESS_20250926165337_00001567	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1, 10.42.0.170	cacd70ef-533d-409d-9984-833b5c8124a2	EF374F3CAE1374E5064C1FAFF9A8227D	01	2025-09-26 03:53:37.923318-04
ACCESS_20250926165337_00001568	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	ba6a844e-95cf-45be-ae53-13fb9415052d	9B6CBF94E80A16D98DCD0F6297EEF7F1	01	2025-09-26 03:53:37.946798-04
ACCESS_20250930145926_00001590	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	a193186f-38b1-4631-807b-b4cd2139dd13	43498900263E134A87782686F1EDD688	01	2025-09-30 01:59:26.713083-04
ACCESS_20250930150031_00001592	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	d888b084-acf5-4a24-9ca6-b04a64c23dbf	B2EBC0E9BA4BF7E35C0ACBF73E6CB893	01	2025-09-30 02:00:31.235387-04
ACCESS_20250930150031_00001593	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	2770dfff-f343-4dfc-be63-ef82cd548dbe	B753DEB00A02EEBD9AB7C9C2D2ED0191	01	2025-09-30 02:00:31.487239-04
ACCESS_20250918163502_00001160	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	58f9ef33-d505-4418-9f1f-9ed8c2229e23	30BBC81411ACE589731F4E36762FCB4A	01	2025-09-18 03:35:02.024505-04
ACCESS_20250918163516_00001169	system	GET	/api/v1/ref/notice/2	공지사항 - 상세정보 조회	10.42.0.1	e20685aa-3483-4034-9735-b3987a911248	DA580A12648C84DF05AF5FD1E025F8F3	01	2025-09-18 03:35:16.685554-04
ACCESS_20250918163548_00001175	system	GET	/api/v1/ref/user/detail/hckwak	사용자 관리 - 상세정보 조회	10.42.0.1	0f39d8c0-2d73-4193-8417-f31451ab7336	CE24517F527343FF582F47209B60EA04	01	2025-09-18 03:35:48.192895-04
ACCESS_20250918163557_00001180	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	787ffd43-547c-4539-80ce-5d6ddab05a3d	40F9EBB8C81EDB098A71EE9F767287B9	01	2025-09-18 03:35:57.000223-04
ACCESS_20250918175050_00001268	system	GET	/api/v1/home/dashboard/notices/2	대시보드 - 공지사항 상세정보 조회	10.42.0.1	70f51316-6a15-4e63-b70e-06de9730c75c	A1870B8145A4144EFCBD99AD717803C9	01	2025-09-18 04:50:50.276636-04
ACCESS_20250918175054_00001270	system	GET	/api/v1/home/dashboard/products/models/8	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	1df7dbb4-a5b3-4d38-a7a0-1c61e742de32	1CA3C2F1D47B9A8DC41757AE12F02497	01	2025-09-18 04:50:54.499563-04
ACCESS_20250918175055_00001271	system	GET	/api/v1/home/dashboard/products/models/8	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	5a1ddf60-95c2-4f73-89f7-b8b91d676df3	CCD90EC705C81C0587DECDE3C067829D	01	2025-09-18 04:50:55.549307-04
ACCESS_20250918175056_00001272	system	GET	/api/v1/home/dashboard/products/models/8	대시보드 - 출고 현황 상세 데이터 조회	10.42.0.1	94348f20-c828-4bba-ad33-70337f40c60d	9CEF5BA6C16A7A266894CA2B3BEEC165	01	2025-09-18 04:50:56.741828-04
ACCESS_20250918175108_00001273	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	a1d4a2af-8eed-42e7-8240-44bb27602bf6	609148EC27476116FC3CF673CF2D1898	01	2025-09-18 04:51:08.895873-04
ACCESS_20250918175108_00001274	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1	069ed484-b6c7-426f-8c55-4942404e7bb2	A44EFFE8201ED9C402602CB66F7E7912	01	2025-09-18 04:51:08.989803-04
ACCESS_20250918175110_00001275	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1	13934a95-9707-4da2-8186-e07da73f47ba	CD70302A27F0AC601F3C2792CEEE4AAD	01	2025-09-18 04:51:10.165659-04
ACCESS_20250918175114_00001277	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	99c72979-e853-4d34-87e8-52aadf86a581	130195B5575DAD8FB77D304C853CA3E8	01	2025-09-18 04:51:14.098982-04
ACCESS_20250918175118_00001278	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	19869280-a6c6-46f9-ab43-bab068e60581	82F5246FA3636311AE0115C9996A464A	01	2025-09-18 04:51:18.056112-04
ACCESS_20250918175120_00001279	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	d1364bc9-0db2-494e-bac7-5c0467442ced	F3CC4353B3EF92A8B8A74D818CB33DF7	01	2025-09-18 04:51:20.611802-04
ACCESS_20250918175121_00001280	system	GET	/api/v1/ref/user/detail/jijeon	사용자 관리 - 상세정보 조회	10.42.0.1	b96f2871-4c70-4cc6-a86a-c93c356b8880	E4607A74134209E7E0B3DC8E1F34A250	01	2025-09-18 04:51:21.186554-04
ACCESS_20250918175128_00001281	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	0ecf8dcb-e5b4-4596-8fc3-3e5c8e30147f	8B5C3F50BC1D60B047C5031A1EE193AB	01	2025-09-18 04:51:28.136502-04
ACCESS_20250918175128_00001282	system	GET	/api/v1/ref/user/detail/jijeon	사용자 관리 - 상세정보 조회	10.42.0.1	b7ca8ff7-16bc-4b07-b41c-25d2d82d9afa	17F1719F33A804E82173656C165B6561	01	2025-09-18 04:51:28.230751-04
ACCESS_20250918175132_00001284	system	GET	/api/v1/ref/user/detail/jijeon	사용자 관리 - 상세정보 조회	10.42.0.1	bce088c7-4726-46dc-92e9-4d05ef8dd0c0	31074EC8973C45454FADB99B25E2C7AE	01	2025-09-18 04:51:32.755323-04
ACCESS_20250918175137_00001285	system	PUT	/api/v1/ref/user	사용자 관리 - 사용자정보 수정	10.42.0.1	c51d4969-10d8-4cc1-a92e-b6d535337eaa	4AAA653B1E5475F82146C4079270ED31	01	2025-09-18 04:51:37.766399-04
ACCESS_20250918175144_00001288	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	fcb3a399-18f1-4305-ac84-8ea93b39bcd8	CFCC3E44D3676B15D84D1D905D1A3255	01	2025-09-18 04:51:44.183926-04
ACCESS_20250918175148_00001289	system	GET	/api/v1/ref/customers/koiware	고객사 관리 - 상세정보 조회	10.42.0.1	4a7b991d-f6e0-4ba3-a7b1-779f2d159485	24997CC258A62B35F0F6B0176AA07934	01	2025-09-18 04:51:48.112153-04
ACCESS_20250918175233_00001290	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	5ec6c9de-942d-42dd-b781-ba2381a38d70	FBE1DE4475D3343291C166AF27550CDA	01	2025-09-18 04:52:33.972274-04
ACCESS_20250919161118_00001355	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	a037b87e-b6b0-4558-8e22-d51846cc6d08	BE59AAFF010CCD72ACC25E86C2C043D4	01	2025-09-19 03:11:18.897973-04
ACCESS_20250919161128_00001356	system	PUT	/api/v1/incoming/slock/config/7	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	a12cbe2d-2ca3-486e-ada0-7034e16530b4	9B4533FD3AE563C186EDC1E761103F88	01	2025-09-19 03:11:28.406198-04
ACCESS_20250919161134_00001357	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1	e357316b-63c4-45c2-bf65-e2e666810885	AF3180D7170ED7020B1F82CA89CA6621	01	2025-09-19 03:11:34.024608-04
ACCESS_20250923172450_00001406	hckwak	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	7ea6d615-60d6-476a-be15-e8f12c206bb8	C743E798434553633E52C6F206D9B680	01	2025-09-23 04:24:50.573563-04
ACCESS_20250923172451_00001407	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	b1c633c7-9623-4f2d-875b-f64b85570582	CD7FDF05F34C758D0376769FB2CC971A	01	2025-09-23 04:24:51.675799-04
ACCESS_20250923172454_00001408	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5ddf39d4-4d39-4570-8b5d-7383bc560226	AA7552BE39FB71408EACFA279D795796	01	2025-09-23 04:24:54.411114-04
ACCESS_20250924185142_00001452	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	ddc6a0af-73bc-4521-90fa-75fcdbedb757	70F42544156A5C5329DF6F000D84EA1C	01	2025-09-24 05:51:42.434805-04
ACCESS_20250926150434_00001470	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	476b45c2-8dc7-4ef6-86b5-56c5a28e5a67	84F11B1CD02225769B8576FE28ACD1B4	01	2025-09-26 02:04:34.343479-04
ACCESS_20250926150438_00001471	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	df0f4229-cff5-4a38-b1c9-8f35b35d4b96	A6640F95CD7CB88ADF173962FE3F53B8	01	2025-09-26 02:04:38.118635-04
ACCESS_20250926150441_00001472	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	2c248177-258a-4ac6-a5de-110e1928c20b	1973A91E85A92A006851020A49C4026C	01	2025-09-26 02:04:41.091986-04
ACCESS_20250926150442_00001473	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1, 10.42.0.170	ffc7eb9c-d5b3-4205-9baf-83aa0f90c542	23E2FF50747EAF1C2108A9736043CD1A	01	2025-09-26 02:04:42.450671-04
ACCESS_20250926150444_00001474	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	717e9698-2696-441c-b3d9-93966921f04f	B0B1CC4FF1DBE681523593AB66B7428E	01	2025-09-26 02:04:44.158685-04
ACCESS_20250926164118_00001524	system	GET	/api/v1/product/13	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	7a9526bb-e159-4dbd-b905-451f5d2452be	4E95AC3C3B2636C23B8478DE2F2C4393	01	2025-09-26 03:41:18.079862-04
ACCESS_20250918163503_00001161	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	9027eabb-1eef-4892-9918-debae0e1e741	486D85CD7B67F76006FADCEAB2B8DD5B	01	2025-09-18 03:35:03.091824-04
ACCESS_20250918163506_00001163	system	GET	/api/v1/product/1	입/출/반품 관리 - 상세정보 조회	10.42.0.1	c69e834e-d431-47a9-aa6f-d177d3fd26e8	62DB0FD545A52347DE9D0F79C586F517	01	2025-09-18 03:35:06.281146-04
ACCESS_20250918163515_00001166	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	f4b40a4b-631b-4097-83aa-668417761278	F6CAFA3321276C65372B42545667A5EC	01	2025-09-18 03:35:15.353672-04
ACCESS_20250918163518_00001170	system	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1	925c5942-36d4-4617-9e53-a610c44cb9f8	40BA21C560B5EBF08E2B96070A20EF0B	01	2025-09-18 03:35:18.299178-04
ACCESS_20250918163519_00001171	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1	0550512f-0917-4698-be32-c395ecbe393e	27E5C0998E5EF969621EECF3D37F4B38	01	2025-09-18 03:35:19.099015-04
ACCESS_20250918163534_00001173	system	GET	/api/v1/ref/customers/GlobalJW	고객사 관리 - 상세정보 조회	10.42.0.1	8d46300b-4912-4838-8f88-811d393e8579	E9148EFD92E2E56D95EEEAC0DF338DC9	01	2025-09-18 03:35:34.250693-04
ACCESS_20250918163549_00001177	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	4571a4e5-59a1-4b40-94c3-6f8737882e11	6BC1E22062F207AE567251CE3DC4AB4A	01	2025-09-18 03:35:49.936458-04
ACCESS_20250918175249_00001291	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1	6ded075c-b969-4452-ab4b-fde703204f61	1D1FC12DEAD58D502B9C0EB4A64D27F9	01	2025-09-18 04:52:49.288079-04
ACCESS_20250918175257_00001292	system	GET	/api/v1/ref/notice/1	공지사항 - 상세정보 조회	10.42.0.1	3571e552-9673-4f1e-91f7-f28a001acbeb	D1548E02ABE792259C6BA0AEF343AEE7	01	2025-09-18 04:52:57.23872-04
ACCESS_20250918175330_00001293	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	9499bcf6-71bf-47b7-828f-fbaa8bd4a0a2	F0421DDFC6652B5DC9A06734A022A0F4	01	2025-09-18 04:53:30.34025-04
ACCESS_20250918175331_00001294	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	dd155596-5a4d-4c0e-82da-e582bafd43e0	963F45AD37123C226300678E28E6141F	01	2025-09-18 04:53:31.708659-04
ACCESS_20250918175335_00001295	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	083c229f-942d-4671-9808-283a454681ca	4FC49636E971B1C87F4864CC0014ADFB	01	2025-09-18 04:53:35.253195-04
ACCESS_20250919161144_00001358	system	PUT	/api/v1/incoming/slock/config/8	입고관리 - 설정값 수정(자물쇠)	10.42.0.1	7e2d393b-a252-4be6-a2e3-c845c6f45bf4	4F56F65BB0DD1D78CDE03A4BC9DFC3AE	01	2025-09-19 03:11:44.199706-04
ACCESS_20250919161158_00001359	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1	aaf4f034-517d-4b90-af19-a3935bc6d659	86401597E06B10BD7BA85B682E14DEB5	01	2025-09-19 03:11:58.966867-04
ACCESS_20250919161159_00001360	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1	cb3d8503-9ca2-45b9-9f66-922b4951e4ec	A289A475D21399AE1DF4E5B53DAEF617	01	2025-09-19 03:11:59.001709-04
ACCESS_20250919161215_00001361	system	GET	/api/v1/incoming/slock/7	입고관리 - 상세정보 조회	10.42.0.1	cb37f0a6-99fc-4ec6-b6fe-bd09c9e1819e	40445B1B1C3C2E72F7D0548F3F3D6F40	01	2025-09-19 03:12:15.806393-04
ACCESS_20250923172647_00001409	hckwak	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	1bdb1c3b-4dff-4668-bc1d-a3fcc77619d7	9675C2B37BF542F6909B7F8D10EBFB80	01	2025-09-23 04:26:47.404141-04
ACCESS_20250923172652_00001410	hckwak	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	a0fca55d-e04c-4ec9-8765-337b0ee12e57	03172C4CB1D04E4710E887F0016762BD	01	2025-09-23 04:26:52.073836-04
ACCESS_20250923172701_00001411	hckwak	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	e824f010-e4bb-4043-8ca8-e55e3f5f762e	6060898258D11BCFAA5871690487BC62	01	2025-09-23 04:27:01.824666-04
ACCESS_20250923172707_00001412	hckwak	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	ae13a83d-931e-4fce-aa77-023be85e5613	E5FF70EFE23542AD9498506D7587ECE2	01	2025-09-23 04:27:07.414833-04
ACCESS_20250923172710_00001413	hckwak	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	fc6a7f95-7ad6-4b47-9a3c-68663d754949	7BC692C0FDBCB7E3646A3A2B1DFE3179	01	2025-09-23 04:27:10.959637-04
ACCESS_20250923172727_00001414	hckwak	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	298cedf8-51b9-42d5-add3-91d0e85da071	279E1DD9AC153C385D4927C59AC2834C	01	2025-09-23 04:27:27.664609-04
ACCESS_20250924185142_00001453	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1	a63401a6-148d-4edd-a633-92b12e7e5f9c	9B84D0D9A61F4BEC809D86AD317D76D2	01	2025-09-24 05:51:42.434562-04
ACCESS_20250926150501_00001475	system	GET	/api/v1/product/9	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	a64bb02d-0c57-493a-898a-d3393ad7a57b	4B5B78535EACE91CCF4E867FE2EF1998	01	2025-09-26 02:05:01.172937-04
ACCESS_20250926150514_00001476	system	GET	/api/v1/product/12	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	97c9f392-f24b-4778-b7e1-508c2b410766	EB5FD7880FA3672E630433D63DA30642	01	2025-09-26 02:05:14.141413-04
ACCESS_20250926164215_00001525	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1, 10.42.0.170	090e75cf-9ff6-4801-9ce5-a076f1753d83	EEB7CF18F2FA13F46EB48991210E0C0C	01	2025-09-26 03:42:15.737291-04
ACCESS_20250926164215_00001526	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	9d932576-6c03-47c6-87f1-d50b1b102c7a	42719E6B1232387AAB1BA0AEB6D7403C	01	2025-09-26 03:42:15.77403-04
ACCESS_20250926164222_00001527	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	58f0b0aa-9eb4-4258-bcdd-23aacf60ff01	89C6C84694BC3CFB8D4207447B135B5F	01	2025-09-26 03:42:22.796586-04
ACCESS_20250926164231_00001528	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	305f6a84-1a28-4f71-9e7b-a4241a6d1c52	C169545F4DEE7BC39EFCD1348E060F6A	01	2025-09-26 03:42:31.872309-04
ACCESS_20250926165345_00001569	system	GET	/api/v1/product/14	입/출/반품 관리 - 상세정보 조회	10.42.0.1, 10.42.0.170	e1cb6728-8b44-45d9-9e7c-6a50654df72b	D6F39E3E5E5C171512E85212126E613B	01	2025-09-26 03:53:45.258925-04
ACCESS_20250926165357_00001570	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1, 10.42.0.170	abd16267-19ae-44bc-82e8-530448de1aee	0F3B1E620536C97755922033B41BD7CD	01	2025-09-26 03:53:57.702707-04
ACCESS_20250930145926_00001591	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	81db20a9-050b-4d88-96e8-d833fe7946a3	43498900263E134A87782686F1EDD688	01	2025-09-30 01:59:26.713105-04
ACCESS_20250930150036_00001597	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1, 10.42.0.170	50d66a37-c610-416b-ac7a-489ea4a7cf78	DFB8104B325E4087AA7A43D5F9C29DEC	01	2025-09-30 02:00:36.710221-04
ACCESS_20250930151252_00001612	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	c7e3b1e4-cae7-47c7-8920-8a132ff0a493	72F56176F1FB8957DCA87B40CFC131EF	01	2025-09-30 02:12:52.629611-04
ACCESS_20251002110116_00001627	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	10187062-1291-4b5c-95a2-15dcd9f60539	48ACDB02E1496EAB583A95E17627C1DA	01	2025-10-01 22:01:16.915382-04
ACCESS_20250918163506_00001162	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1	b6b2a2b8-844b-49e6-b060-a944ffdd6811	7FDD9D5F17A8B2220EDD9BE533240697	01	2025-09-18 03:35:06.156399-04
ACCESS_20250918163511_00001165	system	GET	/api/v1/ref/common-code/items	공통코드 - 코드항목 조회	10.42.0.1	2332b023-5d5a-4257-9e79-cc85b9407cc4	2B85913866C45A85933CE6DED841EBAD	01	2025-09-18 03:35:11.025631-04
ACCESS_20250918163515_00001167	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	c2700836-de55-485f-a83f-93bf57413431	F5F9099C715995761D0A72701857412D	01	2025-09-18 03:35:15.484649-04
ACCESS_20250918163532_00001172	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1	9e18a501-7751-41ca-90a6-2fc045f44e78	1129B7C678A64E79F4480748990CAEE0	01	2025-09-18 03:35:32.85243-04
ACCESS_20250918163549_00001176	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1	cde98472-e59d-437c-b158-a833f5717099	8FA9053FD5E9047BD850C4F45FF90BE4	01	2025-09-18 03:35:49.936449-04
ACCESS_20250918163553_00001178	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	2891e392-4775-497f-8e70-6aee0641b51c	9D91E175C560C6AA7B474B4C62E9A3DD	01	2025-09-18 03:35:53.333716-04
ACCESS_20250918163557_00001181	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1	089b22a3-d570-4745-8950-a3d8b30e44c9	F1E6994664B1D8C4A1E8345EB61EB5C8	01	2025-09-18 03:35:57.147732-04
ACCESS_20250918163604_00001182	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	848c0201-ae74-48d2-8b02-11f16262f9fe	4F5AFC02EDE025EB71704C0D3970052D	01	2025-09-18 03:36:04.843829-04
ACCESS_20250918163607_00001183	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	f2d07647-f728-418f-9c9b-a12d12a8d95a	81CD14DDD471CDD688708D95C2A9D39D	01	2025-09-18 03:36:07.285152-04
ACCESS_20250918163617_00001184	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	31c3fa3e-ba1b-4110-b205-22985efa477f	08C5C65BEFEF111F39A16D04AD1E3138	01	2025-09-18 03:36:17.927234-04
ACCESS_20250918163631_00001185	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	c295ac62-b977-4244-bac6-75d522dac02a	DD78270FF846216D925FD56B1C9FDBE8	01	2025-09-18 03:36:31.137538-04
ACCESS_20250918163634_00001186	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	2d1a5872-5be8-49de-93f3-bb0ce4032712	032A4449A7921CE0F6760BA1360F08B9	01	2025-09-18 03:36:34.608394-04
ACCESS_20250918163638_00001187	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	617a1df9-1e61-41b0-9907-cc75db041a58	DA1F1232839D027C4D8A6EB797F64C58	01	2025-09-18 03:36:38.398046-04
ACCESS_20250918163639_00001188	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	1033f8e4-b6bf-43b4-b2df-251454cfa7af	89E15E9DF8B9325B7B9341832B2722A2	01	2025-09-18 03:36:39.651151-04
ACCESS_20250918163648_00001189	system	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1	13b23f62-146f-41ec-a074-7da27949505a	4E10B5023608E9CB5073AF52EF280D3A	01	2025-09-18 03:36:48.175285-04
ACCESS_20250918163649_00001190	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	298c98ca-c560-464e-b42b-f430f11c547b	119C5204291D9FAC07366EE29A9257E9	01	2025-09-18 03:36:49.434027-04
ACCESS_20250918163732_00001191	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	cfdaae9b-7677-4bd1-8f7e-1f11264ee325	4517A0D0DB26E6CD50BBB929DD675903	01	2025-09-18 03:37:32.912429-04
ACCESS_20250918163737_00001192	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	13f60bac-ec89-403e-b7ea-77fcb75d8b46	5B3531B35A20393FCF9FB3A778CCC651	01	2025-09-18 03:37:37.948-04
ACCESS_20250918163737_00001193	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	0ee0acd7-37d7-4abe-b3bc-62892b316d4c	BC6A56216A2C88B42DBD3853A1C63737	01	2025-09-18 03:37:37.955541-04
ACCESS_20250918163751_00001194	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1	e21eea86-3ced-4585-925d-9fdcf45c73a5	3AE1A3DFD70ECEF989FA33A91078F6FE	01	2025-09-18 03:37:51.543786-04
ACCESS_20250918163751_00001195	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	cc667cb0-719e-474f-b53d-c6e4238b0306	ABFB97FC0BD464B5C87A28384EFEB831	01	2025-09-18 03:37:51.601358-04
ACCESS_20250918163755_00001196	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	189acb1a-aa49-41a5-96b0-8bd9911ebf5e	CD144A40E80355237A45306E22043616	01	2025-09-18 03:37:55.597058-04
ACCESS_20250918163805_00001197	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	53826133-b9d8-4ad8-8ef4-97c52279cfd5	14BCD66F3B259CE7EDD93F1A8F85D7CB	01	2025-09-18 03:38:05.164573-04
ACCESS_20250918163813_00001198	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	820d42fd-6053-4897-bf50-0eaeddbcc79f	94B83A2B8F02EA4FFEE167233AA93C2E	01	2025-09-18 03:38:13.800794-04
ACCESS_20250918163815_00001199	system	GET	/api/v1/report/log	접속현황 - 조회	10.42.0.1	222034d9-8c0c-494a-a4bf-e045412a1387	4719FD55B92079B13B1F201CC8EC1140	01	2025-09-18 03:38:15.383077-04
ACCESS_20250918163816_00001200	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	13058177-1d05-4a69-86bb-3d4729182ff3	3B28314B28D63875C111442F95C394CF	01	2025-09-18 03:38:16.645852-04
ACCESS_20250918163828_00001201	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	dcb29309-caa9-4c7f-b32f-1cee2854fc9b	F3DEE725E5FB504BE06661619C551EE1	01	2025-09-18 03:38:28.458563-04
ACCESS_20250918163837_00001202	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	dbdac071-cb17-4ad3-a023-4e0f15cdfcfc	837936E32105A29B981C895DDBAE8489	01	2025-09-18 03:38:37.007416-04
ACCESS_20250918164027_00001203	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	6709384b-f031-4531-ac00-b839f59f5380	AC4A0422299C1CA443A37F1AD1EE3481	01	2025-09-18 03:40:27.296258-04
ACCESS_20250918164036_00001204	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	c4ccdae6-dbdc-4b6e-9ae2-c2082b4cfbc1	898D19E4DBB9EFF960560F7E89E74ED6	01	2025-09-18 03:40:36.729636-04
ACCESS_20250918164054_00001205	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	75cb3926-5134-4670-86e4-49924579d1d5	303916366ACAFC0817490B2D4CA80DFB	01	2025-09-18 03:40:54.150768-04
ACCESS_20250918164054_00001206	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	eaa66c95-b6c2-4ed4-a4e0-9d89f95cd342	26011B74FDEF950ABE0165359B2D9523	01	2025-09-18 03:40:54.570597-04
ACCESS_20250918164056_00001207	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	1f37f143-73b0-4353-ba62-6f071ab24895	A5FBD80D8FB435F5DA43F6B829362BBF	01	2025-09-18 03:40:56.041938-04
ACCESS_20250918164121_00001208	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d9e8cfd1-caff-4b4f-9996-45bb2799ddd7	390187BC79D5F1D9F4BBB73B2FC7C94E	01	2025-09-18 03:41:21.261588-04
ACCESS_20250918164135_00001209	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	60e3aa97-0a78-472e-b161-b4bb8d73c24d	08365FB7BE65E099B5EAFDC09EC2B1BF	01	2025-09-18 03:41:35.448894-04
ACCESS_20250918164207_00001210	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	d9044657-8d87-45f2-8b5b-8d7f8d472f41	F4FFD7FAC4917D26694A8BE809E02A0A	01	2025-09-18 03:42:07.929016-04
ACCESS_20250918164218_00001211	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	2ccbe4da-5952-45ba-86a8-33d8daadd738	09FC77E54A8D9E26BDACCC5218C58E0B	01	2025-09-18 03:42:18.244246-04
ACCESS_20250918164223_00001212	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	3f822f99-d3c1-4704-89ce-1f04139a5081	390B97D3DE193D84CDD0BD0E60350FC2	01	2025-09-18 03:42:23.237975-04
ACCESS_20250918164252_00001213	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	0a323229-fc33-4ec0-adac-6bbb2eb578ed	7427D17F857DFF840539E31CFEBB58CD	01	2025-09-18 03:42:52.155234-04
ACCESS_20250918164306_00001214	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	6275b675-9438-4055-940f-a24bc38e8ef3	AA24107439D6C5CA25BE518EFCB966E2	01	2025-09-18 03:43:06.24144-04
ACCESS_20250918164308_00001215	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	8d69a0de-b429-4dc4-bebc-3efa9d9ea471	01A5A272AF4976DA7D609769E254B8C1	01	2025-09-18 03:43:08.504041-04
ACCESS_20250918164342_00001216	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	415f4c91-2b5b-4782-8314-e03b87bfa7e0	FD73AAB1BAE282599A0672AC58B68190	01	2025-09-18 03:43:42.294798-04
ACCESS_20250918164356_00001217	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	49a2c145-a944-4996-acfe-9fd51560d1e8	2FCB5911ECC7B341A943745A32C8E1B1	01	2025-09-18 03:43:56.730617-04
ACCESS_20250918164428_00001218	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	4f472edb-6d44-428e-a780-1e4da6061fde	2DF434ADAECE10153D919F7AB238406D	01	2025-09-18 03:44:28.108638-04
ACCESS_20250918164438_00001219	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	32b4ed72-a3c9-4be3-a729-a29ed4fe57e2	1A8093DE6CDDB741C7A3F70CB0487488	01	2025-09-18 03:44:38.306273-04
ACCESS_20250918164439_00001220	system	GET	/api/v1/product/4	입/출/반품 관리 - 상세정보 조회	10.42.0.1	cb3b7eda-bf7c-4f82-a6a8-fd8ccc0c2270	4ABBFF1D21D72FB78BDCD16D2EADC751	01	2025-09-18 03:44:39.168857-04
ACCESS_20250918164551_00001221	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	a45058de-95e6-499d-945a-85613f4f3b51	6786CBCCECB2D6B3A156CF60529F67DD	01	2025-09-18 03:45:51.819512-04
ACCESS_20250918164604_00001222	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	ad752e5a-5a85-4e99-86a1-0d4f31ecb75b	67A15F696FC03A53D6AE0807138A6A8F	01	2025-09-18 03:46:04.831244-04
ACCESS_20250918164605_00001223	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	b63c209c-5ccd-4a46-93c2-532b56f0f7c3	2F32DEE7B81B0C29A7A216F6DACF90AB	01	2025-09-18 03:46:05.905244-04
ACCESS_20250918164613_00001224	system	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	51c90026-30d4-4329-8b63-6d0a7aaa6254	21914351C2BCF4D75C61AF4821F8950A	01	2025-09-18 03:46:13.704144-04
ACCESS_20250918164617_00001225	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	33914a75-5193-4b40-bb15-834bba08c545	6780AB317D958400B5535AFEEB33A58B	01	2025-09-18 03:46:17.292321-04
ACCESS_20250918164617_00001226	system	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	a629dec9-281b-412f-9b3e-85ea1bc9d302	758F6E9D2D7BBD3F01D6FDEA145E0F0E	01	2025-09-18 03:46:17.29977-04
ACCESS_20250918164622_00001227	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	d923e73c-8124-4497-b01f-78c000586f49	556E0CD823191FCD5D029AFDABC07410	01	2025-09-18 03:46:22.837459-04
ACCESS_20250918164634_00001228	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	c4cecf56-ff7f-4bfd-815b-ec73f348eecf	9A593A5261F724D130B25C22335BD698	01	2025-09-18 03:46:34.71142-04
ACCESS_20250918164653_00001229	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	e43b0d28-8b1e-406b-84c3-1e204b74a51b	EE1B1DBD9B9B850ADC5705010CE89D43	01	2025-09-18 03:46:53.725348-04
ACCESS_20250918164654_00001230	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	9f6244f2-9655-474d-8a25-7add6f5502eb	5BFBEDC3290F5E3DE2897C2D43FD3C28	01	2025-09-18 03:46:54.492537-04
ACCESS_20250918164655_00001231	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1	887a90fd-c668-4bda-8863-d878376e7405	4F49BF458DBB0CFC5F7B67F1E214F35B	01	2025-09-18 03:46:55.87238-04
ACCESS_20250918164657_00001232	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1	86e0ca9a-7d18-4763-9c36-7ce88b997a1b	CAA00189C265639ABA4B77DE1CF89996	01	2025-09-18 03:46:57.689754-04
ACCESS_20250918164658_00001233	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	767dd0ce-65fb-41ec-a500-2a37c0455f4b	14952682DE8B6F4F3F76BA3F1F1AAB90	01	2025-09-18 03:46:58.291513-04
ACCESS_20250918164705_00001234	system	GET	/api/v1/product/2	입/출/반품 관리 - 상세정보 조회	10.42.0.1	94bdfafa-4030-4703-96f7-e8770ff45b2c	C786F57CAD0AF399626084F27D32836F	01	2025-09-18 03:47:05.443356-04
ACCESS_20250918164705_00001235	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1	1f6160e4-3a85-4732-8b80-6a360aa76aa9	77897C14772CB77BD5DCB33A179E3D5E	01	2025-09-18 03:47:05.448892-04
ACCESS_20250918164829_00001236	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1	2eb8f374-f90f-46af-8892-ae6f7c8aa952	50E1BC1FBE93E68896F1611F01DDD1E6	01	2025-09-18 03:48:29.237134-04
ACCESS_20250918175430_00001296	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	68ecacf4-a1b8-48c1-9094-82beb97e8234	9C89C31DA5E93F8851E8863F06CFB99E	01	2025-09-18 04:54:30.064853-04
ACCESS_20250918175431_00001297	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1	5930a9a1-be48-4e85-8a1c-c0525e5753f2	6CB31E1B361C72CD068E3B1D61ADD6B4	01	2025-09-18 04:54:31.351544-04
ACCESS_20250918175434_00001298	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	8a59b6a3-06c8-4bc2-9f14-73718f14a7fd	B538E51DDA4AF0C9984CDF9461BAE2AE	01	2025-09-18 04:54:34.799785-04
ACCESS_20250918175444_00001299	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1	298ad522-51da-45aa-af6d-9a7b03f45600	D2083E937F5DF747B8081AF49F68B1A2	01	2025-09-18 04:54:44.083079-04
ACCESS_20250918175450_00001300	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1	86eea312-fabd-4cbc-b5c2-e686adebb8dc	49D1558FDAF1C337D3178EE26B403F89	01	2025-09-18 04:54:50.19043-04
ACCESS_20250918175451_00001301	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1	7769c5b8-0f43-4476-ab09-5e7f5134da6f	DCDF45F235246FCB20F9278A4783B9DD	01	2025-09-18 04:54:51.984424-04
ACCESS_20250918175459_00001302	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1	8c04f48b-9083-4205-8358-cb67ac432948	3EAA991CE9030E37E4E05BD2A0409375	01	2025-09-18 04:54:59.592456-04
ACCESS_20250918175502_00001303	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1	5a855a0f-b0d6-4fa7-8300-42687cbcf719	74CA4E0B4F8EFF63244C644CCA608BBD	01	2025-09-18 04:55:02.839374-04
ACCESS_20250919161255_00001362	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1	9f77397d-aee0-4dcd-9f7b-9591ad566897	2D439F06E523D386CE60B3F307DD3B16	01	2025-09-19 03:12:55.481749-04
ACCESS_20250919161302_00001363	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1	e40ee241-0270-413d-804b-991b8d882ca0	E4A0D77A92D1EAB022DDED6A5BA1F56D	01	2025-09-19 03:13:02.411261-04
ACCESS_20250919161302_00001364	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1	5ad33930-59fd-4b63-ad39-6036cb173b50	ED5E1F699AC36DF1220F88B775759C88	01	2025-09-19 03:13:02.451996-04
ACCESS_20250919161312_00001365	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1	5487d96f-5101-4814-9260-caef95911200	D55C620CC480EBA88D5408850BDBD68B	01	2025-09-19 03:13:12.21721-04
ACCESS_20251002155953_00001645	system	GET	/api/v1/ref/users	사용자 관리 - 조회	10.42.0.1, 10.42.0.170	9ec60cc7-9af2-4d6d-8f1f-09c3006f0f80	06408468CE12F648710AB1F734A06766	01	2025-10-02 02:59:53.228984-04
ACCESS_20251002155957_00001646	system	GET	/api/v1/ref/customers	고객사 관리 - 조회	10.42.0.1, 10.42.0.170	a2c30237-bda9-4154-9d9c-d8d8d73a43aa	238781C6B22D86F4083792FCBEB6EDAA	01	2025-10-02 02:59:57.902572-04
ACCESS_20251002160001_00001647	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1, 10.42.0.170	9d7b2273-f703-4726-8e01-48fb9a8b7b56	4EE89CF2C38A7C129D8FC04496695A5D	01	2025-10-02 03:00:01.563675-04
ACCESS_20251002160002_00001648	system	GET	/api/v1/ref/notice	공지사항 - 조회	10.42.0.1, 10.42.0.170	1a9f70c2-fcc8-4e76-b8e7-3ddafaeb06b5	EE706311C8A41BE87A78CEC71D0E97A7	01	2025-10-02 03:00:02.605183-04
ACCESS_20251002160003_00001649	system	GET	/api/v1/ref/common-code	공통코드 - 조회	10.42.0.1, 10.42.0.170	45636c05-c0c0-49d1-b2bd-7099d45472d7	159BC2CEEE96847CA5CA467E75920802	01	2025-10-02 03:00:03.385204-04
ACCESS_20251002160004_00001650	system	GET	/api/v1/ref/sequence	자동채번 - 조회	10.42.0.1, 10.42.0.170	f681f89f-0bc7-45ce-8d68-d9bba54dc284	8FD417781EAFE7B70FAFFCC89C08AE60	01	2025-10-02 03:00:04.845196-04
ACCESS_20251002160011_00001651	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	2e9a4c90-af63-4e85-b782-7838e194c1b0	7BA76C8C1C3E519032DA8047990B2EDC	01	2025-10-02 03:00:11.23562-04
ACCESS_20251002160013_00001652	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	15fd503f-cc67-4811-8f8e-1ea1c4c22418	D4EBEF18592616FEA866E397F53F33DA	01	2025-10-02 03:00:13.741619-04
ACCESS_20251002160015_00001653	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	5ca35672-9b94-484a-ba72-8ebaa2a525dc	346EF4FF3B8F5FB052C979577726DB10	01	2025-10-02 03:00:15.847029-04
ACCESS_20251002160226_00001654	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	c1f39cd9-1484-4db5-8161-063dde85b8ca	85585AE06EFA811A797813C5B5D8BC45	01	2025-10-02 03:02:26.01827-04
ACCESS_20251002160322_00001655	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1, 10.42.0.170	e86999d9-3101-4162-b2da-9bf213dea3e9	11BDF8F50BBD9CEFA9D492D91EED01B3	01	2025-10-02 03:03:22.458216-04
ACCESS_20251002160337_00001656	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	25f95fa8-1e91-4775-924c-bcfd7e11c9be	2BBD38D261AF3B3A2EE4324F6AD8548F	01	2025-10-02 03:03:37.618136-04
ACCESS_20251002160341_00001657	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	b35d9b15-6c0f-414b-a008-0530cc05e7f9	164168CE36E1EB43CF0B7554B5A57433	01	2025-10-02 03:03:41.847614-04
ACCESS_20251002160346_00001658	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	9f99608a-cc6c-47ca-b3c7-67f04f0dfed6	276819B192ECF4B918BDF11213171972	01	2025-10-02 03:03:46.549882-04
ACCESS_20251002160352_00001659	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	5357094f-4505-42fa-bc4a-98a35319acc3	8611B9F9AA7977EB97B7C96251649B7D	01	2025-10-02 03:03:52.213664-04
ACCESS_20251002160355_00001660	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1, 10.42.0.170	5d7a4a1a-b630-474d-aa26-a825c272624a	627B43BBC3786C0190A89DA5866B8D17	01	2025-10-02 03:03:55.241135-04
ACCESS_20251002160414_00001661	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1, 10.42.0.170	105c4862-f817-46f6-9bb4-c0c90c297080	5BDEC8F1CF17049454C4BB4EBD9AC3BD	01	2025-10-02 03:04:14.480983-04
ACCESS_20251002160423_00001662	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	b844c9a6-d6e2-4d71-91bb-41c3a0ec15c7	7B4501D86B4C71AAAE5E90538EC6DD09	01	2025-10-02 03:04:23.789335-04
ACCESS_20251002160427_00001663	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	50f398b6-7df8-4608-8546-3b01ca264c21	AA7C2ED47ECCF479EEDA83AA2DBD749B	01	2025-10-02 03:04:27.950391-04
ACCESS_20251002160433_00001664	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1, 10.42.0.170	610bf5e4-be5f-4939-b209-0932d47a2e31	86EAFE856D1EC0D25FB3AAAD7274536A	01	2025-10-02 03:04:33.253717-04
ACCESS_20251002160444_00001665	system	PUT	/api/v1/incoming/slock/config/15	입고관리 - 설정값 수정(자물쇠)	10.42.0.1, 10.42.0.170	07101868-8217-4a4c-89b6-3958baa0a668	8139EB21179CFEA1290FE501BB1C6618	01	2025-10-02 03:04:44.702067-04
ACCESS_20251002160451_00001666	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	86e95003-4deb-47a6-8eeb-d564a5189e70	43A7626F47315C4C236EA7DAA197F2DF	01	2025-10-02 03:04:51.380268-04
ACCESS_20251002160458_00001667	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	5d2deca9-8bf3-4400-b005-22f7245c3f2d	149AFE1A8FA39E7DED5D6178BDA0B935	01	2025-10-02 03:04:58.863218-04
ACCESS_20251002160503_00001668	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	9dcb1ad5-c7f6-4508-b90b-a980f44b4a77	A5109BFE3242EFEB0635BD2E060AE50E	01	2025-10-02 03:05:03.246411-04
ACCESS_20251002160525_00001669	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	b1afaa12-a6b2-4f80-927a-6e850bc80659	0B947BE4231514E6823544630331B42A	01	2025-10-02 03:05:25.695667-04
ACCESS_20251002160530_00001670	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	d65f995c-1f4b-4366-a33b-31116501d0cf	095F7AAAC4FBEEB290AD41DC28B5D078	01	2025-10-02 03:05:30.279555-04
ACCESS_20251002160543_00001671	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1, 10.42.0.170	42534dad-da27-48bc-9043-ff031ebff0b1	D0FE0895EAF50D8765541AB56B5AA6AC	01	2025-10-02 03:05:43.711237-04
ACCESS_20251002160548_00001672	system	PUT	/api/v1/incoming/slock/config/15	입고관리 - 설정값 수정(자물쇠)	10.42.0.1, 10.42.0.170	98f9e1db-ec3d-4fec-b14f-20f14a6b2017	31C892FDDBA95A5543DA3F6FE742D283	01	2025-10-02 03:05:48.411831-04
ACCESS_20251002160555_00001673	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	c663f285-5ba5-4e13-9575-6f17f5e35ef3	990C8545314A54AE53DE78D17907E657	01	2025-10-02 03:05:55.222417-04
ACCESS_20251002160626_00001674	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1, 10.42.0.170	983458d6-a795-4aa0-ac74-089a7fa16f01	F9BA5B4E9E8CE92E84D10272915E4A48	01	2025-10-02 03:06:26.567515-04
ACCESS_20251002160626_00001675	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	a34bf84e-d5c6-46b0-945a-67ecc08a5bd1	1086204EC0BC4D21EA8623AAA9224BF1	01	2025-10-02 03:06:26.602872-04
ACCESS_20251002160721_00001676	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	c9681d05-cd9d-441d-9049-32d2b46f0fd4	377FCB4536B9F856C8F1C9C2536058D9	01	2025-10-02 03:07:21.246415-04
ACCESS_20251002160724_00001677	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	1ea34d19-053d-440f-aed4-b7c1b62d77c6	C8F5D3892A66FE6C6F17D675662E6648	01	2025-10-02 03:07:24.087973-04
ACCESS_20251002160733_00001678	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1, 10.42.0.170	089ef93b-64df-440c-be6e-1c85ced2a575	E735688530B7331D5903AC42720B1156	01	2025-10-02 03:07:33.885846-04
ACCESS_20251002160742_00001679	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	5df179a3-3fc8-4d52-918a-9d2e34975f34	A8FF09DED001ABA95D99CD6D41956007	01	2025-10-02 03:07:42.188617-04
ACCESS_20251002160746_00001680	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	a114fecd-9140-4418-8388-d7b5e2c59a60	13CE757D8FB23C96113DDB35C1BEEF03	01	2025-10-02 03:07:46.324176-04
ACCESS_20251002160751_00001681	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	aca9905a-b6cc-49ad-b767-959fe1c8421f	BA112548B172E88CB4750055F7C8B75C	01	2025-10-02 03:07:51.183687-04
ACCESS_20251002160757_00001682	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	f142f92e-585d-43db-86ef-9d501fc83cb3	5647E116DE47C6999411795F142AC6F4	01	2025-10-02 03:07:57.305847-04
ACCESS_20251002160801_00001683	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1, 10.42.0.170	47fb1ad9-58a5-4d7f-8e8d-6d3a32dd708a	E7F99DF66B1DD24A05AC04A43A05A64E	01	2025-10-02 03:08:01.034736-04
ACCESS_20251002160806_00001684	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1, 10.42.0.170	6d6f597b-6255-48ba-a263-396426203b84	61D028572C190F66F9E531B48B878811	01	2025-10-02 03:08:06.049493-04
ACCESS_20251002160819_00001685	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	56f37660-7bd4-445e-a417-2b65f2715200	41F13F704D74D164462479F3CCA76059	01	2025-10-02 03:08:19.256111-04
ACCESS_20251002160823_00001686	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	332ddfd8-3c85-4e75-8005-c4adb70205dc	3F3DF421704FB5D86FA46FCD9EB0F5F9	01	2025-10-02 03:08:23.253846-04
ACCESS_20251002160827_00001687	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	4dfda61e-814e-4877-9920-6649aeee76b0	491B583FD1C9C9F805BB54F4E120A07D	01	2025-10-02 03:08:27.260421-04
ACCESS_20251002160839_00001688	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	4f14fe3e-7a66-4a85-a629-0a8e4a974737	2C8AF7BFDC2EE22B3F0B2E8F3300F3F7	01	2025-10-02 03:08:39.52619-04
ACCESS_20251002160844_00001689	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1, 10.42.0.170	624abcff-ed05-4da9-a45f-ddaa51215561	DE5C9A32C43F155CD373BACCE6102F5E	01	2025-10-02 03:08:44.037762-04
ACCESS_20251002160854_00001690	system	PUT	/api/v1/incoming/slock/config/16	입고관리 - 설정값 수정(자물쇠)	10.42.0.1, 10.42.0.170	59da3554-3d6e-4435-8a65-a9fa65f455c2	41D85C8C6451B40DC4368CEC196486FC	01	2025-10-02 03:08:54.899755-04
ACCESS_20251002160904_00001691	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	82af989b-f299-411e-9b6b-60a1e26ed86e	D30C3438A519ECDA6DD5A67C8DC69338	01	2025-10-02 03:09:04.980325-04
ACCESS_20251002160908_00001692	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	9c2e2af8-5764-4454-9b44-7a703617c080	5A96579247F929613B23172B27F97E0A	01	2025-10-02 03:09:08.758314-04
ACCESS_20251002160923_00001693	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1, 10.42.0.170	6c1fe38f-38f9-4eee-82f4-5859d55bde50	4AC0EBDE027CADCE009B7D6E0A1C7EA5	01	2025-10-02 03:09:23.67709-04
ACCESS_20251002160923_00001694	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	758dca25-6375-40cb-8cc4-2996ce456517	2AA9E2CCC9492A7440CC5A8CE4D296F5	01	2025-10-02 03:09:23.706334-04
ACCESS_20251002160955_00001695	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	495468e8-5653-437c-9817-c2f3ada2f51e	26DE1A55833C01B43E02552BED2431F3	01	2025-10-02 03:09:55.480639-04
ACCESS_20251002160957_00001696	system	POST	/api/v1/incoming/slock/connect-status	입고관리 - Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	54f9986e-ce8c-428c-8a27-f94e54c4ed7e	C51B6267B2A1DBE9AA24B4EA40899CF7	01	2025-10-02 03:09:57.095905-04
ACCESS_20251002161002_00001697	system	POST	/api/v1/incoming/slock/connect	입고관리 - 기기연결(자물쇠)	10.42.0.1, 10.42.0.170	3be17e0a-2d9a-435c-bd94-13a3b35c18fe	AFB8351B5FA0006768695A4546D2D09E	01	2025-10-02 03:10:02.031071-04
ACCESS_20251002161011_00001698	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	70384cc6-3dc5-4a36-b07f-f84a700c4c52	EE6E86EBE11E0B68CEC8CC26BC800C11	01	2025-10-02 03:10:11.776433-04
ACCESS_20251002161016_00001699	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	16b1118a-a351-4f33-b9b9-7453313c7146	36D3BB83B6C570B47B9249E4A5984367	01	2025-10-02 03:10:16.382784-04
ACCESS_20251002161022_00001700	system	GET	/api/v1/incoming/slock/models	입고관리 - Lock 모델 조회	10.42.0.1, 10.42.0.170	79f49178-a08e-4302-b6be-2485826cb6b1	7ED9BA54C8D237E97A9BEB4C02F9A440	01	2025-10-02 03:10:22.474657-04
ACCESS_20251002161025_00001701	system	POST	/api/v1/incoming/slock/registration-info	입고관리 - 등록정보 생성	10.42.0.1, 10.42.0.170	5ce0cfec-c2ec-4de1-829f-6ed05938341c	284D95A719FC74124088CC6F0BF0C5A2	01	2025-10-02 03:10:25.502387-04
ACCESS_20251002161029_00001702	system	POST	/api/v1/incoming/slock	입고관리 - 등록정보 저장(Step3)	10.42.0.1, 10.42.0.170	9caca455-8141-4642-8b17-c7eb94410617	C8135AEDCB28FC20AB11A4518133E9A7	01	2025-10-02 03:10:29.015012-04
ACCESS_20251002161038_00001703	system	POST	/api/v1/incoming/slock/config	입고관리 - 설정값 조회(자물쇠)	10.42.0.1, 10.42.0.170	5204f2e4-10a3-4496-affd-b30c06ded47d	79BBCFB2C2AE5EEA17CEAC2D17EC6E33	01	2025-10-02 03:10:38.90265-04
ACCESS_20251002161048_00001704	system	PUT	/api/v1/incoming/slock/config/17	입고관리 - 설정값 수정(자물쇠)	10.42.0.1, 10.42.0.170	0416a617-4915-40ea-9073-28eec2a3c2b2	778ECF927C6FE2C60044E1D2063629BE	01	2025-10-02 03:10:48.092556-04
ACCESS_20251002161053_00001705	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	2c3b6640-2fb1-49ad-a4d5-8dc3c670ccf5	E8FFD3DB15916A5E859466FE000F1DE2	01	2025-10-02 03:10:53.459749-04
ACCESS_20251002161057_00001706	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	8c8a4674-b7c1-4ee3-bdcb-e70b4d67a391	3301A4FBD8815046E7022E7E223DE56E	01	2025-10-02 03:10:57.910616-04
ACCESS_20251002161103_00001707	system	POST	/api/v1/incoming/slock/control	입고관리 - 자물쇠 제어(Lock, Unlock, Unshakle)	10.42.0.1, 10.42.0.170	14431f22-d4ff-492b-b9c4-888c0da03fe1	461F5C055CE3B76C9BA42C64130709F7	01	2025-10-02 03:11:03.24552-04
ACCESS_20251002161116_00001708	system	PUT	/api/v1/incoming/slock	입고관리 - 부가정보 등록	10.42.0.1, 10.42.0.170	bede297b-41cc-4b65-a2fa-6129bba0a5a5	F2E2B3BEFF51AA6EEC801020D4ADC52B	01	2025-10-02 03:11:16.323862-04
ACCESS_20251002161116_00001709	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	8f563957-5449-47c0-a245-da6347613d20	F200442502D0E580952CB263AE984146	01	2025-10-02 03:11:16.354355-04
ACCESS_20251002161143_00001710	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	a54307a1-9fdd-4354-9546-db7c92336fbf	5287ED324E023AC8BEA730F75A7701DC	01	2025-10-02 03:11:43.821867-04
ACCESS_20251002161152_00001711	system	POST	/api/v1/outgoing/slock/connect-status	출고 Gateway 연결상태 체크	10.42.0.1, 10.42.0.170	c5ef23f5-8080-4499-8004-5e132f8c5e5a	2555B69F8B9776F7CEF45290A54D0027	01	2025-10-02 03:11:52.552465-04
ACCESS_20251002161152_00001712	system	GET	/api/v1/outgoing/slock/customer	출고처리 Step1	10.42.0.1, 10.42.0.170	9c293826-e312-4ec3-a891-32192a3ace08	3CFC565E741196AA25816BD8069FB179	01	2025-10-02 03:11:52.584621-04
ACCESS_20251002161209_00001713	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	1701297c-64b8-4db0-8527-18acbc5cdf1b	BC6795E9CEF47D20C0A17A3BE184F0CD	01	2025-10-02 03:12:09.8153-04
ACCESS_20251002161253_00001714	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1, 10.42.0.170	bb64ff7d-c9ce-4dd5-b8ba-48abf4a97aa5	FCA6FD751773877158D0FA370DD9B401	01	2025-10-02 03:12:53.406234-04
ACCESS_20251002161259_00001715	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1, 10.42.0.170	07911662-dfd2-4ed3-a48c-c54963b99726	D680F81C99959E76882E1C68ADB6EEC0	01	2025-10-02 03:12:59.2583-04
ACCESS_20251002161302_00001716	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	b2bfd936-ba01-4e3a-8b2c-f78979410258	E084F09B7B7FEFD6EBF6883C1ABB6489	01	2025-10-02 03:13:02.104454-04
ACCESS_20251002161308_00001717	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	56ff208a-f085-4ff0-8ded-c2070f940f1a	857A7312055BA944EEFE22F2644DC1EE	01	2025-10-02 03:13:08.769174-04
ACCESS_20251002161323_00001718	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	0604da7d-d6db-4216-a412-5d11d51f347b	970FE2D055E643BA9375964A61A9A10B	01	2025-10-02 03:13:23.709409-04
ACCESS_20251002161339_00001719	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1, 10.42.0.170	4023eea7-dfa7-4cb9-96e5-e92c30462663	209699EB8A0789F7CD2056C8A054AA88	01	2025-10-02 03:13:39.52564-04
ACCESS_20251002161339_00001720	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	913564c1-1b0c-4960-8929-f9ef466df882	10059931D3AC06BFD13E870F940A3150	01	2025-10-02 03:13:39.555178-04
ACCESS_20251002161356_00001721	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	c9477333-6c40-44e0-8dab-57f7fda59a23	F1E55128E865A4D01E0E864D68F34982	01	2025-10-02 03:13:56.975937-04
ACCESS_20251002161418_00001722	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1, 10.42.0.170	b83470b6-85bb-448b-9df3-ee2ef7c3a182	952129E265C27D85619E0DD37A1D0F17	01	2025-10-02 03:14:18.21555-04
ACCESS_20251002161432_00001723	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1, 10.42.0.170	6375eba2-f507-4b5a-879e-6c5bf27a6b8a	26B36A40EB3E9AC09DBB2081EFE95388	01	2025-10-02 03:14:32.831114-04
ACCESS_20251002161435_00001724	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	34220b0d-4314-4866-b122-4ecc4a71748c	430D107F5E24A3739A98291BB95E5797	01	2025-10-02 03:14:35.695258-04
ACCESS_20251002161439_00001725	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	7cf4f915-01bc-4f97-90d1-4e5b7d9033e9	3FB084040ED34631523367EEDB226340	01	2025-10-02 03:14:39.823513-04
ACCESS_20251002161444_00001726	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	2e7114af-314e-42c4-9d08-ad1d0c3ca460	24C20EA57E505E866D45293976337B37	01	2025-10-02 03:14:44.205449-04
ACCESS_20251002161448_00001727	system	POST	/api/v1/outgoing/slock/eventLog	출고 이벤트로그 조회	10.42.0.1, 10.42.0.170	6d7d1427-12ee-4e27-babb-6d2cf8d0cfe3	66874FC2FEE8F3AFEE6C4ED1FE5A6689	01	2025-10-02 03:14:48.1812-04
ACCESS_20251002161455_00001728	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	d15cb493-b379-4877-b078-08d049d3a8a4	8C9C31F6BD97A456DDAEE2C9ECC9D00D	01	2025-10-02 03:14:55.694856-04
ACCESS_20251002161459_00001729	system	POST	/api/v1/outgoing/slock/eventLog	출고 이벤트로그 조회	10.42.0.1, 10.42.0.170	044dfa5b-327c-4201-be88-a0088412f597	55D2BD1C620F36095BA9A665059D06C5	01	2025-10-02 03:14:59.501081-04
ACCESS_20251002161505_00001730	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	3ce8b828-b19e-440d-8b38-1d2b99a9bd45	CB44BD7B6D0C14B29505C9BE707351CD	01	2025-10-02 03:15:05.006418-04
ACCESS_20251002161520_00001731	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1, 10.42.0.170	7b315172-aca9-4c26-9164-4ce115b59a79	288F57571CA6A941050303A86E6E99AE	01	2025-10-02 03:15:20.779396-04
ACCESS_20251002161520_00001732	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	b93d3d77-76e4-4246-89bf-1915c00b0d7e	79569E60425ED018ADD71E8A057EDCEF	01	2025-10-02 03:15:20.808822-04
ACCESS_20251002161545_00001733	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	8183168c-36fb-4c59-832d-d33d233eb55b	DAA754030E2C524796BFD74627C141B4	01	2025-10-02 03:15:45.502005-04
ACCESS_20251002161552_00001734	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	2935bb40-9f27-47bc-ade6-60589ac8458a	3B76DFAEB7ABBDFC653830C947A61FC5	01	2025-10-02 03:15:52.126304-04
ACCESS_20251002161612_00001735	system	POST	/api/v1/outgoing/slock/connect	출고 기기연결	10.42.0.1, 10.42.0.170	16de06ba-2c3e-4cdd-bc60-4d2609568995	82E5831D450CD2D489578A943BB5F331	01	2025-10-02 03:16:12.130653-04
ACCESS_20251002161631_00001736	system	POST	/api/v1/outgoing/slock/customerInfo	출고 내려받기	10.42.0.1, 10.42.0.170	7af76eb3-1df1-4c68-ab73-f83d02acecfe	2C52F7E7638E7F8A2D6DB338478514CF	01	2025-10-02 03:16:31.480276-04
ACCESS_20251002161634_00001737	system	POST	/api/v1/outgoing/slock/deviceSetting	출고 자물쇠 Setting	10.42.0.1, 10.42.0.170	754bbf23-4a4a-483c-bfb3-329d3e17e26b	13C242FF2225FDA0E347FC4AE0B6037F	01	2025-10-02 03:16:34.256183-04
ACCESS_20251002161637_00001738	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	b3746dd8-8454-4e37-bb0d-b7510ff34cef	7AF773B6E4D832D242DED83558124252	01	2025-10-02 03:16:37.120363-04
ACCESS_20251002161700_00001739	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	2a40c90e-54f0-468f-a801-e1ecdfc5030c	E9251731ED240F4E60C1A91FC83265A4	01	2025-10-02 03:17:00.68057-04
ACCESS_20251002161705_00001740	system	POST	/api/v1/outgoing/slock/control	출고 자물쇠 제어	10.42.0.1, 10.42.0.170	57be7a18-afe0-48dd-89d9-948c89201ed3	CFBD74266BBD50EA161224A43EA4F34F	01	2025-10-02 03:17:05.407308-04
ACCESS_20251002161709_00001741	system	POST	/api/v1/outgoing/slock/config	출고 부가정보 불러오기	10.42.0.1, 10.42.0.170	7e68ae1b-156b-49b6-b978-79693c7b2b38	2C8BC49282DEB47EF021707DA35A4895	01	2025-10-02 03:17:09.441363-04
ACCESS_20251002161731_00001742	system	POST	/api/v1/outgoing/slock/inspectResult	출고 검수결과 저장	10.42.0.1, 10.42.0.170	1c434dcf-bf22-44d8-bdca-ad0d1ad74554	BD7FB4F2FB692B146B5A6594153E400D	01	2025-10-02 03:17:31.380516-04
ACCESS_20251002161731_00001743	system	GET	/api/v1/outgoing/slock	출고관리 조회	10.42.0.1, 10.42.0.170	1865c105-2787-4805-a08a-115496893488	F520CF9B4351F8E8A4A50DAFFA1D5BFF	01	2025-10-02 03:17:31.408806-04
ACCESS_20251002161915_00001744	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	f0ddbc47-9631-4443-8704-48422e22d797	8CB7FE50EEF9BDC5C7AEB76A52836EA6	01	2025-10-02 03:19:15.752497-04
ACCESS_20251002161927_00001745	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	e2933f08-d7f5-4ddd-b991-7e493e0a2fa6	B12B763CD93A8F14EC83D5D70259CCE7	01	2025-10-02 03:19:27.343144-04
ACCESS_20251002161938_00001746	system	GET	/api/v1/product/status	입/출/반품 관리 - 상태정보 조회	10.42.0.1, 10.42.0.170	3edfb849-7776-4fa9-8e7a-d428c9c57765	1868BC631883036DFABC26D180526DA2	01	2025-10-02 03:19:38.322532-04
ACCESS_20251002162150_00001747	system	PUT	/api/v1/product	입/출/반품 관리 - 제품정보 수정	10.42.0.1, 10.42.0.170	3561898c-9a4c-4756-b1f5-b5b4a7bda1a9	CA61295B830DF38FA1B5989EBE4E8AD3	01	2025-10-02 03:21:50.344616-04
ACCESS_20251002162150_00001748	system	GET	/api/v1/product	입/출/반품 관리 - 조회	10.42.0.1, 10.42.0.170	4540483b-a19d-4f1f-8fa8-58879c6a6a44	25AAFED3F395AB61A6E77EEA341F91B2	01	2025-10-02 03:21:50.377172-04
ACCESS_20251002162154_00001749	system	GET	/api/v1/product/slock	sLock 초기화 - 조회	10.42.0.1, 10.42.0.170	e7900606-38f4-4a83-b239-1ae5155bd17c	906A58FD64EF8BFA372C7D1D8A7C3705	01	2025-10-02 03:21:54.104742-04
ACCESS_20251002162204_00001750	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	c9230037-4cea-4340-9045-532976acd556	D1C3649CE08DDD42A3619E2B3F74C6E5	01	2025-10-02 03:22:04.969661-04
ACCESS_20251002162219_00001751	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	5c0028ec-7322-4685-a03c-c4657de59a1f	6343DEF53C07F61BEB02CCB7F1A2CD2F	01	2025-10-02 03:22:19.35886-04
ACCESS_20251002162223_00001752	system	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1, 10.42.0.170	34c49a92-37b6-42d5-85b7-0f8dc4346900	848B49F1490FCC9E306704B0BB98828C	01	2025-10-02 03:22:23.313792-04
ACCESS_20251002162507_00001753	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	7acbc6e5-993d-457d-bcfd-6b4be041d436	5C2F23A2B441393C9CEFD9334B7830B5	01	2025-10-02 03:25:07.469811-04
ACCESS_20251002162507_00001754	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	85154145-3122-49c9-94aa-556168536350	C024D94232CCB9DD1CCB766B810EA075	01	2025-10-02 03:25:07.474001-04
ACCESS_20251002162514_00001755	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	c2a20fec-9587-4eae-83a7-c101217172bf	88F08A5F0A42BE3900900898DB3FFE8E	01	2025-10-02 03:25:14.494236-04
ACCESS_20251002162523_00001756	system	GET	/api/v1/report/inout	입/출 현황 - 조회	10.42.0.1, 10.42.0.170	b1443c90-8819-49bf-a156-5a255bc1707e	9B693318EE8D75515DADD87A79388CD9	01	2025-10-02 03:25:23.335966-04
ACCESS_20251002162525_00001757	system	GET	/api/v1/report/inout/download/excel	입/출 현황 - 엑셀 다운로드	10.42.0.1, 10.42.0.170	55aad9c9-3825-4820-95ab-1d76cf1518f4	3CB6A9F7124BDF6FA951BA397AA29D19	01	2025-10-02 03:25:25.299667-04
ACCESS_20251003064744_00001758	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	f88de03a-c477-4d0f-a4db-fed8377690ec	4F8BEDE6DF031FFAD5EE25C3560D862B	01	2025-10-02 17:47:44.398973-04
ACCESS_20251003064744_00001759	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	40a15417-ac30-407a-a4df-66e9a9acaf9e	535C8D1DA0909D6A69BF44788B7A9ECD	01	2025-10-02 17:47:44.399471-04
ACCESS_20251003064750_00001760	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	aea4e258-a7af-4503-bc68-ef92d3099812	BDD949339B4E82026CB3DF447D234A01	01	2025-10-02 17:47:50.157676-04
ACCESS_20251003064750_00001761	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	bbe2055f-19e6-44ae-b492-03d232ef006f	84CEFBF454D1408283966C15AD945B70	01	2025-10-02 17:47:50.157929-04
ACCESS_20251003093427_00001762	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	e782465e-2bed-4588-ae12-0bb308d6aa4a	CB2CC7FDC506581A797564CF1CFC2E94	01	2025-10-02 20:34:27.856916-04
ACCESS_20251003093427_00001763	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	028f8ff0-c5dd-40ea-ba9c-c4307e09b748	02878DCD39A73F04D414315144F8529F	01	2025-10-02 20:34:27.857113-04
ACCESS_20251003162951_00001764	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	1f6724d4-a414-43c7-ae82-7b5ef1e38b6b	76BB73D47E8C043A56CB9EA631491C3D	01	2025-10-03 03:29:51.180653-04
ACCESS_20251003162951_00001765	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	947237a4-fa30-42dd-9ee0-e573e4ea79cc	51E6933B8087D610904F7DD42B409426	01	2025-10-03 03:29:51.180655-04
ACCESS_20251003162955_00001766	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	91eb759e-34c0-471e-959b-65feefd76973	7D5F187DBED46D63977DDC228054F967	01	2025-10-03 03:29:55.89346-04
ACCESS_20251003162955_00001767	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	9b8a466e-44b9-42fb-b691-426a7bbabf85	0B3311B04CA419EE1FC690564DD49933	01	2025-10-03 03:29:55.990544-04
ACCESS_20251003162958_00001768	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	25728e05-0d70-4042-9811-06d3b63fecc0	962452794B1BA8926E552AFDAB332E52	01	2025-10-03 03:29:58.703976-04
ACCESS_20251003162959_00001769	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	9a8eec59-98d7-40dd-a775-70226ac494a8	279745CC7F1EE29C3A3B99E199E0DF20	01	2025-10-03 03:29:59.316442-04
ACCESS_20251003163000_00001770	system	GET	/api/v1/ref/lockmodel	락모델 관리 - 조회	10.42.0.1, 10.42.0.170	e5b48f21-9712-49c1-83fb-baeb949c4c11	4010EF635A36FD069CD609A32E4DA680	01	2025-10-03 03:30:00.839205-04
ACCESS_20251003163001_00001771	system	GET	/api/v1/incoming/slock	입고관리 - 조회	10.42.0.1, 10.42.0.170	2fe87c7b-82e5-48bd-bf65-6a15b8b09170	1001AF55F6FD7547502A127ECEAB7DBE	01	2025-10-03 03:30:01.754787-04
ACCESS_20251003165652_00001772	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	fcd1a22a-5467-4033-bfeb-9c1b01b8078f	838CD017EA3BC1D5247DFD9F48BD4F7C	01	2025-10-03 03:56:52.18667-04
ACCESS_20251003165652_00001773	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	2bfa3f49-2760-4649-803d-af4718e8ddd5	EE978D69A66DB2B56EC87BABAE9B2DF5	01	2025-10-03 03:56:52.217434-04
ACCESS_20251003165657_00001774	system	GET	/api/v1/ref/organizations/users	조직 관리 - 조직 사용자 조회	10.42.0.1, 10.42.0.170	c708a82a-ed35-4be7-998a-61d50b11e63b	F511F504B7B348AF2F7CEAC5AA6CEAE8	01	2025-10-03 03:56:57.572296-04
ACCESS_20251003165727_00001775	system	POST	/api/v1/ref/organizations	조직 관리 - 등록	10.42.0.1, 10.42.0.170	b7a17072-f4ab-45eb-b2fa-c27302bb5d56	A174DDD8FE9C8F98A3A9A52737CAF43F	01	2025-10-03 03:57:27.861194-04
ACCESS_20251003165727_00001776	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	fc0e6694-859c-4c99-a4f9-b4ccfac23fe1	E0ACEB074C60943EDCBE0A24E2FAFBFF	01	2025-10-03 03:57:27.89263-04
ACCESS_20251003165727_00001777	system	GET	/api/v1/ref/organizations	조직 관리 - 조회	10.42.0.1, 10.42.0.170	7d4ad304-fc80-407f-964e-1a1383f2b33d	4C3591BD811D50A6A375A75C9C3AF8CA	01	2025-10-03 03:57:27.919696-04
ACCESS_20251003170449_00001778	system	GET	/api/v1/home/dashboard/notices	대시보드 - 공지사항 조회	10.42.0.1, 10.42.0.170	be254b0f-4a59-4db6-94c0-6a939076a872	1B4A5175D66D63236F8FDB5B7DCDD07F	01	2025-10-03 04:04:49.041496-04
ACCESS_20251003170449_00001779	system	GET	/api/v1/home/dashboard/products	대시보드 - 입/출고 현황 조회	10.42.0.1, 10.42.0.170	d555bd9a-2f45-4280-b003-c703989be43e	4B9698590ACD9DEA3D0C6CD02105FC99	01	2025-10-03 04:04:49.055036-04
\.


--
-- Data for Name: common_code_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.common_code_mgmt (code_type, code1, code2, code3, desc1, desc2, desc3, "order", is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
QUALITY_STATUS	***	***	***	품질상태	\N	\N	0	t	2025-01-17 13:15:02.276-05	system	\N	\N
QUALITY_STATUS	1	***	***	정상	\N	\N	1	t	2025-01-17 13:15:02.276-05	system	\N	\N
QUALITY_STATUS	2	***	***	결함	\N	\N	2	t	2025-01-17 13:15:02.276-05	system	\N	\N
QUALITY_STATUS	3	***	***	수리필요	\N	\N	3	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	***	***	***	택배사	\N	\N	0	t	2025-01-17 13:15:02.276-05	system	\N	\N
COLOR	***	***	***	스마트락 색상	\N	\N	0	t	2025-01-06 13:14:12.077-05	system	\N	\N
COLOR	R	***	***	적색	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
COLOR	Y	***	***	노란색	\N	\N	2	t	2025-01-06 13:14:12.077-05	system	\N	\N
COLOR	G	***	***	녹색	\N	\N	3	t	2025-01-06 13:14:12.077-05	system	\N	\N
COLOR	B	***	***	청색	\N	\N	4	t	2025-01-06 13:14:12.077-05	system	\N	\N
COLOR	K	***	***	흑색	\N	\N	5	t	2025-01-06 13:15:02.276-05	system	\N	\N
COLOR	O	***	***	오렌지색	\N	\N	6	t	2025-01-06 13:15:03.245-05	system	\N	\N
COLOR	P	***	***	보라색	\N	\N	7	t	2025-01-10 13:21:33.729-05	system	\N	\N
COLOR	W	***	***	흰색	\N	\N	8	t	2025-01-10 13:21:33.729-05	system	\N	\N
COLOR	S	***	***	은색	\N	\N	9	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_AUTH	ROLE_SYSTEM	***	***	시스템	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_01	***	***	***	공지사항 구분	\N	\N	0	t	2025-01-10 13:21:33.729-05	system	\N	\N
ALARM_01	1	***	***	콘솔	\N	\N	1	t	2025-01-10 13:21:33.729-05	system	\N	\N
ALARM_01	3	***	***	서버	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_01	4	***	***	DB	\N	\N	4	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_AUTH	***	***	***	사용자 유형	\N	\N	0	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_AUTH	ROLE_ADMIN	***	***	관리자	\N	\N	2	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_AUTH	ROLE_USER	***	***	사용자	\N	\N	1	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	***	***	***	자격증코드	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	1	***	***	기계안전기술사	\N	\N	1	t	2025-01-06 13:15:03.245-05	system	\N	\N
USER_CERTI	2	***	***	가스기사	\N	\N	2	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	3	***	***	가스산업기사	\N	\N	3	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	4	***	***	건설안전기사	\N	\N	4	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	5	***	***	건설안전기술사	\N	\N	5	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_CERTI	6	***	***	건설안전산업기사	\N	\N	6	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	7	***	***	산업안전기사	\N	\N	7	t	2025-01-06 13:15:03.245-05	system	\N	\N
USER_CERTI	8	***	***	산업기계설비기술사	\N	\N	8	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	9	***	***	설비보전기사	\N	\N	9	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_CERTI	10	***	***	위험물산업기사	\N	\N	10	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_CERTI	11	***	***	정보처리기사	\N	\N	11	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	12	***	***	정보처리산업기사	\N	\N	12	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	13	***	***	정보관리기술사	\N	\N	13	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	14	***	***	전기기사	\N	\N	14	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_CERTI	15	***	***	전기기능장	\N	\N	15	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_01	2	***	***	모바일앱	\N	\N	2	t	2025-01-06 13:14:12.077-05	system	\N	\N
ALARM_01	5	***	***	공통	\N	\N	5	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_02	***	***	***	공지사항 유형	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_02	1	***	***	시스템	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
LANGUAGE	***	***	***	사용언어	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
LANGUAGE	KO	***	***	한국어	\N	\N	1	t	2025-01-06 13:15:03.245-05	system	\N	\N
LANGUAGE	EN	***	***	영어	\N	\N	2	t	2025-01-10 13:21:33.729-05	system	\N	\N
LANGUAGE	JA	***	***	일본어	\N	\N	3	t	2025-01-10 13:21:33.729-05	system	\N	\N
LANGUAGE	ZH	***	***	중국어	\N	\N	4	t	2025-01-10 13:21:33.729-05	system	\N	\N
LANGUAGE	VI	***	***	베트남어	\N	\N	5	t	2025-01-06 13:14:12.077-05	system	\N	\N
LOCK_TYPE	***	***	***	락구분	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	3	***	***	전무이사	\N	\N	3	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_POSITION	5	***	***	이사대우	\N	\N	5	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	1	***	***	대표이사	\N	\N	1	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_POSITION	4	***	***	상무이사	\N	\N	4	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	9	***	***	과장	\N	\N	9	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	8	***	***	차장	\N	\N	8	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	11	***	***	사원	\N	\N	11	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_POSITION	***	***	***	직위	\N	\N	0	t	2025-01-06 13:15:03.245-05	system	\N	\N
USER_POSITION	6	***	***	수석부장	\N	\N	6	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_02	2	***	***	네트워크	\N	\N	2	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_02	3	***	***	소프트웨어	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_03	***	***	***	공지사항 중요도	\N	\N	0	t	2025-01-06 13:14:12.077-05	system	\N	\N
ALARM_03	0001	***	***	상	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
ALARM_03	0002	***	***	중	\N	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
ALARM_03	0003	***	***	하	\N	\N	3	t	2025-01-10 13:21:33.729-05	system	\N	\N
SHIPPING_COMPANY	1	***	***	우체국택배	\N	\N	1	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	2	***	***	CJ대한통운	\N	\N	2	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	3	***	***	로젠택배	\N	\N	3	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	4	***	***	한진택배	\N	\N	4	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	5	***	***	롯데택배	\N	\N	5	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	6	***	***	드림택배	\N	\N	6	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	7	***	***	대신택배	\N	\N	7	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	8	***	***	일양로지스	\N	\N	8	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	9	***	***	경동택배	\N	\N	9	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	10	***	***	천일택배	\N	\N	10	t	2025-01-17 13:15:02.276-05	system	\N	\N
USER_POSITION	10	***	***	대리	\N	\N	10	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_POSITION	2	***	***	부사장	\N	\N	2	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_POSITION	7	***	***	부장	\N	\N	7	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	***	***	***	직책	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	2	***	***	CFO	\N	\N	2	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	3	***	***	CTO	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	4	***	***	CMO	\N	\N	4	t	2025-01-06 13:15:03.245-05	system	\N	\N
USER_ROLE	5	***	***	CSO	\N	\N	5	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_ROLE	6	***	***	본부장	\N	\N	6	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	7	***	***	사업부장	\N	\N	7	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	8	***	***	공장장	\N	\N	8	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	9	***	***	부공장장	\N	\N	9	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_ROLE	10	***	***	리더	\N	\N	10	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	11	***	***	부리더	\N	\N	11	t	2025-01-06 13:14:12.077-05	system	\N	\N
USER_ROLE	12	***	***	팀장	\N	\N	12	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	13	***	***	안전파트장	\N	\N	13	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_ROLE	14	***	***	전기파트장	\N	\N	14	t	2025-01-06 13:15:02.276-05	system	\N	\N
USER_ROLE	15	***	***	운전파트장	\N	\N	15	t	2025-01-10 13:21:33.729-05	system	\N	\N
USER_ROLE	16	***	***	계장파트장	\N	\N	16	t	2025-01-06 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	11	***	***	건영택배	\N	\N	11	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	12	***	***	국제정보통신	\N	\N	12	t	2025-01-17 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	***	***	***	입출고상태정보	\N	\N	0	t	2025-01-06 13:14:12.077-05	system	\N	\N
IN_OUTBOUND_STATUS	1	***	***	입고	\N	\N	1	t	2025-01-10 13:21:33.729-05	system	\N	\N
IN_OUTBOUND_STATUS	2	***	***	출고대기	\N	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
IN_OUTBOUND_STATUS	9	***	***	폐기	\N	\N	9	t	2025-01-06 13:14:12.077-05	system	\N	\N
SHIPPING_COMPANY	13	***	***	GTX택배	\N	\N	13	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	14	***	***	DHL	\N	\N	14	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	15	***	***	EMS	\N	\N	15	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	16	***	***	EMS 프리미엄	\N	\N	16	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	17	***	***	FEDEX	\N	\N	17	t	2025-01-17 13:15:02.276-05	system	\N	\N
SHIPPING_COMPANY	18	***	***	UPS	\N	\N	18	t	2025-01-17 13:15:02.276-05	system	\N	\N
USER_ROLE	1	***	***	CEO	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
SHIPPING_STATUS	***	***	***	배송상태	\N	\N	0	t	2025-01-06 13:15:02.276-05	system	\N	\N
SHIPPING_STATUS	1	***	***	발송대기	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
SHIPPING_STATUS	2	***	***	배송중	\N	\N	2	t	2025-01-06 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	8	***	***	반입 (일반)	\N	\N	8	t	2025-01-10 13:21:33.729-05	system	\N	\N
SHIPPING_STATUS	3	***	***	배송완료	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	7	***	***	반입 (불량)	\N	\N	7	t	2025-01-10 13:21:33.729-05	system	\N	\N
IN_OUTBOUND_STATUS	6	***	***	반입 (데모)	\N	\N	6	t	2025-01-06 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	3	***	***	출고 (납품)	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	5	***	***	출고 (데모)	\N	\N	5	t	2025-01-06 13:15:02.276-05	system	\N	\N
IN_OUTBOUND_STATUS	4	***	***	출고 (증정)	\N	\N	4	t	2025-01-06 13:15:02.276-05	system	\N	\N
ORGTYPE	***	***	***	조직구분	\N	\N	0	t	2025-01-06 13:14:12.077-05	system	\N	\N
ORGTYPE	0002	***	***	파트너	\N	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
ORGTYPE	0001	***	***	직영	\N	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
ORGTYPE	0003	***	***	고객	\N	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
ORG_TYPE	0001	***	***	직영	임시데이터(삭제예정)	\N	1	t	2025-01-06 13:15:02.276-05	system	\N	\N
ORG_TYPE	0002	***	***	파트너	임시데이터(삭제예정)	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
ORG_TYPE	***	***	***	조직구분	임시데이터(삭제예정)	\N	0	t	2025-01-06 13:14:12.077-05	system	\N	\N
ORG_TYPE	0003	***	***	고객	임시데이터(삭제예정)	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
SEQUENCE_TYPE	0001	***	***	부서	임시데이터	\N	1	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	***	***	***	시퀀스 구분	임시데이터	\N	0	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0005	***	***	CAM_GL	임시데이터	\N	5	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0009	***	***	ECD_AUTO	임시데이터	\N	9	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0007	***	***	ECD_MT	임시데이터	\N	7	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0006	***	***	ECD_PT	임시데이터	\N	6	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0008	***	***	ECD_TAG	임시데이터	\N	8	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0002	***	***	P_LOCK_AC	임시데이터	\N	2	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0004	***	***	P_LOCK_ML	임시데이터	\N	4	t	2025-01-17 04:50:35.535-05	system	\N	\N
SEQUENCE_TYPE	0003	***	***	P_LOCK_MA	임시데이터	\N	3	t	2025-01-17 04:50:35.535-05	system	\N	\N
AGENT_TYPE	***	***	***	접속 유형	\N	\N	0	t	2025-07-08 08:01:25.742337-04	system	\N	\N
AGENT_TYPE	01	***	***	PC	\N	\N	1	t	2025-07-08 08:02:06.192402-04	system	\N	\N
AGENT_TYPE	02	***	***	모바일	\N	\N	2	t	2025-07-08 08:02:18.305291-04	system	\N	\N
ALARM_03	0004	***	***	안중요	\N	\N	4	t	2025-07-09 21:39:24.443919-04	system	\N	\N
USER_ROLE	17	***	***	팀원	\N	\N	17	t	2025-09-16 01:25:42.812803-04	system	\N	\N
LOCK_TYPE	EX_03	0008	***	ECD_TAG	\N	\N	7	t	2025-01-06 13:15:02.276-05	system	\N	\N
LOCK_TYPE	EX_04	0009	***	ECD_AUTO	\N	\N	8	t	2025-01-06 13:15:02.276-05	system	\N	\N
LOCK_TYPE	EX_02	0007	***	ECD_MT	\N	\N	6	t	2025-01-06 13:15:02.276-05	system	\N	\N
LOCK_TYPE	EX_01	0006	***	ECD_PT	\N	\N	5	t	2025-01-06 13:15:02.276-05	system	\N	\N
LOCK_TYPE	CD_01	0005	***	CAM_GL	\N	\N	4	t	2025-01-06 13:15:02.276-05	system	\N	\N
LOCK_TYPE	PD_02	0003	***	P_LOCK_MA	\N	\N	2	t	2025-01-06 13:15:03.245-05	system	\N	\N
LOCK_TYPE	PD_01	0002	***	P_LOCK_AC	\N	\N	1	t	2025-01-06 13:15:03.245-05	system	\N	\N
LOCK_TYPE	PD_03	0004	***	P_LOCK_ML	\N	\N	3	t	2025-01-06 13:15:02.276-05	system	\N	\N
\.


--
-- Data for Name: communication_logs; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.communication_logs (log_id, df_serial_number, command_type, command_detail, request_time, response_code, response_detail, response_time, processing_time, connection_status, signal_strength, battery_level, created_at) FROM stdin;
1	pdub2025000000	O	40524544005354323530393137303133394F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF3E8D0d0a0000000000	2025-09-16 12:39:10.368-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:39:12.268-04	1	\N	\N	\N	2025-09-16 12:39:12.270735-04
2	pdub2025000000	C	4052454400535432353039313730313339433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF0D410d0a0000000000	2025-09-16 12:39:18.857-04	E00	40524544000843414530303020FA0D0A	2025-09-16 12:39:20.656-04	1	\N	\N	\N	2025-09-16 12:39:20.657311-04
3	ADUL2025000002	O	40524544005354323530393137303133394F304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFB9480d0a0000000000	2025-09-16 12:39:55.878-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:39:57.681-04	1	\N	\N	\N	2025-09-16 12:39:57.682602-04
4	ADUL2025000002	C	405245440053543235303931373031343043304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF29D50d0a0000000000	2025-09-16 12:40:03.726-04	E00	40524544000843414530303020FA0D0A	2025-09-16 12:40:05.538-04	1	\N	\N	\N	2025-09-16 12:40:05.540314-04
5	ADUL2025000002	O	40524544005354323530393137303134304F304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF1A190d0a0000000000	2025-09-16 12:40:30.191-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:40:31.958-04	1	\N	\N	\N	2025-09-16 12:40:31.959957-04
6	ADUL2025000002	C	405245440053543235303931373031343043304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF29D50d0a0000000000	2025-09-16 12:40:42.958-04	E20	405245440008434E45323030E10F0D0A	2025-09-16 12:40:44.739-04	1	\N	\N	\N	2025-09-16 12:40:44.740527-04
7	ADUL2025000002	O	40524544005354323530393137303134314F304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF26DD0d0a0000000000	2025-09-16 12:40:59.893-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:41:01.703-04	1	\N	\N	\N	2025-09-16 12:41:01.704463-04
8	ADUL2025000002	O	40524544005354323530393137303134314F304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF26DD0d0a0000000000	2025-09-16 12:41:21.734-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:41:23.544-04	1	\N	\N	\N	2025-09-16 12:41:23.545661-04
9	ADUL2025000002	C	405245440053543235303931373031343343304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF6C990d0a0000000000	2025-09-16 12:43:41.785-04	E00	40524544000843414530303020FA0D0A	2025-09-16 12:43:43.57-04	1	\N	\N	\N	2025-09-16 12:43:43.571502-04
10	ADUL2025000002	O	40524544005354323530393137303134364F304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF90810d0a0000000000	2025-09-16 12:46:04.158-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-16 12:46:05.951-04	1	\N	\N	\N	2025-09-16 12:46:05.953408-04
11	ADUL2025000002	C	405245440053543235303931373031343643304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFA34D0d0a0000000000	2025-09-16 12:46:34.538-04	E00	40524544000843414530303020FA0D0A	2025-09-16 12:46:36.307-04	1	\N	\N	\N	2025-09-16 12:46:36.308614-04
12	ADUL2025000002	U	405245440053543235303931373031343655304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF3FBA0d0a0000000000	2025-09-16 12:46:47.743-04	E00	405245440008554145303030D6F80D0A	2025-09-16 12:46:49.524-04	1	\N	\N	\N	2025-09-16 12:46:49.52605-04
13	ADUL2025000002	C	405245440053543235303931373031343743304144554C323032353030303030322C3323383D3777566853634D33614270372C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F890d0a0000000000	2025-09-16 12:47:05.357-04	E00	40524544000843414530303020FA0D0A	2025-09-16 12:47:07.134-04	1	\N	\N	\N	2025-09-16 12:47:07.135414-04
14	pdub2025000000	O	40524544005354323530393138313235304F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFB4960d0a0000000000	2025-09-17 23:49:25.178-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-17 23:49:26.912-04	1	\N	\N	\N	2025-09-17 23:49:26.913311-04
15	pdub2025000000	C	4052454400535432353039313831323530433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF875A0d0a0000000000	2025-09-17 23:49:35.75-04	E00	40524544000843414530303020FA0D0A	2025-09-17 23:49:37.468-04	1	\N	\N	\N	2025-09-17 23:49:37.469919-04
16	ADUL2025000003	O	40524544005354323530393138313235314F304144554C323032353030303030332C3371455079365A55427A7476352525422C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0950d0a0000000000	2025-09-17 23:50:39.856-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-17 23:50:41.57-04	1	\N	\N	\N	2025-09-17 23:50:41.571843-04
17	ADUL2025000003	C	405245440053543235303931383132353143304144554C323032353030303030332C3371455079365A55427A7476352525422C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3590d0a0000000000	2025-09-17 23:50:46.26-04	E00	40524544000843414530303020FA0D0A	2025-09-17 23:50:47.994-04	1	\N	\N	\N	2025-09-17 23:50:47.995576-04
18	ADUL2025000003	O	40524544005354323530393138313330304F304144554C323032353030303030332C3371455079365A55427A7476352525422C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0370d0a0000000000	2025-09-18 00:00:12.529-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 00:00:14.281-04	1	\N	\N	\N	2025-09-18 00:00:14.282114-04
19	ADUL2025000003	C	405245440053543235303931383133303143304144554C323032353030303030332C3371455079365A55427A7476352525422C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F0d0a0000000000	2025-09-18 00:00:19.473-04	E00	40524544000843414530303020FA0D0A	2025-09-18 00:00:21.191-04	1	\N	\N	\N	2025-09-18 00:00:21.192654-04
20	ADUL2025000004	O	40524544005354323530393138313330314F304144554C323032353030303030342C5A7671333332614B487350552A2B2B4B2C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFA14C0d0a0000000000	2025-09-18 00:00:42.851-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 00:00:44.536-04	1	\N	\N	\N	2025-09-18 00:00:44.537614-04
21	ADUL2025000004	C	405245440053543235303931383133303143304144554C323032353030303030342C5A7671333332614B487350552A2B2B4B2C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF92800d0a0000000000	2025-09-18 00:00:51.887-04	E00	40524544000843414530303020FA0D0A	2025-09-18 00:00:53.611-04	1	\N	\N	\N	2025-09-18 00:00:53.612585-04
22	pdub2025000000	O	40524544005354323530393138313535304F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF67E40d0a0000000000	2025-09-18 02:50:02.159-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 02:50:04-04	1	\N	\N	\N	2025-09-18 02:50:04.00095-04
23	pdub2025000000	C	4052454400535432353039313831353530433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF54280d0a0000000000	2025-09-18 02:50:06.794-04	E00	40524544000843414530303020FA0D0A	2025-09-18 02:50:08.586-04	1	\N	\N	\N	2025-09-18 02:50:08.58753-04
24	pdub2025000000	O	40524544005354323530393138313535314F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF5B200d0a0000000000	2025-09-18 02:51:47.863-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 02:51:49.687-04	1	\N	\N	\N	2025-09-18 02:51:49.688641-04
25	ADUL2025000005	C	405245440053543235303931383135353343304144554C323032353030303030352C4C732326366559332A25416B793943612C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF40830d0a0000000000	2025-09-18 02:53:35.038-04	E00	40524544000843414530303020FA0D0A	2025-09-18 02:53:36.83-04	1	\N	\N	\N	2025-09-18 02:53:36.830913-04
26	ADUL2025000005	O	40524544005354323530393138313535334F304144554C323032353030303030352C4C732326366559332A25416B793943612C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF734F0d0a0000000000	2025-09-18 02:53:40.86-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 02:53:42.695-04	1	\N	\N	\N	2025-09-18 02:53:42.697003-04
27	ADUL2025000005	C	405245440053543235303931383135353543304144554C323032353030303030352C4C732326366559332A25416B793943612C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFCA1B0d0a0000000000	2025-09-18 02:55:04.214-04	E00	40524544000843414530303020FA0D0A	2025-09-18 02:55:06.041-04	1	\N	\N	\N	2025-09-18 02:55:06.042018-04
28	ADUL2025000005	O	40524544005354323530393138313535394F304144554C323032353030303030352C4C732326366559332A25416B793943612C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF17970d0a0000000000	2025-09-18 02:59:27.173-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 02:59:28.979-04	1	\N	\N	\N	2025-09-18 02:59:28.980681-04
29	ADUL2025000005	C	405245440053543235303931383135353943304144554C323032353030303030352C4C732326366559332A25416B793943612C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF245B0d0a0000000000	2025-09-18 02:59:36.111-04	E00	40524544000843414530303020FA0D0A	2025-09-18 02:59:37.945-04	1	\N	\N	\N	2025-09-18 02:59:37.945867-04
30	ADUL2025000005	O	40524544005354323530393138313535394F304144554C323032353030303030352C4C732326366559332A25416B793943612C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF17970d0a0000000000	2025-09-18 02:59:44.748-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-18 02:59:46.525-04	1	\N	\N	\N	2025-09-18 02:59:46.526529-04
31	ADUL2025000005	C	405245440053543235303931383136303043304144554C323032353030303030352C4C732326366559332A25416B793943612C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFD2860d0a0000000000	2025-09-18 03:00:10.783-04	E00	40524544000843414530303020FA0D0A	2025-09-18 03:00:12.552-04	1	\N	\N	\N	2025-09-18 03:00:12.553775-04
32	pdub2025000000	C	4052454400535432353039313831373535433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF795B0d0a0000000000	2025-09-18 04:54:44.092-04	E00	40524544000843414530303020FA0D0A	2025-09-18 04:54:45.83-04	1	\N	\N	\N	2025-09-18 04:54:45.832246-04
33	pdub2025000000	C	4052454400535432353039313931363130433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF97D20d0a0000000000	2025-09-19 03:10:15.283-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:10:17.12-04	1	\N	\N	\N	2025-09-19 03:10:17.121175-04
34	pdub2025000000	C	4052454400535432353039313931363130433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF97D20d0a0000000000	2025-09-19 03:10:24.105-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:10:25.912-04	1	\N	\N	\N	2025-09-19 03:10:25.913472-04
35	ADUL2025000008	O	40524544005354323530393139313631304F304144554C323032353030303030382C796D26714E6C363D5379722D405142332C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF72B40d0a0000000000	2025-09-19 03:10:50.809-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-19 03:10:52.622-04	1	\N	\N	\N	2025-09-19 03:10:52.624052-04
36	ADUL2025000009	O	40524544005354323530393139313631314F304144554C323032353030303030392C2A7762374B3854356834576E24256B6B2C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFD8020d0a0000000000	2025-09-19 03:11:01.456-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-19 03:11:03.272-04	1	\N	\N	\N	2025-09-19 03:11:03.273722-04
37	ADUL2025000008	C	405245440053543235303931393136313143304144554C323032353030303030382C796D26714E6C363D5379722D405142332C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF7DBC0d0a0000000000	2025-09-19 03:11:11.067-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:11:12.877-04	1	\N	\N	\N	2025-09-19 03:11:12.87811-04
38	ADUL2025000009	C	405245440053543235303931393136313143304144554C323032353030303030392C2A7762374B3854356834576E24256B6B2C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBCE0d0a0000000000	2025-09-19 03:11:14.922-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:11:16.741-04	1	\N	\N	\N	2025-09-19 03:11:16.742663-04
39	ADUL2025000008	O	40524544005354323530393139313631344F304144554C323032353030303030382C796D26714E6C363D5379722D405142332C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF3AD70d0a0000000000	2025-09-19 03:14:19.212-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-19 03:14:21.012-04	1	\N	\N	\N	2025-09-19 03:14:21.013144-04
40	ADUL2025000008	C	405245440053543235303931393136313443304144554C323032353030303030382C796D26714E6C363D5379722D405142332C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF091B0d0a0000000000	2025-09-19 03:14:30.136-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:14:31.947-04	1	\N	\N	\N	2025-09-19 03:14:31.94857-04
41	ADUL2025000009	O	40524544005354323530393139313631344F304144554C323032353030303030392C2A7762374B3854356834576E24256B6B2C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFACA50d0a0000000000	2025-09-19 03:14:36.264-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-19 03:14:38.093-04	1	\N	\N	\N	2025-09-19 03:14:38.095126-04
42	ADUL2025000009	C	405245440053543235303931393136313443304144554C323032353030303030392C2A7762374B3854356834576E24256B6B2C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F690d0a0000000000	2025-09-19 03:14:45.082-04	E00	40524544000843414530303020FA0D0A	2025-09-19 03:14:46.903-04	1	\N	\N	\N	2025-09-19 03:14:46.904052-04
43	ADUL2025000010	O	40524544005354323530393233313732374F304144554C323032353030303031302C7459762D3D53773847245A47542632632C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF68170d0a0000000000	2025-09-23 04:27:27.673-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-23 04:27:29.379-04	1	\N	\N	\N	2025-09-23 04:27:29.380305-04
44	ADUL2025000010	C	405245440053543235303932333137323843304144554C323032353030303031302C7459762D3D53773847245A47542632632C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF4BA40d0a0000000000	2025-09-23 04:28:02.528-04	E00	40524544000843414530303020FA0D0A	2025-09-23 04:28:04.238-04	1	\N	\N	\N	2025-09-23 04:28:04.239645-04
45	ADUL2025000011	O	40524544005354323530393233313732384F304144554C323032353030303031312C25443D73626C3374742538714E3662352C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF2EFD0d0a0000000000	2025-09-23 04:28:37.447-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-23 04:28:39.154-04	1	\N	\N	\N	2025-09-23 04:28:39.155155-04
46	ADUL2025000011	C	405245440053543235303932333137323943304144554C323032353030303031312C25443D73626C3374742538714E3662352C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF21F50d0a0000000000	2025-09-23 04:29:11.548-04	E00	40524544000843414530303020FA0D0A	2025-09-23 04:29:13.249-04	1	\N	\N	\N	2025-09-23 04:29:13.250532-04
47	ADUL2025000012	O	40524544005354323530393233313733354F304144554C323032353030303031322C265233324252786E354D746338432D582C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8910d0a0000000000	2025-09-23 04:35:15.306-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-23 04:35:17.044-04	1	\N	\N	\N	2025-09-23 04:35:17.045997-04
48	ADUL2025000012	C	405245440053543235303932333137333543304144554C323032353030303031322C265233324252786E354D746338432D582C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFFCB5D0d0a0000000000	2025-09-23 04:35:38.553-04	E00	40524544000843414530303020FA0D0A	2025-09-23 04:35:40.251-04	1	\N	\N	\N	2025-09-23 04:35:40.252161-04
49	ADUL2025000013	O	40524544005354323530393233313733354F304144554C323032353030303031332C2365376C2A4D634C732D77743433353D2C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF79A80d0a0000000000	2025-09-23 04:35:48.771-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-23 04:35:50.5-04	1	\N	\N	\N	2025-09-23 04:35:50.501382-04
50	ADUL2025000013	C	405245440053543235303932333137333543304144554C323032353030303031332C2365376C2A4D634C732D77743433353D2C636F6D70616E795F303030303030303068636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF4A640d0a0000000000	2025-09-23 04:35:52.132-04	E00	40524544000843414530303020FA0D0A	2025-09-23 04:35:53.855-04	1	\N	\N	\N	2025-09-23 04:35:53.85622-04
51	ADUL2025000011	O	40524544005354323530393233313733374F304144554C323032353030303031312C25443D73626C3374742538714E3662352C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF2F440d0a0000000000	2025-09-23 04:37:13.539-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-23 04:37:15.263-04	1	\N	\N	\N	2025-09-23 04:37:15.264846-04
52	ADUL2025000011	C	405245440053543235303932333137333743304144554C323032353030303031312C25443D73626C3374742538714E3662352C3230323530333936333530303932343668636B77616BFFFFFFFFFFFFFFFFFFFFFFFFFFFF1C880d0a0000000000	2025-09-23 04:37:16.853-04	E00	40524544000843414530303020FA0D0A	2025-09-23 04:37:18.561-04	1	\N	\N	\N	2025-09-23 04:37:18.56219-04
53	pdub2025000000	C	4052454400535432353039323631363335433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFED630d0a0000000000	2025-09-26 03:35:28.74-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:35:31.356-04	2	\N	\N	\N	2025-09-26 03:35:31.357628-04
54	pdub2025000000	O	40524544005354323530393236313633354F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFDEAF0d0a0000000000	2025-09-26 03:35:34.386-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:35:36.158-04	1	\N	\N	\N	2025-09-26 03:35:36.158974-04
55	pdub2025000000	C	4052454400535432353039323631363335433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFED630d0a0000000000	2025-09-26 03:35:39.226-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:35:40.965-04	1	\N	\N	\N	2025-09-26 03:35:40.966164-04
56	pdub2025000000	U	4052454400535432353039323631363335553070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF71940d0a0000000000	2025-09-26 03:35:43.058-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:35:44.824-04	1	\N	\N	\N	2025-09-26 03:35:44.825703-04
57	ADUL2025000014	C	405245440053543235303932363136333843304144554C323032353030303031342C717A356A4270382B26546E53477065722C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF01220d0a0000000000	2025-09-26 03:38:00.524-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:38:02.322-04	1	\N	\N	\N	2025-09-26 03:38:02.323528-04
58	ADUL2025000014	O	40524544005354323530393236313633384F304144554C323032353030303031342C717A356A4270382B26546E53477065722C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF32EE0d0a0000000000	2025-09-26 03:38:04.613-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:38:06.362-04	1	\N	\N	\N	2025-09-26 03:38:06.363471-04
59	ADUL2025000014	C	405245440053543235303932363136333843304144554C323032353030303031342C717A356A4270382B26546E53477065722C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF01220d0a0000000000	2025-09-26 03:38:09.606-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:38:11.398-04	1	\N	\N	\N	2025-09-26 03:38:11.399264-04
60	ADUL2025000014	U	405245440053543235303932363136333855304144554C323032353030303031342C717A356A4270382B26546E53477065722C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF9DD50d0a0000000000	2025-09-26 03:38:13.212-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:38:15.029-04	1	\N	\N	\N	2025-09-26 03:38:15.0308-04
61	ADUL2025000014	C	405245440053543235303932363136343043304144554C323032353030303031342C717A356A4270382B26546E53477065722C3230323530333936333530303932343673797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF1C4C0d0a0000000000	2025-09-26 03:40:29.941-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:40:31.711-04	1	\N	\N	\N	2025-09-26 03:40:31.712159-04
62	ADUL2025000014	U	405245440053543235303932363136343055304144554C323032353030303031342C717A356A4270382B26546E53477065722C3230323530333936333530303932343673797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF80BB0d0a0000000000	2025-09-26 03:40:34.181-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:40:35.946-04	1	\N	\N	\N	2025-09-26 03:40:35.947858-04
63	ADUL2025000014	C	405245440053543235303932363136343043304144554C323032353030303031342C717A356A4270382B26546E53477065722C3230323530333936333530303932343673797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF1C4C0d0a0000000000	2025-09-26 03:40:45.858-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:40:47.661-04	1	\N	\N	\N	2025-09-26 03:40:47.662472-04
64	ADUL2025000014	O	40524544005354323530393236313634304F304144554C323032353030303031342C717A356A4270382B26546E53477065722C3230323530333936333530303932343673797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF2F800d0a0000000000	2025-09-26 03:40:49.396-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:40:51.177-04	1	\N	\N	\N	2025-09-26 03:40:51.178671-04
65	pdub2025000000	C	4052454400535432353039323631363530433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF883C0d0a0000000000	2025-09-26 03:50:06.323-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:50:08.041-04	1	\N	\N	\N	2025-09-26 03:50:08.041932-04
66	pdub2025000000	O	40524544005354323530393236313635304F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBF00d0a0000000000	2025-09-26 03:50:10.218-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:50:11.969-04	1	\N	\N	\N	2025-09-26 03:50:11.970743-04
67	pdub2025000000	C	4052454400535432353039323631363530433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF883C0d0a0000000000	2025-09-26 03:50:13.566-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:50:15.342-04	1	\N	\N	\N	2025-09-26 03:50:15.343689-04
68	pdub2025000000	U	4052454400535432353039323631363530553070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF14CB0d0a0000000000	2025-09-26 03:50:17.27-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:50:19.057-04	1	\N	\N	\N	2025-09-26 03:50:19.058213-04
69	ADUL2025000015	C	405245440053543235303932363136353043304144554C323032353030303031352C625846364A786E2A744C73503D7578322C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF49F00d0a0000000000	2025-09-26 03:50:34.112-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:50:35.863-04	1	\N	\N	\N	2025-09-26 03:50:35.864305-04
70	ADUL2025000015	O	40524544005354323530393236313635304F304144554C323032353030303031352C625846364A786E2A744C73503D7578322C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF7A3C0d0a0000000000	2025-09-26 03:50:38.688-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:50:40.438-04	1	\N	\N	\N	2025-09-26 03:50:40.439163-04
71	ADUL2025000015	C	405245440053543235303932363136353043304144554C323032353030303031352C625846364A786E2A744C73503D7578322C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF49F00d0a0000000000	2025-09-26 03:50:42.016-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:50:43.801-04	1	\N	\N	\N	2025-09-26 03:50:43.803097-04
72	ADUL2025000015	U	405245440053543235303932363136353055304144554C323032353030303031352C625846364A786E2A744C73503D7578322C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFD5070d0a0000000000	2025-09-26 03:50:45.426-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:50:47.163-04	1	\N	\N	\N	2025-09-26 03:50:47.164094-04
73	ADUL2025000015	C	405245440053543235303932363136353143304144554C323032353030303031352C625846364A786E2A744C73503D7578322C3230323530333736313537313731343773797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0130d0a0000000000	2025-09-26 03:51:54.728-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:51:56.487-04	1	\N	\N	\N	2025-09-26 03:51:56.48801-04
74	ADUL2025000015	O	40524544005354323530393236313635324F304144554C323032353030303031352C625846364A786E2A744C73503D7578322C3230323530333736313537313731343773797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF86930d0a0000000000	2025-09-26 03:51:58.565-04	E00	4052454400084F4145303030ECFA0D0A	2025-09-26 03:52:00.351-04	1	\N	\N	\N	2025-09-26 03:52:00.352717-04
75	ADUL2025000015	C	405245440053543235303932363136353243304144554C323032353030303031352C625846364A786E2A744C73503D7578322C3230323530333736313537313731343773797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFB55F0d0a0000000000	2025-09-26 03:52:02.193-04	E00	40524544000843414530303020FA0D0A	2025-09-26 03:52:03.929-04	1	\N	\N	\N	2025-09-26 03:52:03.930555-04
76	ADUL2025000015	U	405245440053543235303932363136353255304144554C323032353030303031352C625846364A786E2A744C73503D7578322C3230323530333736313537313731343773797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF29A80d0a0000000000	2025-09-26 03:52:06.627-04	E00	405245440008554145303030D6F80D0A	2025-09-26 03:52:08.389-04	1	\N	\N	\N	2025-09-26 03:52:08.390873-04
77	pdub2025000000	C	4052454400535432353130303231363033433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF197D0d0a0000000000	2025-10-02 03:03:37.643-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:03:39.431-04	1	\N	\N	\N	2025-10-02 03:03:39.433395-04
78	pdub2025000000	O	40524544005354323531303032313630334F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF2AB10d0a0000000000	2025-10-02 03:03:41.856-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:03:43.64-04	1	\N	\N	\N	2025-10-02 03:03:43.642312-04
79	pdub2025000000	C	4052454400535432353130303231363033433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF197D0d0a0000000000	2025-10-02 03:03:46.576-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:03:48.357-04	1	\N	\N	\N	2025-10-02 03:03:48.358806-04
80	ADUL2025000016	O	40524544005354323531303032313630344F304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF7B990d0a0000000000	2025-10-02 03:04:23.816-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:04:25.655-04	1	\N	\N	\N	2025-10-02 03:04:25.657147-04
81	ADUL2025000016	C	405245440053543235313030323136303443304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF48550d0a0000000000	2025-10-02 03:04:27.959-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:04:29.793-04	1	\N	\N	\N	2025-10-02 03:04:29.794794-04
82	ADUL2025000016	O	40524544005354323531303032313630344F304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF7B990d0a0000000000	2025-10-02 03:04:51.389-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:04:53.232-04	1	\N	\N	\N	2025-10-02 03:04:53.23416-04
83	ADUL2025000016	C	405245440053543235313030323136303443304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF48550d0a0000000000	2025-10-02 03:04:58.89-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:05:00.732-04	1	\N	\N	\N	2025-10-02 03:05:00.733531-04
84	ADUL2025000016	O	40524544005354323531303032313630354F304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF475D0d0a0000000000	2025-10-02 03:05:03.255-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:05:05.049-04	1	\N	\N	\N	2025-10-02 03:05:05.050955-04
85	ADUL2025000016	C	405245440053543235313030323136303543304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF74910d0a0000000000	2025-10-02 03:05:25.722-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:05:27.591-04	1	\N	\N	\N	2025-10-02 03:05:27.593096-04
86	ADUL2025000016	U	405245440053543235313030323136303555304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8660d0a0000000000	2025-10-02 03:05:30.288-04	E00	405245440008554145303030D6F80D0A	2025-10-02 03:05:32.112-04	1	\N	\N	\N	2025-10-02 03:05:32.113936-04
87	ADUL2025000016	C	405245440053543235313030323136303543304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF74910d0a0000000000	2025-10-02 03:05:55.23-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:05:57.029-04	1	\N	\N	\N	2025-10-02 03:05:57.031007-04
88	pdub2025000000	C	4052454400535432353130303231363037433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFEA6D0d0a0000000000	2025-10-02 03:07:42.197-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:07:44.001-04	1	\N	\N	\N	2025-10-02 03:07:44.002549-04
89	pdub2025000000	O	40524544005354323531303032313630374F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFD9A10d0a0000000000	2025-10-02 03:07:46.333-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:07:48.146-04	1	\N	\N	\N	2025-10-02 03:07:48.147748-04
90	pdub2025000000	C	4052454400535432353130303231363037433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFEA6D0d0a0000000000	2025-10-02 03:07:51.192-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:07:52.993-04	1	\N	\N	\N	2025-10-02 03:07:52.994897-04
91	ADUL2025000017	O	40524544005354323531303032313630384F304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF32A20d0a0000000000	2025-10-02 03:08:19.264-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:08:21.125-04	1	\N	\N	\N	2025-10-02 03:08:21.127248-04
92	ADUL2025000017	C	405245440053543235313030323136303843304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF016E0d0a0000000000	2025-10-02 03:08:23.28-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:08:25.105-04	1	\N	\N	\N	2025-10-02 03:08:25.10723-04
93	ADUL2025000017	U	405245440053543235313030323136303855304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF9D990d0a0000000000	2025-10-02 03:08:27.269-04	E00	405245440008554145303030D6F80D0A	2025-10-02 03:08:29.04-04	1	\N	\N	\N	2025-10-02 03:08:29.042181-04
94	ADUL2025000017	C	405245440053543235313030323136303843304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF016E0d0a0000000000	2025-10-02 03:08:39.535-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:08:41.33-04	1	\N	\N	\N	2025-10-02 03:08:41.331268-04
95	ADUL2025000017	O	40524544005354323531303032313630394F304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF0E660d0a0000000000	2025-10-02 03:09:04.989-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:09:06.826-04	1	\N	\N	\N	2025-10-02 03:09:06.827707-04
96	ADUL2025000017	C	405245440053543235313030323136303943304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF3DAA0d0a0000000000	2025-10-02 03:09:08.76-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:09:10.596-04	1	\N	\N	\N	2025-10-02 03:09:10.597824-04
97	pdub2025000000	C	4052454400535432353130303231363130433070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFCF0C0d0a0000000000	2025-10-02 03:10:11.785-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:10:13.581-04	1	\N	\N	\N	2025-10-02 03:10:13.582653-04
98	pdub2025000000	O	40524544005354323531303032313631304F3070647562323032353030303030302C756E697175655F69645F3030303030302C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCC00d0a0000000000	2025-10-02 03:10:16.391-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:10:18.243-04	1	\N	\N	\N	2025-10-02 03:10:18.245183-04
99	ADUL2025000018	C	405245440053543235313030323136313043304144554C323032353030303031382C363770577072264136412667615544352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF380A0d0a0000000000	2025-10-02 03:10:53.468-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:10:55.277-04	1	\N	\N	\N	2025-10-02 03:10:55.278477-04
100	ADUL2025000018	O	40524544005354323531303032313631304F304144554C323032353030303031382C363770577072264136412667615544352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF0BC60d0a0000000000	2025-10-02 03:10:57.919-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:10:59.729-04	1	\N	\N	\N	2025-10-02 03:10:59.730979-04
101	ADUL2025000018	C	405245440053543235313030323136313143304144554C323032353030303031382C363770577072264136412667615544352C636F6D70616E795F303030303030303073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF04CE0d0a0000000000	2025-10-02 03:11:03.254-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:11:05.116-04	1	\N	\N	\N	2025-10-02 03:11:05.117884-04
102	ADUL2025000018	O	40524544005354323531303032313631334F304144554C323032353030303031382C363770577072264136412667615544352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F90d0a0000000000	2025-10-02 03:13:08.778-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:13:10.557-04	1	\N	\N	\N	2025-10-02 03:13:10.559069-04
103	ADUL2025000018	C	405245440053543235313030323136313343304144554C323032353030303031382C363770577072264136412667615544352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFFC6350d0a0000000000	2025-10-02 03:13:23.719-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:13:25.494-04	1	\N	\N	\N	2025-10-02 03:13:25.495509-04
104	ADUL2025000017	O	40524544005354323531303032313631344F304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF4FDF0d0a0000000000	2025-10-02 03:14:39.833-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:14:41.627-04	1	\N	\N	\N	2025-10-02 03:14:41.628668-04
105	ADUL2025000017	C	405245440053543235313030323136313443304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF7C130d0a0000000000	2025-10-02 03:14:44.232-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:14:46.024-04	1	\N	\N	\N	2025-10-02 03:14:46.025763-04
106	ADUL2025000017	O	40524544005354323531303032313631344F304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF4FDF0d0a0000000000	2025-10-02 03:14:55.704-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:14:57.509-04	1	\N	\N	\N	2025-10-02 03:14:57.510476-04
107	ADUL2025000017	C	405245440053543235313030323136313543304144554C323032353030303031372C4C2A6B66477059336B72752D33264D352C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF40D70d0a0000000000	2025-10-02 03:15:05.033-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:15:06.849-04	1	\N	\N	\N	2025-10-02 03:15:06.850294-04
108	ADUL2025000016	O	40524544005354323531303032313631374F304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF169B0d0a0000000000	2025-10-02 03:17:00.69-04	E00	4052454400084F4145303030ECFA0D0A	2025-10-02 03:17:02.491-04	1	\N	\N	\N	2025-10-02 03:17:02.492665-04
109	ADUL2025000016	C	405245440053543235313030323136313743304144554C323032353030303031362C6E6E426E5524374E776434542D3451252C3230323530333033333637323235343073797374656DFFFFFFFFFFFFFFFFFFFFFFFFFFFF25570d0a0000000000	2025-10-02 03:17:05.435-04	E00	40524544000843414530303020FA0D0A	2025-10-02 03:17:07.234-04	1	\N	\N	\N	2025-10-02 03:17:07.236176-04
\.


--
-- Data for Name: customer_base; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.customer_base (customer_id, business_no, customer_nm, site_info, manager_nm, department, email, tel_no, co_unique_id, admin_pw, master_key, memo, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
POSCO	3018702315	포스코						lqxap8swKGmSbsJ4cMpUnqb/a6tMIAxsaLw6QoKzoK2iV9lEJU+cgp3UjZ0=	6AfNW6YJB/DGxNXk0gj5iUPu+xFjlFmtxNCCo2ag5MJ41uyNh4bdwO06Uvs=	BAn4P+Y+MRTUTACoHbfDR8jfcCuPIYDA2jT9D6Bn6wscIH8B/pDb8+eKd8U=		t	2025-09-16 12:02:55.66401-04	system	\N	\N
SNNC	4168152508	(주)에스엔엔씨						d900wrXsER46jBfj4QInBXjjhH+6EV9PdUpqcpZXa3bJiMN8LmwLE9qYfm0=	vNq6gGjSFFm94+OtHzR++/aygYwQbmtEBAAWGfkosGlLtLIEsC8QABlSc0o=	cNYDvZu7l6AxA4e87XELOwD405jmX3X/NpSKbrTLVpDqv45bBXGloUq0IRU=		t	2025-09-16 12:04:17.003303-04	system	2025-09-16 12:04:37.003451-04	system
GlobalJW	1258196541	글로벌지우						g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=		t	2025-09-16 12:05:56.215969-04	system	\N	\N
koiware	2128198862	코이웨어	코이웨어	곽현철	개발부	koi.hckwak@gmail.com	01091253662	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=		t	2025-09-17 23:54:41.781375-04	hckwak	2025-09-18 01:00:24.483915-04	hckwak
\.


--
-- Data for Name: customer_gen_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.customer_gen_history (history_id, customer_id, co_unique_id, admin_pw, master_key, co_uid_plain, created_at, created_by) FROM stdin;
\.


--
-- Data for Name: jwt_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.jwt_mgmt (user_id, access_token, refresh_token, login_at) FROM stdin;
daenahn	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU4MTcyNDk4LCJ1c2VySWQiOiJkYWVuYWhuIn0.25aYct2dVgCz7t_P_crrzcozH83KRfKNmn49wHXWCn0	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU4MTczMDk4LCJ1c2VySWQiOiJkYWVuYWhuIn0.UeRzZUkGTi7lRUEeAQNgYgQY8MwpsFUbgHVEm-jftC4	2025-09-18 00:54:58.296213-04
hckwak	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU4NjkwMzE3LCJ1c2VySWQiOiJoY2t3YWsifQ.uP2tb8PJ5kGrgS4yndDNMA66ABrtHIN41bTygWM68C0	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU4NjkwOTE3LCJ1c2VySWQiOiJoY2t3YWsifQ.McjY7BM4ncnUIIO11-FxCgGvZxOTTWZ-WLUBsFQVPwI	2025-09-24 00:45:17.334122-04
system	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU5NDk5NDgxLCJ1c2VySWQiOiJzeXN0ZW0ifQ.vMlUu7qB6yC86KobMOttD7S4cG--RvK8m0OLVfpgV9E	eyJ0eXBlIjoiQXV0aG9yaXphdGlvbiIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiJ1c2VyIiwiZXhwIjoxNzU5NTAwMDgxLCJ1c2VySWQiOiJzeXN0ZW0ifQ.JTnokLFRElEJ3W4l1EIa3500v-ulHSPfk05R3yJracA	2025-10-03 09:31:21.714793-04
\.


--
-- Data for Name: lock_customer_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.lock_customer_history (history_id, df_serial_number, co_unique_id, admin_pw, master_key, previous_co_unique_id, previous_admin_pw, previous_master_key, change_reason, process_type, process_id, updated_at, updated_by, note) FROM stdin;
\.


--
-- Data for Name: lock_identity_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.lock_identity_history (history_id, serial_number, unique_id, previous_serial_number, previous_unique_id, model_id, change_reason, process_type, process_id, updated_at, updated_by, note) FROM stdin;
\.


--
-- Data for Name: lock_model_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.lock_model_mgmt (model_id, model_cd, category, model_nm, color, memo, is_active, created_at, created_by, updated_at, updated_by, deleted_at, deleted_by) FROM stdin;
1	PDUL-S0-02L-ASP	PD_01	AR-LOCK-Type1	P	기본 USB LOCK	t	2025-09-16 12:10:09.433189-04	system	\N	\N	\N	\N
2	PDUL-S0-01L-PNR	PD_02	MA-LOCK-Type1	R	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:19:36.087175-04	system	\N	\N	\N	\N
3	PDUL-S0-01L-PNP	PD_02	MA-LOCK-Type1	P	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:20:38.017415-04	system	\N	\N	\N	\N
4	PDUL-S0-01L-PNO	PD_02	MA-LOCK-Type1	O	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:21:14.674209-04	system	\N	\N	\N	\N
5	PDUL-S0-01L-PNG	PD_02	MA-LOCK-Type1	G	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:21:48.504727-04	system	\N	\N	\N	\N
6	PDUL-S0-01L-PNB	PD_02	MA-LOCK-Type1	B	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:22:12.353871-04	system	\N	\N	\N	\N
7	PDUL-S0-01L-PNY	PD_02	MA-LOCK-Type1	Y	소형 MA-Lock, 플라스틱, 25mm, BLE/USB	t	2025-09-16 12:22:26.720347-04	system	\N	\N	\N	\N
8	PDUB-S0-02L-ASP	PD_01	AR-LOCK-Type2	P	기본 패드락, 알루미늄, 50mm, BLE/USB	t	2025-09-16 12:24:02.739922-04	system	\N	\N	\N	\N
9	CLUL-H0-R10-ZNK	CD_01	Round CAM Lock	K	캐비닛락, 28파이	t	2025-09-16 12:25:19.108028-04	system	\N	\N	\N	\N
\.


--
-- Data for Name: lock_settings_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.lock_settings_history (history_id, df_serial_number, lock_method, remote_lock, guard_mode, ecd_id, firmware_version, lif_id, update_flag, change_type, change_reason, updated_at, updated_by, note) FROM stdin;
\.


--
-- Data for Name: menu_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.menu_mgmt (menu_id, par_menu_id, menu_nm, url, "order", is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
menu_20250107_001	\N	홈		1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_002	\N	기준정보		2	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_003	\N	입고 관리		3	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_004	\N	출고 관리		4	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_005	\N	입/출/반품 관리		5	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_006	\N	리포트		6	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_007	menu_20250107_002	조직 관리	/admin/master/organization	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_008	menu_20250107_002	사용자 관리	/admin/master/users	2	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_009	menu_20250107_002	고객사 관리	/admin/master/customers	3	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_010	menu_20250107_002	락 모델 관리	/admin/master/lock-models	4	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_011	menu_20250107_002	공지사항	/admin/master/notice	5	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_012	menu_20250107_002	공통코드 관리	/admin/master/com-code	6	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_013	menu_20250107_002	자동채번 관리	/admin/master/seq	7	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_014	menu_20250107_003	sLock 등록	/inbound/slock	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_017	menu_20250107_004	sLock 출고	/outbound/slock	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_020	menu_20250107_005	입/출/반품 관리	/in-out/management	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_021	menu_20250107_005	sLock 초기화	/in-out/init-slock	2	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_022	menu_20250107_006	입/출고 현황	/reports/in-out	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_023	menu_20250107_006	접속 현황	/reports/conn	2	t	2025-01-07 09:34:33.924-05	system	\N	\N
menu_20250107_024	menu_20250107_001	대시보드	/home/dashboard	1	t	2025-01-07 09:34:33.924-05	system	\N	\N
\.


--
-- Data for Name: notice_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.notice_mgmt (notice_id, division, category, subject, content, importance, post_from, post_to, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
1	1	1	공지사항 테스트	테스트 공지사항	0001	2025-09-18	2025-09-18	t	2025-09-17 23:25:38.252419-04	hckwak	2025-09-17 23:27:18.911015-04	hckwak
2	3	1	서버 공지사항 테스트	서버 공지사항 테스트	0001	2025-09-18	2026-09-18	t	2025-09-17 23:28:02.856523-04	hckwak	\N	\N
\.


--
-- Data for Name: notice_read_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.notice_read_history (notice_id, user_id, read_at) FROM stdin;
1	hckwak	2025-09-17 23:27:05.349896-04
2	system	2025-09-18 03:35:16.689451-04
1	system	2025-09-18 04:52:57.247983-04
\.


--
-- Data for Name: organization_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.organization_mgmt (org_id, par_org_id, org_nm, org_type, memo, "order", is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
JW0000	\N	지우테크	0001	\N	2	t	2025-01-07 10:03:47.034-05	system	\N	\N
JW000013	\N	공통	0001	\N	3	t	2025-09-16 11:53:14.474995-04	system	\N	\N
JW000014	JW0000	PALL팀	0001	\N	0	t	2025-09-16 11:54:42.775979-04	system	\N	\N
JW000015	JW0000	임원그룹	0001	\N	1	t	2025-09-16 11:54:53.503331-04	system	\N	\N
JW000016	JW0000	3M팀	0001	\N	2	t	2025-09-16 11:55:19.262642-04	system	\N	\N
JW000017	JW0000	관리팀	0001	\N	3	t	2025-09-16 11:55:34.933792-04	system	\N	\N
JW000018	JW0000	오존팀	0001	\N	4	t	2025-09-16 11:55:43.838227-04	system	\N	\N
JW000019	JW0000	안전&IoT팀	0001	\N	5	t	2025-09-16 11:56:02.207279-04	system	\N	\N
JW000020	\N	코이웨어	0001	\N	4	t	2025-09-17 22:57:52.15394-04	system	\N	\N
JW000021	JW000020	개발부	0001	\N	0	t	2025-09-17 22:58:04.532358-04	system	\N	\N
JW000023	JW0000	구미지사	0001	\N	6	t	2025-10-03 03:57:27.861194-04	system	\N	\N
\.


--
-- Data for Name: product_info; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.product_info (product_id, serial_number, unique_id, co_unique_id, admin_pw, master_key, lock_method, remote_lock, guard_mode, ecd_id, firmware_ver, lif_id, update_flag, device_status, operation_status, battery_level, is_active, last_connection, created_at, created_by, updated_at, updated_by) FROM stdin;
10	ADUL2025000011	J+a6yD2vR80zswccF0crEqPneVHgW2sHnDJXzRA276vGAW+mKQ+IUQkOtcE=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.004	li_000000000	\N	\N	\N	\N	t	\N	2025-09-23 04:27:13.729689-04	hckwak	2025-09-23 04:37:03.562003-04	hckwak
12	ADUL2025000013	dLqWOBie6NAgXPRlm19PcgcUzPG3u1PcIwVAAtzn0mU+epn4iTM1FjGLGh8=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-23 04:27:19.157156-04	hckwak	2025-09-23 04:37:03.562003-04	hckwak
1	ADUL2025000002	b9d+ElZtiTZd+gSjTt9IR5OnmlaSWx/oTkD7VyTPjtO1lZb430GBa8GRZMg=	\N	\N	\N	0	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-16 12:39:43.811864-04	system	2025-09-16 12:45:57.131089-04	system
11	ADUL2025000012	qGTYxiZMdp4zv3Hfwk8u+Vwo14msBLiuXY01ZA08qfOo4d9jlFJJSN0jYko=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-23 04:27:16.454628-04	hckwak	2025-09-23 04:37:03.562003-04	hckwak
2	ADUL2025000003	yRhYgs7Mukr6ZPAwc9Wsig75rf6KwslD7gXgxBsl/dNiDYTvuyJMFF3q94k=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.004	li_000000000	\N	\N	\N	\N	t	\N	2025-09-17 23:50:27.845546-04	hckwak	2025-09-17 23:59:00.469424-04	hckwak
9	ADUL2025000010	asJpSnd80BQ69v9E5+8YmmBoFGb7t8SmeLZBxHeVil7xf6j9Vri3AX8gsAA=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-23 04:27:10.987379-04	hckwak	2025-09-23 04:37:03.562003-04	hckwak
3	ADUL2025000004	ZGixsZP5A2Ap0xa0pfQyNGg7mcTqupdgbvtccA2oOWLD4m6ypSUAXd5jsqg=	P4a0trmjuGTqiEiiFZB/486ya9Hp11LYwoPkl90r82v3xWXK/KHyVbMKV0I=	P4a0trmjuGTqiEiiF5ti5PDsIr7p11LYwoPkl0p4KKANRzp7iNs1S08h6Tg=	P4a0trmjuGTqiEiiG5RNo5/sIr7p11LYwoPklwiu4r5JkT0FfbOijctlDBc=	1	0	0	ecd_id_000000000	2.0.004	li_000000000	0	\N	\N	\N	\N	\N	2025-09-17 23:50:30.574532-04	hckwak	2025-09-18 00:52:52.565557-04	\N
13	ADUL2025000014	TWQrzJZecauNR4535qmKz8YzagemCxseqDPWb96+/Tg9vuWmn/yqOhgYfo0=	zKs9BZGPQL9s/oCWfxfZmxMVqYYGkij+02mSDvUePjHF2vqRaLu6g92iSxE=	7TrecowlsUp3yG2ksT0noA2R2Yx99q1R/xviK0jd4tTcyUYVru+Knz6dXKE=	QACYw7gwSFqYlsUccJu13J0Bla46Uy3TTPlXB7jpVkf0YoUAYtQoVPLaShg=	1	0	0	ecd_id_000000000	2.0.018	li_000000000	\N	\N	\N	\N	t	\N	2025-09-26 03:37:52.915759-04	system	2025-09-26 03:40:20.924796-04	system
4	ADUL2025000005	AnvC9FZf+rJk2yoisK1PrmrA+0WmEs0y8+IAr65r360KHtFW6f1RKoxTsa0=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-18 02:53:21.685709-04	system	2025-09-18 02:59:12.645863-04	system
14	ADUL2025000015	/SxKX2Q7cJkhzcvHPgor3h3BNlZLs/q80u/DBLB+HZQwnKZMBcdEzOBmvAc=	lqxap8swKGmSbsJ4cMpUnqb/a6tMIAxsaLw6QoKzoK2iV9lEJU+cgp3UjZ0=	6AfNW6YJB/DGxNXk0gj5iUPu+xFjlFmtxNCCo2ag5MJ41uyNh4bdwO06Uvs=	BAn4P+Y+MRTUTACoHbfDR8jfcCuPIYDA2jT9D6Bn6wscIH8B/pDb8+eKd8U=	1	0	0	ecd_id_000000000	2.0.018	li_000000000	\N	\N	\N	\N	t	\N	2025-09-26 03:50:26.476165-04	system	2025-09-26 03:51:42.274433-04	system
5	ADUL2025000006	yw+ItRf2VV210pe0/fwT4LgtKgzFpbQ92cdfxTyqUnV4ddFoeDR0M3LUTUc=	lqxap8swKGmSbsJ4cMpUnqb/a6tMIAxsaLw6QoKzoK2iV9lEJU+cgp3UjZ0=	6AfNW6YJB/DGxNXk0gj5iUPu+xFjlFmtxNCCo2ag5MJ41uyNh4bdwO06Uvs=	BAn4P+Y+MRTUTACoHbfDR8jfcCuPIYDA2jT9D6Bn6wscIH8B/pDb8+eKd8U=	1	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-18 04:55:02.850145-04	hckwak	2025-09-18 04:58:22.931901-04	hckwak
6	ADUL2025000007	uik3qkghaaPKMuvUSvrWbbvICjnK344Nq1BP6LPePvXlcf2m0JhpXK89se4=	lqxap8swKGmSbsJ4cMpUnqb/a6tMIAxsaLw6QoKzoK2iV9lEJU+cgp3UjZ0=	6AfNW6YJB/DGxNXk0gj5iUPu+xFjlFmtxNCCo2ag5MJ41uyNh4bdwO06Uvs=	BAn4P+Y+MRTUTACoHbfDR8jfcCuPIYDA2jT9D6Bn6wscIH8B/pDb8+eKd8U=	1	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-18 04:55:05.62016-04	hckwak	2025-09-18 04:58:22.931901-04	hckwak
7	ADUL2025000008	ohBJGNix7R+fp3+4BCl1HkktajaftDlnmmbRx+1BtdTtN6bVCv054Da6S0w=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-19 03:10:38.824029-04	system	2025-09-19 03:14:09.249425-04	system
8	ADUL2025000009	bg7KnjCA0GXjrzR/VbDLD8nr31Sl4u6MPtIcA72Y2UT9O8UjoUUOwJJZyOM=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.016	li_000000000	\N	\N	\N	\N	t	\N	2025-09-19 03:10:41.671464-04	system	2025-09-19 03:14:09.249425-04	system
17	ADUL2025000018	J927oS28wZrLX5HYTXsbAHBA+wsO610JlhRVUeGUo7j4CGL2CLfB9kUMWTo=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.020	li_000000000	\N	\N	\N	\N	t	\N	2025-10-02 03:10:29.025376-04	system	2025-10-02 03:12:59.2583-04	system
16	ADUL2025000017	QmWYEt6Oa9RH/GNT8Vb1cRy+6knQT+eJH6kYzkx+lBsqlV3AWder66HIsTg=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.020	li_000000000	\N	\N	\N	\N	t	\N	2025-10-02 03:08:06.068836-04	system	2025-10-02 03:14:32.831114-04	system
15	ADUL2025000016	4n63TfdwGPU1AX+zwoomJoEcxSRB1zU0PRS5oJ27IHC0Y0xVJh3m9fLSFvs=	g/41yfG9e+VJBOE4XBVHwg8gqiJ7YJdXBl1kxQMXWIZUHFfTCtj2E9Xk7vc=	dD7PlvGcngjVHc9d9LxaxFXp7/L/T8B857gZGInZe8Tv3mYrrp5TGf8XM8U=	DoYh9607DpPfY0SvjUWMwLLDGAeJNDgFhuqOSWNogEkWYrDbb+KwNPOtUNc=	0	0	0	ecd_id_000000000	2.0.020	li_000000000	\N	\N	\N	\N	t	\N	2025-10-02 03:04:14.514517-04	system	2025-10-02 03:16:34.256183-04	system
\.


--
-- Data for Name: product_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.product_mgmt (product_id, model_id, status, incoming_date, warehouse_location, rack_number, incoming_memo, incoming_by, customer_id, install_site_info, install_department, manager_nm, manager_contact, outgoing_shipping_company, outgoing_tracking_number, outgoing_shipping_status, outgoing_shipping_post_cd, outgoing_shipping_address, outgoing_shipping_detail_address, outgoing_shipping_note, outgoing_shipping_info, outgoing_inspection_result, outgoing_inspector, outgoing_inspected_at, outgoing_quality_status, contract_number, order_number, outgoing_memo, outgoing_expected_date, outgoing_actual_date, return_expected_date, requester_name, requester_contact, request_date, approval_date, approver, refund_date, requires_inspection, refund_inspection_result, refund_inspector, refund_inspected_at, pickup_post_cd, pickup_address, pickup_detail_address, pickup_date, refund_shipping_company, refund_tracking_number, refund_shipping_status, refund_shipping_post_cd, refund_shipping_address, refund_shipping_detail_address, refund_memo, disposal_at, disposal_by, disposal_memo, outgoing_by) FROM stdin;
1	1	1	2025-09-17	구미사무소	\N	정상	system	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	1	5	2025-09-23	코이웨어 창고	\N	d	hckwak	koiware	코이웨어	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	hckwak	2025-09-23	\N	\N	\N	\N	\N	2025-09-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
10	1	5	2025-09-23	코이웨어 창고	\N	d	hckwak	koiware	코이웨어	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	hckwak	2025-09-23	\N	\N	\N	\N	\N	2025-09-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
12	1	5	2025-09-23	코이웨어 창고	\N	d	hckwak	koiware	코이웨어	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	hckwak	2025-09-23	\N	\N	\N	\N	\N	2025-09-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
11	1	5	2025-09-23	코이웨어 창고	\N	d	hckwak	koiware	코이웨어	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	hckwak	2025-09-23	\N	\N	\N	\N	\N	2025-09-23	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
3	1	1	2025-09-18	코이웨어 1301호	\N	테스트 입고	hckwak	koiware	1301호	개발부	곽현철	01091253662	1	111111111	1	06631	서울 서초구 서초대로 356	1301호	\N	\N	성공	hckwak	2025-09-18	\N	202509180001	202509180001	\N	2025-09-18	2025-09-19	\N	곽현철	01091253662	2025-09-18	\N	\N	2025-09-18	f	정상	곽현철	2025-09-18	06631	서울 서초구 서초대로 356	1301호	2025-09-18	1	111111111	3	06631	서울 서초구 서초대로 356	1301호	\N	\N	\N	\N	hckwak
13	1	3	2025-09-26	시스템베이스	\N	테스트 1	system	koiware	시스템베이스	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-09-26	\N	\N	\N	시스템베이스 테스트 1	2025-09-26	2025-09-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
4	1	3	2025-09-18	구미사무소	\N	19	system	GlobalJW	지우본사	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-09-18	\N	\N	\N	\N	\N	2025-01-09	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
14	1	5	2025-09-26	시스템베이스	\N	테스트 2	system	POSCO	시스템베이스	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-09-26	\N	\N	\N	시스템베이스 테스트 2	2025-09-26	2025-09-26	2025-10-26	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
2	1	5	2025-09-18	코이웨어 1301호	\N	테스트 입고	hckwak	koiware	코이웨어	코이웨어	곽현철	01091253662	1	111111	2	06631	서울 서초구 서초대로 356	1301호	\N	\N	성공	hckwak	2025-09-18	\N	111111	111111	\N	2025-09-18	2025-09-18	2026-09-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
6	1	5	2025-09-18	1301호	\N	테스트 입고	hckwak	koiware	코이웨어	코이웨어	곽현철	01091253662	1	111111	2	06631	서울 서초구 서초대로 356	1301호	\N	\N	성공	hckwak	2025-09-18	\N	111111	111111	\N	2025-09-18	2025-09-18	2026-09-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
5	1	5	2025-09-18	1301호	\N	테스트 입고	hckwak	koiware	코이웨어	코이웨어	곽현철	01091253662	1	111111	2	06631	서울 서초구 서초대로 356	1301호	\N	\N	성공	hckwak	2025-09-18	\N	111111	111111	\N	2025-09-18	2025-09-18	2026-09-30	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	hckwak
17	1	3	2025-10-02	구미	\N	02	system	GlobalJW	GlobalJW	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-10-02	\N	\N	\N	\N	\N	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
16	1	3	2025-10-02	구미	\N	02	system	GlobalJW	GlobalJW	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-10-02	\N	\N	\N	\N	\N	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
7	1	3	2025-09-19	구미사무소	\N	12	system	GlobalJW	지우본사	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-09-19	\N	\N	\N	\N	\N	2025-09-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
8	1	3	2025-09-19	구미사무소	\N	12	system	GlobalJW	지우본사	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-09-19	\N	\N	\N	\N	\N	2025-09-19	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
15	1	3	2025-10-02	구미	\N	02	system	GlobalJW	GlobalJW	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	성공	system	2025-10-02	\N	\N	\N	\N	\N	2025-10-02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	system
\.


--
-- Data for Name: role_information; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.role_information (role_id, role_cd, role_nm, created_at, created_by, updated_at, updated_by) FROM stdin;
role_20241211_001	ROLE_SYSTEM	시스템관리자	2025-01-03 09:13:54.213-05	system	\N	\N
role_20241211_002	ROLE_ADMIN	관리자	2025-01-03 09:13:54.213-05	system	\N	\N
role_20241211_003	ROLE_USER	일반사용자	2025-01-03 09:13:54.213-05	system	\N	\N
\.


--
-- Data for Name: role_menu_map; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.role_menu_map (role_id, menu_id, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
role_20241211_001	menu_20250107_001	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_001	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_001	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_002	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_002	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_002	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_003	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_003	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_003	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_004	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_004	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_004	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_005	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_005	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_005	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_006	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_006	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_006	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_007	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_007	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_007	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_008	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_008	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_008	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_009	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_009	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_009	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_010	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_010	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_010	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_011	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_011	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_011	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_012	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_012	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_012	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_013	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_013	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_013	f	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_014	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_014	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_014	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_017	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_017	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_017	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_020	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_020	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_020	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_021	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_021	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_021	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_022	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_022	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_022	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_023	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_023	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_023	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_001	menu_20250107_024	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_002	menu_20250107_024	t	2025-01-07 09:38:36.462-05	system	\N	\N
role_20241211_003	menu_20250107_024	t	2025-01-07 09:38:36.462-05	system	\N	\N
\.


--
-- Data for Name: sequence_history; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.sequence_history (history_id, sequence_type, sequence_value, created_at, created_by) FROM stdin;
1	0001	12	2025-09-16 11:51:24.584597-04	system
2	0001	13	2025-09-16 11:53:14.474995-04	system
3	0001	14	2025-09-16 11:54:42.775979-04	system
4	0001	15	2025-09-16 11:54:53.503331-04	system
5	0001	16	2025-09-16 11:55:19.262642-04	system
6	0001	17	2025-09-16 11:55:34.933792-04	system
7	0001	18	2025-09-16 11:55:43.838227-04	system
8	0001	19	2025-09-16 11:56:02.207279-04	system
9	0002	2	2025-09-16 12:39:43.811864-04	system
10	0001	20	2025-09-17 22:57:52.15394-04	system
11	0001	21	2025-09-17 22:58:04.532358-04	system
12	0002	3	2025-09-17 23:50:27.845546-04	hckwak
13	0002	4	2025-09-17 23:50:30.574532-04	hckwak
14	0001	22	2025-09-18 00:54:16.622884-04	hckwak
15	0002	5	2025-09-18 02:53:21.685709-04	system
16	0002	6	2025-09-18 04:55:02.850145-04	system
17	0002	7	2025-09-18 04:55:05.62016-04	system
18	0002	8	2025-09-19 03:10:38.824029-04	system
19	0002	9	2025-09-19 03:10:41.671464-04	system
20	0002	10	2025-09-23 04:27:10.987379-04	hckwak
21	0002	11	2025-09-23 04:27:13.729689-04	hckwak
22	0002	12	2025-09-23 04:27:16.454628-04	hckwak
23	0002	13	2025-09-23 04:27:19.157156-04	hckwak
24	0002	14	2025-09-26 03:37:52.915759-04	system
25	0002	15	2025-09-26 03:50:26.476165-04	system
26	0002	16	2025-10-02 03:04:14.514517-04	system
27	0002	17	2025-10-02 03:08:06.068836-04	system
28	0002	18	2025-10-02 03:10:29.025376-04	system
29	0001	23	2025-10-03 03:57:27.861194-04	system
\.


--
-- Data for Name: sequence_mgmt; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.sequence_mgmt (sequence_type, sequence_nm, prefix, min_value, max_value, increment_by, format, current_value, usage_limit, used_count, memo, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
0003	자물쇠 시리얼번호(P_LOCK_MA)	ADUB	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(ECD_MT)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0004	자물쇠 시리얼번호(P_LOCK_ML)	MDUL	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(P_LOCK_AC)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0005	자물쇠 시리얼번호(CAM_GL)	CLUL	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(P_LOCK_MA)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0006	자물쇠 시리얼번호(ECD_PT)	PDUB	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(P_LOCK_ML)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0007	자물쇠 시리얼번호(ECD_MT)	PDUB	1	999999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(ECD_AUTO)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0008	자물쇠 시리얼번호(ECD_TAG)	PDUB	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(ECD_PT)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0009	자물쇠 시리얼번호(ECD_AUTO)	PDUB	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	1	9999	0	자물쇠 시리얼번호(ECD_TAG)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0002	자물쇠 시리얼번호(P_LOCK_AC)	ADUL	1	9999	1	{PREFIX}{YYYY}{VALUE:06d}	18	9999	17	자물쇠 시리얼번호(CAM_GL)	t	2025-01-13 10:40:02.269-05	system	\N	\N
0001	부서코드	JW	1	9999	1	{PREFIX}{VALUE:06d}	23	9999	12	부서코드	t	2025-01-07 11:44:25.937-05	system	\N	\N
\.


--
-- Data for Name: user_information; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.user_information (user_id, org_id, emp_no, mobile_no, tel_no, email, "position", resp_office, org_type, etc_cd, division, start_at, retire_at, created_at, created_by, updated_at, updated_by) FROM stdin;
jjoh	JW000016	\N	ce024e0cf8b025642f9c4905adf6f2f2	\N	ab95a8da8c61f9b511626db3e7723e4192587a8f3c2dbc089f5b81b7e2928ff3	9	17	0001	\N	\N	\N	\N	2025-09-16 01:43:45.750142-04	system	2025-09-16 11:59:59.935155-04	system
cwsong	JW000018	\N	ca893ba39ada2512721c09d3214f707e	\N	428fd08467b448c81403f770be2d76b77557c65ad6645ce0007da2141d109b5b	11	17	0001	\N	\N	\N	\N	2025-09-16 03:54:53.093529-04	system	2025-09-16 11:57:51.174416-04	system
khlee2	JW000018	\N	2f4797d21e9ff4f5c2ad3050f7d39822	\N	889ab9dcf1927d6cf74ad11f69917fbd6ba42ae5a2482017bc190c2f39ab0dbe	11	17	0001	\N	\N	\N	\N	2025-09-16 03:55:21.176564-04	system	2025-09-16 11:57:51.174416-04	system
ihchoi	JW000016	\N	1cd6119db6c4b6fcdfcfa7c2327ac487	\N	29d303ed7f98e45db4306bace3fd8c602fca381075b5c49f55d7e1bf54a5c2e6	10	17	0001	\N	\N	\N	\N	2025-09-16 03:54:27.730955-04	system	2025-09-16 11:58:21.846147-04	system
srmkim	JW000017	\N	f7671554610d7dd54a27098f2e10a089	\N	bcf7e254299ac2f4d24e18410ded84aafc7fadaa45e1be6e2c153c288bc4cb7e	10	17	0001	\N	\N	\N	\N	2025-09-16 01:50:50.374824-04	system	2025-09-16 11:58:58.863519-04	system
jhno	JW000014	\N	f3c01d4ddc1a81b7ab0af40f9c7dc3cb	\N	9dcdb67aebdc2cc62595c9e271356a0f7e99daa46c3ca2f4356af2d883f15c75	10	17	0001	\N	\N	\N	\N	2025-09-16 01:51:36.860618-04	system	2025-09-16 11:59:19.926166-04	system
jbson	JW000014	\N	c306c917bd7f701a551b633a1c5d2463	\N	3e8fbce2db9bc02e0a1c60cb99794e3b434f25d9b2697a0ed881d457903cab3a	10	17	0001	\N	\N	\N	\N	2025-09-16 03:51:51.568418-04	system	2025-09-16 11:59:19.926166-04	system
gtgu	JW000018	\N	61389afa0484d627a873500d04f611d8	\N	948cd68d39b05aeaf5a09ed6cacc2438691083bc7583875d5f34d3cadeaf4f38	8	17	0001	\N	\N	\N	\N	2025-09-16 01:42:34.269753-04	system	2025-09-16 11:59:35.189431-04	system
gwseo	JW000018	\N	12dd1fd279625f6841d17cd30ae36344	\N	59748dd8c24a32ead9481aeb40e2802f1481ddcc965f70c6fa80e6aa7b658512	8	17	0001	\N	\N	\N	\N	2025-09-16 01:43:04.114132-04	system	2025-09-16 11:59:35.189431-04	system
cmkim	JW000016	\N	81162fb001cea5a01cb2a33c8229f35b	\N	2ee01f9b10ecb12cc6b2eb2af53a370ad42eb70956cfd324bb6e253136ed244e	7	10	0001	\N	\N	\N	\N	2025-09-16 01:40:32.186021-04	system	2025-09-16 11:59:59.935155-04	system
dhjo	JW000014	\N	7e5da30654f873e903917b9003a0bfff	\N	d0edb345b7b7d66581abb796e048a4690a5c34da489d6c62d7b0b4c89517a899	10	17	0001	\N	\N	\N	\N	2025-09-16 03:54:00.252867-04	system	2025-09-16 11:58:32.815033-04	system
jmlim	JW000018	\N	d07781283f4006bc9db8816a65180cef	\N	3e767b4fbbe01698c1904828fb01d4e7df9ac9fcca829e58d3216c82787924de	9	17	0001	\N	\N	\N	\N	2025-09-16 01:44:29.614026-04	system	2025-09-16 11:59:35.189431-04	system
shjung	JW000016	\N	a232b0e0bba503e4945c50396e3be4e4	\N	bc4bdfa1c442ca1e1631e84a362a40b43cd318da6cf24b74857c1e408171d890	7	10	0001	\N	\N	\N	\N	2025-09-16 01:41:26.714221-04	system	2025-09-16 11:59:59.935155-04	system
zschoi	JW000016	\N	9b4be77b78743800588806a77937be36	\N	18f2d001f8a06bf2d92b26ed87558913559f76778ce95491f31e2504ee194570	7	10	0001	\N	\N	\N	\N	2025-09-16 01:41:59.696563-04	system	2025-09-16 11:59:59.935155-04	system
jychoi	JW000015	\N	8e697cf5909b958357899142b9393a3d	\N	2d80ef6f1b5ceb854f6258ba23b027b371784f1eed3065796d0d0904f46341fe	2	6	0001	\N	\N	\N	\N	2025-09-16 01:33:00.417976-04	system	2025-09-16 12:00:33.253394-04	system
chyou	JW000014	\N	da40f05305dfa42e92be5d6da29d806e	\N	75a9e803d8eec721a4d137131d0f2c1e8f1511d9879ce2fd805df5201c70c879	7	10	0001	\N	\N	\N	\N	2025-09-16 01:40:58.782938-04	system	2025-09-16 12:00:07.719107-04	system
jplee	JW000015	\N	22e67cafac65c37bfd3e6bf099101126	\N	20157576bf470562d15c915b324f697e2b1770cae402aeb7db72033ba4b84228	5	10	0001	\N	\N	\N	\N	2025-09-16 01:38:46.17838-04	system	2025-09-16 12:00:21.821466-04	system
smwoo	JW000015	\N	c4509fd03b0769a3ecf0b45e5d15b1cb	\N	920252291cb37e4057027759a6ffe2ee69128faf9bcd8fb65a79962678fe1970	1	1	0001	\N	\N	\N	\N	2025-09-16 01:27:55.727374-04	system	2025-09-16 12:00:33.253394-04	system
wksong	JW000015	\N	fd47477325f1e9d22073f9414d7588bb	\N	6859c495a93fabb81370c586a910eccbddb8517251fbe515627ca0407d60f57b	2	6	0001	\N	\N	\N	\N	2025-09-16 01:32:19.968617-04	system	2025-09-16 12:00:33.253394-04	system
yskim	JW000015	\N	b312f807b5ed13b19bdc774e08ba05b9	\N	f276bcf791400ca6ec2762f64fc4ad9dbebe1015e0486132c17473a201bdaad3	1	1	0001	\N	\N	\N	\N	2025-09-16 01:23:54.497825-04	system	2025-09-16 12:00:46.463883-04	system
jhbang	JW000016	\N	2ee7b3d2dfff0dfc07fa82ab1cf0ea17	\N	ccd8456710dc87911768f6fdfb410855ec52cdf102dc5f067d53408fe88153b2	10	1	0001	\N	\N	\N	\N	2025-09-16 01:24:51.507404-04	system	2025-09-16 12:00:57.006395-04	system
jijeon	JW000017	\N	73c389649cb980cf290e44ad151e1d53	\N	afee24bf69a854d427d214d3e84060d65373334cf12f67c32a8b638526d0a0ca	10	17	0001	\N	\N	\N	\N	2025-09-16 03:53:28.19064-04	system	2025-09-18 04:51:37.766399-04	system
gtkim	JW000013	\N	cdf6657bac6cf8edfcd7ced69dd97fac	\N	dbf493e711eb89850e3225b445618f96e9d866bfe1a335b71543bd635ef1b599	5	3	0001	\N	\N	\N	\N	2025-09-16 01:30:35.159841-04	system	2025-09-16 11:54:05.967231-04	system
system	JW000013	123411	b27eb0a6802a22f500cde50d105629d5	\N	15d09802359aa2fbd4366507c3863eeddc9d7a339e7b6f151f2d27bce9990ac0	system	test	0001	test	\N	\N	\N	2025-01-08 08:49:49.860418-05	admin	2025-09-16 11:54:27.168165-04	system
yspark	JW000016	\N	3e8616e4fd7c19f44df35e59738a16fa	\N	8404581b6d3365c41720257aa4f0e230f70034523282b9145e684e9b7f5e934d	10	17	0001	\N	\N	\N	\N	2025-09-16 01:52:04.462496-04	system	2025-09-16 11:57:26.072379-04	system
yjwon	JW000016	\N	d2a0891013d409a40f66bf5c23ac662f	\N	df4fcc8eba68ee60f11b5f795b28d32a7a1172e31a394d994bde41ecf8f3dffe	10	17	0001	\N	\N	\N	\N	2025-09-16 03:52:26.614367-04	system	2025-09-16 11:57:26.072379-04	system
hjlim	JW000018	\N	0ac6f2b0ac093001c382a05646e28ccb	\N	b09ebae30f3a3c1ab1d61b09eab19a963a7e2e41cadaa3f038679e5628fd2d02	10	17	0001	\N	\N	\N	\N	2025-09-16 03:52:56.865717-04	system	2025-09-16 11:58:49.421945-04	system
sckang	JW000015	\N	f6d5e44bb2246f682e877262e810869b	\N	4af7ce06849f9d37fe26eb7e95cdafe2e5ababc7abc0ff89ca5e46d40b338e95	3	7	0001	\N	\N	\N	\N	2025-09-16 01:35:36.490826-04	system	2025-09-16 12:00:21.821466-04	system
jskim	JW000015	\N	99cbcba07a46b03052e2a4a51ed03b3d	\N	8c84711630617793cff672143d597fc20f03df939a2ec6c8060e4c0034c30ac7	4	7	0001	\N	\N	\N	\N	2025-09-16 01:36:22.379989-04	system	2025-09-16 12:00:21.821466-04	system
jwlee	JW000015	\N	1e0f53926de43a808b527eb1333497ad	\N	aea3034ecf782dbe95007046fed74aa32422abde2dc311d6c9a43643dff41b74	5	7	0001	\N	\N	\N	\N	2025-09-16 01:37:48.915683-04	system	2025-09-16 12:00:21.821466-04	system
khlee	JW000015	\N	551d8167125b442e69f9d9bcad472262	\N	448608dcd099a8ff96d5d55e1f6262055452164d7c147a6be14b275c13e02829	5	7	0001	\N	\N	\N	\N	2025-09-16 01:37:13.526978-04	system	2025-09-16 12:00:21.821466-04	system
hckwak	JW000021	\N	c8da534cc3a85af6df00d1f4fbce69b9	\N	5ddded432a83dfbd9bb057bf261b715ec46f0af3ae16c3fe1d2f8e040b3055a9	8	10	0001	\N	\N	\N	\N	2025-09-17 22:59:23.955282-04	system	\N	\N
daenahn	JW000021	\N	d734d002d93135a996cdd3151230ec65	\N	25eb66ef7d8ce3dbba6379f88a80edb7de903391cdb6a05be1422610da9ace84	10	17	0001	\N	\N	\N	\N	2025-09-17 23:23:18.614704-04	system	2025-09-18 00:54:46.138117-04	hckwak
\.


--
-- Data for Name: user_master; Type: TABLE DATA; Schema: lock_manager; Owner: lms_admin
--

COPY lock_manager.user_master (user_id, password, first_nm, last_nm, user_nm, language, role_id, is_active, init_passwd, modified_password_at, valid_from, valid_to, created_at, created_by, updated_at, updated_by) FROM stdin;
system	$2a$10$.sS9okX3qX/IytLg.KVYBOnwgvBBDe/8/f2V5ONxjl5tpEoEr05Vq	system	system	시스템관리자	KO	role_20241211_001	t	f	\N	2025-01-03	2026-01-31	2025-01-03 09:12:42.574-05	system	\N	\N
yskim	$2a$10$tdkNOutcCGexLFdmLEBl..o5S.GWLZHbzr6O3TLZLS4/muNZNUPT2	연수	김	김연수	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:23:54.497825-04	system	\N	\N
jijeon	$2a$10$/g20QFW4ayVZMOolVf4iqu6TJI6d5kD/urAthbkCp4hs/vMl9c9KS	지인	전	전지인	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:53:28.19064-04	system	2025-09-18 04:51:37.766399-04	system
smwoo	$2a$10$tF04JI8XgEvNsURQdhNyh./exoZtNK2JxqQrYcNfrlU2WYsT6udfy	선미	우	우 선미	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:27:55.727374-04	system	\N	\N
gtkim	$2a$10$Hpqekh5svy4g9R0AbrSgSuZXBBYxcAFZMyIIWSNRLPpqZ0XzjEgaq	건태	김	김건태	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:30:35.159841-04	system	\N	\N
jychoi	$2a$10$DIN3G3.LM8hsGH0dCwOdYOvcNwIQP8muMxbQMRlwYU.B8WGmMECOS	진영	최	최진영	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:33:00.417976-04	system	\N	\N
wksong	$2a$10$49dXm6SuovXrnDDpg.9UvOUCNtipV16cLrIczKCR7BNd0W9o1sA0.	원규	송	송원규	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:32:19.968617-04	system	2025-09-16 01:33:08.84829-04	system
sckang	$2a$10$DUEJ6trPb1cE/.uawMVSQuMGWeZdbrlTLUVWDE4rim1jfwO37ESAa	선철	강	강선철	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:35:36.490826-04	system	\N	\N
jskim	$2a$10$FoSZ9RqQk4NpSWMCjrj8E.FBfMD0xiMQ/Dx/xZ/Ukg3/lG7vTusja	종상	김	김종상	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:36:22.379989-04	system	\N	\N
jwlee	$2a$10$KF74UormZEMb6HZ1hvXtl.Pw1z.JXP7Oq5/SHSLC.BZhpNfjdDlfS	종원	이	이종원	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:37:48.915683-04	system	\N	\N
jplee	$2a$10$29m158np0AAaOqTgELrMNOFrYzv73kwK7LezkiARwEPmbykiTWBC.	종필	이	이종필	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:38:46.17838-04	system	\N	\N
cmkim	$2a$10$vfeAKnIGd8MSS6XsTUR7juxE8v5vXg.2TkX7J7c9yCIMUY5XjXk72	철민	김	김철민	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:40:32.186021-04	system	\N	\N
chyou	$2a$10$s23G2PYkCTVyvNxnZYqpIOoDfup3GlJKOJ9hvFMkBgcBtpG7iO43G	창훈	유	유창훈	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:40:58.782938-04	system	\N	\N
shjung	$2a$10$c.6PIu3uQYd7IhYDrAKuk.lLJA.ze3qFVOTQj97cDW7kxIsQmCGgy	성호	정	정성호	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:41:26.714221-04	system	\N	\N
zschoi	$2a$10$BAcS5NeBScwgL8Iltsbvc.tPs9pSIfgxgJ18i.mWK0VcncJxFkd22	진수	최	최진수	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:41:59.696563-04	system	\N	\N
gtgu	$2a$10$G.8Vrkq2yoEXBB92UDVnoeVFrEUyHODzckqOR1zpCAAG0wiXPTJQW	기탁	구	구기탁	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:42:34.269753-04	system	\N	\N
gwseo	$2a$10$dtnIKWi0X/9RDVQDVD4e8OYu6TDIiNGIrnf9aufTiAzk4ctBae1e.	경원	서	서경원	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:43:04.114132-04	system	\N	\N
jjoh	$2a$10$Z3P1evc1aW50X6qqwNdFN.qIiPbdiQU2R4hjO9sPU7qayXCx7Ux16	재준	오	오재준	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:43:45.750142-04	system	\N	\N
jmlim	$2a$10$5.GcJc5xhC9idxl6xb7Ah.iIyVJI7/end52OwngQewxuB10pND4L.	재민	임	임재민	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:44:29.614026-04	system	\N	\N
srmkim	$2a$10$3v0ZH/otIw4a9SLVM0pUXOJmRyh2tYoZR9ROOCXDdG2ClqYJiTr3e	새롬미	김	김새롬미	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:50:50.374824-04	system	\N	\N
khlee	$2a$10$ADFt1.T257WQie6aHt4P3.krEAfjaQJrrOGZ7p9ZuXHgExO1k6//O	경훈	이	이경훈	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:37:13.526978-04	system	2025-09-16 01:51:03.85105-04	system
jhno	$2a$10$mtTlMcqrNky5aoYQSBYMH.WIHEx8dqWMHySekeOhvCQ6QPBD6.oUu	지현	노	노지현	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:51:36.860618-04	system	\N	\N
yspark	$2a$10$vuo1tdkfm1znXfndsshf3eiIwwoHyidW4CuzWnQBzNnUSv8m/ipTS	양수	박	박양수	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:52:04.462496-04	system	\N	\N
jhbang	$2a$10$XHH1WM05hSZmZuy9uhvr8ON8TqYresTQLOP.EWQJtnNVJcmpI/lGi	준호	방	방준호	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 01:24:51.507404-04	system	2025-09-16 01:52:17.177223-04	system
jbson	$2a$10$fGpzrjXkDAyUqHLr129CsOK.Htk8u399XL3CAhSALM8G.QXE0gS3W	준범	손	손준범	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:51:51.568418-04	system	\N	\N
yjwon	$2a$10$5SYDJIiphPM/37C97q85SeDt2RaVZ.9xTjn4Cdv3FZssS57BWq4KK	유진	원	원유진	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:52:26.614367-04	system	\N	\N
hjlim	$2a$10$oujGTuIMbQl7HsfWbt8Rp.9JX4Uxz7ZiRhXJL6XU87yR.KEE6Dljq	효진	임	임효진	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:52:56.865717-04	system	\N	\N
dhjo	$2a$10$kFGy4EIx.psnGDlIVClyLeq0PVGz4wMzMZp1GTYXXOqWTB7LSZoJW	동현	조	조동현	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:54:00.252867-04	system	\N	\N
ihchoi	$2a$10$Wzg.VHts3ZqFhso/SKjSXe50.7kcE680kpBB9azE9zsaWcukorqZ6	인혁	최	최인혁	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:54:27.730955-04	system	\N	\N
cwsong	$2a$10$qRE4ZRb8gEkMOCdqQbvhL.LFeMcEl8ZGArq5tnmBEqL2e.7ZOuCTi	찬우	송	송찬우	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:54:53.093529-04	system	\N	\N
khlee2	$2a$10$ZRBmF2SoC58X2NhrNoMYqe.3gHZvMiRjXBIt3RdKyQFP5C7sBXdnW	경형	이	이경형	KO	role_20241211_001	t	t	\N	2025-09-16	2026-09-16	2025-09-16 03:55:21.176564-04	system	\N	\N
hckwak	$2a$10$sUEp2IKyl0C.MPgxUxOC2OrZMd8jvzN5TcxPCVbCVN9q0KP/mtk2G	현철	곽	곽현철	KO	role_20241211_002	t	f	2025-09-17 23:23:47.354335-04	2025-09-18	2026-09-18	2025-09-17 22:59:23.955282-04	system	\N	\N
daenahn	$2a$10$RQkBlk0G4ISKL8o2.CjC4u3D6Cx9v227tzATTisyG4E8aNKV65Cvu	다은	안	안다은	KO	role_20241211_002	f	f	\N	2025-09-18	2026-09-18	2025-09-17 23:23:18.614704-04	system	2025-09-18 00:54:46.138117-04	hckwak
\.


--
-- Data for Name: code_sequences; Type: TABLE DATA; Schema: public; Owner: lms_admin
--

COPY public.code_sequences (composite_key, last_value) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: communication_logs_log_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.communication_logs_log_id_seq', 109, true);


--
-- Name: customer_gen_history_history_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.customer_gen_history_history_id_seq', 1, false);


--
-- Name: lock_customer_history_history_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.lock_customer_history_history_id_seq', 1, false);


--
-- Name: lock_identity_history_history_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.lock_identity_history_history_id_seq', 1, false);


--
-- Name: lock_model_mgmt_model_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.lock_model_mgmt_model_id_seq', 9, true);


--
-- Name: lock_settings_history_history_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.lock_settings_history_history_id_seq', 1, false);


--
-- Name: notice_mgmt_notice_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.notice_mgmt_notice_id_seq', 2, true);


--
-- Name: notice_read_history_notice_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.notice_read_history_notice_id_seq', 1, false);


--
-- Name: product_mgmt_product_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.product_mgmt_product_id_seq', 17, true);


--
-- Name: sequence_history_history_id_seq; Type: SEQUENCE SET; Schema: lock_manager; Owner: lms_admin
--

SELECT pg_catalog.setval('lock_manager.sequence_history_history_id_seq', 29, true);


--
-- Name: seq_access_id; Type: SEQUENCE SET; Schema: public; Owner: lms_admin
--

SELECT pg_catalog.setval('public.seq_access_id', 1779, true);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: access_log access_log_pk; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.access_log
    ADD CONSTRAINT access_log_pk PRIMARY KEY (log_id);


--
-- Name: common_code_mgmt common_code_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.common_code_mgmt
    ADD CONSTRAINT common_code_mgmt_pkey PRIMARY KEY (code_type, code1, code2, code3);


--
-- Name: communication_logs communication_logs_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.communication_logs
    ADD CONSTRAINT communication_logs_pkey PRIMARY KEY (log_id);


--
-- Name: customer_base customer_base_admin_pw_key; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_base
    ADD CONSTRAINT customer_base_admin_pw_key UNIQUE (admin_pw);


--
-- Name: customer_base customer_base_co_unique_id_key; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_base
    ADD CONSTRAINT customer_base_co_unique_id_key UNIQUE (co_unique_id);


--
-- Name: customer_base customer_base_master_key_key; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_base
    ADD CONSTRAINT customer_base_master_key_key UNIQUE (master_key);


--
-- Name: customer_base customer_base_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_base
    ADD CONSTRAINT customer_base_pkey PRIMARY KEY (customer_id);


--
-- Name: customer_gen_history customer_gen_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.customer_gen_history
    ADD CONSTRAINT customer_gen_history_pkey PRIMARY KEY (history_id);


--
-- Name: jwt_mgmt jwt_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.jwt_mgmt
    ADD CONSTRAINT jwt_mgmt_pkey PRIMARY KEY (user_id);


--
-- Name: lock_customer_history lock_customer_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_customer_history
    ADD CONSTRAINT lock_customer_history_pkey PRIMARY KEY (history_id);


--
-- Name: lock_identity_history lock_identity_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_identity_history
    ADD CONSTRAINT lock_identity_history_pkey PRIMARY KEY (history_id);


--
-- Name: lock_model_mgmt lock_model_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_model_mgmt
    ADD CONSTRAINT lock_model_mgmt_pkey PRIMARY KEY (model_id);


--
-- Name: lock_settings_history lock_settings_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.lock_settings_history
    ADD CONSTRAINT lock_settings_history_pkey PRIMARY KEY (history_id);


--
-- Name: menu_mgmt menu_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.menu_mgmt
    ADD CONSTRAINT menu_mgmt_pkey PRIMARY KEY (menu_id);


--
-- Name: notice_mgmt notice_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.notice_mgmt
    ADD CONSTRAINT notice_mgmt_pkey PRIMARY KEY (notice_id);


--
-- Name: notice_read_history notice_read_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.notice_read_history
    ADD CONSTRAINT notice_read_history_pkey PRIMARY KEY (notice_id, user_id);


--
-- Name: organization_mgmt organization_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.organization_mgmt
    ADD CONSTRAINT organization_mgmt_pkey PRIMARY KEY (org_id);


--
-- Name: product_info product_info_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.product_info
    ADD CONSTRAINT product_info_pkey PRIMARY KEY (product_id);


--
-- Name: product_mgmt product_mgmt_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.product_mgmt
    ADD CONSTRAINT product_mgmt_pkey PRIMARY KEY (product_id);


--
-- Name: role_information role_information_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.role_information
    ADD CONSTRAINT role_information_pkey PRIMARY KEY (role_id);


--
-- Name: role_menu_map role_menu_map_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.role_menu_map
    ADD CONSTRAINT role_menu_map_pkey PRIMARY KEY (role_id, menu_id);


--
-- Name: sequence_history sequence_history_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.sequence_history
    ADD CONSTRAINT sequence_history_pkey PRIMARY KEY (history_id);


--
-- Name: sequence_mgmt sequence_mgmt_pkey1; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.sequence_mgmt
    ADD CONSTRAINT sequence_mgmt_pkey1 PRIMARY KEY (sequence_type);


--
-- Name: user_information user_information_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.user_information
    ADD CONSTRAINT user_information_pkey PRIMARY KEY (user_id);


--
-- Name: user_master user_master_pkey; Type: CONSTRAINT; Schema: lock_manager; Owner: lms_admin
--

ALTER TABLE ONLY lock_manager.user_master
    ADD CONSTRAINT user_master_pkey PRIMARY KEY (user_id);


--
-- Name: code_sequences code_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: lms_admin
--

ALTER TABLE ONLY public.code_sequences
    ADD CONSTRAINT code_sequences_pkey PRIMARY KEY (composite_key);


--
-- PostgreSQL database dump complete
--

\unrestrict IfdfqH08Iy5YgYGZk1x47OcjDpiPO7poAWuYSoDlELRkVgtlcD8nUTYidBA3kvN

