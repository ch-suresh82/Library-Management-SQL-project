-- Library_Management_project

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

-- creating relations bewteen tables

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

-- *** Project Tasks *** 
-- CRUD operations
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address
UPDATE members SET member_address = '125 Oak St' WHERE member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT issued_book_name 
FROM issued_status 
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
		issued_member_id,
		count(*) as Total_Books
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE books_issued AS 
							SELECT b.isbn, iss.issued_book_name, count(iss.issued_id)  AS total_books
							FROM issued_status AS iss
							INNER JOIN books AS b  ON iss.issued_book_isbn = b.isbn
							GROUP BY 1, 2;
SELECT * FROM books_issued;

--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by each Category:
SELECT category, SUM(rental_price)
FROM books
GROUP BY 1;

--Task 9: List Members Who Registered in the Last 180 Days:


-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
select 
		e1.emp_id,
		e1.emp_name,
		e1.job_title,
		e1.salary,
		b.*,
		e2.emp_name as Manager
from employees as e1 
inner join branch as b on e1.branch_id = b.branch_id
inner join employees e2 on e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

select book_title
from books
where rental_price > 7.0;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue. */

select 
		m.member_id,
		m.member_name,
		iss.issued_book_name,
		iss.issued_date,
		current_date - iss.issued_date as over_due
from members as m
inner join issued_status as iss on m.member_id = iss.issued_member_id 
left join return_status as rs on iss.issued_id = rs.issued_id
where rs.issued_id is null
	  and 
	  (current_date - iss.issued_date) > 30
order by 1;

/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table) */

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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/
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

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
*/

SELECT * FROM members;
SELECT * FROM  issued_status;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

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

/*
Task 19:
Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
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


/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID, Number of overdue books, Total fines
*/


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

