--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4
-- Dumped by pg_dump version 11.4

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    youtube_id character varying(255),
    difficulty character varying(255),
    cooked_this integer DEFAULT 0,
    yield character varying(255),
    timing text,
    description text,
    activity_order integer,
    published boolean DEFAULT false,
    slug character varying(255),
    transcript text,
    image_id text,
    featured_image_id text,
    activity_type character varying(255),
    last_edited_by_id integer,
    source_activity_id integer,
    source_type integer DEFAULT 0,
    assignment_recipes text,
    published_at timestamp without time zone,
    author_notes text,
    likes_count integer,
    currently_editing_user integer,
    include_in_gallery boolean DEFAULT true,
    creator integer DEFAULT 0,
    premium boolean DEFAULT false,
    summary_tweet character varying(255),
    vimeo_id character varying(255),
    short_description text,
    first_published_at timestamp without time zone,
    studio boolean DEFAULT false,
    byline character varying(255),
    promote_order integer,
    featured_image_tag character varying
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: activity_equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_equipment (
    id integer NOT NULL,
    activity_id integer NOT NULL,
    equipment_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    optional boolean DEFAULT false,
    equipment_order integer
);


--
-- Name: activity_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_equipment_id_seq OWNED BY public.activity_equipment.id;


--
-- Name: activity_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_ingredients (
    id integer NOT NULL,
    activity_id integer NOT NULL,
    ingredient_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit character varying(255),
    quantity numeric,
    ingredient_order integer,
    display_quantity character varying(255),
    note character varying(255)
);


--
-- Name: actor_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actor_addresses (
    id integer NOT NULL,
    actor_type character varying(255) NOT NULL,
    actor_id integer NOT NULL,
    address_id character varying(255),
    client_metadata character varying(255),
    sequence integer DEFAULT 0 NOT NULL,
    ip_address character varying(255),
    status character varying(255) DEFAULT 'something'::character varying,
    issued_at integer,
    expires_at integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unique_key character varying(255)
);


--
-- Name: actor_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actor_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actor_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actor_addresses_id_seq OWNED BY public.actor_addresses.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: advertisements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advertisements (
    id integer NOT NULL,
    image text,
    title text,
    description text,
    button_title text,
    url text,
    campaign text,
    published boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    matchname character varying(255),
    weight integer DEFAULT 100,
    add_referral_code boolean DEFAULT false
);


--
-- Name: advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.advertisements_id_seq OWNED BY public.advertisements.id;


--
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.answers (
    id integer NOT NULL,
    question_id integer NOT NULL,
    user_id integer NOT NULL,
    type character varying(255),
    contents text,
    correct boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.answers_id_seq OWNED BY public.answers.id;


--
-- Name: assemblies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assemblies (
    id integer NOT NULL,
    title character varying(255),
    description text,
    image_id text,
    youtube_id character varying(255),
    assembly_type character varying(255) DEFAULT 'Assembly'::character varying,
    slug character varying(255),
    likes_count integer,
    comments_count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published boolean,
    published_at timestamp without time zone,
    price numeric(8,2),
    badge_id integer,
    show_prereg_page_in_index boolean DEFAULT false,
    short_description text,
    upload_copy text,
    buy_box_extra_bullets text,
    preview_copy text,
    testimonial_copy text,
    prereg_image_id text,
    prereg_email_list_id character varying(255),
    description_alt text,
    vimeo_id character varying(255),
    premium boolean DEFAULT false
);


--
-- Name: assemblies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assemblies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assemblies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assemblies_id_seq OWNED BY public.assemblies.id;


--
-- Name: assembly_inclusions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assembly_inclusions (
    id integer NOT NULL,
    includable_type character varying(255),
    includable_id integer,
    assembly_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    include_disqus boolean DEFAULT true
);


--
-- Name: assembly_inclusions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assembly_inclusions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assembly_inclusions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assembly_inclusions_id_seq OWNED BY public.assembly_inclusions.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id integer NOT NULL,
    activity_id integer,
    child_activity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255),
    description text,
    slug character varying(255)
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: badges_sashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges_sashes (
    id integer NOT NULL,
    badge_id integer,
    sash_id integer,
    notified_user boolean DEFAULT false,
    created_at timestamp without time zone
);


--
-- Name: badges_sashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badges_sashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_sashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badges_sashes_id_seq OWNED BY public.badges_sashes.id;


--
-- Name: box_sort_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.box_sort_images (
    id integer NOT NULL,
    question_id integer NOT NULL,
    key_image boolean DEFAULT false,
    key_explanation text DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_order integer
);


--
-- Name: box_sort_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.box_sort_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: box_sort_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.box_sort_images_id_seq OWNED BY public.box_sort_images.id;


