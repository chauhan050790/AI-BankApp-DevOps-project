CREATE TABLE accounts (
    id BIGINT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    balance DECIMAL(19, 2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (id),
    CONSTRAINT uk_accounts_username UNIQUE (username)
);

CREATE TABLE transactions (
    id BIGINT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(19, 2) NOT NULL,
    type VARCHAR(32) NOT NULL,
    timestamp DATETIME(6) NOT NULL,
    account_id BIGINT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id) REFERENCES accounts (id)
);

CREATE INDEX ix_transactions_account_timestamp
    ON transactions (account_id, timestamp DESC);
