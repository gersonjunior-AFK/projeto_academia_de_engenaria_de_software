CREATE DATABASE smartpark;

USE smartpark;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_cliente),
    UNIQUE (cpf),
    UNIQUE (email)
);

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    placa VARCHAR(7) NOT NULL,
    modelo VARCHAR(60) NOT NULL,
    marca VARCHAR(40),
    cor VARCHAR(30),
    tipo_veiculo ENUM('CARRO', 'MOTO', 'UTILITARIO') NOT NULL,
    tipo_energia ENUM('FLEX', 'GASOLINA', 'DIESEL', 'HIBRIDO', 'ELETRICO') NOT NULL,
    PRIMARY KEY (id_veiculo),
    UNIQUE (placa),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE vaga (
    id_vaga INT AUTO_INCREMENT,
    codigo VARCHAR(10) NOT NULL,
    setor VARCHAR(20) NOT NULL,
    tipo ENUM('COMUM', 'PREFERENCIAL', 'ELETRICA', 'MOTO') NOT NULL,
    status_ocupacao ENUM('DISPONIVEL', 'OCUPADA', 'RESERVADA', 'MANUTENCAO') NOT NULL DEFAULT 'DISPONIVEL',
    valor_hora DECIMAL(8,2) NOT NULL,
    ativa BOOLEAN DEFAULT TRUE,
    ultima_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vaga),
    UNIQUE (codigo),
    CHECK (valor_hora >= 0)
);

CREATE TABLE equipamento (
    id_equipamento INT AUTO_INCREMENT,
    id_vaga INT NULL,
    codigo VARCHAR(20) NOT NULL,
    nome VARCHAR(80) NOT NULL,
    tipo ENUM('CAMERA', 'SENSOR', 'CANCELA', 'MAQUINA_TICKET', 'MAQUINA_PAGAMENTO') NOT NULL,
    localizacao VARCHAR(100),
    status ENUM('ONLINE', 'OFFLINE', 'MANUTENCAO') NOT NULL DEFAULT 'ONLINE',
    data_instalacao DATE,
    ultima_comunicacao DATETIME,
    PRIMARY KEY (id_equipamento),
    UNIQUE (codigo),
    FOREIGN KEY (id_vaga) REFERENCES vaga(id_vaga),
    CHECK (
        (tipo = 'SENSOR' AND id_vaga IS NOT NULL)
        OR
        (tipo <> 'SENSOR' AND id_vaga IS NULL)
    )
);

CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_vaga INT NOT NULL,
    modalidade ENUM('EVENTO', 'AEROPORTO', 'MENSAL', 'ANTECIPADA') NOT NULL,
    data_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    inicio_reserva DATETIME NOT NULL,
    fim_reserva DATETIME NOT NULL,
    status ENUM('ATIVA', 'CONCLUIDA', 'CANCELADA') NOT NULL DEFAULT 'ATIVA',
    PRIMARY KEY (id_reserva),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vaga) REFERENCES vaga(id_vaga),
    CHECK (fim_reserva > inicio_reserva)
);

CREATE TABLE ticket (
    id_ticket INT AUTO_INCREMENT,
    id_veiculo INT NOT NULL,
    id_equipamento INT NOT NULL,
    codigo_ticket VARCHAR(30) NOT NULL,
    codigo_qr VARCHAR(100) NOT NULL,
    data_emissao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('EMITIDO', 'UTILIZADO', 'CANCELADO') NOT NULL DEFAULT 'EMITIDO',
    PRIMARY KEY (id_ticket),
    UNIQUE (codigo_ticket),
    UNIQUE (codigo_qr),
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento)
);

CREATE TABLE estacionamento (
    id_estacionamento INT AUTO_INCREMENT,
    id_ticket INT NOT NULL,
    id_vaga INT NOT NULL,
    id_reserva INT NULL,
    id_equipamento_entrada INT NOT NULL,
    id_equipamento_saida INT NULL,
    data_entrada DATETIME NOT NULL,
    data_saida DATETIME NULL,
    status ENUM('EM_ANDAMENTO', 'FINALIZADO', 'CANCELADO') NOT NULL DEFAULT 'EM_ANDAMENTO',
    PRIMARY KEY (id_estacionamento),
    UNIQUE (id_ticket),
    UNIQUE (id_reserva),
    FOREIGN KEY (id_ticket) REFERENCES ticket(id_ticket),
    FOREIGN KEY (id_vaga) REFERENCES vaga(id_vaga),
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
    FOREIGN KEY (id_equipamento_entrada) REFERENCES equipamento(id_equipamento),
    FOREIGN KEY (id_equipamento_saida) REFERENCES equipamento(id_equipamento),
    CHECK (
        (status = 'FINALIZADO' AND data_saida IS NOT NULL)
        OR
        (status <> 'FINALIZADO' AND data_saida IS NULL)
    ),
    CHECK (data_saida IS NULL OR data_saida >= data_entrada)
);

CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT,
    id_estacionamento INT NOT NULL,
    id_equipamento INT NULL,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento ENUM('CREDITO', 'DEBITO', 'PIX', 'DINHEIRO') NOT NULL,
    status ENUM('APROVADO', 'PENDENTE', 'RECUSADO', 'ESTORNADO') NOT NULL DEFAULT 'PENDENTE',
    data_pagamento DATETIME NULL,
    PRIMARY KEY (id_pagamento),
    UNIQUE (id_estacionamento),
    FOREIGN KEY (id_estacionamento) REFERENCES estacionamento(id_estacionamento),
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id_equipamento),
    CHECK (valor >= 0)
);

CREATE INDEX idx_veiculo_cliente ON veiculo(id_cliente);
CREATE INDEX idx_reserva_cliente ON reserva(id_cliente);
CREATE INDEX idx_reserva_vaga ON reserva(id_vaga);
CREATE INDEX idx_ticket_veiculo ON ticket(id_veiculo);
CREATE INDEX idx_estacionamento_vaga ON estacionamento(id_vaga);
CREATE INDEX idx_estacionamento_entrada ON estacionamento(data_entrada);
CREATE INDEX idx_pagamento_data ON pagamento(data_pagamento);

INSERT INTO cliente (nome, cpf, telefone, email)
VALUES
('Carlos Mendes', '11111111111', '61990000001', 'carlos@email.com'),
('Mariana Souza', '22222222222', '61990000002', 'mariana@email.com'),
('Roberto Lima', '33333333333', '61990000003', 'roberto@email.com'),
('Ana Ferreira', '44444444444', '61990000004', 'ana@email.com'),
('Lucas Oliveira', '55555555555', '61990000005', 'lucas@email.com');

INSERT INTO veiculo (id_cliente, placa, modelo, marca, cor, tipo_veiculo, tipo_energia)
VALUES
(1, 'ABC1D23', 'Onix', 'Chevrolet', 'Prata', 'CARRO', 'FLEX'),
(2, 'DEF2G34', 'Model 3', 'Tesla', 'Branco', 'CARRO', 'ELETRICO'),
(3, 'HIJ3K45', 'CG 160', 'Honda', 'Preta', 'MOTO', 'GASOLINA'),
(4, 'LMN4O56', 'Corolla', 'Toyota', 'Cinza', 'CARRO', 'HIBRIDO'),
(5, 'PQR5S67', 'Fiorino', 'Fiat', 'Branca', 'UTILITARIO', 'FLEX'),
(1, 'TUV6W78', 'Biz 125', 'Honda', 'Vermelha', 'MOTO', 'GASOLINA'),
(2, 'XYZ7A89', 'Compass', 'Jeep', 'Preta', 'CARRO', 'DIESEL');

INSERT INTO vaga (codigo, setor, tipo, status_ocupacao, valor_hora, ativa)
VALUES
('A01', 'A', 'COMUM', 'RESERVADA', 12.00, TRUE),
('A02', 'A', 'PREFERENCIAL', 'DISPONIVEL', 12.00, TRUE),
('A03', 'A', 'PREFERENCIAL', 'DISPONIVEL', 12.00, TRUE),
('B01', 'B', 'ELETRICA', 'RESERVADA', 18.00, TRUE),
('B02', 'B', 'ELETRICA', 'DISPONIVEL', 18.00, TRUE),
('C01', 'C', 'MOTO', 'OCUPADA', 6.00, TRUE),
('C02', 'C', 'COMUM', 'OCUPADA', 12.00, TRUE),
('D01', 'D', 'COMUM', 'DISPONIVEL', 12.00, TRUE);

