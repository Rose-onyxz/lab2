-- Лабораторная работа № 2 «Создание запросов»
-- Вариант 4
-- Таблицы исходной базы данных: readers, fines.
-- Запросы выполняются по порядку в редакторе SQL PostgreSQL.

-- 1. Выбрать всех читателей, у которых фамилия, имя и отчество начинаются на одну букву.
SELECT
    reader_id,
    last_name,
    first_name,
    middle_name,
    birth_date,
    passport_data,
    address,
    contact_phone
FROM readers
WHERE middle_name IS NOT NULL
  AND UPPER(LEFT(last_name, 1)) = UPPER(LEFT(first_name, 1))
  AND UPPER(LEFT(first_name, 1)) = UPPER(LEFT(middle_name, 1));


-- 2. Выбрать всех читателей, которым за утерянные книги был назначен штраф более 100 рублей.
SELECT DISTINCT
    r.reader_id,
    r.last_name,
    r.first_name,
    r.middle_name,
    f.fine_amount
FROM readers AS r
JOIN fines AS f ON f.reader_id = r.reader_id
WHERE f.is_lost = TRUE
  AND f.fine_amount > 100;


-- 3. Создать таблицу, содержащую данные 1 запроса с указанием адресов и контактных телефонов.
-- При повторном запуске скрипта предыдущая таблица результатов удаляется и создается заново.
DROP TABLE IF EXISTS readers_variant4;

CREATE TABLE readers_variant4 AS
SELECT
    reader_id,
    last_name,
    first_name,
    middle_name,
    birth_date,
    passport_data,
    address,
    contact_phone
FROM readers
WHERE middle_name IS NOT NULL
  AND UPPER(LEFT(last_name, 1)) = UPPER(LEFT(first_name, 1))
  AND UPPER(LEFT(first_name, 1)) = UPPER(LEFT(middle_name, 1));


-- 4. Добавить в созданную таблицу читателей, возраст которых меньше 18 лет.
INSERT INTO readers_variant4 (
    reader_id,
    last_name,
    first_name,
    middle_name,
    birth_date,
    passport_data,
    address,
    contact_phone
)
SELECT
    r.reader_id,
    r.last_name,
    r.first_name,
    r.middle_name,
    r.birth_date,
    r.passport_data,
    r.address,
    r.contact_phone
FROM readers AS r
WHERE r.birth_date > CURRENT_DATE - INTERVAL '18 years'
  AND NOT EXISTS (
      SELECT 1
      FROM readers_variant4 AS rv
      WHERE rv.reader_id = r.reader_id
  );


-- 5. В созданной таблице для телефонных номеров с кодом 495 изменить код на 499.
UPDATE readers_variant4
SET contact_phone = REPLACE(contact_phone, '495', '499')
WHERE contact_phone LIKE '%495%';


-- 6. Удалить из созданной таблицы всех читателей, у которых в номере телефона меньше 11 цифр.
DELETE FROM readers_variant4
WHERE contact_phone IS NOT NULL
  AND LENGTH(REGEXP_REPLACE(contact_phone, '[^0-9]', '', 'g')) < 11;


-- 7. Посчитать сумму денег, выплаченных в качестве штрафов каждым читателем.
-- В исходной таблице fines нет отдельного признака оплаты, поэтому суммируется fine_amount.
SELECT
    r.reader_id,
    r.last_name,
    r.first_name,
    r.middle_name,
    COALESCE(SUM(f.fine_amount), 0) AS total_fines
FROM readers AS r
LEFT JOIN fines AS f ON f.reader_id = r.reader_id
GROUP BY
    r.reader_id,
    r.last_name,
    r.first_name,
    r.middle_name
ORDER BY r.reader_id;
