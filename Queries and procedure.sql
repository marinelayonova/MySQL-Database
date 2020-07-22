-----Select all pediatricians----

use patients;

select doctors.name as DoctorsName, doctors.specialization, doctors.room, doctors.phone
from doctors
where specialization='pediatrician';



-----Select all doctors who share one room-----

use patients;

select doctors.room, count(doctors.id) numberOfDoctorsInOneRoom
from doctors
group by room;


------Select patients with their diagnoses and treatment-------
use patients;

select patients.name as Patient, diagnoses.name as Diagnose, treatments.treatment
from patients join diagnoses join treatments
on patients.id in(
	select patient_id
    from patients_diagnoses
    where patients_diagnoses.diagnose_id=diagnoses.id)
where diagnoses.id in(
	select diagnose_id
    from diagnoses_treatments
    where diagnoses_treatments.treatment_id=treatments.id)
order by Patient;

------Select doctors with their working hours and rooms--------

use patients;

select doctors.name, doctors.room, rooms_doctors.dayOfWeek, rooms_doctors.hoursOfDoctors
from doctors left join rooms_doctors
on doctor_room in(
		select doctor_room
        from rooms_doctors
        where rooms_doctors.doctor_room=doctors.id);
		
		
		
		
----------Select the diagnoses and count the days of healing for each--------		

use patients;

select sum(datediff(patients_healing.endOfHealing, patients_healing.startOfHealing)) as HealingDays,
diagnoses.name as Diagnose
from patients_healing join diagnoses join patients
on diagnoses.id in(
	select diagnose_id
    from patients_diagnoses
    where patients_diagnoses.diagnose_id=diagnoses.id
    and patients_diagnoses.patient_id=patients.id)
where patient_id in(
	select patient_id
    from patients_healing
    where patients_healing.patient_id=patients.id)
group by diagnoses.id
order by Diagnose;
		
		
----------Call a procedure with a cursor which finds the patients with 'Gastritis'-----------
use patients;

drop procedure if exists DiagnosesProcedure;
delimiter *
create procedure DiagnosesProcedure()
begin
declare finished int;
declare tempDiagnose varchar(50);
declare tempPatient varchar (100);
declare PatientDiagnose CURSOR for
SELECT patients.name, diagnoses.name
from patients join diagnoses
on patients.id in(
	select patient_id
    from patients_diagnoses
    where patients_diagnoses.diagnose_id=diagnoses.id)
where diagnoses.id in(
	select id
    from diagnoses
    where name='Gastritis');
declare continue handler FOR NOT FOUND set finished = 1;
set finished=0;
OPEN PatientDiagnose;
diagnose_loop: while(finished=0)
DO
FETCH PatientDiagnose INTO  tempPatient, tempDiagnose;
	IF(finished=1)
    THEN
    LEAVE diagnose_loop;
    END IF;
    SELECT tempDiagnose, tempPatient;
end while;
CLOSE PatientDiagnose;
SET finished=0;
SELECT 'Finished!';

end;
*
delimiter *


call DiagnosesProcedure();