INSERT INTO equipamento (id_vaga, codigo, nome, tipo, localizacao, status, data_instalacao, ultima_comunicacao)
VALUES
(1, 'SEN-A01', 'Sensor da vaga A01', 'SENSOR', 'Setor A - A01', 'ONLINE', '2026-01-10', NOW()),
(2, 'SEN-A02', 'Sensor da vaga A02', 'SENSOR', 'Setor A - A02', 'ONLINE', '2026-01-10', NOW()),
(3, 'SEN-A03', 'Sensor da vaga A03', 'SENSOR', 'Setor A - A03', 'ONLINE', '2026-01-10', NOW()),
(4, 'SEN-B01', 'Sensor da vaga B01', 'SENSOR', 'Setor B - B01', 'ONLINE', '2026-01-10', NOW()),
(5, 'SEN-B02', 'Sensor da vaga B02', 'SENSOR', 'Setor B - B02', 'ONLINE', '2026-01-10', NOW()),
(6, 'SEN-C01', 'Sensor da vaga C01', 'SENSOR', 'Setor C - C01', 'ONLINE', '2026-01-10', NOW()),
(7, 'SEN-C02', 'Sensor da vaga C02', 'SENSOR', 'Setor C - C02', 'ONLINE', '2026-01-10', NOW()),
(8, 'SEN-D01', 'Sensor da vaga D01', 'SENSOR', 'Setor D - D01', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'CAM-ENT', 'Camera de entrada', 'CAMERA', 'Entrada principal', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'CAM-SAI', 'Camera de saida', 'CAMERA', 'Saida principal', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'CAN-ENT', 'Cancela de entrada', 'CANCELA', 'Entrada principal', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'CAN-SAI', 'Cancela de saida', 'CANCELA', 'Saida principal', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'TCK-001', 'Maquina de tickets', 'MAQUINA_TICKET', 'Entrada principal', 'ONLINE', '2026-01-10', NOW()),
(NULL, 'PGT-001', 'Terminal de pagamento', 'MAQUINA_PAGAMENTO', 'Area de pagamento', 'ONLINE', '2026-01-10', NOW());

INSERT INTO reserva (id_cliente, id_vaga, modalidade, data_reserva, inicio_reserva, fim_reserva, status)
VALUES
(1, 1, 'ANTECIPADA', '2026-11-01 10:00:00', '2026-11-10 08:00:00', '2026-11-10 12:00:00', 'ATIVA'),
(2, 4, 'AEROPORTO', '2026-11-01 11:00:00', '2026-11-10 07:00:00', '2026-11-12 20:00:00', 'ATIVA'),
(2, 5, 'EVENTO', '2026-10-20 09:00:00', '2026-10-25 18:00:00', '2026-10-25 23:00:00', 'CONCLUIDA'),
(4, 8, 'ANTECIPADA', '2026-10-22 14:00:00', '2026-10-28 09:00:00', '2026-10-28 12:00:00', 'CANCELADA'),
(5, 2, 'MENSAL', '2026-10-01 08:00:00', '2026-10-05 08:00:00', '2026-10-31 20:00:00', 'CONCLUIDA');

INSERT INTO ticket (id_veiculo, id_equipamento, codigo_ticket, codigo_qr, data_emissao, status)
VALUES
(3, 13, 'TK-0001', 'QR-SMART-0001', '2026-11-03 08:00:00', 'EMITIDO'),
(4, 13, 'TK-0002', 'QR-SMART-0002', '2026-11-03 08:30:00', 'EMITIDO'),
(1, 13, 'TK-0003', 'QR-SMART-0003', '2026-10-30 09:00:00', 'UTILIZADO'),
(5, 13, 'TK-0004', 'QR-SMART-0004', '2026-10-30 10:00:00', 'UTILIZADO'),
(7, 13, 'TK-0005', 'QR-SMART-0005', '2026-10-25 18:00:00', 'UTILIZADO'),
(6, 13, 'TK-0006', 'QR-SMART-0006', '2026-10-29 13:00:00', 'UTILIZADO'),
(2, 13, 'TK-0007', 'QR-SMART-0007', '2026-10-31 14:00:00', 'UTILIZADO');

