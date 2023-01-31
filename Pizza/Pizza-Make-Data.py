# name: Pizza Make Data
# description: cleaning the data sets and creating new data sets
# author: Gustavo Sopena
# date started: Monday: January 23, 2023

import argparse
import pandas as pd
import numpy as np

# =========================
# setup
# =========================

# set the seed for the random number generator
np.random.seed(0)

# create the parser
parser = argparse.ArgumentParser(description="cleaning the data sets and creating new data sets")

# add the arguments
parser.add_argument("-s", "--section", help="choose the section to run", type=int, required=True)

# parse the arguments
args = parser.parse_args()

# =========================
# create the orders data set
# =========================

if args.section == 1:
    # load the data sets
    orders = pd.read_csv("orders.csv")
    order_details = pd.read_csv("order_details.csv")
    pizzas = pd.read_csv("pizzas.csv")

    # combine the data sets
    orders_and_details = pd.merge(orders, order_details)

    # make a column called "row_id"
    orders_and_details["row_id"] = np.arange(1, orders_and_details.shape[0]+1)

    # merge the columns "date" and "time" into a new column called "created_at"
    orders_and_details["created_at"] = orders_and_details["date"] + " " + orders_and_details["time"]

    # make a list of the unique order id values
    unique_order_ids = orders_and_details["order_id"].unique()

    # make a list of random values for each unique order id
    customer_id_list = np.random.randint(1, 515, len(unique_order_ids))

    # make a dictionary of the order id values and the customer ids
    customer_id_dict = dict(zip(unique_order_ids, customer_id_list))

    # map the dictionary to the "order_id" column to create a new column called "customer_id"
    orders_and_details["customer_id"] = orders_and_details["order_id"].map(customer_id_dict)
    orders_and_details["address_id"] = orders_and_details["order_id"].map(customer_id_dict)
    
    # make a list of 0s and 1s for each unique order id
    is_delivery_list = np.random.randint(0, 2, len(unique_order_ids))

    # make a dictionary of the order id values and the 0s and 1s
    is_delivery_dict = dict(zip(unique_order_ids, is_delivery_list))

    # map the dictionary to the "order_id" column to create a new column called "is_delivery"
    orders_and_details["is_delivery"] = orders_and_details["order_id"].map(is_delivery_dict)

    # look up the pizza id from the orders_and_details data set in the pizzas data set and get the index of the pizza id
    # use the id list to make a new column called "item_id"
    orders_and_details["item_id"] = ""
    for i in range(0, orders_and_details.shape[0]):
        # this is the id of the pizza as a string
        pid = orders_and_details["pizza_id"][i]
        pidx = pizzas[pizzas["pizza_id"] == pid].index[0]
        orders_and_details["item_id"][i] = "it_" + str(pidx+1)

    # drop columns
    orders_and_details = orders_and_details.drop(columns=["date", "time", "pizza_id", "order_details_id"])

    # rename the column (if not dropped)
    # orders_and_details = orders_and_details.rename(columns={"order_details_id": "item_details_id"})

    # reorder the columns
    orders_and_details = orders_and_details[["row_id", "order_id", "created_at", "item_id", "quantity", "customer_id", "is_delivery", "address_id"]]

    # save the new data set to a csv file called "updated_orders.csv"
    orders_and_details.to_csv("updated_orders.csv", index=False)

# =========================
# create the items data set
# =========================

if args.section == 2:
    # load the data sets
    pizzas = pd.read_csv("pizzas.csv")

    # rename columns
    pizzas = pizzas.rename(columns={"pizza_id": "sku", "size" : "item_size", "price" : "item_price", "pizza_type_id" : "item_name"})

    # add a new column called "item_category" to pizzas
    pizzas["item_category"] = "pizza"

    # add a new column called "item_id" to pizzas labeled "it_" and the row index plus 1
    pizzas["item_id"] = ""
    for i in range(0, pizzas.shape[0]):
        pizzas["item_id"][i] = "it_" + str(i+1)

    # reorder the columns as follows: item_id, sku, item_name_details_id, item_category, item_size, item_price
    pizzas = pizzas[["item_id", "sku", "item_name_id", "item_category", "item_size", "item_price"]]

    # save the new data set to a csv file called "updated_items.csv"
    pizzas.to_csv("updated_items.csv", index=False)
