/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT * FROM `Facilities` WHERE membercost>0


/* Q2: How many facilities do not charge a fee to members? */

SELECT count(facid) FROM `Facilities` WHERE membercost=0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost,monthlymaintenance 
FROM `Facilities` 
WHERE membercost>0 AND membercost<.2*monthlymaintenance


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM `Facilities` WHERE facid IN ('1','5')

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance>100 THEN 'expensive'
ELSE 'cheap' END AS costlabel 
FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT * 
FROM Members
WHERE joindate 
IN 
(SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT b.memid,str(m.surname)+','+str(m.firstname) as FullName,b.facid,f.name as FacilityName
FROM `Bookings`  b
LEFT JOIN Members  m 
ON b.memid=m.memid
LEFT JOIN Facilities  f
ON b.facid=f.facid
WHERE b.facid IN ('0','1')
AND b.memid!=0
ORDER BY FullName

Yields error during runtime

SELECT DISTINCT b.memid,m.surname+','+m.firstname as FullName,b.facid,f.name as FacilityName
FROM `Bookings`  b
LEFT JOIN Members  m 
ON b.memid=m.memid
LEFT JOIN Facilities  f
ON b.facid=f.facid
WHERE b.facid IN ('0','1')
AND b.memid!=0
ORDER BY FullName

Yields 0s for FullName

SELECT DISTINCT b.memid,m.surname||','||m.firstname as FullName,b.facid,f.name as FacilityName
FROM `Bookings`  b
LEFT JOIN Members  m 
ON b.memid=m.memid
LEFT JOIN Facilities  f
ON b.facid=f.facid
WHERE b.facid IN ('0','1')
AND b.memid!=0
ORDER BY FullName

Yields 0s for FullName

SELECT DISTINCT b.memid,CONCAT(m.surname,',',m.firstname) as FullName,b.facid,f.name as FacilityName
FROM `Bookings`  b
LEFT JOIN Members  m 
ON b.memid=m.memid
LEFT JOIN Facilities  f
ON b.facid=f.facid
WHERE b.facid IN ('0','1')
AND b.memid!=0
ORDER BY FullName

yields error during runtime


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT DATE(b.starttime) as date, b.bookid, b.facid, b.memid, b.slots, m.surname, m.firstname, f.name as facility_Name, 
CASE WHEN b.memid=0 THEN f.guestcost*slots
ELSE f.membercost*b.slots END as total_cost
FROM `Bookings` b
LEFT JOIN Members m
ON b.memid=m.memid
LEFT JOIN Facilities f
ON b.facid=f.facid
WHERE DATE(starttime)='2012-09-14'
ORDER BY total_cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT DATE(b.starttime) as date, b.bookid, b.facid, b.memid, b.slots, m.surname, m.firstname, f.name as facility_Name, 
CASE WHEN b.memid=0 THEN f.guestcost*slots
ELSE f.membercost*b.slots END as total_cost
FROM 
(SELECT * FROM Bookings WHERE DATE(starttime)='2012-09-14') as b
LEFT JOIN Members m
ON b.memid=m.memid
LEFT JOIN Facilities f
ON b.facid=f.facid
ORDER BY total_cost DESC


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT b.facid,f.name as facility_name,
SUM((CASE WHEN b.memid=0 THEN f.guestcost
ELSE f.membercost END)*b.slots) as total_revenue
FROM Bookings b
LEFT JOIN Facilities f
ON b.facid=f.facid
GROUP BY facid
ORDER BY total_revenue DESC

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m.memid,m.surname,m.firstname,m.recommendedby,
r.memid as RecommendedCheck,r.surname as Recommender_Last_Name,r.firstname as Recommender_First_Name
FROM Members m 
INNER JOIN Members r
on m.recommendedby=r.memid
WHERE m.recommendedby IS NOT NULL AND m.recommendedby>1
ORDER BY m.surname, m.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.facid,f.name as facility_name,SUM(b.slots) as Total_Mem_Rentals
FROM Facilities f
LEFT JOIN Bookings b
ON f.facid=b.facid
WHERE b.memid!=0
GROUP BY f.facid

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.facid,f.name as facility_name,EXTRACT(YEAR FROM b.starttime) as Year, EXTRACT(MONTH FROM b.starttime) as Month, SUM(b.slots) as Total_Mem_Rentals_by_Month
FROM Facilities f
LEFT JOIN Bookings b
ON f.facid=b.facid
WHERE b.memid!=0
GROUP BY f.facid,Year,Month

