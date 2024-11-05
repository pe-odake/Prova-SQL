CREATE DATABASE DB_Biblioteca
USE DB_Biblioteca

--CRIANDO AS TABELAS
CREATE TABLE Leitores (
	idLeitor INT PRIMARY KEY,
	nomeLeitor VARCHAR (100),
	dataNasc DATE,
	CPF VARCHAR(14) unique,
	generoFavorito VARCHAR (50)
)

CREATE TABLE Livros(
	idLivro INT PRIMARY KEY,
	idleitor INT NULL,
	nomeLivro VARCHAR (100),
	dataPublicação DATE,
	idAutor INT,
	idEditora INT,
	idEstante INT,
	idPrateleira INT,
	genero VARCHAR (50)
)

CREATE TABLE Autores(
	idAutor INT PRIMARY KEY,
	nomeAutor VARCHAR (100),
	dataNasc DATE,
)

CREATE TABLE Editora(
	idEditora INT PRIMARY KEY,
	nomeEditora VARCHAR (100)
)

--INSERINDO VALORES A TABELA
INSERT INTO Leitores (idLeitor, nomeLeitor, dataNasc, CPF, generoFavorito)
VALUES
	(1, 'Pedro Souza', '2000-05-12', '123.456.789-10', 'Fantasia'),
	(2, 'Alberto Luis', '1990-02-22', '987.654.321-09', 'Drama'),
	(3, 'Mirella Rodrigues', '2001-03-05', '456.789.123-45', 'Romance'),
	(4, 'João Silva', '2002-05-15', '111.222.333-45', 'Fantasia'),
	(5, 'Lucas Pratos', '2000-10-19', '101.202.303-99', 'Comédia')

INSERT INTO Livros( idLivro, idleitor, nomeLivro, dataPublicação, idAutor, idEditora ,idEstante, idPrateleira, genero)
VALUES
	(1, NULL,'Dom Casmurro', '1888-05-12', 1, 10 ,101, 1, 'Historico'), -- o idLeitor null quer dizer que ele não esta com ninguem, e esta disponivel para ler
	(2, 2,'O Alienista', '1885-08-22', 1, 10 ,101, 4,'Historico'),
	(3, 4,'As Crônicas de Nárnia', '1954-05-06', 2, 20 ,201, 2,'Fantasia'),
	(4, 3,'1984', '1964-05-10', 3, 10 ,102, 3,'Suspense'),
	(5, 5,'Revolução dos Bichos', '1959-12-09', 3, 30 ,102, 3,'Suspense')

INSERT INTO Autores (idAutor, nomeAutor, dataNasc)
VALUES
	
	(1, 'Machado de Assis' ,'1840-10-12' ),
	(2, 'C. S. Lewis' ,'1899-12-25'),
	(3, 'George Orwell' ,'1920-03-06')

INSERT INTO Editora (idEditora, nomeEditora)
VALUES
	
	(10, 'Alfa' ),
	(20, 'Beta'),
	(30, 'Gama')
		

--CRIANDO AS CHAVES ESTRANGEIRAS

ALTER TABLE Livros
ADD CONSTRAINT FK_Livros_Autor FOREIGN KEY (IdAutor)
REFERENCES Autores (IdAutor);

ALTER TABLE Livros
ADD CONSTRAINT FK_Livros_Editora FOREIGN KEY (IdEditora)
REFERENCES Editora (IdEditora);

ALTER TABLE Livros
ADD CONSTRAINT FK_Livros_leitor FOREIGN KEY (idLeitor)
REFERENCES  Leitores (idLeitor);

SELECT * FROM Livros 
SELECT * FROM Leitores
SELECT * FROM Autores
SELECT * FROM Editora



--- SUBQUERY
--- SUBQUERY QUE SELECIONA OS LIVORS COM O AUTOR NASCIDO DEPOIS DE 1880
SELECT 
	idLivro,
	nomeLivro

FROM Livros
WHERE idAutor IN (SELECT idAutor FROM Autores WHERE dataNasc > '1880')

--- VIEW
--- VIEW QUE CONTA QUANTOS LIVROS TEM CADA AUTOR

