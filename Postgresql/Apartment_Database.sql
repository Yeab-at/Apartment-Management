CREATE TABLE logtable (
    LogID SERIAL PRIMARY KEY,
    ActionType VARCHAR(10) NOT NULL,          
    TableName VARCHAR(100) NOT NULL,          
    ActionDate DATE NOT NULL DEFAULT CURRENT_DATE,
	ActionTime time NOT NULL DEFAULT CURRENT_TIME,
    UserName VARCHAR(128) NOT NULL          
);

CREATE TABLE Department (
    Department_Id INT PRIMARY KEY,
    Department_Name VARCHAR(50) NOT NULL UNIQUE
);

CREATE OR REPLACE FUNCTION fn_department_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Department', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_department_log
AFTER INSERT OR UPDATE OR DELETE
ON Department
FOR EACH ROW
EXECUTE FUNCTION fn_department_log();

CREATE OR REPLACE Procedure usp_InsertIntoDepartment(DepartmentID INT,DepartmentName VARCHAR)
LANGUAGE PLPGSQL
AS $$
BEGIN
INSERT INTO Department(Department_Id,Department_Name)
VALUES (DepartmentID,DepartmentName);
END;
$$

CREATE TABLE Staff(
    Staff_Id varchar(10) PRIMARY KEY ,
    Staff_fName VARCHAR(25) NOT NULL,
    Staff_lName VARCHAR(25) NOT NULL,
	Staff_Email VARCHAR(50) NOT NULL UNIQUE CHECK (Staff_Email LIKE '%_@__%.__%'),
	staff_phone varchar(10) NOT NULL CHECK (staff_phone ~ '^[0-9]'),
    Department_Id INT NOT NULL,
    FOREIGN KEY (Department_Id) REFERENCES Department(Department_Id)
);

CREATE OR REPLACE FUNCTION fn_staff_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Staff', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_staff_log
AFTER INSERT OR UPDATE OR DELETE
ON Staff
FOR EACH ROW
EXECUTE FUNCTION fn_staff_log();

