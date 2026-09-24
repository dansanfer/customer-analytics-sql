import os
import streamlit as st
import pandas as pd
import plotly.express as px
from sqlalchemy import create_engine

st.set_page_config(
    page_title="Customer Analytics & Retention Dashboard",
    page_icon="📊",
    layout="wide"
)

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "postgres")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "customer_analytics")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

@st.cache_resource
def get_database_connection():
    return create_engine(DATABASE_URL)

@st.cache_data(ttl=600)
def load_data():
    engine = get_database_connection()
    cohort_df = pd.read_sql("SELECT * FROM mv_cohort_retention ORDER BY cohort_month, month_number;", engine)
    rfm_df = pd.read_sql("SELECT * FROM mv_rfm_segmentation ORDER BY total_score DESC;", engine)
    return cohort_df, rfm_df

try:
    cohort_df, rfm_df = load_data()
except Exception as e:
    st.error(f"Erro ao ligar ao PostgreSQL: {e}")
    st.info("Certifique-se de que o serviço do PostgreSQL está ativo e as Materialized Views foram criadas.")
    st.stop()


st.title("📊 Customer Analytics & Retention Dashboard")
st.markdown("Monitorização de retenção por coorte e segmentação comportamental RFM sobre dados transacionais.")

total_customers = len(rfm_df)
total_revenue = rfm_df['monetary_total'].sum()
avg_ticket = rfm_df['monetary_total'].mean()
vip_customers = len(rfm_df[rfm_df['customer_segment'] == 'VIP / Campeão'])

col1, col2, col3, col4 = st.columns(4)
col1.metric("Total Clientes", f"{total_customers}")
col2.metric("Receita Total", f"R$ {total_revenue:,.2f}")
col3.metric("Ticket Médio / Cliente", f"R$ {avg_ticket:,.2f}")
col4.metric("Clientes VIP", f"{vip_customers} ({vip_customers/total_customers*100:.1f}%)")

st.divider()


st.subheader("1. Análise de Retenção de Coorte (Mês a Mês)")
st.caption("Percentagem de utilizadores ativos nos meses subsequentes à primeira transação.")

cohort_pivot = cohort_df.pivot(
    index='cohort_month', 
    columns='month_number', 
    values='retention_rate_pct'
)

fig_cohort = px.imshow(
    cohort_pivot,
    labels=dict(x="Mês Relativo (0 = Aquisição)", y="Mês da Coorte", color="Retenção (%)"),
    text_auto=".1f",
    aspect="auto",
    color_continuous_scale="Blues"
)
fig_cohort.update_layout(xaxis_title="Período Relativo (Meses decorridos)", yaxis_title="Coorte")
st.plotly_chart(fig_cohort, use_container_width=True)

st.divider()

st.subheader("2. Segmentação Comportamental RFM")

col_left, col_right = st.columns([1, 1])

with col_left:
    segment_counts = rfm_df['customer_segment'].value_counts().reset_index()
    segment_counts.columns = ['Segmento', 'Quantidade']
    
    fig_segments = px.pie(
        segment_counts, 
        values='Quantidade', 
        names='Segmento',
        title="Distribuição da Base de Clientes por Segmento",
        hole=0.4,
        color_discrete_sequence=px.colors.qualitative.Safe
    )
    st.plotly_chart(fig_segments, use_container_width=True)

with col_right:
    fig_scatter = px.scatter(
        rfm_df,
        x='recency_days',
        y='monetary_total',
        size='frequency',
        color='customer_segment',
        hover_name='customer_id',
        labels={
            'recency_days': 'Recência (Dias sem comprar)',
            'monetary_total': 'Valor Total Transacionado (R$)',
            'frequency': 'Frequência',
            'customer_segment': 'Segmento'
        },
        title="Recência vs. Valor Monetário (Tamanho da bolha = Frequência)"
    )
    st.plotly_chart(fig_scatter, use_container_width=True)

st.markdown("### Consulta Detalhada de Clientes")
selected_segment = st.selectbox("Filtrar por Segmento:", ["Todos"] + list(rfm_df['customer_segment'].unique()))

filtered_df = rfm_df if selected_segment == "Todos" else rfm_df[rfm_df['customer_segment'] == selected_segment]
st.dataframe(filtered_df, use_container_width=True)