-- Trigger kiểm tra thông tin xe nhập vào phải có giá trị lớn hơn 0
CREATE OR REPLACE TRIGGER TRG_VALID_CARS_INSERT
BEFORE INSERT OR UPDATE ON CARS FOR EACH ROW
BEGIN
    IF(:NEW.Price<=0)
    THEN 
    RAISE_APPLICATION_ERROR(-20100, 'Gia xe khong hop le, xin vui long nhap lai');
    END IF;
END;

-- Trigger kiểm tra nhân viên phải đạt tối thiểu 18 tuổi khi vào làm việc
CREATE OR REPLACE TRIGGER trg_EMP_insert_update 
AFTER INSERT OR UPDATE ON EMPLOYEES
FOR EACH ROW  
DECLARE
    today DATE;
BEGIN 
        SELECT SYSDATE INTO today FROM DUAL;
        IF EXTRACT(YEAR FROM today) - EXTRACT(YEAR FROM :NEW.EMPBIRTH) < 18 THEN 
            RAISE_APPLICATION_ERROR(-20100, 'Nhan vien phai dat toi thieu 18 tuoi khi vao lam viec');  
        END IF;  
END;

-- Procedure
-- Tìm nhân viên được nhập từ máy và thay đổi mức lương của nhân viên đó theo mức lương được nhập vào
CREATE OR REPLACE PROCEDURE changeEmployeeSalary (empID VARCHAR2 ,sal NUMBER) 
AS 
dem NUMBER; 
BEGIN 
SELECT COUNT(Emp1.EmpID) INTO dem
FROM EMPLOYEES Emp1
WHERE Emp1.EmpID = empID; 
IF (dem>0) THEN 
    UPDATE EMPLOYEES 
    SET EMPSALARY = sal 
    WHERE EMPID = empID; 
ELSE 
    SELECT COUNT(Emp2.EmpID) INTO dem 
    FROM EMPLOYEES@off2 Emp2
    WHERE Emp2.EmpID = empID; 
    IF (dem > 0) THEN 
        UPDATE EMPLOYEES@off2 
        SET EMPSALARY = sal 
        WHERE EMPID = empID; 
    END IF; 
END IF; 
COMMIT; 
END;
-- test
BEGIN
    changeEmployeeSalary('11', 999999);
END;



-- Function
-- Tính tổng tiền tất cả các hóa đơn khách hàng chi trả
CREATE OR REPLACE FUNCTION sumPrice (customerId CUSTOMERS.CUSID%TYPE) RETURN NUMBER 
AS 
    totalPrice NUMBER; 
BEGIN 
    SELECT SUM(TOTAL) INTO totalPrice
    FROM (
            SELECT SUM(TOTALPRICE) AS TOTAL FROM PAYMENTS WHERE CUSID=customerId
            UNION
            SELECT SUM(TOTALPRICE) AS TOTAL FROM PAYMENTS@off2 WHERE CUSID=customerId);
    
    RETURN totalPrice;
END;
-- test
SET SERVEROUTPUT ON;
DECLARE 
    t NUMBER;
BEGIN
    t := sumPrice('31');
    DBMS_OUTPUT.PUT_LINE('Tong tien: ' || t);
END;






