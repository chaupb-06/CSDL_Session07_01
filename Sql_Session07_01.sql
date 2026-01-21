--create database CSDL_session07_01
create database CSDL_session07_01;
--create table book
create table book(
    book_id serial primary key,
	title varchar(255),
	author varchar(100),
	genre varchar(50),
	price decimal(10, 2),
	description text,
	created_at timestamp default current_timestamp
);
explain analyze
select * from book where author ilike '%Rowling%';
explain analyze
select * from book where genre = 'Fantasy';
--Tạo các chỉ mục phù hợp để tối ưu truy vấn
create extension if not exists pg_trgm;
create index idx_book_author_trgm
on book
using gin (author gin_trgm_ops);
create index idx_book_genre on book(genre);

--So sánh thời gian truy vấn trước và sau khi tạo Index (dùng EXPLAIN ANALYZE)
explain analyze
select * from book where author ilike '%Rowling%';
explain analyze
select * from book where genre = 'Fantasy';
--Thử nghiệm các loại chỉ mục khác nhau
-- B-tree cho genre
explain analyze select * from book where genre = 'Fantasy';
-- Chưa có gin index
explain analyze select * from book where description ilike '%magic%';
-- GIN cho description (phục vụ tìm kiếm full-text)
create index idx_book_description_gin on book using gin(description gin_trgm_ops);
-- Kiểm tra hiệu suất
explain analyze select * from book where description ilike '%magic%';
--Tạo một Clustered Index (sử dụng lệnh CLUSTER) trên bảng book theo cột genre và kiểm tra sự khác biệt trong hiệu suất
cluster book using idx_book_genre;
explain analyze
select * from book where genre = 'Fantasy';
--Viết báo cáo ngắn (5-7 dòng) giải thích
--Trong hệ thống bán sách với hơn 500.000 bản ghi, việc sử dụng chỉ mục phù hợp giúp cải thiện đáng kể hiệu năng truy vấn.
--B-tree index tỏ ra hiệu quả nhất cho các truy vấn so sánh bằng như genre = 'Fantasy'.
--Đối với tìm kiếm chuỗi con sử dụng ILIKE '%keyword%', GIN index kết hợp với pg_trgm cho hiệu năng vượt trội so với quét tuần tự.
--Full-text search trên title và description hoạt động hiệu quả nhất với GIN index trên to_tsvector.
--Việc CLUSTER bảng theo genre giúp cải thiện tốc độ truy vấn do dữ liệu được sắp xếp vật lý, tuy nhiên cần thực hiện lại định kỳ.
--Hash index không được khuyến khích trong PostgreSQL vì chỉ hỗ trợ toán tử = và ít linh hoạt hơn B-tree.

