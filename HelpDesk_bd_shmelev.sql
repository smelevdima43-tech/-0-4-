USE HelpDesk_Фамилия; -- ЗАМЕНИТЕ Фамилия на свою!
GO

-- УДАЛЯЕМ СТАРЫЕ ТАБЛИЦЫ, ЧТОБЫ ИВАНОВ И ДУБЛИ ИСЧЕЗЛИ НАВСЕГДА
DROP TABLE IF EXISTS Tickets;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Priorities;
DROP TABLE IF EXISTS Statuses;
DROP TABLE IF EXISTS Roles;
GO

-- Создание таблиц заново
CREATE TABLE Roles 
( Id INT IDENTITY(1,1) PRIMARY KEY, Name NVARCHAR(50) NOT NULL UNIQUE ); 
GO

CREATE TABLE Categories 
( Id INT IDENTITY(1,1) PRIMARY KEY, Name NVARCHAR(100) NOT NULL UNIQUE ); 
GO

CREATE TABLE Priorities 
( Id INT IDENTITY(1,1) PRIMARY KEY, Name NVARCHAR(50) NOT NULL UNIQUE, SortOrder INT NOT NULL ); 
GO

CREATE TABLE Statuses
( Id INT IDENTITY(1,1) PRIMARY KEY, Name NVARCHAR(50) NOT NULL UNIQUE );
GO

CREATE TABLE Users
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    RoleId INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(Id)
);
GO

CREATE TABLE Tickets
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CategoryId INT NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    PriorityId INT NOT NULL,
    StatusId INT NOT NULL,
    AssignedUserId INT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Tickets_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Tickets_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
    CONSTRAINT FK_Tickets_Priorities FOREIGN KEY (PriorityId) REFERENCES Priorities(Id),
    CONSTRAINT FK_Tickets_Statuses FOREIGN KEY (StatusId) REFERENCES Statuses(Id),
    CONSTRAINT FK_Tickets_AssignedUser FOREIGN KEY (AssignedUserId) REFERENCES Users(Id)
);
GO

-- Справочники
INSERT INTO Roles (Name) VALUES (N'Студент'), (N'Куратор'), (N'Системный администратор');
GO

INSERT INTO Categories (Name) VALUES 
(N'Компьютерная техника'), (N'Лицензионное ПО'), (N'Интернет и локальная сеть'), 
(N'Доступ к ресурсам'), (N'Печатное оборудование'), (N'Разное');
GO

INSERT INTO Priorities (Name, SortOrder) VALUES (N'Критический', 1), (N'Высокий', 2), (N'Средний', 3), (N'Низкий', 4);
GO

INSERT INTO Statuses (Name) VALUES (N'Открыта'), (N'В процессе решения'), (N'Ожидание ответа'), (N'Успешно решена'), (N'Отменена');
GO

-- ДОБАВЛЯЕМ ПОЛЬЗОВАТЕЛЕЙ (Джавадов добавлен под Id=6)
INSERT INTO Users (Login, PasswordHash, FullName, RoleId, IsActive) VALUES
(N'shmelev_di', N'TEMP_ADMIN', N'Шмелев Дмитрий Игоревич', 3, 1),      -- Id = 1
(N'lesnov_td', N'TEMP_SUPPORT', N'Леснов Тимур Дмитриевич', 2, 1),    -- Id = 2 (Автор заявки №2)
(N'mamadov_mk', N'TEMP_USER', N'Мамадов Мубориз Кахорович', 1, 1),    -- Id = 3
(N'smirnova_ao', N'TEMP_SUPPORT', N'Смирнова Анна Олеговна', 2, 1),   -- Id = 4
(N'gasanov_ks', N'TEMP_USER', N'Гасанов Кирилл Сергеевич', 1, 1),     -- Id = 5
(N'dzhavadov_es', N'TEMP_USER', N'Джавадов Эмиль Сергеевич', 1, 1);   -- Id = 6 (Автор заявки №7)
GO

-- ДОБАВЛЯЕМ ЗАЯВКИ
INSERT INTO Tickets (UserId, CategoryId, Description, PriorityId, StatusId, AssignedUserId) VALUES
(3, 1, N'Компьютер сильно шумит и греется при работе', 2, 1, NULL),                   -- Заявка 1: Автор Мамадов
(2, 4, N'Не обновляется антивирус на сервере', 3, 4, 4),                              -- Заявка 2: Автор ЛЕСНОВ (выполнена Смирновой)
(3, 5, N'Замялась бумага в принтере в 304 аудитории', 4, 5, NULL),                    -- Заявка 3: Автор Мамадов
(5, 3, N'Нет доступа к сетевой папке с методичками', 3, 2, 4),                        -- Заявка 4: Автор Гасанов
(5, 2, N'Ошибка активации Visual Studio 2022', 1, 3, 2),                              -- Заявка 5: Автор Гасанов
(1, 6, N'Требуется замена монитора на более широкий', 4, 2, 4),                       -- Заявка 6: Автор Шмелев
(6, 3, N'Отваливается Wi-Fi каждые 10 минут', 2, 4, 2);                               -- Заявка 7: Автор ДЖАВАДОВ (решена Лесновым)
GO
-- Проверки ограничений (Ожидаются 2 красные ошибки)
INSERT INTO Categories (Name) VALUES (N'Лицензионное ПО');
GO

INSERT INTO Tickets (UserId, CategoryId, Description, PriorityId, StatusId) 
VALUES (999, 1, N'Проверка внешнего ключа', 2, 1);
GO

-- ИТОГОВАЯ ТАБЛИЦА (Смотрим сюда)
SELECT 
    t.Id AS [Номер],
    u.FullName AS [Автор заявки],
    c.Name AS [Категория],
    t.Description AS [Описание проблемы],
    p.Name AS [Приоритет],
    s.Name AS [Статус],
    ISNULL(a.FullName, N'Не назначен') AS [Исполнитель],
    FORMAT(t.CreatedAt, 'dd.MM.yyyy HH:mm') AS [Дата создания]
FROM Tickets AS t
INNER JOIN Users AS u ON t.UserId = u.Id
INNER JOIN Categories AS c ON t.CategoryId = c.Id
INNER JOIN Priorities AS p ON t.PriorityId = p.Id
INNER JOIN Statuses AS s ON t.StatusId = s.Id
LEFT JOIN Users AS a ON t.AssignedUserId = a.Id
ORDER BY t.Id;
GO