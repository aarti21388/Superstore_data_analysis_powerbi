import pandas as pd

df=pd.read_csv("superstore_final_dataset.csv",parse_dates=['Order_Date','Ship_Date'],dayfirst=True)

df_cleaned=df.drop_duplicates(subset=df.columns.difference(["Row_ID"]))


df_cleaned.dropna(subset=['Postal_Code'], inplace=True)

print(df_cleaned.isnull().sum())

df_cleaned['Postal_Code']=df_cleaned['Postal_Code'].astype(int)

df_cleaned['Order_Date']=pd.to_datetime(df_cleaned['Order_Date'])

df_cleaned['Ship_Date']=pd.to_datetime(df_cleaned['Ship_Date'])

df_cleaned['ship_after_order']=df_cleaned['Order_Date']<=df_cleaned['Ship_Date']
print(df_cleaned)
print(df_cleaned['ship_after_order'].unique())
print(df_cleaned['ship_after_order'].nunique())
print(df_cleaned['ship_after_order'].value_counts())
df_cleaned['same']=df_cleaned['Order_Date']==df_cleaned['Ship_Date']
print(df_cleaned['same'].value_counts())
df_cleaned.to_csv('superstore.csv',encoding='UTF-8',index=False)

