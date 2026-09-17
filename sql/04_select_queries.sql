-- ============================================================
-- Projeto: CariocaStore
-- Arquivo: 04_select_queries.sql
-- Objetivo: realizar consultas utilizando SELECT
-- ============================================================


-- ============================================================
-- CONSULTA 1
-- Duas tabelas: categoria e produto
-- Recursos: JOIN, GROUP BY, COUNT e AVG
-- Objetivo: mostrar a quantidade de produtos e o preço médio
-- de cada categoria.
-- ============================================================

SELECT
    c.nome AS categoria,
    COUNT(p.id_produto) AS quantidade_produtos,
    ROUND(AVG(p.preco_venda), 2) AS preco_medio
FROM categoria AS c
INNER JOIN produto AS p
    ON p.id_categoria = c.id_categoria
GROUP BY
    c.id_categoria,
    c.nome
ORDER BY
    c.nome;


-- ============================================================
-- CONSULTA 2
-- Três tabelas: cliente, pedido e item_pedido
-- Recursos: JOIN, GROUP BY, COUNT e SUM
-- Objetivo: mostrar o histórico resumido de compras.
-- ============================================================

SELECT
    cl.nome AS cliente,
    COUNT(DISTINCT pe.id_pedido) AS total_pedidos,
    SUM(ip.quantidade) AS unidades_compradas,
    ROUND(SUM(ip.subtotal), 2) AS valor_total_comprado
FROM cliente AS cl
INNER JOIN pedido AS pe
    ON pe.id_cliente = cl.id_cliente
INNER JOIN item_pedido AS ip
    ON ip.id_pedido = pe.id_pedido
GROUP BY
    cl.id_cliente,
    cl.nome
ORDER BY
    valor_total_comprado DESC;


-- ============================================================
-- CONSULTA 3
-- Consulta com subconsulta
-- Objetivo: encontrar produtos com preço acima da média.
-- ============================================================

SELECT
    codigo_sku,
    nome AS produto,
    preco_venda
FROM produto
WHERE preco_venda > (
    SELECT AVG(preco_venda)
    FROM produto
)
ORDER BY
    preco_venda DESC;


-- ============================================================
-- CONSULTA 4 — COMPLEMENTAR
-- Duas tabelas: produto e item_pedido
-- Objetivo: identificar os produtos mais vendidos.
-- ============================================================

SELECT
    p.codigo_sku,
    p.nome AS produto,
    SUM(ip.quantidade) AS quantidade_vendida,
    ROUND(SUM(ip.subtotal), 2) AS valor_total_vendido
FROM produto AS p
INNER JOIN item_pedido AS ip
    ON ip.id_produto = p.id_produto
GROUP BY
    p.id_produto,
    p.codigo_sku,
    p.nome
ORDER BY
    quantidade_vendida DESC,
    valor_total_vendido DESC;