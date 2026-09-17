-- ============================================================
-- Projeto: CariocaStore
-- SGBD: PostgreSQL 17
-- Arquivo: 01_create_tables.sql
-- Objetivo: criar as dez tabelas do sistema de vendas
-- ============================================================

BEGIN;

-- 1. CLIENTE
CREATE TABLE cliente (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150),
    telefone VARCHAR(20),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);

-- 2. FUNCIONARIO
CREATE TABLE funcionario (
    id_funcionario INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo_funcionario VARCHAR(20) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL,
    data_admissao DATE NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_funcionario_codigo UNIQUE (codigo_funcionario),
    CONSTRAINT uq_funcionario_email UNIQUE (email)
);

-- 3. CATEGORIA
CREATE TABLE categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(80) NOT NULL,
    descricao VARCHAR(250),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);

-- 4. FORNECEDOR
CREATE TABLE fornecedor (
    id_fornecedor INTEGER GENERATED ALWAYS AS IDENTITY,
    nome_fantasia VARCHAR(120) NOT NULL,
    email VARCHAR(150),
    telefone VARCHAR(20),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
    CONSTRAINT uq_fornecedor_nome UNIQUE (nome_fantasia),
    CONSTRAINT uq_fornecedor_email UNIQUE (email)
);

-- 5. ENDERECO: depende de CLIENTE
CREATE TABLE endereco (
    id_endereco INTEGER GENERATED ALWAYS AS IDENTITY,
    id_cliente INTEGER NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    principal BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_endereco PRIMARY KEY (id_endereco),
    CONSTRAINT fk_endereco_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_endereco_uf
        CHECK (uf ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_endereco_cep
        CHECK (cep ~ '^[0-9]{5}-?[0-9]{3}$')
);

-- Um cliente pode ter vários endereços, mas apenas um principal.
CREATE UNIQUE INDEX uq_endereco_principal_por_cliente
    ON endereco (id_cliente)
    WHERE principal = TRUE;

-- 6. PRODUTO: depende de CATEGORIA
CREATE TABLE produto (
    id_produto INTEGER GENERATED ALWAYS AS IDENTITY,
    id_categoria INTEGER NOT NULL,
    codigo_sku VARCHAR(20) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao VARCHAR(250),
    unidade_medida VARCHAR(10) NOT NULL,
    preco_venda NUMERIC(10, 2) NOT NULL,
    quantidade_estoque INTEGER NOT NULL DEFAULT 0,
    estoque_minimo INTEGER NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT uq_produto_sku UNIQUE (codigo_sku),
    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_produto_unidade_medida
        CHECK (unidade_medida IN ('UN', 'KG', 'L', 'PCT')),
    CONSTRAINT ck_produto_preco_venda
        CHECK (preco_venda > 0),
    CONSTRAINT ck_produto_quantidade_estoque
        CHECK (quantidade_estoque >= 0),
    CONSTRAINT ck_produto_estoque_minimo
        CHECK (estoque_minimo >= 0)
);

-- 7. PRODUTO_FORNECEDOR: relaciona PRODUTO e FORNECEDOR
CREATE TABLE produto_fornecedor (
    id_produto INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,
    preco_compra NUMERIC(10, 2) NOT NULL,
    prazo_entrega_dias INTEGER NOT NULL DEFAULT 0,
    fornecedor_principal BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_produto_fornecedor
        PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT fk_produto_fornecedor_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_produto_fornecedor_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_produto_fornecedor_preco
        CHECK (preco_compra > 0),
    CONSTRAINT ck_produto_fornecedor_prazo
        CHECK (prazo_entrega_dias >= 0)
);

-- Um produto pode ter vários fornecedores, mas apenas um principal.
CREATE UNIQUE INDEX uq_fornecedor_principal_por_produto
    ON produto_fornecedor (id_produto)
    WHERE fornecedor_principal = TRUE;

-- 8. PEDIDO: depende de CLIENTE e FUNCIONARIO
CREATE TABLE pedido (
    id_pedido INTEGER GENERATED ALWAYS AS IDENTITY,
    id_cliente INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    data_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pedido VARCHAR(20) NOT NULL DEFAULT 'aberto',
    observacao VARCHAR(250),

    CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_funcionario
        FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_pedido_status
        CHECK (status_pedido IN ('aberto', 'pago', 'cancelado', 'concluido'))
);

-- 9. ITEM_PEDIDO: relaciona PEDIDO e PRODUTO
CREATE TABLE item_pedido (
    id_item_pedido INTEGER GENERATED ALWAYS AS IDENTITY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(12, 2)
        GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,

    CONSTRAINT pk_item_pedido PRIMARY KEY (id_item_pedido),
    CONSTRAINT uq_item_pedido_produto UNIQUE (id_pedido, id_produto),
    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_item_pedido_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_item_pedido_quantidade
        CHECK (quantidade > 0),
    CONSTRAINT ck_item_pedido_preco
        CHECK (preco_unitario > 0)
);

-- 10. PAGAMENTO: depende de PEDIDO
CREATE TABLE pagamento (
    id_pagamento INTEGER GENERATED ALWAYS AS IDENTITY,
    id_pedido INTEGER NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    valor_pagamento NUMERIC(12, 2) NOT NULL,
    data_pagamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pagamento VARCHAR(20) NOT NULL DEFAULT 'pendente',

    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_pagamento_forma
        CHECK (
            forma_pagamento IN (
                'dinheiro',
                'pix',
                'cartao_credito',
                'cartao_debito'
            )
        ),
    CONSTRAINT ck_pagamento_valor
        CHECK (valor_pagamento > 0),
    CONSTRAINT ck_pagamento_status
        CHECK (
            status_pagamento IN (
                'pendente',
                'aprovado',
                'cancelado',
                'estornado'
            )
        )
);

COMMIT;