CREATE OR REPLACE FUNCTION staff_info_together(
    input_staff_id VARCHAR(10),
    input_full_name VARCHAR(100),
    input_departid INT,
    input_staff_email VARCHAR(100),
    input_staff_phone VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    firstname VARCHAR(50);
    lastname VARCHAR(50);
    space_pos INT;
    role_name TEXT;
BEGIN
    input_full_name := LTRIM(RTRIM(input_full_name));
    IF input_full_name = '' THEN
        RAISE EXCEPTION 'Full name cannot be empty.';
    END IF;
    IF input_full_name ~ '[^A-Za-z ]' THEN
        RAISE EXCEPTION 'Full name must contain only letters and spaces.';
    END IF;
    space_pos := LENGTH(input_full_name) - POSITION(' ' IN REVERSE(input_full_name)) + 1;
    firstname := LEFT(input_full_name, space_pos - 1);
    lastname := SUBSTRING(input_full_name FROM space_pos + 1);
    firstname := INITCAP(firstname);
    lastname := INITCAP(lastname);
    IF EXISTS (SELECT 1 FROM staff WHERE staff_email = input_staff_email) THEN
        RAISE EXCEPTION 'Email already exists.';
    END IF;
    INSERT INTO staff (staff_id, staff_fname, staff_lname, department_id, staff_email, staff_phone)
    VALUES (input_staff_id, firstname, lastname, input_departid, input_staff_email, input_staff_phone);
    role_name := CASE input_departid
        WHEN 1 THEN 'hr_member'
        WHEN 2 THEN 'maintenance_member'
        WHEN 3 THEN 'receptionist'
        WHEN 4 THEN 'finance'
        ELSE NULL
    END;
END;
$$;

CREATE TABLE RoomType (
    Room_Type_Id INT PRIMARY KEY,
    Bedrooms VARCHAR(30) NOT NULL,
    Room_Cost NUMERIC(10,2)  NOT NULL,
    Room_Size varchar (50) NOT NULL,
    Room_Description varchar(70)  
);

CREATE OR REPLACE FUNCTION fn_RoomType_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'RoomType', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_RoomType_log
AFTER INSERT OR UPDATE OR DELETE
ON RoomType
FOR EACH ROW
EXECUTE FUNCTION fn_RoomType_log();

CREATE OR REPLACE PROCEDURE usp_InsertIntoRoomType
(input_Room_Type_Id INT,
input_Bedrooms VARCHAR(100),
input_Room_Cost NUMERIC(10,2) ,
input_Room_Size VARCHAR(50),
input_Room_Description VARCHAR(255))
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO ROOMTYPE (ROOM_TYPE_ID, BEDROOMS, ROOM_COST, ROOM_SIZE, ROOM_DESCRIPTION)
    VALUES (input_Room_Type_Id, input_Bedrooms, input_Room_Cost, input_Room_Size, input_Room_Description);
END;
$$

CREATE TABLE Room (
    Room_No INT PRIMARY KEY,
    Room_Type_Id INT NOT NULL,
    Room_Availability VARCHAR(10) NOT NULL CHECK (Room_Availability IN ('Available', 'Occupied','Unavailable')), 
    Floor_Number INT NOT NULL,
    FOREIGN KEY (Room_Type_Id) REFERENCES RoomType(Room_Type_Id)
);

CREATE OR REPLACE FUNCTION fn_Room_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Room', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_Room_log
AFTER INSERT OR UPDATE OR DELETE
ON Room
FOR EACH ROW
EXECUTE FUNCTION fn_Room_log();

CREATE or REPLACE PROCEDURE usp_RoomInfo(
input_Room_No INT,
input_Room_Type_Id INT,
input_Room_Availability VARCHAR(20),
input_Floor_Number INT)
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO Room (Room_No, Room_Type_Id, Room_Availability, Floor_Number)
    VALUES (input_Room_No, input_Room_Type_Id, input_Room_Availability, input_Floor_Number);
END;
$$;

CREATE TABLE Tenant (
    Tenant_Id SERIAL PRIMARY KEY,
    Tenant_fName VARCHAR(50) NOT NULL,
    Tenant_lName VARCHAR(50) NOT NULL,
    Tenant_Email VARCHAR(100) NOT NULL UNIQUE CHECK(Tenant_Email Like '%_@__%.__%'),
    Tenant_Phone varchar(10) NOT NULL UNIQUE CHECK (Tenant_Phone ~ '^[0-9]') 
);

CREATE OR REPLACE FUNCTION fn_Tenant_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Tenant', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_Tenant_log
AFTER INSERT OR UPDATE OR DELETE
ON Tenant
FOR EACH ROW
EXECUTE FUNCTION fn_Tenant_log();

CREATE OR REPLACE PROCEDURE usp_tenant_info_together(
    input_full_name VARCHAR(100),
    input_phone VARCHAR(20),
    input_tenant_email VARCHAR(100)
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    fname VARCHAR(50);
    lname VARCHAR(50);
    space_pos INT;
BEGIN
    input_full_name := LTRIM(RTRIM(input_full_name));
    IF input_full_name = '' THEN
        RAISE EXCEPTION 'Full name cannot be empty.';
    END IF;
    IF input_full_name ~ '[^A-Za-z ]' THEN
        RAISE EXCEPTION 'Full name must contain only letters and spaces.';
    END IF;
    IF EXISTS (SELECT 1 FROM tenant WHERE tenant_email = input_tenant_email) THEN
        RAISE EXCEPTION 'Email is in use.';
    END IF;
    space_pos := LENGTH(input_full_name) - POSITION(' ' IN REVERSE(input_full_name)) + 1;
    IF space_pos = 0 THEN
        fname := INITCAP(input_full_name);
        lname := '';
    ELSE
        fname := INITCAP(LEFT(input_full_name, space_pos - 1));
        lname := INITCAP(SUBSTRING(input_full_name FROM space_pos + 1));
    END IF;
    INSERT INTO tenant (tenant_fname, tenant_lname, tenant_email, tenant_phone)
    VALUES (fname, lname, input_tenant_email, input_phone);
END;
$$;

CREATE TABLE TenantRoom (
    Tenant_Id INT NOT NULL,
    Room_No INT NOT NULL,
    Occupancy_StartDate DATE NOT NULL,
    Occupancy_EndDate DATE ,
    PRIMARY KEY (Tenant_Id, Room_No),
    FOREIGN KEY (Tenant_Id) REFERENCES Tenant(Tenant_Id),
    FOREIGN KEY (Room_No) REFERENCES Room(Room_No)
);

CREATE OR REPLACE FUNCTION fn_TenantRoom_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'TenantRoom', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_TenantRoom_log
AFTER INSERT OR UPDATE OR DELETE
ON TenantRoom
FOR EACH ROW
EXECUTE FUNCTION fn_TenantRoom_log();

CREATE OR REPLACE PROCEDURE usp_into_tenant_room(
    input_tenid INT,
    input_roomno INT,
    input_startdate DATE,
    input_enddate DATE
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    start_diff INT;
    end_diff INT;
BEGIN
    start_diff := (input_startdate - CURRENT_DATE);
    end_diff := (input_enddate - input_startdate);
    IF  start_diff < 1 THEN
        RAISE EXCEPTION 'Your occupancy date has to be at least 1 day from today.';
    END IF;
    IF end_diff < 90 THEN
        RAISE EXCEPTION 'Your occupancy ending date has to be at least 3 months from occupancy starting date.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tenant WHERE tenant_id = input_tenid) THEN
        RAISE EXCEPTION 'Invalid Tenant_Id';
    END IF;
    IF EXISTS (SELECT 1 FROM tenantroom WHERE tenant_id = input_tenid) THEN
        RAISE EXCEPTION 'Tenant already has an assigned room.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM room WHERE room_no = input_roomno AND room_availability = 'available') THEN
        RAISE EXCEPTION 'Invalid Room_Id';
    END IF;
    INSERT INTO tenantroom (tenant_id, room_no, occupancy_startdate, occupancy_enddate)
    VALUES (input_tenid, input_roomno, input_startdate, input_enddate);
    UPDATE room
    SET room_availability = 'Occupied'
    WHERE room_no = input_roomno AND room_availability = 'Available';
END;
$$;

CREATE TABLE PaymentAgreement (
    Agreement_Id SERIAL PRIMARY KEY,
    Tenant_Id INT NOT NULL,
	payment_date DATE ,
    Room_No INT NOT NULL,
    Room_Cost NUMERIC(10,2) NOT NULL,
	agreed_on date default CURRENT_DATE,
    FOREIGN KEY (Tenant_Id) REFERENCES Tenant(Tenant_Id),
    FOREIGN KEY (Room_No) REFERENCES Room(Room_No)
);

CREATE OR REPLACE FUNCTION fn_PaymentAgreement_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'PaymentAgreement', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_PaymentAgreement_log
AFTER INSERT OR UPDATE OR DELETE
ON PaymentAgreement
FOR EACH ROW
EXECUTE FUNCTION fn_PaymentAgreement_log();

CREATE TABLE Payment (
    Payment_Id SERIAL PRIMARY KEY,
    Agreement_Id INT NOT NULL,
    Payment_DoneDate DATE NOT NULL default CURRENT_DATE,
    Payment_Amount NUMERIC(10,2) NOT NULL,
	Payment_Status VARCHAR(20) NOT NULL DEFAULT 'unpaid' CHECK (Payment_Status IN ('Paid', 'Unpaid','Overdue')),
	Payment_lateStatus VARCHAR(20) NOT NULL CHECK (Payment_lateStatus IN ('Late', 'On time')),
	FOREIGN KEY (Agreement_Id) REFERENCES PaymentAgreement(Agreement_Id)
);

CREATE OR REPLACE FUNCTION fn_Payment_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Payment', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_Payment_log
AFTER INSERT OR UPDATE OR DELETE
ON Payment
FOR EACH ROW
EXECUTE FUNCTION fn_Payment_log();

CREATE OR REPLACE FUNCTION fill_completeagreement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_room_cost NUMERIC(10,2);
BEGIN
    v_room_cost := (
        SELECT rt.room_cost
        FROM roomtype rt
        JOIN room r ON r.room_type_id = rt.room_type_id
        WHERE r.room_no = NEW.room_no
    );
    INSERT INTO paymentagreement (tenant_id, room_no, room_cost, payment_date)
    VALUES (NEW.tenant_id, NEW.room_no, v_room_cost, CURRENT_DATE);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION GetAgreementByRoom(p_room_no INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_agreement_id INT;
BEGIN
    SELECT Agreement_Id INTO v_agreement_id
    FROM PaymentAgreement
    WHERE Room_No = p_room_no
    LIMIT 1;
    RETURN v_agreement_id;
END;
$$;


CREATE OR REPLACE PROCEDURE usp_payment(
    input_room_no INT,
    input_payment_amount NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    room_cost NUMERIC(10,2);
    agreement_id INT;
    payment_date DATE;
BEGIN
    room_cost := (
        SELECT roomtype.room_cost
        FROM roomtype
        JOIN room ON room.room_type_id = roomtype.room_type_id
        JOIN tenantroom ON tenantroom.room_no = room.room_no
        WHERE tenantroom.room_no = input_room_no
          AND tenantroom.occupancy_enddate IS NULL
    );

    IF input_payment_amount != room_cost THEN
        RAISE EXCEPTION 'Expected amount is: %', room_cost;
    END IF;

    agreement_id := (
        SELECT paymentagreement.agreement_id
        FROM paymentagreement
        JOIN tenantroom ON tenantroom.tenant_id = paymentagreement.tenant_id
        WHERE tenantroom.room_no = input_room_no
          AND tenantroom.occupancy_enddate IS NULL
    );

    payment_date := (
        SELECT paymentagreement.payment_date
        FROM paymentagreement
        JOIN tenantroom ON tenantroom.tenant_id = paymentagreement.tenant_id
        WHERE tenantroom.room_no = input_room_no
          AND tenantroom.occupancy_enddate IS NULL
    );

    IF CURRENT_DATE <= payment_date THEN
        INSERT INTO payment (agreement_id, payment_amount, payment_status, payment_latestatus)
        VALUES (agreement_id, input_payment_amount, 'paid', 'On Time');
    ELSE
        INSERT INTO payment (agreement_id, payment_amount, payment_status, payment_latestatus)
        VALUES (agreement_id, input_payment_amount, 'paid', 'Late');
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE usp_overduepayments()
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_date DATE := CURRENT_DATE;
BEGIN
    UPDATE payment
    SET payment_status = 'Overdue'
    FROM paymentagreement
    WHERE payment.agreement_id = paymentagreement.agreement_id
      AND (CURRENT_DATE - payment.payment_donedate) >= 30
      AND v_current_date > paymentagreement.payment_date;
END;
$$;


CREATE TABLE maintenance(
    request_id SERIAL PRIMARY KEY,
    room_no INT NOT NULL,
    issue VARCHAR(255) NOT NULL,
    request_date DATE DEFAULT CURRENT_DATE,
    maintenance_status VARCHAR(50) NOT NULL DEFAULT 'Unresolved'
        CHECK (maintenance_status IN ('Resolved', 'Unresolved')),
    FOREIGN KEY (room_no) REFERENCES room(room_no)
);

CREATE OR REPLACE FUNCTION fn_maintenance_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'Maintenance', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_maintenance_log
AFTER INSERT OR UPDATE OR DELETE
ON maintenance
FOR EACH ROW
EXECUTE FUNCTION fn_maintenance_log();


CREATE OR REPLACE PROCEDURE usp_createMaintenanceRequest(
    input_room_no INT,
    input_issue VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM room WHERE room_no = input_room_no) THEN
        RAISE EXCEPTION 'Room does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM room WHERE room_no = input_room_no AND room_availability = 'Occupied') THEN
        RAISE EXCEPTION 'Invalid Room';
    END IF;

    INSERT INTO maintenance (room_no, issue)
    VALUES (input_room_no, input_issue);
END;
$$;

CREATE TABLE tenantstaff (
    issue_number SERIAL PRIMARY KEY,
    room_no INT,
    staff_id VARCHAR(10) NOT NULL,
    assistance_type VARCHAR(50) NOT NULL,
    assistance_issueddate DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE OR REPLACE FUNCTION fn_tenantstaff_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logtable (ActionType, TableName, ActionDate, ActionTime, UserName)
    VALUES (TG_OP, 'TenantStaff', CURRENT_DATE, CURRENT_TIME, CURRENT_USER);
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_tenantstaff_log
AFTER INSERT OR UPDATE OR DELETE
ON tenantstaff
FOR EACH ROW
EXECUTE FUNCTION fn_tenantstaff_log();


CREATE OR REPLACE PROCEDURE usp_issuestafftomain(
    input_room_no INT,
    input_staff_id VARCHAR(10),
    input_assistance_type VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM room WHERE room_no = input_room_no) THEN
        RAISE EXCEPTION 'Room does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM room WHERE room_no = input_room_no AND room_availability = 'Occupied') THEN
        RAISE EXCEPTION 'Room is not occupied';
    END IF;

    INSERT INTO tenantstaff (room_no, staff_id, assistance_type)
    VALUES (input_room_no, input_staff_id, input_assistance_type);
END;
$$;


CREATE OR REPLACE PROCEDURE usp_cancellease(
    input_tenant_id INT,
    input_room_no INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    rowcount INT;
BEGIN
    UPDATE tenantroom
    SET occupancy_enddate = CURRENT_DATE
    WHERE tenant_id = input_tenant_id
      AND room_no = input_room_no
      AND (occupancy_enddate IS NULL OR occupancy_enddate > CURRENT_DATE);

    GET DIAGNOSTICS rowcount = ROW_COUNT;

    IF rowcount = 0 THEN
        RAISE NOTICE 'No active lease found to cancel for given Tenant and Room.';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION fn_icancelled_lease()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE room
    SET room_availability = 'Available'
    WHERE room_no = NEW.room_no
      AND NEW.occupancy_enddate IS NOT NULL
      AND NEW.occupancy_enddate <= CURRENT_DATE
      AND room_availability ILIKE 'available';

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_icancelled_lease
AFTER UPDATE ON tenantroom
FOR EACH ROW
EXECUTE FUNCTION fn_icancelled_lease();

CREATE OR REPLACE FUNCTION fn_dcancelled_lease()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_firstname VARCHAR(25);
    v_lastname VARCHAR(25);
BEGIN
    v_firstname := (
        SELECT tenant_fname
        FROM tenant
        WHERE tenant_id = OLD.tenant_id
    );

    v_lastname := (
        SELECT tenant_lname
        FROM tenant
        WHERE tenant_id = OLD.tenant_id
    );

    RAISE NOTICE 'Goodbye % %', v_firstname, v_lastname;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_dcancelled_lease
AFTER DELETE ON tenantroom
FOR EACH ROW
EXECUTE FUNCTION fn_dcancelled_lease();

CREATE OR REPLACE PROCEDURE usp_endlease()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tenantroom
    USING paymentagreement pa, payment p
    WHERE tenantroom.tenant_id = pa.tenant_id
      AND pa.agreement_id = p.agreement_id
      AND tenantroom.occupancy_enddate = CURRENT_DATE
      AND p.payment_status = 'Paid';
END;
$$;

CREATE ROLE hr_member LOGIN PASSWORD 'hr_user';
GRANT EXECUTE ON PROCEDURE usp_InsertIntoDepartment TO hr_member;
GRANT SELECT ON Department TO hr_member;
GRANT EXECUTE ON FUNCTION staff_info_together TO hr_member;

CREATE ROLE maintenance_member LOGIN PASSWORD 'maintenance_member_user';
GRANT EXECUTE ON PROCEDURE usp_issuestafftomain TO maintenance_member;
GRANT SELECT ON maintenance TO maintenance_member;
GRANT SELECT ON tenantstaff TO maintenance_member;

CREATE ROLE receptionist LOGIN PASSWORD 'receptionist_user';
GRANT EXECUTE ON PROCEDURE usp_tenant_info_together TO receptionist;
GRANT SELECT ON tenant TO receptionist;
GRANT SELECT ON tenantroom TO receptionist;
GRANT EXECUTE ON PROCEDURE usp_into_tenant_room TO receptionist;
GRANT EXECUTE ON PROCEDURE usp_cancellease TO receptionist;

CREATE ROLE finance LOGIN PASSWORD 'finance_user';
GRANT EXECUTE ON PROCEDURE usp_payment TO finance;
