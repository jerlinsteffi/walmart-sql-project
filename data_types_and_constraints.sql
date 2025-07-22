-- Set invoice_id as NOT NULL
ALTER TABLE details
ALTER COLUMN invoice_id INT NOT NULL;
GO

-- Add primary key constraint on invoice_id
ALTER TABLE details
ADD CONSTRAINT PK_invoice_id PRIMARY KEY (invoice_id);
GO

-- Change unit_price datatype to MONEY
ALTER TABLE details
ALTER COLUMN unit_price MONEY;
GO

-- Change quantity datatype to INT
ALTER TABLE details
ALTER COLUMN quantity INT;
GO

-- Change date column datatype to DATE
ALTER TABLE details
ALTER COLUMN date DATE;
GO

-- Change time column datatype to TIME(0)
ALTER TABLE details
ALTER COLUMN time TIME(0);
GO