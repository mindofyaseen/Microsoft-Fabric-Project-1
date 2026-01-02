import streamlit as st
import pyodbc
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="Fabric Sales Analytics", layout="wide")

def get_conn():
    f = st.secrets["fabric"]
    
    # List of drivers to try
    drivers = [
        '{ODBC Driver 17 for SQL Server}',
        '{ODBC Driver 18 for SQL Server}',
        '{FreeTDS}'
    ]
    
    last_error = None
    for driver in drivers:
        try:
            conn_str = (
                f'DRIVER={driver};'
                f'SERVER={f["server"]};'
                f'DATABASE={f["database"]};'
                f'UID={f["username"]};'
                f'PWD={f["password"]};'
                f'Authentication=ActiveDirectoryPassword;'
                f'Encrypt=yes;'
                f'TrustServerCertificate=no;'
            )
            return pyodbc.connect(conn_str)
        except Exception as e:
            last_error = e
            continue
    
    st.error(f"Could not connect using any driver. Last error: {last_error}")
    return None

@st.cache_data
def run_query(query):
    conn = get_conn()
    if conn:
        df = pd.read_sql(query, conn)
        conn.close()
        return df
    return None

st.title("📊 Fabric Sales Executive Dashboard")

# Analytics logic... (Baqi code wahi rahega)
try:
    query = """
    SELECT 
        f.OrderNumber, f.OrderQuantity,
        p.CategoryName as ProductCategory, p.ProductPrice,
        (f.OrderQuantity * p.ProductPrice) as SalesAmount,
        t.Country as TerritoryCountry,
        c.Year as OrderYear, c.Month_Name as OrderMonth, c.Month as MonthNum
    FROM [gold].[Fact_Sales] f
    LEFT JOIN [gold].[Dim_Product] p ON f.ProductKey = p.ProductKey
    LEFT JOIN [gold].[Dim_Territory] t ON f.TerritoryKey = t.SalesTerritoryKey
    LEFT JOIN [gold].[Dim_Calendar] c ON f.OrderDate = c.Date
    """
    df = run_query(query)

    if df is not None:
        col1, col2, col3 = st.columns(3)
        col1.metric("Total Revenue", f"${df['SalesAmount'].sum():,.0f}")
        col2.metric("Total Orders", f"{df['OrderNumber'].nunique():,}")
        col3.metric("Items Sold", f"{df['OrderQuantity'].sum():,}")
        
        st.plotly_chart(px.bar(df.groupby('ProductCategory')['SalesAmount'].sum().reset_index(), 
                               x='ProductCategory', y='SalesAmount', template="plotly_dark"))
except Exception as e:
    st.error(f"Dashboard Error: {e}")