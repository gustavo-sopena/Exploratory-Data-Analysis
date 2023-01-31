-- name: Pizza Make Tables
-- description: this code creates tables and adds the foreign keys
-- author: Gustavo Sopena
-- date started: Monday: January 23, 2023

CREATE TABLE `orders` (
    `row_id` int  NOT NULL ,
    `order_id` varchar(10)  NOT NULL ,
    `created_at` datetime  NOT NULL ,
    `item_id` varchar(10)  NOT NULL ,
    `quantity` int  NOT NULL ,
    `customer_id` int  NOT NULL ,
    `is_delivery` boolean  NOT NULL ,
    `address_id` int  NOT NULL ,
    PRIMARY KEY (
        `row_id`
    )
);

CREATE TABLE `customers` (
    `customer_id` int  NOT NULL ,
    `customer_first_name` varchar(50)  NOT NULL ,
    `customer_last_name` varchar(50)  NOT NULL ,
    PRIMARY KEY (
        `customer_id`
    )
);

CREATE TABLE `addresses` (
    `address_id` int  NOT NULL ,
    `delivery_address_1` varchar(200)  NOT NULL ,
    `delivery_address_2` varchar(200)  NULL ,
    `delivery_city` varchar(50)  NOT NULL ,
    `delivery_zipcode` varchar(20)  NOT NULL ,
    PRIMARY KEY (
        `address_id`
    )
);

CREATE TABLE `items` (
    `item_id` varchar(10)  NOT NULL ,
    `sku` varchar(20)  NOT NULL ,
    `item_name` varchar(100)  NOT NULL ,
    `item_category` varchar(100)  NOT NULL ,
    `item_size` varchar(10)  NOT NULL ,
    `item_price` decimal(10,2)  NOT NULL ,
    PRIMARY KEY (
        `item_id`
    ),
    UNIQUE (
        `sku`
    )
);

ALTER TABLE `orders`
ADD CONSTRAINT `fk_customers_customer_id`
FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`);

ALTER TABLE `orders`
ADD CONSTRAINT `fk_addresses_address_id`
FOREIGN KEY (`address_id`) REFERENCES `addresses`(`address_id`);

ALTER TABLE `orders`
ADD CONSTRAINT `fk_items_item_id`
FOREIGN KEY (`item_id`) REFERENCES `items`(`item_id`);
