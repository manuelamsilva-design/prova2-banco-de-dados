
CREATE TABLE jogadores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    senha VARCHAR (50) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ativo',
    data_cadastro    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT status_jogador CHECK (status IN ('ativo', 'inativo', 'banido'))
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(100) NOT NULL
);

CREATE TABLE torneios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'inscricoes',
        CHECK (status IN ('inscricoes', 'em_andamento', 'encerrado', 'cancelado'))
);

CREATE TABLE partidas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(120) NOT NULL,
    id_jogador INTEGER NOT NULL,
    id_modalidade INTEGER NOT NULL,
    id_torneio INTEGER NOT NULL,
    data_agendada TIMESTAMP NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'agendada',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resultado VARCHAR(150),
    CONSTRAINT fk_partida_jogador FOREIGN KEY (id_jogador) REFERENCES jogadores(id),
    CONSTRAINT fk_partida_modalidade FOREIGN KEY (id_modalidade) REFERENCES modalidades(id),
    CONSTRAINT fk_partida_torneio FOREIGN KEY (id_torneio) REFERENCES torneios(id),
    CONSTRAINT status_partida CHECK (status IN ('agendada', 'em_andamento', 'concluida', 'cancelada'))
);

CREATE TABLE historico_partidas (
    id SERIAL PRIMARY KEY,
    id_partida INTEGER NOT NULL,
    acao VARCHAR(50) NOT NULL,
    descricao VARCHAR(200) NOT NULL,
    data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historico_partida FOREIGN KEY (id_partida) REFERENCES partidas(id) ON DELETE CASCADE
);

INSERT INTO jogadores (nome, email, senha, status) VALUES
('Manuela', 'manuela@email.com', 'senha123', 'ativo'),
('Gabriel', 'gabriel@email.com', 'senha456', 'ativo'),
('Felipe', 'felipe@email.com', 'senha789', 'inativo');

INSERT INTO modalidades (nome, categoria) VALUES
('League of Legends', 'MOBA'),
('Counter-Strike 2', 'FPS'),
('Rocket League', 'Esporte eletrônico');

INSERT INTO torneios (nome, data_inicio, data_fim, status) VALUES
('Copa Gamer SC', '2026-12-01', '2026-12-10', 'inscricoes'),
('Desafio Arena Digital', '2027-01-10', '2027-01-20', 'inscricoes'),
('Festival E-sports Sul', '2027-02-05', '2027-02-15', 'inscricoes');

INSERT INTO partidas (titulo, id_jogador, id_modalidade, id_torneio, data_agendada, status, resultado) VALUES
('Manuela x Convidado A', 1, 1, 1, '2026-12-03 14:00:00', 'agendada', NULL),
('Gabriel x Convidado B', 2, 2, 2, '2027-01-12 16:30:00', 'agendada', NULL),
('Manuela x Convidado C', 1, 3, 3, '2027-02-08 19:00:00', 'agendada', NULL);

CREATE OR REPLACE FUNCTION fn_buscar_jogadores (p_termo TEXT) 
RETURNS TABLE (
    id_jogador INTEGER,
    nome VARCHAR(40),
    email VARCHAR(120),
    status VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT j.id_jogador, j.nome, j.email, j.status
    FROM jogadores j
    WHERE j.nome ILIKE '%' || p_termo || '%' OR j.email ILIKE '%' || p_termo || '%'
    ORDER BY j.nome;
END; $$;

CREATE VIEW vw_painel_principal AS
SELECT
    j.nome,
    p.titulo,
    m.categoria,
    p.data_agendada,
    p.status
FROM partidas p
JOIN jogadores j ON p.id_jogador = j.id
JOIN modalidades m ON p.id_modalidade = m.id;

CREATE VIEW vw_cronograma_partidas AS
SELECT
    p.id,
    p.titulo,
    p.data_agendada,
    p.status,
    (p.data_agendada::DATE - CURRENT_DATE) AS dias_restantes,
    j.nome
FROM partidas p
JOIN jogadores j ON p.id_jogador = j.id