import streamlit as st
import pyodbc
import pandas as pd
import plotly.express as px
import platform

# Page Layout
st.set_page_config(page_title="Fabric Sales Analytics", layout="wide")

# Connection Function with OS detection
def get_conn():
    f = st.secrets["fabric"]
    
    # OS detect karke sahi driver select karna
    if platform.system() == "Windows":
        driver = '{ODBC Driver 18 for SQL Server}'
    else:
        # Streamlit Cloud (Linux) ke liye Driver 17 lazmi hai
        driver = '{ODBC Driver 17 for SQL Server}'
    
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

@st.cache_data
def run_query(query):
    with get_conn() as conn:
        return pd.read_sql(query, conn)

st.title("📊 Fabric Sales Executive Dashboard")
st.markdown("---")

try:
    # 1. Corrected Query
    query = """
    SELECT 
        f.OrderNumber,
        f.OrderQuantity,
        p.CategoryName as ProductCategory, 
        p.ProductPrice,
        (f.OrderQuantity * p.ProductPrice) as SalesAmount,
        t.Country as TerritoryCountry,
        c.Year as OrderYear,
        c.Month_Name as OrderMonth,
        c.Month as MonthNum
    FROM [gold].[Fact_Sales] f
    LEFT JOIN [gold].[Dim_Product] p ON f.ProductKey = p.ProductKey
    LEFT JOIN [gold].[Dim_Territory] t ON f.TerritoryKey = t.SalesTerritoryKey
    LEFT JOIN [gold].[Dim_Calendar] c ON f.OrderDate = c.Date
    """
    df = run_query(query)

    # 2. Key Metrics (KPIs)
    col1, col2, col3, col4 = st.columns(4)
    
    total_rev = df['SalesAmount'].sum()
    total_orders = df['OrderNumber'].nunique()
    total_qty = df['OrderQuantity'].sum()
    avg_order = total_rev / total_orders if total_orders > 0 else 0
    
    col1.metric("Total Revenue", f"${total_rev:,.0f}")
    col2.metric("Total Orders", f"{total_orders:,}")
    col3.metric("Items Sold", f"{total_qty:,}")
    col4.metric("Avg Order Value", f"${avg_order:,.2f}")

    st.markdown("---")

    # 3. Visualizations
    row1_1, row1_2 = st.columns(2)

    with row1_1:
        st.subheader("📦 Revenue by Product Category")
        cat_df = df.groupby('ProductCategory')['SalesAmount'].sum().reset_index().sort_values('SalesAmount', ascending=False)
        fig1 = px.bar(cat_df, x='ProductCategory', y='SalesAmount', color='ProductCategory', template="plotly_dark")
        st.plotly_chart(fig1, use_container_width=True)

    with row1_2:
        st.subheader("🌎 Sales Distribution by Country")
        geo_df = df.groupby('TerritoryCountry')['SalesAmount'].sum().reset_index()
        fig2 = px.pie(geo_df, values='SalesAmount', names='TerritoryCountry', hole=0.4, template="plotly_dark")
        st.plotly_chart(fig2, use_container_width=True)

    st.markdown("---")

    # 4. Monthly Trend
    st.subheader("📈 Monthly Revenue Trend")
    trend_df = df.groupby(['OrderYear', 'MonthNum', 'OrderMonth'])['SalesAmount'].sum().reset_index()
    trend_df = trend_df.sort_values(['OrderYear', 'MonthNum'])
    
    fig3 = px.line(trend_df, x='OrderMonth', y='SalesAmount', color='OrderYear', markers=True, template="plotly_dark")
    st.plotly_chart(fig3, use_container_width=True)

except Exception as e:
    st.error(f"Error: {e}")