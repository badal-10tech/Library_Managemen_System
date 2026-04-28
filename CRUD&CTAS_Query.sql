select * from books;
select * from branch;
select * from employees;
select * from members;
select * from issued_status;
select * from return_status;

-- project task
-- Task 1. Create a New Book Record -- '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes, 'HarperLee', 'J.B. Lippincott & Co.')"

insert into books (isbn,book_title,category,rental_price,status,author,publisher) values('978-1-60129-456-2', 
'To Kill a Mockingbird', 
'Classic', 6.00, 'yes',
'HarperLee', 
'J.B. Lippincott & Co.');

-- select * from members
-- where member_id ='C103';

-- Task 2. Update an Existing member address
update members
set member_address = '125 Oak St'
where member_id = 'C103';

select * from members
where member_id ='C103';

-- Task 3: Delete a Record from the Issued Status Table where issued_id = 'IS104' 
delete from issued_status
where issued_id = 'IS104';

select * from issued_status
where issued_id ='IS104';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select i_s.issued_member_id,m.member_name ,count(i_s.issued_book_name) as total_book_issued from issued_status as i_s
join members as m on i_s.issued_member_id = m.member_id
group by i_s.issued_member_id,m.member_name
having count(i_s.issued_book_name) > 1;



-- 3. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table book_issued_cnt as 
select b.isbn,b.book_title ,count(ist.issued_id) as book_issued_cnt from  issued_status as ist
right join books as b 
on ist.issued_book_isbn = b.isbn
group by b.isbn,b.book_title;

select * from book_issued_cnt;
select count(distinct isbn  ) from books;

-- Task 7. Create a Table of Books with Rental Price Above a Certain Threshold: above 7.00
create table Books_rent_gt7 as
select isbn,book_title,category,rental_price from books
where rental_price >7;

select * from Books_rent_gt7;