CREATE VIEW quantDeAutorPorLivro AS

SELECT 
	nomeAutor,
	COUNT(b.idAutor) AS 'Número de Livros por Autor'

FROM Autores AS a
INNER JOIN Livros AS b
ON a.idAutor = b.idAutor
GROUP BY nomeAutor

SELECT * FROM quantDeAutorPorLivro 

--- FUNCTION
--- FUNÇÃO QUE TRAZ A IDADE DOS AUTORES CASO FOSSEM VIVOS

CREATE FUNCTION calcIdade (@dataNasc DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @dataNasc, GETDATE());
END;

SELECT 
	nomeAutor, 
	dbo.calcIdade(dataNasc) AS Idade

FROM Autores

--- PROCEDURES
--- PROCEDURES QUE ADICIONA NOVOS LIVROS AO CATALOGO

IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'SP_ADD_lIVROS')
	BEGIN
		DROP PROCEDURE SP_ADD_LIVROS
	END
GO

CREATE PROCEDURE SP_ADD_LIVROS
	@idLivro INT,
	@idleitor INT NULL,
	@nomeLivro VARCHAR (100),
	@dataPublicação DATE,
	@idAutor INT,
	@idEditora INT,
	@idEstante INT,
	@idPrateleira INT,
	@genero VARCHAR (50)

AS
    INSERT INTO Livros ( idLivro, idleitor, nomeLivro, dataPublicação, idAutor, idEditora ,idEstante, idPrateleira, genero)
	VALUES (@idLivro, @idleitor, @nomeLivro, @dataPublicação, @idAutor, @idEditora, @idEstante, @idPrateleira, @genero)
GO

EXEC SP_ADD_LIVROS 6, 1, 'Contos de Machado de Assis', '2021-01-01', 1, 10, 301, 1, 'Contos'

--- TRIGGER
--- TRIGGER QUE FAZ PRINT DE MENSAGEM DO LIVRO QUE ACABOU DE SER ADICIONADO
CREATE TRIGGER livro_Adicionado 
ON Livros
AFTER INSERT 
AS
BEGIN
	DECLARE @ultimo_livro VARCHAR(100);
	SELECT @ultimo_livro = nomeLivro FROM Livros ORDER BY idLivro ASC;

	PRINT @ultimo_Livro + ' adicionado com sucesso'
END
GO


--- LOOPS 

DECLARE @tabelaAtual INT = 1;
DECLARE @totalTabelas INT = 4;
DECLARE @nomeTabela VARCHAR(50);
DECLARE @quantidade INT;

WHILE @tabelaAtual <= @totalTabelas
BEGIN
    SET @nomeTabela = CASE @tabelaAtual
                      WHEN 1 THEN 'Autores'
                      WHEN 2 THEN 'leitores'
                      WHEN 3 THEN 'Livros'
                      WHEN 4 THEN 'Editora'
                      END; 

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT @quantidade = COUNT(*) FROM ' + @nomeTabela;
    EXEC sp_executesql @sql, N'@quantidade INT OUTPUT', @quantidade OUTPUT;
    PRINT 'A tabela ' + @nomeTabela + ' possui ' + CAST(@quantidade AS VARCHAR) + ' linhas';
    SET @tabelaAtual = @tabelaAtual + 1;
END

--- CTE
--- CTE PARA AUTORES DE ACORCO COM SEU GENERO FAVORITO

WITH Genero_Autor
AS(
	SELECT
		nomeAutor,
		STRING_AGG(b.genero, ', ') AS 'Generos do Autor'

	FROM Autores AS a
	INNER JOIN Livros AS b
	ON a.idAutor = b.idAutor
	GROUP BY nomeAutor
)
SELECT * FROM Genero_Autor

--WINDOW FUNCTION

SELECT 
	nomeEditora,
	b.nomeLivro,
	COUNT(b.idLivro) OVER (PARTITION BY nomeEditora) AS 'Número de livros da Editora'

FROM Editora AS a
INNER JOIN Livros AS b
ON a.idEditora = b.idEditora



