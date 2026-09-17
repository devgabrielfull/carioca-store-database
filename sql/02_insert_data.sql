-- ============================================================
-- Projeto: CariocaStore
-- SGBD: PostgreSQL 17
-- Arquivo: 02_insert_data.sql
-- Objetivo: inserir dados ficticios coerentes nas dez tabelas
-- Observacao: executar uma unica vez, depois de 01_create_tables.sql
-- ============================================================

BEGIN;

-- 1. CLIENTES (5 registros)
INSERT INTO cliente (nome, email, telefone)
VALUES
    ('Ana Beatriz Ribeiro', 'ana.ribeiro@example.com', '(21) 90000-0001'),
    ('Bruno Martins Alves', 'bruno.alves@example.com', '(21) 90000-0002'),
    ('Carla Souza Lima', 'carla.lima@example.com', '(21) 90000-0003'),
    ('Diego Ferreira Costa', 'diego.costa@example.com', '(21) 90000-0004'),
    ('Elisa Gomes Pereira', 'elisa.pereira@example.com', '(21) 90000-0005');

-- 2. FUNCIONARIOS (5 registros)
INSERT INTO funcionario (
    codigo_funcionario,
    nome,
    cargo,
    email,
    data_admissao
)
VALUES
    ('FUN001', 'Marcos Vinicius Rocha', 'Caixa', 'marcos@cariocastore.test', '2024-02-05'),
    ('FUN002', 'Juliana Mendes Silva', 'Vendedora', 'juliana@cariocastore.test', '2024-04-15'),
    ('FUN003', 'Rafael Nunes Barros', 'Estoquista', 'rafael@cariocastore.test', '2025-01-10'),
    ('FUN004', 'Patricia Araujo Dias', 'Gerente', 'patricia@cariocastore.test', '2023-08-21'),
    ('FUN005', 'Lucas Teixeira Melo', 'Auxiliar administrativo', 'lucas@cariocastore.test', '2025-06-02');

-- 3. CATEGORIAS (5 registros)
INSERT INTO categoria (nome, descricao)
VALUES
    ('Alimentos', 'Produtos alimenticios secos e embalados'),
    ('Bebidas', 'Bebidas nao alcoolicas e agua'),
    ('Higiene Pessoal', 'Produtos para cuidados pessoais'),
    ('Limpeza', 'Produtos utilizados na limpeza domestica'),
    ('Utilidades Domesticas', 'Utensilios e artigos para o lar');

-- 4. FORNECEDORES (5 registros)
INSERT INTO fornecedor (nome_fantasia, email, telefone)
VALUES
    ('Distribuidora Guanabara', 'contato@guanabara.test', '(21) 3000-1001'),
    ('Atacado Carioca', 'vendas@atacadocarioca.test', '(21) 3000-1002'),
    ('Bebidas Rio', 'pedidos@bebidasrio.test', '(21) 3000-1003'),
    ('Higiene Brasil', 'comercial@higienebrasil.test', '(21) 3000-1004'),
    ('Casa Limpa Distribuidora', 'vendas@casalimpa.test', '(21) 3000-1005');

-- 5. ENDERECOS (6 registros)
INSERT INTO endereco (
    id_cliente,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    uf,
    cep,
    principal
)
VALUES
    (1, 'Rua das Palmeiras', '120', 'Apto 201', 'Tijuca', 'Rio de Janeiro', 'RJ', '20000-101', TRUE),
    (1, 'Avenida Central', '450', NULL, 'Centro', 'Rio de Janeiro', 'RJ', '20000-102', FALSE),
    (2, 'Avenida do Sol', '85', NULL, 'Méier', 'Rio de Janeiro', 'RJ', '20000-103', TRUE),
    (3, 'Rua da Harmonia', '311', 'Casa 2', 'Vila Isabel', 'Rio de Janeiro', 'RJ', '20000-104', TRUE),
    (4, 'Travessa das Flores', '42', NULL, 'Maracanã', 'Rio de Janeiro', 'RJ', '20000-105', TRUE),
    (5, 'Rua do Comércio', '900', 'Bloco B', 'Madureira', 'Rio de Janeiro', 'RJ', '20000-106', TRUE);

-- 6. PRODUTOS (12 registros)
INSERT INTO produto (
    id_categoria,
    codigo_sku,
    nome,
    descricao,
    unidade_medida,
    preco_venda,
    quantidade_estoque,
    estoque_minimo
)
VALUES
    (1, 'CAR-001', 'Arroz 5 kg', 'Pacote de arroz branco tipo 1', 'PCT', 32.90, 40, 10),
    (1, 'CAR-002', 'Feijao 1 kg', 'Pacote de feijao carioca', 'PCT', 8.99, 55, 15),
    (1, 'CAR-003', 'Macarrao 500 g', 'Massa seca tipo espaguete', 'PCT', 5.49, 60, 15),
    (1, 'CAR-004', 'Cafe 500 g', 'Cafe torrado e moido', 'PCT', 18.90, 35, 10),
    (2, 'CAR-005', 'Refrigerante 2 L', 'Refrigerante sabor cola', 'UN', 11.99, 48, 12),
    (2, 'CAR-006', 'Agua mineral 1,5 L', 'Agua mineral sem gas', 'UN', 3.49, 100, 24),
    (3, 'CAR-007', 'Sabonete 90 g', 'Sabonete corporal neutro', 'UN', 4.29, 80, 20),
    (3, 'CAR-008', 'Creme dental 90 g', 'Creme dental com fluor', 'UN', 7.89, 65, 15),
    (4, 'CAR-009', 'Detergente 500 ml', 'Detergente liquido neutro', 'UN', 2.99, 90, 20),
    (4, 'CAR-010', 'Desinfetante 2 L', 'Desinfetante de uso geral', 'UN', 8.49, 45, 10),
    (5, 'CAR-011', 'Vassoura multiuso', 'Vassoura para limpeza domestica', 'UN', 16.90, 25, 5),
    (5, 'CAR-012', 'Pano de chao', 'Pano de algodao para limpeza', 'UN', 6.50, 70, 15);

