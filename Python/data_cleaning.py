import pandas as pd
import re

df = pd.read_csv("food_delivery_cleaned.csv")

# Remove unwanted empty columns
df = df.drop(columns=["Unnamed: 33", "Unnamed: 34"])

df["Item_Count"] = (
    df["Items in order"]
    .fillna("")
    .apply(lambda x: len([item for item in x.split(",") if item.strip()]))
)

df["Item_Count"] = df["Item_Count"].astype(int)
print("\nItem Count:")
print(df[["Items in order", "Item_Count"]].head(10))

print("\nItem Count Data Type:")
print(df["Item_Count"].dtype)

print("\nMissing Item Count:")
print(df["Item_Count"].isna().sum())

print("\n Dataset Shape:")
print(df.shape)
print("------------------------")

print("\n Missing Values:")
print(df.isnull().sum())

print("\nRows with missing OrderTime:")
print(df[df["OrderTime"].isna()])

print("\nRows with missing OrderDate:")
print(df[df["OrderDate"].isna()])

df["OrderTime"] = pd.to_datetime(df["OrderTime"], errors="coerce")
df["OrderDate"] = pd.to_datetime(df["OrderDate"], errors="coerce")

numeric_columns = [
    "DistanceKM",
    "Item_Count",
    "Bill subtotal",
    "Packaging charges",
    "Restaurant discount (Promo)",
    "Restaurant discount (Flat offs, Freebies & others)",
    "Gold discount",
    "Brand pack discount",
    "Total",
    "Rating",
    "KPT duration (minutes)",
    "Rider wait time (minutes)"
]

print("\nNumeric Data Types:")
print(df[numeric_columns].dtypes)
print("--------------------------")

df = df.drop(index=21321)
print("New Dataset Shape:")
print(df.shape)
print(df[["OrderTime", "OrderDate"]].isnull().sum())

df["Instructions"] = df["Instructions"].fillna("No Instructions")

df["Discount construct"] = df["Discount construct"].fillna("No Discount")

df["Review"] = df["Review"].fillna("No Review")

df["Cancellation / Rejection reason"] = df["Cancellation / Rejection reason"].fillna("Not Applicable")

df["Customer complaint tag"] = df["Customer complaint tag"].fillna("No Complaint")

df["Restaurant compensation (Cancellation)"] = df["Restaurant compensation (Cancellation)"].fillna(0)

df["Restaurant penalty (Rejection)"] = df["Restaurant penalty (Rejection)"].fillna(0)

print("\nMissing Values After Handling:")
print(df.isna().sum())

print("Rating values:")
print(df["Rating"].value_counts().sort_index())

print("\nItem Count values:")
print(df["Item_Count"].value_counts().sort_index())

print("\nKPT Duration:")
print(df["KPT duration (minutes)"].describe())

print("\nRider Wait Time:")
print(df["Rider wait time (minutes)"].describe())

print(df["Item_Count"].head(20))
print(df["Item_Count"].dtype)
print(df["Item_Count"].isna().sum())

financial_columns = [
    "Bill subtotal",
    "Packaging charges",
    "Restaurant discount (Promo)",
    "Restaurant discount (Flat offs, Freebies & others)",
    "Gold discount",
    "Brand pack discount",
    "Total"
]

print("\nFinancial Columns Summary:")
print(df[financial_columns].describe())

print("\nRows with missing financial values:")
print(df[df[financial_columns].isna().any(axis=1)])

df.to_csv("food_delivery_final.csv", index=False)

print("\nFinal dataset saved successfully!")

print("Rows:", len(df))
print("Columns:", len(df.columns))
print(df.shape)