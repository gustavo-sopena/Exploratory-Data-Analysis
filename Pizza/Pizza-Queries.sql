-- name: Pizza Queries
-- description: queries that explore the pizza orders and sales data
-- author: Gustavo Sopena
-- date started: Monday: January 23, 2023

-- In the following code, the tables orders, items, and addresses are joined together
-- We obtain the view that is used to construct the visuals in the dashboard

select o.order_id, i.item_price, o.quantity,
       i.item_category, i.item_name, o.created_at,
       a.delivery_address_1, a.delivery_address_2, a.delivery_city,
       a.delivery_zipcode, o.is_delivery 
from orders o
left join items i
    on o.item_id = i.item_id
left join addresses a
    on o.address_id = a.address_id

-- We want to be able to plot a histogram, boxplot, or table of the prices for each order
-- To do this, we setup the data so that we have a column of distinct orders associated with the total price for that order
-- total price = quantity x item price

with order_and_rprice (order_id, TotalRowPrice) as (
    select o.order_id, o.quantity * i.item_price as TotalRowPrice
    from orders o
    left join items i
        on o.item_id = i.item_id
)
select sum(TotalRowPrice) as TotalOrderPrice
from order_and_rprice
group by order_id

-- by running the above code, we obtain
-- |TotalOrderPrice|
-- |---------------|
-- |13.25|
-- |92.00|
-- |37.25|
-- |16.50|
-- |16.50|

-- How about we find out what day the pizzeria is busiest?
-- I think the pizzeria is "busy" if the amount of pizzas made per day or the amount of orders made per day exceeds a certain threshold
-- e.g.,
-- | date     | pizzasMadePerDay | ordersMadePerDay |
-- | 03/14/23 | 333              | 33               |
-- | 03/15/23 |  13              | 5                |

select date(created_at) as mdy, sum(quantity) as pizzasMadePerDay, count(distinct(order_id)) as ordersMadePerDay
from orders
group by mdy
-- order by ordersMadePerDay desc

-- To answer which pizzas are the best and worst selling, we want to see to total sales for each pizza

-- with itemPrice as (
--     select o.created_at, o.item_id, i.item_price
--     from orders o
--     left join items i
--         on o.item_id = i.item_id
-- )
-- select item_id, sum(item_price)
-- from itemPrice
-- group by item_id
-- order by 2 desc

-- Initially, I selected the item ID and summed up the price
-- However, this means that items with different sizes, such as "bbq_ckn_s" and "bbq_ckn_m" are different items
-- Of course, that is not necessarily true
-- Let us adjust the code to group by the item name and not ID
-- Also, remember to include the quantities of the items for each order

with itemPrice (crated_at, item_name, TotalRowPrice) as (
    select o.created_at, i.item_name, o.quantity * i.item_price as TotalRowPrice
    from orders o
    left join items i
        on o.item_id = i.item_id
)
select item_name, sum(TotalRowPrice) as TotalOrderPrice
from itemPrice
group by item_name
order by TotalOrderPrice desc

-- from the output, we see that the highest selling pizza is the "thai_ckn"
-- similarly, we see that the lowest selling pizza is the "brie_carre"

-- Finally, let us obtain the average order value
-- Using the column "TotalRowPrice" created before we can take the average of that column to obtain the result