INSERT INTO estacionamento
(id_ticket, id_vaga, id_reserva, id_equipamento_entrada, id_equipamento_saida, data_entrada, data_saida, status)
VALUES
(1, 6, NULL, 9, NULL, '2026-11-03 08:00:00', NULL, 'EM_ANDAMENTO'),
(2, 7, NULL, 9, NULL, '2026-11-03 08:30:00', NULL, 'EM_ANDAMENTO'),
(3, 8, NULL, 9, 10, '2026-10-30 09:00:00', '2026-10-30 11:00:00', 'FINALIZADO'),
(4, 8, NULL, 9, 10, '2026-10-30 10:00:00', '2026-10-30 13:00:00', 'FINALIZADO'),
(5, 5, 3, 9, 10, '2026-10-25 18:00:00', '2026-10-25 22:00:00', 'FINALIZADO'),
(6, 8, NULL, 9, 10, '2026-10-29 13:00:00', '2026-10-29 15:00:00', 'FINALIZADO'),
(7, 8, NULL, 9, 10, '2026-10-31 14:00:00', '2026-10-31 17:00:00', 'FINALIZADO');

INSERT INTO pagamento
(id_estacionamento, id_equipamento, valor, forma_pagamento, status, data_pagamento)
VALUES
(3, 14, 24.00, 'PIX', 'APROVADO', '2026-10-30 11:05:00'),
(4, 14, 36.00, 'CREDITO', 'APROVADO', '2026-10-30 13:05:00'),
(5, 14, 72.00, 'DEBITO', 'APROVADO', '2026-10-25 22:05:00'),
(6, 14, 12.00, 'DINHEIRO', 'APROVADO', '2026-10-29 15:05:00'),
(7, 14, 36.00, 'PIX', 'APROVADO', '2026-10-31 17:05:00');

SELECT
    codigo AS vaga,
    setor,
    tipo,
    valor_hora
FROM vaga
WHERE status_ocupacao = 'DISPONIVEL'
  AND ativa = TRUE
ORDER BY setor, codigo;

SELECT
    c.nome AS cliente,
    v.placa,
    v.modelo,
    va.codigo AS vaga,
    e.data_entrada,
    e.status
FROM estacionamento e
INNER JOIN ticket t ON e.id_ticket = t.id_ticket
INNER JOIN veiculo v ON t.id_veiculo = v.id_veiculo
INNER JOIN cliente c ON v.id_cliente = c.id_cliente
INNER JOIN vaga va ON e.id_vaga = va.id_vaga
WHERE e.status = 'EM_ANDAMENTO'
ORDER BY e.data_entrada;

SELECT
    tipo,
    COUNT(*) AS quantidade_vagas
FROM vaga
WHERE ativa = TRUE
GROUP BY tipo
ORDER BY quantidade_vagas DESC;

SELECT
    forma_pagamento,
    COUNT(*) AS quantidade_pagamentos,
    SUM(valor) AS faturamento_total
FROM pagamento
WHERE status = 'APROVADO'
GROUP BY forma_pagamento
ORDER BY faturamento_total DESC;

SELECT
    c.nome AS cliente,
    v.placa,
    va.codigo AS vaga,
    e.data_entrada,
    e.data_saida,
    TIMESTAMPDIFF(MINUTE, e.data_entrada, e.data_saida) AS tempo_permanencia_minutos,
    e.status
FROM estacionamento e
INNER JOIN ticket t ON e.id_ticket = t.id_ticket
INNER JOIN veiculo v ON t.id_veiculo = v.id_veiculo
INNER JOIN cliente c ON v.id_cliente = c.id_cliente
INNER JOIN vaga va ON e.id_vaga = va.id_vaga
WHERE e.status = 'FINALIZADO'
ORDER BY e.data_entrada DESC;

SELECT
    eq.codigo,
    eq.nome,
    eq.tipo,
    va.codigo AS vaga_associada,
    eq.localizacao,
    eq.status,
    eq.ultima_comunicacao
FROM equipamento eq
LEFT JOIN vaga va ON eq.id_vaga = va.id_vaga
ORDER BY eq.tipo, eq.codigo;

SELECT
    r.id_reserva,
    c.nome AS cliente,
    va.codigo AS vaga,
    va.tipo AS tipo_vaga,
    r.modalidade,
    r.inicio_reserva,
    r.fim_reserva,
    r.status
FROM reserva r
INNER JOIN cliente c ON r.id_cliente = c.id_cliente
INNER JOIN vaga va ON r.id_vaga = va.id_vaga
WHERE r.status = 'ATIVA'
ORDER BY r.inicio_reserva;

SELECT
    tipo,
    status_ocupacao,
    COUNT(*) AS quantidade
FROM vaga
WHERE ativa = TRUE
GROUP BY tipo, status_ocupacao
ORDER BY tipo, status_ocupacao;