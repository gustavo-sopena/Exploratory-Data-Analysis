-- name: Pizza Drop Tables
-- description: clean up script
-- author: Gustavo Sopena
-- date started: Monday: January 23, 2023

-- drop the foreign keys

ALTER TABLE `orders`
DROP FOREIGN KEY `fk_customers_customer_id`;

ALTER TABLE `orders`
DROP FOREIGN KEY `fk_addresses_address_id`;

ALTER TABLE `orders`
DROP FOREIGN KEY `fk_items_item_id`;

-- drop the tables

DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `items`;
DROP TABLE IF EXISTS `customers`;
