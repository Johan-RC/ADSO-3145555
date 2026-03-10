-- =========================================
-- EXTENSION UUID
-- =========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================
-- MODULE 1: SECURITY
-- =========================================

CREATE TABLE role (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE module (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE view (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    route VARCHAR(200),
    module_id UUID REFERENCES module(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_role (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES "user"(id) ON DELETE CASCADE,
    role_id UUID REFERENCES role(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE role_module (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID REFERENCES role(id) ON DELETE CASCADE,
    module_id UUID REFERENCES module(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE module_view (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID REFERENCES module(id) ON DELETE CASCADE,
    view_id UUID REFERENCES view(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

-- =========================================
-- MODULE 2: PARAMETER
-- =========================================

CREATE TABLE type_document (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    abbreviation VARCHAR(10),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE person (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    type_document_id UUID REFERENCES type_document(id) ON DELETE SET NULL,
    phone VARCHAR(20),
    email VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE file (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_name VARCHAR(200),
    file_path TEXT,
    person_id UUID REFERENCES person(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

-- =========================================
-- MODULE 3: INVENTORY
-- =========================================

CREATE TABLE category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE supplier (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    category_id UUID REFERENCES category(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES supplier(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID UNIQUE REFERENCES product(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    status BOOLEAN DEFAULT TRUE
);

-- =========================================
-- MODULE 4: SALES
-- =========================================

CREATE TABLE customer (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    person_id UUID UNIQUE REFERENCES person(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE "order" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customer(id) ON DELETE SET NULL,
    order_date TIMESTAMPTZ DEFAULT NOW(),
    total NUMERIC(12,2) CHECK (total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE order_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES "order"(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

-- =========================================
-- MODULE 5: METHOD PAYMENT
-- =========================================

CREATE TABLE method_payment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

-- =========================================
-- MODULE 6: BILLING
-- =========================================

CREATE TABLE invoice (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES "order"(id) ON DELETE SET NULL,
    invoice_date TIMESTAMPTZ DEFAULT NOW(),
    total NUMERIC(12,2) CHECK (total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE invoice_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoice(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id) ON DELETE SET NULL,
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC(12,2) CHECK (unit_price >= 0),
    subtotal NUMERIC(12,2) CHECK (subtotal >= 0)
);

CREATE TABLE payment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoice(id) ON DELETE CASCADE,
    method_payment_id UUID REFERENCES method_payment(id) ON DELETE SET NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status BOOLEAN DEFAULT TRUE
);