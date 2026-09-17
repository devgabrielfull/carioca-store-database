-- ============================================================
-- Projeto: CariocaStore
-- Arquivo: 03_crud.sql
-- Objetivo: demonstrar operações CRUD
-- ============================================================

BEGIN;

-- ============================================================
-- 1. CREATE — INSERT
-- Cadastra um cliente de teste
-- ============================================================

INSERT INTO cliente (nome, email, telefone)
VALUES (
    'Cliente Teste CRUD',
    'cliente.crud@cariocastore.test',
    '(21) 99999-0000'
)
RETURNING
    id_cliente,
    nome,
    email,
    telefone,
    data_cadastro,
    ativo;


-- ============================================================
-- 2. READ — SELECT
-- Consulta o cliente cadastrado
-- ============================================================

SELECT
    id_cliente,
    nome,
    email,
    telefone,
    ativo
FROM cliente
WHERE email = 'cliente.crud@cariocastore.test';


-- ============================================================
-- 3. UPDATE
-- Atualiza o nome e o telefone do cliente
-- ============================================================

UPDATE cliente
SET
    nome = 'Cliente CRUD Atualizado',
    telefone = '(21) 98888-0000'
WHERE email = 'cliente.crud@cariocastore.test'
RETURNING
    id_cliente,
    nome,
    email,
    telefone,
    ativo;


-- ============================================================
-- 4. DELETE
-- Exclui o cliente utilizado no teste
-- ============================================================

DELETE FROM cliente
WHERE email = 'cliente.crud@cariocastore.test'
RETURNING
    id_cliente,
    nome,
    email;


COMMIT;


-- ============================================================
-- VERIFICAÇÃO FINAL
-- O total deve voltar para 5 clientes
-- ============================================================

SELECT COUNT(*) AS total_clientes_apos_crud
FROM cliente;