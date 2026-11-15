from sqlalchemy import URL, create_engine, text

connect_url = URL.create(
    "mssql+pyodbc",
    query={
        "odbc_connect": (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            r"SERVER=(local)\SQLEXPRESS;"
            "DATABASE=Datawarehouse;"
            "Trusted_Connection=yes;"
            "TrustServerCertificate=yes;"
        )
    },
)

engine = create_engine(connect_url, pool_pre_ping=True)


try:
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
        print("The connection is successfully completed!")
except Exception as e:
    print(f"Connection failed: {e}")