-- JawnTide wiki database. Run once as root:  mariadb -uroot -p < wiki-schema.sql
-- The website user "web" gets full use of ace_wiki only; the game server user "ace" may only confirm link codes.
CREATE DATABASE IF NOT EXISTS ace_wiki CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ace_wiki;

-- one wiki login per game account; name = the character used to link
CREATE TABLE IF NOT EXISTS wiki_user (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id INT UNSIGNED NOT NULL UNIQUE,
  name VARCHAR(32) NOT NULL UNIQUE,
  pass_hash VARBINARY(64) NOT NULL,
  pass_salt VARBINARY(16) NOT NULL,
  is_admin TINYINT(1) NOT NULL DEFAULT 0,
  blocked TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
  last_login DATETIME NULL
) ENGINE=InnoDB;

-- codes shown on the website; the game server fills account and character when the player types /wiki CODE
CREATE TABLE IF NOT EXISTS link_code (
  code CHAR(8) PRIMARY KEY,
  created_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
  expires_at DATETIME NOT NULL,
  account_id INT UNSIGNED NULL,
  char_name VARCHAR(32) NULL,
  access_level INT NULL,
  confirmed_at DATETIME NULL,
  used_at DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS session (
  token CHAR(64) PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  csrf CHAR(32) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
  expires_at DATETIME NOT NULL,
  KEY (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS page (
  slug VARCHAR(80) PRIMARY KEY,
  title VARCHAR(120) NOT NULL,
  current_rev INT UNSIGNED NOT NULL,
  locked TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
  updated_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP()
) ENGINE=InnoDB;

-- every saved version of every page
CREATE TABLE IF NOT EXISTS revision (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(80) NOT NULL,
  title VARCHAR(120) NOT NULL,
  body MEDIUMTEXT NOT NULL,
  summary VARCHAR(200) NOT NULL DEFAULT '',
  user_id INT UNSIGNED NULL,          -- NULL = written by the site (starter articles)
  created_at DATETIME NOT NULL DEFAULT UTC_TIMESTAMP(),
  KEY (slug, id)
) ENGINE=InnoDB;
