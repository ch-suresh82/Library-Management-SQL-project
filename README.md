# Library Management SQL Project

![Library](https://github.com/ch-suresh82/Library-Management-SQL-project/blob/main/Library%20PNG.jpg)

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

- **Database Creation**: Created a database named Library_Management_sql_pro2.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
-- create book table
CREATE TABLE books (
	isbn	VARCHAR(20) PRIMARY KEY, 
	book_title	VARCHAR(55),
	category	VARCHAR(18),
	rental_price  FLOAT,
	status    VARCHAR(5),
	author		VARCHAR(25),	
	publisher	VARCHAR(28)
);

SELECT * FROM books;

-- create branch table
CREATE TABLE branch (
	branch_id	VARCHAR(10) PRIMARY KEY,
	manager_id		VARCHAR(10), --FK
	branch_address		VARCHAR(25),
	contact_no		VARCHAR(15)
);

-- create employee table
CREATE TABLE employees (
	emp_id		VARCHAR(10) PRIMARY KEY,
	emp_name		VARCHAR(25),
	job_title		VARCHAR(15),
	salary		INT,
	branch_id	VARCHAR(10) --FK
);

ALTER TABLE employees RENAME COLUMN position TO job_title;
ALTER TABLE employees ALTER COLUMN salary TYPE float;

-- create issued_status
CREATE TABLE issued_status (
	issued_id	VARCHAR(10) PRIMARY KEY,
	issued_member_id	VARCHAR(10), --FK
	issued_book_name	VARCHAR(60 , --FK
	issued_date		DATE,
	issued_book_isbn	VARCHAR(25),
	issued_emp_id	VARCHAR(10) --FK
);

-- create members table
CREATE TABLE members (
	member_id	VARCHAR(10) PRIMARY KEY,
	member_name		VARCHAR(25),
	member_address		VARCHAR(25),
	reg_date 	DATE
);

-- create return_status table
CREATE TABLE return_status (
	return_id	VARCHAR(10) PRIMARY KEY,
	issued_id	VARCHAR(10), --FK
	return_book_name 	VARCHAR(60),
	return_date		DATE,
	return_book_isbn 	VARCHAR(25) --FK
);
```

 ### Creating relations bewteen tables
 ```sql

ALTER TABLE return_status ADD CONSTRAINT fk_book_isbn FOREIGN KEY (return_book_isbn) REFERENCES books(isbn);
ALTER TABLE return_status DROP CONSTRAINT fk_book_isbn;

ALTER TABLE return_status ADD CONSTRAINT fk_issued_id FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id); 

ALTER TABLE issued_status ADD CONSTRAINT fk_member_id FOREIGN KEY (issued_member_id) REFERENCES members(member_id); 

ALTER TABLE issued_status ADD CONSTRAINT fk_issued_emp_id FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id); 

ALTER TABLE issued_status ADD CONSTRAINT fk_issued_book_isbn FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn); 

ALTER TABLE employees ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES branch(branch_id); 


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issued_status; 
SELECT * FROM return_status;

```
![ERD](https://github.com/ch-suresh82/Library-Management-SQL-project/blob/main/Library_ERD.png)
 ## Project Tasks 
 
### CRUD operations

**1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" **
```sql
INSERT INTO books VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**2. Update an Existing Member's Address**
```sql
UPDATE members SET member_address = '125 Oak St' WHERE member_id = 'C103';
```
**3. Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.**
```sql
DELETE FROM issued_status WHERE issued_id = 'IS121';
```
**4. Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.**
```sql
SELECT issued_book_name 
FROM issued_status 
WHERE issued_emp_id = 'E101';
```
**5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.**
```sql
SELECT 
		issued_member_id,
		count(*) as Total_Books
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;
```
**6. Create Summary Tables: Used CTAS to generate new tables based on query results  each book and total book_issued_cnt **
```sql
CREATE TABLE books_issued AS 
							SELECT b.isbn, iss.issued_book_name, count(iss.issued_id)  AS total_books
							FROM issued_status AS iss
							INNER JOIN books AS b  ON iss.issued_book_isbn = b.isbn
							GROUP BY 1, 2;
SELECT * FROM books_issued;
```
**7. Retrieve All Books in a Specific Category:**
```sql
SELECT * FROM books
WHERE category = 'Classic';
```
**8. Find Total Rental Income by each Category:**
```sql
SELECT category, SUM(rental_price)
FROM books
GROUP BY 1;
```
**9. List Employees with Their Branch Manager's Name and their branch details:**
```sql
SELECT 
		e1.emp_id,
		e1.emp_name,
		e1.job_title,
		e1.salary,
		b.*,
		e2.emp_name AS Manager
FROM employees AS e1 
INNER JOIN branch AS b ON e1.branch_id = b.branch_id
INNER JOIN employees e2 ON e2.emp_id = b.manager_id;
```
**10. Create a Table of Books with Rental Price Above a Certain Threshold:**
```sql
SELECT book_title
FROM books
WHERE rental_price > 7.0;
```
**11. Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```
** 12. Identify Members with Overdue Books **
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue. 
```sql
SELECT 
		m.member_id,
		m.member_name,
		iss.issued_book_name,
		iss.issued_date,
		CURRENT_DATE - iss.issued_date AS over_due
