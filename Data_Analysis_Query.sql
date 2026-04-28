use library_DB;

set sql_safe_updates = 0;
-- Task 1: Retrive All books in a specifc Category for 'Classic'
select  category ,book_title from books
where category = 'Classic';


-- Task 2: Find a toatal Rental income by Category
select category,sum(books_earning) as category_earning from(
select b.category,b.isbn,count(ist.issued_id) * b.rental_price as books_earning from issued_status as ist 
join 
books as b
on ist.issued_book_isbn = b.isbn 
group by category,isbn) t
group by t.category;

select b.category,count(ist.issued_id) as no_issued,sum(b.rental_price) as books_earning from issued_status as ist 
join 
books as b
on ist.issued_book_isbn = b.isbn 
group by category;

-- Task 3: write a query to get the total revenue
select sum(book_revenue) as total_revenue from 
(select b.isbn,count(ist.issued_id)*b.rental_price as book_revenue from issued_status as ist 
join 
books as b
on ist.issued_book_isbn = b.isbn 
group by  b.isbn ) t;


-- Task 4: List Members Who Registered in the Last 180 Days:
select * from Members
where DATEDIFF(CURDATE(), reg_date) <= 180;

-- Task 5: L List Employees with Their Branch Manager's Name and their branch details:
select e.emp_name,b.*,m.emp_name as manager_name  from employees as e
join branch as b
on e.branch_id = b.branch_id
left join employees as m
on b.manager_id = m.emp_id ;

-- Task  6: Retrieve the List of Books Not Yet Returned

select ist.issued_book_name from issued_status as ist
left join return_status as rst
on ist.issued_id = rst.issued_id
where rst.return_id is    null;

-- Task  6: Retrieve the List of Books has Returned
select ist.issued_book_name from issued_status as ist
left join return_status as rst
on ist.issued_id = rst.issued_id
where rst.return_id is   not null;

-- Task 7: Identify Members with Overdue Books Write a query to identify members who have overdue books 
-- (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

select m.member_name ,m.member_id,b.book_title, ist.issued_date,(curdate() - ist.issued_date)  as overdue
from issued_status as ist
join members as m on 
ist.issued_member_id = m.member_id
left join return_status as rst
on ist.issued_id = rst.issued_id
left join books as b
on ist.issued_book_isbn = b.isbn
where rst.return_id is null and (curdate() - ist.issued_date) > 30;




-- Task 8: Update Book Status on Return Write a query to update the status of books in the
-- books table to "afailable" when they are returned (based on entries in the return_status table).

select * from issued_status;
select * from return_status
where issued_id  ="IS130";

select * from books 
where isbn = '978-0-451-52994-2'; 
-- update books 
-- set status = "No"
-- where isbn = '978-0-451-52994-2';
select * from issued_status
where issued_book_isbn = '978-0-451-52994-2';

select * from books;

select ist.issued_id,ist.issued_book_name from issued_status as ist
left join return_status as rst
on ist.issued_id = rst.issued_id
where rst.return_id is    null;
-- Store procedure
DELIMITER $$
create procedure add_return_records(IN P_return_id  VARCHAR(10) , IN P_issued_id VARCHAR(10))
begin
     insert into return_status (return_id,issued_id,return_date) value (P_return_id,P_issued_id,curdate());
     
     update books 
     set status = "Yes" 
     where isbn = (select issued_book_isbn from issued_status where issued_id = P_issued_id);
end $$
DELIMITER ;

call add_return_records("RS119","IS130");
call add_return_records("RS120","IS134");

-- Task 9: Branch Performance Report Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

-- select ist.*, rst.return_id,b.rental_price,e.emp_id,br.branch_id from issued_status as ist 
select br.branch_id,br.manager_id,count(ist.issued_id) as number_book_issued,count(rst.return_id) as number_of_book_return, sum(b.rental_price) as total_revenue from issued_status as ist 
left join return_status as rst 
on ist.issued_id = rst.issued_id
join books as b
on ist.issued_book_isbn = b.isbn
join employees as e
on ist.issued_emp_id = e.emp_id
left join branch as br
on e.branch_id = br.branch_id
group by br.branch_id,br.manager_id;


-- Task 10: CTAS: Create a Table of Active Members Use the CREATE TABLE AS (CTAS) statement to create a
-- new table active_members containing members who have issued at least one book in the last 6 months.
-- create table active_members as

/* select m.member_id,m.member_name,count(ist.issued_id)  as book_issued_count from issued_status as ist
right join members as m 
on ist.issued_member_id = m.member_id 
where "2024-9-15"- ist.issued_date <= 60 and ist.issued_id is not null 
group by  m.member_id, m.member_name
having count(ist.issued_id) >= 1
order by m.member_id;*/

CREATE TABLE active_members
AS
SELECT * 
FROM members 
WHERE member_id IN (
    SELECT issued_member_id 
    FROM issued_status 
    WHERE issued_date >= DATE_SUB('2024-04-13', INTERVAL 6 MONTH)
);
select * from active_members;

-- Task 11: Find Employees with the Most Book Issues Processed Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

select e.emp_id,e.emp_name,b.branch_id,count(ist.issued_id) as booke_issued_count  from issued_status as ist 
join employees as e
on ist.issued_emp_id = e.emp_id
join branch as b 
on e.branch_id = b.branch_id
group by e.emp_id,e.emp_name,b.branch_id;

/* Task 12: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.*/
select e.emp_id,e.emp_name , count(ist.issued_id) no_books_processed , e.branch_id from issued_status as ist
join employees as e
on ist .issued_emp_id = e.emp_id
group by  e.emp_id,e.emp_name,e.branch_id 
order by   no_books_processed desc limit 3;

select * from issued_status;

-- Task 13: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
-- If the book is not available (statu    s = 'no'), the procedure should return an error message indicating that the book is currently not available.
DELIMITER $$ 
create procedure update_status (
  p_isbn  VARCHAR(25),
 p_issued_id varchar(10),
 p_issued_member_id varchar(10) ,
 p_issued_emp_id varchar(10) )
begin
      -- Declare variables
    DECLARE v_status VARCHAR(5);
    DECLARE v_book_title VARCHAR(100);
     select  status, book_title into v_status, v_book_title from books
     where isbn = p_isbn;
      IF v_status IS NULL THEN
        SELECT CONCAT('Invalid ISBN. Book not found: ', p_isbn) AS message;
     ELSEIF  lower(v_status) = 'yes' then 
               insert into issued_status (issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id) 
               value(p_issued_id,p_issued_member_id,v_book_title,current_date(),p_isbn,p_issued_emp_id);
               update books set status = 'no' where  isbn = p_isbn;
               SELECT CONCAT('Book records added successfully for book isbn : ', p_isbn) AS message;
	else 
        SELECT CONCAT('Sorry to inform you the book you have requested is unavailable book_isbn: ')AS message;
     end if;
end $$
DELIMITER ;

call update_status('978-0-06-025492-6', 'IS142','C105','E106');

select * from books
where isbn = '978-0-06-025492-6';


-- Task 14: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
select   member_name ,count(issued_id) as overdue_book_count ,sum(fine) as total_fine from
(select ist.*,m.*,(current_date() - ist.issued_date)*0.5 as fine  from issued_status as ist 
right  join members as m 
on ist.issued_member_id = m.member_id
left join return_status as rst
on ist.issued_id = rst.issued_id
where return_id is null and current_date() - issued_date > 30) t
group by t.member_name;


  