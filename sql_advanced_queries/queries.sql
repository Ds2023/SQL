--Using JOIN to get the student names, school id, email, phone number--

select personal_details.phone_number,personal_details.stud_name,
personal_details.stud_ID,school_details.stud_email
from personal_details
inner join school_details
on personal_details.stud_ID = school_details.stud_ID;

--Creating a table with all the details from contacts to school and financial details--

select * from personal_details
inner join financial_details
on personal_details.stud_ID = financial_details.stud_ID
inner join school_details
on personal_details.stud_ID = school_details.stud_ID
inner join contact_details
on school_details.stud_email = contact_details.stud_email;

--Adding student names on any empty row of stud_name in financial_details--

update financial_details
SET stud_name = (select personal_details.stud_name
from personal_details
where personal_details.stud_ID = financial_details.stud_ID);

--On the financial_details table add a column, fee_cleared, that has True if student has cleared current fee and False if not--

ALTER TABLE financial_details ADD fee_cleared varchar(20);
update financial_details
set fee_cleared = 'TRUE'
where financial_details.sem_fee = financial_details.fee_paid;
update financial_details
set fee_cleared = 'FALSE'
where financial_details.sem_fee <> financial_details.fee_paid;

--Getting the national ID and name of all students who have cleared their fees--

select personal_details.national_ID, financial_details.stud_name
from personal_details
join financial_details
on personal_details.stud_name = financial_details.stud_name
where financial_details.fee_cleared = 'TRUE';

--Getting the total sum of fees paid so far and the total current deficit--

select sum(sem_fee) as 'Total_Sem_Fees', 
sum(fee_paid) as 'Total_Fees_Paid',
sum(sem_fee)  - sum(fee_paid) as 'Fee_deficit'
from financial_details;

--Getting the count of students who share a current home county i.e., 
--Say Nairobi, get the number of students who’s current_home_county is Nairobi, and so on for all available counties--

select count (stud_ID) as 'No. of students',
school_details.current_home_county
from school_details
group by school_details.current_home_county;

--Getting the count of Male and/or Female students from each secondary_school_county--

select school_details.secondary_school_county,
personal_details.gender,
count(personal_details.gender) as 'count'
from school_details
join personal_details
on school_details.stud_ID = personal_details.stud_ID
group by school_details.secondary_school_county,
personal_details.gender;

--Getting the percentage of students who set their next_of_kin as Mother vs those that set it as Father1--

select next_of_kin_relation,
count(contact_details.next_of_kin_relation) as 'Count',
format((count(next_of_kin_relation)/15 * 100),2) 
as 'percentage'
from contact_details
group by next_of_kin_relation
union
select '',count(next_of_kin_relation),''
from contact_details;
