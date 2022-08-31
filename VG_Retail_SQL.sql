/*Please write a query that selects the top 5 Video Game Publishers that have
had the most sales globally and the subsequent breakdown across North
America, Europe, and Japan.*/

select publisher,
sum(global_sales) as Total_Sales,
sum(na_sales) as North_America_Sales,
sum(eu_sales) as Europe_Sales,
sum(jp_sales) as Japan_Sales
from VG_Retail_Sales
group by publisher
order by Total_Sales DESC
limit 5;

/*Upon successful completion of this, please count the number of video games
produced by each of these top 5 publishers.*/

SELECT publisher,
count (*) as Total_Number_Video_Games
from VG_Retail_Sales
WHERE publisher in ('Nintendo', 'Activision', 'Electronic Arts', 'Sony Computer Entertainment', 'Take-Two Interactive')
group by publisher
order by Total_Number_Video_Games Desc;

/*Please write a query to identify the top 5 platforms for video games sales as
well as the number of video games available for each platform globally. Order this in descending order.*/


select platform,
Sum(global_sales) as Total_Sales,
count (*) as Total_Record_Count
from VG_Retail_Sales
group by platform
order by Total_Record_Count DESC
limit 5;

/*Segmenting the data further, please identify the top-selling video game for
each of the top 5 platforms globally.*/

WITH CTE1 AS(
  select platform, name,
	Max(global_sales) as Maximum_Sales
	FROM VG_Retail_Sales
	group by platform
	order by Maximum_Sales desc)

Select * from CTE1
limit 5;

/*Please write a query to calculate both the total number of games per genre, as
well as the total global sales per genre.*/

select genre,
sum(global_sales) as Total_Sales,
count (*) as Total_Number_Games
from VG_Retail_Sales
group by genre
Order by Total_Sales Desc;

/*Re-using the query you’ve written previously, identify the top selling genre for
each market – are there any differences between the markets?*/

with North_America_View as (
  SELECT genre,
  sum(global_sales),
  sum(na_sales) as North_America_Sales
  from VG_Retail_Sales
  group by genre
  order by North_America_Sales DESC
	limit 1),
    
  EU_VIEW AS(
  SELECT genre,
  sum(global_sales),
  sum(eu_sales) as EU_Sales
  from VG_Retail_Sales
  group by genre
  order by EU_Sales DESC
	limit 1),
 
  Japan_View as(
  SELECT genre,
  sum(global_sales),
  sum(jp_sales) as Japan_Sales
  from VG_Retail_Sales
  group by genre
  order by Japan_Sales DESC
	limit 1)

Select *
from Japan_View, EU_VIEW, North_America_View;

/*Please write a query to calculate the percentage of sales each genre
contributes to the overall total (global sales). Order this in descending order.*/

Select *,
Round((Total_Sales_Per_Genre / Total_Sales_Overall)*100,2) as Percentage_Total
from (
select genre,
sum(global_sales) as Total_Sales_Per_Genre,
(Select sum(global_sales) from VG_Retail_Sales) as Total_Sales_Overall
from VG_Retail_Sales
group by genre
order by Total_Sales_Per_Genre desc);

/*Having reviewed the overall proportion of sales each genre contributed to the overall
total, it’s clear that there are some very niche genre categories, and subsequently,
very niche video games. You’ve decided that you’re going to categorise each video
game into three categories:
Low Sales – Between $0 – $2M
Medium Sales – Between $2 to 5M
High Sales – Greater than $5M Sales

Please write a query that classifies each video game as either being Low
Sales, Medium Sales or High Sales using the classification criteria that has
been provided above and the global sales column.*/

Select Name, publisher, genre, global_sales,
Case
	When global_sales <= 2 then 'Low Sales'
    when global_sales <= 5 then 'Medium Sales'
    else 'High Sales'
    end as Classification_Criteria
From VG_Retail_Sales;

/*Please write a query that counts the number of video games that fit into
either the Low Sales, Medium Sales or High Sales Categories*/

with Sales_Classification as(
  Select Name, publisher, genre, global_sales,
Case
	When global_sales <= 2 then 'Low Sales'
    when global_sales <= 5 then 'Medium Sales'
    else 'High Sales'
    end as Classification_Criteria
From VG_Retail_Sales)

select Classification_Criteria,
count(Classification_Criteria) as Class_Count
from Sales_Classification
group by Classification_Criteria
order by Class_Count Desc;

/*Lastly, using the classification criteria you’ve defined above (i.e. Low,
Medium, High), please write a query that identifies the top 3 most popular
video games for each of the classification criteria.*/

with Sales_Classification as(
 	Select Name, publisher, genre, global_sales, na_sales, eu_sales, jp_sales,
Case
	When global_sales <= 2 then 'Low Sales'
   when global_sales <= 5 then 'Medium Sales'
   else 'High Sales'
    end as Classification_Criteria
From VG_Retail_Sales),

Rankings as (
	select *,
	row_number() over (partition by classification_criteria order by global_sales desc) as Sales_Rank 
/*Decided to use row_number instead of rank or dense_rank to avoid duplicate ranks (multiple 1s for example) since many of the games had the same global sales number. Adding more decimal points to global_sales or presenting global_sales as the whole number instead of in millions would have made the ranking as accurate as possible.*/
	from Sales_Classification)

select *
from rankings
where sales_rank<=3;
