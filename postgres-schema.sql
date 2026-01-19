-- Pezza Incubator - Postgres Sample Schema
-- Use this schema across incubators (Java, Python, Node, .NET)
-- Verified for PostgreSQL 14+

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS pezza;
SET search_path TO pezza;

-- Core tables
CREATE TABLE IF NOT EXISTS pizzas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL CHECK (price > 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  status TEXT NOT NULL CHECK (status IN ('NEW','PAID','CANCELLED','DELIVERED')),
  total NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  pizza_id UUID NOT NULL REFERENCES pizzas(id) ON DELETE RESTRICT,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE IF NOT EXISTS stock (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pizza_id UUID NOT NULL REFERENCES pizzas(id) ON DELETE CASCADE,
  quantity INT NOT NULL CHECK (quantity >= 0),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Derived totals trigger (optional example)
CREATE OR REPLACE FUNCTION update_order_total() RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders o
    SET total = COALESCE((
      SELECT SUM(oi.quantity * oi.unit_price) FROM order_items oi WHERE oi.order_id = o.id
    ), 0)
  WHERE o.id = NEW.order_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_order_total ON order_items;
CREATE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_order_total();

-- Sample data
INSERT INTO pizzas (name, price) VALUES
('Margherita', 89.90),
('BBQ Chicken', 109.90)
ON CONFLICT DO NOTHING;

INSERT INTO customers (email, full_name) VALUES
('alice@example.com', 'Alice Example'),
('bob@example.com', 'Bob Example')
ON CONFLICT DO NOTHING;

-- Example order
DO $$
DECLARE
  c UUID;
  p UUID;
  o UUID;
BEGIN
  SELECT id INTO c FROM customers LIMIT 1;
  SELECT id INTO p FROM pizzas LIMIT 1;
  IF c IS NOT NULL AND p IS NOT NULL THEN
    INSERT INTO orders(customer_id, status) VALUES (c, 'NEW') RETURNING id INTO o;
    INSERT INTO order_items(order_id, pizza_id, quantity, unit_price) VALUES (o, p, 2, 89.90);
  END IF;
END $$;