FROM members AS m
INNER JOIN issued_status AS iss ON m.member_id = iss.issued_member_id 
LEFT JOIN return_status AS rs ON iss.issued_id = rs.issued_id
WHERE rs.issued_id IS NULL
	  AND 
	  (CURRENT_DATE - iss.issued_date) > 30
ORDER BY 1;
```
** 13. Update Book Status on Return**
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table) 
```sql
SELECT * FROM return_status;
SELECT * FROM books;
SELECT *  FROM issued_status
WHERE issued_book_isbn = '978-0-375-41398-8';

CREATE OR REPLACE PROCEDURE book_status_on_return(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
		v_isbn VARCHAR(30);
		v_issued_book_name VARCHAR(50);
		
BEGIN
		INSERT INTO return_status(return_id, issued_id, return_date)
		VALUES (p_return_id, p_issued_id, CURRENT_DATE);

		SELECT issued_book_isbn, issued_book_name
			   INTO
			   v_isbn,  v_issued_book_name
	    FROM issued_status
		WHERE issued_id = p_issued_id;
		
		UPDATE books SET status = 'yes'
		WHERE isbn = v_isbn;

		RAISE NOTICE 'Thank you for Return the Book: %', v_issued_book_name;
END;
$$

-- calling stored procedure 
CALL book_status_on_return('RS134', 'IS134');


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';
```
** 14. Branch Performance Report **
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals. 
```sql
SELECT * FROM branch;
SELECT * FROM books; 
SELECT * FROM employees;  
SELECT * FROM issued_status; -- issued_emp_id = emp_id
SELECT * FROM return_status; --

SELECT 
		emp.branch_id AS branch_id,
		br.manager_id AS manager_id,
		COUNT(iss.issued_id) AS No_of_Books_Issued,
		COUNT(rs.return_id) AS No_of_Books_Returned,
		SUM(b.rental_price) AS Amount_Generated
FROM issued_status AS iss
INNER JOIN employees AS emp ON emp.emp_id = iss.issued_emp_id
INNER JOIN branch as br ON br.branch_id = emp.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = iss.issued_id
INNER JOIN books AS b ON b.isbn = iss.issued_book_isbn
GROUP BY 1,2;
```

**16. Find Employees with the Most Book Issues Processed**
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM branch;

SELECT 
		e.emp_name AS Employee_Name,
		b.*,
		COUNT(iss.issued_id) AS No_of_books
FROM issued_status AS iss
INNER JOIN employees AS e ON iss.issued_emp_id = e.emp_id 
INNER JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY 1,2
HAVING COUNT(iss.issued_id) > 1;
```

**17. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.**

Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
CREATE OR REPLACE PROCEDURE issueing_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
		v_status VARCHAR(10);

BEGIN
		SELECT status
		  	   INTO
			   v_status	 
		FROM books
		WHERE isbn = p_issued_book_isbn;

		IF v_status = 'yes' THEN

			INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
	
			UPDATE books SET status = 'no'
			WHERE isbn = p_issued_book_isbn;
	
			RAISE NOTICE 'Issued record added successfully for book isbn: %', p_issued_book_isbn;
		ELSE
			RAISE NOTICE 'SORRY THE BOOK IS UNAVAILABBLE: %', p_issued_book_isbn;
		END IF;	
END; 
$$

SELECT * FROM books;
select * from issued_status;
select * from
-- CALL function
CALL issueing_book('IS142','C109','978-0-330-25864-8','E104');

```

**19. Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.**

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID, Number of overdue books, Total fines


```sql
CREATE TABLE member_overdue_summary AS
SELECT 
  m.member_id,
  COUNT(i.issued_id) AS total_books_issued,
  COUNT(
    CASE 
      WHEN r.return_date IS NULL AND CURRENT_DATE - i.issued_date > 30 
      THEN 1 
    END
  ) AS overdue_books,
  ROUND(
    SUM(
      CASE 
        WHEN r.return_date IS NULL AND CURRENT_DATE - i.issued_date > 30 
        THEN (CURRENT_DATE - i.issued_date - 30) * 0.50 
        ELSE 0 
      END
    )::numeric, 2
  ) AS total_fine
FROM members m
JOIN issued_status i ON i.issued_member_id = m.member_id
LEFT JOIN return_status r ON r.issued_id = i.issued_id
GROUP BY m.member_id;

SELECT * FROM member_overdue_summary;

```

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.












