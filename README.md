# Library Management System using SQL 

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](/IMG_7524.PNG)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

![ERD](/libarayDB_ERD.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
create database library_DB;
use library_DB;
set sql_safe_updates =0;
-- Project "Library Managment System"

-- creating a branch table

DROP TABLE if exists branch;
create table branch (
branch_id varchar(30) primary key
,manager_id varchar(30),  -- fk
branch_address VARCHAR(100),
contact_no bigint
);

-- creating a employees table

DROP TABLE if exists employees;
create table employees (
emp_id varchar(30) primary key
,emp_name varchar(25),
position VARCHAR(20),
salary int,
branch_id VARCHAR(10) -- fk
);

-- creating a employees table

DROP TABLE if exists books;
create table books(
isbn varchar(25) primary key ,
book_title varchar(80),
category varchar(20),
rental_price decimal(3,2),
status varchar(5 ),
author varchar(35),
publisher varchar(55));

-- creating a members table

DROP TABLE if exists members;
create table members(
member_id varchar(10) primary key ,
member_name varchar(15),
member_address varchar(75),
reg_date date );


-- creating a issued_status table
-- issued_id	issued_member_id	issued_book_name	issued_date	 issued_book_isbn	issued_emp_id
DROP TABLE if exists issued_status;
create table issued_status(
issued_id varchar(10) primary key ,
issued_member_id varchar(10)  , -- FK
issued_book_name  varchar(75),
issued_date date ,
issued_book_isbn  varchar(25), -- fk
issued_emp_id varchar(10) ); -- FK


-- creating a return_status table
-- return_id	issued_id	return_book_name	return_date	return_book_isbn
DROP TABLE if exists return_status;

create table return_status(
return_id varchar(10) primary key ,
issued_id varchar(10)  , -- fk
return_book_name  varchar(75),
return_date date ,
return_book_isbn  varchar(25) );


-- Making relaation btw the tables by adding Foregin key constrain
-- adding fk in issued_satatus
alter table  issued_status
add constraint fk_members
foreign key (issued_member_id)  references members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn);

alter table issued_status
add constraint fk_employee
foreign key (issued_emp_id) references employees(emp_id);

-- adding fk in return_status
alter table return_status
add constraint fk_issued
foreign key (issued_id) references issued_status(issued_id);

-- adding fk i employees
alter table employees add constraint fk_branch
foreign key(branch_id) references branch(branch_id);


```

**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```

**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt\*\*

```sql
create table book_issued_cnt as
select b.isbn,b.book_title ,count(ist.issued_id) as book_issued_cnt from  issued_status as ist
right join books as b
on ist.issued_book_isbn = b.isbn
group by b.isbn,b.book_title;

-- checking the table
select * from book_issued_cnt;
select count(distinct isbn  ) from books;
```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7.Retrieve All Books in a Specific Category**:

```sql
select  category ,book_title from books
where category = 'Classic';
```

**Task 8.Task 8: Find Total Rental Income by Category**:

```sql
select category,sum(books_earning) as category_earning from(
select b.category,b.isbn,count(ist.issued_id) * b.rental_price as books_earning from issued_status as ist
join
books as b
on ist.issued_book_isbn = b.isbn
group by category,isbn) t
group by t.category;
```

**Task 9.List Members Who Registered in the Last 180 Days**:

```sql
select * from Members
where DATEDIFF(CURDATE(), reg_date) <= 180;
```

**Task 10.List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e.emp_name,b.*,m.emp_name as manager_name  from employees as e
join branch as b
on e.branch_id = b.branch_id
left join employees as m
on b.manager_id = m.emp_id ;
```

**Task 11. Create a Table of Books with Rental Price Above a Certain Threshold**:

```sql
create table Books_rent_gt7 as
select isbn,book_title,category,rental_price from books
where rental_price >7;
```

**Task 12: Retrieve the List of Books Not Yet Returned**

```sql
select ist.issued_book_name from issued_status as ist
left join return_status as rst
on ist.issued_id = rst.issued_id
where rst.return_id is    null;
```

**Task 13: Write a query to get the total revenue**

```sql
select sum(book_revenue) as total_revenue from
(select b.isbn,count(ist.issued_id)*b.rental_price as book_revenue from issued_status as ist
join
books as b
on ist.issued_book_isbn = b.isbn
group by  b.isbn ) t;
```

## Advanced SQL Operations

**Task 14: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select m.member_name ,m.member_id,b.book_title, ist.issued_date,(curdate() - ist.issued_date)  as overdue
from issued_status as ist
join members as m on
ist.issued_member_id = m.member_id
left join return_status as rst
on ist.issued_id = rst.issued_id
left join books as b
on ist.issued_book_isbn = b.isbn
where rst.return_id is null and (curdate() - ist.issued_date) > 30;
```

**Task 15: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql

DELIMITER $$
create procedure add_return_records(IN P_return_id  VARCHAR(10) , IN P_issued_id VARCHAR(10))
begin
     insert into return_status (return_id,issued_id,return_date) value (P_return_id,P_issued_id,curdate());

     update books
     set status = "Yes"
     where isbn = (select issued_book_isbn from issued_status where issued_id = P_issued_id);
end $$
DELIMITER ;



-- Testing FUNCTION add_return_records
call add_return_records("RS119","IS130");
call add_return_records("RS120","IS134");

```

**Task 16: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 17: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

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

```

**Task 18: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select e.emp_id,e.emp_name , count(ist.issued_id) no_books_processed , e.branch_id from issued_status as ist
join employees as e
on ist .issued_emp_id = e.emp_id
group by  e.emp_id,e.emp_name,e.branch_id
order by   no_books_processed desc limit 3;

select * from issued_status;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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

```

**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
The number of overdue books.
The total fines, with each day's fine calculated at $0.50.
The number of books issued by each member.
The resulting table should show:
Member ID
Number of overdue books
Total fines

```sql
select   member_name ,count(issued_id) as overdue_book_count ,sum(fine) as total_fine from
(select ist.*,m.*,(current_date() - ist.issued_date)*0.5 as fine  from issued_status as ist
right  join members as m
on ist.issued_member_id = m.member_id
left join return_status as rst
on ist.issued_id = rst.issued_id
where return_id is null and current_date() - issued_date > 30) t
group by t.member_name;
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
