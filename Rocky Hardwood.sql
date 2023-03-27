DROP TABLE if EXISTS #temp 

select 
o.order_id,
p.product_price_sqft_bf,
o.quantity,
p.product_cat,
p.product_name,
o.date_created,
o.client_id,
o.product_id,
c.business_name,
p.sku,
CONCAT(s.first_name, ' ', s.last_name) AS FullName,
c.state
INTO #TEMP FROM dbo.orders AS o 
LEFT JOIN dbo.products AS p on o.product_id=p.product_id
LEFT JOIN dbo.clients AS c on o.client_id=c.client_id
LEFT JOIN dbo.SalesReps AS s on o.rep_id=s.rep_id

select * from #temp

select top 20 order_id, sum(product_price_sqft_bf*quantity) as Revenue from #temp
Group by order_id 
order by Revenue desc

select top 20 product_name, sum(product_price_sqft_bf*quantity) as Revenue from #temp
Group by product_name 
order by Revenue desc

DROP TABLE if EXISTS #temp1 

SELECT product_name, product_cat, sku,
sum(product_price_sqft_bf*quantity) OVER (Partition BY sku) AS 'Rev by Sku', 
sum(product_price_sqft_bf*quantity) OVER (Partition BY product_cat) AS 'Rev By Cat'  

INTO #temp1 FROM #temp

SELECT distinct sku, product_name, product_cat, [rev by sku]
from #temp1
order by sku desc



select business_name, sum(product_price_sqft_bf*quantity) as Revenue from #temp
Group by business_name
order by Revenue desc

select Fullname, 
CASE WHEN Fullname = 'Ricky Mei' THEN sum(product_price_sqft_bf*quantity)*1.1
else sum(product_price_sqft_bf*quantity) END as Revenue from #temp
Group by fullname
order by Revenue desc

UPDATE dbo.SalesReps 
Set first_name='Ricky'
WHERE first_name='Ricky '