-- 7. RELACIONAMENTOS ENTRE PRODUTOS E FORNECEDORES (16 registros)
INSERT INTO produto_fornecedor (
    id_produto,
    id_fornecedor,
    preco_compra,
    prazo_entrega_dias,
    fornecedor_principal
)
VALUES
    (1, 1, 25.50, 3, TRUE),
    (1, 2, 26.00, 2, FALSE),
    (2, 1, 6.30, 3, TRUE),
    (2, 2, 6.50, 2, FALSE),
    (3, 2, 3.60, 2, TRUE),
    (4, 1, 14.00, 3, TRUE),
    (5, 3, 8.20, 1, TRUE),
    (5, 2, 8.50, 2, FALSE),
    (6, 3, 1.80, 1, TRUE),
    (7, 4, 2.30, 4, TRUE),
    (8, 4, 4.80, 4, TRUE),
    (9, 5, 1.55, 3, TRUE),
    (9, 2, 1.70, 2, FALSE),
    (10, 5, 5.20, 3, TRUE),
    (11, 5, 10.90, 3, TRUE),
    (12, 5, 3.40, 3, TRUE);

-- 8. PEDIDOS (6 registros)
INSERT INTO pedido (
    id_cliente,
    id_funcionario,
    data_pedido,
    status_pedido,
    observacao
)
VALUES
    (1, 1, '2026-09-01 09:15:00', 'concluido', 'Compra realizada no caixa 1'),
    (2, 2, '2026-09-02 14:30:00', 'concluido', 'Cliente solicitou sacola'),
    (1, 1, '2026-09-03 10:20:00', 'concluido', NULL),
    (3, 3, '2026-09-04 16:45:00', 'concluido', 'Retirada no balcao'),
    (4, 2, '2026-09-05 11:10:00', 'concluido', 'Pagamento dividido'),
    (5, 4, '2026-09-06 18:05:00', 'pago', 'Aguardando encerramento do caixa');

-- 9. ITENS DOS PEDIDOS (13 registros)
INSERT INTO item_pedido (
    id_pedido,
    id_produto,
    quantidade,
    preco_unitario
)
VALUES
    (1, 1, 1, 32.90),
    (1, 2, 2, 8.99),
    (2, 5, 2, 11.99),
    (2, 6, 4, 3.49),
    (3, 3, 3, 5.49),
    (3, 4, 1, 18.90),
    (4, 7, 4, 4.29),
    (4, 8, 2, 7.89),
    (5, 9, 5, 2.99),
    (5, 10, 2, 8.49),
    (5, 12, 3, 6.50),
    (6, 11, 1, 16.90),
    (6, 1, 1, 32.90);

-- 10. PAGAMENTOS (7 registros)
INSERT INTO pagamento (
    id_pedido,
    forma_pagamento,
    valor_pagamento,
    data_pagamento,
    status_pagamento
)
VALUES
    (1, 'pix', 50.88, '2026-09-01 09:20:00', 'aprovado'),
    (2, 'cartao_credito', 37.94, '2026-09-02 14:35:00', 'aprovado'),
    (3, 'dinheiro', 35.37, '2026-09-03 10:25:00', 'aprovado'),
    (4, 'cartao_debito', 32.94, '2026-09-04 16:50:00', 'aprovado'),
    (5, 'dinheiro', 25.00, '2026-09-05 11:15:00', 'aprovado'),
    (5, 'pix', 26.43, '2026-09-05 11:16:00', 'aprovado'),
    (6, 'pix', 49.80, '2026-09-06 18:10:00', 'aprovado');

COMMIT;

-- ============================================================
-- CONFERENCIA: quantidade de registros por tabela
-- Resultado esperado: todas as tabelas com 5 ou mais registros
-- Total esperado: 80 registros
-- ============================================================

WITH contagens (tabela, quantidade, ordem) AS (
    SELECT 'cliente', COUNT(*), 1 FROM cliente
    UNION ALL
    SELECT 'endereco', COUNT(*), 2 FROM endereco
    UNION ALL
    SELECT 'funcionario', COUNT(*), 3 FROM funcionario
    UNION ALL
    SELECT 'categoria', COUNT(*), 4 FROM categoria
    UNION ALL
    SELECT 'fornecedor', COUNT(*), 5 FROM fornecedor
    UNION ALL
    SELECT 'produto', COUNT(*), 6 FROM produto
    UNION ALL
    SELECT 'produto_fornecedor', COUNT(*), 7 FROM produto_fornecedor
    UNION ALL
    SELECT 'pedido', COUNT(*), 8 FROM pedido
    UNION ALL
    SELECT 'item_pedido', COUNT(*), 9 FROM item_pedido
    UNION ALL
    SELECT 'pagamento', COUNT(*), 10 FROM pagamento
)
SELECT tabela, quantidade
FROM (
    SELECT tabela, quantidade, ordem
    FROM contagens

    UNION ALL

    SELECT 'TOTAL', SUM(quantidade), 99
    FROM contagens
) AS resultado
ORDER BY ordem;
