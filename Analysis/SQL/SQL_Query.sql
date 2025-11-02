select *
from railway
order by Date_of_Purchase asc;

---fill null values by 'no delay' 
update railway
set "Reason_for_Delay"='No delay'
where Reason_for_Delay is null;


---check null 
select  "Transaction_ID","Journey_Status"
from railway
where "Journey_Status"is null;


---check duplicates
select "Transaction_ID",COUNT(*) as Number_of_duplicates
from railway
group by "Transaction_ID"
having COUNT(*) > 1;


---add coloumn
Alter table railway
add Delay_time TIME,
 Day_of_Week VARCHAR(20),
  Journey_Duration TIME,
      Refund VARCHAR(20); 
	     
---update delay time 
update railway
SET Delay_time = DATEADD(SECOND, DATEDIFF(SECOND, Arrival_Time, Actual_Arrival_Time), 0);

---check delayed values with 0 delay time 
SELECT Journey_Status, Delay_Time 
FROM Railway
WHERE Journey_Status = 'Delayed'
  AND Delay_Time = '00:00:00';


---make every 0 delay time to be on time  journey status and no refund request 
UPDATE Railway
SET 
    Journey_Status = 'On Time',
    Refund_Request = 'No'
WHERE Delay_Time = '00:00:00';

---make every 0 delaye time be no delayed in reason for delay and refund request = no 
UPDATE Railway
SET 
    Reason_for_Delay = 'No Delay',
    Refund_Request = 'No'
WHERE Delay_Time = '00:00:00';


---check the changes
select Journey_Status,Refund_Request
from railway
where Journey_Status='On Time'
and Refund_Request='Yes'




--- rename coloumn 
EXEC sp_rename 'railway.Refund', 'Refund_Amount', 'COLUMN'; 


--- make refund amount = price if refund request = yes 
UPDATE railway
SET Refund_Amount = 
    CASE 
        WHEN Refund_Request = 'yes' THEN Price
        ELSE 0
    END


--- update journey_duration 
update railway
SET Journey_duration  = DATEADD(SECOND, DATEDIFF(SECOND, Departure_Time, Arrival_Time), 0);

--- update Day_of_Week
UPDATE railway
SET Day_of_Week = datename(WEEKDAY,Date_of_Journey);


--- add discount coloumn 
ALTER TABLE Railway
ADD Discount DECIMAL(5,2);

---update discount 
UPDATE Railway
SET Discount =
    CASE
        WHEN Railcard IN ('Adult', 'Senior', 'Disabled') THEN
            CASE Ticket_Type
                WHEN 'Advance' THEN ROUND((1 - ((1 - 1.0/3) * (1 - 0.5))) * 100, 2)
                WHEN 'Off-Peak' THEN ROUND((1 - ((1 - 1.0/3) * (1 - 0.25))) * 100, 2)
                WHEN 'Anytime'  THEN ROUND((1.0/3) * 100, 2)
                ELSE 0
            END
        ELSE
            CASE Ticket_Type
                WHEN 'Advance' THEN 50
                WHEN 'Off-Peak' THEN 25
                WHEN 'Anytime'  THEN 0
                ELSE 0
            END
    END;

	---change discount data type 
ALTER TABLE Railway
ALTER COLUMN Discount VARCHAR(10);

--- add % to discount number 
UPDATE Railway
SET Discount = CAST(Discount AS VARCHAR(10)) + '%';


---add routes coloumn 
ALTER TABLE railway
ADD Routes VARCHAR(255);


---update routes coloumn 
UPDATE railway
SET Routes = Departure_Station + ' to ' + Arrival_Destination;


---change data type 
alter table railway
alter COLUMN  Departure_Time TIME(0);

alter table railway
alter COLUMN  Arrival_Time TIME(0);

alter table railway
alter COLUMN  Actual_Arrival_Time TIME(0);

alter table railway
alter COLUMN  Time_of_Purchase TIME(0);


---add Revenue_per_Ticket coloumn
ALTER TABLE railway
ADD Revenue_per_Ticket DECIMAL(10,2);

UPDATE railway
SET Revenue_per_Ticket = 
    IIF(Refund_Request = 'No', Price, 0);

	
CREATE TABLE Tickets (
    Ticket_ID INT PRIMARY KEY,
    Ticket_Type VARCHAR(50),
    Ticket_Class VARCHAR(50),
    Railcard VARCHAR(50),
    Discount DECIMAL(5, 3),
    Ticket VARCHAR(255)
);


