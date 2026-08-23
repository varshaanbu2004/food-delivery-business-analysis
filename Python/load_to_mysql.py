import pandas as pd
import mysql.connector
import re
# -----------------------------
# 1. Load the final cleaned CSV
# -----------------------------
df = pd.read_csv(
    "food_delivery_analysis/food_delivery_cleaned.csv",
    encoding="utf-8-sig"
)

# Remove unwanted Excel-generated columns
df = df.loc[:, ~df.columns.str.startswith("Unnamed")]

# Remove the invalid final row identified during cleaning
df = df.drop(index=21321)

print("Rows after cleaning:", len(df))
print("Columns after cleaning:", len(df.columns))
print("CSV loaded successfully")

def count_items(order):
    if pd.isna(order):
        return 0

    quantities = re.findall(r'(\d+)\s*x', str(order))
    return sum(int(qty) for qty in quantities)

df["Item_Count"] = df["Items in order"].apply(count_items)
# 5. Convert date/time columns
df["OrderTime"] = pd.to_datetime(df["OrderTime"], errors="coerce")
df["OrderDate"] = pd.to_datetime(df["OrderDate"], errors="coerce")

# 6. Your other missing-value handling
df["Instructions"] = df["Instructions"].fillna("No Instructions")
df["Discount construct"] = df["Discount construct"].fillna("No Discount")
df["Review"] = df["Review"].fillna("No Review")
df["Cancellation / Rejection reason"] = df["Cancellation / Rejection reason"].fillna("Not Applicable")
df["Customer complaint tag"] = df["Customer complaint tag"].fillna("No Complaint")

df["Restaurant compensation (Cancellation)"] = (
    df["Restaurant compensation (Cancellation)"].fillna(0)
)

df["Restaurant penalty (Rejection)"] = (
    df["Restaurant penalty (Rejection)"].fillna(0)
)

# 7. SAVE ONLY AFTER ALL CLEANING
df.to_csv("food_delivery_final.csv", index=False)

print("Final dataset saved successfully!")
print("Rows:", len(df))
print("Columns:", len(df.columns))
print("Item_Count missing:", df["Item_Count"].isna().sum())

# -----------------------------
# 2. Connect to MySQL
# -----------------------------
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Varsha@24",
    database="food_delivery_analysis"
)

cursor = connection.cursor()

print("Connected to MySQL successfully!")

# -----------------------------
# 3. Create the table
# -----------------------------
create_table_query = """
CREATE TABLE IF NOT EXISTS food_delivery_orders (
    Restaurant_ID BIGINT,
    Restaurant_name VARCHAR(255),
    Subzone VARCHAR(255),
    City VARCHAR(100),
    Order_ID BIGINT,
    Order_Placed_At VARCHAR(100),
    OrderTime VARCHAR(50),
    OrderDate VARCHAR(50),
    Order_Status VARCHAR(100),
    Delivery VARCHAR(100),
    Distance VARCHAR(50),
    DistanceKM DECIMAL(10,2),
    Items_in_order TEXT,
    Item_Count INT,
    Instructions TEXT,
    Discount_construct TEXT,
    Bill_subtotal DECIMAL(12,2),
    Packaging_charges DECIMAL(12,2),
    Restaurant_discount_Promo DECIMAL(12,2),
    Restaurant_discount_Flat DECIMAL(12,2),
    Gold_discount DECIMAL(12,2),
    Brand_pack_discount DECIMAL(12,2),
    Total DECIMAL(12,2),
    Rating DECIMAL(3,1),
    Review TEXT,
    Cancellation_Rejection_reason TEXT,
    Restaurant_compensation_Cancellation DECIMAL(12,2),
    Restaurant_penalty_Rejection DECIMAL(12,2),
    KPT_duration_minutes DECIMAL(10,2),
    Rider_wait_time_minutes DECIMAL(10,2),
    Order_Ready_Marked VARCHAR(50),
    Customer_complaint_tag VARCHAR(255),
    Customer_ID VARCHAR(100)
)
"""

cursor.execute(create_table_query)

# Remove any previous incomplete import
cursor.execute("TRUNCATE TABLE food_delivery_orders")

print("Table ready for import!")

# -----------------------------
# 4. Prepare column names
# -----------------------------
df = df.rename(columns={
    "Restaurant ID": "Restaurant_ID",
    "Restaurant name": "Restaurant_name",
    "Order ID": "Order_ID",
    "Order Placed At": "Order_Placed_At",
    "Order Status": "Order_Status",
    "Items in order": "Items_in_order",
    "Discount construct": "Discount_construct",
    "Bill subtotal": "Bill_subtotal",
    "Packaging charges": "Packaging_charges",
    "Restaurant discount (Promo)": "Restaurant_discount_Promo",
    "Restaurant discount (Flat offs, Freebies & others)": "Restaurant_discount_Flat",
    "Gold discount": "Gold_discount",
    "Brand pack discount": "Brand_pack_discount",
    "Cancellation / Rejection reason": "Cancellation_Rejection_reason",
    "Restaurant compensation (Cancellation)": "Restaurant_compensation_Cancellation",
    "Restaurant penalty (Rejection)": "Restaurant_penalty_Rejection",
    "KPT duration (minutes)": "KPT_duration_minutes",
    "Rider wait time (minutes)": "Rider_wait_time_minutes",
    "Order Ready Marked": "Order_Ready_Marked",
    "Customer complaint tag": "Customer_complaint_tag",
    "Customer ID": "Customer_ID"
})

# -----------------------------
# 5. Replace pandas NaN with None
# -----------------------------
df = df.astype(object).where(pd.notna(df), None)

# -----------------------------
# 6. Prepare INSERT query
# -----------------------------
insert_query = """
INSERT INTO food_delivery_orders (
    Restaurant_ID,
    Restaurant_name,
    Subzone,
    City,
    Order_ID,
    Order_Placed_At,
    OrderTime,
    OrderDate,
    Order_Status,
    Delivery,
    Distance,
    DistanceKM,
    Items_in_order,
    Item_Count,
    Instructions,
    Discount_construct,
    Bill_subtotal,
    Packaging_charges,
    Restaurant_discount_Promo,
    Restaurant_discount_Flat,
    Gold_discount,
    Brand_pack_discount,
    Total,
    Rating,
    Review,
    Cancellation_Rejection_reason,
    Restaurant_compensation_Cancellation,
    Restaurant_penalty_Rejection,
    KPT_duration_minutes,
    Rider_wait_time_minutes,
    Order_Ready_Marked,
    Customer_complaint_tag,
    Customer_ID
)
VALUES (
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
)
"""
# -----------------------------
# 7. Convert DataFrame to rows
# -----------------------------
rows = list(df.itertuples(index=False, name=None))

# -----------------------------
# 8. Insert all rows
# -----------------------------
cursor.executemany(insert_query, rows)

connection.commit()

print("Rows inserted:", cursor.rowcount)

# -----------------------------
# 9. Verify row count
# -----------------------------
cursor.execute("SELECT COUNT(*) FROM food_delivery_orders")

total_rows = cursor.fetchone()[0]

print("Rows currently in MySQL:", total_rows)

# -----------------------------
# 10. Close connection
# -----------------------------
cursor.close()
connection.close()

print("MySQL import completed successfully!")


print(df["Item_Count"].head(10))
print("Non-null Item_Count:", df["Item_Count"].notna().sum())