CREATE DATABASE Employee_Management_System;
USE Employee_Management_System;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- ====================================================================================
-- 1. EMPLOYEE INSIGHTS
-- ====================================================================================
-- Q1. How many unique employees are currently in the system?

SELECT count(*) total_employees
FROM Employee;

-- Q2. Which departments have the highest number of employees?

-- Employees per department
SELECT j.jobdept, COUNT(e.emp_ID) AS Total_employees
FROM Employee e
JOIN JobDepartment j ON e.Job_ID = j.Job_ID
GROUP BY j.jobdept
ORDER BY total_employees DESC;



-- Q3. What is the average salary per department?

-- Average salary by department
SELECT j.jobdept, AVG(s.amount) AS avg_salary
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept;


-- Q4. Who are the top 5 highest-paid employees?

-- Top 5 highest paid employees
SELECT e.firstname, e.lastname, s.amount
FROM Employee e
JOIN SalaryBonus s ON e.Job_ID = s.Job_ID
ORDER BY s.amount DESC
LIMIT 5;


-- Q5. What is the total salary expenditure across the company?

-- Total salary expenditure
SELECT SUM(amount) AS total_salary
FROM SalaryBonus;

-- =================================================================
-- 2. JOB ROLE & DEPARTMENT ANALYSIS
-- =================================================================

-- Q6. How many different job roles exist in each department?

-- Count roles per department
SELECT jobdept, COUNT(name) AS total_roles
FROM JobDepartment
GROUP BY jobdept;


--  Q7. What is the average salary range per department?

-- Average salary per department
SELECT j.jobdept, AVG(s.amount) AS avg_salary
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept;


--  Q8. Which job roles offer the highest salary?

-- Highest paying job roles
SELECT j.name, s.amount
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
ORDER BY s.amount DESC;


-- Q9. Which departments have the highest total salary allocation?

-- Total salary by department
SELECT j.jobdept, SUM(s.amount) AS total_salary
FROM JobDepartment j
JOIN SalaryBonus s ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept
ORDER BY total_salary DESC;

-- =========================================================================
-- 3. QUALIFICATION & SKILLS ANALYSIS
-- =========================================================================

-- Q10. How many employees have at least one qualification listed?

-- Employees with qualifications
SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM Qualification;


--  Q11. Which positions require the most qualifications?

-- Most demanded positions
SELECT Position, COUNT(*) AS total_requirements
FROM Qualification
GROUP BY Position
ORDER BY total_requirements DESC;


-- Q12. Which employees have the highest number of qualifications?

-- Most qualified employees
SELECT e.firstname, e.lastname, COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID
ORDER BY total_qualifications DESC;


-- =====================================================================
-- 4. LEAVE & ABSENCE ANALYSIS
-- =====================================================================


-- Q13. Which year had the most employees taking leaves?

-- Year with highest leaves
SELECT YEAR(date) AS year, COUNT(*) AS total_leaves
FROM Leaves
GROUP BY year
ORDER BY total_leaves DESC;


-- Q14. What is the average number of leave days per department?

-- Average leaves per department
SELECT j.jobdept, AVG(l.leave_ID) AS avg_leaves
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
JOIN JobDepartment j ON e.Job_ID = j.Job_ID
GROUP BY j.jobdept;


-- Q15. Which employees have taken the most leaves?

-- Employees with most leaves
SELECT e.firstname, e.lastname, COUNT(l.leave_ID) AS total_leaves
FROM Employee e
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID
ORDER BY total_leaves DESC;


-- Q16. What is the total number of leave days taken company-wide?

-- Total leaves in company
SELECT COUNT(*) AS total_leave_days
FROM Leaves;


-- Q17. How do leave days correlate with payroll amounts?

-- Leaves vs payroll
SELECT e.firstname, e.lastname,
       COUNT(l.leave_ID) AS leaves_taken,
       p.total_amount
FROM Employee e
JOIN Payroll p ON e.emp_ID = p.emp_ID
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, p.total_amount;



-- =================================================================
-- 5. PAYROLL & COMPENSATION ANALYSIS
-- =================================================================


-- Q18. What is the total monthly payroll processed?

-- Total payroll
SELECT SUM(total_amount) AS total_payroll
FROM Payroll;

-- Q19. What is the average bonus given per department?

-- Average bonus per department
SELECT j.jobdept, AVG(s.bonus) AS avg_bonus
FROM SalaryBonus s
JOIN JobDepartment j ON s.Job_ID = j.Job_ID
GROUP BY j.jobdept;


-- Q20. Which department receives the highest total bonuses?

-- Highest bonus department
SELECT j.jobdept, SUM(s.bonus) AS total_bonus
FROM SalaryBonus s
JOIN JobDepartment j ON s.Job_ID = j.Job_ID
GROUP BY j.jobdept
ORDER BY total_bonus DESC;


-- Q21. What is the average value of total_amount after deductions?

-- Average payroll amount
SELECT AVG(total_amount) AS avg_payroll
FROM Payroll;
