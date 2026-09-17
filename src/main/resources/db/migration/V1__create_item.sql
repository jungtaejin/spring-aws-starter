-- Runs on PostgreSQL (RDS) and on H2 in PostgreSQL mode (local/test).
CREATE TABLE item (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
