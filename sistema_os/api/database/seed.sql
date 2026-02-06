-- ======================================
-- BANCO E USUÁRIOS
-- ======================================

CREATE DATABASE IF NOT EXISTS os_agricola;
USE os_agricola;

-- ======================================
-- USERS
-- ======================================

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  cargo VARCHAR(50) NOT NULL
);

-- Senha hash bcrypt de "123456"
-- hash: $2b$10$Qb5M2PE3iV1/pnXl16rE9eHKePNlSx5GQ98XKRQQwAxWAj5v3aGTC

INSERT INTO users (nome, email, password, cargo) VALUES
('Carlos Operador', 'operador@agro.com', '$2b$10$Qb5M2PE3iV1/pnXl16rE9eHKePNlSx5GQ98XKRQQwAxWAj5v3aGTC', 'operador'),
('João Manutenção', 'manutencao@agro.com', '$2b$10$Qb5M2PE3iV1/pnXl16rE9eHKePNlSx5GQ98XKRQQwAxWAj5v3aGTC', 'manutencao'),
('Marcos Gestor', 'gestor@agro.com', '$2b$10$Qb5M2PE3iV1/pnXl16rE9eHKePNlSx5GQ98XKRQQwAxWAj5v3aGTC', 'gestor');


-- ======================================
-- SECTORS
-- ======================================

CREATE TABLE IF NOT EXISTS sectors (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL
);

INSERT INTO sectors (nome) VALUES
('Produção'),
('Embalagem'),
('Armazenamento'),
('Expedição');


-- ======================================
-- MACHINES
-- ======================================

CREATE TABLE IF NOT EXISTS machines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  sector_id INT,
  FOREIGN KEY (sector_id) REFERENCES sectors(id)
);

INSERT INTO machines (nome, sector_id) VALUES
('Esteira 01', 1),
('Prensa 02', 1),
('Empacotadora 01', 2),
('Seladora 01', 2),
('Paleteira 01', 3);


-- ======================================
-- ORDERS (OS)
-- ======================================

CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  setor VARCHAR(100) NOT NULL,
  maquina VARCHAR(100) NOT NULL,
  prioridade ENUM('alta','media','baixa') NOT NULL,
  descricao TEXT NOT NULL,
  status ENUM('aberto','em_execucao','concluido') NOT NULL DEFAULT 'aberto',
  causa_raiz TEXT NULL,
  custo DECIMAL(10,2) NULL,
  operador_id INT NOT NULL,
  manutencao_id INT NULL,
  data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_fechamento TIMESTAMP NULL,
  code VARCHAR(50) NOT NULL,
  FOREIGN KEY (operador_id) REFERENCES users(id),
  FOREIGN KEY (manutencao_id) REFERENCES users(id)
);

-- INSERIR UMA OS EXEMPLO
INSERT INTO orders (setor, maquina, prioridade, descricao, operador_id, code)
VALUES ('Produção', 'Esteira 01', 'alta', 'Correia está escapando', 1, 'OS-TESTE-001');
