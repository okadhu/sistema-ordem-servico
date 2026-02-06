-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS os_agricola;
USE os_agricola;

-- ======================
--       USERS
-- ======================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    matricula VARCHAR(20),
    cargo ENUM('operador', 'manutencao', 'gestor') NOT NULL DEFAULT 'operador',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
--       ORDERS
-- ======================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setor VARCHAR(100) NOT NULL,
    maquina VARCHAR(100) NOT NULL,
    prioridade ENUM('alta', 'media', 'baixa') NOT NULL,
    descricao TEXT NOT NULL,
    status ENUM('aberto', 'em_execucao', 'concluido') NOT NULL DEFAULT 'aberto',
    causa_raiz TEXT,
    custo DECIMAL(10,2),

    operador_id INT NOT NULL,
    manutencao_id INT,

    data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP NULL,

    FOREIGN KEY (operador_id) REFERENCES users(id),
    FOREIGN KEY (manutencao_id) REFERENCES users(id)
);

-- ======================
--    HISTÓRICO (LOG)
-- ======================
CREATE TABLE IF NOT EXISTS order_updates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    usuario_id INT NOT NULL,
    acao VARCHAR(100) NOT NULL,
    detalhes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (usuario_id) REFERENCES users(id)
);
