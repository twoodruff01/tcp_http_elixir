BEGIN;

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.requests
(
    id SERIAL PRIMARY KEY,
    request VARCHAR(300),
    method VARCHAR(10),
    create_timestamp timestamp without time zone NOT NULL
);

INSERT INTO requests (request, method, create_timestamp) VALUES ('/some/path/to/resource', 'GET', current_timestamp);

END;