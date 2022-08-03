create schema Clinic_2022;
use Clinic_2022;

########## Creating Tables ##########

CREATE TABLE Clinic
(c_name		CHAR(25) NOT NULL,
c_address	CHAR(50) NOT NULL,
PRIMARY KEY		(c_name)
)ENGINE = InnoDB;

CREATE TABLE Doctor (
    d_id INT NOT NULL,
    d_f_name CHAR(25) NOT NULL,
    d_l_name CHAR(25) NOT NULL,
    d_gender BOOL NOT NULL,
    d_years_of_exp INT,
    d_dob DATE NOT NULL,
    d_age FLOAT,
    manager_id INT,
    PRIMARY KEY (d_id)
)  ENGINE=INNODB;

CREATE TABLE Patient (
    p_id INT NOT NULL,
    p_f_name CHAR(25) NOT NULL,
    p_l_name CHAR(25) NOT NULL,
    p_gender BOOL NOT NULL,
    p_dob DATE NOT NULL,
    p_age FLOAT,
    PRIMARY KEY (p_id)
)  ENGINE=INNODB;

CREATE TABLE Schedules (
    sc_id INT NOT NULL,
    d_id INT NOT NULL,
    c_name CHAR(25) NOT NULL,
    sc_day CHAR(10),
    sc_start_hour TIME,
    sc_end_hour TIME,
    PRIMARY KEY (sc_id),
    CONSTRAINT fk_doctor_id_1 FOREIGN KEY (d_id)
        REFERENCES Doctor (d_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_clinic FOREIGN KEY (c_name)
        REFERENCES Clinic (c_name)
        ON DELETE CASCADE
)  ENGINE=INNODB;

CREATE TABLE Room (
    r_num INT NOT NULL,
    r_type CHAR(25),
    PRIMARY KEY (r_num)
)  ENGINE=INNODB;

CREATE TABLE Session (
    s_id INT NOT NULL,
    d_id INT NOT NULL,
    p_id INT NOT NULL,
    r_num INT NOT NULL,
    s_date DATE,
    s_hour TIME,
    PRIMARY KEY (s_id),
    CONSTRAINT fk_doctor_id_2 FOREIGN KEY (d_id)
        REFERENCES Doctor (d_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_patient_id_1 FOREIGN KEY (p_id)
        REFERENCES Patient (p_id)
        ON DELETE CASCADE,
	CONSTRAINT fk_room_num_1 FOREIGN KEY (r_num)
        REFERENCES Room (r_num)
        ON DELETE CASCADE
)  ENGINE=INNODB;

CREATE TABLE Prescription (
    prsc_id INT NOT NULL,
    s_id INT NOT NULL,
    prsc_date CHAR(25),
    PRIMARY KEY (prsc_id),
    CONSTRAINT fk_session_id_1 FOREIGN KEY (s_id)
        REFERENCES Session (s_id)
        ON DELETE CASCADE
)  ENGINE=INNODB;

CREATE TABLE Analysis (
    a_id INT NOT NULL,
	s_id INT NOT NULL,
    a_RBC FLOAT,
    a_WBC FLOAT,
    a_HGB FLOAT,
    PRIMARY KEY (a_id),
    CONSTRAINT fk_session_id_2 FOREIGN KEY (s_id)
        REFERENCES Session (s_id)
        ON DELETE CASCADE
)  ENGINE=INNODB;

CREATE TABLE Diagnosis (
    diag_id INT NOT NULL,
    diag_name CHAR(30),
    PRIMARY KEY (diag_id)
)  ENGINE=INNODB;

CREATE TABLE DOS (
    diag_id INT NOT NULL,
    s_id INT NOT NULL,
    
    CONSTRAINT fk_diagnosis_id_1 FOREIGN KEY (diag_id)
        REFERENCES Diagnosis (diag_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_session_id_3 FOREIGN KEY (s_id)
        REFERENCES Session (s_id)
        ON DELETE CASCADE
)  ENGINE=INNODB;

CREATE TABLE Medicine (
    m_id INT NOT NULL,
    m_name CHAR(30),
    PRIMARY KEY (m_id)
)  ENGINE=INNODB;

CREATE TABLE Lines_In_Prescription (
    line_num INT NOT NULL,
    prsc_id INT NOT NULL,
    m_id INT NOT NULL,
    lip_amount INT,
    
    PRIMARY KEY (prsc_id, line_num),
    
    CONSTRAINT fk_prescription_id_1 FOREIGN KEY (prsc_id)
	REFERENCES Prescription (prsc_id)
    ON DELETE CASCADE,
    CONSTRAINT fk_medicine_id_1 FOREIGN KEY (m_id)
    REFERENCES Medicine (m_id)
    ON DELETE CASCADE
)  ENGINE=INNODB;

########## Creating Log Files ##########

CREATE TABLE Patient_Log (
    p_id INT NOT NULL,
    p_f_name_new CHAR(25),
    p_f_name_old CHAR(25),
    p_l_name_new CHAR(25),
    p_l_name_old CHAR(25),
    p_gender_new BOOL,
    p_gender_old BOOL,
    p_dob_new DATE,
    p_dob_old DATE,
    p_age_new FLOAT,
    p_age_old FLOAT,
    command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Patient_inst_trigg AFTER INSERT ON Patient
FOR EACH ROW
BEGIN
	INSERT INTO Patient_Log VALUES(new.p_id, new.p_f_name, null, new.p_l_name, null, new.p_gender, null, new.p_dob, null, new.p_age, null, now(), 'INSERT');
END$
delimiter ;

delimiter $
CREATE TRIGGER Patient_updt_trigg AFTER UPDATE ON Patient
FOR EACH ROW
BEGIN
	INSERT INTO Patient_Log VALUES(new.p_id, new.p_f_name, old.p_f_name, new.p_l_name, old.p_l_name, new.p_gender, old.p_gender, new.p_dob, old.p_dob, new.p_age, old.p_age, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Patient_del_trigg AFTER DELETE ON Patient
FOR EACH ROW
BEGIN
	INSERT INTO Patient_Log VALUES(old.p_id, null, old.p_f_name, null, old.p_l_name, null, old.p_gender, null, old.p_dob, null, old.p_age, now(), 'DELETE');
END$
delimiter ;

CREATE TABLE Session_Log (
	s_id INT NOT NULL,
    d_id INT NOT NULL,
    p_id INT NOT NULL,
    r_num INT NOT NULL,
    s_date_new DATE,
	s_date_old DATE,
    s_hour_new TIME,
    s_hour_old TIME,
    command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Session_inst_trigg AFTER INSERT ON Session
FOR EACH ROW
BEGIN
	INSERT INTO Session_Log VALUES(new.s_id, new.d_id,new.p_id,new.r_num,new.s_date,null,new.s_hour,null, now(), 'INSERT');
END$
delimiter;

delimiter $
CREATE TRIGGER Session_updt_trigg AFTER UPDATE ON Session
FOR EACH ROW
BEGIN
	INSERT INTO Session_Log VALUES(new.s_id, new.d_id,new.p_id,new.r_num,new.s_date,old.s_date,new.s_hour,old.s_hour, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Session_del_trigg AFTER DELETE ON Session
FOR EACH ROW
BEGIN
	INSERT INTO Session_Log VALUES(old.s_id, old.d_id,old.p_id,old.r_num,null,old.s_date,null,old.s_hour, now(), 'DELETE');
END$
delimiter ;

CREATE TABLE Doctor_log (
    d_id INT NOT NULL,
    d_f_name_new CHAR(25) ,
    d_f_name_old CHAR(25) ,
    d_l_name_new CHAR(25) ,
    d_l_name_old CHAR(25) ,
    d_gender_new BOOL ,
    d_gender_old BOOL ,
    d_years_of_exp_new INT,
    d_years_of_exp_old INT,
    d_dob_new DATE ,
    d_dob_old DATE ,
    d_age_new FLOAT,
    d_age_old FLOAT,
    manager_id_new INT,
    manager_id_old INT,
	command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Doctor_inst_trigg AFTER INSERT ON Doctor
FOR EACH ROW
BEGIN
	INSERT INTO Doctor_Log VALUES(new.d_id, new.d_f_name,null,new.d_l_name,null,new.d_gender,null,new.d_years_of_exp,null,new.d_dob,null,new.d_age,null,new.manager_id,null, now(), 'INSERT');
END$
delimiter;

delimiter $
CREATE TRIGGER Doctor_updt_trigg AFTER UPDATE ON Doctor
FOR EACH ROW
BEGIN
	INSERT INTO Doctor_Log VALUES(new.d_id, new.d_f_name,old.d_f_name,new.d_l_name,old.d_l_name,new.d_gender,old.d_gender,new.d_years_of_exp,old.d_years_of_exp,new.d_dob,old.d_dob,new.d_age,old.d_age,new.manager_id,old.manager_id, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Doctor_del_trigg AFTER DELETE ON Doctor
FOR EACH ROW
BEGIN
INSERT INTO Doctor_Log VALUES(old.d_id, null,old.d_f_name,null,old.d_l_name,null,old.d_gender,null,old.d_years_of_exp,null,old.d_dob,null,old.d_age,null,old.manager_id, now(), 'DELETE');
END$
delimiter ;

CREATE TABLE Schedules_Log (
    sc_id INT,
    d_id INT,
    c_name CHAR(25),
    sc_day_new CHAR(10),
    sc_day_old CHAR(10),
    sc_start_hour_new TIME,
    sc_start_hour_old TIME,
    sc_end_hour_new TIME,
    sc_end_hour_old TIME,
	command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Schedules_inst_trigg AFTER INSERT ON Schedules
FOR EACH ROW
BEGIN
	INSERT INTO Schedules_Log VALUES(new.sc_id, new.d_id, new.c_name, new.sc_day, null, new.sc_start_hour, null, new.sc_end_hour, null, now(), 'INSERT');
END$
delimiter ;

delimiter $
CREATE TRIGGER Schedules_updt_trigg AFTER UPDATE ON Schedules
FOR EACH ROW
BEGIN
	INSERT INTO Schedules_Log VALUES(new.sc_id, new.d_id, new.c_name, new.sc_day, old.sc_day, new.sc_start_hour, old.sc_start_hour, new.sc_end_hour, old.sc_end_hour, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Schedules_del_trigg AFTER DELETE ON Schedules
FOR EACH ROW
BEGIN
	INSERT INTO Schedules_Log VALUES(old.sc_id, old.d_id, old.c_name, null, old.sc_day, null, old.sc_start_hour, null, old.sc_end_hour, now(), 'DELETE');
END$
delimiter ;

CREATE TABLE Medicine_Log (
    m_id INT,
    m_name_new CHAR(30),
    m_name_old CHAR(30),
    command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Medicine_inst_trigg AFTER INSERT ON Medicine
FOR EACH ROW
BEGIN
	INSERT INTO Medicine_Log VALUES(new.m_id,new.m_name,null, now(), 'INSERT');
END$
delimiter;

delimiter $
CREATE TRIGGER Medicine_updt_trigg AFTER UPDATE ON Medicine
FOR EACH ROW
BEGIN
	INSERT INTO Medicine_Log VALUES(new.m_id,new.m_name,old.m_name, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Medicine_del_trigg AFTER DELETE ON Medicine
FOR EACH ROW
BEGIN
INSERT INTO  Medicine_Log VALUES(old.m_id,null,old.m_name, now(), 'DELETE');
END$
delimiter ;

CREATE TABLE Diagnosis_Log (
    diag_id INT,
    diag_name_new CHAR(30),
    diag_name_old CHAR(30),
    command_ts timestamp,
    command char(10)
)  ENGINE=INNODB;

delimiter $
CREATE TRIGGER Diagnosis_inst_trigg AFTER INSERT ON Diagnosis
FOR EACH ROW
BEGIN
	INSERT INTO Diagnosis_Log VALUES(new.diag_id, new.diag_name, null, now(), 'INSERT');
END$
delimiter ;

delimiter $
CREATE TRIGGER Diagnosis_updt_trigg AFTER UPDATE ON Diagnosis
FOR EACH ROW
BEGIN
	INSERT INTO Diagnosis_Log VALUES(new.diag_id, new.diag_name, old.diag_name, now(), 'UPDATE');
END$
delimiter ;

delimiter $
CREATE TRIGGER Diagnosis_del_trigg AFTER DELETE ON Diagnosis
FOR EACH ROW
BEGIN
	INSERT INTO Diagnosis_Log VALUES(old.diag_id, null, old.diag_name, now(), 'DELETE');
END$
delimiter ;

########## Populating the database ##########

insert into Doctor values
(341270111, "Ross", "Geller", 0, 20, '1994-9-8', null, null),
(341270222, "Rachel", "Green", 1, 10, '1969-2-11', null, 341270111),
(341270333, "Monika", "Geller", 1, 12, '1964-6-15', null, 341270111),
(341270444, "Phoebe", "Buffay", 1, 5, '1963-7-30', null, 341270111),
(341270555, "Joey", "Tribbiani", 0, 8, '1967-7-25', null, 341270111),
(341270666, "Chandler", "Bing", 0, 14, '1969-8-19', null, 341270111);
SELECT * FROM Doctor;

INSERT INTO Room VALUES
(1,"Lab"),
(2,"Lab"),
(3,"Examination"),
(4,"Examination"),
(5,"Examination"),
(6,"Examination");
SELECT * FROM Room;

INSERT INTO Diagnosis VALUES
(100,"Covid-19"),
(101,"Flue"),
(102,"Heart Stroke"),
(103,"Cancer"),
(104,"Diabetes"),
(105,"Headaches"),
(106,"Stomach Aches");
SELECT * FROM Diagnosis;

insert into Medicine values
(1,'levothyroxine'),
(2,'rosuvastatin'),
(3,'albuterol'),
(4,'fluticasone'),
(5,'esomeprazole'),
(6,'insulin'),
(7,'glargine'),
(8,'sitagliptin'),
(9,'tiotropium'),
(10,'pregabalin'),
(11,'Advil');
SELECT * FROM Medicine;

insert into Patient values
('321561231','Frank','Kohen','0','1960-11-10', null),
('213562145','Estelle','Costanza','1','1970-11-10', null),
('342341231','Susan','Ross','1','1980-11-10', null),
('634612239','Morty','Seinfeld','0','1990-11-10', null),
('352345232','jerry','Seinfeld','0','1965-11-10', null),
('321561234','George','Costanza','0','1982-11-10', null),
('321565435','Elaine','Benes','1','1995-11-10', null),
('323454237','Cosmo','Kramer','0','2000-11-10', null),
('312853231',' Joe','Davola','0','1957-11-10', null),
('223324236','Kenny','Bania','0','1955-11-10', null);
SELECT * FROM Patient;

insert into Clinic values
("Ocean Medical Clinic", "Trinity House 1-3 Ocean Village");
SELECT * FROM Clinic;

insert into Schedules values
(221, 341270111, "Ocean Medical Clinic", "Sunday", '10:00:00', '16:00:00'),
(222, 341270111, "Ocean Medical Clinic", "Thursday", '12:00:00', '17:00:00'),
(223, 341270222, "Ocean Medical Clinic", "Monday", '08:00:00', '16:00:00'),
(224, 341270222, "Ocean Medical Clinic", "Friday", '07:30:00', '13:00:00'),
(225, 341270333, "Ocean Medical Clinic", "Tuesday", '08:00:00', '14:00:00'),
(226, 341270333, "Ocean Medical Clinic", "Thursday", '08:00:00', '12:00:00'),
(227, 341270444, "Ocean Medical Clinic", "Monday", '10:00:00', '16:00:00'),
(228, 341270444, "Ocean Medical Clinic", "Wednesday", '12:00:00', '18:00:00'),
(229, 341270555, "Ocean Medical Clinic", "Wednesday", '08:00:00', '14:00:00'),
(230, 341270555, "Ocean Medical Clinic", "Moday", '14:00:00', '20:00:00'),
(231, 341270666, "Ocean Medical Clinic", "Sunday", '08:00:00', '16:00:00'),
(232, 341270666, "Ocean Medical Clinic", "Monday", '08:00:00', '16:00:00');
SELECT * FROM Schedules;

insert into Session values
(1000, 341270111, 321561231, 3, '2022-1-2', '10:00:00'),
(1001, 341270111, 213562145, 3, '2022-1-2', '10:30:00'),
(1002, 341270222, 213562145, 4, '2022-1-3', '08:00:00'),
(1003, 341270222, 312853231, 4, '2022-1-3', '08:30:00'),
(1004, 341270333, 342341231, 5, '2022-1-4', '13:00:00'),
(1005, 341270333, 634612239, 5, '2022-1-4', '13:30:00'),
(1006, 341270444, 352345232, 6, '2022-1-5', '12:00:00'),
(1007, 341270444, 634612239, 6, '2022-1-5', '13:00:00'),
(1008, 341270333, 223324236, 3, '2022-1-6', '08:00:00'),
(1009, 341270111, 323454237, 4, '2022-1-6', '12:00:00'),
(1010, 341270222, 321565435, 3, '2022-1-7', '07:00:00'),
(1011, 341270222, 321561234, 3, '2022-1-7', '08:00:00'),
(1012, 341270666, 321565435, 4, '2022-1-9', '08:00:00'),
(1013, 341270666, 321561234, 5, '2022-1-9', '15:00:00'),
(1014, 341270222, 321561234, 1, '2022-1-10', '08:00:00'),
(1015, 341270333, 352345232, 2, '2022-1-11', '09:00:00'),
(1016, 341270222, 634612239, 1, '2022-1-10', '09:00:00'),
(1017, 341270333, 342341231, 2, '2022-1-11', '10:00:00'),
(1018, 341270222, 213562145, 1, '2022-1-10', '10:00:00');
SELECT * FROM Session;

insert into DOS values
(100,1000),
(105,1000),
(103,1001),
(105,1001),
(102,1002),
(104,1003),
(106,1004),
(101,1005),
(101,1006),
(104,1007),
(104,1008),
(106,1009),
(105,1010),
(105,1011),
(105,1012),
(103,1013);
SELECT * FROM DOS;

insert into Analysis values
(3000, 1014, 7.2, 3.4, 12.1),
(3001, 1015, 5.5, 8.9, 16.0),
(3002, 1016, 4.21, 3.98, 19.1),
(3003, 1017, 5.64, 7.02, 20),
(3004, 1018, 5.0, 4.0, 12.12);
SELECT * FROM Analysis;

insert into Prescription values
(4000, 1003, '2022-1-3'),
(4001, 1002, '2022-1-3'),
(4002, 1004, '2022-1-4'),
(4003, 1006, '2022-1-5'),
(4004, 1007, '2022-1-5'),
(4005, 1008, '2022-1-6');
SELECT * FROM Prescription;

insert into Lines_In_Prescription values
(1, 4000, 6, 10),
(1, 4001, 2, 10),
(2, 4001, 3, 10),
(1, 4002, 4, 5),
(2, 4002, 5, 6),
(1, 4003, 11, 10),
(2, 4003, 8, 11),
(3, 4003, 9, 12),
(1, 4004, 6, 10),
(1, 4005, 6, 10);
SELECT * FROM Lines_In_Prescription;

###################### Calculate age of Patients and Doctors######################
##### calculate Patient table age
DROP PROCEDURE IF EXISTS UpdatePatientAge;
DELIMITER $$
CREATE PROCEDURE UpdatePatientAge( in pid INT)
BEGIN
	# get patient DOB
    SELECT Patient.p_dob INTO @DOB FROM Patient WHERE Patient.p_id = pid;
    # get patient age based on DOB
    SELECT timestampdiff(YEAR, @DOB, CURDATE()) INTO @AGE;
    # update patient age
    UPDATE Patient SET Patient.p_age = @age WHERE Patient.p_id = pid;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS UpdatePatientTableAge;
DELIMITER $$
CREATE PROCEDURE UpdatePatientTableAge()
BEGIN
	DECLARE n INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    
    SELECT count(*) INTO n from Patient;
    SET i = 0;
    
    WHILE i < n DO
		SELECT Patient.p_id INTO @pid FROM Patient LIMIT i, 1;
        call UpdatePatientAge(@pid);
        SET i = i + 1;
    END WHILE;
    
END$$
DELIMITER ;
call UpdatePatientTableAge();

##### calculate Doctor table age

DROP PROCEDURE IF EXISTS UpdateDoctorAge;
DELIMITER $$
CREATE PROCEDURE UpdateDoctorAge( in did INT)
BEGIN
	# get patient DOB
    SELECT Doctor.d_dob INTO @DOB FROM Doctor WHERE Doctor.d_id = did;
    # get patient age based on DOB
    SELECT timestampdiff(YEAR, @DOB, CURDATE()) INTO @AGE;
    # update patient age
    UPDATE Doctor SET Doctor.d_age = @AGE WHERE Doctor.d_id = did;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS UpdateDoctorTableAge;
DELIMITER $$
CREATE PROCEDURE UpdateDoctorTableAge()
BEGIN
	DECLARE n INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    
    SELECT count(*) INTO n from Doctor;
    SET i = 0;
    
    WHILE i < n DO
		SELECT Doctor.d_id INTO @did FROM Doctor LIMIT i, 1;
        call UpdateDoctorAge(@did);
        SET i = i + 1;
    END WHILE;
    
END$$
DELIMITER ;
call UpdateDoctorTableAge();

########## Creating Queries ##########

##### Patient Queries

### 1 - Display all Prescription(includeign lines) worte for a patient (using patient_id)
DELIMITER $$
CREATE PROCEDURE GetPrcPerPait1( in pai_Id varchar(255))
BEGIN
select line.prsc_id,Medicine.m_name,line.lip_amount as amount from 
	Lines_In_Prescription as line,
(select pre.prsc_id  from
	Prescription as pre,
	Session as si,
	Patient  as pai
    where
    pai.p_id  = si.p_id
    and pre.s_id = si.s_id
    and pai.p_id  = pai_Id) as tmp,Medicine
    where
        tmp.prsc_id = line.prsc_id and
        line.m_id =Medicine.m_id;
END$$
DELIMITER ;
#test with Estelle
call GetPrcPerPait1('213562145');

### 2 - for a given patient id and doctor name display all sessions that the patient had with the doctor
DELIMITER $$
CREATE PROCEDURE DisplaySessionOfPatientWithDoctor( in pid INT, dname CHAR(25))
BEGIN
	select * from patient, session, doctor
	where
    patient.p_id = session.p_id and session.d_id = doctor.d_id and patient.p_id = pid and doctor.d_f_name like dname;
END$$
DELIMITER ;

call DisplaySessionOfPatientWithDoctor(321565435, "rachel");

### 3 - for a given doctor id and day, display the schedule of that doctor
DELIMITER $$
CREATE PROCEDURE DisplayDoctorScheduleOfDay( in did INT, scday CHAR(25))
BEGIN
	select * from doctor, schedules
	where doctor.d_id = schedules.d_id and doctor.d_id = did and schedules.sc_day like scday;
END$$
DELIMITER ;
call DisplayDoctorScheduleOfDay(341270666, "sunday");

### 4 - for a given patiend id display all of his diagnostics
DELIMITER $$
CREATE PROCEDURE DisplayDIagnosticsOfPatient( in pid INT)
BEGIN
	select * from patient, session, DOS, Diagnosis
	where
    patient.p_id = session.p_id and session.s_id = DOS.s_id and DOS.diag_id = diagnosis.diag_id and patient.p_id = pid;
END$$
DELIMITER ;

call DisplayDIagnosticsOfPatient(321561231);

### 5 - for a given patient id show all sessions that had more than 1 line in the prescription
DELIMITER $$
CREATE PROCEDURE DisplayPrescriptionWIthMoreThanOneLine( in pid INT)
BEGIN
	select *
from
	patient,
	session,
    (select prescription.s_id, prescription.prsc_id, count(lip.prsc_id) as lip_count
	from prescription, Lines_In_Prescription as lip
    where
    prescription.prsc_id = lip.prsc_id
    group by lip.prsc_id) as TMP
    
    where
		patient.p_id = session.p_id and session.s_id = TMP.s_id and TMP.lip_count > 1 and patient.p_id = pid;
END$$
DELIMITER ;

call DisplayPrescriptionWIthMoreThanOneLine(213562145);

### 6 - for a given patient id show all sessions that had more than 1 diagnosis
DELIMITER $$
CREATE PROCEDURE DisplaySessionsOfPatientWithMoreThanOneDiagnostic( in pid INT)
BEGIN
	select * from 
patient,
session,
(select DOS.s_id, count(DOS.s_id) as count from patient, session, DOS where patient.p_id = session.p_id and session.s_id = DOS.s_id group by DOS.s_id) as TMP
where patient.p_id = session.p_id and session.s_id = TMP.s_id and TMP.count > 1 and patient.p_id = pid;
END$$
DELIMITER ;

call DisplaySessionsOfPatientWithMoreThanOneDiagnostic(321561231);

### 7 - for a given patient id display all doctors info that had a session with that patient
DELIMITER $$
CREATE PROCEDURE DisplayDoctorInfoThatHadSessionWithPatient( in pid INT)
BEGIN
	select distinct *
	from
		doctor,
        (select session.d_id
	from patient, session
    where
		patient.p_id = session.p_id and patient.p_id = pid) as TMP
	
    where
		doctor.d_id = TMP.d_id;
END$$
DELIMITER ;

call DisplayDoctorInfoThatHadSessionWithPatient(213562145);

### 8 - for a given patient id show all sessions that had an analysis
DELIMITER $$
CREATE PROCEDURE DisplayAnlysisOfPatient( in pid INT)
BEGIN
	select * 
    from Analysis, Session, Patient 
    where
    Analysis.s_id = Session.s_id and Patient.p_id = Session.p_id and Patient.p_id = pid;
END$$
DELIMITER ;

call DisplayAnlysisOfPatient(321561234);

### 9 - for a given patient id count the number of sessions
DELIMITER $$
CREATE PROCEDURE ShowNumberOfSessionForAPatient( in pid INT)
BEGIN
	select *, count(session.p_id) as number_of_sessions from session where session.p_id = pid group by session.p_id;
END$$
DELIMITER ;

call ShowNumberOfSessionForAPatient(213562145);

### 10 - for a given patient id display the rooms he had sessions in
DELIMITER $$
CREATE PROCEDURE ShowRoomsThatPatientVisited( in pid INT)
BEGIN
	select room.* from session, room where session.p_id = pid and session.r_num = room.r_num;
END$$
DELIMITER ;

call ShowRoomsThatPatientVisited(213562145);


########## Doctor Queries

### 1 - for a given doctor id show all the prescriptions he wrote
DELIMITER $$
CREATE PROCEDURE DisplayPrescriptionsWrittenByDoctor( in did INT)
BEGIN
	select * from session, prescription where session.s_id = prescription.s_id and session.d_id = did;
END$$
DELIMITER ;

call DisplayPrescriptionsWrittenByDoctor(341270222);

### 2 - for a given doctor id show all his patients
DELIMITER $$
CREATE PROCEDURE ShowPatientsOfDoctor( in did INT)
BEGIN
	select patient.* from patient, session where patient.p_id = session.p_id and session.d_id = did;
END$$
DELIMITER ;

call ShowPatientsOfDoctor(341270222);

### 3 - for a given doctor id display his manager info
DELIMITER $$
CREATE PROCEDURE DisplayManagerOfDoctor( in did INT)
BEGIN
	select *
	from
		doctor,
        (select doctor.manager_id from doctor where doctor.d_id = did) as TMP
	where
    doctor.d_id = TMP.manager_id;
END$$
DELIMITER ;

call DisplayManagerOfDoctor(341270222);

### 4 - for a given doctor id show all sessions that had more than 1 line in prescription
DELIMITER $$
CREATE PROCEDURE ShowPrescriptionsWithMoreThanOneLineWrittenByDoctor( in did INT)
BEGIN
	select *
from 
	session,
    (select prescription.prsc_id, prescription.s_id, count(prescription.prsc_id) as lip_count
	from prescription, Lines_In_Prescription as lip
	where
		prescription.prsc_id = lip.prsc_id
	group by prescription.prsc_id) as TMP

where session.d_id = 341270222 and session.s_id = TMP.s_id and TMP.lip_count > 1;
END$$
DELIMITER ;

call ShowPrescriptionsWithMoreThanOneLineWrittenByDoctor(341270222);

### 5 - for a given doctor id count the number of session he had
DELIMITER $$
CREATE PROCEDURE ShowNumberOfsessionOfDoctor( in did INT)
BEGIN
	select TMP.d_id, TMP.session_count
	from (select *, count(session.d_id) as session_count from session group by session.d_id) as TMP
	where TMP.d_id = did;
END$$
DELIMITER ;

call ShowNumberOfsessionOfDoctor(341270222);

### 6 - for a given doctor id display the medicines he prescibed
DELIMITER $$
CREATE PROCEDURE ShowMedicinesDoctorPrescribed( in did INT)
BEGIN
	select medicine.*
	from medicine
	inner join 
	(select prescription.s_id, prescription.prsc_id, lip.m_id
	from session, prescription, Lines_In_Prescription as lip
	where session.s_id = prescription.s_id and prescription.prsc_id = lip.prsc_id and session.d_id = did) as TMP
	ON TMP.m_id = medicine.m_id;
END$$
DELIMITER ;

call ShowMedicinesDoctorPrescribed(341270222);

### 7 - for a given doctor id display the number of prescription he wrote
DELIMITER $$
CREATE PROCEDURE SHowNumberOfPrescriptionsWrittenByDoctor( in did INT)
BEGIN
	select count(session.d_id) as num_of_prsc_written from session, prescription where session.s_id = prescription.s_id and session.d_id = did group by session.d_id;
END$$
DELIMITER ;

call SHowNumberOfPrescriptionsWrittenByDoctor(341270222);

### 8 - for a given doctor id show the number of diagnostics he gave
DELIMITER $$
CREATE PROCEDURE ShowNumOfDiagnosisByDoctor( in did INT)
BEGIN
	select count(session.d_id) as NUM_OF_DIAG_BY_DOCTOR from Session, DOS where Session.s_id = DOS.s_id and session.d_id = did group by session.d_id;
END$$
DELIMITER ;

call ShowNumOfDiagnosisByDoctor(341270111);
### 9 - for a given doctor id show the session that had a diagnosis of diabetes 
DELIMITER $$
CREATE PROCEDURE ShowSessionofDoctorWithDiabetes( in did INT)
BEGIN
	select session.*, diagnosis.diag_name as Diagnosis from diagnosis, DOS, Session
where diagnosis.diag_id = DOS.diag_id and DOS.s_id = session.s_id and diagnosis.diag_name like "diabetes" and session.d_id = did;
END$$
DELIMITER ;

call ShowSessionofDoctorWithDiabetes(341270222);

### 10 - for a given doctor id display his schedule
DELIMITER $$
CREATE PROCEDURE DisplayDoctorSchedules( in did INT)
BEGIN
	select * from schedules as sc where sc.d_id = did;
END$$
DELIMITER ;

call DisplayDoctorSchedules(341270111);

########## Manager Queries

### 1 - display the doctor that diagnosed the youngest patient with diabetes

select doctor.*
from
	Session,
    DOS,
    doctor,
    (select TMP2.p_id
	from
		(select min(patient.p_age) as p_age from DOS, Session, patient where DOS.s_id = Session.s_id and Session.p_id = patient.p_id and DOS.diag_id = 104) as TMP1,
		(select patient.* from DOS, Session, patient where DOS.s_id = Session.s_id and Session.p_id = patient.p_id and DOS.diag_id = 104) as TMP2
	where
		TMP2.p_age = TMP1.p_age) as TMP1
where
	Session.p_id = TMP1.p_id and Session.s_id = DOS.s_id and DOS.diag_id = 104 and doctor.d_id = Session.d_id;
    
### 2 - Display all male Patient that older then 45 , sorted by dec age
select pa.*
	from Patient as pa
	where pa.p_gender = 0
	and pa.p_age >= 45
    order by p_age asc;

### 3 - Display all female doctor in age btween 35 and 59 that , sorted by asc age
select doc.*
	from Doctor as doc
    where doc.d_gender = 1
    and
    d_dob BETWEEN '1963-12-25' AND '1987-12-31'
	order by d_age asc;
### 4 - Display all doctor with more then 10 years of expirnce sorted by years of exp desc
select doc.d_f_name,doc.d_l_name,doc.d_years_of_exp
	from Doctor as doc
    where
    d_years_of_exp >9
	order by d_years_of_exp desc;
    
### 5 - Display all the doctors aspsific last name
DELIMITER $$
CREATE PROCEDURE GetAllDoctorWithThisLastName( in last_name varchar(255))
BEGIN
	SELECT d_f_name,d_l_name FROM Clinic_2022.doctor
    where d_l_name=last_name;
END$$
DELIMITER ;

call GetAllDoctorWithThisLastName('Geller');

### 6 - Display all Prescription(includeign lines) worte by a aspsific doctor
DELIMITER $$
CREATE PROCEDURE GetPrcPerDoc5( in last_name varchar(255))
BEGIN
select line.prsc_id,Medicine.m_name,line.lip_amount from 
	Lines_In_Prescription as line,
(select pre.prsc_id  from
	Prescription as pre,
	Session as si,
	Doctor as doc
    where
    doc.d_id  = si.d_id
    and pre.s_id = si.s_id
    and doc.d_l_name =last_name) as tmp,Medicine
    where
        tmp.prsc_id = line.prsc_id and
        line.m_id =Medicine.m_id;
END$$
DELIMITER ;

### 7 - Display all Prescription that been given in a spasific day
DELIMITER $$
CREATE PROCEDURE GetPrscInDate1( in in_date1 varchar(255))
BEGIN
select line.prsc_id,Medicine.m_name,line.lip_amount as amount  from 
	Lines_In_Prescription as line,
(select pre.prsc_id  from
	Prescription as pre,
	Session as si,
	Patient  as pai
    where
    pai.p_id  = si.p_id
    and pre.s_id = si.s_id
    and si.s_date = in_date1) as tmp,Medicine
    where
        tmp.prsc_id = line.prsc_id and
        line.m_id =Medicine.m_id;
END$$
DELIMITER ;

call GetPrscInDate1("2022-1-4");

### 8 - Display Doctor information who wrote the maximum diagnostics
select *
from
	doctor,
    
    (select TMP1.d_id, TMP1.diag_count
	from
		(select Session.d_id, count(Session.d_id) as diag_count from Session, DOS where Session.s_id = DOS.s_id group by Session.d_id) as TMP1,
		(select max(TMP1.diagnostic_count) as max_diag_count from (select count(Session.d_id) as diagnostic_count from Session, DOS where Session.s_id = DOS.s_id group by Session.d_id) as TMP1) as TMP2
	where
		TMP1.diag_count = TMP2.max_diag_count) as TMP
        
where doctor.d_id = TMP.d_id;        

### 9 - Display first name of all patients who had HGB > 16

select patient.p_f_name from patient, Session, analysis where analysis.s_id = session.s_id  and analysis.a_HGB > 16 and patient.p_id = Session.p_id;



### 10 - Display all Patient who ever hade asison in aspesific room
select patient.*
from
	patient,
    (select * from Session where Session.r_num = 3) as TMP
    where patient.p_id = TMP.p_id;


########## INSERT/UPDATE/DELETE with procedures ##########


DELIMITER $$
CREATE PROCEDURE AddPatientProcedure( in
	pid INT,
    pfname CHAR(25),
    plname CHAR(25),
    pgender BOOL,
    pDOB DATE,
    patientage FLOAT
    )
BEGIN
	insert into Patient values
	(pid, pfname, plname, pgender, pDOB,patientage);
END$$
DELIMITER ;

call AddPatientProcedure(316559837, "Rick", "Sanchez", 0, '1969-1-1', 52);
call AddPatientProcedure(316559838, "Morty", "Smith", 0, '2000-1-1', 22);


DELIMITER $$
CREATE PROCEDURE UpdatePatientFirstNameProcedure( in pid INT, pfname CHAR(25))
BEGIN
	UPDATE Patient
    SET Patient.p_f_name = pfname
    WHERE Patient.p_id = pid;
END$$
DELIMITER ;

call UpdatePatientFirstNameProcedure(316559837, "Rick1");
call UpdatePatientFirstNameProcedure(316559838, "Morty1");

DELIMITER $$
CREATE PROCEDURE DeletePatientProcedure( in pid INT)
BEGIN
	DELETE FROM Patient WHERE Patient.p_id = pid;
END$$
DELIMITER ;

call DeletePatientProcedure(316559837);
call DeletePatientProcedure(316559838);