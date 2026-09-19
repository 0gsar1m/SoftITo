CREATE DATABASE Okul;

CREATE TABLE bolum (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(50) NOT NULL
);

CREATE TABLE ders (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(100) NOT NULL,
    kredi INT,
    bolum_id INT REFERENCES bolum(id)
);

CREATE TABLE Ogrenci (
    identify SERIAL PRIMARY KEY, 
    ad VARCHAR(50),
    not_ort NUMERIC(4,2)
);

ALTER TABLE ogrenci ADD COLUMN bolum VARCHAR(50);

CREATE TABLE kayit (
    ogrenci_id INT REFERENCES ogrenci(identify) ON DELETE CASCADE,
    ders_id INT REFERENCES ders(id) ON DELETE CASCADE,
    notu INT,
    donem VARCHAR(25),
    PRIMARY KEY (ogrenci_id, ders_id)
);

-- Veri işlemleri

INSERT INTO Ogrenci (ad, not_ort) VALUES ('Emirikano', 43.3);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Zıpırcan', 68.3);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Cırcırböceği Cemal', 42.1);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Makyajlı Muhtar', 88.9);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Çorapsız Çetin', 50.0);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Gözlüklü Gönül', 95.4);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Tostçu Tayfun', 31.8);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Biberli Bedriye', 74.2);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Hapşıran Hikmet', 61.7);
INSERT INTO ogrenci (ad, not_ort) VALUES ('Lastik Lütfü', 22.3);

SELECT * FROM Ogrenci WHERE not_ort > 45.0 ORDER BY identify;

UPDATE Ogrenci SET not_ort = 99 WHERE ad = 'Emirikano';

-- identify = 3 silinirse alttaki kayit tablosunda (3, 4, ...) satırı FK hatası verir.
-- DELETE FROM Ogrenci WHERE identify = 3 RETURNING *;

SELECT * FROM Ogrenci ORDER BY identify ASC, not_ort DESC;

-- 1. BÖLÜM VERİLERİ
INSERT INTO bolum (id, ad) VALUES
(1, 'Şanssızlık Mühendisliği'),
(2, 'Dedikodu Bilimleri ve Stratejik Fısıltı'),
(3, 'Uykusuzluk ve Gece 3 Mesajları Anabilim Dalı'),
(4, 'Fast Food Felsefesi ve Ketçap Yönetimi');

-- 2. ÖĞRENCİ VERİLERİ
INSERT INTO ogrenci (ad, not_ort) VALUES
('Zıpırcan', 68.30),
('Cırcırböceği Cemal', 42.10),
('Pırtlayan Pınar', 12.50),
('Makyajlı Muhtar', 88.90),
('Çorapsız Çetin', 50.00),
('Tostçu Tayfun', 31.80),
('Biberli Bedriye', 74.20),
('Hapşıran Hikmet', 61.70);

-- 3. DERS VERİLERİ
INSERT INTO ders (ad, kredi, bolum_id) VALUES
('Kopya Çekme Teknikleri 101', 4, 1),
('Açık Unutulan Muslukları Kapatma Sanatı', 3, 1),
('Yan Masadakinin Konuşmasını Dinleme ve Raporlama', 5, 2),
('Sabah 8.00 Dersine Gidiyormuş Gibi Görünme', 2, 3),
('Ketçap ve Mayonez Dökülme Risk Analizi', 4, 4),
('Sosyal Medyada Eski Sevgilinin Profilini İnceleme', 3, 2);

-- 4. KAYIT (NOT VE DÖNEM) VERİLERİ
INSERT INTO kayit(ogrenci_id, ders_id, notu, donem) VALUES
(1, 1, 45, '2025-Güz'),
(1, 2, 70, '2025-Güz'),
(2, 3, 90, '2025-Güz'),
(3, 4, 15, '2026-Bahar'),
(4, 5, 88, '2026-Bahar'),
(5, 1, 50, '2025-Güz'),
(6, 5, 30, '2026-Bahar'),
(7, 6, 95, '2026-Bahar'),
(8, 2, 62, '2025-Güz');

-- Senaryo 1: Hangi öğrenci hangi dersi almış ve notu kaç
SELECT o.ad AS Ogrenci_Ad, d.ad AS Ders_Ad
FROM kayit k
JOIN ogrenci o ON k.ogrenci_id = o.identify
JOIN ders d ON k.ders_id = d.id;

-- Senaryo 2: Hangi öğrenci, hangi bölümün dersini alıyor ve kaç not almış?
SELECT o.ad AS ogrenci_ad, b.ad AS bolum_ad, k.notu AS ogrenci_not 
FROM Ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
JOIN bolum b ON b.id = d.bolum_id;

-- Senaryo 3: Her öğrencinin aldığı toplam kredi
SELECT o.ad AS ogrenci_ad, SUM(d.kredi) AS toplam_kredi
FROM Ogrenci o 
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id GROUP BY o.identify, o.ad;

-- Senaryo 4: Not ortalaması genel ortalama üstünde olan öğrenciler
SELECT ad,not_ort FROM ogrenci WHERE not_ort > (SELECT AVG(not_ort) FROM ogrenci);

-- Senaryo 5: If else ile harf notunu sınıflandırıp select yapacaz
SELECT ad,
	CASE
		WHEN not_ort >= 90 THEN 'AA'
		WHEN not_ort >= 60 THEN 'BB' 
		WHEN not_ort >= 30 THEN 'CC'
		ELSE 'FF'
	END AS harf_notu
FROM ogrenci;

-- Senaryo 6: Her ders için öğrencileri notlarına göre sırala
SELECT o.ad, d.ad AS ders, k.notu, ROW_NUMBER() OVER (PARTITION BY d.ad ORDER BY k.notu DESC) AS siralama
FROM ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id;

--CTE 
--geçici bir ogrenci_ort table oluşturuyoz sonra üzerinden arama yapıyoz
WITH ogrenci_ort AS (
    SELECT o.identify, o.ad, AVG(k.notu) AS ort
    FROM ogrenci o
    LEFT JOIN kayit k ON o.identify = k.ogrenci_id
    GROUP BY o.identify, o.ad
)
SELECT * FROM ogrenci_ort WHERE ort > 60 ORDER BY ort DESC;

-- Senaryo 7: Kaç farklı derste not verilmiş
SELECT DISTINCT d.ad AS ders, k.ders_id 
FROM kayit k
JOIN ders d ON k.ders_id = d.id;

-- Senaryo 8: Kaç farklı derste not verilmiş (Tek satır tamsayı)
SELECT COUNT(DISTINCT ders_id) AS farkli_ders_sayisi
FROM kayit;