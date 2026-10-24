-- A. DATABASE SETUP
-- =====================================================

-- A.1 Create database
CREATE DATABASE restaurant_reviews;
\c restaurant_reviews

-- A.2 Create tables
CREATE TABLE restaurant (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(200),
    description TEXT
);

CREATE TABLE review (
    id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
    user_name VARCHAR(50),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);

-- =====================================================
-- B. INSERTING DATA
-- =====================================================

INSERT INTO restaurant (name, street_address, description) VALUES
('Warung Sunda Asri', 'Jl. Sudirman No. 10', 'Masakan Sunda rumahan'),
('Sate Pak Kumis', 'Jl. Kalimalang No. 5', 'Sate kambing dan ayam'),
('Bakmi Jaya', 'Jl. Pondok Bambu No. 21', 'Bakmi ayam khas Jakarta');

INSERT INTO review (restaurant_id, user_name, rating, review_text, review_date) VALUES
(1, 'arsy', 5, 'Sambalnya mantap', '2026-10-01'),
(1, 'budi', 4, 'Enak, harga oke', '2026-10-05'),
(2, 'citra', 3, 'Satenya agak alot', '2026-10-03'),
(2, 'dina', 5, 'Bumbu kacangnya juara', '2026-10-10'),
(3, 'eko', 2, 'Antrinya lama', '2026-10-08');

SELECT * FROM restaurant;
SELECT * FROM review;

-- =====================================================
-- C. CRUD OPERATIONS
-- =====================================================

-- C.1 Create
-- Insert a new restaurant
INSERT INTO restaurant (name, street_address, description)
VALUES ('Kopi Senja', 'Jl. Duren Sawit No. 7', 'Kedai kopi santai');

-- Insert a new review for an existing restaurant
INSERT INTO review (restaurant_id, user_name, rating, review_text, review_date)
VALUES (3, 'fajar', 4, 'Bakminya kenyal', '2026-10-15');

SELECT * FROM restaurant;
SELECT * FROM review;

-- C.2 Read
-- All reviews for a specific restaurant
SELECT * FROM review WHERE restaurant_id = 1;

-- All reviews with rating 4 or higher
SELECT * FROM review WHERE rating >= 4;

-- JOIN: restaurants with their reviews
SELECT r.name, v.user_name, v.rating, v.review_text, v.review_date
FROM restaurant r
JOIN review v ON v.restaurant_id = r.id
ORDER BY r.id;

-- C.3 Update
-- Update description of one restaurant
UPDATE restaurant SET description = 'Masakan Sunda autentik dengan sambal khas' WHERE id = 1;

-- Update rating of a specific review
UPDATE review SET rating = 4 WHERE id = 3;

SELECT * FROM restaurant WHERE id = 1;
SELECT * FROM review WHERE id = 3;

-- C.4 Delete
-- Delete one review by id
DELETE FROM review WHERE id = 5;
SELECT * FROM review;

-- Delete a restaurant; its reviews are deleted by ON DELETE CASCADE
SELECT * FROM review WHERE restaurant_id = 2;   -- before
DELETE FROM restaurant WHERE id = 2;
SELECT * FROM review WHERE restaurant_id = 2;   -- after (0 rows)

-- =====================================================
-- D. ADDITIONAL QUERIES
-- =====================================================

-- D.1 Highest-rated restaurant (average rating)
SELECT r.name, ROUND(AVG(v.rating), 2) AS avg_rating
FROM restaurant r
JOIN review v ON v.restaurant_id = r.id
GROUP BY r.id, r.name
ORDER BY avg_rating DESC
LIMIT 1;

-- D.2 Number of reviews per restaurant
SELECT r.name, COUNT(v.id) AS total_review
FROM restaurant r
LEFT JOIN review v ON v.restaurant_id = r.id
GROUP BY r.id, r.name
ORDER BY r.id;

-- D.3 Most recent review per restaurant
SELECT DISTINCT ON (r.id) r.name, v.user_name, v.rating, v.review_text, v.review_date
FROM restaurant r
JOIN review v ON v.restaurant_id = r.id
ORDER BY r.id, v.review_date DESC;

-- =====================================================
-- EXTRA CREDIT
-- =====================================================

-- E.1 Menu table + at least 3 items per restaurant
CREATE TABLE menu (
    id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
    item_name VARCHAR(100),
    price NUMERIC(10,2)
);

INSERT INTO menu (restaurant_id, item_name, price) VALUES
(1, 'Nasi Timbel', 30000), (1, 'Ayam Goreng', 25000), (1, 'Karedok', 15000),
(3, 'Bakmi Ayam', 22000), (3, 'Pangsit Goreng', 15000), (3, 'Es Teh', 5000),
(4, 'Kopi Susu', 20000), (4, 'Americano', 18000), (4, 'Roti Bakar', 15000);

SELECT * FROM menu;

-- E.2 Restaurants with menu and average rating
SELECT r.name, m.item_name, m.price,
       (SELECT ROUND(AVG(rating), 2) FROM review WHERE restaurant_id = r.id) AS avg_rating
FROM restaurant r
JOIN menu m ON m.restaurant_id = r.id
ORDER BY r.name, m.item_name;