INSERT INTO Tickets (Ticket_ID, Ticket_Type, Ticket_Class, Railcard, Discount, Ticket) VALUES
(1, 'Advance', 'Standard', 'None', 50.0, 'Advance | Standard | None'),
(2, 'Advance', 'Standard', 'Senior', 66.5, 'Advance | Standard | Senior'),
(3, 'Advance', 'Standard', 'Adult', 66.5, 'Advance | Standard | Adult'),
(4, 'Advance', 'Standard', 'Disabled', 66.5, 'Advance | Standard | Disabled'),
(5, 'Advance', 'First Class', 'None', 50.0, 'Advance | First Class | None'),
(6, 'Advance', 'First Class', 'Senior', 66.5, 'Advance | First Class | Senior'),
(7, 'Advance', 'First Class', 'Adult', 66.5, 'Advance | First Class | Adult'),
(8, 'Advance', 'First Class', 'Disabled', 66.5, 'Advance | First Class | Disabled'),
(9, 'Anytime', 'Standard', 'None', 0.0, 'Anytime | Standard | None'),
(10, 'Anytime', 'Standard', 'Senior', 33.0, 'Anytime | Standard | Senior'),
(11, 'Anytime', 'Standard', 'Adult', 33.0, 'Anytime | Standard | Adult'),
(12, 'Anytime', 'Standard', 'Disabled', 33.0, 'Anytime | Standard | Disabled'),
(13, 'Anytime', 'First Class', 'None', 0.0, 'Anytime | First Class | None'),
(14, 'Anytime', 'First Class', 'Senior', 33.0, 'Anytime | First Class | Senior'),
(15, 'Anytime', 'First Class', 'Adult', 33.0, 'Anytime | First Class | Adult'),
(16, 'Anytime', 'First Class', 'Disabled', 33.0, 'Anytime | First Class | Disabled'),
(17, 'Off-Peak', 'Standard', 'None', 25.0, 'Off-Peak | Standard | None'),
(18, 'Off-Peak', 'Standard', 'Senior', 49.75, 'Off-Peak | Standard | Senior'),
(19, 'Off-Peak', 'Standard', 'Adult', 49.75, 'Off-Peak | Standard | Adult'),
(20, 'Off-Peak', 'Standard', 'Disabled', 49.75, 'Off-Peak | Standard | Disabled'),
(21, 'Off-Peak', 'First Class', 'None', 25.0, 'Off-Peak | First Class | None'),
(22, 'Off-Peak', 'First Class', 'Senior', 49.75, 'Off-Peak | First Class | Senior'),
(23, 'Off-Peak', 'First Class', 'Adult', 49.75, 'Off-Peak | First Class | Adult'),
(24, 'Off-Peak', 'First Class', 'Disabled', 49.75, 'Off-Peak | First Class | Disabled');


CREATE TABLE Delays (
    Delay_ID INT PRIMARY KEY,
    Reason_for_Delay VARCHAR(100),
    Category VARCHAR(50)
);



	INSERT INTO Delays (Delay_ID, Reason_for_Delay, Category) VALUES
(1, 'No Delay', 'None'),
(2, 'Signal Failure', 'Infrastructure'),
(3, 'Staff Shortage', 'Operational'),
(4, 'Staffing', 'Operational'),
(5, 'Technical Issue', 'Rolling Stock'),
(6, 'Traffic', 'Operational'),
(7, 'Weather', 'External Factors');


CREATE TABLE Stations (
    Station_ID INT PRIMARY KEY,
    Station_Name VARCHAR(100)
);


INSERT INTO Stations (Station_ID, Station_Name) VALUES
(1, 'Birmingham New Street'),
(2, 'Bristol Temple Meads'),
(3, 'Cardiff Central'),
(4, 'Coventry'),
(5, 'Crewe'),
(6, 'Didcot'),
(7, 'Doncaster'),
(8, 'Durham'),
(9, 'Edinburgh'),
(10, 'Edinburgh Waverley'),
(11, 'Edinburgh Waverley'), 
(12, 'Leicester'),
(13, 'Liverpool Lime Street'),
(14, 'London Euston'),
(15, 'London Kings Cross'),
(16, 'London Paddington'),
(17, 'London St Pancras'),
(18, 'London Waterloo'),
(19, 'Manchester Piccadilly'),
(20, 'Nottingham'),
(21, 'Nuneaton'),
(22, 'Oxford'),
(23, 'Peterborough'),
(24, 'Reading'),
(25, 'Sheffield'),
(26, 'Stafford'),
(27, 'Swindon'),
(28, 'Tamworth'),
(29, 'Wakefield'),
(30, 'Warrington'),
(31, 'Wolverhampton'),
(32, 'York');