--
-- Name: chargebee_gift_redemptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chargebee_gift_redemptions (
    id integer NOT NULL,
    gift_id character varying(255),
    complete boolean DEFAULT false,
    user_id integer,
    plan_amount integer,
    currency_code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chargebee_gift_redemptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chargebee_gift_redemptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chargebee_gift_redemptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chargebee_gift_redemptions_id_seq OWNED BY public.chargebee_gift_redemptions.id;


--
-- Name: circulator_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circulator_users (
    id integer NOT NULL,
    user_id integer,
    circulator_id integer,
    owner boolean,
    deleted_at timestamp without time zone
);


--
-- Name: circulator_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.circulator_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: circulator_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.circulator_users_id_seq OWNED BY public.circulator_users.id;


--
-- Name: circulators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circulators (
    id integer NOT NULL,
    serial_number character varying(255),
    notes character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    circulator_id character varying(255) NOT NULL,
    encrypted_secret_key character varying(64),
    name character varying(255),
    last_accessed_at timestamp without time zone,
    deleted_at timestamp without time zone,
    hardware_options integer,
    hardware_version character varying(255),
    build_date integer,
    model_number character varying(255),
    pcba_revision character varying(255),
    athena_sync_at timestamp without time zone
);


--
-- Name: circulators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.circulators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: circulators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.circulators_id_seq OWNED BY public.circulators.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    user_id integer,
    content text,
    commentable_id integer,
    commentable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rating integer
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: components; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.components (
    id integer NOT NULL,
    name character varying(255),
    slug character varying(255),
    component_type character varying(255),
    meta public.hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    component_parent_type character varying(255),
    component_parent_id integer,
    "position" integer
);


--
-- Name: components_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.components_id_seq OWNED BY public.components.id;


--
-- Name: copies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.copies (
    id integer NOT NULL,
    location character varying(255),
    copy text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: copies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.copies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.copies_id_seq OWNED BY public.copies.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id integer NOT NULL,
    title character varying(255),
    slug character varying(255),
    description text,
    published boolean DEFAULT false,
    course_order numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    short_description character varying(255),
    image_id text,
    additional_script text,
    youtube_id character varying(255)
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;


--
-- Name: embed_pdfs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.embed_pdfs (
    id bigint NOT NULL,
    title character varying,
    image_id text,
    image_alt character varying,
    image_longdesc text,
    pdf_id character varying,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: embed_pdfs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.embed_pdfs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: embed_pdfs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.embed_pdfs_id_seq OWNED BY public.embed_pdfs.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    user_id integer,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enrollable_id integer,
    enrollable_type character varying(255),
    price numeric(8,2) DEFAULT 0,
    sales_tax numeric(8,2) DEFAULT 0,
    gift_certificate_id integer,
    trial_expires_at timestamp without time zone
);


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipment (
    id integer NOT NULL,
    title character varying(255),
    product_url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.equipment_id_seq OWNED BY public.equipment.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    user_id integer,
    action character varying(255),
    trackable_id integer,
    trackable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    viewed boolean DEFAULT false,
    group_type character varying(255),
    group_name text,
    published boolean DEFAULT false
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: followerships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.followerships (
    id integer NOT NULL,
    user_id integer,
    follower_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: followerships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.followerships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: followerships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.followerships_id_seq OWNED BY public.followerships.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(40),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: gift_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gift_certificates (
    id integer NOT NULL,
    purchaser_id integer,
    recipient_email character varying(255) DEFAULT ''::character varying NOT NULL,
    recipient_name character varying(255) DEFAULT ''::character varying NOT NULL,
    recipient_message text DEFAULT ''::text,
    assembly_id integer,
    price numeric(8,2) DEFAULT 0,
    sales_tax numeric(8,2) DEFAULT 0,
    token character varying(255),
    redeemed boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    followed_up boolean DEFAULT false,
    email_to_recipient boolean
);


--
-- Name: gift_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gift_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gift_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gift_certificates_id_seq OWNED BY public.gift_certificates.id;


--
-- Name: guide_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guide_activities (
    id integer NOT NULL,
    guide_id character varying(255),
    guide_title character varying(255),
    activity_id integer,
    guide_digest character varying(255),
    autoupdate boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: guide_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guide_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guide_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guide_activities_id_seq OWNED BY public.guide_activities.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.images (
    id integer NOT NULL,
    filename character varying(255),
    url character varying(255),
    caption character varying(255),
    imageable_id integer,
    imageable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: inclusions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inclusions (
    id integer NOT NULL,
    course_id integer,
    activity_id integer,
    activity_order numeric,
    nesting_level integer DEFAULT 1,
    title character varying(255)
);


--
-- Name: inclusions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inclusions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inclusions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inclusions_id_seq OWNED BY public.inclusions.id;


--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingredients (
    id integer NOT NULL,
    title character varying(255),
    product_url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    for_sale boolean DEFAULT false,
    sub_activity_id integer,
    density numeric,
    slug character varying(255),
    image_id text,
    youtube_id character varying(255),
    text_fields text,
    comments_count integer DEFAULT 0,
    vimeo_id character varying(255)
);


--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;


--
-- Name: joule_cook_history_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.joule_cook_history_items (
    id integer NOT NULL,
    user_id integer,
    idempotency_id character varying(255),
    start_time character varying(255),
    started_from character varying(255),
    deleted_at timestamp without time zone,
    guide_id character varying(255),
    cook_id character varying(255),
    timer_id character varying(255),
    program_id character varying(255),
    program_type character varying(255),
    set_point double precision,
    cook_time integer,
    cook_history_item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    turbo_cook_state character varying(255)
);


--
-- Name: joule_cook_history_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.joule_cook_history_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: joule_cook_history_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.joule_cook_history_items_id_seq OWNED BY public.joule_cook_history_items.id;


--
-- Name: joule_ready_guide_skus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.joule_ready_guide_skus (
    guide_id character varying(255),
    sku character varying(255),
    name character varying(255)
);


--
-- Name: joule_ready_surveys_sent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.joule_ready_surveys_sent (
    program_id character varying(255),
    user_id integer,
    name character varying(255),
    email character varying(255),
    guide_id character varying(255),
    cook_id character varying(255),
    sku character varying(255),
    collector_url character varying(255),
    email_sent_at timestamp without time zone
);


--
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.likes (
    id integer NOT NULL,
    user_id integer,
    likeable_id integer,
    likeable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.likes_id_seq OWNED BY public.likes.id;


--
-- Name: marketplace_guides; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_guides (
    id integer NOT NULL,
    guide_id character varying(255),
    url character varying(255),
    button_text character varying(255),
    button_text_line_2 character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feature_name character varying(255)
);


--
-- Name: marketplace_guides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketplace_guides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketplace_guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketplace_guides_id_seq OWNED BY public.marketplace_guides.id;


--
-- Name: menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menus (
    id bigint NOT NULL,
    name character varying,
    url character varying,
    parent_id integer,
    is_studio boolean DEFAULT false,
    is_premium boolean DEFAULT false,
    is_free boolean DEFAULT false,
    is_not_logged boolean DEFAULT false,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;


--
-- Name: merit_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merit_actions (
    id integer NOT NULL,
    user_id integer,
    action_method character varying(255),
    action_value integer,
    had_errors boolean DEFAULT false,
    target_model character varying(255),
    target_id integer,
    processed boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: merit_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merit_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merit_actions_id_seq OWNED BY public.merit_actions.id;


--
-- Name: merit_activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merit_activity_logs (
    id integer NOT NULL,
    action_id integer,
    related_change_type character varying(255),
    related_change_id integer,
    description character varying(255),
    created_at timestamp without time zone
);


--
-- Name: merit_activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merit_activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merit_activity_logs_id_seq OWNED BY public.merit_activity_logs.id;


--
-- Name: merit_score_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merit_score_points (
    id integer NOT NULL,
    score_id integer,
    num_points integer DEFAULT 0,
    log character varying(255),
    created_at timestamp without time zone
);


--
-- Name: merit_score_points_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merit_score_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_score_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merit_score_points_id_seq OWNED BY public.merit_score_points.id;


--
-- Name: merit_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merit_scores (
    id integer NOT NULL,
    sash_id integer,
    category character varying(255) DEFAULT 'default'::character varying
);


--
-- Name: merit_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merit_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merit_scores_id_seq OWNED BY public.merit_scores.id;


--
-- Name: oauth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_tokens (
    id integer NOT NULL,
    user_id integer,
    service character varying(255),
    token character varying(255),
    refresh_token character varying(255),
    token_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_tokens_id_seq OWNED BY public.oauth_tokens.id;


--
-- Name: order_sort_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_sort_images (
    id integer NOT NULL,
    question_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: order_sort_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_sort_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_sort_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_sort_images_id_seq OWNED BY public.order_sort_images.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id integer NOT NULL,
    title character varying(255),
    content text,
    slug character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    likes_count integer,
    image_id text,
    primary_path character varying(255),
    short_description text,
    show_footer boolean DEFAULT false,
    published boolean DEFAULT false,
    is_promotion boolean,
    discount_id character varying(255),
    redirect_path character varying(255)
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_id integer,
    searchable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: poll_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poll_items (
    id integer NOT NULL,
    title character varying(255),
    description text,
    status character varying(255),
    poll_id integer,
    votes_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    comments_count integer DEFAULT 0
);


--
-- Name: poll_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_items_id_seq OWNED BY public.poll_items.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.polls (
    id integer NOT NULL,
    title character varying(255),
    description text,
    slug character varying(255),
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_id text,
    closed_at timestamp without time zone
);


--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.polls_id_seq OWNED BY public.polls.id;


--
-- Name: premium_gift_certificate_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.premium_gift_certificate_groups (
    id bigint NOT NULL,
    title character varying NOT NULL,
    coupon_count integer NOT NULL,
    created_by_id integer NOT NULL,
    coupon_creation_status boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: premium_gift_certificate_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.premium_gift_certificate_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: premium_gift_certificate_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.premium_gift_certificate_groups_id_seq OWNED BY public.premium_gift_certificate_groups.id;


--
-- Name: premium_gift_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.premium_gift_certificates (
    id integer NOT NULL,
    purchaser_id integer,
    price numeric(8,2) DEFAULT 0,
    sales_tax numeric(8,2) DEFAULT 0,
    token character varying(255),
    redeemed boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    premium_gift_certificate_group_id integer
);


--
-- Name: premium_gift_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.premium_gift_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: premium_gift_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.premium_gift_certificates_id_seq OWNED BY public.premium_gift_certificates.id;


--
-- Name: private_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.private_tokens (
    id integer NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: private_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.private_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: private_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.private_tokens_id_seq OWNED BY public.private_tokens.id;


--
-- Name: publishing_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishing_schedules (
    id integer NOT NULL,
    activity_id integer,
    publish_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT false
);


--
-- Name: publishing_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publishing_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publishing_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publishing_schedules_id_seq OWNED BY public.publishing_schedules.id;


--
-- Name: push_notification_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_notification_tokens (
    id integer NOT NULL,
    actor_address_id integer,
    endpoint_arn character varying(255),
    device_token character varying(255),
    app_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: push_notification_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.push_notification_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_notification_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.push_notification_tokens_id_seq OWNED BY public.push_notification_tokens.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    quiz_id integer,
    type character varying(255),
    contents text DEFAULT ''::text,
    question_order integer,
    answer_count integer DEFAULT 0,
    correct_answer_count integer DEFAULT 0,
    incorrect_answer_count integer DEFAULT 0
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: quiz_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    quiz_id integer NOT NULL,
    completed boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quiz_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quiz_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quiz_sessions_id_seq OWNED BY public.quiz_sessions.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quizzes (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activity_id integer,
    slug character varying(255),
    start_copy text,
    end_copy text,
    published boolean DEFAULT false
);


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quizzes_id_seq OWNED BY public.quizzes.id;


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recipe_ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.activity_ingredients.id;


--
-- Name: revision_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revision_records (
    id integer NOT NULL,
    revisionable_type character varying(100) NOT NULL,
    revisionable_id integer NOT NULL,
    revision integer NOT NULL,
    data bytea,
    created_at timestamp without time zone NOT NULL,
    trash boolean DEFAULT false
);


--
-- Name: revision_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.revision_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: revision_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.revision_records_id_seq OWNED BY public.revision_records.id;


--
-- Name: sashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sashes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sashes_id_seq OWNED BY public.sashes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    footer_image character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    featured_activity_1_id integer,
    featured_activity_2_id integer,
    featured_activity_3_id integer,
    global_message text,
    global_message_active boolean DEFAULT false,
    forum_maintenance boolean,
    hero_cms_title character varying(255) DEFAULT ''::character varying,
    hero_cms_image text DEFAULT ''::text,
    hero_cms_description text DEFAULT ''::text,
    hero_cms_button_text character varying(255) DEFAULT ''::character varying,
    hero_cms_url character varying(255) DEFAULT ''::character varying,
    premium_membership_price numeric(8,2)
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: spree_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spree_orders (
    id integer,
    number character varying,
    item_total numeric,
    total numeric,
    state character varying,
    adjustment_total numeric,
    user_id integer,
    completed_at timestamp without time zone,
    bill_address_id integer,
    ship_address_id integer,
    payment_total numeric,
    shipment_state character varying,
    payment_state character varying,
    email character varying,
    special_instructions character varying(65535),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    currency character varying,
    last_ip_address character varying,
    created_by_id integer,
    shipment_total numeric,
    additional_tax_total numeric,
    promo_total numeric,
    channel character varying,
    included_tax_total numeric,
    item_count integer,
    approver_id integer,
    approved_at timestamp without time zone,
    confirmation_delivered boolean,
    considered_risky boolean,
    guest_token character varying,
    canceled_at timestamp without time zone,
    canceler_id integer,
    store_id integer,
    state_lock_version integer,
    taxable_adjustment_total numeric,
    non_taxable_adjustment_total numeric,
    fulfillment_state character varying,
    guest_checkout boolean,
    is_gift boolean,
    utm_campaign character varying,
    utm_source character varying,
    utm_medium character varying,
    utm_term character varying,
    utm_content character varying,
    abandoned_checkout_email_sent_at timestamp without time zone,
    chefsteps_user_id integer,
    exported_drop_ship_at timestamp without time zone,
    import_source character varying,
    fulfillment_responsibility character varying,
    email_responsibility character varying,
    shipping_hold boolean,
    signifyd_case_id integer,
    ship_hold_applied_by character varying,
    ship_hold_applied_at timestamp without time zone,
    geo_cookie_json character varying(65535),
    cancellation_reason character varying
);


--
-- Name: step_ingredients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.step_ingredients (
    id integer NOT NULL,
    step_id integer NOT NULL,
    ingredient_id integer NOT NULL,
    quantity numeric,
    unit character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ingredient_order integer,
    display_quantity character varying(255),
    note character varying(255)
);


--
-- Name: step_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.step_ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: step_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.step_ingredients_id_seq OWNED BY public.step_ingredients.id;


--
-- Name: steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.steps (
    id integer NOT NULL,
    title text,
    activity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    youtube_id character varying(255),
    step_order integer,
    directions text,
    image_id text,
    transcript text,
    image_description character varying(255),
    subrecipe_title character varying(255),
    audio_clip character varying(255),
    audio_title character varying(255),
    hide_number boolean,
    is_aside boolean,
    presentation_hints text DEFAULT '{}'::text,
    extra text,
    vimeo_id character varying(255),
    appliance_instruction_text text,
    appliance_instruction_image text,
    appliance_instruction_image_type integer DEFAULT 0,
    appliance_instruction_image_alt text,
    image_alt text
);


--
-- Name: steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.steps_id_seq OWNED BY public.steps.id;


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_events (
    id integer NOT NULL,
    event_id character varying(255),
    object character varying(255),
    api_version character varying(255),
    request_id character varying(255),
    event_type character varying(255),
    created integer,
    event_at timestamp without time zone,
    livemode boolean,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    processed boolean DEFAULT false
);


--
-- Name: stripe_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_events_id_seq OWNED BY public.stripe_events.id;


--
-- Name: stripe_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_orders (
    id integer NOT NULL,
    idempotency_key character varying(255),
    user_id integer,
    data text,
    submitted boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stripe_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stripe_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_orders_id_seq OWNED BY public.stripe_orders.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    user_id integer,
    plan_id character varying(255),
    status character varying(255),
    resource_version bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: suggested_recipes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggested_recipes (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: suggested_recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suggested_recipes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suggested_recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suggested_recipes_id_seq OWNED BY public.suggested_recipes.id;


--
-- Name: suggested_recipes_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggested_recipes_users (
    suggested_recipe_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying(255),
    taggings_count integer DEFAULT 0
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tf2_redemptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tf2_redemptions (
    id integer NOT NULL,
    user_id integer,
    redemption_code character varying(255),
    redeemed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tf2_redemptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tf2_redemptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tf2_redemptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tf2_redemptions_id_seq OWNED BY public.tf2_redemptions.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id integer NOT NULL,
    activity_id integer,
    user_id integer,
    title character varying(255),
    image_id text,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    course_id integer,
    approved boolean DEFAULT false,
    likes_count integer,
    slug character varying(255),
    comments_count integer DEFAULT 0,
    assembly_id integer
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: user_acquisitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_acquisitions (
    id integer NOT NULL,
    user_id integer,
    signup_method character varying(255),
    landing_page text,
    referrer text,
    utm_source character varying(255),
    utm_medium character varying(255),
    utm_campaign character varying(255),
    utm_term character varying(255),
    utm_content character varying(255),
    gclid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_acquisitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_acquisitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_acquisitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_acquisitions_id_seq OWNED BY public.user_acquisitions.id;


--
-- Name: user_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activities (
    id integer NOT NULL,
    user_id integer,
    activity_id integer,
    action character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_activities_id_seq OWNED BY public.user_activities.id;


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_settings (
    id integer NOT NULL,
    user_id integer,
    locale character varying(10),
    country_iso2 character varying(2),
    has_viewed_turbo_intro boolean,
    preferred_temperature_unit character varying(1),
    has_purchased_truffle_sauce boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_settings_id_seq OWNED BY public.user_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    provider character varying(255),
    facebook_user_id character varying(255),
    location character varying(255) DEFAULT ''::character varying,
    website character varying(255) DEFAULT ''::character varying,
    quote text DEFAULT ''::text,
    chef_type character varying(255) DEFAULT ''::character varying NOT NULL,
    slug character varying(255),
    from_aweber boolean,
    viewed_activities text,
    signed_up_from character varying(255),
    image_id text,
    bio text,
    sash_id integer,
    level integer DEFAULT 0,
    role character varying(255),
    stripe_id character varying(255),
    authentication_token character varying(255),
    google_refresh_token character varying(255),
    google_access_token character varying(255),
    google_user_id character varying(255),
    referrer_id integer,
    referred_from character varying(255),
    survey_results public.hstore,
    events_count integer,
    twitter_user_id character varying(255),
    twitter_auth_token character varying(255),
    twitter_user_name character varying(255),
    signup_incentive_available boolean DEFAULT true,
    timf_incentive_available boolean DEFAULT true,
    premium_member boolean DEFAULT false,
    premium_membership_created_at timestamp without time zone,
    premium_membership_price numeric(8,2) DEFAULT 0,
    used_circulator_discount boolean DEFAULT false,
    needs_special_terms boolean DEFAULT false,
    deleted_at timestamp without time zone,
    first_joule_purchased_at timestamp without time zone,
    joule_purchase_count integer DEFAULT 0,
    referral_code character varying(255),
    remember_token character varying,
    apple_user_id character varying,
    opt_in boolean,
    country_code text,
    marketing_mail_status integer DEFAULT 0,
    is_abused boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version character varying(255)
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.videos (
    id integer NOT NULL,
    youtube_id character varying(255),
    title character varying(255),
    description character varying(255),
    featured boolean,
    filmstrip boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_id text
);


--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    user_id integer,
    votable_id integer,
    votable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: activity_equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_equipment ALTER COLUMN id SET DEFAULT nextval('public.activity_equipment_id_seq'::regclass);


--
-- Name: activity_ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- Name: actor_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor_addresses ALTER COLUMN id SET DEFAULT nextval('public.actor_addresses_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: advertisements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisements ALTER COLUMN id SET DEFAULT nextval('public.advertisements_id_seq'::regclass);


--
-- Name: answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers ALTER COLUMN id SET DEFAULT nextval('public.answers_id_seq'::regclass);


--
-- Name: assemblies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assemblies ALTER COLUMN id SET DEFAULT nextval('public.assemblies_id_seq'::regclass);


--
-- Name: assembly_inclusions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assembly_inclusions ALTER COLUMN id SET DEFAULT nextval('public.assembly_inclusions_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: badges_sashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges_sashes ALTER COLUMN id SET DEFAULT nextval('public.badges_sashes_id_seq'::regclass);


--
-- Name: box_sort_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.box_sort_images ALTER COLUMN id SET DEFAULT nextval('public.box_sort_images_id_seq'::regclass);


--
-- Name: chargebee_gift_redemptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chargebee_gift_redemptions ALTER COLUMN id SET DEFAULT nextval('public.chargebee_gift_redemptions_id_seq'::regclass);


--
-- Name: circulator_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circulator_users ALTER COLUMN id SET DEFAULT nextval('public.circulator_users_id_seq'::regclass);


--
-- Name: circulators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circulators ALTER COLUMN id SET DEFAULT nextval('public.circulators_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: components id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.components ALTER COLUMN id SET DEFAULT nextval('public.components_id_seq'::regclass);


--
-- Name: copies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.copies ALTER COLUMN id SET DEFAULT nextval('public.copies_id_seq'::regclass);


--
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);


--
-- Name: embed_pdfs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embed_pdfs ALTER COLUMN id SET DEFAULT nextval('public.embed_pdfs_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: equipment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT nextval('public.equipment_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: followerships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followerships ALTER COLUMN id SET DEFAULT nextval('public.followerships_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: gift_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gift_certificates ALTER COLUMN id SET DEFAULT nextval('public.gift_certificates_id_seq'::regclass);


--
-- Name: guide_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guide_activities ALTER COLUMN id SET DEFAULT nextval('public.guide_activities_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: inclusions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inclusions ALTER COLUMN id SET DEFAULT nextval('public.inclusions_id_seq'::regclass);


--
-- Name: ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);


--
-- Name: joule_cook_history_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joule_cook_history_items ALTER COLUMN id SET DEFAULT nextval('public.joule_cook_history_items_id_seq'::regclass);


--
-- Name: likes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes ALTER COLUMN id SET DEFAULT nextval('public.likes_id_seq'::regclass);


--
-- Name: marketplace_guides id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_guides ALTER COLUMN id SET DEFAULT nextval('public.marketplace_guides_id_seq'::regclass);


--
-- Name: merit_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_actions ALTER COLUMN id SET DEFAULT nextval('public.merit_actions_id_seq'::regclass);


--
-- Name: merit_activity_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_activity_logs ALTER COLUMN id SET DEFAULT nextval('public.merit_activity_logs_id_seq'::regclass);


--
-- Name: merit_score_points id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_score_points ALTER COLUMN id SET DEFAULT nextval('public.merit_score_points_id_seq'::regclass);


--
-- Name: merit_scores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_scores ALTER COLUMN id SET DEFAULT nextval('public.merit_scores_id_seq'::regclass);


--
-- Name: oauth_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_tokens_id_seq'::regclass);


--
-- Name: order_sort_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_sort_images ALTER COLUMN id SET DEFAULT nextval('public.order_sort_images_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: poll_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_items ALTER COLUMN id SET DEFAULT nextval('public.poll_items_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls ALTER COLUMN id SET DEFAULT nextval('public.polls_id_seq'::regclass);


--
-- Name: premium_gift_certificate_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.premium_gift_certificate_groups ALTER COLUMN id SET DEFAULT nextval('public.premium_gift_certificate_groups_id_seq'::regclass);


--
-- Name: premium_gift_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.premium_gift_certificates ALTER COLUMN id SET DEFAULT nextval('public.premium_gift_certificates_id_seq'::regclass);


--
-- Name: private_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_tokens ALTER COLUMN id SET DEFAULT nextval('public.private_tokens_id_seq'::regclass);


--
-- Name: publishing_schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishing_schedules ALTER COLUMN id SET DEFAULT nextval('public.publishing_schedules_id_seq'::regclass);


--
-- Name: push_notification_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_notification_tokens ALTER COLUMN id SET DEFAULT nextval('public.push_notification_tokens_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: quiz_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions ALTER COLUMN id SET DEFAULT nextval('public.quiz_sessions_id_seq'::regclass);


--
-- Name: quizzes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quizzes ALTER COLUMN id SET DEFAULT nextval('public.quizzes_id_seq'::regclass);


--
-- Name: revision_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_records ALTER COLUMN id SET DEFAULT nextval('public.revision_records_id_seq'::regclass);


--
-- Name: sashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sashes ALTER COLUMN id SET DEFAULT nextval('public.sashes_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: step_ingredients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.step_ingredients ALTER COLUMN id SET DEFAULT nextval('public.step_ingredients_id_seq'::regclass);


--
-- Name: steps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.steps ALTER COLUMN id SET DEFAULT nextval('public.steps_id_seq'::regclass);


--
-- Name: stripe_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events ALTER COLUMN id SET DEFAULT nextval('public.stripe_events_id_seq'::regclass);


--
-- Name: stripe_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_orders ALTER COLUMN id SET DEFAULT nextval('public.stripe_orders_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: suggested_recipes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_recipes ALTER COLUMN id SET DEFAULT nextval('public.suggested_recipes_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tf2_redemptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tf2_redemptions ALTER COLUMN id SET DEFAULT nextval('public.tf2_redemptions_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: user_acquisitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_acquisitions ALTER COLUMN id SET DEFAULT nextval('public.user_acquisitions_id_seq'::regclass);


--
-- Name: user_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activities ALTER COLUMN id SET DEFAULT nextval('public.user_activities_id_seq'::regclass);


--
-- Name: user_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings ALTER COLUMN id SET DEFAULT nextval('public.user_settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: activity_equipment activity_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_equipment
    ADD CONSTRAINT activity_equipment_pkey PRIMARY KEY (id);


--
-- Name: activity_ingredients activity_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_ingredients
    ADD CONSTRAINT activity_ingredients_pkey PRIMARY KEY (id);


--
-- Name: actor_addresses actor_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor_addresses
    ADD CONSTRAINT actor_addresses_pkey PRIMARY KEY (id);


--
-- Name: active_admin_comments admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: advertisements advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advertisements
    ADD CONSTRAINT advertisements_pkey PRIMARY KEY (id);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: assemblies assemblies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assemblies
    ADD CONSTRAINT assemblies_pkey PRIMARY KEY (id);


--
-- Name: assembly_inclusions assembly_inclusions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assembly_inclusions
    ADD CONSTRAINT assembly_inclusions_pkey PRIMARY KEY (id);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: badges_sashes badges_sashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges_sashes
    ADD CONSTRAINT badges_sashes_pkey PRIMARY KEY (id);


--
-- Name: box_sort_images box_sort_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.box_sort_images
    ADD CONSTRAINT box_sort_images_pkey PRIMARY KEY (id);


--
-- Name: chargebee_gift_redemptions chargebee_gift_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chargebee_gift_redemptions
    ADD CONSTRAINT chargebee_gift_redemptions_pkey PRIMARY KEY (id);


--
-- Name: circulator_users circulator_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circulator_users
    ADD CONSTRAINT circulator_users_pkey PRIMARY KEY (id);


--
-- Name: circulators circulators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circulators
    ADD CONSTRAINT circulators_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: components components_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_pkey PRIMARY KEY (id);


--
-- Name: copies copies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.copies
    ADD CONSTRAINT copies_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: embed_pdfs embed_pdfs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embed_pdfs
    ADD CONSTRAINT embed_pdfs_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: followerships followerships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followerships
    ADD CONSTRAINT followerships_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: gift_certificates gift_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gift_certificates
    ADD CONSTRAINT gift_certificates_pkey PRIMARY KEY (id);


--
-- Name: guide_activities guide_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guide_activities
    ADD CONSTRAINT guide_activities_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: inclusions inclusions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inclusions
    ADD CONSTRAINT inclusions_pkey PRIMARY KEY (id);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: joule_cook_history_items joule_cook_history_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.joule_cook_history_items
    ADD CONSTRAINT joule_cook_history_items_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: marketplace_guides marketplace_guides_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_guides
    ADD CONSTRAINT marketplace_guides_pkey PRIMARY KEY (id);


--
-- Name: merit_actions merit_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_actions
    ADD CONSTRAINT merit_actions_pkey PRIMARY KEY (id);


--
-- Name: merit_activity_logs merit_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_activity_logs
    ADD CONSTRAINT merit_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: merit_score_points merit_score_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_score_points
    ADD CONSTRAINT merit_score_points_pkey PRIMARY KEY (id);


--
-- Name: merit_scores merit_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merit_scores
    ADD CONSTRAINT merit_scores_pkey PRIMARY KEY (id);


--
-- Name: oauth_tokens oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_tokens
    ADD CONSTRAINT oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: order_sort_images order_sort_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_sort_images
    ADD CONSTRAINT order_sort_images_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: poll_items poll_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_items
    ADD CONSTRAINT poll_items_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: premium_gift_certificate_groups premium_gift_certificate_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.premium_gift_certificate_groups
    ADD CONSTRAINT premium_gift_certificate_groups_pkey PRIMARY KEY (id);


--
-- Name: premium_gift_certificates premium_gift_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.premium_gift_certificates
    ADD CONSTRAINT premium_gift_certificates_pkey PRIMARY KEY (id);


--
-- Name: private_tokens private_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.private_tokens
    ADD CONSTRAINT private_tokens_pkey PRIMARY KEY (id);


--
-- Name: publishing_schedules publishing_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishing_schedules
    ADD CONSTRAINT publishing_schedules_pkey PRIMARY KEY (id);


--
-- Name: push_notification_tokens push_notification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_notification_tokens
    ADD CONSTRAINT push_notification_tokens_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_sessions quiz_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_pkey PRIMARY KEY (id);


--
-- Name: quizzes quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: revision_records revision_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_records
    ADD CONSTRAINT revision_records_pkey PRIMARY KEY (id);


--
-- Name: sashes sashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sashes
    ADD CONSTRAINT sashes_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: step_ingredients step_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.step_ingredients
    ADD CONSTRAINT step_ingredients_pkey PRIMARY KEY (id);


--
-- Name: steps steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.steps
    ADD CONSTRAINT steps_pkey PRIMARY KEY (id);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: stripe_orders stripe_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_orders
    ADD CONSTRAINT stripe_orders_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: suggested_recipes suggested_recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggested_recipes
    ADD CONSTRAINT suggested_recipes_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tf2_redemptions tf2_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tf2_redemptions
    ADD CONSTRAINT tf2_redemptions_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_acquisitions user_acquisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_acquisitions
    ADD CONSTRAINT user_acquisitions_pkey PRIMARY KEY (id);


--
-- Name: user_activities user_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activities
    ADD CONSTRAINT user_activities_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: activity_equipment_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX activity_equipment_index ON public.activity_equipment USING btree (activity_id, equipment_id);


--
-- Name: aindex_endpoint_and_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX aindex_endpoint_and_address ON public.push_notification_tokens USING btree (endpoint_arn, actor_address_id);


--
-- Name: enrollable_user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX enrollable_user_index ON public.enrollments USING btree (enrollable_type, enrollable_id, user_id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_activities_on_activity_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_activity_order ON public.activities USING btree (activity_order);


--
-- Name: index_activities_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_activities_on_slug ON public.activities USING btree (slug);


--
-- Name: index_activity_equipment_on_equipment_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_equipment_on_equipment_order ON public.activity_equipment USING btree (equipment_order);


--
-- Name: index_activity_ingredients_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_ingredients_on_activity_id ON public.activity_ingredients USING btree (activity_id);


--
-- Name: index_activity_ingredients_on_ingredient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_ingredients_on_ingredient_id ON public.activity_ingredients USING btree (ingredient_id);


--
-- Name: index_activity_ingredients_on_ingredient_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_ingredients_on_ingredient_order ON public.activity_ingredients USING btree (ingredient_order);


--
-- Name: index_actor_addresses_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actor_addresses_on_actor_id ON public.actor_addresses USING btree (actor_id);


--
-- Name: index_actor_addresses_on_actor_type_and_actor_id_and_unique_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_actor_addresses_on_actor_type_and_actor_id_and_unique_key ON public.actor_addresses USING btree (actor_type, actor_id, unique_key);


--
-- Name: index_actor_addresses_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actor_addresses_on_address_id ON public.actor_addresses USING btree (address_id);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_answers_on_question_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_answers_on_question_id_and_user_id ON public.answers USING btree (question_id, user_id);


--
-- Name: index_assembly_inclusions_on_assembly_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assembly_inclusions_on_assembly_id ON public.assembly_inclusions USING btree (assembly_id);


--
-- Name: index_assembly_inclusions_on_includable_id_and_includable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assembly_inclusions_on_includable_id_and_includable_type ON public.assembly_inclusions USING btree (includable_id, includable_type);


--
-- Name: index_assignments_on_activity_id_and_child_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_activity_id_and_child_activity_id ON public.assignments USING btree (activity_id, child_activity_id);


--
-- Name: index_badges_sashes_on_badge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_badges_sashes_on_badge_id ON public.badges_sashes USING btree (badge_id);


--
-- Name: index_badges_sashes_on_badge_id_and_sash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_badges_sashes_on_badge_id_and_sash_id ON public.badges_sashes USING btree (badge_id, sash_id);


--
-- Name: index_badges_sashes_on_sash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_badges_sashes_on_sash_id ON public.badges_sashes USING btree (sash_id);


--
-- Name: index_box_sort_images_on_image_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_box_sort_images_on_image_order ON public.box_sort_images USING btree (image_order);


--
-- Name: index_box_sort_images_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_box_sort_images_on_question_id ON public.box_sort_images USING btree (question_id);


--
-- Name: index_chargebee_gift_redemptions_on_complete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chargebee_gift_redemptions_on_complete ON public.chargebee_gift_redemptions USING btree (complete);


--
-- Name: index_chargebee_gift_redemptions_on_gift_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_chargebee_gift_redemptions_on_gift_id ON public.chargebee_gift_redemptions USING btree (gift_id);


--
-- Name: index_circulator_users_on_circulator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_circulator_users_on_circulator_id ON public.circulator_users USING btree (circulator_id);


--
-- Name: index_circulator_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_circulator_users_on_deleted_at ON public.circulator_users USING btree (deleted_at);


--
-- Name: index_circulator_users_on_user_id_and_circulator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_circulator_users_on_user_id_and_circulator_id ON public.circulator_users USING btree (user_id, circulator_id);


--
-- Name: index_circulator_users_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_circulator_users_unique ON public.circulator_users USING btree (user_id, circulator_id, COALESCE(deleted_at, 'infinity'::timestamp without time zone));


--
-- Name: index_circulators_on_circulator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_circulators_on_circulator_id ON public.circulators USING btree (circulator_id, COALESCE(deleted_at, 'infinity'::timestamp without time zone));


--
-- Name: index_circulators_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_circulators_on_deleted_at ON public.circulators USING btree (deleted_at);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON public.comments USING btree (commentable_id, commentable_type);


--
-- Name: index_copies_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_copies_on_location ON public.copies USING btree (location);


--
-- Name: index_embed_pdfs_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_embed_pdfs_on_slug ON public.embed_pdfs USING btree (slug);


--
-- Name: index_events_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_action ON public.events USING btree (action);


--
-- Name: index_events_on_action_and_trackable_type_and_trackable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_action_and_trackable_type_and_trackable_id ON public.events USING btree (action, trackable_type, trackable_id);


--
-- Name: index_events_on_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_group_name ON public.events USING btree (group_name);


--
-- Name: index_events_on_group_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_group_type ON public.events USING btree (group_type);


--
-- Name: index_events_on_trackable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_trackable_type ON public.events USING btree (trackable_type);


--
-- Name: index_events_on_trackable_type_and_trackable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_trackable_type_and_trackable_id ON public.events USING btree (trackable_type, trackable_id);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_user_id ON public.events USING btree (user_id);


--
-- Name: index_followerships_on_follower_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followerships_on_follower_id ON public.followerships USING btree (follower_id);


--
-- Name: index_followerships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followerships_on_user_id ON public.followerships USING btree (user_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_gift_certificates_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gift_certificates_on_token ON public.gift_certificates USING btree (token);


--
-- Name: index_guide_activities_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guide_activities_on_activity_id ON public.guide_activities USING btree (activity_id);


--
-- Name: index_guide_activities_on_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guide_activities_on_guide_id ON public.guide_activities USING btree (guide_id);


--
-- Name: index_inclusions_on_activity_id_and_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inclusions_on_activity_id_and_course_id ON public.inclusions USING btree (activity_id, course_id);


--
-- Name: index_inclusions_on_course_id_and_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inclusions_on_course_id_and_activity_id ON public.inclusions USING btree (course_id, activity_id);


--
-- Name: index_ingredients_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ingredients_on_slug ON public.ingredients USING btree (slug);


--
-- Name: index_joule_cook_history_items_on_cook_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_joule_cook_history_items_on_cook_id ON public.joule_cook_history_items USING btree (cook_id);


--
-- Name: index_joule_cook_history_items_on_user_id_and_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_joule_cook_history_items_on_user_id_and_guide_id ON public.joule_cook_history_items USING btree (user_id, guide_id);


--
-- Name: index_joule_cook_history_items_on_user_id_and_idempotency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_joule_cook_history_items_on_user_id_and_idempotency_id ON public.joule_cook_history_items USING btree (user_id, idempotency_id);


--
-- Name: index_joule_ready_guide_skus_on_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_joule_ready_guide_skus_on_guide_id ON public.joule_ready_guide_skus USING btree (guide_id);


--
-- Name: index_joule_ready_surveys_sent_on_email_and_guide_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_joule_ready_surveys_sent_on_email_and_guide_id ON public.joule_ready_surveys_sent USING btree (email, guide_id);


--
-- Name: index_likes_on_likeable_type_and_likeable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_likes_on_likeable_type_and_likeable_id ON public.likes USING btree (likeable_type, likeable_id);


--
-- Name: index_menus_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menus_on_parent_id ON public.menus USING btree (parent_id);


--
-- Name: index_premium_gift_certificates_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_premium_gift_certificates_on_token ON public.premium_gift_certificates USING btree (token);


--
-- Name: index_premium_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_premium_group_id ON public.premium_gift_certificates USING btree (premium_gift_certificate_group_id);


--
-- Name: index_push_notification_tokens_on_actor_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_push_notification_tokens_on_actor_address_id ON public.push_notification_tokens USING btree (actor_address_id);


--
-- Name: index_questions_on_question_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_question_order ON public.questions USING btree (question_order);


--
-- Name: index_quiz_sessions_on_user_id_and_quiz_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_quiz_sessions_on_user_id_and_quiz_id ON public.quiz_sessions USING btree (user_id, quiz_id);


--
-- Name: index_quizzes_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quizzes_on_activity_id ON public.quizzes USING btree (activity_id);


--
-- Name: index_quizzes_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_quizzes_on_slug ON public.quizzes USING btree (slug);


--
-- Name: index_step_ingredients_on_ingredient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_step_ingredients_on_ingredient_id ON public.step_ingredients USING btree (ingredient_id);


--
-- Name: index_step_ingredients_on_ingredient_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_step_ingredients_on_ingredient_order ON public.step_ingredients USING btree (ingredient_order);


--
-- Name: index_step_ingredients_on_step_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_step_ingredients_on_step_id ON public.step_ingredients USING btree (step_id);


--
-- Name: index_steps_on_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_steps_on_activity_id ON public.steps USING btree (activity_id);


--
-- Name: index_steps_on_step_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_steps_on_step_order ON public.steps USING btree (step_order);


--
-- Name: index_subscriptions_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_plan_id ON public.subscriptions USING btree (plan_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_user_id ON public.subscriptions USING btree (user_id);


--
-- Name: index_subscriptions_on_user_id_and_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_user_id_and_plan_id ON public.subscriptions USING btree (user_id, plan_id);


--
-- Name: index_sug_recipes_users_on_sug_recipe_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sug_recipes_users_on_sug_recipe_id_and_user_id ON public.suggested_recipes_users USING btree (suggested_recipe_id, user_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON public.taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tf2_redemptions_on_redemption_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tf2_redemptions_on_redemption_code ON public.tf2_redemptions USING btree (redemption_code);


--
-- Name: index_user_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_settings_on_user_id ON public.user_settings USING btree (user_id);


--
-- Name: index_users_on_apple_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_apple_user_id ON public.users USING btree (apple_user_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON public.users USING btree (authentication_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_referral_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_referral_code ON public.users USING btree (referral_code);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_slug ON public.users USING btree (slug);


--
-- Name: index_users_on_survey_results; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_survey_results ON public.users USING gist (survey_results);


--
-- Name: index_versions_on_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_version ON public.versions USING btree (version);


--
-- Name: revision_records_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revision_records_id ON public.revision_records USING btree (revisionable_id);


--
-- Name: revision_records_type_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX revision_records_type_and_created_at ON public.revision_records USING btree (revisionable_type, created_at, trash);


--
-- Name: taggings_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX taggings_idx ON public.taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20120906183600');

INSERT INTO schema_migrations (version) VALUES ('20120906183601');

INSERT INTO schema_migrations (version) VALUES ('20120907204320');

INSERT INTO schema_migrations (version) VALUES ('20120907210535');

INSERT INTO schema_migrations (version) VALUES ('20120907211940');

INSERT INTO schema_migrations (version) VALUES ('20120907212347');

INSERT INTO schema_migrations (version) VALUES ('20120908000108');

INSERT INTO schema_migrations (version) VALUES ('20120910171803');

INSERT INTO schema_migrations (version) VALUES ('20120910174915');

INSERT INTO schema_migrations (version) VALUES ('20120910193913');

INSERT INTO schema_migrations (version) VALUES ('20120910200259');

INSERT INTO schema_migrations (version) VALUES ('20120910202332');

INSERT INTO schema_migrations (version) VALUES ('20120910222521');

INSERT INTO schema_migrations (version) VALUES ('20120911170416');

INSERT INTO schema_migrations (version) VALUES ('20120918174110');

INSERT INTO schema_migrations (version) VALUES ('20120918175153');

INSERT INTO schema_migrations (version) VALUES ('20120918180334');

INSERT INTO schema_migrations (version) VALUES ('20120918181437');

INSERT INTO schema_migrations (version) VALUES ('20120918182057');

INSERT INTO schema_migrations (version) VALUES ('20120918200048');

INSERT INTO schema_migrations (version) VALUES ('20120918205119');

INSERT INTO schema_migrations (version) VALUES ('20120918205824');

INSERT INTO schema_migrations (version) VALUES ('20120918210534');

INSERT INTO schema_migrations (version) VALUES ('20120919211822');

INSERT INTO schema_migrations (version) VALUES ('20120919212813');

INSERT INTO schema_migrations (version) VALUES ('20120919214421');

INSERT INTO schema_migrations (version) VALUES ('20120920013144');

INSERT INTO schema_migrations (version) VALUES ('20120920232906');

INSERT INTO schema_migrations (version) VALUES ('20120921175914');

INSERT INTO schema_migrations (version) VALUES ('20120921184813');

INSERT INTO schema_migrations (version) VALUES ('20120921185009');

INSERT INTO schema_migrations (version) VALUES ('20120921194426');

INSERT INTO schema_migrations (version) VALUES ('20120921201328');

INSERT INTO schema_migrations (version) VALUES ('20120921203420');

INSERT INTO schema_migrations (version) VALUES ('20120921223049');

INSERT INTO schema_migrations (version) VALUES ('20120924173630');

INSERT INTO schema_migrations (version) VALUES ('20120925191652');

INSERT INTO schema_migrations (version) VALUES ('20121016170420');

INSERT INTO schema_migrations (version) VALUES ('20121016175145');

INSERT INTO schema_migrations (version) VALUES ('20121016175154');

INSERT INTO schema_migrations (version) VALUES ('20121016175156');

INSERT INTO schema_migrations (version) VALUES ('20121031154704');

INSERT INTO schema_migrations (version) VALUES ('20121101192217');

INSERT INTO schema_migrations (version) VALUES ('20121101192525');

INSERT INTO schema_migrations (version) VALUES ('20121101192906');

INSERT INTO schema_migrations (version) VALUES ('20121102222837');

INSERT INTO schema_migrations (version) VALUES ('20121105174027');

INSERT INTO schema_migrations (version) VALUES ('20121106174642');

INSERT INTO schema_migrations (version) VALUES ('20121107160105');

INSERT INTO schema_migrations (version) VALUES ('20121107174550');

INSERT INTO schema_migrations (version) VALUES ('20121107214910');

INSERT INTO schema_migrations (version) VALUES ('20121108012944');

INSERT INTO schema_migrations (version) VALUES ('20121108182047');

INSERT INTO schema_migrations (version) VALUES ('20121113173813');

INSERT INTO schema_migrations (version) VALUES ('20121113174122');

INSERT INTO schema_migrations (version) VALUES ('20121117005144');

INSERT INTO schema_migrations (version) VALUES ('20121119230540');

INSERT INTO schema_migrations (version) VALUES ('20121119231431');

INSERT INTO schema_migrations (version) VALUES ('20121120010958');

INSERT INTO schema_migrations (version) VALUES ('20121120235025');

INSERT INTO schema_migrations (version) VALUES ('20121120235558');

INSERT INTO schema_migrations (version) VALUES ('20121121000516');

INSERT INTO schema_migrations (version) VALUES ('20121121002129');

INSERT INTO schema_migrations (version) VALUES ('20121121012755');

INSERT INTO schema_migrations (version) VALUES ('20121128002108');

INSERT INTO schema_migrations (version) VALUES ('20121129200836');

INSERT INTO schema_migrations (version) VALUES ('20121130003726');

INSERT INTO schema_migrations (version) VALUES ('20121130174415');

INSERT INTO schema_migrations (version) VALUES ('20121204034228');

INSERT INTO schema_migrations (version) VALUES ('20121204182259');

INSERT INTO schema_migrations (version) VALUES ('20121204200040');

INSERT INTO schema_migrations (version) VALUES ('20121205001009');

INSERT INTO schema_migrations (version) VALUES ('20121206174614');

INSERT INTO schema_migrations (version) VALUES ('20121211054934');

INSERT INTO schema_migrations (version) VALUES ('20121211182921');

INSERT INTO schema_migrations (version) VALUES ('20121211193255');

INSERT INTO schema_migrations (version) VALUES ('20121212214325');

INSERT INTO schema_migrations (version) VALUES ('20121213221618');

INSERT INTO schema_migrations (version) VALUES ('20121214195623');

INSERT INTO schema_migrations (version) VALUES ('20121219174423');

INSERT INTO schema_migrations (version) VALUES ('20121219230839');

INSERT INTO schema_migrations (version) VALUES ('20121227025850');

INSERT INTO schema_migrations (version) VALUES ('20130111211249');

INSERT INTO schema_migrations (version) VALUES ('20130118022653');

INSERT INTO schema_migrations (version) VALUES ('20130119011958');

INSERT INTO schema_migrations (version) VALUES ('20130129040806');

INSERT INTO schema_migrations (version) VALUES ('20130129211056');

INSERT INTO schema_migrations (version) VALUES ('20130130202212');

INSERT INTO schema_migrations (version) VALUES ('20130201024834');

INSERT INTO schema_migrations (version) VALUES ('20130201212635');

INSERT INTO schema_migrations (version) VALUES ('20130202001335');

INSERT INTO schema_migrations (version) VALUES ('20130205201927');

INSERT INTO schema_migrations (version) VALUES ('20130207185212');

INSERT INTO schema_migrations (version) VALUES ('20130213032124');

INSERT INTO schema_migrations (version) VALUES ('20130214180700');

INSERT INTO schema_migrations (version) VALUES ('20130218175151');

INSERT INTO schema_migrations (version) VALUES ('20130222232451');

INSERT INTO schema_migrations (version) VALUES ('20130225200629');

INSERT INTO schema_migrations (version) VALUES ('20130301001135');

INSERT INTO schema_migrations (version) VALUES ('20130301211313');

INSERT INTO schema_migrations (version) VALUES ('20130314223754');

INSERT INTO schema_migrations (version) VALUES ('20130319231112');

INSERT INTO schema_migrations (version) VALUES ('20130326004604');

INSERT INTO schema_migrations (version) VALUES ('20130327164521');

INSERT INTO schema_migrations (version) VALUES ('20130329223844');

INSERT INTO schema_migrations (version) VALUES ('20130408214027');

INSERT INTO schema_migrations (version) VALUES ('20130409175941');

INSERT INTO schema_migrations (version) VALUES ('20130410021410');

INSERT INTO schema_migrations (version) VALUES ('20130410192912');

INSERT INTO schema_migrations (version) VALUES ('20130413050615');

INSERT INTO schema_migrations (version) VALUES ('20130416000229');

INSERT INTO schema_migrations (version) VALUES ('20130423001211');

INSERT INTO schema_migrations (version) VALUES ('20130430004200');

INSERT INTO schema_migrations (version) VALUES ('20130430020837');

INSERT INTO schema_migrations (version) VALUES ('20130430064220');

INSERT INTO schema_migrations (version) VALUES ('20130501080659');

INSERT INTO schema_migrations (version) VALUES ('20130503055031');

INSERT INTO schema_migrations (version) VALUES ('20130510075258');

INSERT INTO schema_migrations (version) VALUES ('20130514172913');

INSERT INTO schema_migrations (version) VALUES ('20130517234114');

INSERT INTO schema_migrations (version) VALUES ('20130522233158');

INSERT INTO schema_migrations (version) VALUES ('20130523070642');

INSERT INTO schema_migrations (version) VALUES ('20130528224505');

INSERT INTO schema_migrations (version) VALUES ('20130529004931');

INSERT INTO schema_migrations (version) VALUES ('20130529004932');

INSERT INTO schema_migrations (version) VALUES ('20130529004933');

INSERT INTO schema_migrations (version) VALUES ('20130529004934');

INSERT INTO schema_migrations (version) VALUES ('20130529004935');

INSERT INTO schema_migrations (version) VALUES ('20130529005122');

INSERT INTO schema_migrations (version) VALUES ('20130531231424');

INSERT INTO schema_migrations (version) VALUES ('20130603054950');

INSERT INTO schema_migrations (version) VALUES ('20130607095439');

INSERT INTO schema_migrations (version) VALUES ('20130610214426');

INSERT INTO schema_migrations (version) VALUES ('20130617082814');

INSERT INTO schema_migrations (version) VALUES ('20130617183832');

INSERT INTO schema_migrations (version) VALUES ('20130619005926');

INSERT INTO schema_migrations (version) VALUES ('20130619181831');

INSERT INTO schema_migrations (version) VALUES ('20130620003117');

INSERT INTO schema_migrations (version) VALUES ('20130622034558');

INSERT INTO schema_migrations (version) VALUES ('20130625221953');

INSERT INTO schema_migrations (version) VALUES ('20130625222351');

INSERT INTO schema_migrations (version) VALUES ('20130627182731');

INSERT INTO schema_migrations (version) VALUES ('20130705201256');

INSERT INTO schema_migrations (version) VALUES ('20130705213430');

INSERT INTO schema_migrations (version) VALUES ('20130710021704');

INSERT INTO schema_migrations (version) VALUES ('20130711190428');

INSERT INTO schema_migrations (version) VALUES ('20130712092924');

INSERT INTO schema_migrations (version) VALUES ('20130716181605');

INSERT INTO schema_migrations (version) VALUES ('20130716195202');

INSERT INTO schema_migrations (version) VALUES ('20130718175414');

INSERT INTO schema_migrations (version) VALUES ('20130722222812');

INSERT INTO schema_migrations (version) VALUES ('20130722224407');

INSERT INTO schema_migrations (version) VALUES ('20130730221542');

INSERT INTO schema_migrations (version) VALUES ('20130801200151');

INSERT INTO schema_migrations (version) VALUES ('20130807061501');

INSERT INTO schema_migrations (version) VALUES ('20130807230858');

INSERT INTO schema_migrations (version) VALUES ('20130815190455');

INSERT INTO schema_migrations (version) VALUES ('20130815223614');

INSERT INTO schema_migrations (version) VALUES ('20130816231547');

INSERT INTO schema_migrations (version) VALUES ('20130826071934');

INSERT INTO schema_migrations (version) VALUES ('20130828232233');

INSERT INTO schema_migrations (version) VALUES ('20130830231635');

INSERT INTO schema_migrations (version) VALUES ('20130830231723');

INSERT INTO schema_migrations (version) VALUES ('20130831000252');

INSERT INTO schema_migrations (version) VALUES ('20130902180017');

INSERT INTO schema_migrations (version) VALUES ('20130904000610');

INSERT INTO schema_migrations (version) VALUES ('20130904061731');

INSERT INTO schema_migrations (version) VALUES ('20130909223358');

INSERT INTO schema_migrations (version) VALUES ('20130911162405');

INSERT INTO schema_migrations (version) VALUES ('20130911231701');

INSERT INTO schema_migrations (version) VALUES ('20130916043934');

INSERT INTO schema_migrations (version) VALUES ('20130919231657');

INSERT INTO schema_migrations (version) VALUES ('20130926174619');

INSERT INTO schema_migrations (version) VALUES ('20131007195833');

INSERT INTO schema_migrations (version) VALUES ('20131007205245');

INSERT INTO schema_migrations (version) VALUES ('20131007233517');

INSERT INTO schema_migrations (version) VALUES ('20131008180254');

INSERT INTO schema_migrations (version) VALUES ('20131016205052');

INSERT INTO schema_migrations (version) VALUES ('20131024191215');

INSERT INTO schema_migrations (version) VALUES ('20131025183651');

INSERT INTO schema_migrations (version) VALUES ('20131029230840');

INSERT INTO schema_migrations (version) VALUES ('20131102051548');

INSERT INTO schema_migrations (version) VALUES ('20131119233415');

INSERT INTO schema_migrations (version) VALUES ('20131126190511');

INSERT INTO schema_migrations (version) VALUES ('20131127223228');

INSERT INTO schema_migrations (version) VALUES ('20131202234540');

INSERT INTO schema_migrations (version) VALUES ('20131204231600');

INSERT INTO schema_migrations (version) VALUES ('20131206190918');

INSERT INTO schema_migrations (version) VALUES ('20131218181720');

INSERT INTO schema_migrations (version) VALUES ('20131221021749');

INSERT INTO schema_migrations (version) VALUES ('20131231065957');

INSERT INTO schema_migrations (version) VALUES ('20140113192608');

INSERT INTO schema_migrations (version) VALUES ('20140116044848');

INSERT INTO schema_migrations (version) VALUES ('20140120193602');

INSERT INTO schema_migrations (version) VALUES ('20140122170857');

INSERT INTO schema_migrations (version) VALUES ('20140124214214');

INSERT INTO schema_migrations (version) VALUES ('20140124214349');

INSERT INTO schema_migrations (version) VALUES ('20140128044815');

INSERT INTO schema_migrations (version) VALUES ('20140131232038');

INSERT INTO schema_migrations (version) VALUES ('20140203201306');

INSERT INTO schema_migrations (version) VALUES ('20140409202332');

INSERT INTO schema_migrations (version) VALUES ('20140503000201');

INSERT INTO schema_migrations (version) VALUES ('20140505192216');

INSERT INTO schema_migrations (version) VALUES ('20140619202821');

INSERT INTO schema_migrations (version) VALUES ('20140716010252');

INSERT INTO schema_migrations (version) VALUES ('20140912175712');

INSERT INTO schema_migrations (version) VALUES ('20141206210108');

INSERT INTO schema_migrations (version) VALUES ('20141209201825');

INSERT INTO schema_migrations (version) VALUES ('20141209201826');

INSERT INTO schema_migrations (version) VALUES ('20141209201827');

INSERT INTO schema_migrations (version) VALUES ('20141223074816');

INSERT INTO schema_migrations (version) VALUES ('20150129232709');

INSERT INTO schema_migrations (version) VALUES ('20150204222833');

INSERT INTO schema_migrations (version) VALUES ('20150209233616');

INSERT INTO schema_migrations (version) VALUES ('20150303235719');

INSERT INTO schema_migrations (version) VALUES ('20150410180303');

INSERT INTO schema_migrations (version) VALUES ('20150427031537');

INSERT INTO schema_migrations (version) VALUES ('20150427031541');

INSERT INTO schema_migrations (version) VALUES ('20150428161705');

INSERT INTO schema_migrations (version) VALUES ('20150501224129');

INSERT INTO schema_migrations (version) VALUES ('20150521223942');

INSERT INTO schema_migrations (version) VALUES ('20150611165828');

INSERT INTO schema_migrations (version) VALUES ('20150623222712');

INSERT INTO schema_migrations (version) VALUES ('20150803172751');

INSERT INTO schema_migrations (version) VALUES ('20150803180035');

INSERT INTO schema_migrations (version) VALUES ('20150813054610');

INSERT INTO schema_migrations (version) VALUES ('20151009164704');

INSERT INTO schema_migrations (version) VALUES ('20151012184541');

INSERT INTO schema_migrations (version) VALUES ('20151013184529');

INSERT INTO schema_migrations (version) VALUES ('20151014035425');

INSERT INTO schema_migrations (version) VALUES ('20151016225227');

INSERT INTO schema_migrations (version) VALUES ('20151019174739');

INSERT INTO schema_migrations (version) VALUES ('20151027001131');

INSERT INTO schema_migrations (version) VALUES ('20151029060740');

INSERT INTO schema_migrations (version) VALUES ('20151031060613');

INSERT INTO schema_migrations (version) VALUES ('20151031165901');

INSERT INTO schema_migrations (version) VALUES ('20151117050815');

INSERT INTO schema_migrations (version) VALUES ('20151119220841');

INSERT INTO schema_migrations (version) VALUES ('20151202012640');

INSERT INTO schema_migrations (version) VALUES ('20160108005443');

INSERT INTO schema_migrations (version) VALUES ('20160205193023');

INSERT INTO schema_migrations (version) VALUES ('20160211214758');

INSERT INTO schema_migrations (version) VALUES ('20160211221836');

INSERT INTO schema_migrations (version) VALUES ('20160506185009');

INSERT INTO schema_migrations (version) VALUES ('20160615221610');

INSERT INTO schema_migrations (version) VALUES ('20160617174858');

INSERT INTO schema_migrations (version) VALUES ('20160627175815');

INSERT INTO schema_migrations (version) VALUES ('20160628151954');

INSERT INTO schema_migrations (version) VALUES ('20160630195733');

INSERT INTO schema_migrations (version) VALUES ('20160818162532');

INSERT INTO schema_migrations (version) VALUES ('20160818231947');

INSERT INTO schema_migrations (version) VALUES ('20160913212211');

INSERT INTO schema_migrations (version) VALUES ('20161208175329');

INSERT INTO schema_migrations (version) VALUES ('20161214230642');

INSERT INTO schema_migrations (version) VALUES ('20161221053707');

INSERT INTO schema_migrations (version) VALUES ('20161226225433');

INSERT INTO schema_migrations (version) VALUES ('20170105211422');

INSERT INTO schema_migrations (version) VALUES ('20170109173731');

INSERT INTO schema_migrations (version) VALUES ('20170224233915');

INSERT INTO schema_migrations (version) VALUES ('20170228210819');

INSERT INTO schema_migrations (version) VALUES ('20170306212842');

INSERT INTO schema_migrations (version) VALUES ('20170317222144');

INSERT INTO schema_migrations (version) VALUES ('20170522182222');

INSERT INTO schema_migrations (version) VALUES ('20190108224208');

INSERT INTO schema_migrations (version) VALUES ('20190123202608');

INSERT INTO schema_migrations (version) VALUES ('20190125235137');

INSERT INTO schema_migrations (version) VALUES ('20190126001041');

INSERT INTO schema_migrations (version) VALUES ('20190412184807');

INSERT INTO schema_migrations (version) VALUES ('20190415183302');

INSERT INTO schema_migrations (version) VALUES ('20190423172616');

INSERT INTO schema_migrations (version) VALUES ('20190423201327');

INSERT INTO schema_migrations (version) VALUES ('20190806055356');

INSERT INTO schema_migrations (version) VALUES ('20190815162014');

INSERT INTO schema_migrations (version) VALUES ('20190909221446');

INSERT INTO schema_migrations (version) VALUES ('20190912222024');

INSERT INTO schema_migrations (version) VALUES ('20191014223026');

INSERT INTO schema_migrations (version) VALUES ('20191028212012');

INSERT INTO schema_migrations (version) VALUES ('20200224232623');

