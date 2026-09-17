-- ============================================================
-- Projeto: CariocaStore
-- Arquivo: 05_stored_procedure.sql
-- Objetivo: criar e testar uma stored procedure
-- ============================================================


-- ============================================================
-- STORED PROCEDURE: registrar_item_pedido
--
-- Responsabilidades:
-- 1. Verificar se a quantidade é válida;
-- 2. Verificar se o pedido existe e está aberto;
-- 3. Verificar se o produto existe e está ativo;
-- 4. Verificar se existe estoque suficiente;
-- 5. Inserir o produto no pedido;
-- 6. Atualizar o estoque.
-- ============================================================

CREATE OR REPLACE PROCEDURE registrar_item_pedido(
    IN p_id_pedido INTEGER,
    IN p_id_produto INTEGER,
    IN p_quantidade INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_pedido VARCHAR(20);
    v_nome_produto VARCHAR(120);
    v_estoque_atual INTEGER;
    v_preco_venda NUMERIC(10, 2);
BEGIN
    -- Verifica se a quantidade é válida
    IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
        RAISE EXCEPTION
            'A quantidade deve ser maior que zero.';
    END IF;


    -- Localiza e bloqueia o pedido durante a operação
    SELECT pe.status_pedido
    INTO v_status_pedido
    FROM pedido AS pe
    WHERE pe.id_pedido = p_id_pedido
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Pedido de ID % não encontrado.',
            p_id_pedido;
    END IF;


    -- Somente pedidos abertos podem receber itens
    IF v_status_pedido <> 'aberto' THEN
        RAISE EXCEPTION
            'O pedido % não está aberto. Status atual: %.',
            p_id_pedido,
            v_status_pedido;
    END IF;


    -- Localiza o produto e bloqueia seu estoque
    SELECT
        pr.nome,
        pr.quantidade_estoque,
        pr.preco_venda
    INTO
        v_nome_produto,
        v_estoque_atual,
        v_preco_venda
    FROM produto AS pr
    WHERE pr.id_produto = p_id_produto
      AND pr.ativo = TRUE
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Produto ativo de ID % não encontrado.',
            p_id_produto;
    END IF;


    -- Evita colocar o mesmo produto duas vezes no pedido
    IF EXISTS (
        SELECT 1
        FROM item_pedido AS ip
        WHERE ip.id_pedido = p_id_pedido
          AND ip.id_produto = p_id_produto
    ) THEN
        RAISE EXCEPTION
            'O produto % já está presente no pedido %.',
            p_id_produto,
            p_id_pedido;
    END IF;


    -- Verifica se o estoque é suficiente
    IF v_estoque_atual < p_quantidade THEN
        RAISE EXCEPTION
            'Estoque insuficiente para o produto "%". Disponível: %. Solicitado: %.',
            v_nome_produto,
            v_estoque_atual,
            p_quantidade;
    END IF;


    -- Insere o produto no pedido
    INSERT INTO item_pedido (
        id_pedido,
        id_produto,
        quantidade,
        preco_unitario
    )
    VALUES (
        p_id_pedido,
        p_id_produto,
        p_quantidade,
        v_preco_venda
    );


    -- Atualiza o estoque
    UPDATE produto
    SET quantidade_estoque =
        quantidade_estoque - p_quantidade
    WHERE id_produto = p_id_produto;


    RAISE NOTICE
        'Produto "%" adicionado ao pedido %. Estoque: % -> %.',
        v_nome_produto,
        p_id_pedido,
        v_estoque_atual,
        v_estoque_atual - p_quantidade;
END;
$$;


-- ============================================================
-- TESTE CONTROLADO DA STORED PROCEDURE
-- O teste será desfeito no final para não alterar os 80 registros.
-- ============================================================

BEGIN;


-- Estoque antes da chamada
SELECT
    id_produto,
    nome,
    quantidade_estoque AS estoque_antes
FROM produto
WHERE id_produto = 1;


-- Cria um pedido temporário e guarda seu ID
INSERT INTO pedido (
    id_cliente,
    id_funcionario,
    status_pedido,
    observacao
)
VALUES (
    1,
    1,
    'aberto',
    'Teste da stored procedure'
)
RETURNING id_pedido AS id_pedido_teste
\gset


-- Mostra o ID gerado
\echo Pedido temporario criado com ID :id_pedido_teste


-- Executa a stored procedure
CALL registrar_item_pedido(
    :id_pedido_teste,
    1,
    2
);


-- Verifica o item inserido
SELECT
    ip.id_pedido,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal
FROM item_pedido AS ip
INNER JOIN produto AS p
    ON p.id_produto = ip.id_produto
WHERE ip.id_pedido = :id_pedido_teste;


-- Verifica a redução do estoque
SELECT
    id_produto,
    nome,
    quantidade_estoque AS estoque_depois
FROM produto
WHERE id_produto = 1;


-- Desfaz somente os dados do teste
ROLLBACK;


-- Confirma que o estoque voltou ao valor original
SELECT
    id_produto,
    nome,
    quantidade_estoque AS estoque_apos_rollback
FROM produto
WHERE id_produto = 1;


-- Confirma que o pedido temporário foi removido
SELECT COUNT(*) AS pedidos_teste_restantes
FROM pedido
WHERE observacao = 'Teste da stored procedure';