CREATE TABLE Journeys (
    Journey_ID INT PRIMARY KEY,
    Routes VARCHAR(255),
    Date_of_Journey DATE,
    Day_of_Week VARCHAR(20),
    Departure_Time TIME,
    Arrival_Time TIME,
    Actual_Arrival_Time TIME,
    Journey_Duration TIME,
    Journey_Status VARCHAR(20),
    Delay_Time TIME,
    Reason_for_Delay VARCHAR(100),
    Delay_ID INT,
    Departure_Station VARCHAR(100),
    Arrival_destination VARCHAR(100),
    Dep_ID INT,
    Arr_ID INT,
    FOREIGN KEY (Delay_ID) REFERENCES Delays(Delay_ID),
    FOREIGN KEY (Dep_ID) REFERENCES Stations(Station_ID),
    FOREIGN KEY (Arr_ID) REFERENCES Stations(Station_ID)
);



INSERT INTO journeys (
    Journey_ID, Routes, Date_of_Journey, Day_of_Week, 
    Departure_Time, Arrival_Time, Actual_Arrival_Time,
    Journey_Duration, Journey_Status, Delay_Time, 
    Reason_for_Delay, Departure_Station, Arrival_Destination, Delay_ID
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY r.Date_of_Purchase ASC) AS Journey_ID, 
    r.Routes,
    r.Date_of_Journey,
    r.Day_of_Week,
    r.Departure_Time,
    r.Arrival_Time,
    r.Actual_Arrival_Time,
    r.Journey_Duration,
    r.Journey_Status,
    r.Delay_Time,
    r.Reason_for_Delay,
    r.Departure_Station,
    r.Arrival_Destination,
    d.Delay_ID
FROM railway AS r
LEFT JOIN delays AS d
    ON r.Reason_for_Delay = d.Reason_for_Delay;


UPDATE j
SET 
    j.Dep_ID = s1.Station_ID,
    j.Arr_ID = s2.Station_ID
FROM Journeys j
LEFT JOIN Stations s1 ON j.Departure_Station = s1.Station_Name
LEFT JOIN Stations s2 ON j.Arrival_Destination = s2.Station_Name;



ALTER TABLE Railway
ADD Journey_ID INT;

;WITH Numbered AS (
    SELECT 
         ROW_NUMBER() OVER (ORDER BY r.Date_of_Journey ASC) AS New_Journey_ID, 
         r.Transaction_ID
    FROM Railway AS r
)
UPDATE r
SET r.Journey_ID = n.New_Journey_ID
FROM Railway AS r
JOIN Numbered AS n 
    ON r.Transaction_ID = n.Transaction_ID;



CREATE TABLE Transactions (
    Transaction_ID nvarchar(50) PRIMARY KEY,
    Date_of_Purchase DATE,
    Time_of_Purchase TIME,
    Purchase_Type VARCHAR(50),
    Payment_Method VARCHAR(50),
    Price DECIMAL(10,2),
    Refund_Amount DECIMAL(10,2),
    Revenue_Per_Ticket DECIMAL(10,2),
    Refund_Request VARCHAR(10),
    Ticket_ID INT,
    Journey_ID INT,
    FOREIGN KEY (Ticket_ID) REFERENCES Tickets(Ticket_ID),
    FOREIGN KEY (Journey_ID) REFERENCES Journeys(Journey_ID)
);



INSERT INTO Transactions (
    Transaction_ID, Date_of_Purchase, Time_of_Purchase,
    Purchase_Type, Payment_Method, Price, Refund_Amount,
    Revenue_Per_Ticket, Refund_Request, Ticket_ID, Journey_ID
)
SELECT 
    r.Transaction_ID,
    r.Date_of_Purchase,
    r.Time_of_Purchase,
    r.Purchase_Type,
    r.Payment_Method,
    r.Price,
    r.Refund_Amount,
    r.Revenue_Per_Ticket,
    r.Refund_Request,
    t.Ticket_ID,
    r.Journey_ID
FROM Railway AS r
LEFT JOIN Tickets AS t
    ON r.Ticket_Type = t.Ticket_Type
    AND r.Ticket_Class = t.Ticket_Class
    AND r.Railcard = t.Railcard;


select * from Delays
select * from Stations
select * from Tickets
select * from Transactions
select *from Journeys

select *
from railway
order by Date_of_Purchase asc;










