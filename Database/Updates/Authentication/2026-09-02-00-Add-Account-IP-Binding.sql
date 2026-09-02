USE `ace_auth`;

-- Table: account_ip_binding
-- Every IP address ever used by an account accumulates here. A single IP may be bound to more than
-- one account only up to the per-IP allowance enforced in application code (ip_binding_ip_allowance,
-- default 1 = one account per IP). The composite unique key just prevents duplicate (ip, account) rows.

CREATE TABLE IF NOT EXISTS `account_ip_binding` (
    `id`          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `account_id`  INT UNSIGNED    NOT NULL,
    `ip_address`  VARCHAR(45)     NOT NULL,
    `bound_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `bound_by`    VARCHAR(10)     NOT NULL DEFAULT 'login',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uidx_ip_account` (`ip_address`, `account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: account_ip_change_log
-- Audit log of every new IP recorded for an account.

CREATE TABLE IF NOT EXISTS `account_ip_change_log` (
    `id`            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `account_id`    INT UNSIGNED    NOT NULL,
    `old_ip`        VARCHAR(45)     NOT NULL,
    `new_ip`        VARCHAR(45)     NOT NULL,
    `changed_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `auto_banned`   TINYINT(1)      NOT NULL DEFAULT 0,
    `admin_cleared` TINYINT(1)      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_account_date` (`account_id`, `changed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
