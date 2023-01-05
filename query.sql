-- QUERY 1
-- Liệt kê nhân viên (EmpId, EmpName, EmpSalary) ở cả 2 chi nhánh
(SELECT EmpId, EmpName, EmpSalary
FROM EMPLOYEES)
UNION
(SELECT EmpId, EmpName, EmpSalary
FROM EMPLOYEES@off2);

-- QUERY 2
-- Liệt kê 5 hóa đơn có giá trị cao nhất, sắp xếp giảm dần theo giá trị (PaymentID, Tong, SL)
(SELECT pm1.PaymentID, TotalPrice, SUM(ExportQuantity) AS SL
FROM Payment_Details pmd1, Payments pm1
WHERE pmd1.PaymentID=pm1.PaymentID
GROUP BY pm1.PaymentID, TotalPrice)
UNION
(SELECT pm2.PaymentID, TotalPrice, SUM(ExportQuantity) AS SL
FROM Payment_Details@off2 pmd2, Payments@off2 pm2
WHERE pmd2.PaymentID=pm2.PaymentID
GROUP BY pm2.PaymentID, TotalPrice)
ORDER BY TOTALPRICE DESC, SL DESC
FETCH FIRST 5 ROWS ONLY;

-- QUERY 3
-- Cho biết chi nhánh nào bán được đa dạng xe nhất (OficeID, City, SLLoai)
(SELECT o.OfficeID, City, COUNT(Distinct pd.CarID) AS SLXE 
FROM Offices o, Warehouse_Manages wm ,Cars c, payment_details pd 
WHERE  
    o.OfficeID=wm.OfficeID 
    AND c.CarID=wm.CarID 
    AND pd.CarID=c.CarID 
    AND ExportQuantity >0 
GROUP BY o.OfficeID, City) 
UNION  
(SELECT o2.OfficeID, City, COUNT(Distinct pd2.CarID) AS SLXE 
FROM Offices@off2 o2, Warehouse_Manages@off2 wm2 ,Cars@off2 c2, payment_details@off2 pd2 
WHERE  
    o2.OfficeID=wm2.OfficeID 
    AND c2.CarID=wm2.CarID 
    AND pd2.CarID=c2.CarID 
    AND ExportQuantity >0 
GROUP BY o2.OfficeID, City) 
ORDER BY SLXE
FETCH FIRST 1 ROW WITH TIES;

-- QUERY 4
-- Tìm khách hàng đã mua xe ở cả hai chi nhánh (CusID, CusName) 
SELECT C1.CUSID, CUSNAME
FROM CUSTOMERS C1, PAYMENTS P1
WHERE C1.CUSID = P1.CUSID
INTERSECT
SELECT C2.CUSID, CUSNAME
FROM CUSTOMERS@off2 C2, PAYMENTS@off2 P2
WHERE C2.CUSID = P2.CUSID


-- QUERY 5
-- Tìm khách hàng chỉ mua xe ở chi nhánh Office1 (CusID, CusName)
SELECT DISTINCT C.CUSID, CUSNAME
FROM CUSTOMERS C, PAYMENTS P1
WHERE C.CUSID=P1.CUSID
MINUS
SELECT DISTINCT C.CUSID, CUSNAME
FROM CUSTOMERS C, PAYMENTS@off2 P2
WHERE C.CUSID=P2.CUSID;

-- QUERY 6
-- Tìm loại xe được mua nhiều nhất (CarID, CarName, SL)
(SELECT pd.CarID,CarName, SUM(ExportQuantity) AS SL
FROM Payment_details pd, Cars c
WHERE 
    c.CarID=pd.CarID
GROUP BY  pd.CarID, CarName)
UNION
(SELECT pd2.CarID,CarName, SUM(ExportQuantity) AS SL
FROM Payment_details@off2 pd2, Cars@off2 c2
WHERE 
    c2.CarID=pd2.CarID
GROUP BY  pd2.CarID, CarName)
ORDER BY SL DESC
FETCH FIRST 1 ROW WITH TIES;


-- QUERY 7
-- Xem số lượng xe hiện có ở cả hai chi nhánh (CarName, SLOffice1, SLOffice2)
SELECT SUM(SLOFFICE) AS TOTAL 
FROM 
((SELECT SUM(QUANTITY) AS SLOFFICE
FROM WAREHOUSE_MANAGES W1 )
UNION
(SELECT SUM(QUANTITY) AS SLOFFICE
FROM  WAREHOUSE_MANAGES@off2 W2))


-- QUERY 8
-- Cho biết tổng số lượng xe đã nhập, đã xuất của từng loại xe trong năm 2020 của chi nhánh Office2 (CarName, SLNhap, SLXuat)
SELECT C.CARID, CARNAME, NVL(SUM(IMPORTQUANTITY), 0) AS SLNhap, NVL(SUM(EXPORTQUANTITY), 0) AS SLXuat
FROM CARS C 
LEFT JOIN WAREHOUSE_IMPORTS@off2 WM2 ON C.CARID=WM2.CARID 
LEFT JOIN PAYMENT_DETAILS@off2 PD2 ON C.CARID=PD2.CARID
GROUP BY C.CARID, CARNAME;


-- QUERY 9
-- Tìm nhân viên bán được nhiều xe nhất trong năm 2016 của cả hai chi nhánh
(SELECT e.EmpID, EmpName, SUM(ExportQuantity) AS DoanhSo 
FROM Employees e, Payments p, Payment_details pd 
WHERE  
  e.EmpID=p.EmpID 
  AND p.PaymentID=pd.PaymentID 
  AND EXTRACT(YEAR FROM PaymentDate) = 2016 
GROUP BY e.EmpID, EmpName) 
UNION 
(SELECT e.EmpID, EmpName, SUM(ExportQuantity) AS DoanhSo 
FROM Employees@off2 e, Payments@off2 p, Payment_details@off2 pd 
WHERE  
  e.EmpID=p.EmpID 
  AND p.PaymentID=pd.PaymentID 
  AND EXTRACT(YEAR FROM PaymentDate) = 2016 
GROUP BY e.EmpID, EmpName) 
ORDER BY DOANHSO DESC
FETCH FIRST 1 ROWS ONLY;


-- QUERY 10
-- Tìm hóa đơn mua tất cả loại xe hiện có trong công ty có nhà cung cấp là Toyota
SELECT *
FROM PAYMENTS P
WHERE NOT EXISTS 
    (
    SELECT * 
    FROM CARS C
    WHERE VENDOR='Toyota'
    AND NOT EXISTS
        (
        SELECT *
        FROM PAYMENT_DETAILS PD
        WHERE PD.CARID=C.CARID
        AND PD.PAYMENTID=P.PAYMENTID))
UNION
SELECT *
FROM PAYMENTS@off2 P2
WHERE NOT EXISTS 
    (
    SELECT * 
    FROM CARS C
    WHERE VENDOR='Toyota'
    AND NOT EXISTS
        (
        SELECT *
        FROM PAYMENT_DETAILS@off2 PD2
        WHERE PD2.CARID=C.CARID
        AND PD2.PAYMENTID=P2.PAYMENTID));



