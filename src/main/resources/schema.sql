DROP SCHEMA IF EXISTS LSRS CASCADE;
CREATE SCHEMA LSRS;

-- CREATE CHILDCARE TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Childcare(
	time_limit	INTEGER PRIMARY KEY
);

-- CREATE POPULATION CATEGORY --
CREATE TABLE IF NOT EXISTS LSRS.PopulationCategory(
   city_size           TEXT PRIMARY KEY
);

-- CREATE STORE CITY --
CREATE TABLE IF NOT EXISTS LSRS.StoreCity(
	city_name         VARCHAR(50)     NOT NULL,
	state_name        TEXT            NOT NULL,
	population        NUMERIC         NOT NULL,
	city_size		  TEXT,
	CONSTRAINT pk_storecity PRIMARY KEY(city_name, state_name),
	CONSTRAINT fk_storecity_pop_cat FOREIGN KEY(city_size) REFERENCES LSRS.PopulationCategory(city_size) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION LSRS.update_population_mapping()
	RETURNS TRIGGER
	AS
'
BEGIN
	NEW.city_size := CASE WHEN NEW.population < 3700000 THEN ''Small''
						  WHEN NEW.population BETWEEN 3700000 AND 6700000 THEN ''Medium''
						  WHEN NEW.population BETWEEN 6700000 AND 9000000 THEN ''Large''
						  ELSE ''Extra Large'' END;

	RETURN NEW;
END;
'
LANGUAGE PLPGSQL;


CREATE TRIGGER city_size_changes
BEFORE UPDATE OR INSERT
ON LSRS.StoreCity
FOR EACH ROW
EXECUTE PROCEDURE LSRS.update_population_mapping();


-- CREATE STORE TABLE --
CREATE SEQUENCE IF NOT EXISTS LSRS.store_id_seq
	start 1
	increment 1
	NO MAXVALUE
	CACHE 1;

CREATE TABLE IF NOT EXISTS LSRS.Store(
	store_number INTEGER PRIMARY KEY DEFAULT nextval('LSRS.store_id_seq'),
	address          VARCHAR(50)      NOT NULL,
	restaurant       BOOL             NOT NULL,
	snackbar         BOOL             NOT NULL,
	phone_number     VARCHAR(15)      NOT NULL,
	time_limit		 INTEGER,
	city_name        VARCHAR(50)     NOT NULL,
	state_name       TEXT            NOT NULL,

	CONSTRAINT fk_sale_time_limit FOREIGN KEY(time_limit) REFERENCES LSRS.Childcare(time_limit) ON DELETE SET DEFAULT,
	CONSTRAINT fk_store_city FOREIGN KEY(city_name, state_name) REFERENCES LSRS.StoreCity(city_name, state_name)

);

ALTER SEQUENCE LSRS.store_id_seq OWNED BY LSRS.Store.store_number;


-- CREATE CATEGORY TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Category(
   category_name               VARCHAR(255)       PRIMARY KEY
);

-- CREATE PRODUCT TABLE --
CREATE SEQUENCE IF NOT EXISTS LSRS.product_id_seq
	start 1
	increment 1
	NO MAXVALUE
	CACHE 1;

CREATE TABLE IF NOT EXISTS LSRS.Product(
	pid                INTEGER 		  PRIMARY KEY DEFAULT nextval('LSRS.product_id_seq'),
	product_name       VARCHAR(255)   NOT NULL,
	retail_price       NUMERIC        DEFAULT 0
);

ALTER SEQUENCE LSRS.product_id_seq OWNED BY LSRS.Product.pid;

-- CREATE PRODUCT ASSIGNED --
CREATE TABLE IF NOT EXISTS LSRS.ProductAssigned(
	pid			  INTEGER,
	category_name TEXT,
	CONSTRAINT fk_product_assigned_pid FOREIGN KEY(pid) REFERENCES LSRS.Product(pid) ON DELETE CASCADE,
	CONSTRAINT fk_product_assigned_category_name FOREIGN KEY(category_name) REFERENCES LSRS.Category(category_name) ON DELETE CASCADE
);

-- CREATE LISTED AT --
CREATE TABLE IF NOT EXISTS LSRS.ListedAt(
	pid  			INTEGER,
	store_number	INTEGER,
	CONSTRAINT fk_listed_at_pid FOREIGN KEY(pid) REFERENCES LSRS.Product(pid) ON DELETE CASCADE,
	CONSTRAINT fk_listed_at_store_number FOREIGN KEY(store_number) REFERENCES LSRS.Store(store_number) ON DELETE CASCADE
);

-- CREATE SALE DATE TABLE --
CREATE TABLE IF NOT EXISTS LSRS.SaleDate(
	sale_date    DATE  PRIMARY KEY
);

-- CREATE SALE TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Sale(
	volume             INTEGER        NOT NULL,
	store_number       INTEGER,
	sale_date          DATE,
	pid                INTEGER,
	CONSTRAINT pk_sale PRIMARY KEY(sale_date, pid, store_number),
	CONSTRAINT fk_sale_store_number FOREIGN KEY(store_number) REFERENCES LSRS.Store(store_number) ON DELETE CASCADE,
	CONSTRAINT fk_sale_date FOREIGN KEY(sale_date) REFERENCES LSRS.SaleDate(sale_date) ON DELETE CASCADE,
	CONSTRAINT fk_sale_pid FOREIGN KEY(pid) REFERENCES LSRS.Product(pid) ON DELETE CASCADE
);

-- CREATE HOLIDAY TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Holiday(
	holi_description        VARCHAR(255),
	sale_date 				DATE,
	CONSTRAINT pk_holiday PRIMARY KEY(sale_date),
	CONSTRAINT fk_date_holiday FOREIGN KEY(sale_date) REFERENCES LSRS.SaleDate(sale_date) ON DELETE CASCADE
);

-- CREATE DISCOUNT TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Discount(
	discount_price     NUMERIC        DEFAULT 0,
	pid                INTEGER,
	sale_date          DATE,
	CONSTRAINT pk_discount PRIMARY KEY(discount_price, sale_date),
	CONSTRAINT fk_discount_pid FOREIGN KEY(pid) REFERENCES LSRS.Product(pid) ON DELETE CASCADE,
	CONSTRAINT fk_discount_sale_date FOREIGN KEY(sale_date) REFERENCES LSRS.SaleDate(sale_date) ON DELETE CASCADE
);

-- CREATE CAMPAIGN TABLE --
CREATE TABLE IF NOT EXISTS LSRS.Campaign(
	description TEXT PRIMARY KEY
);

-- CREATE CAMPAIGN ACTIVE ON --
CREATE TABLE IF NOT EXISTS LSRS.CampaignActiveOn(
	description 	TEXT,
	sale_date 		DATE,
	CONSTRAINT fk_campaign_active_on_description FOREIGN KEY(description) REFERENCES LSRS.Campaign(description) ON DELETE CASCADE,
	CONSTRAINT fk_campaign_active_on_date FOREIGN KEY(sale_date) REFERENCES LSRS.SaleDate(sale_date) ON DELETE CASCADE
);