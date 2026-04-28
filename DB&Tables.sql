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

